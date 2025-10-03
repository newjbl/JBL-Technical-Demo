@tool
extends Control

const tmp_dir = "res://tmp_glb"

var file_dialog: FileDialog
var gdir_dialog: FileDialog
var selected_files = []
var goutput_dir = ""
var progress: ProgressBar
var tlog: TextEdit
var import_btn: Button
var config: ConfigFile
var file_edit: LineEdit
var dir_edit: LineEdit

var ctrl_infor_0: CheckBox
var ctrl_infor_1: CheckBox
var ctrl_infor_2: CheckBox
var ctrl_infor_3: CheckBox
var mesh_type:String = 'tres'
var texture_type:String = ''
var texture_compress:bool = false
var has_export_tex:bool = false
var blend_json_copy:bool = false


func _ready():
	# 主界面尺寸
	custom_minimum_size = Vector2(1000, 800)
	# 创建主UI
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.size.x = 800
	add_child(vbox)
	# 文件选择部分
	var file_hbox = HBoxContainer.new()
	file_hbox.size.x = 800
	vbox.add_child(file_hbox)
	var file_label = Label.new()
	file_label.text = "GLB Files:"
	file_label.custom_minimum_size.x = 120
	file_hbox.add_child(file_label)
	file_edit = LineEdit.new()
	file_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	file_edit.editable = false
	file_edit.placeholder_text = "Select GLB files..."
	file_edit.size.x = 600
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
	var ctl_hbox = HBoxContainer.new()
	vbox.add_child(ctl_hbox)
	ctrl_infor_0 = CheckBox.new()
	ctrl_infor_0.text = 'if save mesh to *.res'
	ctrl_infor_1 = CheckBox.new()
	ctrl_infor_1.text = 'if convert texture to webp'
	ctrl_infor_2 = CheckBox.new()
	ctrl_infor_2.text = 'if texture loss compress'
	ctrl_infor_3 = CheckBox.new()
	ctrl_infor_3.text = 'if add a blend json copy'
	ctl_hbox.add_child(ctrl_infor_0)
	ctl_hbox.add_child(ctrl_infor_1)
	ctl_hbox.add_child(ctrl_infor_2)
	ctl_hbox.add_child(ctrl_infor_3)
	ctrl_infor_0.toggled.connect(update_check_box.bind(0))
	ctrl_infor_1.toggled.connect(update_check_box.bind(1))
	ctrl_infor_2.toggled.connect(update_check_box.bind(2))
	ctrl_infor_3.toggled.connect(update_check_box.bind(3))
	
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
	tlog = TextEdit.new()
	tlog.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tlog.editable = false
	vbox.add_child(tlog)
	# 设置文件对话框 (600x400)
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = PackedStringArray(["*.glb ; GLB Files"])
	file_dialog.files_selected.connect(update_input_dir)
	file_dialog.min_size = Vector2(500, 300)
	add_child(file_dialog)
	# 设置目录对话框 (600x400)
	gdir_dialog = FileDialog.new()
	gdir_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	gdir_dialog.access = FileDialog.ACCESS_FILESYSTEM
	gdir_dialog.dir_selected.connect(update_output_dir)
	gdir_dialog.min_size = Vector2(500, 300)
	add_child(gdir_dialog)
	# 加载配置
	_load_config()

func update_check_box(pressed:bool, id:int):
	if id == 0:
		if pressed:
			mesh_type = 'res'
		else:
			mesh_type = 'tres'
	elif id == 1:
		if pressed:
			texture_type = 'webp'
		else:
			texture_type = ''
	elif id == 2:
		if pressed:
			texture_compress = true
		else:
			texture_compress = false
	elif id == 3:
		if pressed:
			blend_json_copy = true
		else:
			blend_json_copy = false
	_save_config()
	
func update_input_dir(files):
	selected_files = files
	file_edit.text = "%d files selected" % files.size()
	if files.size() > 0:
		var outdir = selected_files[0].get_base_dir()
		update_output_dir(outdir)
	# 保存选择的文件
	_save_config()
	
