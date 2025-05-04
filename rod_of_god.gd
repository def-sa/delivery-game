extends StaticBody3D

@onready var ground: CSGBox3D = $ground
@onready var rod_of_god: MeshInstance3D = $rod_of_god

func _ready() -> void:
	for hole in ground.get_children():
		hole.radius = randf_range(12,22)
		var y = randf_range(-6,6)
		hole.position += Vector3(y,y,0)
		var x = randf_range(0,180)
		rod_of_god.rotation += Vector3(x,x,x)
