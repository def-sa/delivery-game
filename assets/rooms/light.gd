extends CSGBox3D

@onready var light: OmniLight3D = $light

var hall_light_chance = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() < hall_light_chance:
		light.visible = true
	else:
		light.visible = false
