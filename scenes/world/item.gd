class_name Item extends Node3D

@onready var player: CharacterBody3D = $"../../../Player"
@onready var gui: CanvasLayer = $"../../../Player/gui"

@export_group("Box variables")

@export var tiers = {
	"COMMON": false,
	"STANDARD": false,
	"BUISNESS": false,
	"PREMIUM": false,
	"FIRST_CLASS": false,
	"EXPORT": false
}

@export var modifiers = {
	"GRABBABLE": false,
	"DELIVERABLE": false,
	"DETECTABLE": false,
	"OPENABLE": false
}

@export var box_size: Vector3 = Vector3(1, 1, 1)
@export var box_mass: float = 1.0
@export var box_mesh:Mesh
var box_mesh_instance:MeshInstance3D
##can be left blank, will use default box shape
@export var box_collision: CollisionShape3D
@export var box_texture: Texture
##if no weight defined, it will default to averaging a weight based on its size
@export var box_weight: float = ((box_size.x+box_size.y+box_size.z)/3)/box_mass
var box_tier:String
var box_modifiers:Array[String] = []

@export_enum("circle", "square") var shadow_type: String = "square"


#TODO : link up id with delivery point
## id will be generated automatically, type here to override
@export var id: String = "test"
## will be generated automatically, type here to override
@export var street = 0

var current_box:RigidBody3D

var is_delivered:bool = false

var is_detected:bool
var overlay_visible:bool
var item_detection_overlay
var overlays_active := []
var overlay_shake_amount: float = 1.2
var overlay_offset_amount: float = 3.1
@onready var border_offset = Vector2(64, 64)
var reticle_offset = Vector2(0, 0)
var reticle_max_size = 100.0
var reticle_min_size = 1.0
var reticle_max_distance = 44.0



var is_on_rope:bool = false
var rope_array_mesh:ArrayMesh
var rope_mesh_instance:MeshInstance3D
var first_bend_ray:RayCast3D
var end_bend_ray:RayCast3D
#var rope_middle_point = null
var start_bend_point = null
var bend_points = []
var end_bend_point = null


const DECAL = preload("res://scenes/world/decal.tscn")
const ITEM_DETECTION_RECT = preload("res://scenes/ui/item_detection_rect.tscn")

func _ready() -> void:

	for tier in tiers.keys():
		if tiers[tier] == true:
			box_tier = tier
	
	for modifier in modifiers.keys():
		if modifiers[modifier] == true:
			box_modifiers.push_back(modifier)
	
	current_box = spawn_box(modifiers)


func _physics_process(delta: float) -> void:
	_is_on_rope()
	_is_detected(delta)

