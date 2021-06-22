tool
extends Spatial
class_name BaseCube

enum State {
	Unsolved
	Highlighted
	Mistake
	Solved
}

# how far off the cube surface the label offset is placed (in meters)
const LABEL_OFFSET = 0.0001

export (State) var state = State.Unsolved setget _set_state
export var UnsolvedImage : StreamTexture = null
export var highlight_color = Color.green setget _set_highlight_color

var _ready = false;

func _ready():
	for mesh_inst in $meshes.get_children():
		mesh_inst.set_surface_material(0,SpatialMaterial.new())
		
	_ready = true
	
	# offset labels a distance off the cube surface to prevent artifacts
	for label in $labels.get_children():
		if label is Spatial:
			var side_name = label.name
			var new_translatation = label.translation
			var side_plane = $meshes.get_node(side_name)
			if side_plane != null:
				new_translatation = side_plane.translation + side_plane.translation.normalized() * LABEL_OFFSET
			label.translation = new_translatation
	
func clear_labels():
	set_fb_label("")
	set_tb_label("")
	set_lr_label("")
		
func set_fb_label(text):
	$labels/front.text = text
	$labels/back.text = text
		
func set_tb_label(text):
	$labels/top.text = text
	$labels/bottom.text = text
		
func set_lr_label(text):
	$labels/left.text = text
	$labels/right.text = text
		
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
			$labels.visible = true
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Color.white
					mat.albedo_texture = UnsolvedImage
		State.Highlighted:
			$labels.visible = true
			var albedo_color = _get_light_highlight()
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = albedo_color
					mat.albedo_texture = UnsolvedImage
		State.Mistake:
			$labels.visible = true
			var albedo_color = _get_light_highlight()
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = albedo_color
					# TODO i need to make a mistake texture
					mat.albedo_texture = UnsolvedImage
		State.Solved:
			$labels.visible = false
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
