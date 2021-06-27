extends Object
class_name Array3D

var _data = []
var _dims = [0,0,0]
var _strides = [0,0,0]
var _offset = 0

func initDataDims(data, dims):
	self._data = data
	self._dims = dims
	self._strides = [1, self._dims[0], self._dims[0] * self._dims[1]]
	self._offset = 0
	
func initDimsFill(dims,fill_val):
	self._data = []
	for x in range(dims[0]):
		for y in range(dims[1]):
			for z in range(dims[2]):
				self._data.append(fill_val)
	self._dims = dims
	self._strides = [1, self._dims[0], self._dims[0] * self._dims[1]]
	self._offset = 0

func at(i: int, j: int, k: int):
	return self._data[self._offset + i * self._strides[0] + j * self._strides[1] + k * self._strides[2]];

func atIdx(idx: int):
	return self._data[idx];

# renamed to "setVal" because "set" shadowed Object.set()
func setVal(i: int, j: int, k: int, val):
	self._data[self._offset + i * self._strides[0] + j * self._strides[1] + k * self._strides[2]] = val;

func setAtIdx(idx: int, val):
	self._data[idx] = val;

func low(w: int, h: int, d: int):
	var new_dims = [
		self._dims[0] - w,
		self._dims[0] - h,
		self._dims[0] - d
	];

	var new_offset = self._offset + w * self._strides[0] + h * self._strides[1] + d * self._strides[2];

	var view = get_script().new(self._data, new_dims)
	view._offset = new_offset;
	view._strides = self._strides.duplicate();

	return view;

func slice(from, to):
	var idx1 = self.idx(from[0], from[1], from[2]);
	var idx2 = self.idx(to[0], to[1], to[2]);
	self._data = self._data.slice(idx1, idx2);
	self._dims = [
		to[0] - from[0],
		to[1] - from[1],
		to[2] - from[2]
	];

func high(w: int, h: int, d: int):
	var view = get_script().new(self._data, [w, h, d]);
	view._strides = self._strides;
	view._offset = self._offset;

	return view;

func idx(i: int, j: int, k: int) -> int:
	return self._offset + i * self._strides[0] + j * self._strides[1] + k * self._strides[2];

func idxToCoords(idx: int):
	var _idx = idx - self._offset;
	var k = int(floor(_idx / self._strides[2]));
	var j = int(floor((_idx % self._strides[2]) / self._strides[1]));
	var i = int(floor((_idx % self._strides[1]) / self._strides[0]));

	return [i, j, k];

func clear():
	self._data = [];

func dims():
	return self._dims;

func data():
	return self._data;
