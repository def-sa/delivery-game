extends Node3D

#@export var modifiers:Array[String] = []
#
func _ready() -> void:
	spawn_debug_boxes()

func spawn_debug_boxes():
	for child in get_children():
		if child.is_in_group("spawner"):
			child.spawn_box(child.modifiers)
			
			
			#if 0.5 < randf():
				#child.spawn_box(modifiers)
			#else:
				#child.spawn_box(["openable"])
