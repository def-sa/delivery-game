extends CharacterBody3D


##meta
@onready var mesh: MeshInstance3D = $player_mesh
@onready var collision: CollisionShape3D = $player_collision

##gui
@onready var text_edit: TextEdit = $"../../ui/text_box/chat_container/text_edit"

@onready var right_hand: StaticBody3D = $"../../ui/3d_gui/right_hand"



@onready var left_hand: StaticBody3D = $"../../ui/3d_gui/left_hand"
@onready var helmet: StaticBody3D = $"../../ui/3d_gui/helmet"
@onready var ui: Control = $"../../ui"


##grabbing 
@onready var hand_raycast: RayCast3D = $hand_raycast
@onready var path_3d: Path3D = $hand_raycast/path_3d
@onready var path_follow: PathFollow3D = $hand_raycast/path_3d/path_follow
@onready var hand: Marker3D = $hand_raycast/path_3d/hand

##scanning
@onready var scan_speed_timer: Timer = $timers/scan_speed_timer
@onready var area_3d: Area3D = $area_3d

##extra
@onready var player_animation: AnimationPlayer = $"../../ui/player_animation"

@onready var camera: Camera3D = $"../../ui/3d_gui/camera"

@onready var flashlight: SpotLight3D = $flashlight

##player variables
@export var jump_velocity:float = 4
@export var speed:float = 5
@export var height:float = 2 # in meters

#region states
enum PLAYER_STATES {
		IDLE,
		WALKING,
		SPRINTING,
		JUMPING,
		CROUCHING,
		CLIMBING,
		TYPING
}
@onready var player_state:int:
	set(v):
		if v == player_state: return 
		print("player state: ", str(PLAYER_STATES.keys()[v]))
		_set_player_state(player_state, v)
		player_state = v
		
@onready var mouse: TextureRect = $"../../ui/mouse"


#enum MOUSE_STATES {
	#FREE_LOOK,
	#POINT
#}
#@onready var mouse_state:
	#set(v):
		#if v == mouse_state: return
		#_set_mouse_state(mouse_state, v)
		#mouse_state = v
#endregion

##camera
var yaw = 0.0
var pitch = 0.0
var locked_camera:bool = false

##grabbing
var held_object:
	set(v):
		var held: bool
		var current_obj
		if held_object and not v:
			held = false
			current_obj = held_object
		if v and not held_object:
			held = true
			current_obj = v
		held_object = v
		
		#if not current_obj: return
		if not current_obj is physics_item: return
		current_obj.is_being_held = held


#var object_rotation: Vector3 = Vector3.ZERO
var object_drag:float = 0.25
var max_object_speed:float = 10.0:
	set(v):
		v = clamp(v, 4.0, 100.0)
		max_obj_speed = v
var max_obj_speed = 20

var hand_scroll:float = 0.35:
	set(v):
		hand_scroll = clamp(v, 0.15, 1)
var rotation_power = 0.5

var max_grab_reach:float = 7.5:
	set(v):
		max_grab_reach = v
		hand_raycast.target_position.z = max_grab_reach
		path_3d.curve.set_point_position(1, Vector3(0,0,max_grab_reach))
		hand.position.z = max_grab_reach
var grab_max_speed: float = 25.0       # top speed (m/s)
var grab_acceleration: float = 2.0    # how fast we can change velocity
var grab_stopping_radius: float = 0.067  # within this distance we’ll stop

##scan
var object_and_overlay_dict = {}
var scan_speed = 2
var scan_radius # TODO


