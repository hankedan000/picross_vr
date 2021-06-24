extends Spatial

export var enabled = true

# in meters
export var max_cast_length = 0.20# 10cm

onready var raycast = $RaycastPosition/RayCast
onready var mesh_inst := $RaycastPosition/MeshInstance

# the cube we're currently casting upon
var curr_cube : BaseCube = null

func _ready():
	raycast.cast_to = Vector3(0,max_cast_length,0)

func _process(_delta):
	if ! enabled:
		return
		
	var collide_point = null
	if raycast.is_colliding():
		collide_point = raycast.get_collision_point()
		var collider = raycast.get_collider()
		var collider_parent = collider.get_parent()
		if collider_parent is BaseCube:
			if curr_cube == collider_parent:
				# same cube we're casting on
				pass
			elif curr_cube != null:
				# casting upon a different cube, so unhighlight previous cube
				curr_cube.state = BaseCube.State.Unsolved
				curr_cube = collider_parent
				collider_parent.state = BaseCube.State.Highlighted
			else:
				# wasn't casting upon any cube's before
				curr_cube = collider_parent
				collider_parent.state = BaseCube.State.Highlighted
	else:
		# not coliding with anything now
		if curr_cube != null:
			# release highlight if we were colliding with a cube before
			curr_cube.state = BaseCube.State.Unsolved
			curr_cube = null
			
	var pointer_length = max_cast_length
	if collide_point:
		var ray : Vector3 = collide_point - raycast.global_transform.origin
		pointer_length = ray.length()
	mesh_inst.transform.origin = Vector3(0,pointer_length/2,0)
	mesh_inst.mesh.height = pointer_length
