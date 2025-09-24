extends Node3D

@export var human:Node3D

var player_human:PLAYER_NODE_C = null

func _process(_delta: float) -> void:
	if player_human and player_human.human_ani_tree.active:
		var _playback = player_human.human_ani_tree.get('parameters/playback')
		#if playback:
		#	print("%s, %s" % [playback.get_current_node(), playback.is_playing()])
		
	
	
func _ready() -> void:
	player_human = PLAYER_NODE_C.new()
	construct_human(player_human)

func construct_human(human_node:PLAYER_NODE_C):
	var human_struct = human_node['human_struct']
	var ske:Skeleton3D = human_struct['skeleton']
	ske.name = 'Skeleton3D'
	human.add_child(ske)
	var ani_player:AnimationPlayer = human_node.human_ani_player
	ani_player.root_node = human.get_path()
	human.add_child(ani_player)
	var ani_tree:AnimationTree = human_node.human_ani_tree
	#ani_tree.root_node = human.get_path()
	human.add_child(ani_tree)
	
	for eachone in human_struct['mesh3ds']:
		if eachone != null:
			human.add_child(eachone)
			#add_collision_for_mesh(eachone)
	align_children_to_bottom()
	
func add_collision_for_mesh(mesh_instance: MeshInstance3D):
	if not mesh_instance.mesh:
		return
	var aabb: AABB = mesh_instance.mesh.get_aabb()
	var box_shape = BoxShape3D.new()
	box_shape.size = aabb.size   # BoxShape3D 的 size 就是宽高深

	var collision = CollisionShape3D.new()
	collision.shape = box_shape
	collision.transform.origin = aabb.position + aabb.size * 0.5  # 把盒子放到 mesh 的中心

	mesh_instance.add_child(collision)
	collision.owner = mesh_instance.get_tree().edited_scene_root  # 确保保存到场景

func align_children_to_bottom():
	var off_set = 0
	for child in human.get_children():
		if child is MeshInstance3D and child.name == 'body':
			var _aabb = child.get_aabb()
			off_set = get_mesh_bottom_in_world(child)
			break
	for child in human.get_children():
		if child is MeshInstance3D:
			# 把它往上移，使得最低点落到父节点的 y=0
			child.translate(Vector3(0, -off_set, 0))

func get_mesh_bottom_in_world(mesh_instance: MeshInstance3D) -> float:
	var aabb = mesh_instance.get_aabb()
	# mesh 的局部底部点（局部坐标）
	var local_bottom = Vector3(
		aabb.position.x + aabb.size.x / 2.0,
		aabb.position.y + aabb.size.y / 2.0,
		aabb.position.z + aabb.size.z / 2.0
	)
	# 转换到世界坐标
	var world_bottom = mesh_instance.to_global(local_bottom)
	return world_bottom.y

	
