extends Spatial

export var enabled = true

# in meters
export var max_cast_length = 0.20# 10cm

onready var raycast = $RaycastPosition/RayCast
onready var mesh_inst := $RaycastPosition/MeshInstance

# the controller that the ray cast is a child of
var controller : ARVRController = null
# the cube we're currently casting upon
var curr_cube : BaseCube = null

func _ready():
	raycast.cast_to = Vector3(0,max_cast_length,0)
	_on_player_selection_mode_changed(player.selection_mode)
	player.connect("selection_mode_changed",self,"_on_player_selection_mode_changed")
	
	# get our parent controller node
	var parent = get_parent()
	while parent != null:
		if parent is ARVRController:
			controller = parent
			break
		parent = parent.get_parent()
		
	if controller == null:
		vr.log_warning("in CubeRaycast._ready() : CubeRaycast is not a child of an ARVRController")

func _process(_delta):
	if ! enabled:
		return
		
	var collide_point = null
	var collide_normal = null
	if raycast.is_colliding():
		collide_point = raycast.get_collision_point()
		collide_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		var collider_parent = collider.get_parent()
		if collider_parent is BaseCube:
			if curr_cube == collider_parent:
				# same cube we're casting on
				pass
			elif curr_cube != null:
				# casting upon a different cube, so unhighlight previous cube
				curr_cube.highlighted = false
				curr_cube = collider_parent
				collider_parent.highlighted = true
			else:
				# wasn't casting upon any cube's before
				curr_cube = collider_parent
				curr_cube.highlighted = true
	else:
		# not coliding with anything now
		if curr_cube != null:
			# release highlight if we were colliding with a cube before
			curr_cube.highlighted = false
			curr_cube = null
			
	var pointer_length = max_cast_length
	if collide_point:
		var ray : Vector3 = collide_point - raycast.global_transform.origin
		pointer_length = ray.length()
	mesh_inst.transform.origin = Vector3(0,pointer_length/2,0)
	mesh_inst.mesh.height = pointer_length
	
	# handle creation mode cube placement logic
	if curr_cube and game.mode == game.GameMode.Create:
		var coll_face_res = curr_cube.get_colliding_face(collide_normal)
		var CONFIDENCE_THRESHOLD = 0.6# 1.0 is 100% accurate
		if coll_face_res.confidence > CONFIDENCE_THRESHOLD:
			# TODO handle cube placement logic
			pass
	
	# handle cube selection action (ie. keep, remove, etc)
	if curr_cube and controller and controller._button_just_pressed(vr.CONTROLLER_BUTTON.INDEX_TRIGGER):
		if game.mode == game.GameMode.Play:
			match player.selection_mode:
				Player.SelectionMode.Keep:
					# toggle cube between keep/unkeep
					if curr_cube.state == BaseCube.State.MarkedToKeep:
						curr_cube.state = BaseCube.State.Unsolved
					elif curr_cube.state == BaseCube.State.Unsolved:
						curr_cube.state = BaseCube.State.MarkedToKeep
				Player.SelectionMode.Remove:
					if curr_cube.state == BaseCube.State.Unsolved:
						var cube_key = curr_cube.key
						if game.active_picross.remove_cube(cube_key):
							# cube successfully removed
							curr_cube = null
						else:
							# OUCH! tried to remove a cube that's part of final solution
							# give player a violent rumble to let them know :P
							if controller is OQ_ARVRController:
								controller.simple_rumble(0.6,0.3)

func _set_color(color : Color):
	var mat : SpatialMaterial = $RaycastPosition/MeshInstance.get_surface_material(0)
	mat.albedo_color = color

func _on_player_selection_mode_changed(selection_mode):
	match selection_mode:
		Player.SelectionMode.Keep:
			_set_color(Player.KEEP_COLOR)
		Player.SelectionMode.Remove:
			_set_color(Player.REMOVE_COLOR)
