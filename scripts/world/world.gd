extends Node3D
@onready var test_objects: Node3D = $Objects/test_objects

func _ready() -> void:
	spawn_debug_boxes()

func spawn_debug_boxes():
	for child in test_objects.get_children():
		if child.is_in_group("spawner"):
			child.spawn_box(child.modifiers)
			
