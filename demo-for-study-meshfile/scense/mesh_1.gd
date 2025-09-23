extends Node3D
@export var mesh3d:MeshInstance3D
func _ready() -> void:
	var array_mesh:ArrayMesh = mesh3d.mesh
	for i in array_mesh.get_surface_count():
		var sf = array_mesh.surface_get_arrays(i)
		print('~')
	
