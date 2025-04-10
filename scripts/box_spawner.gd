extends Node3D

@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
@export var box_texture: Texture
#if no weight defined, it will default to calculating a weight based on its size
@export var box_weight: float

const box_script = preload("res://scenes/box.gd")
const decal_script = preload("res://scenes/decal.gd")

#TODO : link up id with delivery point
var id 
var is_delivered:bool = false
@export var modifiers: Array


#TODO
var tier = 0
#TODO 
var street = 0

func _ready() -> void:
	if box_size and !box_weight:
		box_weight = (box_size.x + box_size.y + box_size.z)/3


#i want to pass in variables into the spawner and create the box with those variables 
#modifers x
#rarity
#texture x
#size x
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
	
	rigidbody.mass = box_weight
	
	var shadow_decal = Decal.new()
	var noise_texture = NoiseTexture2D.new()
	noise_texture.width = 1
	noise_texture.height = 1
	
	shadow_decal.texture_albedo = noise_texture
	shadow_decal.modulate = Color(0.0, 0.0, 0.0)
	shadow_decal.size.x = box_size.x
	shadow_decal.size.z = box_size.z
	shadow_decal.size.y = 20
	shadow_decal.lower_fade = 2
	shadow_decal.upper_fade = .5
	shadow_decal.position.y = -10.55
	shadow_decal.distance_fade_enabled = true
	shadow_decal.distance_fade_begin = 0.0
	shadow_decal.distance_fade_length = 20
	shadow_decal.set_script(decal_script)
	
	#var on_screen_notifier = VisibleOnScreenNotifier3D.new()
	#on_screen_notifier.aabb = box_mesh.get_aabb()
	
	
	
	
	#rigidbody.add_child(on_screen_notifier)
	rigidbody.add_child(shadow_decal)
	rigidbody.add_child(mesh)
	rigidbody.add_child(collision)
	
	rigidbody.set_script(box_script)
	
	#object id 
	#tier, street, total boxes spawned, (game name)
	rigidbody.id = str("%01d" % tier) + "x" + str("%03d" % street) + "x" + str("%04d" % Global.total_boxes_spawned) + "xTEST"
	rigidbody.tier = tier
	
	for modifier in modifiers:
		rigidbody.add_to_group(modifier)
	
	
	add_child(rigidbody)
	Global.total_boxes_spawned =+ 1
	print("box spawned:", rigidbody)
