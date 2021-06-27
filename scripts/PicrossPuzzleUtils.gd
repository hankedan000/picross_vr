extends Node
class_name PicrossPuzzleUtils

static func fromJSON(puzzle) -> PicrossPuzzle:
	var pzl = PicrossPuzzle.new(puzzle.dims, puzzle.hints);
	pzl._name = puzzle.name;
	return pzl;

#static func isSolvable(puzzle) -> bool:
#	# return PicrossSolver.hierarchicalSolve(this) != null;
#	return PicrossSolver.bruteForceSolve(puzzle) != null;
