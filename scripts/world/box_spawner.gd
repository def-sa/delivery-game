extends Node3D
@export_group("Box variables")
@export_enum("ECONOMY", "STANDARD", "BUISNESS", "PREMIUM", "FIRST_CLASS", "EXPORT") var tier: int
@export var modifiers: Dictionary = {
	"deliverable": false,
	"detectable": false,
	"grabbable": false,
	"openable": false
}


@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
@export var box_texture: Texture
#if no weight defined, it will default to calculating a weight based on its size
@export var box_weight: float

#TODO: box cannot be resized if box inside
@export var has_box_inside: bool
@export var is_hollow_box: bool
var is_inside_box: bool

@export_group("Inside box variables")
@export var inside_box_modifiers: Dictionary = {
	"deliverable": false,
	"detectable": false,
	"grabbable": false,
	"openable": false
}
@export_range(0.1, .75, 0.01) var _inside_box_size = .5
@onready var inside_box_size = Vector3(_inside_box_size,_inside_box_size,_inside_box_size)
#@export var inside_box_size: Vector3 = Vector3(1,1,1)
@export var inside_box_mass: float
@export var inside_box_texture: Texture
@export var inside_box_weight: float

const box_script = preload("res://scripts/world/box.gd")
const decal_script = preload("res://scripts/world/decal.gd")
const box_spawner_script = preload("res://scripts/world/box_spawner.gd")
const hollow_box_obj = preload("res://assets/world/box/hollow_box.obj")
#const hollow_obj = preload("res://assets/world/box/hollow_obj.tscn")
const hollow_box_collision = preload("res://assets/world/box/hollow_box_collision.tscn")

#TODO : link up id with delivery point
var id 
var is_delivered:bool = false

#TODO 
var street = 0

func _ready() -> void:
	#print(tier)
	
	
	if box_size and !box_weight:
		box_weight = (box_size.x + box_size.y + box_size.z)/3
	if inside_box_size and !inside_box_weight:
		inside_box_weight = (inside_box_size.x + inside_box_size.y + inside_box_size.z)/3
	
	if has_box_inside:
		is_hollow_box = true
	
	if is_hollow_box:
		box_size = Vector3(1,1,1)
	#print(modifiers)
	#TODO: modifiers not being applied correctly? 
	#spawn_box(modifiers)

#i want to pass in variables into the spawner and create the box with those variables 
#modifers x
#rarity x
#texture x
#size x
#weight x
#openable x
#------
# est. value
# from street # (to determine est. value + for id) 
# id
# pos to delivery point

func spawn_box(new_modifiers:Dictionary):
	
	if !modifiers:
		modifiers = new_modifiers
	
	var rigidbody = RigidBody3D.new()
	rigidbody.set_collision_layer_value(2, true)
	rigidbody.set_collision_mask_value(2, true)
	if box_mass > 0:
		rigidbody.mass = box_mass
	
	if is_inside_box:
		rigidbody.continuous_cd = true
	
	var mesh = MeshInstance3D.new()
	if is_hollow_box:
		mesh.mesh = hollow_box_obj
		mesh.transparency = .5
	else:
		var box_mesh = BoxMesh.new()
		box_mesh.size = box_size
		mesh.mesh = box_mesh
		
	if box_texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = box_texture
		mesh.material_override = material
	
	
	
	if is_hollow_box:
		var collision_shapes = hollow_box_collision.instantiate().get_children()
		for shape in collision_shapes:
			rigidbody.add_child(shape.duplicate())
	else:
		var collision = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.extents = box_size / 2  # BoxShape3D uses half-extents
		collision.shape = box_shape
		rigidbody.add_child(collision)
	
	rigidbody.mass = box_weight
	
	if has_box_inside:
		var spawner_node = Node3D.new()
		spawner_node.set_script(box_spawner_script)
		add_child(spawner_node)
		spawner_node.is_inside_box = true
		spawner_node.box_size = inside_box_size
		spawner_node.box_texture = inside_box_texture
		spawner_node.box_mass = inside_box_mass
		
		var obj_spawned = spawner_node.spawn_box(inside_box_modifiers)
		#obj_spawned.gravity_scale = 0
		
		var remote_transform = RemoteTransform3D.new()
		remote_transform.remote_path = spawner_node.get_path()
		remote_transform.update_rotation = false
		remote_transform.update_scale = false
		rigidbody.add_child(remote_transform)
		
		var area_3d = Area3D.new()
		area_3d.set_collision_layer_value(2, true)
		area_3d.set_collision_mask_value(2, true)
		var area_3d_collision = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = box_size
		area_3d_collision.shape = box_shape
		area_3d.add_child(area_3d_collision)
		
		area_3d.connect("body_exited", _body_exited_box_with_item.bind(obj_spawned, rigidbody))
		rigidbody.add_child(area_3d)
	
	
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
	
	
	rigidbody.add_child(shadow_decal)
	rigidbody.add_child(mesh)
	
	
	rigidbody.set_script(box_script)
	
	#object id 
	#tier, street, total boxes spawned, (game name)
	rigidbody.id = str("%01d" % tier) + "x" + str("%03d" % street) + "x" + str("%04d" % Global.total_boxes_spawned) + "xTEST"
	rigidbody.tier = tier
	
	
	#print(rigidbody.get_tree_string_pretty())
	add_child(rigidbody)
	
	for modifier in modifiers.keys():
		if modifiers.get(modifier) == true:
			rigidbody.add_to_group(modifier)
	
	Global.total_boxes_spawned =+ 1
	#print("box spawned:", rigidbody)
	return rigidbody

func _body_exited_box_with_item(body: Node3D, obj_spawned: RigidBody3D, parent_box: RigidBody3D) -> void:
	if body == obj_spawned:
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.global_position = parent_box.global_position
