extends Node

var street = 0
var delivered = 0
var total_boxes_spawned = 0


@onready var score_node = get_node("/root/main/World/Player/CanvasLayer/GUI/score")
var score = 0:
	set(v):
		score = v
		score_node.text = str(score)
