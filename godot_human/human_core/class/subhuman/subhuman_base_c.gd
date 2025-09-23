extends Resource
class_name SUBHUMAN_BASE_C

#### basic infor
var id:int = 0
var human_name:String = ''
var human_sex:COM_C.sex = COM_C.sex.Male
var human_race:COM_C.race = COM_C.race.Asian
var human_age:int = -1

func _init() -> void:
	id = ResourceUID.create_id()
	human_name = str(randi())
	human_age = randi()
