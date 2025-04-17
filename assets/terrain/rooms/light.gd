extends CSGBox3D

@onready var box_spawner: Node3D = $box_spawner
@onready var light: OmniLight3D = $light
@export var modifiers: Dictionary = {
	"deliverable": false,
	"detectable": false,
	"grabbable": false,
	"openable": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if box_spawner:
		box_spawner.spawn_box(modifiers)
	if light:
		if randf() > .5:
			light.hide()
