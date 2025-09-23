@abstract class_name HUMAN_NODE_AC

extends HUMAN_DATA_AC

var human_skeleton:Skeleton3D = null

var human_body_mesh3d:MeshInstance3D = null
var human_eye_mesh3d:MeshInstance3D = null
var human_eyeo_mesh3d:MeshInstance3D = null
var human_tear_mesh3d:MeshInstance3D = null
var human_tee_mesh3d:MeshInstance3D = null
var human_tong_mesh3d:MeshInstance3D = null

var human_dir:String = ''

func create_huma_main():
	set_human_data()
	create_human_skeleton()
	create_human_mesh()
	create_human_texture()
	
	return {
		'mesh3ds':[human_body_mesh3d, human_eye_mesh3d,
				   human_eyeo_mesh3d, human_tear_mesh3d,
				   human_tee_mesh3d, human_tong_mesh3d], 
		'skeleton': human_skeleton,
	}
	
func set_human_data():
	
	human_dir = "res://human_core/res/extract__base_aaa/"
	human_look_o.skeleton_path = "res://human_core/res/skeleton.tscn"
	human_look_o.ani_tree_path = ''
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
	
func update_mesh_infor(a:String, c:String, d:String):
	if a != '':
		var b = MeshInstance3D.new()
		b.mesh = load(a)
		if c != '':
			b.skin = load(c)
		b.name = d
		return b
	return null
	
func create_human_skeleton():
	if human_look_o.skeleton_path != '':
		human_skeleton = load(human_look_o.skeleton_path).instantiate() 
	
func create_human_mesh():
	human_body_mesh3d = update_mesh_infor(human_look_o.mesh_body, human_look_o.skin_body, 'body')
	human_eye_mesh3d = update_mesh_infor(human_look_o.mesh_eye, human_look_o.skin_eye, 'eye')
	human_eyeo_mesh3d = update_mesh_infor(human_look_o.mesh_eyeo, human_look_o.skin_eyeo, 'eyeo')
	human_tear_mesh3d = update_mesh_infor(human_look_o.mesh_tear, human_look_o.skin_tear, 'tear')
	human_tee_mesh3d = update_mesh_infor(human_look_o.mesh_tee, human_look_o.skin_tee, 'tee')
	human_tong_mesh3d = update_mesh_infor(human_look_o.mesh_tong, human_look_o.skin_tong, 'tong')
	

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
	
	
func create_human_cloth():
	pass
	
func create_human_ani():
	pass
	
func create_human_item():
	pass
	
	
