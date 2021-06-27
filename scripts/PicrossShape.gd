extends Object
class_name PicrossShape

var _cells := Array3D.new()# Array3D<CellState>;
var edits_history = []# ShapeEdit[];

func initFromDimState(dims, fill_state):
	edits_history = []
	self._cells.initDimsFill(dims,fill_state)

# returns a Box such that all dimensions of dims are positive
func boundingBox(from, to) -> PicrossTypes.Box:
	if (from.size() != to.size()): return null;

	var start = from.copy();
	var dims = []
	for d in range(from.size()): dims.append(0)

	for d in range(from.size()):
		dims[d] = to[d] - from[d];

		if (dims[d] < 0):
			start[d] = to[d];
			dims[d] *= -1;

		dims[d] += 1;

	var box := PicrossTypes.Box.new()
	box.start = start
	box.dims = dims
	return box;

func computeBoundingBox() -> PicrossTypes.Box:
	var _min = [self._cells.dims[0], self._cells.dims[1], self._cells.dims[2]];
	var _max = [0, 0, 0];
	var coords = [];

	for d in range(3):
		coords[PuzzleGenerator.coord_x[d]] = 0
		while coords[PuzzleGenerator.coord_x[d]] < self._cells.dims[PuzzleGenerator.coord_x[d]]:
			coords[PuzzleGenerator.coord_y[d]] = 0
			while coords[PuzzleGenerator.coord_y[d]] < self._cells.dims[PuzzleGenerator.coord_y[d]]:
				coords[d] = 0
				while coords[d] < _min[d]:
					if self._cells.at(coords[0],coords[1],coords[2]) != PicrossTypes.CellState.blank:
						_min[d] = coords[d];
						break;
					coords[d] += 1
					
				coords[d] = self._cells.dims[d] - 1
				while coords[d] >= _max[d]:
					if self._cells.at(coords[0],coords[1],coords[2]) != PicrossTypes.CellState.blank:
						_max[d] = coords[d];
						break;
					coords[d] -= 1
				coords[PuzzleGenerator.coord_y[d]] += 1
			coords[PuzzleGenerator.coord_x[d]] += 1

	return boundingBox(_min, _max);

func trim():
	var bounding_box = self.computeBoundingBox();
	# TODO implement this
	# self._cells.slice(bounding_box.start, bounding_box.start.map((p, i) => p + bounding_box.dims[i]));

# returns whether the state has changed
func setCell(i: int, j: int, k: int, state) -> bool:
	if (i < 0 || i >= self.dims()[0] ||
		j < 0 || j >= self.dims()[1] ||
		k < 0 || k >= self.dims()[2]):
		return false;

	var prev = self._cells.at(i,j,k);
	var changed = prev != state;

	if (changed):
		var idx = self._cells.idx(i, j, k);
		self.edits_history.push_back(PicrossTypes.ShapeEdit.new(prev, state, idx));
		self._cells.setAtIdx(idx, state);

	return changed;

func getCell(i: int, j: int, k: int):
	if (i < 0 || i >= self.dims()[0] ||
		j < 0 || j >= self.dims()[1] ||
		k < 0 || k >= self.dims()[2]):
		return PicrossTypes.CellState.blank;

	return self._cells.at(i,j,k);

func cellExists(i: int, j: int, k: int) -> bool:
	var c = self.getCell(i, j, k);
	return c != PicrossTypes.CellState.blank;

func cells():
	return self._cells;

func dims():
	return self._cells.dims();

func getRowCellCounts():
	var row_counts = Utils.make_2d_array(self.dims()[1],self.dims()[2],[])
	var blank = false;

	for k in range(self.dims()[2]):
		for j in range(self.dims()[1]):
			#ith row
			var row_rep = []
			for i in range(self.dims()[0]):
				if (self.cellExists(i, j, k)):
					if (row_rep.size() == 0 || blank):
						row_rep.push_back(1);
						blank = false;
					else:
						row_rep[row_rep.size() - 1] += 1;
				else:
					# there's at least one blank between two groups
					blank = true;
			row_counts[j][k] = row_rep;

	return row_counts;

func getColCellCounts():
	var col_counts = Utils.make_2d_array(self.dims()[0],self.dims()[2],[])
	var blank = false;

	for k in range(self.dims()[2]):
		for i in range(self.dims()[0]):
			#jth column
			var col_rep = []
			for j in range(self.dims()[1]):
				if (self.cellExists(i, j, k)):
					if (col_rep.size() == 0 || blank):
						col_rep.push_back(1);
						blank = false;
					else:
						col_rep[col_rep.size() - 1] += 1
				else:
					blank = true; #there's at least one blank between two groups
			col_counts[i][k] = col_rep;

	return col_counts;

func getDepthCellCounts():
	var depth_counts = Utils.make_2d_array(self.dims()[0],self.dims()[1],[])
	var blank = false;

	for j in range(self.dims()[1]):
		for i in range(self.dims()[0]):
			var depth_rep = []
			for k in range(self.dims()[2]):
				if (self.cellExists(i, j, k)):
					if (depth_rep.size() == 0 || blank):
						depth_rep.push_back(1);
						blank = false;
					else:
						depth_rep[depth_rep.size() - 1] += 1
				else:
					blank = true; #there's at least one blank between two groups
			depth_counts[i][j] = depth_rep;

	return depth_counts;