func _is_detected(delta):
	#reset 
	_clear_detected_overlays()
	#add new detected overlays
	if is_detected and modifiers.has("DETECTABLE"):
		
		item_detection_overlay = ITEM_DETECTION_RECT.duplicate().instantiate()
		gui.item_detection.add_child(item_detection_overlay)
		overlays_active.push_back(item_detection_overlay)
		
		var camera = get_viewport().get_camera_3d()
		#do not show overlay if behind camera
		item_detection_overlay.visible = not camera.is_position_behind(global_position)
		#if object offscreen, show reticle
		gui.cube_behind.visible = not camera.is_position_in_frustum(global_position)
		#for items not in camera view, do reticle
		if not camera.is_position_in_frustum(global_position):
			var reticle_position = camera.unproject_position(global_position)
			gui.cube_behind.global_position = reticle_position
			
			var distance = player.global_position.distance_to(global_position)
			distance = clamp(distance, 1.0, reticle_max_distance)
			#invert size based on difference of distance
			var reticle_size = lerp(reticle_min_size, reticle_max_size, (1.0 - (distance / reticle_max_distance)))
			
			gui.cube_behind.size = Vector2(reticle_size, reticle_size)
			
			#simple 
			#var reticle_size = player.global_position.distance_to(global_position)
			#gui.cube_behind.size = Vector2(reticle_size,reticle_size)
		
		
		#set position of rect 
		var bounding_box = _get_2d_bounding_box(box_mesh_instance)
		var ui_rectangle = item_detection_overlay.rectangle_node
		ui_rectangle.position = bounding_box.position
		ui_rectangle.size = bounding_box.size
		
		#set color based on tier 
		var ui_solid_bg = item_detection_overlay.colored_bg_node
		ui_solid_bg.size.x = bounding_box.size.x
		ui_solid_bg.position.y -= 25
		ui_solid_bg.color = Global.TIER_COLORS[box_tier]
		
		#set ui text -- "ID"
		var ui_text = item_detection_overlay.item_text_node
		ui_text.text = id
		
		#optional shake
		if Settings.scanner_flashing:
			#random delay timer, to not update the bounding box every frame
			await get_tree().create_timer(randf_range(0, 0.10 * delta)).timeout
			if !ui_rectangle: return # this needs to be here if child has been free'd already due to delay
			ui_rectangle.position += Vector2(randf_range(-overlay_shake_amount,overlay_shake_amount),randf_range(-overlay_shake_amount,overlay_shake_amount))
			bounding_box.size += Vector2(randf_range(-overlay_offset_amount,overlay_offset_amount),randf_range(-overlay_offset_amount,overlay_offset_amount))
			bounding_box.position += Vector2(randf_range(-overlay_offset_amount,overlay_offset_amount),randf_range(-overlay_offset_amount,overlay_offset_amount))
			#if offset is more than 6 then make visible
			ui_rectangle.visible = ui_rectangle.position.distance_to(bounding_box.position) <= 6
	else: #not detected
		_clear_detected_overlays()

func _clear_detected_overlays():
	gui.cube_behind.visible = false
	for child in gui.item_detection.get_children():
		if overlays_active.has(child):
			child.queue_free()
			overlays_active.erase(child)

func _get_2d_bounding_box(mesh_instance: MeshInstance3D) -> Rect2:
	# Get the bounding box (AABB) of the 3D object
	var aabb = mesh_instance.get_aabb()
	
	# List of 3D corners of the bounding box
	var corners = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + Vector3(0, 0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
		aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
		aabb.position + aabb.size,
	]
	
	# Project each corner into 2D screen space
	var screen_positions = []
	for corner in corners:
		# Transform the corner to world space
		var global_corner = mesh_instance.global_transform.basis * corner + mesh_instance.global_transform.origin
		var screen_pos = get_viewport().get_camera_3d().unproject_position(global_corner)
		screen_positions.append(screen_pos)
	
	# Find the 2D bounding box
	var min_x = screen_positions[0].x
	var min_y = screen_positions[0].y
	var max_x = screen_positions[0].x
	var max_y = screen_positions[0].y
	
	for pos in screen_positions:
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)
	
	# Return the 2D bounding box
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
func _is_on_rope():
	if is_on_rope and rope_mesh_instance: #create rope, update mesh every frame
		
		rope_array_mesh.clear_surfaces()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		
		var start = to_local(player.global_position + (Vector3.UP * 3))
		var end = to_local(current_box.global_position)
		
		
		var to_end_bend_point = (current_box.global_position - player.global_position).normalized() * 100
		var to_start_bend_point
		if bend_points.size() < 2:
			to_start_bend_point = (end - player.global_position).normalized() * 12
		else:
			to_start_bend_point = to_end_bend_point
			first_bend_ray.global_position = player.global_position
			first_bend_ray.target_position = -bend_points[1]
		
		
		end_bend_ray.global_position = player.global_position
		end_bend_ray.target_position = to_end_bend_point
		
		first_bend_ray.force_raycast_update()
		end_bend_ray.force_raycast_update()
		#if end_bend_ray.is_colliding(): #clear path to box preferred over bend
			#print("colliding with end bend ray")
			#bend_points.clear()
			#bend_points.push_front(start)
			#bend_points.push_back(end)
		#else:
		#bend_points.clear()
		if first_bend_ray.is_colliding(): #if raycast is colliding, save point and use
			var collision = rope_mesh_instance.to_local(first_bend_ray.get_collision_point())
			for i in bend_points.size():
				if collision == bend_points[i]:
					bend_points.push_back(collision)
			if not start_bend_point: #if no start bend point established, create
				start_bend_point = collision
		elif start_bend_point: #didn't hit wall and bend point is active
			bend_points.push_back(rope_mesh_instance.to_local(first_bend_ray.get_collision_point()))
		elif end_bend_ray.is_colliding(): # not colliding, dont bend
			bend_points.clear()
			start_bend_point = null
			
		
		#if bend_points.size() <= 2:
			#return
		if _calculate_total_length(bend_points) >= 20:
			print("SNAP!")
			return
		bend_points.push_front(start)
		bend_points.push_back(end)
		bend_points.push_front(start)
		bend_points.push_back(end)
		print(bend_points)
		
		var color_array = []
		var color = Color(1,1,1)
		for x in bend_points:
			color_array.push_back(color)
		
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bend_points)
		#arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([start, middle]+bend_points+[end_bend_point, end])
		arrays[Mesh.ARRAY_COLOR] = PackedColorArray(color_array)
		rope_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arrays)
		
		rope_mesh_instance.mesh = rope_array_mesh
		#first_bend_ray.enabled = false
	else: #if rope not initialized
		rope_array_mesh = ArrayMesh.new()
		rope_mesh_instance = MeshInstance3D.new()
		
		first_bend_ray = RayCast3D.new()
		first_bend_ray.set_collision_mask_value(1, true)
		first_bend_ray.set_collision_mask_value(2, true)
		first_bend_ray.set_collision_mask_value(3, true)
		first_bend_ray.enabled = false
		first_bend_ray.add_exception(player)
		first_bend_ray.debug_shape_thickness = 4
		first_bend_ray.debug_shape_custom_color = Color.BLUE
		
		end_bend_ray = first_bend_ray.duplicate()
		end_bend_ray.debug_shape_custom_color = Color.RED
		
		add_child(first_bend_ray)
		add_child(end_bend_ray)
		add_child(rope_mesh_instance)
		return
