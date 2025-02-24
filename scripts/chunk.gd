extends StaticBody3D

@export var size: Vector3 = Vector3(50, 10, 50)

func _ready():
	_generate_terrain()

func _generate_terrain():
	var mesh = MeshInstance3D.new()
	# TODO: use noise texture 
	var temp = BoxMesh.new()
	temp.size = size
	mesh.mesh = temp
	add_child(mesh)

	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	collision_shape.shape = shape
	add_child(collision_shape)
