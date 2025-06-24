extends Control

@onready var player: CharacterBody3D = $"../.."
#@onready var box: RigidBody3D = $World/box
@onready var camera: Camera3D = $"../../camera_pivot/spring_arm_3d/camera"
@onready var offscreen_reticle: TextureRect = $offscreen_reticle
@onready var negative_shader = preload("res://shaders/negative.gdshader")
@onready var item_detection_timer: Timer = $"../../item_detection_timer"
@onready var item_detection_area: Area3D = $"../../item_detection_area"
#@onready var far_scan_light: SpotLight3D = $"../../far_scan_light"
#@onready var short_scan_light: OmniLight3D = $"../../short_scan_light"

const ITEM_DETECTION_RECT = preload("res://scenes/ui/item_detection_rect.tscn")

#object
var objects_inside_area = []:
	set(v):
		v.erase(player)
		objects_inside_area = v
		print(objects_inside_area)

var item_detection_overlays = []
#[object, current ui container]
#var items_detected_dict:Array[Dictionary]
	#set(v):
		#print(connected_nodes_array)

#[object, current ui container]
#var connected_nodes_array = []

@onready var viewport_center = Vector2(get_viewport().size) / 2.0
@onready var border_offset = Vector2(32, 32)
@onready var max_reticle_position = viewport_center - border_offset
var reticle_offset = Vector2(32, 32)

#object reticle, thank you 
# https://www.youtube.com/watch?v=EKVYfF8oG0s
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("rmb"):
		item_detection_timer.start()
		#far_scan_light.spot_range = 4096
		#short_scan_light.light_energy = 5
		
	#far_scan_light.visible = item_detection_timer.time_left > 0
	if item_detection_timer.time_left > 0:
		#far_scan_light.spot_range -= item_detection_area.scale.x * 14.05 # this lines up almost perfectly scaling with the item detection timer
		item_detection_area.scale = Vector3(item_detection_timer.time_left,item_detection_timer.time_left,item_detection_timer.time_left)
	#else:
		#far_scan_light.spot_range = 0
	
	#offscreen_reticle.visible = objects_inside_area.is_empty()
	

func item_entered_area(object):
	if object == player: return
	var parent = object.get_parent()
	if "is_detected" in parent:
		parent.is_detected = true

func item_exited_area(object):
	if object == player: return
	var parent = object.get_parent()
	if "is_detected" in parent:
		parent.is_detected = false



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


func _on_item_detection_timer_timeout() -> void:
	item_detection_area.scale = Vector3(0.01,0.01,0.01)


func _on_item_detection_area_body_entered(body: Node3D) -> void:
	item_entered_area(body)
	objects_inside_area = item_detection_area.get_overlapping_bodies()

func _on_item_detection_area_body_exited(body: Node3D) -> void:
	item_exited_area(body)
	objects_inside_area = item_detection_area.get_overlapping_bodies()
