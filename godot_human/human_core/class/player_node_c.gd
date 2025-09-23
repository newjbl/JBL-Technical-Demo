extends HUMAN_NODE_AC
class_name PLAYER_NODE_C

var human_struct:Dictionary = {}

func _init() -> void:
	print('init user human!')	
	human_struct = create_huma_main()
	print(human_base_o)
	
