extends Node3D

@onready var ray_interaction = $Player/camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand = $Player/camera_pivot/spring_arm_3d/camera/hand
@onready var gui_obj_speed_bar = $Player/GUI/obj_speed_bar
@onready var gui_obj_speed_text = $Player/GUI/obj_speed_text
@onready var grab_buffer_timer = $Player/camera_pivot/spring_arm_3d/camera/grab_buffer_timer
@onready var grab_buffer_display = $Player/GUI/buffer_timer_display
@onready var gui_cooldown = $Player/GUI/gui_cooldown

var pull_power:float = 10.0
var max_obj_speed:float = 10.0:
	set(value):
		value = clamp(value, 4.0, 25.0)
		gui_obj_speed_bar.value = value
		max_obj_speed = value
var obj_speed_step:float = 1
var carrying = null
var hovered_obj = null

func _ready():
	Signalbus.grab_buffer_expired.connect(_grab_buffer_expired)
	Signalbus.grab_buffer_cooldown_updated.connect(_grab_buffer_updated)
	Signalbus.gui_cooldown.connect(_gui_cooldown)
	gui_obj_speed_bar.value = max_obj_speed
	_grab_buffer_expired() #reset values
	
func _physics_process(delta):
	if carrying:
		grab_buffer_display.value = grab_buffer_timer.time_left
		var a = carrying.global_transform.origin
		var b = player_hand.global_transform.origin
		var direction = (b - a)
		var distance = (b - a).length()
		#prints(direction, distance)
		var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
		carrying.linear_velocity = direction * movement_speed
	check_hover()

func _unhandled_input(event: InputEvent) -> void:
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
		
	if event.is_action_pressed("lmb"):
		if not carrying:
			pick_up_object()
			
	elif event.is_action_released("lmb"):
		if carrying:
			drop_object()
			obj_speed_gui_visible(false)
			grab_buffer_display.hide()

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
			if obj.is_in_group("grabbable"):
				if obj != hovered_obj:
					#for previously hovered object
					if hovered_obj:
						toggle_outline(hovered_obj, false)
					#for the new hovered object
					hovered_obj = obj
					toggle_outline(hovered_obj, true)
					
			else:
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
	if ray_interaction.is_colliding():
		var obj = ray_interaction.get_collider()
		if obj.is_in_group("grabbable"):
			carrying = obj
			start_buffer_timer()
			obj_speed_gui_visible(true)
			toggle_outline(carrying, true)
			if hovered_obj and hovered_obj != carrying:
				toggle_outline(hovered_obj, false)
				hovered_obj = null

func drop_object():
	carrying = null
	if carrying:
		toggle_outline(carrying, false)

func toggle_outline(obj, toggle: bool):
	if obj:
		var outline = obj.get_node("Mesh/Outline")
		if outline:
			outline.visible = toggle

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
