extends Resource

class_name SUBHUMAN_LOOK_C

###3.  外貌信息： 
###    3.1 模型数据：mesh信息，skin信息，skeleton信息，texture信息，ani_tree信息
###    3.2 毛发数据：
###    3.3 纹身数据：
###    3.4 其他数据：


#### 3.1 模型数据
var mesh_body:String = ''
var mesh_eye:String = ''
var mesh_eyeo:String = ''
var mesh_tear:String = ''
var mesh_tee:String = ''
var mesh_tong:String = ''

var skin_body:String = ''
var skin_eye:String = ''
var skin_eyeo:String = ''
var skin_tear:String = ''
var skin_tee:String = ''
var skin_tong:String = ''

var texa_body:Array = []
var texa_eye:Array = []
var texa_eyeo:Array = []
var texa_tear:Array = []
var texa_tee:Array = []
var texa_tong:Array = []
var texn_body:Array = []
var texn_eye:Array = []
var texn_eyeo:Array = []
var texn_tear:Array = []
var texn_tee:Array = []
var texn_tong:Array = []

var skeleton_path:String = ''
var ani_tree_path:String = ''

###  3.2 毛发数据
var hair_dics:Dictionary = {
	'headhair': [],
	'bodyhair': [],
	'armhair': [],
	'leghair': [],
	'eyebrows': [],
	'eyelashes': [],
	'beard': [],
}

###  3.3  纹身数据


###  3.4  其他数据：斑点、腮红、毛孔、皮肤颜色
