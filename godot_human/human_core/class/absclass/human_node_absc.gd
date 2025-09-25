@abstract class_name HUMAN_NODE_AC

extends HUMAN_DATA_AC

var human_skeleton:Skeleton3D = null

var human_ani_player:AnimationPlayer = null
var human_ani_tree:AnimationTree = null

var human_body_mesh3d:MeshInstance3D = null
var human_eye_mesh3d:MeshInstance3D = null
var human_eyeo_mesh3d:MeshInstance3D = null
var human_tear_mesh3d:MeshInstance3D = null
var human_tee_mesh3d:MeshInstance3D = null
var human_tong_mesh3d:MeshInstance3D = null

var human_dir:String = ''

var human_noded:Node3D = null


func create_huma_main() -> void:
	human_noded = Node3D.new()
	human_noded.scale = Vector3(0.01, 0.01, 0.01)
	human_noded.name = 'human'
	set_human_data()
	create_human_skeleton()
	create_human_mesh()
	create_human_ani()
	create_human_texture()
	
	#return human_noded
	
func set_human_data():
	
	human_dir = "res://human_core/res/extract__base_aaa/"
	human_look_o.skeleton_path = "res://human_core/res/skeleton.tscn"
	human_look_o.ani_tree_path = "res://human_core/ani/ani_temp.tscn"
	human_look_o.mesh_body = human_dir.path_join("mesh__CC_Base_Body.tres")
	human_look_o.mesh_eye = human_dir.path_join("mesh__CC_Base_Eye.tres")
	human_look_o.mesh_eyeo = human_dir.path_join("mesh__CC_Base_EyeOcclusion.tres")
	human_look_o.mesh_tear = human_dir.path_join("mesh__CC_Base_TearLine.tres")
	human_look_o.mesh_tee = human_dir.path_join("mesh__CC_Base_Teeth.tres")
	human_look_o.mesh_tong = human_dir.path_join("mesh__CC_Base_Tongue.tres")
		
	human_look_o.skin_body = human_dir.path_join("skin__CC_Base_Body.tres")
	human_look_o.skin_eye = human_dir.path_join("skin__CC_Base_Eye.tres")
	human_look_o.skin_eyeo = human_dir.path_join("skin__CC_Base_EyeOcclusion.tres")
	human_look_o.skin_tear = human_dir.path_join("skin__CC_Base_TearLine.tres")
	human_look_o.skin_tee = human_dir.path_join("skin__CC_Base_Teeth.tres")
	human_look_o.skin_tong = human_dir.path_join("skin__CC_Base_Tongue.tres")
	
	human_look_o.blend_body = human_dir.path_join("blend__CC_Base_Body.res")
	human_look_o.blend_eye = human_dir.path_join("blend__CC_Base_eye.res")
	human_look_o.blend_eyeo = human_dir.path_join("blend__CC_Base_eyeo.res")
	human_look_o.blend_tear = human_dir.path_join("blend__CC_Base_tear.res")
	human_look_o.blend_tee = human_dir.path_join("blend__CC_Base_tee.res")
	human_look_o.blend_tong = human_dir.path_join("blend__CC_Base_tong.res")
	
	for idx in range(6):
		human_look_o.texa_body = array_append(human_look_o.texa_body, human_dir.path_join("mat_diffuse_CC_Base_Body__surface_%s.webp"%[idx]))
		human_look_o.texa_eye = array_append(human_look_o.texa_eye, human_dir.path_join("mat_diffuse_CC_Base_Eye__surface_%s.webp"%[idx]))
		human_look_o.texa_eyeo = array_append(human_look_o.texa_eyeo, human_dir.path_join("mat_diffuse_CC_Base_EyeOcclusion__surface_%s.webp"%[idx]))
		human_look_o.texa_tear = array_append(human_look_o.texa_tear, human_dir.path_join("mat_diffuse_CC_Base_TearLine__surface_%s.webp"%[idx]))
		human_look_o.texa_tee = array_append(human_look_o.texa_tee, human_dir.path_join("mat_diffuse_CC_Base_Teeth__surface_%s.webp"%[idx]))
		human_look_o.texa_tong = array_append(human_look_o.texa_tong, human_dir.path_join("mat_diffuse_CC_Base_Tongue__surface_%s.webp"%[idx]))

		human_look_o.texn_body = array_append(human_look_o.texn_body, human_dir.path_join("mat_normal_CC_Base_Body__surface_%s.webp"%[idx]))
		human_look_o.texn_eye = array_append(human_look_o.texn_eye, human_dir.path_join("mat_normal_CC_Base_Eye__surface_%s.webp"%[idx]))
		human_look_o.texn_eyeo = array_append(human_look_o.texn_eyeo, human_dir.path_join("mat_normal_CC_Base_EyeOcclusion__surface_%s.webp"%[idx]))
		human_look_o.texn_tear = array_append(human_look_o.texn_tear, human_dir.path_join("mat_normal_CC_Base_TearLine__surface_%s.webp"%[idx]))
		human_look_o.texn_tee = array_append(human_look_o.texn_tee, human_dir.path_join("mat_normal_CC_Base_Teeth__surface_%s.webp"%[idx]))
		human_look_o.texn_tong = array_append(human_look_o.texn_tong, human_dir.path_join("mat_normal_CC_Base_Tongue__surface_%s.webp"%[idx]))

