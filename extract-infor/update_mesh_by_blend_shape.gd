@tool
extends Control

# UI控件引用
var array_mesh_path_edit: LineEdit
var blend_shape_path_edit: LineEdit
var blend_shape_dropdown: OptionButton
var blend_shape_value_spin: SpinBox
var output_path_edit: LineEdit
var apply_btn: Button
var status_label: Label

# 配置文件路径
const CONFIG_PATH = "res://addons/blend_shape_adjuster/config.cfg"

# 初始化UI
func _ready():
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)
	
	# 标题
	var title_label = Label.new()
	title_label.text = "Blend Shape Adjuster"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	# ArrayMesh 文件选择
	var array_mesh_group = create_file_group("ArrayMesh File:", "_on_array_mesh_browse")
	array_mesh_path_edit = array_mesh_group[0]
	vbox.add_child(array_mesh_group[1])
	
	# Blend Shape 文件选择
	var blend_shape_group = create_file_group("Blend Shape File:", "_on_blend_shape_browse")
	blend_shape_path_edit = blend_shape_group[0]
	vbox.add_child(blend_shape_group[1])
	
	# Blend Shape 名称下拉框
	var blend_shape_name_hbox = HBoxContainer.new()
	vbox.add_child(blend_shape_name_hbox)
	
	var blend_shape_name_label = Label.new()
	blend_shape_name_label.text = "Blend Shape Name:"
	blend_shape_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blend_shape_name_label.size_flags_stretch_ratio = 0.3
	blend_shape_name_hbox.add_child(blend_shape_name_label)
	
	blend_shape_dropdown = OptionButton.new()
	blend_shape_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blend_shape_name_hbox.add_child(blend_shape_dropdown)
	
	# Blend Shape 值调整
	var blend_shape_value_hbox = HBoxContainer.new()
	vbox.add_child(blend_shape_value_hbox)
	
	var blend_shape_value_label = Label.new()
	blend_shape_value_label.text = "Blend Shape Value:"
	blend_shape_value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blend_shape_value_label.size_flags_stretch_ratio = 0.3
	blend_shape_value_hbox.add_child(blend_shape_value_label)
	
	blend_shape_value_spin = SpinBox.new()
	blend_shape_value_spin.min_value = 0.0
	blend_shape_value_spin.max_value = 1.0
	blend_shape_value_spin.step = 0.01
	blend_shape_value_spin.value = 0.5
	blend_shape_value_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blend_shape_value_hbox.add_child(blend_shape_value_spin)
	
	# 输出文件路径
	var output_group = create_file_group("Output File:", "_on_output_browse")
	output_path_edit = output_group[0]
	vbox.add_child(output_group[1])
	
	# 应用按钮
	apply_btn = Button.new()
	apply_btn.text = "Apply and Save"
	apply_btn.pressed.connect(_on_apply_pressed)
	vbox.add_child(apply_btn)
	
	# 状态标签
	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(status_label)
	
	# 加载上次的路径
	load_config()
	
	# 如果已经选择了Blend Shape文件，更新下拉框
	if blend_shape_path_edit.text != "":
		update_blend_shape_dropdown()

# 创建文件选择组件的辅助函数
func create_file_group(label_text: String, btn_callback: String) -> Array:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 0.3
	hbox.add_child(label)
	
	var path_edit = LineEdit.new()
	path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(path_edit)
	
	var btn = Button.new()
	btn.text = "Browse"
	btn.pressed.connect(Callable(self, btn_callback))
	hbox.add_child(btn)
	
	return [path_edit, hbox]

# 文件浏览按钮回调
func _on_array_mesh_browse():
	show_file_dialog("Select ArrayMesh File", PackedStringArray(["*.tres ; ArrayMesh Resource Files"]), "_on_array_mesh_selected", FileDialog.FILE_MODE_OPEN_FILE)

func _on_blend_shape_browse():
	show_file_dialog("Select Blend Shape File", PackedStringArray(["*.tres ; Resource Files"]), "_on_blend_shape_selected", FileDialog.FILE_MODE_OPEN_FILE)

func _on_output_browse():
	show_file_dialog("Save Output File", PackedStringArray(["*.tres ; ArrayMesh Resource Files"]), "_on_output_selected", FileDialog.FILE_MODE_SAVE_FILE)

# 显示文件对话框
func show_file_dialog(title: String, filters: PackedStringArray, callback: String, mode: FileDialog.FileMode):
	var dialog = FileDialog.new()
	dialog.file_mode = mode
	dialog.access = FileDialog.ACCESS_RESOURCES
	#dialog.resizable = true
	dialog.title = title
	dialog.filters = filters
	dialog.file_selected.connect(Callable(self, callback))
	
	# 添加到场景树并显示
	get_tree().root.add_child(dialog)
	dialog.popup_centered_ratio(0.7)
	
	# 对话框关闭后自动清理
	#dialog.popup_hide.connect(dialog.queue_free)

# 文件选择回调
func _on_array_mesh_selected(path):
	array_mesh_path_edit.text = path
	save_config()

func _on_blend_shape_selected(path):
	blend_shape_path_edit.text = path
	save_config()
	update_blend_shape_dropdown()

