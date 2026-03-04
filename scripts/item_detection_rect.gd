extends Control

@export var rectangle_node: ReferenceRect

@export var left_bar_node: ColorRect
@export var right_bar_node: ColorRect
@export var top_bar_node: ColorRect
@export var bottom_bar_node: ColorRect

@export var description_label: RichTextLabel
@export var name_label: Label

var health_bar_node
var connected_box:
	set(v):
		connected_box = v
		print(connected_box)

var color: Color
var name_text: String
var id: String
var description: String

#visibility, max health
var has_health = [true, 100]:
	set(v):
		has_health = v
		if has_health[0] and health_bar_node: return
		_init_healthbar(has_health[0], has_health[1])
const HEALTHBAR = preload("res://scenes/healthbar.tscn")

var overlay_state:int:
	set(v):
		_set_overlay_state(overlay_state, v)
		overlay_state = v
		print("overlay state: ", str(OVERLAY_STATES.keys()[v]))
		
enum OVERLAY_STATES {
	UNDETECTED,
	DETECTED,
	HELD,
	MOUSE_CLICKED,
	MOUSE_HOVERED
	}

var is_discovered = false
var healthbar_visible = true
var show_overlay = false:
	set(v):
		show_overlay = v
		self.visible = show_overlay


func _ready() -> void:
	set_as_top_level(true)
	overlay_state = OVERLAY_STATES.UNDETECTED
	set_color(Color(1,1,1,.5))
	set_name_text("???")

func set_color(new_color:Color):
	rectangle_node.border_color = new_color
	top_bar_node.color = new_color
	#left_bar_node.color = new_color
func set_name_text(new_text:String):
	if name_text == "" and is_discovered: 
		name_label.text = id
	else:
		name_label.text = new_text
func set_description(new_text:String):
	description_label.text = new_text

func _set_overlay_state(current_overlay_state, new_overlay_state):
	if not current_overlay_state and not new_overlay_state: return
	if health_bar_node: health_bar_node.visible = healthbar_visible
	description_label.visible = true
	
	
	match new_overlay_state:
		OVERLAY_STATES.UNDETECTED:
			show_overlay = false
			pass
		OVERLAY_STATES.DETECTED:
			show_overlay = true
			description_label.visible = false
			#print(connected_box_state, Global.BOX_STATES.ON_CART)
			if not connected_box.box_state == Global.BOX_STATES.ON_CART:
				if health_bar_node: health_bar_node.visible = false
			
			pass
		OVERLAY_STATES.HELD:
			held_or_clicked()
			pass
		OVERLAY_STATES.MOUSE_CLICKED:
			held_or_clicked()
			pass
		OVERLAY_STATES.MOUSE_HOVERED:
			
			pass


func held_or_clicked():
	show_overlay = true
	if not is_discovered: is_discovered = true

func _init_healthbar(visibility:bool, max_health:float):
	health_bar_node = HEALTHBAR.duplicate().instantiate()
	
	left_bar_node.add_child(health_bar_node)
	health_bar_node.set_max_health(max_health)
	
	health_bar_node.position = left_bar_node.position + Vector2(-left_bar_node.size.x - 16,0)
	healthbar_visible = visibility 
	
func set_health_ui(current_health:float, new_health:float):
	health_bar_node.set_health_ui(current_health, new_health)
func set_box_damaged_state(box_health:float):
	health_bar_node.set_box_damaged_state(box_health, connected_box.box_mesh_instance)

func _process(delta: float) -> void:
	if show_overlay:
		_position_ui()
		
	if not is_discovered: return
	set_color(color)
	set_name_text(name_text)
	set_description(description)
	
	#await get_tree().create_timer(0.1).timeout
	## TODO: figure out shake

func _position_ui():
	#if queue free'd mesh instance can be null, so check for that
	if not connected_box.box_mesh_instance: return
	if not health_bar_node: return
	
	#health_bar_node.visible = self.visible
	var camera = get_viewport().get_camera_3d()
	self.visible = not camera.is_position_behind(connected_box.global_position)

	var rect_vars = _get_2d_bounding_box(connected_box.box_mesh_instance)
	position = rect_vars.position
	
	rectangle_node.size = rect_vars.size
	name_label.size = rect_vars.size
	top_bar_node.size.x = rect_vars.size.x
	left_bar_node.size.y = rect_vars.size.y
	
	if has_health[0] == true:
		health_bar_node.aspect_ratio_container.custom_minimum_size = left_bar_node.size
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
