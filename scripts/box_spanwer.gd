extends Node3D

@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
@export var box_texture: Texture
@export var modifiers: Array

#i want to pass in variables into the spawner and create the box with those variables 
#modifers
#rarity
#texture
#size
#weight
#openable

func spawn_box(modifiers:Array):
	
	var rigidbody = RigidBody3D.new()
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
	
	for modifier in modifiers:
		rigidbody.add_to_group(modifier)
	
	
	add_child(rigidbody)
	print("box spawned:", rigidbody)


#func _process(delta: float) -> void:
	#print(child.get_groups())
