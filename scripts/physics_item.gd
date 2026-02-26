extends RigidBody3D
class_name physics_item

@export_group("Paths")
@export var player: CharacterBody3D
@export var gui: Control
@export var detected_overlay_container: Control
@export var camera: Camera3D

@export_group("Box variables")
@export var box_name:String
#TODO : link up id with delivery point
## id will be generated automatically, type here to override
@export var id: String
@export var box_description: String = "cannot generate description for item."

var box_tier:String
@export var tiers = {
	"COMMON": true,
	"STANDARD": false,
	"BUISNESS": false,
	"PREMIUM": false,
	"FIRST_CLASS": false,
	"EXPORT": false
}

var box_modifiers:Array[String] = []
@export var modifiers = {
	"GRABBABLE": false,
	"DELIVERABLE": false,
	"DETECTABLE": true,
	"OPENABLE": false,
	"SCANNABLE": false,
	"BREAKABLE": false,
	"EXPLODE_ON_DEATH": false,
	"FLAMMABLE": false
}


@export var box_mesh:Mesh
var box_mesh_instance:MeshInstance3D
##can be left blank, will use default box shape
@export var box_collision: CollisionShape3D
@export var box_texture: Texture
@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_scale: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
##if no weight defined, it will default to averaging a weight based on its size
@export var box_weight: float = ((box_size.x+box_size.y+box_size.z)/3)/box_mass
@export_enum("circle", "square", "none") var shadow_type: String = "square"

var current_box:RigidBody3D
enum BOX_STATES {
	IDLE,
	DELIVERED,
	ON_CART,
	ON_ROPE,
	SCANNED
}

var box_state:int:
	set(v):
		if box_state == v: return
		print("box state : " + str(BOX_STATES.keys()[v]))
		_set_box_state(box_state, v)
		
		box_state = v

var box_overlay

var is_being_held:
	set(v):
		is_being_held = v
		if not box_overlay: return #can be deleted too soon, so check 
		if is_being_held:
			box_overlay.overlay_state = box_overlay.OVERLAY_STATES.HELD
		else:
			box_overlay.overlay_state = box_overlay.OVERLAY_STATES.UNDETECTED

#var rope_array_mesh:ArrayMesh
#var rope_mesh_instance:MeshInstance3D
#var first_bend_ray:RayCast3D
#var end_bend_ray:RayCast3D
##var rope_middle_point = null
#var start_bend_point = null
#var bend_points = []
#var end_bend_point = null

@export_group("Health variables")
@export var has_health:bool = true
# clamped 0 to 1, 0 = normal, 1 = invulnerable
var invulnerable_percent: float = 0.0
var i_frames:bool:
	set(v):
		i_frames = v
		if i_frames == true:
			await get_tree().create_timer(0.075).timeout
			i_frames = false

var health_bar_node
var box_health:float:
	set(v):
		if box_overlay:
			box_overlay.set_health_ui(box_health, v)
			box_overlay.set_box_damaged_state(box_health)
		box_health = v
		if box_health <= 0: break_box(true)
	
@export var box_max_health:float = 100.0
@export var box_damage_sensitivity:float = 1.0
var box_damage_particle_node

const DECAL = preload("res://scenes/decal.tscn")
const ITEM_DETECTION_RECT = preload("res://scenes/item_detection_rect.tscn")
const GROUND_HIT_PARTICLE = preload("res://scenes/ground_hit_particle.tscn")
const DEFAULT_BOX_BREAK_PARTICLE = preload("res://scenes/default_box_break_particle.tscn")
const EXPLOSION = preload("res://scenes/explosion.tscn")

## TODO : fix rope
func _ready() -> void:
	
	box_health = box_max_health
	
	for tier in tiers.keys():
		if tiers[tier] == true:
			box_tier = tier
			
	current_box = spawn_box(modifiers)
	box_state = BOX_STATES.IDLE


func _set_box_state(current_box_state, new_box_state) -> void:
	if not current_box_state and not new_box_state: return
	#print(box_overlay.connected_box_state, new_box_state)
	
	match new_box_state:
		BOX_STATES.IDLE:
			if not modifiers["DETECTABLE"]: return
			if not box_overlay: return
			box_overlay.visible = false
			invulnerable_percent = 0.0
			pass
		BOX_STATES.DELIVERED:
			break_box(false)
			pass
		BOX_STATES.ON_CART:
			invulnerable_percent = 0.9
			pass
		BOX_STATES.ON_ROPE:
			pass
		BOX_STATES.SCANNED:
			pass


##optional shake
#if Settings.scanner_flashing:
	##random delay timer, to not update the bounding box every frame
	#await get_tree().create_timer(randf_range(0, 0.10 * delta)).timeout
	#if !ui_rectangle: return # this needs to be here if child has been free'd already due to delay
	#ui_rectangle.position += Vector2(randf_range(-overlay_shake_amount,overlay_shake_amount),randf_range(-overlay_shake_amount,overlay_shake_amount))
	#bounding_box.size += Vector2(randf_range(-overlay_offset_amount,overlay_offset_amount),randf_range(-overlay_offset_amount,overlay_offset_amount))
	#bounding_box.position += Vector2(randf_range(-overlay_offset_amount,overlay_offset_amount),randf_range(-overlay_offset_amount,overlay_offset_amount))
	##if offset is more than 6 then make visible
	#ui_rectangle.visible = ui_rectangle.position.distance_to(bounding_box.position) <= 6

