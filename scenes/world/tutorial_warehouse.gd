extends StaticBody3D
@onready var box: Node3D = $box

func _ready() -> void:
	box.spawn_box(null)