func _ready() -> void:
	#init
	player_state = PLAYER_STATES.IDLE
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
	
	if event.is_action_pressed("rmb"):
		scan_speed_timer.wait_time = scan_speed
		scan_speed_timer.start()
	
	# BUG : really stupid bug where "t" is put in chat upon first initalization
	if event.is_action_pressed("chat", false):
		player_state = PLAYER_STATES.TYPING
	
	#grabbing, interact
	if event.is_action_pressed("interact") and not held_object:
		if hand_raycast.is_colliding():
			held_object = hand_raycast.get_collider()
	if event.is_action_released("interact"):
		locked_camera = false
		_drop_object()
	
	#hand scroll
	if event.is_action_pressed("wheel_up"):
		hand_scroll += 0.1
	if event.is_action_pressed("wheel_down"):
		hand_scroll -= 0.1
	
	#lock camera when rmb and holding
	if held_object and event.is_action_pressed("rmb"):
		locked_camera = true
	if held_object and event.is_action_released("rmb"):
		locked_camera = false
	
	
	#handle camera movement on mouse motion
	if event is InputEventMouseMotion \
	and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED \
	and ui.is_mouse_pointing == false:
		
		##BUG : cant move while rotating object 
		if held_object and locked_camera:
			#create_tween().tween_property(held_object, "global_position", path_follow.global_position, 0.1)
			#create_tween().tween_property(held_object,"rotation_degrees", \
				#held_object.rotation_degrees + Vector3( \
				#-event.relative.y * rotation_power, \
				#event.relative.x * rotation_power,0),0.1)
			return
		
		yaw -= event.relative.x * Settings.mouse_senstivity / 10000.0
		pitch -= event.relative.y * Settings.mouse_senstivity / 10000.0
		
		hand_raycast.rotation.y = wrapf(yaw,0, TAU)
		hand_raycast.rotation.x = clamp(pitch, -PI/2 + 0.1 , PI/2 - 0.1)
		
		flashlight.rotation = hand_raycast.rotation
		camera.rotation = hand_raycast.rotation
		#TODO: left hand 
		right_hand.rotation = hand_raycast.rotation
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		
	_grab_object(delta)
	
	if player_state == PLAYER_STATES.TYPING: return
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		player_state = PLAYER_STATES.JUMPING
		velocity.y = jump_velocity
		move_and_slide()
		return
		
	if Input.get_vector("move_left", "move_right", "move_forward", "move_back"):
		if Input.is_action_pressed("sprint") and is_on_floor():
			player_state = PLAYER_STATES.SPRINTING
			_player_movement(delta, speed * 1.25)
			return
		if Input.is_action_pressed("crouch"):
			player_state = PLAYER_STATES.CROUCHING
			_player_movement(delta, speed * 0.75)
			return
		player_state = PLAYER_STATES.WALKING
		_player_movement(delta, speed)
		return
	else:
		player_state = PLAYER_STATES.IDLE
	
func _process(delta: float) -> void:
	
	area_3d.visible = scan_speed_timer.time_left > 0
	if scan_speed_timer.time_left > 0:
		var time_left = ((scan_speed_timer.time_left* 100) * delta) + 0.01
		area_3d.scale = Vector3(time_left,time_left,time_left)

	
func _set_player_state(current_player_state, new_player_state) -> void:
	if not current_player_state and not new_player_state: return
	
	ui.is_mouse_pointing = false
	player_animation.stop()
	#collision.shape.height = height
	create_tween().tween_property(collision.shape, "height", height, 0.25)
	
	match new_player_state:
		PLAYER_STATES.IDLE:
			#normal fov, slight sway animation
			player_animation.play("idle_bob_loop")
			create_tween().tween_property(camera, "fov", Settings.fov, 0.25)
			#camera.fov = Settings.fov
			#velocity 
			pass
		PLAYER_STATES.WALKING:
			#walking headbob, arm moving
			player_animation.play("walking_bob_loop")
			create_tween().tween_property(camera, "fov", Settings.fov * 1.015, 0.25)
			pass
		PLAYER_STATES.SPRINTING:
			#sprinting fov change, headbob
			player_animation.play("sprinting_bob_loop")
			create_tween().tween_property(camera, "fov", Settings.fov * 1.075, 0.25)
			pass
		PLAYER_STATES.JUMPING:
			create_tween().tween_property(self, "velocity", velocity/10, 0.25)
			pass
		PLAYER_STATES.CROUCHING:
			player_animation.speed_scale = .5
			player_animation.play("walking_bob_loop")
			create_tween().tween_property(collision.shape, "height", collision.shape.height / 2, 0.25)
			#collision.shape.height /= 2
		PLAYER_STATES.CLIMBING:
			pass
		PLAYER_STATES.TYPING:
			get_viewport().set_input_as_handled()
			text_edit.grab_focus()
			ui.is_mouse_pointing = true
			
			pass
	
func _player_movement(delta: float, _speed:float):
	#handle mmovement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)
	move_and_slide()
	

	