func update_output_dir(dir):
	goutput_dir = dir
	dir_edit.text = dir
	# 保存选择的目录
	_save_config()

func _on_browse_files():
	# 文件对话框尺寸 600x400
	file_dialog.popup_centered(Vector2i(600, 400))

func _on_browse_dir():
	# 目录对话框尺寸 600x400
	gdir_dialog.popup_centered(Vector2i(600, 400))

# 加载上次的配置
func _load_config():
	config = ConfigFile.new()
	var err = config.load("user://glb_outer_importer.cfg")
	if err == OK:
		selected_files = config.get_value("settings", "selected_files", [])
		if not selected_files.is_empty():
			file_edit.text = "%d files selected" % selected_files.size()
		goutput_dir = config.get_value("settings", "output_dir", "")
		dir_edit.text = goutput_dir
		mesh_type = config.get_value('settings', 'mesh_type', 'tres')
		texture_type = config.get_value('settings', 'texture_type', '')
		texture_compress = config.get_value('settings', 'texture_compress', false)
		blend_json_copy = config.get_value('settings', 'blend_json_copy', false)
		if mesh_type == 'res':
			ctrl_infor_0.set_pressed_no_signal(true)
		else:
			ctrl_infor_0.set_pressed_no_signal(false)
			
		if texture_type == 'webp':
			ctrl_infor_1.set_pressed_no_signal(true)
		else:
			ctrl_infor_1.set_pressed_no_signal(false)
		
		ctrl_infor_2.set_pressed_no_signal(texture_compress)
		ctrl_infor_3.set_pressed_no_signal(blend_json_copy)


# 保存当前配置
func _save_config():
	config.set_value("settings", "selected_files", selected_files)
	config.set_value("settings", "output_dir", goutput_dir)
	config.set_value("settings", "mesh_type", mesh_type)
	config.set_value("settings", "texture_type", texture_type)
	config.set_value("settings", "texture_compress", texture_compress)
	config.set_value("settings", "blend_json_copy", blend_json_copy)
	
	config.save("user://glb_outer_importer.cfg")

func create_output_dir(out_dir: String, file_path: String) -> String:
	# 1. 获取输入文件的文件名（不带路径）
	var file_name = file_path.get_file()
	# 2. 去掉扩展名
	var base_name = file_name.get_basename()
	base_name = "extract__%s"%[base_name]
	# 3. 拼接输出目录
	var new_dir_path = out_dir.path_join(base_name)
	delete_dir_recursive(new_dir_path)
	# 4. 如果目录不存在则创建
	var dir := DirAccess.open(out_dir)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(out_dir)
		dir = DirAccess.open(out_dir)
	if not dir.dir_exists(base_name):
		dir.make_dir(base_name)
	# 5. 返回新目录的绝对路径
	return ProjectSettings.globalize_path(new_dir_path)


func delete_dir_recursive(path: String) -> void:
	# 判断目录是否存在
	if not DirAccess.dir_exists_absolute(path):
		print("目录不存在: ", path)
		return
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("无法打开目录: %s" % path)
		return
	# 遍历文件和子目录
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			var sub_path = path.path_join(file_name)
			if dir.current_is_dir():
				delete_dir_recursive(sub_path)  # 递归删除子目录
			else:
				DirAccess.remove_absolute(sub_path)  # 删除文件
		file_name = dir.get_next()
	dir.list_dir_end()
	

func _on_import():
	if selected_files.is_empty() or goutput_dir.is_empty():
		_log_error("Please select files and output directory")
		return
	# 检查输出目录
	var dir = DirAccess.open(goutput_dir)
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
		var this_out_dir = create_output_dir(goutput_dir, file_path)
		_process_glb(file_path, this_out_dir)
		progress.value = (float(i + 1) / total_files) * 100
		# 允许UI更新
		await get_tree().process_frame
	_log("All files processed!")
	import_btn.disabled = false
	# 保存配置
	_save_config()

