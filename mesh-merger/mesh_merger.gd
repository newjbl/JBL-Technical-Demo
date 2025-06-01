extends Node3D

@export var mesh_1:MeshInstance3D
@export var mesh_2:MeshInstance3D
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
	
# 修改后的合并函数
func merge_meshes() -> void:
	if rst_arraymesh != null:
		rst_arraymesh.clear_surfaces()
	var _surface_tool := SurfaceTool.new()
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for node in [mesh_1, mesh_2]:
		if node is MeshInstance3D and node.mesh is ArrayMesh:
			_surface_tool.append_from(node.mesh, 0, node.transform)
	rst_arraymesh = _surface_tool.commit()
	
func generate_lods():
	var _importer_mesh:ImporterMesh = ImporterMesh.new()
	var surface_array: = rst_arraymesh.surface_get_arrays(0)
	_importer_mesh.clear()
	_importer_mesh.add_surface(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	_importer_mesh.generate_lods(60, 0, [])
	rst_arraymesh = _importer_mesh.get_mesh()
	
	var lod_count = _importer_mesh.get_surface_lod_count(0)
	print("LOD count: ", lod_count)
	
	for i in range(lod_count):
		var lod_size = _importer_mesh.get_surface_lod_size(0, i)
		print("LOD ", i, " size: ", lod_size, "index: ", _importer_mesh.get_surface_lod_indices(0, i).size())
func save_mesh_to_file() -> void:
	var mesh_path = SAVE_PATH + "/combined_mesh.res"
	var tex_path = SAVE_PATH + "/combined_texture.png"
	# 保存网格
	var err = ResourceSaver.save(rst_arraymesh, mesh_path)
	if err == OK:
		print("网格保存成功：", mesh_path)
	else:
		push_error("网格保存失败：%s" % error_string(err))
		
func save_tex_to_file() -> void:
	var tex_path = SAVE_PATH + "combined_texture.png"
	# 保存网格
	var err = ResourceSaver.save(rst_arraymesh, tex_path)
	if err == OK:
		print("网格保存成功：", tex_path)
	else:
		push_error("网格保存失败：%s" % error_string(err))	
