extends Node3D
@onready var objects: Node3D = $Objects

func _ready() -> void:
	spawn_debug_boxes()

func spawn_debug_boxes():
	for child in objects.get_children():
		if child.is_in_group("spawner"):
			child.spawn_box(child.modifiers)
			