func _log(message):
	tlog.text += message + "\n"
	# 滚动到底部
	tlog.scroll_vertical = tlog.get_line_count()

func _log_error(message):
	tlog.text += "[ERROR] " + message + "\n"
	tlog.scroll_vertical = tlog.get_line_count()

func _process_glb(file_path, output_dir):
	# 加载 GLB 场景
	var glb_scene = ResourceLoader.load(file_path)
	if glb_scene == null:
		push_error("无法加载 GLB: %s" % file_path)
		return
	# 实例化场景
	var instance = glb_scene.instantiate()
	_process_scene(instance, output_dir)

func fix_mesh_tres_details(file_list:Array, keep_blend:bool=false):
	for file_path in file_list:
		var lines: PackedStringArray = []
		var f := FileAccess.open(file_path, FileAccess.READ)
		if f:
			lines = f.get_as_text().split("\n", false)
			f.close()
		if lines.size() == 0:
			return
		var new_lines: Array = []
		new_lines.append(lines[0])  # 保留第一行
		var inside_resource := false
		var valid_block: Array = []
		var _a = lines.size()
		for i in range(1, lines.size()):
			var line: String = lines[i]
			var stripped := line.strip_edges()
			if stripped == "[resource]":
				inside_resource = true
				valid_block.clear()
				valid_block.append(line)
				continue
			if inside_resource:
				if keep_blend == true:
					if i == lines.size() - 1:
						inside_resource = false
						valid_block.append(line)
						new_lines.append_array(valid_block)
						valid_block.clear()
						continue
				else:
					if "blend_shape_mode" in stripped:
						inside_resource = false
						new_lines.append_array(valid_block)
						valid_block.clear()
						continue
				if stripped.find("material") != -1:
					continue
				if keep_blend == false:
					if stripped.find("_blend_shape_names") != -1 \
					or stripped.find("blend_shapes") != -1 :
						continue  # 删除这些字段
				valid_block.append(line)
		# 覆盖写回文件
		var fw := FileAccess.open(file_path, FileAccess.WRITE)
		if fw:
			for l in new_lines:
				#print("will write:  %s" % [l])
				fw.store_line(l)
			fw.close()
	
