extends Node3D

@export var modifiers:Array = []

func _ready() -> void:
	spawn_debug_boxes(modifiers)

func spawn_debug_boxes(modifiers:Array):
	for child in get_children():
		if child.is_in_group("spawner"):
			if 0.5 < randf():
				child.spawn_box(modifiers)
			else:
				child.spawn_box(["openable"])
