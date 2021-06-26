extends Node
class_name PicrossPuzzle

enum HintType {
	simple, circle, square
}

class LineHint:
	var num
	var hint_type
	
var _hints = [[[]]]
