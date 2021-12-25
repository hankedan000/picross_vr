extends Spatial

onready var cube := $Cube
onready var normal_node := $Normal
onready var ray_cast := $RayCast

var ray_angle = 0
const ROTATIONS_PER_SECOND = 0.25
const RAY_OFFSET_DISTANCE = 3.0

var _orig_cube_tranform = null
var _scale = 1.0

func _input(event):
	if event is InputEventMouse:
		_scale = event.position.x / 1024

func _process(delta):
	var angular_speed = ROTATIONS_PER_SECOND * 2 * PI
	ray_angle += angular_speed * delta
	
	ray_cast.global_transform.origin = Vector3(RAY_OFFSET_DISTANCE * cos(ray_angle),RAY_OFFSET_DISTANCE * sin(ray_angle), 0)
	ray_cast.global_transform = ray_cast.global_transform.looking_at(Vector3.ZERO,Vector3.UP)
	
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		var collision_normal = ray_cast.get_collision_normal()
		
		normal_node.global_transform.origin = collision_point
		normal_node.global_transform = normal_node.global_transform.looking_at(collision_normal + collision_point,Vector3.UP)
		
	if _orig_cube_tranform == null:
		_orig_cube_tranform = cube.transform
	cube.transform = _orig_cube_tranform.scaled(Vector3(1,1,1) * _scale)
