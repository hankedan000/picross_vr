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

const PLATYPUS = {
	"dims": [12, 3, 5],
	"hints": [
		[
			[{
				"num": 2,
				"type": 1
			}, null, null, null, {
				"num": 2,
				"type": 1
			}],
			[{
				"num": 8,
				"type": 0
			}, null, null, null, {
				"num": 8,
				"type": 0
			}],
			[{
				"num": 6,
				"type": 0
			}, {
				"num": 9,
				"type": 0
			}, {
				"num": 9,
				"type": 0
			}, {
				"num": 9,
				"type": 0
			}, {
				"num": 6,
				"type": 0
			}]
		],
		[
			[null, {
				"num": 0,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 0,
				"type": 0
			}, null],
			[{
				"num": 2,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}],
			[null, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, null],
			[null, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, null],
			[null, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, null],
			[null, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, null],
			[null, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, null],
			[{
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}],
			[{
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}],
			[null, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, null],
			[{
				"num": 0,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 2,
				"type": 0
			}, {
				"num": 0,
				"type": 0
			}],
			[{
				"num": 0,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 1,
				"type": 0
			}, {
				"num": 0,
				"type": 0
			}]
		],
		[
			[null, {
				"num": 1,
				"type": 0
			}, null],
			[{
				"num": 2,
				"type": 1
			}, null, null],
			[null, null, null],
			[null, null, null],
			[null, null, null],
			[null, null, null],
			[null, null, null],
			[null, null, null],
			[{
				"num": 2,
				"type": 1
			}, null, null],
			[null, null, null],
			[null, null, {
				"num": 3,
				"type": 0
			}],
			[null, {
				"num": 3,
				"type": 0
			}, null]
		]
	],
	"name": "Platypus"
}

func _ready():
	var puzzles_json = [HORSE_PUZZLE,PLATYPUS]
	for puzzle_json in puzzles_json:
		var puzzle := PicrossPuzzleUtils.fromJSON(puzzle_json)
		var shape := PicrossSolver.bruteForceSolve(puzzle)
		if shape != null:
			print("%s is solvable!" % [puzzle.name()])
			print(shape.cells())
		else:
			print("%s is not solvable :(" % [puzzle.name()])
