extends StaticBody3D


@onready var house: CSGBox3D = $house


@onready var random_offset_min = 0.0
@onready var random_offset_max = 23

func _ready() -> void:
	var x = randf_range(random_offset_min, random_offset_max)
	var z = randf_range(random_offset_min, random_offset_max)
	house.position += Vector3(x,0,z)
