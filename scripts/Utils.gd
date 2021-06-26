extends Node
class_name Utils

static func make_2d_array(x:int, y:int, val):
	var arr = []
	for xx in range(x):
		arr.append([])
		for yy in range(y):
			arr[x].append(val)
	return arr

static func make_3d_array(x:int, y:int, z:int, val):
	var arr = []
	for xx in range(x):
		arr.append([])
		for yy in range(y):
			arr[x].append([])
			for zz in range(z):
				arr[x][y].append(val)
	return arr
