extends StaticBody3D


@onready var house: Node3D = $house
@onready var pavement: CSGBox3D = $pavement_bounding_box/CSGCombiner3D/pavement
@onready var light: OmniLight3D = $light

#@onready var bounding_box: CSGBox3D = $bounding_box

@onready var random_offset_min = 0.0
@onready var random_offset_max = 20

func _ready() -> void:
	var x = randf_range(random_offset_min, random_offset_max)
	var z = randf_range(random_offset_min, random_offset_max)
	house.position += Vector3(x,0,z)
	pavement.position += Vector3(x,0,z)
	light.position += Vector3(x,0,z)
	#for node in bounding_box.get_children():
		#node.position += Vector3(x,0,0)

	
	
