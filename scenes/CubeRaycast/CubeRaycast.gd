extends Spatial

export var enabled = true

# in meters
export var max_cast_length = 0.20# 10cm
export var show_collision_normal = false

onready var raycast = $RaycastPosition/RayCast
onready var mesh_inst := $RaycastPosition/MeshInstance

# the controller that the ray cast is a child of
var controller : ARVRController = null
# the cube we're currently casting upon
var curr_cube : BaseCube = null

# TODO should queu_free() this guy when I leave the scene
var _coll_normal_node : Spatial = null

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
			
	if show_collision_normal and collide_point != null:
		# add to parent for the first time
		if _coll_normal_node == null:
			_coll_normal_node = $CollisionNormal
			remove_child(_coll_normal_node)
			get_parent().add_child(_coll_normal_node)
			
		_coll_normal_node.visible = show_collision_normal
		_coll_normal_node.global_transform.origin = collide_point
		_coll_normal_node.global_transform = _coll_normal_node.global_transform.looking_at(collide_normal+collide_point,Vector3.UP)
	elif _coll_normal_node != null and collide_point == null:
		_coll_normal_node.visible = false
		
			
	var pointer_length = max_cast_length
	if collide_point:
		var ray : Vector3 = collide_point - raycast.global_transform.origin
		pointer_length = ray.length()
	mesh_inst.transform.origin = Vector3(0,pointer_length/2,0)
	mesh_inst.mesh.height = pointer_length
	
	# handle creation mode cube placement logic
	if game.active_picross is EditablePicross and curr_cube and game.mode == game.GameMode.Create:
		var coll_face_res = curr_cube.get_colliding_face(collide_normal)
		var CONFIDENCE_THRESHOLD = 0.5# 1.0 is 100% accurate
		if coll_face_res.confidence > CONFIDENCE_THRESHOLD:
			var next_i = curr_cube.key[0]
			var next_j = curr_cube.key[1]
			var next_k = curr_cube.key[2]
			if coll_face_res.face == "back":
				next_k += 1
			elif coll_face_res.face == "front":
				next_k -= 1
			elif coll_face_res.face == "right":
				next_i += 1
			elif coll_face_res.face == "left":
				next_i -= 1
			elif coll_face_res.face == "top":
				next_j += 1
			elif coll_face_res.face == "bottom":
				next_j -= 1
				
			game.active_picross.set_next_cube_location(next_i,next_j,next_k)
	
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
		elif game.mode == game.GameMode.Create and game.active_picross is EditablePicross:
			match player.selection_mode:
				Player.SelectionMode.Keep:
					game.active_picross.add_next_cube()
				Player.SelectionMode.Remove:
					var cube_key = curr_cube.key
					if game.active_picross.remove_cube(cube_key,true):
						# cube successfully removed
						curr_cube = null
			
	if curr_cube == null:
		if game.mode == game.GameMode.Create and game.active_picross is EditablePicross:
			game.active_picross.hide_next_cube()

func _set_color(color : Color):
	var mat : SpatialMaterial = $RaycastPosition/MeshInstance.get_surface_material(0)
	mat.albedo_color = color

func _on_player_selection_mode_changed(selection_mode):
	match selection_mode:
		Player.SelectionMode.Keep:
			_set_color(Player.KEEP_COLOR)
		Player.SelectionMode.Remove:
			_set_color(Player.REMOVE_COLOR)
