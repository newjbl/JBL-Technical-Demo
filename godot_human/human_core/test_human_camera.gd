extends Camera3D

@export var target_path: NodePath                          # 指向 human 节点
@export var min_ortho_size: float = 0.5
@export var max_ortho_size: float = 50.0

@export var rotate_speed: float = 0.005                    # 左键旋转灵敏度（绕 Y）
@export var pan_speed: float = 0.002                       # 右键基础平移速度（会乘以 size）
@export var zoom_step: float =  -1.0                       # 每次滚轮变化量（负表示拉近）
@export var zoom_time: float = 0.22                        # 平滑缩放时间（秒）

@export var camera_distance: float = 20.0                  # 摄像机到目标的 Z 距离（正交下只是位置）

var target: Node3D = null
var pan_offset: Vector3 = Vector3.ZERO                     # 视图中心相对 target 的偏移（world）
var _tween = null                                          # 当前 tween（若有）

func _ready():
	target = get_node_or_null(target_path)
	if target == null:
		push_error("Camera target (human) not assigned!")
	if projection != PROJECTION_ORTHOGONAL:
		push_error("Camera must be set to Orthogonal projection for this script!")
	# 确保 size 在允许范围内
	size = clamp(size, min_ortho_size, max_ortho_size)
	_update_camera()

func _process(_delta):
	# 每帧更新摄像机位置（保证 tween / 平移时即时可见）
	_update_camera()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# 左键：让 human 绕 Y 轴旋转（水平拖动）
			# 用 rotate_y 做增量旋转，直观且保留原始旋转基线
			var _a = event.relative.x * rotate_speed
			target.rotate_y(event.relative.x * rotate_speed)
			# 不改变摄像机朝向（仍看向 target + pan_offset）
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# 右键：平移摄像机中心（pan_offset）
			# 使用当前摄像机的 right/up 基（global_transform.basis.x/y）
			# 乘以 size: size 小（靠近）时移动更小（更精细）
			var right = global_transform.basis.x
			var up = global_transform.basis.y
			# 这里的符号使得鼠标右移时画面向右移动（直觉）
			pan_offset += (-right * event.relative.x + up * event.relative.y) * pan_speed * size

	elif event is InputEventMouseButton and event.pressed:
		# 滚轮（向上/向下），注意使用 wheel 的常量
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_start_smooth_zoom(-abs(zoom_step))   # wheel up -> 拉近（根据 zoom_step 的符号）
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_start_smooth_zoom(abs(zoom_step))    # wheel down -> 推远
			
			
			
func _center_mouse():
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center: Vector2 = viewport_size / 2
	Input.warp_mouse(center)
	
# -------------------------
# 缩放并将鼠标指向点移到屏幕中心（平滑）
# 思路：
# 1) 计算当前鼠标在世界上的点（与经过当前 view-center 的平面相交得到）
# 2) 将目标视图中心设置为该点（即期望 pan_offset = mouse_world_point - target_origin）
# 3) 使用 tween 同步平滑插值 size 和 pan_offset（zoom_time）
# -------------------------
func _start_smooth_zoom(delta_size: float) -> void:
	if target == null:
		return

	# 1) 计算当前视图中心（world）和鼠标对应的世界点
	var current_center: Vector3 = target.global_transform.origin + pan_offset

	var vp := get_viewport()
	var mouse_pos: Vector2 = vp.get_mouse_position()
	var from: Vector3 = project_ray_origin(mouse_pos)
	var dir: Vector3 = project_ray_normal(mouse_pos)

	# 用与摄像机视线方向一致的平面（穿过 current_center）来求交点
	var plane_n: Vector3 = -global_transform.basis.z   # 摄像机观察方向（指向场景的方向）
	var denom: float = plane_n.dot(dir)

	var mouse_world_point: Vector3
	if abs(denom) > 0.00001:
		var t = plane_n.dot(current_center - from) / denom
		mouse_world_point = from + dir * t
	else:
		# 如果平行（极少见），退化处理：取射线一点（from）向前一定距离
		mouse_world_point = from + dir * 10.0

	# 2) 计算目标 size（并 clamp）
	var target_size = clamp(size + delta_size, min_ortho_size, max_ortho_size)
	if is_equal_approx(target_size, size):
		return

	# 3) 期望的 pan_offset：使得视图中心变为 mouse_world_point
	var desired_pan = mouse_world_point - target.global_transform.origin

	# 取消已有 tween（如果有）
	if _tween:
		_tween.kill()
		_tween = null

	# 4) 创建 tween，同时平滑 size（Camera3D.size）和 pan_offset（本脚本的变量）
	_tween = create_tween()
	_tween.tween_property(self, "size", target_size, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "pan_offset", desired_pan, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# tween 完成后清理引用
	_tween.tween_callback(Callable(self, "_on_zoom_tween_finished"))
	_center_mouse()

func _on_zoom_tween_finished() -> void:
	_tween = null

# -------------------------
# 每帧把摄像机放到 target + pan_offset 前方，并朝向 center
# -------------------------
func _update_camera() -> void:
	if target == null:
		return
	var center = target.global_transform.origin + pan_offset

	# 将摄像机放在 center 的前方一定距离（沿 +Z 方向），保持 look_at center
	# 注意：这里用固定的 camera_distance（可 export 调整）
	global_transform.origin = center + Vector3(0, 0, camera_distance)
	look_at(center, Vector3.UP)