func _grab_object(delta:float):
	if not held_object: return 
	
	hand.position = path_follow.position
	path_follow.progress_ratio = hand_scroll
	#held_object.global_position = path_follow.global_position
	
	var to_target: Vector3 = hand.global_position - held_object.global_position
	#var to_distance = to_target.length()
	#if to_distance < grab_stopping_radius:
		#held_object.linear_velocity = Vector3.ZERO
		#return
	var desired_vel: Vector3 = to_target.normalized() * grab_max_speed

	var blend = clamp(grab_acceleration * delta, 0.0, 0.05)
	held_object.linear_velocity = held_object.linear_velocity.lerp(desired_vel, blend)
	
	#if locked_camera:
	#var to_cam = (camera.global_position - held_object.global_position).normalized()
	#var target_yaw = atan2(to_cam.x, to_cam.z)
	#
	#held_object.rotation_degrees = Vector3(0,rad_to_deg(target_yaw),0) # [pitch, yaw, roll]
	
	#var a = held_object.global_transform.origin
	#var b = hand.global_transform.origin
	#var direction = (b - a)
	#var distance = (b - a).length() * object_drag
	#var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
	##move player_hand inwards/outwards toward the player, using the variable hand_scroll
	#held_object.linear_velocity = direction * movement_speed
	
func _drop_object():
	held_object = null
	
func _on_text_edit_focus_entered() -> void:
	player_state = PLAYER_STATES.TYPING
	
func _on_text_edit_focus_exited() -> void:
	player_state = PLAYER_STATES.IDLE


























#
###region // references
####gui references
##@onready var grab_buffer_display: ProgressBar = $gui/crosshair_grabbing/ProgressBar
##@onready var health_bar: ProgressBar = $gui/health_bar
##@onready var box_open_bar: ProgressBar = $gui/MarginContainer/box_open_bar
##
####timers
##@onready var grab_buffer_timer: Timer = $grab_buffer_timer
##@onready var box_open_timer: Timer = $box_open_timer
##
####item overlay
##@onready var item_overlay: Control = $gui/item_overlay
##@onready var item_detection_gui: Control = $gui/item_detection
##
####camera references
##@onready var camera_pivot: Node3D = $camera_pivot
##@onready var spring_arm: SpringArm3D = $camera_pivot/spring_arm_3d
##@onready var spring_position: Node3D = $camera_pivot/spring_arm_3d/spring_position
##@onready var camera: Camera3D = $camera_pivot/spring_arm_3d/camera
##@onready var flashlight: SpotLight3D = $flashlight
##@onready var far_scan_light: SpotLight3D = $far_scan_light
##@onready var short_scan_light: OmniLight3D = $short_scan_light
##
##@onready var ray_interaction: RayCast3D = $camera_pivot/spring_arm_3d/camera/ray_interaction
##@onready var player_hand: Marker3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D/hand
##@onready var path_3d: Path3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D
##@onready var path_follow_3d: PathFollow3D = $camera_pivot/spring_arm_3d/camera/ray_interaction/Path3D/PathFollow3D
##@onready var rotate_to_player_joint = $camera_pivot/spring_arm_3d/camera/rotate_to_player_joint
##@onready var static_body: StaticBody3D = $camera_pivot/spring_arm_3d/camera/StaticBody3D
##
##@onready var no_fly_ray: RayCast3D = $no_fly_ray
##
##@onready var player_mesh: MeshInstance3D = $player_mesh
##
##
##@onready var dialogue: RichTextLabel = $"../../pause_gui/dialogue"
##
##
##@onready var pause_menu: Control = $"../../pause_gui/pause_menu"
##
##
##
###endregion
##
##@export_category("Player variables")
##
####player variables
##@export var speed:int = Settings.player_speed
##@export var jump_velocity:float = Settings.player_jump
##@export var health:int = 100:
	##set(v):
		##health = v
		##health_bar.value = health
		##if v <= 0:
			##player_dead()
##
##
####camera variables
##var min_zoom_in: int = 0 #default spring length
##var max_zoom_out: int = 30
##var perspective = "first" #default is "first"
##var spring_arm_length = min_zoom_in
##var camera_locked_in = false
##var spin_locked: bool = false
##
##var flashlight_toggle:bool = false:
	##set(v):
		##flashlight_toggle = v
		##flashlight.visible = flashlight_toggle
##
#### grabbing variables 
##var rotation_power = 0.05
##var pull_power:float = 10.0
###TODO : remake this to be static, and use a different way to increase player "grip"
##var max_obj_speed:float = 10.0:
	##set(value):
		##value = clamp(value, 4.0, 25.0)
		##max_obj_speed = value
