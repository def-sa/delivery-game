extends CharacterBody3D

@export_category("Player variables")

##player variables
@export var speed:int = 8
@export var jump_velocity:float = 4.5
@export var health:int = 100:
	set(v):
		health = v
		health_bar.value = health
		if v <= 0:
			player_dead()


##camera variables
var min_zoom_in: int = 0 #default spring length
var max_zoom_out: int = 30
var perspective = "first" #default is "first"

## grab object variables 
var rotation_power = 0.05
var pull_power:float = 10.0
#TODO : remake this to be static, and use a different way to increase player "grip"
# remove drag gui and everything
var max_obj_speed:float = 10.0:
	set(value):
		value = clamp(value, 4.0, 25.0)
		#gui_obj_speed_bar.value = value
		max_obj_speed = value
var obj_speed_step:float = 1
var hand_scroll = .35:
	set(v):
		hand_scroll = clamp(v, 0.15, 1)
#TODO : maybe add something with drag?
var object_drag = 0.1
var max_reach = 5.5


##gui item overlay variables
var spin_locked: bool = false
#var spin_speed: Vector3 = Vector3(1,1,1)

##gui references
#@onready var gui_obj_speed_bar: ProgressBar = $GUI_layer/GUI/obj_speed_bar
#@onready var gui_obj_speed_text: RichTextLabel = $GUI_layer/GUI/obj_speed_text
#@onready var gui_cooldown: Timer = $GUI_layer/GUI/gui_cooldown
#@onready var interact_tip_text: Label = $GUI_layer/GUI/interact_tip_text
@onready var grab_buffer_display: ProgressBar = $GUI_layer/GUI/crosshair_grabbing/ProgressBar
@onready var health_bar: ProgressBar = $GUI_layer/GUI/health_bar
@onready var box_open_bar: ProgressBar = $GUI_layer/GUI/MarginContainer/box_open_bar


##timers
@onready var grab_buffer_timer: Timer = $grab_buffer_timer
@onready var box_open_timer: Timer = $box_open_timer

##item overlay
@onready var item_overlay: Control = $GUI_layer/GUI/item_overlay
@onready var item_detection_gui: Control = $GUI_layer/GUI/item_detection


##camera references
@onready var camera_pivot: Node3D = $camera_pivot
@onready var spring_arm: SpringArm3D = $camera_pivot/spring_arm_3d
@onready var spring_position: Node3D = $camera_pivot/spring_arm_3d/spring_position
@onready var camera: Camera3D = $camera_pivot/spring_arm_3d/camera
@onready var flashlight: SpotLight3D = $flashlight
@onready var click_ray: RayCast3D = $camera_pivot/spring_arm_3d/camera/click_ray
@onready var ray_interaction: RayCast3D = $camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand: Marker3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D/hand
@onready var path_3d: Path3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D
@onready var path_follow_3d: PathFollow3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D
@onready var rotate_to_player_joint = $camera_pivot/spring_arm_3d/camera/rotate_to_player_joint
@onready var static_body: StaticBody3D = $camera_pivot/spring_arm_3d/camera/StaticBody3D


@onready var no_fly_ray: RayCast3D = $no_fly_ray
@onready var player: CharacterBody3D = $"."
@onready var item_detection_area: Area3D = $item_detection_area


var spring_arm_length = min_zoom_in
var flashlight_toggle:bool = false:
	set(value):
		flashlight_toggle = value
		flashlight.visible = flashlight_toggle
		
var camera_locked_in = false

var carrying_obj = null: #object itself
	set(v):
		carrying_obj = v
		if carrying_obj:
			carrying_obj.can_sleep = !holding

var hovered_obj = null:
	set(v):
		hovered_obj = v
		if hovered_obj:
			if hovered_obj == carrying_obj and holding:
				item_overlay.set_to(carrying_obj, "holding")
			else:
				if hovered_obj.is_in_group("grabbable"):
					item_overlay.set_to(hovered_obj, "hovering")
		else:
			item_overlay.set_to(carrying_obj, "off")

