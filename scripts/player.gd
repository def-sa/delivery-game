extends CharacterBody3D

##player variables
@export var speed:int = 8
@export var jump_velocity:float = 4.5

##camera variables
var min_zoom_in: int = 0 #default spring length
var max_zoom_out: int = 30
var perspective = "first" #default is "first"

## grab object variables  
var rotation_power = 0.05
var pull_power:float = 10.0
#TODO : remake this to be static, and use a different way to increase player "grip"
var max_obj_speed:float = 10.0:
	set(value):
		value = clamp(value, 4.0, 25.0)
		gui_obj_speed_bar.value = value
		max_obj_speed = value
var obj_speed_step:float = 1

##gui references
@onready var gui_obj_speed_bar: ProgressBar = $GUI/obj_speed_bar
@onready var gui_obj_speed_text: RichTextLabel = $GUI/obj_speed_text
@onready var gui_cooldown: Timer = $GUI/gui_cooldown
@onready var interact_tip_text: Label = $GUI/interact_tip_text



##camera references
@onready var camera_pivot: Node3D = $camera_pivot
@onready var spring_arm: SpringArm3D = $camera_pivot/spring_arm_3d
@onready var spring_position: Node3D = $camera_pivot/spring_arm_3d/spring_position
@onready var camera: Camera3D = $camera_pivot/spring_arm_3d/camera
@onready var flashlight: SpotLight3D = $flashlight
@onready var ray_interaction: RayCast3D = $camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand: Marker3D = $camera_pivot/spring_arm_3d/camera/hand
@onready var grab_buffer_timer: Timer = $camera_pivot/spring_arm_3d/camera/grab_buffer_timer
@onready var grab_buffer_display: TextureProgressBar = $GUI/buffer_timer_display
@onready var rotate_to_player_joint = $camera_pivot/spring_arm_3d/camera/rotate_to_player_joint
@onready var static_body: StaticBody3D = $camera_pivot/spring_arm_3d/camera/StaticBody3D


var spring_arm_length = min_zoom_in
var flashlight_toggle:bool = false:
	set(value):
		flashlight_toggle = value
		flashlight.visible = flashlight_toggle
		
var camera_locked_in = false
var carrying = null #object itself
var hovered_obj = null
var holding = false
var current_rotation: Vector3



func _ready() -> void:
	Signalbus.grab_buffer_expired.connect(_grab_buffer_expired)
	Signalbus.grab_buffer_cooldown_updated.connect(_grab_buffer_updated)
	Signalbus.gui_cooldown.connect(_gui_cooldown)
	Signalbus.player_speed_updated.connect(_player_speed_updated)
	Signalbus.player_jump_updated.connect(_player_jump_updated)
	#Signalbus.grab_buffer_expired.connect(_on_grab_buffer_timer_timeout)
	
	gui_obj_speed_bar.value = max_obj_speed
	
	_grab_buffer_expired() #reset values
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	spring_arm.spring_length = -1


func _physics_process(delta: float) -> void:
	check_hover()
	player_grabbing(delta)
	player_movement(delta)
	
	if holding == true:
		pick_up_object()
		interact_tip_text.visible = false
		
	if holding == false:
		drop_object()
		obj_speed_gui_visible(false)
		grab_buffer_display.hide()
		rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
		holding = null #so we dont keep running these ^^^ 
	
func player_grabbing(delta: float):
	if carrying:
		grab_buffer_display.value = grab_buffer_timer.time_left
		var a = carrying.global_transform.origin
		var b = player_hand.global_transform.origin
		var direction = (b - a)
		var distance = (b - a).length()
		var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
		carrying.linear_velocity = direction * movement_speed

func player_movement(delta: float):
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

func _process(delta: float) -> void:
	camera.fov = Settings.fov
	#Signalbus.grab_buffer_cooldown_updated.connect(_grab_buffer_updated)

func _input(event: InputEvent) -> void:
	
	#perspective toggle
	if event.is_action_pressed("r"):
		perspective_toggle()
		
	#flashlight toggle
	if event.is_action_pressed("f"):
		if flashlight_toggle:
			flashlight_toggle = false
		else:
			flashlight_toggle = true
			
	#handle mouse motion rotations such as camera & flashlight
	if !camera_locked_in:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			
			camera_pivot.rotation.y -= event.relative.x * Settings.sensitivity/10000.0
			camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)
			
			camera_pivot.rotation.x -= event.relative.y * Settings.sensitivity/10000.0
			# -PI/2 = min vertical angle, PI/4 = max vertical angle
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/1.75)
			
			flashlight.rotation = camera_pivot.rotation
			#flashlight.rotation.x = camera_pivot.rotation.x
	else:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body.rotate_y(deg_to_rad(event.relative.x * rotation_power))
	
	## TODO
	#control grip, maybe refine this later
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
		
	if event.is_action_pressed("control_grip_in"):
		gui_cooldown.start()
		gui_obj_speed_text.visible = true
		gui_obj_speed_bar.visible = true
		max_obj_speed += obj_speed_step
		
	if event.is_action_pressed("control_grip_out"):
		gui_cooldown.start()
		gui_obj_speed_text.visible = true
		gui_obj_speed_bar.visible = true
		max_obj_speed -= obj_speed_step

	#handle obj rotation
	if event.is_action_pressed("rmb"):
		if carrying:
			camera_locked_in = true
		#if carrying:
			#rotate_obj(event)

	if event.is_action_released("rmb"):
		camera_locked_in = false

	#handle obj movement
	if event.is_action_pressed("interact"):
		if hovered_obj != null and hovered_obj.is_in_group("grabbable"):
			if !holding:
				holding = true
			else:
				holding = false