##var obj_speed_step:float = 1
##var object_drag = 0.1
##var max_reach = 5.5
##var hand_scroll = .35:
	##set(v):
		##hand_scroll = clamp(v, 0.15, 1)
##
##var carrying_obj = null: #object itself
	##set(v):
		##carrying_obj = v
		##grab_buffer_display.visible = carrying_obj != null
		##if carrying_obj:
			##carrying_obj.can_sleep = !carrying_obj
			##_pick_up_object()
		##else:
			##rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
##
##
##var hovered_obj = null:
	##set(v):
		##hovered_obj = v
		##if hovered_obj:
			##if hovered_obj == carrying_obj:
				##item_overlay.set_to(carrying_obj, "holding")
			##else:
				##if hovered_obj.is_in_group("grabbable"):
					##item_overlay.set_to(hovered_obj, "hovering")
		##elif !carrying_obj:
			##item_overlay.set_to(null, "off")
##
##
##
##var clicked_obj = null
##
####perspective toggle vars
##var current_camera_rotation: Vector3
##var holding_perspective_toggle = false:
	##set(v):
		##holding_perspective_toggle = v
		##if holding_perspective_toggle == true:
			##_perspective_toggle()
#
#
#func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#
	##Signalbus.grab_buffer_expired.connect(_grab_buffer_expired)
	##Signalbus.grab_buffer_updated.connect(_grab_buffer_updated)
	##Signalbus.player_speed_updated.connect(_player_speed_updated)
	##Signalbus.player_jump_updated.connect(_player_jump_updated)
	##Signalbus.fov_updated.connect(_fov_updated)
	##Signalbus.max_grab_length_updated.connect(_max_grab_length_updated)
	##Signalbus.box_open_timer_updated.connect(_box_open_timer_updated)
	##Signalbus.box_open_timer_expired.connect(_box_open_timer_expired)
	#
	#
	#_box_open_timer_updated(Settings.box_open_timer_default)
	#_grab_buffer_updated(Settings.grab_buffer_default)
	#
	##TODO: add settings file load/save
	#camera.fov = Settings.fov_default
	#
	#path_follow_3d.progress_ratio = hand_scroll
	#path_3d.curve.set_point_position(1, Vector3(path_3d.curve.get_point_position(1).x,path_3d.curve.get_point_position(1).y,-max_reach)) 
	#
	##pause_menu.pause(true, false)
	##dialogue.set_speech_text("[wave amp=50.0 freq=5.0 connected=1]waaaaaaoooowwww[/wave]")
	#
#
#
##region // private functions 
#func _physics_process(delta: float) -> void:
	#hovered_obj = _ray_intersect_obj()
	#
	#_player_movement(delta)
	#_player_grabbing()
	#
	##turn off ray interaction if not in first person mode
	#ray_interaction.enabled = bool(perspective == "first")
	#player_mesh.visible = !bool(perspective == "first")
	##player_mesh.look_at(player_hand.global_position)
	#
	##handle click ray if mouse visible
	#if Input.is_action_pressed("tab"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#clicked_obj = _shoot_click_ray()
	#else:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#
	##BUG: 
	##this "works", but you can still get insane height using corners
	#if no_fly_ray.get_collider() == carrying_obj:
		#drop_object()