var holding = false:
	set(v):
		holding = v
		if holding == false:
			#item_overlay.set_to(carrying_obj, "off")
			carrying_obj = null
			grab_buffer_display.hide()
			rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
			holding = null #so we dont keep running these ^^^ 
		if holding == true:
			#start_buffer_timer()
			item_overlay.set_to(carrying_obj, "holding")
			grab_buffer_timer.start()
			grab_buffer_display.show()
			pick_up_object()
			
var current_camera_rotation: Vector3

var holding_perspective_toggle = false

func _ready() -> void:
	
	Signalbus.grab_buffer_expired.connect(_grab_buffer_expired)
	Signalbus.grab_buffer_updated.connect(_grab_buffer_updated)
	Signalbus.player_speed_updated.connect(_player_speed_updated)
	Signalbus.player_jump_updated.connect(_player_jump_updated)
	Signalbus.fov_updated.connect(_fov_updated)
	Signalbus.max_grab_length_updated.connect(_max_grab_length_updated)
	Signalbus.box_open_timer_updated.connect(_box_open_timer_updated)
	Signalbus.box_open_timer_expired.connect(_box_open_timer_expired)
	
	_box_open_timer_updated(Settings.box_open_timer_default)
	_grab_buffer_updated(Settings.grab_buffer_default)
	
	
	_grab_buffer_expired() #reset values
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	spring_arm.spring_length = -1
	
	path_follow_3d.progress_ratio = hand_scroll
	path_3d.curve.set_point_position(1, Vector3(path_3d.curve.get_point_position(1).x,path_3d.curve.get_point_position(1).y,-max_reach)) 

var clicked_obj = null

func _physics_process(delta: float) -> void:
	_player_movement(delta)
	_player_grabbing()
	
	ray_interaction.enabled = bool(perspective == "first")
	
	if Input.is_action_pressed("tab"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		clicked_obj = shoot_click_ray()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if no_fly_ray.get_collider() == carrying_obj:
		drop_object()

func _player_grabbing():
	hovered_obj = _ray_intersect_obj()
	grab_buffer_timer.paused = (carrying_obj == hovered_obj and holding)
	if carrying_obj:
		#grab_buffer_timer.start()
		grab_buffer_display.value = grab_buffer_timer.time_left
		box_open_bar.value = box_open_timer.time_left
		
		var a = carrying_obj.global_transform.origin
		var b = player_hand.global_transform.origin
		var direction = (b - a)
		var distance = (b - a).length() * object_drag
		var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
		
		#move player_hand inwards/outwards toward the player, using the variable hand_scroll
		path_follow_3d.progress_ratio = hand_scroll
		
		carrying_obj.linear_velocity = direction * movement_speed

func _player_movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	#handle mmovement
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()




func _input(event: InputEvent) -> void:

	
	
	if event.is_action_pressed("cam_zoom_in"):
		hand_scroll += 0.1
	if event.is_action_pressed("cam_zoom_out"):
		hand_scroll += -0.1
	
	#if event.is_action_pressed("toggle_rope"):
		#if carrying_obj and carrying_obj is RigidBody3D:
			#if "is_roped" in carrying_obj:
				#
					#if !carrying_obj.is_roped:
						#if items_on_rope.size() < rope_limit:
							#add_obj_to_rope(carrying_obj)
							#update_rope_ui()
						#else:
							#print("cannot exceed rope limit of : ", rope_limit)
					#else:
						#for item in items_on_rope:
							#if item.rigidbody_attached_to_end == carrying_obj:
								#carrying_obj.is_roped = false
								#items_on_rope.erase(item)
								#item.queue_free()
								#update_rope_ui()
				
	
	#perspective toggle
	if event.is_action_pressed("r"):
		holding_perspective_toggle = true
		perspective_toggle()
	
	if event.is_action_released("r"):
		holding_perspective_toggle = false
		
	#camera zoom
	if event.is_action_pressed("zoom"):
		zoom(true)
	elif event.is_action_released("zoom"):
		zoom(false)
		
	#flashlight toggle
	if event.is_action_pressed("f"):
		if flashlight_toggle:
			flashlight_toggle = false
		else:
			flashlight_toggle = true
	
	if event.is_action_pressed("lmb"):
		if carrying_obj and carrying_obj.is_in_group("openable"):
			box_open_bar.show()
			box_open_timer.start()
	elif event.is_action_released("lmb"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if clicked_obj and clicked_obj.is_in_group("grabbable"):
				item_overlay.set_to(clicked_obj, "hovering")
		box_open_timer.stop()
		#box_open_timer_played_once = false
		box_open_bar.hide()
		
	#handle mouse motion rotations such as camera & flashlight
	if !camera_locked_in:
		spin_locked = false
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			
			camera_pivot.rotation.y -= event.relative.x * Settings.sensitivity/10000.0
			camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)
			
			camera_pivot.rotation.x -= event.relative.y * Settings.sensitivity/10000.0
			# -PI/2 = min vertical angle, PI/4 = max vertical angle
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/1.75)
			
			flashlight.rotation = camera_pivot.rotation
	else: #if camera locked
		spin_locked = true
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body.rotate_y(deg_to_rad(event.relative.x * rotation_power))
	
	if holding_perspective_toggle: # hold r + zoom to zoom camera
		if not event.is_action_pressed("control_grip_in"):
			if event.is_action_pressed("cam_zoom_in"):
				if spring_arm.spring_length >= min_zoom_in:
					spring_arm.spring_length -= 1
					spring_arm_length = spring_arm.spring_length
			
		if not event.is_action_pressed("control_grip_out"):
			if event.is_action_pressed("cam_zoom_out"):
				if spring_arm.spring_length <= max_zoom_out:
					spring_arm.spring_length += 1
					spring_arm_length = spring_arm.spring_length
	#handle obj rotation
	if event.is_action_pressed("rmb"):
		if carrying_obj:
			camera_locked_in = true
	if event.is_action_released("rmb"):
		camera_locked_in = false
	
	#handle obj movement
	if event.is_action_pressed("interact"):
		holding = !holding

