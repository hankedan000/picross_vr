extends Node
class_name PicrossShapeUtils

static func generate(dims, generator: FuncRef):
	var cells = [];
	
	for k in range(dims[2]):
		for j in range(dims[1]):
			for i in range(dims[1]):
				var val = generator.call_func(i, j, k);
				if val is bool:
					cells.push_back(int(val))
				else:
					cells.push_back(val)
					
	return PicrossShape.new(cells,dims)

static func fromJSON(shape):
	return PicrossShape.new(shape.cells, shape.dims);
