extends Node3D

@export var human:Node3D

var player_human:PLAYER_NODE_C = null

func _process(_delta: float) -> void:
	pass
	#if player_human and player_human.human_ani_tree.active:
	#	var _playback = player_human.human_ani_tree.get('parameters/playback')
		#if playback:
		#	print("%s, %s" % [playback.get_current_node(), playback.is_playing()])
		
	
	
func _ready() -> void:
	player_human = PLAYER_NODE_C.new()
	print(player_human)
	human.add_child(player_human.human_noded)
	#construct_human(player_human)


	
