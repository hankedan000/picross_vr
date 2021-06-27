extends Node2D

const HORSE_PUZZLE = {
	"name": "Horse",
	"dims": [4, 4, 1],
	"hints": [
		[
			[{
				"num": 2,
				"type": 1
			}],
			[{
				"num": 3,
				"type": 0
			}],
			[{
				"num": 1,
				"type": 0
			}],
			[{
				"num": 2,
				"type": 0
			}]
		],
		[
			[{
				"num": 2,
				"type": 0
			}],
			[{
				"num": 1,
				"type": 0
			}],
			[null],
			[{
				"num": 1,
				"type": 0
			}]
		],
		[
			[null, null, null, null],
			[null, null, null, null],
			[null, null, null, null],
			[null, null, null, null]
		]
	]
}

func _ready():
#	print(PicrossSolver.simpleLeftMost([3],[1,1,1,1]))
#	return
	var puzzle := PicrossPuzzleUtils.fromJSON(HORSE_PUZZLE)
	var shape := PicrossSolver.bruteForceSolve(puzzle)
	if shape != null:
		print("%s is solvable!" % [puzzle.name()])
	else:
		print("%s is not solvable :(" % [puzzle.name()])