func shoot_click_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var ray_length = 1000  # Adjust as needed
	var ray_end = ray_origin + ray_direction * ray_length

	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_end
	#params.collision_mask = 1  # Optional: Set collision layers to check

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(params)
	
	if result.get("collider"):
		return result.get("collider")	

#@onready var rope_follow: RigidBody3D = $rope_follow
#@onready var entities: Node3D = $"../Entities"
#
#func add_obj_to_rope(obj:RigidBody3D):
	##create rope
	#const PATH_3D_ROPE_SCRIPT = preload("res://scripts/path_3d_rope.gd")
	#const PATH_3D_ROPE = preload("res://scenes/path_3d_rope.tscn")
	#var path_3d = PATH_3D_ROPE.instantiate()
	#path_3d.transform.origin = rope_follow.transform.origin
	#path_3d.set_script(PATH_3D_ROPE_SCRIPT)
	#path_3d.number_of_segments = 6
	#path_3d.mesh_sides = 8
	#path_3d.cable_thickness = 0.5
	#path_3d.rigidbody_attached_to_start = rope_follow
	#
	#for pos in path_3d.curve.get_baked_points().size():
		#if pos == 0:
			#path_3d.curve.set_point_position(pos, rope_follow.global_position)
		#if pos == 1:
			#path_3d.curve.set_point_position(pos, obj.global_position)
	#
	#path_3d.rigidbody_attached_to_end = obj
	#if "is_roped" in obj:
		#obj.is_roped = true
	#
	#
	#items_on_rope.push_back(path_3d)
	#entities.add_child(path_3d)


#func update_rope_ui():
	#
	#for child in roped_items_gui.get_children():
		#child.queue_free()
		#
	#for i in items_on_rope.size():
		#var color_rect = ColorRect.new()
		#color_rect.custom_minimum_size = Vector2(250,250)
		#color_rect.color = Color(1.0, 0.0, 0.0, 0.482)
		#roped_items_gui.add_child(color_rect)


func _ray_intersect_obj():
	if ray_interaction.is_colliding():
		var obj = ray_interaction.get_collider()
		return obj

