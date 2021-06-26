extends Object
class_name PicrossPuzzle

signal resolved()

enum HintType {
	simple, circle, square
}

class LineHint:
	var num
	var hint_type
	
	func _init(num,hint_type):
		self.num = num
		self.hint_type = hint_type
	
var _hints = null# array of LineHint
var _shape;
var _dims# number[];
var _name := 'Untitled Puzzle';

#constructor(shape: PicrossShape);
#constructor(dims: int[], hints: PuzzleHints);
#constructor(
#	dims_or_shape: int[] | PicrossShape,
#	hints_or_name?: PuzzleHints | string
#) {
#	super();
#	if (arguments.length == 2) {
#		self._dims = dims_or_shape as number[];
#		self._hints = hints_or_name as PuzzleHints;
#		self._shape = new PicrossShape(self._dims, CellState.unknown);
#	} else {
#		self._shape = dims_or_shape as PicrossShape;
#		self._dims = self._shape.dims;
#		self.hints; #generate hints
#		self._shape = new PicrossShape(self._dims, CellState.unknown);
#	}
#}

func checkResolved():
	if (self.isResolved()):
		emit_signal('resolved')

# a puzzle is satisfied when all hints are satisfied
func isResolved() -> bool:
	for d in range(3):
		for x in range(self._shape.dims[PuzzleGenerator.coord_x[d]]):
			for y in range(self._shape.dims[PuzzleGenerator.coord_y[d]]):
				var hint = self.getLineHint(x, y, d);
				if (
					hint != null &&
					!get_script().lineSatifiesHint(self._shape.getLine(x, y, d), hint)
				):
					return false;

	return true;

static func lineSatifiesHint(line, hint) -> bool:
	var cells_count = 0;
	var blocks_count = 0;
	var in_block = false;

	for cell in line:
		if (cells_count > hint.num):
			return false;

		if (cell != PicrossShape.CellState.blank):
			if (!in_block):
				blocks_count += 1;
				in_block = true;
			cells_count += 1;
		elif (in_block):
			in_block = false;

	if (cells_count != hint.num):
		return false;
	elif (hint.num == 0 && cells_count == 0):
		return true;

	match (hint.type):
		HintType.simple:
			return blocks_count == 1;

		HintType.circle:
			return blocks_count == 2;

		HintType.square:
			return blocks_count > 2;

		_:
			return false;

func getRow(j: int, k: int):
	return self._shape.getRow(j, k);

func getCol(i: int, k: int):
	return self._shape.getCol(i, k);

func getDepth(i: int, j: int):
	return self._shape.getDepth(i, j);

func hasHint(x: int, y: int, d) -> bool:
	if (self.hints[d].size() - 1 < x):
		return false;

	return self.hints[d][x][y] != null;

func hints():
	if (self._hints != null):
		return self._hints;

	var desc = self._shape.description();
	self._hints = [];

	for d in range(3):
		self._hints.push_back([]);
		for x in range(self.dims[PuzzleGenerator.coord_x[d]]):
			var line = [];
			for y in range(self.dims[PuzzleGenerator.coord_y[d]]):
				line.push_back(get_script().cellCountToHint(desc[d][x][y]));
			self._hints[d].push_back(line);

	return self._hints;

func getLineHint(x: int, y: int, d):
	if self.hints[d].size() - 1 < x:
		return null;

	return self.hints[d][x][y];

func shape():
	return self._shape;

func setShape(new_shape):
	self._shape = new_shape;

func isSolvable() -> bool:
	# return PicrossSolver.hierarchicalSolve(this) != null;
	return PicrossSolver.bruteForceSolve(self) != null;

static func cellCountToHint(seq):
	if (seq == null || seq.size() == 0):
		return LineHint.new(0,HintType.simple);

	var sum = 0
	for group in seq:
		sum += group
	var group_count = seq.size();

	if (group_count == 1): return LineHint.new(sum,HintType.simple);
	if (group_count == 2): return LineHint.new(sum,HintType.circle);
	if (group_count >= 3): return LineHint.new(sum,HintType.square);

func toJSON():
	return {
		dims: self.dims,
		hints: self.hints,
		name: self._name
	};

func restart():
	self._shape.restore();

func dims():
	return self._dims;

func name() -> String:
	return self._name;

func setName(name: String):
	self._name = name;
