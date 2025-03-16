extends RigidBody3D

@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
@export var box_texture: Texture

var id
var is_delivered: bool = false

@export var modifiers: Array


@onready var rigidbody = $"."
@onready var mesh = $"."/MeshInstance3D
@onready var collision = $"."/CollisionShape3D

#i want to pass in variables into the spawner and create the box with those variables 
#modifers
#rarity
#texture
#size
#weight
#openable


func _ready() -> void:
	if box_texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = box_texture
		mesh.material_override = material
	
	for modifier in modifiers:
		rigidbody.add_to_group(modifier)