#region damage handling
func _on_damage_taken(body:Node):
	if i_frames == true: return
	i_frames = true
	if body == player: return
	
	
	if not box_damage_particle_node:
		var particle_node = GROUND_HIT_PARTICLE.instantiate()
		add_child(particle_node)
		box_damage_particle_node = particle_node
	
	var body_velocity
	if body is not RigidBody3D: 
		body_velocity = Vector3.ZERO
	else:
		body_velocity = body.linear_velocity
	
	#box takes more damage from y velocity than others
	var box_velocity = Vector3(\
	current_box.linear_velocity.x*(box_damage_sensitivity / 3),\
	current_box.linear_velocity.y*(box_damage_sensitivity / 4),\
	current_box.linear_velocity.z*(box_damage_sensitivity / 3))
	
	var speed = (body_velocity - box_velocity).length()
	box_health -= speed * (1.0 - invulnerable_percent)
	print("DAMAGE TAKEN: ", speed * (1.0 - invulnerable_percent))
	box_damage_particle_node.global_position = current_box.global_position + Vector3(0, -box_size.y, 0)
	box_damage_particle_node.emitting = true
func break_box(play_animation:bool):
	box_state == BOX_STATES.IDLE
	box_overlay.overlay_state = box_overlay.OVERLAY_STATES.UNDETECTED
	
	if modifiers["EXPLODE_ON_DEATH"] == true:
		explode()
	
	if play_animation:
		var break_particle = DEFAULT_BOX_BREAK_PARTICLE.instantiate()
		add_child(break_particle)
		break_particle.global_position = current_box.global_position
		
		break_particle.restart()
		break_particle.connect("finished", _on_broken_animation_finished)
		for child in get_children():
			if not child == break_particle:
				child.queue_free()
	else:
		queue_free()
func _on_broken_animation_finished():
	queue_free()
func explode():
	var explosion = EXPLOSION.instantiate()
	explosion.connected_physics_item = self
	add_child(explosion)
#endregion 

func spawn_box(modifiers):
	var rigidbody = self
	
	if box_mass > 0:
		rigidbody.mass = box_mass
		
	var mesh = MeshInstance3D.new()
	box_mesh_instance = mesh
	if box_mesh:
		if box_mesh is BoxMesh and box_size != Vector3(1, 1, 1):
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
	
	add_child(collision)
	box_collision = collision
	
	rigidbody.mass = box_weight
	
	if not id:
		id = name
	
	if not shadow_type == "none":
		
		var shadow_decal = DECAL.instantiate()
		if shadow_type == "circle":
			const CIRCLE_TRANSPARENT = preload("res://assets/circle transparent.png")
			shadow_decal.texture_albedo = CIRCLE_TRANSPARENT
			
		shadow_decal.size.x = box_size.x
		shadow_decal.size.z = box_size.z
		add_child(shadow_decal)
		
	add_child(mesh)
	rigidbody.scale = box_scale
	
	# always make an overlay , could lead to performance issues if many boxes are spawned
	#if not box_overlay:
	box_overlay = ITEM_DETECTION_RECT.duplicate().instantiate()
	
	box_overlay.connected_box = rigidbody
	box_overlay.color = Global.TIER_COLORS[box_tier]
	box_overlay.name_text = box_name
	box_overlay.id = id
	box_overlay.description = box_description
	box_overlay.visible = false
	detected_overlay_container.add_child(box_overlay)
	
	#initalize healthbar
	box_overlay.has_health = [has_health, box_max_health]
	box_health = box_max_health
	
	#if breakable, attached damage function
	if modifiers["BREAKABLE"] == true:
		rigidbody.contact_monitor = true
		rigidbody.max_contacts_reported = 1
		rigidbody.connect("body_entered", _on_damage_taken)
	
	#object id 
	#tier, street, total boxes spawned, (game name)
	#rigidbody.name = str(current_tier) + "x" + str("%03d" % street) + "x" + str("%04d" % Global.total_boxes_spawned) + "xTEST"
	
	#rigidbody.id = str("%01d" % tier) + "x" + str("%03d" % street) + "x" + str("%04d" % Global.total_boxes_spawned) + "xTEST"
	#rigidbody.tier = tier
	
	
	#add_child(rigidbody)
	
	#player can push, and terrain collision
	rigidbody.set_collision_mask_value(1, true)
	rigidbody.set_collision_layer_value(1, false)
	
	rigidbody.set_collision_mask_value(2, true)
	rigidbody.set_collision_layer_value(2, true)
	
	
	
	for modifier in modifiers.keys():
		#print(modifier, modifiers[modifier])
		if modifiers[modifier] == true:
			rigidbody.add_to_group(modifier.to_lower())
	
	
	Global.total_boxes_spawned =+ 1
	#print("box spawned:", rigidbody)
	return rigidbody
