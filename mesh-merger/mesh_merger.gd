extends Node3D

@export var mesh_1:MeshInstance3D
@export var mesh_2:MeshInstance3D
@export var show_mesh:MeshInstance3D
@export var tex_1:Texture2D
@export var tex_2:Texture2D
@export var ske:Skeleton3D
@export var SAVE_PATH:String

var rst_arraymesh:ArrayMesh = null
var rst_skin:Skin = null

var skin2_to_skin1_dic:Dictionary = {}

func _ready() -> void:
	get_skin_infor()
	update_mesh_2_infor()
	merge_meshes()
	save_mesh_to_file()
	print("finish!!!")
	#save_mesh_infor(show_mesh)
	
# 修改后的合并函数
func merge_meshes() -> void:
	if rst_arraymesh != null:
		rst_arraymesh.clear_surfaces()
	var _surface_tool := SurfaceTool.new()
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for node in [mesh_1, mesh_2]:
		#save_mesh_infor(node)
		if node is MeshInstance3D and node.mesh is ArrayMesh:
			_surface_tool.append_from(node.mesh, 0, node.transform)
	rst_arraymesh = _surface_tool.commit()
	#var _arrays:Array = rst_arraymesh.surface_get_arrays(0)

func update_mesh_2_infor() -> void:
	var _surface_tool := SurfaceTool.new()
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var new_bones:PackedInt32Array = []
	var _arrays:Array = mesh_2.mesh.surface_get_arrays(0)
	var i = 0
	while i  < _arrays[Mesh.ARRAY_WEIGHTS].size():
		if _arrays[Mesh.ARRAY_WEIGHTS][i] > 0.0:
			new_bones.append(skin2_to_skin1_dic[_arrays[Mesh.ARRAY_BONES][i]])
		i += 1
	_surface_tool.set_bones(new_bones)
	
func get_skin_infor() -> void:
	var ske_name_idx_dic_1:Dictionary = {}
	for i in mesh_1.skin.get_bind_count():
		var b_name:String = mesh_1.skin.get_bind_name(i)
		ske_name_idx_dic_1[b_name] = i
	for i in mesh_2.skin.get_bind_count():
		var b_name:String = mesh_2.skin.get_bind_name(i)
		if b_name not in ske_name_idx_dic_1:
			print('%s !!!!' % [b_name])
		skin2_to_skin1_dic[i] = ske_name_idx_dic_1[b_name]
	rst_skin = mesh_1.skin
	
func save_mesh_to_file() -> void:
	var mesh_path = SAVE_PATH + "/combined_mesh.tres"
	var skin_path = SAVE_PATH + "/combined_skin.tres"
	var tex_path = SAVE_PATH + "/combined_texture.png"
	# 保存网格
	var err = ResourceSaver.save(rst_arraymesh, mesh_path)
	if err == OK:
		print("网格保存成功：", mesh_path)
	else:
		push_error("网格保存失败：%s" % error_string(err))
	# 保存网格
	err = ResourceSaver.save(rst_skin, skin_path)
	if err == OK:
		print("skin保存成功：", skin_path)
	else:
		push_error("skin保存失败：%s" % error_string(err))

