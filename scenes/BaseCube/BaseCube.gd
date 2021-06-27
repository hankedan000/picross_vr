tool
extends Spatial
class_name BaseCube

enum State {
	Unsolved
	MarkedToKeep
	Mistake
	Solved
}

# how far off the cube surface the label offset is placed (in meters)
const LABEL_OFFSET = 0.0001

export (State) var state = State.Unsolved setget _set_state
export var UnsolvedImage : StreamTexture = null
export var MistakeImage : StreamTexture = null

var highlighted = false setget _set_highlighted
# [x,y,z] index of where the cube is located within the picross
var key = null

var _highlight_color : Color = Color.white
var __ready = false

func _ready():
	clear_labels()
	_highlight_color = Player.KEEP_COLOR
	
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
		
	player.connect("selection_mode_changed",self,"_on_player_selection_mode_changed")
		
	__ready = true
	
func clear_labels():
	set_fb_label(-1,"normal")
	set_tb_label(-1,"normal")
	set_lr_label(-1,"normal")

# each sprint is 64x64 pixels
const SPRITE_SIZE = 64
const NORMAL_NUMBERS_Y = SPRITE_SIZE * 2 # 3rd row
const CIRCLED_NUMBERS_Y = SPRITE_SIZE * 3 # 4th row

func _label_type_to_sprite_sheet_y(type):
	match type:
		PicrossTypes.HintType.simple:
			return NORMAL_NUMBERS_Y
		PicrossTypes.HintType.circle:
			return CIRCLED_NUMBERS_Y
		_:
			vr.log_warning("unsupported label type %s" % type)
			return NORMAL_NUMBERS_Y

func set_fb_label(number : int, type):
	var label_visible = false
	if number >= 0:
		label_visible = true
		var label_y = _label_type_to_sprite_sheet_y(type)
		$labels/front.region_rect.position.y = label_y
		$labels/front.region_rect.position.x = number * SPRITE_SIZE
		$labels/back.region_rect.position.y = label_y
		$labels/back.region_rect.position.x = number * SPRITE_SIZE
	$labels/front.visible = label_visible
	$labels/back.visible = label_visible
		
func set_tb_label(number : int, type):
	var label_visible = false
	if number >= 0:
		label_visible = true
		var label_y = _label_type_to_sprite_sheet_y(type)
		$labels/top.region_rect.position.y = label_y
		$labels/top.region_rect.position.x = number * SPRITE_SIZE
		$labels/bottom.region_rect.position.y = label_y
		$labels/bottom.region_rect.position.x = number * SPRITE_SIZE
	$labels/top.visible = label_visible
	$labels/bottom.visible = label_visible
		
func set_lr_label(number : int, type):
	var label_visible = false
	if number >= 0:
		label_visible = true
		var label_y = _label_type_to_sprite_sheet_y(type)
		$labels/left.region_rect.position.y = label_y
		$labels/left.region_rect.position.x = number * SPRITE_SIZE
		$labels/right.region_rect.position.y = label_y
		$labels/right.region_rect.position.x = number * SPRITE_SIZE
	$labels/left.visible = label_visible
	$labels/right.visible = label_visible
	
func _set_highlighted(value):
	if state == State.Unsolved:
		highlighted = value
		
		if highlighted:
			_set_albedo_color(_highlight_color)
		else:
			_set_albedo_color(Color.white)
	else:
		highlighted = false

func _set_albedo_color(color : Color):
	if state == State.Unsolved:
		for mesh_inst in $meshes.get_children():
			var mat : Material = mesh_inst.get_surface_material(0)
			if mat is SpatialMaterial:
				mat.albedo_color = color

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
		State.MarkedToKeep:
			$labels.visible = true
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Player.KEEP_COLOR
					mat.albedo_texture = UnsolvedImage
		State.Mistake:
			$labels.visible = true
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Player.KEEP_COLOR
					mat.albedo_texture = MistakeImage
		State.Solved:
			$labels.visible = false
			for mesh_inst in $meshes.get_children():
				var mat : Material = mesh_inst.get_surface_material(0)
				if mat is SpatialMaterial:
					mat.albedo_color = Color.white
					mat.albedo_texture = null

func _on_player_selection_mode_changed(selection_mode):
	match selection_mode:
		Player.SelectionMode.Keep:
			_highlight_color = Player.KEEP_COLOR
		Player.SelectionMode.Remove:
			_highlight_color = Player.REMOVE_COLOR
	
	# update color if we're highlighted
	if highlighted:
		_set_albedo_color(_highlight_color)
