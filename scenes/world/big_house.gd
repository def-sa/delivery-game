extends StaticBody3D

@onready var csg_boxes: CSGBox3D = $outer

@export var front_deck_chance: Dictionary = {"front_deck": 0.3}
@export var front_door_chance: Dictionary = {"front_door": 1.0}

@onready var all_variables: Array = [
	front_deck_chance,
	front_door_chance
]

func _ready() -> void:
	for child in csg_boxes.get_children():
		# For each chance dictionary, match the key with part of the child's name
		for chance_option in all_variables:
			var key: String = chance_option.keys()[0]
			if child.get_name().contains(key):
				# Directly use the chance value for visibility.
				var probability: float = chance_option[key]
				child.visible = randf() < probability