func check_hover():
	if carrying:
		toggle_outline(carrying, true)
		#if not hovering over carryable, start timer
		if ray_interaction.is_colliding():
			var obj = ray_interaction.get_collider()
			if obj.is_in_group("grabbable"):
				grab_buffer_timer.start()
	else:
		if ray_interaction.is_colliding():
			var obj = ray_interaction.get_collider()
			if obj:
				if obj.is_in_group("grabbable"):
					interact_tip_text.visible = true
					if obj != hovered_obj:
						#for previously hovered object
						if hovered_obj:
							toggle_outline(hovered_obj, false)
						#for the new hovered object
						hovered_obj = obj
						toggle_outline(hovered_obj, true)
			else:
				interact_tip_text.visible = false
				#turn off outline if not hovering over grabbable object
				if hovered_obj:
					toggle_outline(hovered_obj, false)
					hovered_obj = null
		else:
			#turn off outline if raycast is not colliding
			if hovered_obj:
				toggle_outline(hovered_obj, false)
				hovered_obj = null

func pick_up_object():
	if carrying:
			return
	if ray_interaction.is_colliding():
		var obj = ray_interaction.get_collider()
		if obj.is_in_group("grabbable"):
			carrying = obj
			rotate_to_player_joint.set_node_b(obj.get_path())
			start_buffer_timer()
			obj_speed_gui_visible(true)
			toggle_outline(carrying, true)
			if hovered_obj and hovered_obj != carrying:
				rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
				toggle_outline(hovered_obj, false)
				hovered_obj = null

func drop_object():
	carrying = null
	holding = false
	if carrying:
		toggle_outline(carrying, false)

func perspective_toggle():
	if spring_arm.spring_length <= 1:
		perspective = "first"
		spring_arm_length = 3
	match perspective:
		"first":
			current_rotation = camera_pivot.rotation
			#camera_pivot.rotation = -current_rotation
			if spring_arm.spring_length >= 1:
				camera_pivot.rotation.y = rad_to_deg(180)
				perspective = "third"
				return
			spring_arm.spring_length = spring_arm_length
			camera_pivot.rotation = current_rotation
			perspective = "second"
			##TODO : controls need to be inverted ?
		"second":
			spring_arm.spring_length = spring_arm_length
			camera_pivot.rotation = -current_rotation
			camera_pivot.rotation.y = rad_to_deg(-180)
			perspective = "third"
		"third":
			camera_pivot.rotation = current_rotation
			spring_arm.spring_length = -1
			perspective = "first"
	


func obj_speed_gui_visible(valueBool):
	gui_obj_speed_text.visible = valueBool
	gui_obj_speed_bar.visible = valueBool
	grab_buffer_display.visible = valueBool

var timer_played_once = false
func start_buffer_timer():
	if timer_played_once == false:
		grab_buffer_timer.start()
	timer_played_once = true

func _grab_buffer_updated(is_default, value):
	grab_buffer_timer.set_wait_time(value)
	grab_buffer_display.max_value = value

func _grab_buffer_expired():
	timer_played_once = false #reset timer
	drop_object()
	obj_speed_gui_visible(false)
	grab_buffer_display.hide()

func _gui_cooldown():
	gui_obj_speed_text.visible = false
	gui_obj_speed_bar.visible = false

func toggle_outline(obj, toggle: bool):
	if obj:
		var mesh
		for child in obj.get_children():
			#looks very specifically for any "mesh" children nodes
			if str(child.name.to_lower()).find("mesh") != -1:
				mesh = child
		if mesh:
			var outline = mesh.get_node("./outline")
			if outline:
				outline.visible = toggle

func _on_grab_buffer_timer_timeout() -> void:
	Signalbus.grab_buffer_expired.emit()

func _on_gui_cooldown_timeout() -> void:
	Signalbus.gui_cooldown.emit()

func _player_speed_updated(is_default, value):
	speed = value

func _player_jump_updated(is_default, value):
	jump_velocity = value
