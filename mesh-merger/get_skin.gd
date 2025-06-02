extends MeshInstance3D

@export var mesh3d:MeshInstance3D

var ske_name_idx_dic_1:Dictionary = {}
var ske_name_idx_dic_2:Dictionary = {}

func _ready() -> void:
	var _skin = mesh3d.skin
	if _skin == null:
		print("no skin!")
	else:
		for i in _skin.get_bind_count():
			print("bind_%s, name=%s, :"%[i, _skin.get_bind_name(i)], _skin.get_bind_pose(i))