func fix_mesh_tres(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("Cannot open directory: %s" % dir_path)
		return
	var file_list_1:Array = []
	var file_list_2:Array = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("mesh_") and file_name.ends_with(".%s"%[mesh_type]):
			copy_file(dir_path.path_join(file_name), dir_path.path_join(file_name.replace(".", "_all.")))
			file_list_1.append(dir_path.path_join(file_name))
			file_list_2.append(dir_path.path_join(file_name.replace(".", "_all.")))
		file_name = dir.get_next()
	dir.list_dir_end()
	fix_mesh_tres_details(file_list_1, false)
	fix_mesh_tres_details(file_list_2, true)

func save_blend_shape_bin(path: String, data: Dictionary) -> void:
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_var(data) # 直接保存 Godot 内部结构（支持 PackedArray）
	f.close()
	if blend_json_copy:
		save_dict_to_json(data, path.replace('.res', '.json'))


func save_dict_to_json(dict_data: Dictionary, file_path: String):
	# 将字典转换为 JSON 字符串
	var json_string = JSON.stringify(dict_data)
	# 打开文件用于写入（如果文件不存在会被创建）
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		# 将 JSON 字符串写入文件
		file.store_string(json_string)
		file.close() # 关闭文件，确保数据写入磁盘
		print("字典已成功保存到: ", file_path)
	else:
		# 处理文件打开失败的情况
		print("文件打开失败：", FileAccess.get_open_error())

func _process_scene(instance, output_dir):
	
	#for skeleton_obj in instance.find_children("*", "Skeleton3D", true):
	#	save_skeleton_to_file(skeleton_obj, output_dir.path_join("skeleton.json"))
		
		
	# 遍历所有 MeshInstance3D
	var _mesh_count = 0
	for mesh_instance in instance.find_children("*", "MeshInstance3D", true):
		var node_mesh = mesh_instance.mesh
		var node_name = mesh_instance.name
		var clean_name = node_name.replace(":", "_").replace("/", "_").replace("\\", "_")
		if node_mesh:
			var mesh_path = output_dir.path_join("mesh__%s.%s"%[clean_name, mesh_type])
			var blend_path = output_dir.path_join("blend__%s.res"%[clean_name])
			ResourceSaver.save(node_mesh, mesh_path)
			var blend_dict = _extract_blend_shape_data(node_mesh, clean_name, output_dir)
			save_blend_shape_bin(blend_path, blend_dict)
		# 处理蒙皮数据
		if mesh_instance.skin:
			var skin_path = output_dir.path_join("skin__%s.%s"%[clean_name, mesh_type])
			var err = ResourceSaver.save(mesh_instance.skin, skin_path)
			if err == OK:
				_log("Saved skin: " + skin_path)
			else:
				_log_error("Failed to save skin: " + skin_path + " (Error: " + str(err) + ")")
		
		# 处理材质数据 - 修复材质获取问题
		if node_mesh:
			# 遍历网格的所有表面
			for surface_idx in range(node_mesh.get_surface_count()):
				var mat = node_mesh.surface_get_material(surface_idx)
				if mat:
					_extract_textures(mat, clean_name, output_dir, surface_idx)
				else:
					_log("No material found for surface " + str(surface_idx) + " on " + node_name)

	fix_mesh_tres(output_dir)

func copy_file(src_path: String, dst_path: String) -> void:
	var err = DirAccess.copy_absolute(src_path, dst_path)
	if err == OK:
		print("复制成功: %s -> %s" % [src_path, dst_path])
	else:
		push_error("复制失败，错误码: %s" % err)
	
			
# 提取blend shape数据到单独资源
func _extract_blend_shape_data(mesh: ArrayMesh, _clean_name:String, _output_dir:String):
	var blend_rst = {}
	var shape_count = mesh.get_blend_shape_count()
	for sf_idx in mesh.get_surface_count():
		var blend_arrays = mesh.surface_get_blend_shape_arrays(sf_idx)
		#print("surface infor: %s, %s"%[sf_idx, blend_arrays.size()])
		for shape_idx in shape_count:
			var shape_name = mesh.get_blend_shape_name(shape_idx)
			if shape_name not in blend_rst:
				blend_rst[shape_name] = []
			blend_rst[shape_name].append(blend_arrays[shape_idx])
			#print('blend infor:%s=%s, %s, current shape size=%s'%\
			#[shape_idx, shape_name, blend_arrays[shape_idx].size(), blend_rst[shape_name].size()])
	return blend_rst
	

func convert_to_webp_same_path(src_path: String) -> void:
	var img := Image.new()
	var err = img.load(src_path)
	if err != OK:
		push_error("加载图片失败: %s" % src_path)
		return
	# 生成目标路径（只改扩展名为 .webp）
	var dst_path = src_path.get_basename() + ".webp"
	err = img.save_webp(dst_path, texture_compress, 1.0) # 0.9 表示高质量
	if err != OK:
		push_error("保存 WebP 失败: %s" % dst_path)
	else:
		print("已保存 WebP:", dst_path)


# 添加 surface_index 参数以区分同一网格的不同表面
func _extract_textures(mat, base_name, output_dir, surface_index=0):
	print('process texture:%s' % [base_name])
	var textures = []
	var suffix = "_surface_" + str(surface_index)
	if mat is StandardMaterial3D:
		if mat.albedo_texture:
			textures.append({
				"texture": mat.albedo_texture,
				"type": "diffuse",
				"path": output_dir.path_join("mat_diffuse_%s_%s.png"%[base_name, suffix])
			})
		if mat.normal_texture:
			textures.append({
				"texture": mat.normal_texture,
				"type": "normal",
				"path": output_dir.path_join("mat_normal_%s_%s.png"%[base_name, suffix])
			})
		if mat.metallic_texture:
			textures.append({
				"texture": mat.metallic_texture,
				"type": "metallic",
				"path": output_dir.path_join("mat__metallic_%s_%s.png"%[base_name, suffix])
			})
		if mat.roughness_texture:
			textures.append({
				"texture": mat.roughness_texture,
				"type": "roughness",
				"path": output_dir.path_join("mat__roughness_%s_%s.png"%[base_name, suffix])
			})
		if mat.emission_texture:
			textures.append({
				"texture": mat.emission_texture,
				"type": "emission",
				"path": output_dir.path_join("mat__emission_%s_%s.png"%[base_name, suffix])
			})
		if mat.ao_texture:
			textures.append({
				"texture": mat.ao_texture,
				"type": "ao",
				"path": output_dir.path_join("mat__ao_%s_%s.png"%[base_name, suffix])
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
					"path": output_dir.path_join("mat__%s_%s_%s.png" % [base_name, tex_type, suffix])
				})
	# 保存所有纹理
	for tex_data in textures:
		_save_texture(tex_data.texture, tex_data.path)
		#if texture_type == 'webp':
		#	convert_to_webp_same_path(tex_data.path)

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
			if texture_type == 'webp':
				# 生成目标路径（只改扩展名为 .webp）
				var dst_path = dir_path.get_basename() + ".webp"
				var err = img.save_webp(dst_path, texture_compress, 1.0) # 0.9 表示高质量
				if err != OK:
					push_error("保存 WebP 失败: %s" % dst_path)
				else:
					print("已保存 WebP:", dst_path)
			else:
				var err = img.save_png(path)
				if err == OK:
					_log("Saved texture: " + path)
				else:
					_log_error("Failed to save texture: " + path + " (Error: " + str(err) + ")")
	elif texture is CompressedTexture2D:
		#_log_error("Cannot save compressed texture: " + texture.resource_path)
		copy_image_file(texture.resource_path, path)

func copy_image_file(src_path: String, dst_path: String) -> void:
	if texture_type == 'webp':
		var tex := ResourceLoader.load(src_path)
		var img:Image = null
		if tex and (tex is CompressedTexture2D or tex is Texture2D):
			img = tex.get_image()
		if img == null:
			push_error("加载图片失败: %s" % src_path)
			return
		# 生成目标路径（只改扩展名为 .webp）
		dst_path = dst_path.get_basename() + ".webp"
		var err = img.save_webp(dst_path, texture_compress, 1.0) # 0.9 表示高质量
		if err != OK:
			push_error("保存 WebP 失败: %s" % dst_path)
		else:
			print("已保存 WebP:", dst_path)
	else:
		var err = DirAccess.copy_absolute(src_path, dst_path)
		if err != OK:
			push_error("拷贝失败: %s -> %s, 错误码: %d" % [src_path, dst_path, err])

func save_skeleton_to_file(skeleton: Skeleton3D, file_path: String) -> void:
	var skeleton_data = {
		"bones": []
	}
	var bone_count = skeleton.get_bone_count()
	for i in range(bone_count):
		var rest = skeleton.get_bone_rest(i)
		var _a = rest.basis
		var _b = rest.origin
		var r = [[rest.basis.x.x, rest.basis.x.y, rest.basis.x.z],
			[rest.basis.y.x, rest.basis.y.y, rest.basis.y.z],
			[rest.basis.z.x, rest.basis.z.y, rest.basis.z.z],
			[rest.origin.x, rest.origin.y, rest.origin.z]]
		var bone_info = {
			"name": skeleton.get_bone_name(i),
			"parent": skeleton.get_bone_parent(i),
			"rest": r
		}
		skeleton_data["bones"].append(bone_info)
	var json_text = JSON.stringify(skeleton_data, "\t")  # 带缩进的 JSON
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.close()
		print("骨骼信息已保存到: ", file_path)
	else:
		push_error("无法写入文件: %s" % file_path)
