extends Node

var street = 0
var delivered = 0
var total_boxes_spawned = 0

const TIER_COLORS = {
	"COMMON": Color("999999"),
	"STANDARD": Color("ebebeb"),
	"BUISNESS": Color("91ff80"),
	"PREMIUM": Color("80aeff"),
	"FIRST_CLASS": Color("8280ff"),
	"EXPORT": Color("ffff52")
}

@onready var score_node = get_node("/root/main/World/Player/GUI_layer/GUI/score")

var score = 0:
	set(v):
		score = v
		score_node.text = str(score)

var dialogues = {
	"TXT_DUMMY": ["Hello, traveler!", "Beware of the dangers ahead.", "Take this map, it will help you."],
	"merchant": ["Welcome to my shop!", "I have the finest goods in town."]
}