func save_text_to_file(file_path: String, content: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("写入成功：", file_path)
	else:
		print("无法打开文件进行写入：", file_path)
		
func save_mesh_infor(mesh:MeshInstance3D):
	var mesh_name:String = mesh.name
	var mesh_infor_path:String = ''
	var txt_rst:String = ''
	var _skin = mesh.skin
	if _skin != null:
		mesh_infor_path = SAVE_PATH + "/%s_skin.tres" % [mesh_name]
		txt_rst = '------------start-------------\n'
		txt_rst += '\nskin are:\n'
		for i in _skin.get_bind_count():
			#print("Bind ", i, ": ", _skin.get_bind_pose(i))
			var b_name:String = _skin.get_bind_name(i)
			txt_rst += "Bind_%s, %s : %s\n" % [i, b_name, _skin.get_bind_pose(i)]
		save_text_to_file(mesh_infor_path, txt_rst)	
		
	var arraymesh = mesh.mesh
	var _arrays:Array = arraymesh.surface_get_arrays(0)
	mesh_infor_path = SAVE_PATH + "/%s_vertex.tres" % [mesh_name]
	txt_rst = '------------start-------------\n'
	txt_rst += '\nMesh.ARRAY_VERTEX are:\n'
	for i in _arrays[Mesh.ARRAY_VERTEX]:
		txt_rst += "%s\n" % [i]
	save_text_to_file(mesh_infor_path, txt_rst)	
	
	mesh_infor_path = SAVE_PATH + "/%s_normal.tres" % [mesh_name]
	txt_rst = '------------start-------------\n'
	txt_rst += '\nMesh.ARRAY_NORMAL are:\n'
	for i in _arrays[Mesh.ARRAY_NORMAL]:
		txt_rst += "%s\n" % [i]
	save_text_to_file(mesh_infor_path, txt_rst)	
	
	mesh_infor_path = SAVE_PATH + "/%s_tangent.tres" % [mesh_name]
	txt_rst = '------------start-------------\n'
	txt_rst += '\nMesh.ARRAY_TANGENT are:\n'
	var ii = 0
	while ii + 4 <= _arrays[Mesh.ARRAY_TANGENT].size():
		txt_rst += '%s, %s, %s, %s\n' % [_arrays[Mesh.ARRAY_TANGENT][ii],
		_arrays[Mesh.ARRAY_TANGENT][ii + 1],
		_arrays[Mesh.ARRAY_TANGENT][ii + 2],
		_arrays[Mesh.ARRAY_TANGENT][ii + 3]]
		ii += 4
	save_text_to_file(mesh_infor_path, txt_rst)	
	
	
	if _arrays[Mesh.ARRAY_COLOR] != null:
		mesh_infor_path = SAVE_PATH + "/%s_color.tres" % [mesh_name]
		txt_rst = '------------start-------------\n'
		txt_rst += '\nMesh.ARRAY_COLOR are:\n'
		for i in _arrays[Mesh.ARRAY_COLOR]:
			txt_rst += "%s\n" % [i]
		save_text_to_file(mesh_infor_path, txt_rst)	
		
	if _arrays[Mesh.ARRAY_TEX_UV] != null:
		mesh_infor_path = SAVE_PATH + "/%s_uv.tres" % [mesh_name]
		txt_rst = '------------start-------------\n'
		txt_rst += '\nMesh.ARRAY_TEX_UV are:\n'
		for i in _arrays[Mesh.ARRAY_TEX_UV]:
			txt_rst += "%s\n" % [i]
		save_text_to_file(mesh_infor_path, txt_rst)	
		
	if _arrays[Mesh.ARRAY_TEX_UV2] != null:
		mesh_infor_path = SAVE_PATH + "/%s_uv2.tres" % [mesh_name]
		txt_rst = '------------start-------------\n'
		txt_rst += '\nMesh.ARRAY_TEX_UV2 are:\n'
		for i in _arrays[Mesh.ARRAY_TEX_UV2]:
			txt_rst += "%s\n" % [i]
		save_text_to_file(mesh_infor_path, txt_rst)	
		
	mesh_infor_path = SAVE_PATH + "/%s_bones.tres" % [mesh_name]
	txt_rst = '------------start-------------\n'
	txt_rst += '\nMesh.ARRAY_BONES are:\n'
	var i = 0
	while i + 4 <= _arrays[Mesh.ARRAY_BONES].size():
		txt_rst += '%s, %s, %s, %s\n' % [_arrays[Mesh.ARRAY_BONES][i],
		_arrays[Mesh.ARRAY_BONES][i + 1],
		_arrays[Mesh.ARRAY_BONES][i + 2],
		_arrays[Mesh.ARRAY_BONES][i + 3]]
		i += 4
	save_text_to_file(mesh_infor_path, txt_rst)	
	
	mesh_infor_path = SAVE_PATH + "/%s_weights.tres" % [mesh_name]
	txt_rst = '------------start-------------\n'
	txt_rst += '\nMesh.ARRAY_WEIGHTS are:\n'
	i = 0
	while i + 4 < _arrays[Mesh.ARRAY_WEIGHTS].size():
		txt_rst += '%s, %s, %s, %s\n' % [_arrays[Mesh.ARRAY_WEIGHTS][i],
		_arrays[Mesh.ARRAY_WEIGHTS][i + 1],
		_arrays[Mesh.ARRAY_WEIGHTS][i + 2],
		_arrays[Mesh.ARRAY_WEIGHTS][i + 3]]
		i += 4
	save_text_to_file(mesh_infor_path, txt_rst)	
	
	mesh_infor_path = SAVE_PATH + "/%s_index.tres" % [mesh_name]
	txt_rst = '------------start-------------\n'
	txt_rst += '\nMesh.ARRAY_INDEX are:\n'
	txt_rst += "%s\n" % [_arrays[Mesh.ARRAY_INDEX]]
	txt_rst += "\n------------start-------------\n\n\n"
	save_text_to_file(mesh_infor_path, txt_rst)
