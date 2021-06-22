extends Spatial

export var UnsolvedImage : StreamTexture = null

func _ready():
	for mesh_inst in $meshes.get_children():
		mesh_inst.set_surface_material(0,SpatialMaterial.new())
		
func set_unsolved():
	for mesh_inst in $meshes.get_children():
		var mat : Material = mesh_inst.get_surface_material(0)
		if mat is SpatialMaterial:
			mat.albedo_texture = UnsolvedImage