func array_append(a:Array, b:String) -> Array:
	if FileAccess.file_exists(b):
		a.append(b)
	return a
	
func create_human_skeleton():
	if human_look_o.skeleton_path != '':
		human_skeleton = load(human_look_o.skeleton_path).instantiate().get_child(0).duplicate()
		if human_noded != null:
			human_noded.add_child(human_skeleton)
			
func update_mesh_infor(a:String, c:String, d:String):
	if a != '':
		var b = MeshInstance3D.new()
		b.mesh = load(a)
		if c != '':
			b.skin = load(c)
			b.skeleton = NodePath("../Skeleton3D")
		b.name = d
		return b
	return null
	


func create_human_ani():
	var ani_tscn:Node3D = load(human_look_o.ani_tree_path).instantiate()
	human_ani_player = ani_tscn.get_child(0).duplicate()
	human_ani_tree = ani_tscn.get_child(1).duplicate()
	human_noded.add_child(human_ani_player)
	human_noded.add_child(human_ani_tree)


	
func create_human_mesh():
	var a = load_blend_shape_bin(human_look_o.blend_body)
	var b = a['Brow_Compress_L']
	print(a)
	human_body_mesh3d = update_mesh_infor(human_look_o.mesh_body, human_look_o.skin_body, 'body')
	human_eye_mesh3d = update_mesh_infor(human_look_o.mesh_eye, human_look_o.skin_eye, 'eye')
	human_eyeo_mesh3d = update_mesh_infor(human_look_o.mesh_eyeo, human_look_o.skin_eyeo, 'eyeo')
	human_tear_mesh3d = update_mesh_infor(human_look_o.mesh_tear, human_look_o.skin_tear, 'tear')
	human_tee_mesh3d = update_mesh_infor(human_look_o.mesh_tee, human_look_o.skin_tee, 'tee')
	human_tong_mesh3d = update_mesh_infor(human_look_o.mesh_tong, human_look_o.skin_tong, 'tong')
	if human_noded != null:
		human_noded.add_child(human_body_mesh3d)
		human_noded.add_child(human_eye_mesh3d)
		human_noded.add_child(human_eyeo_mesh3d)
		human_noded.add_child(human_tear_mesh3d)
		human_noded.add_child(human_tee_mesh3d)
		human_noded.add_child(human_tong_mesh3d)

func udpate_human_texture(a:Array, b:Array, c:MeshInstance3D, tran_idx:Array=[]):
	print(range(a.size()))
	for idx in range(a.size()):
		print(idx)
		var mat:StandardMaterial3D = StandardMaterial3D.new()
		if FileAccess.file_exists(a[idx]):
			mat.albedo_texture = load(a[idx])
		if idx < b.size() and FileAccess.file_exists(b[idx]):
			mat.normal_enabled = true
			mat.normal_texture = load(b[idx])
		if idx in tran_idx:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		c.set_surface_override_material(idx, mat)

func create_human_texture():
	udpate_human_texture(human_look_o.texa_body, human_look_o.texn_body, human_body_mesh3d, [5])
	udpate_human_texture(human_look_o.texa_eye, human_look_o.texn_eye, human_eye_mesh3d)
	udpate_human_texture(human_look_o.texa_eyeo, human_look_o.texn_eyeo, human_eyeo_mesh3d, [0, 1])
	udpate_human_texture(human_look_o.texa_tear, human_look_o.texn_tear, human_tear_mesh3d, [0, 1])
	udpate_human_texture(human_look_o.texa_tee, human_look_o.texn_tee, human_tee_mesh3d)
	udpate_human_texture(human_look_o.texa_tong, human_look_o.texn_tong, human_tong_mesh3d)
	

func load_blend_shape_bin(path: String) -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = f.get_var()
	f.close()
	return data
	
func apply_blend_shape(mesh: ArrayMesh, shape_name: String, surface_data: Array) -> void:
	var shape_idx = mesh.find_blend_shape_by_name(shape_name)
	if shape_idx == -1:
		return

	for s in surface_data.size():
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = surface_data[s]["vertices"]
		arrays[Mesh.ARRAY_NORMAL] = surface_data[s]["normals"]
		mesh.surface_set_blend_shape_arrays(s, shape_idx, arrays)


func create_human_cloth():
	pass
	
	
func create_human_item():
	pass
	
	
