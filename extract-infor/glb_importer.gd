@tool
extends Control

var file_dialog: FileDialog
var dir_dialog: FileDialog
var selected_files = []
var output_dir = ""
var progress: ProgressBar
var log: TextEdit
var import_btn: Button
var config: ConfigFile
var file_edit: LineEdit
var dir_edit: LineEdit

var has_export_tex:bool = false

func _ready():
	# 主界面尺寸
	custom_minimum_size = Vector2(1000, 800)
	
	# 创建主UI
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)
	
	# 文件选择部分
	var file_hbox = HBoxContainer.new()
	vbox.add_child(file_hbox)
	
	var file_label = Label.new()
	file_label.text = "GLB Files:"
	file_label.custom_minimum_size.x = 120
	file_hbox.add_child(file_label)
	
	file_edit = LineEdit.new()
	file_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_edit.editable = false
	file_edit.placeholder_text = "Select GLB files..."
	file_hbox.add_child(file_edit)
	
	var file_btn = Button.new()
	file_btn.text = "Browse"
	file_btn.pressed.connect(_on_browse_files)
	file_hbox.add_child(file_btn)
	
	# 输出目录部分
	var dir_hbox = HBoxContainer.new()
	vbox.add_child(dir_hbox)
	
	var dir_label = Label.new()
	dir_label.text = "Output Directory:"
	dir_label.custom_minimum_size.x = 120
	dir_hbox.add_child(dir_label)
	
	dir_edit = LineEdit.new()
	dir_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dir_edit.editable = false
	dir_edit.placeholder_text = "Select output directory..."
	dir_hbox.add_child(dir_edit)
	
	var dir_btn = Button.new()
	dir_btn.text = "Browse"
	dir_btn.pressed.connect(_on_browse_dir)
	dir_hbox.add_child(dir_btn)
	
	# 按钮区域
	var btn_hbox = HBoxContainer.new()
	vbox.add_child(btn_hbox)
	
	import_btn = Button.new()
	import_btn.text = "Import GLB Data"
	import_btn.pressed.connect(_on_import)
	btn_hbox.add_child(import_btn)
	
	progress = ProgressBar.new()
	progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress.max_value = 100
	progress.value = 0
	progress.visible = false
	vbox.add_child(progress)
	
	log = TextEdit.new()
	log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log.editable = false
	vbox.add_child(log)
	
	# 设置文件对话框 (600x400)
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = PackedStringArray(["*.glb ; GLB Files"])
	file_dialog.files_selected.connect(func(files): 
		selected_files = files
		file_edit.text = "%d files selected" % files.size()
		# 保存选择的文件
		_save_config()
	)
	file_dialog.min_size = Vector2(500, 300)
	add_child(file_dialog)
	
	# 设置目录对话框 (600x400)
	dir_dialog = FileDialog.new()
	dir_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dir_dialog.access = FileDialog.ACCESS_FILESYSTEM
	dir_dialog.dir_selected.connect(func(dir):
		output_dir = dir
		dir_edit.text = dir
		# 保存选择的目录
		_save_config()
	)
	dir_dialog.min_size = Vector2(500, 300)
	add_child(dir_dialog)
	
	# 加载配置
	_load_config()

func _on_browse_files():
	# 文件对话框尺寸 600x400
	file_dialog.popup_centered(Vector2i(600, 400))

func _on_browse_dir():
	# 目录对话框尺寸 600x400
	dir_dialog.popup_centered(Vector2i(600, 400))

# 加载上次的配置
func _load_config():
	config = ConfigFile.new()
	var err = config.load("user://glb_importer.cfg")
	if err == OK:
		selected_files = config.get_value("settings", "selected_files", [])
		if not selected_files.is_empty():
			file_edit.text = "%d files selected" % selected_files.size()
		
		output_dir = config.get_value("settings", "output_dir", "")
		dir_edit.text = output_dir

# 保存当前配置
func _save_config():
	config.set_value("settings", "selected_files", selected_files)
	config.set_value("settings", "output_dir", output_dir)
	config.save("user://glb_importer.cfg")