func _calculate_total_length(points: Array) -> float:
	var total_length: float = 0.0
	for i in range(points.size() - 1):
		total_length += points[i].distance_to(points[i + 1])
	return total_length
func spawn_box(modifiers):
	var rigidbody = RigidBody3D.new()
	
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
	
	rigidbody.add_child(collision)
	
	rigidbody.mass = box_weight
	
	var shadow_decal = DECAL.instantiate()
	
	if shadow_type == "circle":
		const CIRCLE_TRANSPARENT = preload("res://assets/circle transparent.png")
		shadow_decal.texture_albedo = CIRCLE_TRANSPARENT
		
	shadow_decal.size.x = box_size.x
	shadow_decal.size.z = box_size.z
	
	rigidbody.add_child(shadow_decal)
	rigidbody.add_child(mesh)
	
	
	
	
	#object id 
	#tier, street, total boxes spawned, (game name)
	#rigidbody.name = str(current_tier) + "x" + str("%03d" % street) + "x" + str("%04d" % Global.total_boxes_spawned) + "xTEST"
	
	#rigidbody.id = str("%01d" % tier) + "x" + str("%03d" % street) + "x" + str("%04d" % Global.total_boxes_spawned) + "xTEST"
	#rigidbody.tier = tier
	
	
	add_child(rigidbody)
	
	rigidbody.set_collision_layer_value(2, true)
	rigidbody.set_collision_mask_value(2, true)
	
	for modifier in modifiers.keys():
		#print(modifier, modifiers[modifier])
		if modifiers[modifier] == true:
			rigidbody.add_to_group(modifier.to_lower())
	
	Global.total_boxes_spawned =+ 1
	#print("box spawned:", rigidbody)
	return rigidbody





#func _body_exited_box_with_item(body: Node3D, obj_spawned: RigidBody3D, parent_box: RigidBody3D) -> void:
	#if body == obj_spawned:
		#body.linear_velocity = Vector3.ZERO
		#body.angular_velocity = Vector3.ZERO
		#body.global_position = parent_box.global_position