#func _input(event: InputEvent) -> void:
	#
	###TODO: rope :)
	#if event.is_action_pressed("toggle_rope"):
		#carrying_obj.get_parent().is_on_rope = true
	#
	#if event.is_action_pressed("sprint"):
		#Settings.player_speed *= 1.5
		#Settings.fov *= 1.05
	#
	#if event.is_action_released("sprint"):
		#Settings.player_speed /= 1.5 
		#Settings.fov /= 1.05
	#
	##hand scroll
	#if event.is_action_pressed("wheel_up"):
		#hand_scroll += 0.1
	#if event.is_action_pressed("wheel_down"):
		#hand_scroll -= 0.1
	#
	##perspective toggle
	#if event.is_action_pressed("r"):
		#holding_perspective_toggle = true
	#if event.is_action_released("r"):
		#holding_perspective_toggle = false
	#
	 ## hold r + zoom to zoom camera
	##NOTE: probably will change this keybind later
	#if holding_perspective_toggle:
		#if spring_arm.spring_length <= .5:
			#perspective = "first"
		#if event.is_action_pressed("wheel_up"):
			#if spring_arm.spring_length >= min_zoom_in:
				#spring_arm.spring_length -= 1
		#if event.is_action_pressed("wheel_down"):
			#if spring_arm.spring_length <= max_zoom_out:
				#spring_arm.spring_length += 1
		#spring_arm_length = spring_arm.spring_length
	#
	##camera zoom
	#_zoom(bool(event.is_action_pressed("zoom")))
	#
	##flashlight toggle
	#if event.is_action_pressed("f"):
		#flashlight_toggle = !flashlight_toggle
	#
	##open box OR click obj if in mouse visible mode
	#if event.is_action_pressed("lmb"):
		#if carrying_obj and carrying_obj.is_in_group("openable"):
			#box_open_bar.show()
			#box_open_timer.start()
	#if event.is_action_released("lmb"):
		#box_open_timer.stop()
		#box_open_bar.hide()
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			#if clicked_obj and clicked_obj.is_in_group("grabbable"):
				#item_overlay.set_to(clicked_obj, "hovering")
			#
	##handle mouse motion rotations such as camera & flashlight
	#spin_locked = !camera_locked_in
	#if !camera_locked_in: #camera unlocked
		#if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#camera_pivot.rotation.y -= event.relative.x * Settings.sensitivity/10000.0
			#camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)
			#camera_pivot.rotation.x -= event.relative.y * Settings.sensitivity/10000.0
			## -PI/2 = min vertical angle, PI/4 = max vertical angle
			#camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/1.75)
			#flashlight.rotation = camera_pivot.rotation
			#far_scan_light.rotation = camera_pivot.rotation
			#
	#else: #camera locked
		#if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			#static_body.rotate_y(deg_to_rad(event.relative.x * rotation_power))
	#
	##handle obj rotation
	#if event.is_action_pressed("rmb"):
		#if carrying_obj:
			#camera_locked_in = true
	#if event.is_action_released("rmb"):
		#camera_locked_in = false
	#
	##handle obj movement
	#if event.is_action_pressed("interact"):
		#if !carrying_obj:
			#_pick_up_object()
		#else:
			#drop_object()
		#
		#var obj = _ray_intersect_obj()
		#if obj and obj.is_in_group("interactable"):
			#Signalbus.is_interact_pressed.emit(obj)
			#return
		##holding = !holding
#
#
#func _player_grabbing():
	##timer pauses instead of refreshing when not hovering. makes holding harder, might get removed/reworked
	#grab_buffer_timer.paused = (carrying_obj == hovered_obj)
	#if carrying_obj:
		#
		###TODO: items with a certain momentum should do damage to enemies
		##var obj_mass = carrying_obj.mass
		##var obj_velocity = carrying_obj.linear_velocity
		##var obj_momentum = obj_mass * obj_velocity
		###print(obj_momentum)
		##if obj_momentum.x >= 40 or obj_momentum.y >= 40 or obj_momentum.z >= 40:
			##const hurt_area_scene = preload("res://scenes/world/hurt_area.tscn")
			##var hurt_area = hurt_area_scene.instantiate()
			##hurt_area.position = carrying_obj.position
			##carrying_obj.add_child(hurt_area)
		#grab_buffer_display.value = grab_buffer_timer.time_left
		#box_open_bar.value = box_open_timer.time_left
		#var a = carrying_obj.global_transform.origin
		#var b = player_hand.global_transform.origin
		#var direction = (b - a)
		#var distance = (b - a).length() * object_drag
		#var movement_speed = clamp(distance * pull_power, 0, max_obj_speed)
		##move player_hand inwards/outwards toward the player, using the variable hand_scroll
		#path_follow_3d.progress_ratio = hand_scroll
		#carrying_obj.linear_velocity = direction * movement_speed
#func _player_movement(delta: float):
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = jump_velocity
	##handle mmovement
	#var input_dir := Input.get_vector("left", "right", "forward", "back")
	#var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	#direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	#if direction:
		#velocity.x = direction.x * speed
		#velocity.z = direction.z * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)
	#move_and_slide()
#func _shoot_click_ray():
	#var mouse_pos = get_viewport().get_mouse_position()
	#var ray_origin = camera.project_ray_origin(mouse_pos)
	#var ray_direction = camera.project_ray_normal(mouse_pos)
	#var ray_length = 1000  # Adjust as needed
	#var ray_end = ray_origin + ray_direction * ray_length