func _on_import():
	if selected_files.is_empty() or output_dir.is_empty():
		_log_error("Please select files and output directory")
		return
	
	# 检查输出目录
	var dir = DirAccess.open(output_dir)
	if dir == null:
		_log_error("Output directory does not exist or is not accessible")
		return
	
	# 禁用按钮，防止重复点击
	import_btn.disabled = true
	progress.visible = true
	progress.value = 0
	
	# 处理所有文件
	var total_files = selected_files.size()
	for i in range(total_files):
		var file_path = selected_files[i]
		_log("Processing: " + file_path)
		_process_glb(file_path, output_dir)
		progress.value = (float(i + 1) / total_files) * 100
		# 允许UI更新
		await get_tree().process_frame
	
	_log("All files processed!")
	import_btn.disabled = false
	# 保存配置
	_save_config()

func _log(message):
	log.text += message + "\n"
	# 滚动到底部
	log.scroll_vertical = log.get_line_count()

func _log_error(message):
	log.text += "[ERROR] " + message + "\n"
	log.scroll_vertical = log.get_line_count()

func _process_glb(file_path, output_dir):
	print('process file:%s' % [file_path])
	# 使用低级API加载GLB
	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	
	# 读取文件内容
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		_log_error("Failed to open file: " + file_path)
		return
	
	var buffer = file.get_buffer(file.get_length())
	file.close()
	
	# 解析GLB
	var err = gltf_doc.append_from_buffer(buffer, "", gltf_state)
	if err != OK:
		_log_error("Failed to parse GLB: " + file_path)
		return
	
	# 生成场景
	var scene = gltf_doc.generate_scene(gltf_state)
	if scene == null:
		_log_error("Failed to generate scene from GLB: " + file_path)
		return
	
	# 处理场景中的所有网格
	_process_scene(scene, output_dir)
	
	# 只释放场景节点
	scene.queue_free()

func _process_scene(scene, output_dir):
	# 获取所有MeshInstance3D节点
	var nodes = scene.find_children("*", "MeshInstance3D", true)
	if nodes.is_empty():
		_log("No MeshInstance3D nodes found")
		return
	
	# 创建目录确保存在
	var dir = DirAccess.open(output_dir)
	if dir == null:
		_log_error("Failed to access output directory: " + output_dir)
		return
	
	# 处理每个网格节点
	for node in nodes:
		var node_name = node.name
		if node_name.is_empty():
			node_name = "unnamed_" + str(randi_range(1000, 9999))
		
		# 清理节点名用于文件名
		var clean_name = node_name.replace(":", "_").replace("/", "_").replace("\\", "_")
		
		# 处理网格数据
		var node_mesh = node.mesh  # 重命名为 node_mesh 避免冲突
		if node_mesh:
			# 保存网格数据 (不包含blend shape)
			var st:SurfaceTool = SurfaceTool.new()
			var mesh_path = output_dir.path_join(clean_name + "_mesh.tres")
			var mesh_path_ = output_dir.path_join(clean_name + "_mesh_.tres")
			st.append_from(node_mesh, 0, node.transform)
			var _arraymesh:ArrayMesh = st.commit()
			var err = ResourceSaver.save(_arraymesh, mesh_path)
			err = ResourceSaver.save(node_mesh, mesh_path_)
			if err == OK:
				_log("Saved mesh: " + mesh_path)
			else:
				_log_error("Failed to save mesh: " + mesh_path + " (Error: " + str(err) + ")")
			
			# 处理BlendShapes - 单独保存blend shape数据
			if node_mesh is ArrayMesh and node_mesh.get_blend_shape_count() > 0:
				# 创建只包含blend shape数据的资源
				var shape_data = _extract_blend_shape_data(node_mesh)
				if shape_data:
					var shape_path = output_dir.path_join(clean_name + "_shape.tres")
					err = ResourceSaver.save(shape_data, shape_path)
					if err == OK:
						_log("Saved blend shapes: " + shape_path)
					else:
						_log_error("Failed to save blend shapes: " + shape_path + " (Error: " + str(err) + ")")
		
		# 处理蒙皮数据
		if node.skin:
			var skin_path = output_dir.path_join(clean_name + "_skin.tres")
			var err = ResourceSaver.save(node.skin, skin_path)
			if err == OK:
				_log("Saved skin: " + skin_path)
			else:
				_log_error("Failed to save skin: " + skin_path + " (Error: " + str(err) + ")")
		
		# 处理材质数据 - 修复材质获取问题
		if has_export_tex == false and node_mesh:
			# 遍历网格的所有表面
			for surface_idx in range(node_mesh.get_surface_count()):
				var mat = node_mesh.surface_get_material(surface_idx)
				if mat:
					_extract_textures(mat, clean_name, output_dir, surface_idx)
					has_export_tex = true
				else:
					_log("No material found for surface " + str(surface_idx) + " on " + node_name)