func description():
	return [
		self.getRowCellCounts(),
		self.getColCellCounts(),
		self.getDepthCellCounts()
	]

func getRow(j: int, k: int): # returns array of CellState
	var row = [];

	for i in range(self.dims()[0]):
		row.push_back(self.getCell(i, j, k));

	return row;

func getCol(i: int, k: int): # returns array of CellState
	var col = [];

	for j in range(self.dims()[1]):
		col.push_back(self.getCell(i, j, k));

	return col;

func getDepth(i: int, j: int): # returns array of CellState
	var depth = [];

	for k in range(self.dims()[2]):
		depth.push_back(self.getCell(i, j, k));

	return depth;

func getLine(x: int, y: int, dir):  # returns array of CellState
	match dir:
		PicrossTypes.LineDirection.row:
			return self.getRow(x, y);
		PicrossTypes.LineDirection.col:
			return self.getCol(x, y);
		PicrossTypes.LineDirection.depth:
			return self.getDepth(x, y);

	return null;

# returns whether the state of the line changes
func setRow(j: int, k: int, info: PicrossTypes.LineInfo) -> bool:
	if (info == null):
		return false;

	var changed = false;

	for block in info.blocks:
		var i = block.start
		while i < block.start + block.length:
			changed = self.setCell(i, j, k, PicrossTypes.CellState.painted) || changed;
			i+=1

	for blank in info.blanks:
		var i = blank.start
		while i < blank.start + blank.length:
			changed = self.setCell(i, j, k, PicrossTypes.CellState.blank) || changed;
			i+=1

	return changed;

func setCol(i: int, k: int, info: PicrossTypes.LineInfo) -> bool:
	var changed = false;

	if (info == null):
		return false;

	for block in info.blocks:
		var j = block.start
		while j < block.start + block.length:
			changed = self.setCell(i, j, k, PicrossTypes.CellState.painted) || changed;
			j+=1

	for blank in info.blanks:
		var j = blank.start
		while j < blank.start + blank.length:
			changed = self.setCell(i, j, k, PicrossTypes.CellState.blank) || changed;
			j+=1

	return changed;

func setDepth(i: int, j: int, info: PicrossTypes.LineInfo) -> bool:
	var changed = false;

	if (info == null):
		return false;

	for block in info.blocks:
		var k = block.start
		while k < block.start + block.length:
			changed = self.setCell(i, j, k, PicrossTypes.CellState.painted) || changed;
			k+=1

	for blank in info.blanks:
		var k = blank.start
		while k < blank.start + blank.length:
			changed = self.setCell(i, j, k, PicrossTypes.CellState.blank) || changed;
			k+=1

	return changed;

func setLine(x: int, y: int, dir, info: PicrossTypes.LineInfo) -> bool:
	match (dir):
		PicrossTypes.LineDirection.row:
			return self.setRow(x, y, info);
		PicrossTypes.LineDirection.col:
			return self.setCol(x, y, info);
		PicrossTypes.LineDirection.depth:
			return self.setDepth(x, y, info);

	return false;


# returns the list of cells surrounded by a blank in the line
func getLineEdges(x: int, y: int, d):
	var line = self.getLine(x, y, d);

	# first and last cells are edges
	var edges = [0, line.size() - 1];

	var i = 0;
	while i < line.size() - 1:
		if (line[i] != PicrossTypes.CellState.blank && (
			line[i - 1] == PicrossTypes.CellState.blank ||
			line[i + 1] == PicrossTypes.CellState.blank)):
			edges.push_back(i);
		i += 1

	return edges;

# static methods

#func get editHistory(): ShapeEditHistory {
#	return {
#		history: self.edits_history,
#		dims: self.dims
#	};
#}
#
#func set editHistory(eh: ShapeEditHistory) {
#	self.editHistory.dims = eh.dims;
#	self.editHistory.history = eh.history;
#}

func restore():
	for edit in self.edits_history:
		self._cells.setAtIdx(edit.idx, edit.from);

	self.edits_history = [];

#func reset(): void {
#	for (const { idx: at } of self.edits_history) {
#		self._cells.setAtIdx(at, CellState.blank);
#	}
#
#	self.edits_history = [];
#}

#func static fromHistory(hist: ShapeEditHistory): PicrossShape {
#	const shape = new PicrossShape(hist.dims, CellState.blank);
#	shape.edits_history = hist.history;
#	shape.restore();
#
#	return shape;
#}

func toJSON():
	return {
		"dims" : self.dims(),
		"cells" : self._cells.data()
	}

func fillBoundingBox():
	var box = self.computeBoundingBox();

	for i in range(box.start[0],box.start[0] + box.dims[0]):
		for j in range(box.start[1],box.start[1] + box.dims[1]):
			for k in range(box.start[2],box.start[2] + box.dims[2]):
				if ! self.cellExists(i, j, k):
					self.setCell(i, j, k, PicrossTypes.CellState.unknown);