#
	#var params = PhysicsRayQueryParameters3D.new()
	#params.from = ray_origin
	#params.to = ray_end
	##params.collision_mask = 1  # Optional: Set collision layers to check
#
	#var space_state = get_world_3d().direct_space_state
	#var result = space_state.intersect_ray(params).get("collider")
	#
	#if result:
		#return result
#func _ray_intersect_obj():
	#if ray_interaction.is_colliding():
		#var obj = ray_interaction.get_collider()
		#return obj
#func _pick_up_object():
	#
	#grab_buffer_timer.start()
	##grab_buffer_display.visible = bool(carrying_obj)
	##grab_buffer_display.visible = holding
	#if carrying_obj:
		#return
	#var obj = _ray_intersect_obj()
	##grab_buffer_display.visible = bool(obj and obj.is_in_group("grabbable"))
	#if obj and obj.is_in_group("grabbable"):
		#carrying_obj = obj
		#item_overlay.set_to(carrying_obj, "holding")
		#rotate_to_player_joint.set_node_b(obj.get_path())
		#if hovered_obj and hovered_obj != carrying_obj:
			#rotate_to_player_joint.set_node_b(rotate_to_player_joint.get_path())
			##hovered_obj = null
#func _perspective_toggle():
	#if spring_arm.spring_length <= .5:
		#perspective = "first"
		#spring_arm_length = 3
	#match perspective:
		#"first":
			#current_camera_rotation = camera_pivot.rotation
			#if spring_arm.spring_length >= 1:
				#camera_pivot.rotation.y = rad_to_deg(180)
				#perspective = "third"
				#return
			#spring_arm.spring_length = spring_arm_length
			#camera_pivot.rotation = current_camera_rotation
			#perspective = "second"
			###TODO : controls need to be inverted ?
		#"second":
			#spring_arm.spring_length = spring_arm_length
			#camera_pivot.rotation = -current_camera_rotation
			#camera_pivot.rotation.y = rad_to_deg(-180)
			#perspective = "third"
		#"third":
			#camera_pivot.rotation = current_camera_rotation
			#spring_arm.spring_length = -1
			#perspective = "first"
#func _zoom(zooming):
	#if zooming:
		#camera.fov = Settings.fov / 2.5
	#else:
		#camera.fov = Settings.fov
##endregion
#
##public functions
#func drop_object():
	#carrying_obj = null
	##holding = false
#func player_dead():
	#position = Vector3(0, 6, 0)
	#health = 100
	#Global.score = 0
#
##region // signal connects / settings updates 
#func _grab_buffer_updated(value):
	#if value == 0:
		#value = 1000000000
	#grab_buffer_timer.set_wait_time(value)
	#grab_buffer_display.max_value = value
#func _grab_buffer_expired():
	##grab_buffer_timer_played_once = false #reset timer
	#drop_object()
	#grab_buffer_display.hide()
#func _on_grab_buffer_timer_timeout() -> void:
	#Signalbus.grab_buffer_expired.emit()
#func _player_speed_updated(value):
	#speed = value
#func _player_jump_updated(value):
	#jump_velocity = value
#func _fov_updated(value):
	#camera.set_fov(value)
#func _max_grab_length_updated(value):
	#path_3d.curve.set_point_position(1, Vector3(0,0,-value))
#func _box_open_timer_updated(value):
	#if value == 0:
		#value = 0.01
	#box_open_timer.set_wait_time(value)
	#box_open_bar.max_value = value
#func _box_open_timer_expired():
	#box_open_timer.stop()
	#box_open_bar.hide()
	#if carrying_obj and carrying_obj.is_in_group("openable"):
		#item_overlay.set_to(carrying_obj, "off")
		#carrying_obj.queue_free()
		#drop_object()
#func _on_box_open_timer_timeout() -> void:
	#Signalbus.box_open_timer_expired.emit()
#
#
	##in_dialogue = !in_dialogue
	##character_speech_label.visible = in_dialogue
	###pause_menu.in_dialogue = in_dialogue
	##character_speech_label.text = "[wave amp=50.0 freq=5.0]"+String(Global.dialogues[object.name][0])+"[/wave]"
	##pause_menu.pause(in_dialogue, false)
	##set_dialogue(object.name)
	#
##endregion
#
##func set_dialogue(name):
	#
	
