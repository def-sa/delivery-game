extends Node3D

@onready var ray_interaction = $Player/camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand = $Player/camera_pivot/spring_arm_3d/camera/hand
@onready var gui_speed_bar = $Player/GUI/speed_bar
@onready var grab_buffer_timer = $Player/camera_pivot/spring_arm_3d/camera/grab_buffer_timer

var last_obj_hovered: RigidBody3D
var holding_object:bool = false
var pull_power = 10
var max_obj_speed = 4

func _ready() -> void:
	gui_speed_bar.value = max_obj_speed
	Signalbus.grab_buffer_expired.connect(_grab_buffer_expired)

func _process(delta: float) -> void:
	#handle object outline & holding objects
	var object = ray_find_obj()
	print(grab_buffer_timer.time_left)
	
	#hovering
	if object != null:
		object.outline_visible = true
		last_obj_hovered = object
		
		if holding_object:
			#reset timer jank ass method (?)
			grab_buffer_timer.start()
		#if hovering and holding
	#not hovering
	else:
		#holding but not hovering, wait 2 seconds
		if holding_object:
			start_buffer_timer()
		if last_obj_hovered:
			last_obj_hovered.outline_visible = false
			
	if last_obj_hovered:
		if holding_object:
			var a = last_obj_hovered.global_transform.origin
			var b = player_hand.global_transform.origin
			var direction = (b - a).normalized()
			var distance = (b - a).length()
			
			var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
			last_obj_hovered.linear_velocity = direction * movement_speed

var timer_played_once = false
func start_buffer_timer():
	if timer_played_once == false:
		grab_buffer_timer.start()
	timer_played_once = true



#raycast that returns whatever RigidBody3d it collides with
func ray_find_obj():
	var collider = ray_interaction.get_collider()
	if collider and collider is RigidBody3D:
		return collider

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
			holding_object = true
			if last_obj_hovered:
				last_obj_hovered.outline_visible = true
			
	if event.is_action_released("lmb"):
		holding_object = false
		if last_obj_hovered:
			last_obj_hovered.outline_visible = false
	
	if event.is_action_pressed("control_grip_in"):
		max_obj_speed += 1
		gui_speed_bar.value = max_obj_speed
	if event.is_action_pressed("control_grip_out"):
		max_obj_speed -= 1
		gui_speed_bar.value = max_obj_speed

func _grab_buffer_expired():
	timer_played_once = false #reset timer
	
	if holding_object == true:
		holding_object = false
	if last_obj_hovered:
		last_obj_hovered.outline_visible = false
