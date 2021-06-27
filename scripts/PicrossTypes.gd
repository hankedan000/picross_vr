extends Object
class_name PicrossTypes

enum LineDirection {
	row = 0, col = 1, depth = 2
}

enum CellState {
	blank, unknown, painted
}

enum HintType {
	simple, circle, square
}

class LineHint:
	var num
	var type
	
class ShapeEdit:
	var from# CellState
	var to# CellState
	var idx# number
	
	func _init(from,to,idx):
		self.from = from
		self.to = to
		self.idx = idx

class ShapeEditHistory:
	var history# ShapeEdit[]
	var dims# number[]
	
class Box:
	var start# number[]
	var dims# number[]
	
class BlockPosition:
	var start;
	var length;
	
	func _init(start: int,length: int):
		self.start = start
		self.length = length
		
	func duplicate():
		return get_script().new(self.start,self.length)
		
	func _to_string():
		return str({"start":start,"length":length})

class LineInfo:
	var blocks;# BlockPosition[]
	var blanks;# BlockPosition[]
	
	func _init(blocks,blanks):
		self.blocks = blocks
		self.blanks = blanks
		
	func _to_string():
		return str({"blocks":blocks,"blanks":blanks})

enum PuzzleDifficulty {
	simple, medium, hard
}
