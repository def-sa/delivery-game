extends Node3D
class_name box_spawner

#modifers
#rarity
#texture
#size
#weight


@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
@export var box_texture: Texture


func spawn_box():
	var rigidbody = RigidBody3D.new()
	rigidbody.add_to_group("grabbable")
	rigidbody.mass = box_mass
	
	var mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = box_size
	mesh.mesh = box_mesh
	
	if box_texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = box_texture
		mesh.material_override = material
	
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.extents = box_size / 2  # BoxShape3D uses half-extents
	collision.shape = box_shape
	
	rigidbody.add_child(mesh)
	rigidbody.add_child(collision)
	add_child(rigidbody)
	print("box spawned:", rigidbody)
