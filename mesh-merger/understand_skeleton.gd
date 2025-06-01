extends Node3D

@export var mesh:MeshInstance3D

func _ready() -> void:
	var _st:SurfaceTool = SurfaceTool.new()
	
	print('skin are:')
	var _skin = mesh.skin
	for i in _skin.get_bind_count():
		print("Bind ", i, ": ", _skin.get_bind_pose(i))
				
	var arraymesh = mesh.mesh
	var _arrays:Array = arraymesh.surface_get_arrays(0)
	print('Mesh.ARRAY_VERTEX are:')
	for i in _arrays[Mesh.ARRAY_VERTEX]:
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
