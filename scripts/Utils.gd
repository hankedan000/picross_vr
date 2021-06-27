extends Object
class_name Utils

static func make_2d_array(x:int, y:int, val):
	var arr = []
	for xx in range(x):
		arr.append([])
		for yy in range(y):
			arr[xx].append(val)
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

static func reverse(arr):
	var out = []
	for val in arr:
		out.push_front(val)
	return out

static func fill(elem, length: int):
	var out = []
	for i in range(length):
		out.append(elem)
	return out

static func compositions(n: int):
	var res = [];
	var comps = fill(1, n);

	res.push_back(comps.duplicate());

	for comp in findSets(comps, 0):
		res.push_back(comp)

	return res;

static func findSets(set, start_idx: int):
	if (set[set.size() - 1] != 1 || set.size() < 3):
		return [];
	var res = []

	set = set.slice(0, set.size() - 2);

	var i = start_idx;
	while i < set.size():
		set[i] += 1;
		res.push_back(set.duplicate())

		for s in findSets(set, i):
			res.push_back(s)

		set[i] -= 1;
		i += 1;

	return res;
