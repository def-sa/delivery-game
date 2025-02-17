extends Node3D

@onready var ray_interaction = $Player/camera_pivot/spring_arm_3d/camera/ray_interaction
@onready var player_hand = $Player/camera_pivot/spring_arm_3d/camera/hand
@onready var gui_obj_speed_bar = $Player/GUI/obj_speed_bar
@onready var gui_obj_speed_text = $Player/GUI/obj_speed_text
@onready var grab_buffer_timer = $Player/camera_pivot/spring_arm_3d/camera/grab_buffer_timer
@onready var grab_buffer_display = $Player/GUI/buffer_timer_display
#@onready var grab_buffer_slider = $"pause_menu/MarginContainer/AspectRatioContainer/TabContainer/gameplay/VBoxContainer2/Grab Buffer Cooldown/grab_buffer_slider"

var last_obj_hovered: RigidBody3D
var last_grabbed_object: RigidBody3D
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
	_grab_buffer_expired() #reset values
	
	
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
	holding_object = true
	_obj_speed_gui_visible(true)
	grab_buffer_display.show()
	if last_grabbed_object:
		if last_grabbed_object.is_in_group("grabbable"):
			_toggle_outline(last_grabbed_object, true)

func _handle_lmb_released():
	holding_object = false
	_obj_speed_gui_visible(false)
	grab_buffer_display.hide()
	if last_grabbed_object:
		if last_grabbed_object.is_in_group("grabbable"):
			_toggle_outline(last_grabbed_object, false)


# TODO: learn what the hell a state machine is and use it for this 
# BUG: prefer last object held if interacting with new obj, so dragging over multiple isnt impossible
func _process(delta: float) -> void:
	
	var ray_object = ray_find_obj()
	
	#hovering over valid target
	if ray_object != null:
		last_obj_hovered = ray_object
		if ray_object == last_grabbed_object:
			pass
		else:
			#check if hovering over another grabbable object
			if ray_object.is_in_group("grabbable"):
				ray_object = last_grabbed_object
				_handle_grabbable_object(last_obj_hovered)
				_toggle_outline(last_obj_hovered, true)
				_obj_speed_gui_visible(true)
				grab_buffer_display.show()
						
			#if so, dont set outline on that object, and instead keep focus on previous object
			#if not, handle hovering normally. set outline, gui ect
		_on_hovering_valid_object(ray_object)
	#ray_object is null
	else:
		pass
		#_on_hovering()
	_handle_grab_buffer_display()
	_handle_grabbing()


func _on_hovering():
	if last_grabbed_object:
		_toggle_outline(last_grabbed_object, false)
		#not hovering but still holding, activate 2 second buffer
		if last_grabbed_object:
			start_buffer_timer()
			_toggle_outline(last_grabbed_object, true)
			_obj_speed_gui_visible(true)
		else:
			_toggle_outline(last_grabbed_object, false)
			_obj_speed_gui_visible(false)
			grab_buffer_display.hide()
	last_grabbed_object = null

# remove this 
func _on_hovering_valid_object(ray_object):
	#if grabbable, show outline
	if last_obj_hovered.is_in_group("grabbable"):
		last_grabbed_object = last_obj_hovered
		#if new grabbable object hovered

		if last_grabbed_object == last_obj_hovered:
			pass
		else:
			print("last grabbed isnt last obj hovered")
		
		_handle_grabbable_object(last_obj_hovered)
	#obj not grabbable, hide gui elements and reset outline
	else:
		_toggle_outline(last_obj_hovered, false)
		_obj_speed_gui_visible(false)
		grab_buffer_display.hide()

func _handle_grab_buffer_display():
	#make display go up in value instead of down
	var buffer_value = -(grab_buffer_timer.time_left - grab_buffer_timer.wait_time)
	grab_buffer_display.value = grab_buffer_timer.time_left

func _handle_grabbing():
	#handle grabbing
	if last_grabbed_object:
		if last_grabbed_object.is_in_group("grabbable"):
			if holding_object:
				var a = last_grabbed_object.global_transform.origin
				var b = player_hand.global_transform.origin
				var direction = (b - a).normalized()
				var distance = (b - a).length()
				
				var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
				last_grabbed_object.linear_velocity = direction * movement_speed
			#if grabbable but not holding, show outline
			else:
				_toggle_outline(last_grabbed_object, false)

func _handle_grabbable_object(obj):
	_toggle_outline(last_grabbed_object, true)
	#if holding obj, show gui elements and reset buffer timer
	if holding_object: #updates on lmb toggle
		_obj_speed_gui_visible(true)
		grab_buffer_display.show()
		#reset timer jank ass method (?)
		grab_buffer_timer.start()


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



func _toggle_outline(obj, toggle_bool):
	if obj:
		if obj.is_in_group("grabbable"):
			var outline_node = obj.get_node("./Mesh/Outline")
			if outline_node:
				outline_node.visible = toggle_bool
			else:
				print(outline_node.name, " not found")
		else:
			print(obj.name, " not grabable")


func _grab_buffer_updated(is_default, value):
	grab_buffer_timer.set_wait_time(value)
	grab_buffer_display.max_value = value

func _grab_buffer_expired():
	timer_played_once = false #reset timer
	holding_object = false
	_obj_speed_gui_visible(false)
	last_grabbed_object = null
	grab_buffer_display.hide()
	if last_grabbed_object:
		_toggle_outline(last_grabbed_object, false)



#__________________

#
#
#func _toggle_active_object(obj, toggle:bool):
	#if toggle == true:
		#grab_buffer_display.show()
		##reset timer jank ass method (?)
		#grab_buffer_timer.start()
	#elif toggle == false:
		#grab_buffer_display.hide()
	#holding_object = toggle
	#_toggle_outline(obj, toggle)
	#_obj_speed_gui_visible(toggle)
	#

## BUG: prefer last object held if interacting with new obj, so dragging over multiple isnt impossible
#func _process(delta: float) -> void:
	#
	#var ray_object = ray_find_obj()
	#
	##hovering over valid target
	#if ray_object != null:
		#
		#if last_obj_hovered == null:
			#last_obj_hovered = ray_object
			#
		#if ray_object.is_in_group("grabbable"):
			#last_grabbed_object = ray_object
			#
		##if new hovered obj is last obj grabbed
		#if ray_object == last_grabbed_object:
			#if holding_object:
				#print("new obj is last grabbed obj")
				#_toggle_active_object(last_grabbed_object, true)
				#_handle_grabbing_for_obj(last_grabbed_object)
				#
				#_toggle_active_object(last_obj_hovered, false)
		#else:
			#if holding_object:
				#print("new obj is NOT last grabbed obj")
				#_toggle_active_object(last_obj_hovered, true)
				#_handle_grabbing_for_obj(last_obj_hovered)
				#
				#_toggle_active_object(last_grabbed_object, false)
				#
		#last_obj_hovered = ray_object
		#
		#
		#
		#
		##if ray_object == last_grabbed_object:
			##
			##pass
		##else:
			##pass
			##check if hovering over another grabbable object
			##if ray_object.is_in_group("grabbable"):
				##last_grabbed_object = ray_object
				##_handle_grabbable_object(last_obj_hovered)
				##_toggle_outline(last_obj_hovered, true)
				##_obj_speed_gui_visible(true)
				##grab_buffer_display.show()
						#
			##if so, dont set outline on that object, and instead keep focus on previous object
			##if not, handle hovering normally. set outline, gui ect
		##_on_hovering_valid_object(ray_object)
	##ray_object is null
	##else:
		##pass
		#_on_hovering()
	##_handle_grab_buffer_display()
	##_handle_grabbing()
