extends Node3D

@export var mesh_1:MeshInstance3D
@export var mesh_2:MeshInstance3D
@export var show_mesh:MeshInstance3D
@export var tex_1:Texture2D
@export var tex_2:Texture2D
@export var ske:Skeleton3D
@export var SAVE_PATH:String

var rst_arraymesh:ArrayMesh = null
var rst_mesh3d:MeshInstance3D = null

func _ready() -> void:
	merge_meshes()
	save_mesh_to_file()
	print("finish!!!")
	show_mesh_infor(show_mesh, 'show_mesh')
	
# 修改后的合并函数
func merge_meshes() -> void:
	if rst_arraymesh != null:
		rst_arraymesh.clear_surfaces()
	var _surface_tool := SurfaceTool.new()
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for node in [mesh_1, mesh_2]:
		show_mesh_infor(node, str(node))
		if node is MeshInstance3D and node.mesh is ArrayMesh:
			_surface_tool.append_from(node.mesh, 0, node.transform)
	rst_arraymesh = _surface_tool.commit()
	
func save_mesh_to_file() -> void:
	var mesh_path = SAVE_PATH + "/combined_mesh.tres"
	var tex_path = SAVE_PATH + "/combined_texture.png"
	# 保存网格
	var err = ResourceSaver.save(rst_arraymesh, mesh_path)
	if err == OK:
		print("网格保存成功：", mesh_path)
	else:
		push_error("网格保存失败：%s" % error_string(err))


func show_mesh_infor(mesh:MeshInstance3D, mesh_name:String):
	
	var _skin = mesh.skin
	if _skin != null:
		print('skin are:')
		for i in _skin.get_bind_count():
			print("Bind ", i, ": ", _skin.get_bind_pose(i))
			
	var arraymesh = mesh.mesh
	var _arrays:Array = arraymesh.surface_get_arrays(0)
	print('Mesh.ARRAY_VERTEX are:')
	for i in _arrays[Mesh.ARRAY_VERTEX]:
		print(i)
	
	print('Mesh.ARRAY_NORMAL are:')
	for i in _arrays[Mesh.ARRAY_NORMAL]:
		print(i)
		
	print('Mesh.ARRAY_TANGENT are:')
	for i in _arrays[Mesh.ARRAY_TANGENT]:
		print(i)
	
	if _arrays[Mesh.ARRAY_COLOR] != null:
		print('Mesh.ARRAY_COLOR are:')
		for i in _arrays[Mesh.ARRAY_COLOR]:
			print(i)
	if _arrays[Mesh.ARRAY_TEX_UV] != null:
		print('Mesh.ARRAY_TEX_UV are:')
		for i in _arrays[Mesh.ARRAY_TEX_UV]:
			print(i)
	
	if _arrays[Mesh.ARRAY_TEX_UV2] != null:
		print('Mesh.ARRAY_TEX_UV2 are:')
		for i in _arrays[Mesh.ARRAY_TEX_UV2]:
			print(i)

	print('Mesh.ARRAY_BONES are:')
	var i = 0
	while i + 4 < _arrays[Mesh.ARRAY_BONES].size():
		print('%s, %s, %s, %s' % [_arrays[Mesh.ARRAY_BONES][i],
		_arrays[Mesh.ARRAY_BONES][i + 1],
		_arrays[Mesh.ARRAY_BONES][i + 2],
		_arrays[Mesh.ARRAY_BONES][i + 3]]) 
		i += 4
		
	print('Mesh.ARRAY_WEIGHTS are:')
	i = 0
	while i + 4 < _arrays[Mesh.ARRAY_WEIGHTS].size():
		print('%s, %s, %s, %s' % [_arrays[Mesh.ARRAY_WEIGHTS][i],
		_arrays[Mesh.ARRAY_WEIGHTS][i + 1],
		_arrays[Mesh.ARRAY_WEIGHTS][i + 2],
		_arrays[Mesh.ARRAY_WEIGHTS][i + 3]]) 
		i += 4

	print('Mesh.ARRAY_INDEX are:')
	print(_arrays[Mesh.ARRAY_INDEX])
	print('\n\n\n\n')
