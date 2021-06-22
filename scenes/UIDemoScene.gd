extends Spatial

onready var picross := $Picross

func _ready():
	
	for x in range(10):
		for y in range(10):
			for z in range(10):
				picross.add_cube(x,y,z)
