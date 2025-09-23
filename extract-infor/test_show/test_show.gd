extends Node3D


func read_blend_shapes(res_path: String) -> void:
	var mesh: ArrayMesh = load(res_path)
	if mesh == null:
		push_error("无法加载: %s" % res_path)
		return
	var count = mesh.get_blend_shape_count()
	print("Blend Shape 数量:", count)
	for i in count:
		var name = mesh.get_blend_shape_name(i)
		print("Blend Shape[%d] 名字: %s" % [i, name])
		# 遍历每个 surface 的 blend shape 数据
		for s in mesh.get_surface_count():
			var arrays = mesh.surface_get_blend_shape_arrays(s)
			if arrays.size() > 0:
				print("  Surface %d 的数据:" % s)
				print("    顶点数:", arrays[Mesh.ARRAY_VERTEX].size())
				# 还可以取 NORMAL/TANGENT 等

func _ready() -> void:
	read_blend_shapes("res://test_show/assert/blend__CC_Base_Eye.tres")
