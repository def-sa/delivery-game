extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_pivot = $camera_pivot
@onready var spring_arm = $camera_pivot/spring_arm_3d
@onready var spring_position = $camera_pivot/spring_arm_3d/spring_position
@onready var camera = $camera_pivot/spring_arm_3d/camera

#
## mouse properties
#var mouse_control = false
#var mouse_sensitivity = 0.005
#var invert_y = false
#var invert_x = false
#
## zoom settings
#var max_zoom = 3.0
#var min_zoom = 0.4
#var zoom_speed = 0.09
#
#var zoom = 1.5

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#handle mmovement
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()



func _process(delta: float) -> void:
	camera.fov = Settings.camera_fov



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		camera_pivot.rotation.y -= event.relative.x * Settings.sensitivity/10000.0
		camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)
		
		camera_pivot.rotation.x -= event.relative.y * Settings.sensitivity/10000.0
		# -PI/2 = min vertical angle, PI/4 = max vertical angle
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/4)
	if event.is_action_pressed("cam_zoom_in"):
		spring_arm.spring_length -= 1
	if event.is_action_pressed("cam_zoom_out"):
		spring_arm.spring_length += 1
		 
		if event.is_action_pressed("perspective_toggle"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
