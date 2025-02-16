extends Node3D

@onready var ray_interaction = $Player/camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand = $Player/camera_pivot/spring_arm_3d/camera/hand
@onready var gui_obj_speed_bar = $Player/GUI/obj_speed_bar
@onready var gui_obj_speed_text = $Player/GUI/obj_speed_text
@onready var grab_buffer_timer = $Player/camera_pivot/spring_arm_3d/camera/grab_buffer_timer
@onready var grab_buffer_display = $Player/GUI/buffer_timer_display
#@onready var grab_buffer_slider = $"pause_menu/MarginContainer/AspectRatioContainer/TabContainer/gameplay/VBoxContainer2/Grab Buffer Cooldown/grab_buffer_slider"

var last_obj_hovered: RigidBody3D
var holding_object:bool = false
var raycast_found_obj:bool = false
var pull_power:float = 10.0
var obj_speed_step:float = 1
var max_obj_speed:float = 10.0:
	set(value):
		value = clamp(value, 4.0, 25.0)
		gui_obj_speed_bar.value = value
		max_obj_speed = value
		

# TODO: refactor to input manager
func _ready() -> void:
	Signalbus.grab_buffer_expired.connect(_grab_buffer_expired)
	Signalbus.grab_buffer_cooldown_updated.connect(_grab_buffer_updated)
	#grab_buffer_slider.value_changed.connect(_on_grab_buffer_slider_value_changed)
	gui_obj_speed_bar.value = max_obj_speed

# BUG: prefer last object held if interacting with new obj, so dragging over multiple isnt impossible
# BUG: create component for each obj that is grabbable instead of using object.outline_visible
func _process(delta: float) -> void:
	if holding_object:
		#make display go up in value instead of down
		var buffer_value = -(grab_buffer_timer.time_left - grab_buffer_timer.wait_time)
		grab_buffer_display.value = buffer_value
		
	elif holding_object == false:
		grab_buffer_display.value = 0
	
		
	#handle object outline & holding objects
	var object = ray_find_obj()
	#print(grab_buffer_timer.time_left)
	#hovering
	if object != null:
		raycast_found_obj = true
		last_obj_hovered = object
		if holding_object:
			object.outline_visible = true
			#reset timer jank ass method (?)
			grab_buffer_timer.start()
			grab_buffer_display.value = 0
	#not hovering
	else:
		raycast_found_obj = false
		#holding but not hovering, activate 2 second buffer
		if holding_object:
			start_buffer_timer()
			last_obj_hovered.outline_visible = false
			_obj_speed_gui_visible(true)
		else:
			_obj_speed_gui_visible(false)
	
	#handle grabbing
	if last_obj_hovered:
		if holding_object:
			var a = last_obj_hovered.global_transform.origin
			var b = player_hand.global_transform.origin
			var direction = (b - a).normalized()
			var distance = (b - a).length()
			
			var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
			last_obj_hovered.linear_velocity = direction * movement_speed

func _obj_speed_gui_visible(valueBool):
	gui_obj_speed_text.visible = valueBool
	gui_obj_speed_bar.visible = valueBool
	grab_buffer_display.visible = valueBool

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
		_handle_lmb_pressed()
	if event.is_action_released("lmb"):
		_handle_lmb_released()
	if event.is_action_pressed("control_grip_in"):
		max_obj_speed += obj_speed_step
	if event.is_action_pressed("control_grip_out"):
		max_obj_speed -= obj_speed_step

func _handle_lmb_pressed():
	#grab_buffer_timer.paused = false
	if raycast_found_obj == true:
		holding_object = true
		if grab_buffer_timer.time_left > 0:
			if last_obj_hovered:
				last_obj_hovered.outline_visible = true

func _handle_lmb_released():
	#grab_buffer_timer.paused = true
	holding_object = false
	if last_obj_hovered:
		last_obj_hovered.outline_visible = false


func _grab_buffer_updated(is_default, value):
	grab_buffer_timer.set_wait_time(value)
	grab_buffer_display.max_value = value

func _grab_buffer_expired():
	timer_played_once = false #reset timer
	
	if holding_object == true:
		holding_object = false
	#if last_obj_hovered:
		#last_obj_hovered.outline_visible = false
