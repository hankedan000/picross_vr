extends Node
class_name PicrossPuzzleUtils

static func fromJSON(puzzle) -> PicrossPuzzle:
	# make sure the type is an 'int' or else the rest of the code won't cast
	# it to the enum HintType correctly
	for hint2d in puzzle.hints:
		for hint1d in hint2d:
			for i in range(hint1d.size()):
				if hint1d[i] != null:
					hint1d[i].type = int(hint1d[i].type)
	var pzl = PicrossPuzzle.new(puzzle.dims, puzzle.hints);
	pzl._name = puzzle.name;
	return pzl;

#static func isSolvable(puzzle) -> bool:
#	# return PicrossSolver.hierarchicalSolve(this) != null;
#	return PicrossSolver.bruteForceSolve(puzzle) != null;
