extends Node

@onready var score_node = get_node("/root/main/Player/CanvasLayer/GUI/score")
var score = 0

func add_score(to_add):
	if to_add:
		score = score + to_add
		score_node.text = str(score)