func _on_output_selected(path):
	output_path_edit.text = path
	save_config()

# 更新Blend Shape下拉框
func update_blend_shape_dropdown():
	blend_shape_dropdown.clear()
	
	if blend_shape_path_edit.text == "":
		return
	
	var blend_shape_data = ResourceLoader.load(blend_shape_path_edit.text)
	if blend_shape_data == null:# or not blend_shape_data.has("blend_shapes"):
		set_status("Invalid Blend Shape file: " + blend_shape_path_edit.text, true)
		return
	
	for shape_name in blend_shape_data.blend_shapes:
		blend_shape_dropdown.add_item(shape_name)
	
	if blend_shape_dropdown.item_count > 0:
		blend_shape_dropdown.select(0)

# 应用并保存按钮回调
func _on_apply_pressed():
	# 验证输入
	if array_mesh_path_edit.text == "":
		set_status("ArrayMesh file not selected!", true)
		return
	
	if blend_shape_path_edit.text == "":
		set_status("Blend Shape file not selected!", true)
		return
	
	if output_path_edit.text == "":
		set_status("Output file not selected!", true)
		return
	
	if blend_shape_dropdown.item_count == 0:
		set_status("No Blend Shapes found!", true)
		return
	
	# 加载资源
	var array_mesh = ResourceLoader.load(array_mesh_path_edit.text)
	if array_mesh == null or not array_mesh is ArrayMesh:
		set_status("Invalid ArrayMesh file: " + array_mesh_path_edit.text, true)
		return
	
	var blend_shape_data = ResourceLoader.load(blend_shape_path_edit.text)
	if blend_shape_data == null or not blend_shape_data.has("blend_shapes"):
		set_status("Invalid Blend Shape file: " + blend_shape_path_edit.text, true)
		return
	
	# 获取选中的Blend Shape名称
	var selected_idx = blend_shape_dropdown.get_selected_id()
	if selected_idx == -1:
		set_status("No Blend Shape selected!", true)
		return
	
	var selected_shape = blend_shape_dropdown.get_item_text(selected_idx)
	var blend_shape_value = blend_shape_value_spin.value
	
	# 处理网格
	var modified_mesh = apply_blend_shape(array_mesh, blend_shape_data, selected_shape, blend_shape_value)
	
	if modified_mesh:
		# 保存结果 - 注意参数顺序：资源在前，路径在后
		var error = ResourceSaver.save(modified_mesh, output_path_edit.text)
		if error == OK:
			set_status("Successfully saved modified mesh to: " + output_path_edit.text)
		else:
			set_status("Failed to save mesh: Error " + str(error), true)
	else:
		set_status("Failed to apply Blend Shape", true)

# 应用Blend Shape到网格
func apply_blend_shape(mesh: ArrayMesh, blend_shape_data, shape_name: String, value: float) -> ArrayMesh:
	# 创建网格副本
	var new_mesh = mesh.duplicate()
	
	# 获取基础顶点数据
	var surface_count = new_mesh.get_surface_count()
	if surface_count == 0:
		set_status("Mesh has no surfaces", true)
		return null
	
	# 检查Blend Shape数据是否存在
	if not blend_shape_data.blend_shapes.has(shape_name):
		set_status("Blend Shape not found: " + shape_name, true)
		return null
	
	var blend_shape = blend_shape_data.blend_shapes[shape_name]
	
	# 处理每个表面
	for surface_idx in range(surface_count):
		# 获取原始表面数据
		var arrays = new_mesh.surface_get_arrays(surface_idx)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		
		# 检查顶点数量是否匹配
		if vertices.size() != blend_shape.size():
			set_status("Vertex count mismatch: Mesh surface %d has %d vertices, Blend Shape has %d" % [
				surface_idx, vertices.size(), blend_shape.size()
			], true)
			continue
		
		# 应用Blend Shape
		for i in range(vertices.size()):
			# 线性插值: new_vertex = original_vertex + (blend_shape_vertex - original_vertex) * value
			vertices[i] = vertices[i].lerp(blend_shape[i], value)
		
		# 更新顶点数组
		arrays[Mesh.ARRAY_VERTEX] = vertices
		
		# 重新创建表面
		new_mesh.surface_remove(surface_idx)
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return new_mesh

# 设置状态信息
func set_status(message: String, is_error: bool = false):
	status_label.text = message
	if is_error:
		status_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	else:
		status_label.add_theme_color_override("font_color", Color(0.2, 1, 0.2))

# 保存配置
func save_config():
	var config = ConfigFile.new()
	
	config.set_value("paths", "array_mesh", array_mesh_path_edit.text)
	config.set_value("paths", "blend_shape", blend_shape_path_edit.text)
	config.set_value("paths", "output", output_path_edit.text)
	
	var err = config.save(CONFIG_PATH)
	if err != OK:
		push_error("Failed to save config: " + str(err))

# 加载配置
func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	if err == OK:
		array_mesh_path_edit.text = config.get_value("paths", "array_mesh", "")
		blend_shape_path_edit.text = config.get_value("paths", "blend_shape", "")
		output_path_edit.text = config.get_value("paths", "output", "")