#func check_hover():
	#var obj = _ray_intersect_obj()
	#hovered_obj = obj
	##if obj != hovered_obj:
		
	
	#if carrying_obj:
		#if hovered_obj:
				#hovered_obj = null
				#drop_object()
				#item_overlay.set_to(obj, "off")
	#if carrying_obj:
		#if obj: # carrying_obj obj, ray colliding, obj exists
			##// handle carrying_obj modifiers
			#if obj != hovered_obj:
				#hovered_obj = obj
			#
			#grab_buffer_timer.start()
	#else:
		#if obj:
			#if obj != hovered_obj:
				#hovered_obj = obj
		##else: #if not colliding (obj returns null)
			#item_overlay.set_to(obj, "off")
			#if hovered_obj:
				#hovered_obj = null
			#holding = false #just in case

func pick_up_object():
	if carrying_obj:
		return
	var obj = _ray_intersect_obj()
	if obj and obj.is_in_group("grabbable"):
		carrying_obj = obj
		rotate_to_player_joint.set_node_b(obj.get_path())
		if hovered_obj and hovered_obj != carrying_obj:
			rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
			#hovered_obj = null

func drop_object():
	carrying_obj = null
	holding = false

func player_dead():
	position = Vector3(0, 6, 0)
	health = 100
	Global.score = 0


func perspective_toggle():
	if spring_arm.spring_length <= 1:
		perspective = "first"
		spring_arm_length = 3
	match perspective:
		"first":
			current_camera_rotation = camera_pivot.rotation
			#camera_pivot.rotation = -current_camera_rotation
			if spring_arm.spring_length >= 1:
				camera_pivot.rotation.y = rad_to_deg(180)
				perspective = "third"
				return
			spring_arm.spring_length = spring_arm_length
			camera_pivot.rotation = current_camera_rotation
			perspective = "second"
			##TODO : controls need to be inverted ?
		"second":
			spring_arm.spring_length = spring_arm_length
			camera_pivot.rotation = -current_camera_rotation
			camera_pivot.rotation.y = rad_to_deg(-180)
			perspective = "third"
		"third":
			camera_pivot.rotation = current_camera_rotation
			spring_arm.spring_length = -1
			perspective = "first"

func zoom(zooming):
	if zooming:
		camera.fov = Settings.fov / 2.5
	else:
		camera.fov = Settings.fov

func _grab_buffer_updated(value):
	if value == 0:
		value = 1000000000
	grab_buffer_timer.set_wait_time(value)
	grab_buffer_display.max_value = value
func _grab_buffer_expired():
	#grab_buffer_timer_played_once = false #reset timer
	drop_object()
	grab_buffer_display.hide()

func _on_grab_buffer_timer_timeout() -> void:
	Signalbus.grab_buffer_expired.emit()

func _player_speed_updated(value):
	speed = value

func _player_jump_updated(value):
	jump_velocity = value

#BUG : this crashes the game when updated too fast???? i have no idea why
func _fov_updated(value):
	camera.set_fov(value)

func _max_grab_length_updated(value):
	path_3d.curve.set_point_position(1, Vector3(0,0,-value))

func _box_open_timer_updated(value):
	if value == 0:
		value = 0.01
	box_open_timer.set_wait_time(value)
	box_open_bar.max_value = value

func _box_open_timer_expired():
	box_open_timer.stop()
	box_open_bar.hide()
	if carrying_obj and carrying_obj.is_in_group("openable"):
		item_overlay.set_to(carrying_obj, "off")
		carrying_obj.queue_free()
		drop_object()


func _on_box_open_timer_timeout() -> void:
	Signalbus.box_open_timer_expired.emit()

func _on_item_detection_area_body_entered(body: Node3D) -> void:
	item_detection_gui.item_entered_area(body)
	item_detection_gui.objects_inside_area = item_detection_area.get_overlapping_bodies()

func _on_item_detection_area_body_exited(body: Node3D) -> void:
	item_detection_gui.item_exited_area(body)
	item_detection_gui.objects_inside_area = item_detection_area.get_overlapping_bodies()
