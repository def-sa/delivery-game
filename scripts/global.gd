extends Node

var delivered = 0
var total_boxes_spawned = 0
var current_block = 0




const TIER_COLORS = {
	"COMMON": Color("999999"),
	"STANDARD": Color("ebebeb"),
	"BUISNESS": Color("91ff80"),
	"PREMIUM": Color("80aeff"),
	"FIRST_CLASS": Color("8280ff"),
	"EXPORT": Color("ffff52")
}

const MODIFIERS = {
	"GRABBALBE": "Can be grabbed",
	"DELIVERABLE": "Can be delivered to a delivery point",
	"DETECTABLE": "Can be detected by your scanner",
	"OPENABLE": "Can be opened"
}

const AR_CODES = {
	"SCAN_LIGHT": ""
}

@onready var score_node = get_node("/root/main/World/Player/gui/score")

var score = 0:
	set(v):
		score = v
		score_node.text = str(score)

var dialogues = {
	"TXT_DUMMY": ["Hello, traveler!", "Beware of the dangers ahead.", "Take this map, it will help you."],
	"merchant": ["Welcome to my shop!", "I have the finest goods in town."]
}


enum PLAYER_STATES {
		IDLE,
		WALKING,
		SPRINTING,
		JUMPING,
		CROUCHING,
		CLIMBING,
		TYPING
}

enum OVERLAY_STATES {
	UNDETECTED,
	DETECTED,
	HELD,
	MOUSE_CLICKED,
	MOUSE_HOVERED
	}

enum BOX_STATES {
	IDLE,
	DELIVERED,
	ON_CART,
	ON_ROPE,
	SCANNED
}
