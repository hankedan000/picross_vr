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

var __ready = false;

func _ready():
	for mesh_inst in $meshes.get_children():
		mesh_inst.set_surface_material(0,SpatialMaterial.new())
	
	# offset labels a distance off the cube surface to prevent artifacts
	for label in $labels.get_children():
		if label is Spatial:
			var side_name = label.name
			var new_translatation = label.translation
			var side_plane = $meshes.get_node(side_name)
			if side_plane != null:
				new_translatation = side_plane.translation + side_plane.translation.normalized() * LABEL_OFFSET
			label.translation = new_translatation
		
	__ready = true
	
func clear_labels():
	set_fb_label(-1)
	set_tb_label(-1)
	set_lr_label(-1)

# each sprint is 64x64 pixels
const SPRITE_SIZE = 64
const NORMAL_NUMBERS_Y = SPRITE_SIZE * 2 # 3rd row
const CIRCLED_NUMBERS_Y = SPRITE_SIZE * 3 # 4th row

func set_fb_label(number : int):
	var label_visible = false
	if number >= 0:
		label_visible = true
		$labels/front.region_rect.position.y = NORMAL_NUMBERS_Y
		$labels/front.region_rect.position.x = number * SPRITE_SIZE
		$labels/back.region_rect.position.y = NORMAL_NUMBERS_Y
		$labels/back.region_rect.position.x = number * SPRITE_SIZE
	$labels/front.visible = label_visible
	$labels/back.visible = label_visible
		
func set_tb_label(number : int):
	var label_visible = false
	if number >= 0:
		label_visible = true
		$labels/top.region_rect.position.y = NORMAL_NUMBERS_Y
		$labels/top.region_rect.position.x = number * SPRITE_SIZE
		$labels/bottom.region_rect.position.y = NORMAL_NUMBERS_Y
		$labels/bottom.region_rect.position.x = number * SPRITE_SIZE
	$labels/top.visible = label_visible
	$labels/bottom.visible = label_visible
		
func set_lr_label(number : int):
	var label_visible = false
	if number >= 0:
		label_visible = true
		$labels/left.region_rect.position.y = NORMAL_NUMBERS_Y
		$labels/left.region_rect.position.x = number * SPRITE_SIZE
		$labels/right.region_rect.position.y = NORMAL_NUMBERS_Y
		$labels/right.region_rect.position.x = number * SPRITE_SIZE
	$labels/left.visible = label_visible
	$labels/right.visible = label_visible
		
func _get_light_highlight():
	var light_color = highlight_color
	light_color.s = 0.2
	return light_color

func _set_state(value):
	state = value
	
	if not __ready:
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
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Color.white
					mat.albedo_texture = null
			

func _set_highlight_color(value):
	highlight_color = value
	
	if not __ready:
		yield(self,"ready")
	
	# force update of color by setting state to current state
	_set_state(state)