# 提取blend shape数据到单独资源
func _extract_blend_shape_data(mesh: ArrayMesh) -> Resource:
	var blend_shape_data = {}
	
	# 获取blend shape名称
	blend_shape_data["names"] = []
	for i in range(mesh.get_blend_shape_count()):
		blend_shape_data["names"].append(mesh.get_blend_shape_name(i))
	
	# 获取每个表面的blend shape数据
	blend_shape_data["surfaces"] = []
	for surface_idx in range(mesh.get_surface_count()):
		var surface_data = {}
		
		# 获取表面原始数组
		var blend_shape_arrays = mesh.surface_get_blend_shape_arrays(surface_idx)
		
		# 只保存blend shape相关数据
		surface_data["blend_shape_arrays"] = blend_shape_arrays
		blend_shape_data["surfaces"].append(surface_data)
	
	# 创建资源
	var resource = Resource.new()
	resource.set_meta("blend_shape_data", blend_shape_data)
	return resource

# 添加 surface_index 参数以区分同一网格的不同表面
func _extract_textures(mat, base_name, output_dir, surface_index=0):
	print('process texture:%s' % [base_name])
	var textures = []
	var suffix = "" if surface_index == 0 else "_surface" + str(surface_index)
	
	if mat is StandardMaterial3D:
		if mat.albedo_texture:
			textures.append({
				"texture": mat.albedo_texture,
				"type": "diffuse",
				"path": output_dir.path_join(base_name + suffix + "_diffuse.png")
			})
		if mat.normal_texture:
			textures.append({
				"texture": mat.normal_texture,
				"type": "normal",
				"path": output_dir.path_join(base_name + suffix + "_normal.png")
			})
		if mat.metallic_texture:
			textures.append({
				"texture": mat.metallic_texture,
				"type": "metallic",
				"path": output_dir.path_join(base_name + suffix + "_metallic.png")
			})
		if mat.roughness_texture:
			textures.append({
				"texture": mat.roughness_texture,
				"type": "roughness",
				"path": output_dir.path_join(base_name + suffix + "_roughness.png")
			})
		if mat.emission_texture:
			textures.append({
				"texture": mat.emission_texture,
				"type": "emission",
				"path": output_dir.path_join(base_name + suffix + "_emission.png")
			})
		if mat.ao_texture:
			textures.append({
				"texture": mat.ao_texture,
				"type": "ao",
				"path": output_dir.path_join(base_name + suffix + "_ao.png")
			})
	elif mat is ShaderMaterial:
		var shader_params = mat.get_shader_parameter_list()
		for param in shader_params:
			var value = mat.get_shader_parameter(param.name)
			if value is Texture2D:
				var tex_type = "texture"
				var param_name_lower = param.name.to_lower()
				if "albedo" in param_name_lower or "diffuse" in param_name_lower:
					tex_type = "diffuse"
				elif "normal" in param_name_lower:
					tex_type = "normal"
				elif "metal" in param_name_lower:
					tex_type = "metallic"
				elif "rough" in param_name_lower:
					tex_type = "roughness"
				elif "emit" in param_name_lower:
					tex_type = "emission"
				elif "ao" in param_name_lower or "ambient_occlusion" in param_name_lower:
					tex_type = "ao"
				
				textures.append({
					"texture": value,
					"type": tex_type,
					"path": output_dir.path_join(base_name + suffix + "_%s.png" % tex_type)
				})
	
	# 保存所有纹理
	for tex_data in textures:
		_save_texture(tex_data.texture, tex_data.path)

func _save_texture(texture, path):
	if texture is ImageTexture:
		var img = texture.get_image()
		if img:
			# 确保目录存在
			var dir_path = path.get_base_dir()
			if not DirAccess.dir_exists_absolute(dir_path):
				var err = DirAccess.make_dir_recursive_absolute(dir_path)
				if err != OK:
					_log_error("Failed to create directory: " + dir_path)
					return
			
			var err = img.save_png(path)
			if err == OK:
				_log("Saved texture: " + path)
			else:
				_log_error("Failed to save texture: " + path + " (Error: " + str(err) + ")")
	elif texture is CompressedTexture2D:
		_log_error("Cannot save compressed texture: " + texture.resource_path)
