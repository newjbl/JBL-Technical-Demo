@tool
extends EditorPlugin

var button
var pending_import_path : String

func _enter_tree():
	button = Button.new()
	button.text = "导入 GLB"
	button.tooltip_text = "选择外部 GLB 文件，拷贝到项目并自动导入"
	button.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)

	# 监听资源导入完成的信号
	var fs = get_editor_interface().get_resource_filesystem()
	fs.resources_reimported.connect(_on_resources_reimported)

func _exit_tree():
	if button:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
		button.queue_free()
		button = null

func _on_button_pressed():
	var dlg = EditorFileDialog.new()
	dlg.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dlg.access = EditorFileDialog.ACCESS_FILESYSTEM
	dlg.filters = PackedStringArray(["*.glb ; GLTF binary"])
	dlg.title = "选择一个 GLB 文件"
	get_editor_interface().get_base_control().add_child(dlg)
	dlg.file_selected.connect(_on_file_selected)
	dlg.popup_centered_ratio(0.6)

func _on_file_selected(path: String):
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var dst_dir = "res://tmp_glb/%s" % timestamp
	DirAccess.make_dir_recursive_absolute(dst_dir)

	var dst_path = dst_dir.path_join(path.get_file())
	var err = DirAccess.copy_absolute(path, dst_path)
	if err != OK:
		push_error("拷贝失败: %s" % err)
		return

	# 保存等待导入完成后的路径
	pending_import_path = dst_path

	# 触发导入
	#get_editor_interface().get_resource_filesystem().scan()
	print("⏳ 等待导入: %s" % dst_path)

# 当资源导入完成时调用
func _on_resources_reimported(paths: PackedStringArray):
	if pending_import_path == "":
		return
	for p in paths:
		if p == pending_import_path:
			print("✅ 导入完成: %s" % p)
			# 调用你的处理函数
			_process_glb(p, "res://processed_meshes")
			pending_import_path = ""
			break

# 这里直接放你原来的函数（也可以从其他脚本调用）
func _process_glb(file_path: String, output_dir: String):
	print(">>> process_glb called with: ", file_path, " -> ", output_dir)
	# 你的处理逻辑...
