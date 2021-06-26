extends Node
class_name PicrossPuzzleUtils

func fromJSON(puzzle):
	var pzl = PicrossPuzzle.new(puzzle.dims, puzzle.hints);
	pzl.name = puzzle.name;
	return pzl;
