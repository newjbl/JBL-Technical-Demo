@tool
extends Node3D

@export var mesh3d_a: MeshInstance3D
@export var mesh3d_b: MeshInstance3D
@export var vertex_index: int = 0:
	set(value):
		vertex_index = value
		_update_markers()

var marker_a: MeshInstance3D
var marker_b: MeshInstance3D

func _ready():
	_update_markers()
	var ske = load_skeleton_from_file("res://mesh/construct_human/extract__base_aaa/skeleton.json")
	add_child(ske)
	var show_ske_mesh = visualize_skeleton(ske)
	add_child(show_ske_mesh)
	
	
func _update_markers():
	# 清理旧的 marker
	for m in [marker_a, marker_b]:
		if m and m.is_inside_tree():
			m.queue_free()

	# --- Mesh A ---
	if mesh3d_a and mesh3d_a.mesh:
		var arrays_a = mesh3d_a.mesh.surface_get_arrays(0)
		if arrays_a.size() > Mesh.ARRAY_VERTEX:
			var vertices_a: PackedVector3Array = arrays_a[Mesh.ARRAY_VERTEX]
			if vertex_index >= 0 and vertex_index < vertices_a.size():
				var local_pos_a: Vector3 = vertices_a[vertex_index]
				var world_pos_a: Vector3 = mesh3d_a.to_global(local_pos_a)
				marker_a = _make_marker(world_pos_a, Color.RED)

	# --- Mesh B ---
	if mesh3d_b and mesh3d_b.mesh:
		var arrays_b = mesh3d_b.mesh.surface_get_arrays(0)
		if arrays_b.size() > Mesh.ARRAY_VERTEX:
			var vertices_b: PackedVector3Array = arrays_b[Mesh.ARRAY_VERTEX]
			if vertex_index >= 0 and vertex_index < vertices_b.size():
				var local_pos_b: Vector3 = vertices_b[vertex_index]
				var world_pos_b: Vector3 = mesh3d_b.to_global(local_pos_b)
				marker_b = _make_marker(world_pos_b, Color.BLUE)

# 辅助函数：创建一个彩色 marker 小球
func _make_marker(world_pos: Vector3, color: Color) -> MeshInstance3D:
	var marker = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.01
	sphere.height = 0.01
	marker.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	marker.set_surface_override_material(0, mat)
	add_child(marker)
	marker.global_position = world_pos
	return marker
	
func load_skeleton_from_file(file_path: String) -> Skeleton3D:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开文件: %s" % file_path)
		return null
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.parse_string(json_text)
	if typeof(json) != TYPE_DICTIONARY or not json.has("bones"):
		push_error("骨骼 JSON 格式错误")
		return null
	var skeleton = Skeleton3D.new()
	# 先添加所有骨骼
	for bone_info in json["bones"]:
		skeleton.add_bone(bone_info["name"])
	# 再设置父子关系和 rest pose
	for i in range(len(json["bones"])):
		var bone_info = json["bones"][i]
		var parent = bone_info["parent"]
		if parent >= 0:
			skeleton.set_bone_parent(i, parent)
		var r = bone_info["rest"]
		var basis_data = r.slice(0, 3)
		var origin_data = r.slice(3, 4)
		var rest = Transform3D(
			Basis(
				Vector3(basis_data[0][0], basis_data[0][1], basis_data[0][2]),
				Vector3(basis_data[1][0], basis_data[1][1], basis_data[1][2]),
				Vector3(basis_data[2][0], basis_data[2][1], basis_data[2][2])
			), 
			Vector3(origin_data[0][0], origin_data[0][1], origin_data[0][2])
			)
		skeleton.set_bone_rest(i, rest)
	return skeleton


func visualize_skeleton(skeleton: Skeleton3D) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()

	for i in range(skeleton.get_bone_count()):
		var parent_index = skeleton.get_bone_parent(i)
		if parent_index < 0:
			continue  # 根骨骼没有父骨骼

		var bone_pos = skeleton.get_bone_rest(i).origin
		var parent_pos = skeleton.get_bone_rest(parent_index).origin

		vertices.append(parent_pos)
		vertices.append(bone_pos)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)

	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh

	# 材质可选
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0, 0)
	mat.metallic = 0
	mat.roughness = 1
	mesh_instance.material_override = mat

	return mesh_instance
