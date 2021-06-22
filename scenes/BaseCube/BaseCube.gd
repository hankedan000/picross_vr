tool
extends Spatial
class_name BaseCube

enum State {
	Unsolved
	Highlighted
	Mistake
	Solved
}

export (State) var state = State.Unsolved setget _set_state
export var UnsolvedImage : StreamTexture = null
export var highlight_color = Color.green setget _set_highlight_color

var _ready = false;

func _ready():
	for mesh_inst in $meshes.get_children():
		mesh_inst.set_surface_material(0,SpatialMaterial.new())
		
	_ready = true
		
func _get_light_highlight():
	var light_color = highlight_color
	light_color.s = 0.2
	return light_color

func _set_state(value):
	state = value
	
	if not _ready:
		yield(self,"ready")
	
	match value:
		State.Unsolved:
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Color.white
					mat.albedo_texture = UnsolvedImage
		State.Highlighted:
			var albedo_color = _get_light_highlight()
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = albedo_color
					mat.albedo_texture = UnsolvedImage
		State.Mistake:
			var albedo_color = _get_light_highlight()
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = albedo_color
					# TODO i need to make a mistake texture
					mat.albedo_texture = UnsolvedImage
		State.Solved:
			var albedo_color = _get_light_highlight()
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Color.white
					mat.albedo_texture = null
			

func _set_highlight_color(value):
	highlight_color = value
	
	if not _ready:
		yield(self,"ready")
	
	# force update of color by setting state to current state
	_set_state(state)
