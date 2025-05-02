extends CharacterBody3D

#region // references
##gui references
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
@onready var scan_light: SpotLight3D = $scan_light

@onready var ray_interaction: RayCast3D = $camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand: Marker3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D/hand
@onready var path_3d: Path3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D
@onready var path_follow_3d: PathFollow3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D
@onready var rotate_to_player_joint = $camera_pivot/spring_arm_3d/camera/rotate_to_player_joint
@onready var static_body: StaticBody3D = $camera_pivot/spring_arm_3d/camera/StaticBody3D

@onready var no_fly_ray: RayCast3D = $no_fly_ray
#endregion

@export_category("Player variables")

##player variables
@export var speed:int = Settings.player_speed
@export var jump_velocity:float = Settings.player_jump
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
var spring_arm_length = min_zoom_in
var camera_locked_in = false
var spin_locked: bool = false

var flashlight_toggle:bool = false:
	set(v):
		flashlight_toggle = v
		flashlight.visible = flashlight_toggle

## grabbing variables 
var rotation_power = 0.05
var pull_power:float = 10.0
#TODO : remake this to be static, and use a different way to increase player "grip"
var max_obj_speed:float = 10.0:
	set(value):
		value = clamp(value, 4.0, 25.0)
		max_obj_speed = value
var obj_speed_step:float = 1
var object_drag = 0.1
var max_reach = 5.5
var hand_scroll = .35:
	set(v):
		hand_scroll = clamp(v, 0.15, 1)

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
		elif !carrying_obj:
			item_overlay.set_to(null, "off")
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
			_pick_up_object()
var clicked_obj = null

##perspective toggle vars
var current_camera_rotation: Vector3
var holding_perspective_toggle = false:
	set(v):
		holding_perspective_toggle = v
		if holding_perspective_toggle == true:
			_perspective_toggle()


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
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
	
	#TODO: add settings file load/save
	camera.fov = Settings.fov_default
	
	path_follow_3d.progress_ratio = hand_scroll
	path_3d.curve.set_point_position(1, Vector3(path_3d.curve.get_point_position(1).x,path_3d.curve.get_point_position(1).y,-max_reach)) 



#region // private functions 
func _physics_process(delta: float) -> void:
	_player_movement(delta)
	_player_grabbing()
	
	#turn off ray interaction if not in first person mode
	ray_interaction.enabled = bool(perspective == "first")
	
	#handle click ray if mouse visible
	if Input.is_action_pressed("tab"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		clicked_obj = _shoot_click_ray()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#BUG: 
	#this "works", but you can still get insane height using corners
	if no_fly_ray.get_collider() == carrying_obj:
		drop_object()
func _input(event: InputEvent) -> void:
	
	##TODO: rope :)
	#if event.is_action_pressed("toggle_rope"):
	
	if event.is_action_pressed("sprint"):
		Settings.player_speed *= 1.5
		Settings.fov *= 1.05
	
	if event.is_action_released("sprint"):
		Settings.player_speed /= 1.5 
		Settings.fov /= 1.05
	
	#hand scroll
	if event.is_action_pressed("wheel_up"):
		hand_scroll += 0.1
	if event.is_action_pressed("wheel_down"):
		hand_scroll -= 0.1
	
	#perspective toggle
	if event.is_action_pressed("r"):
		holding_perspective_toggle = true
	if event.is_action_released("r"):
		holding_perspective_toggle = false
	
	 # hold r + zoom to zoom camera
	#NOTE: probably will change this keybind later
	if holding_perspective_toggle:
		if spring_arm.spring_length <= .5:
			perspective = "first"
		if event.is_action_pressed("wheel_up"):
			if spring_arm.spring_length >= min_zoom_in:
				spring_arm.spring_length -= 1
		if event.is_action_pressed("wheel_down"):
			if spring_arm.spring_length <= max_zoom_out:
				spring_arm.spring_length += 1
		spring_arm_length = spring_arm.spring_length
	
	#camera zoom
	_zoom(bool(event.is_action_pressed("zoom")))
	
	#flashlight toggle
	if event.is_action_pressed("f"):
		flashlight_toggle = !flashlight_toggle
	
	#open box OR click obj if in mouse visible mode
	if event.is_action_pressed("lmb"):
		if carrying_obj and carrying_obj.is_in_group("openable"):
			box_open_bar.show()
			box_open_timer.start()
	if event.is_action_released("lmb"):
		box_open_timer.stop()
		box_open_bar.hide()
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if clicked_obj and clicked_obj.is_in_group("grabbable"):
				item_overlay.set_to(clicked_obj, "hovering")
			
	#handle mouse motion rotations such as camera & flashlight
	spin_locked = !camera_locked_in
	if !camera_locked_in: #camera unlocked
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			camera_pivot.rotation.y -= event.relative.x * Settings.sensitivity/10000.0
			camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)
			camera_pivot.rotation.x -= event.relative.y * Settings.sensitivity/10000.0
			# -PI/2 = min vertical angle, PI/4 = max vertical angle
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/1.75)
			flashlight.rotation = camera_pivot.rotation
			scan_light.rotation = camera_pivot.rotation
			
	else: #camera locked
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body.rotate_y(deg_to_rad(event.relative.x * rotation_power))
	
	#handle obj rotation
	if event.is_action_pressed("rmb"):
		
		if carrying_obj:
			camera_locked_in = true
	if event.is_action_released("rmb"):
		camera_locked_in = false
	
	#handle obj movement
	if event.is_action_pressed("interact"):
		holding = !holding
func _player_grabbing():
	hovered_obj = _ray_intersect_obj()
	
	#timer pauses instead of refreshing when not hovering. makes holding harder, might get removed/reworked
	grab_buffer_timer.paused = (carrying_obj == hovered_obj and holding)
	if carrying_obj:
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
func _shoot_click_ray():
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
	var result = space_state.intersect_ray(params).get("collider")
	
	if result:
		return result
func _ray_intersect_obj():
	if ray_interaction.is_colliding():
		var obj = ray_interaction.get_collider()
		return obj
func _pick_up_object():
	if carrying_obj:
		return
	var obj = _ray_intersect_obj()
	if obj and obj.is_in_group("grabbable"):
		carrying_obj = obj
		rotate_to_player_joint.set_node_b(obj.get_path())
		if hovered_obj and hovered_obj != carrying_obj:
			rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
			#hovered_obj = null
func _perspective_toggle():
	if spring_arm.spring_length <= .5:
		perspective = "first"
		spring_arm_length = 3
	match perspective:
		"first":
			current_camera_rotation = camera_pivot.rotation
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
func _zoom(zooming):
	if zooming:
		camera.fov = Settings.fov / 2.5
	else:
		camera.fov = Settings.fov
#endregion

#public functions
func drop_object():
	carrying_obj = null
	holding = false
func player_dead():
	position = Vector3(0, 6, 0)
	health = 100
	Global.score = 0

#region // signal connects / settings updates 
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
#endregion
