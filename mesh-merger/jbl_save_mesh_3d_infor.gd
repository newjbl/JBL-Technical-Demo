extends Node3D

func _ready():
	var scene = load("res://assets/case2_fix.fbx")
	var inst = scene.instantiate()
	add_child(inst)
	var mesh3d = inst.get_child(0).get_child(0).get_child(3)
	var _skin = mesh3d.skin
	var st:SurfaceTool = SurfaceTool.new()
	
