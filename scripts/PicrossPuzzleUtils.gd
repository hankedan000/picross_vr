extends Node
class_name PicrossPuzzleUtils

static func fromJSON(puzzle):
	var pzl = PicrossPuzzle.new(puzzle.dims, puzzle.hints);
	pzl.name = puzzle.name;
	return pzl;

static func isSolvable(puzzle) -> bool:
	# return PicrossSolver.hierarchicalSolve(this) != null;
	return PicrossSolver.bruteForceSolve(puzzle) != null;
