extends Node

# 导出Skeleton3D节点（在Inspector面板拖拽骨骼节点到这里）
@export var skeleton: Skeleton3D

func _ready():
	# 确保skeleton引用有效
	if skeleton:
		# 获取骨骼列表
		var bone_names = get_bone_list()
		print("骨骼列表: ", bone_names)
	else:
		push_warning("未分配Skeleton3D节点！")

# 获取骨骼名称列表
func get_bone_list() -> PackedStringArray:
	var bones = PackedStringArray()
	# 遍历所有骨骼索引
	for bone_idx in skeleton.get_bone_count():
		# 获取骨骼名称并添加到数组
		bones.append(skeleton.get_bone_name(bone_idx))
	return bones

# 可选：在编辑器中实时查看骨骼列表（需启用Tool模式）
func _get_configuration_warnings() -> PackedStringArray:
	if not skeleton:
		return ["必须分配一个Skeleton3D节点"]
	return []
