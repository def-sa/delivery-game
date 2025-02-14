extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5

@onready var camera_pivot = $camera_pivot
@onready var spring_arm = $camera_pivot/spring_arm_3d
@onready var spring_position = $camera_pivot/spring_arm_3d/spring_position
@onready var camera = $camera_pivot/spring_arm_3d/camera

var min_zoom_in: int = 0
var max_zoom_out: int = 30

var perspective = "first"
var spring_arm_length = min_zoom_in


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spring_arm.spring_length = -1
	#Signalbus.grab_buffer_expired.connect(_on_grab_buffer_timer_timeout)

func _physics_process(delta: float) -> void:
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
	camera.fov = Settings.camera_fov
	

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("r"):
		perspective_toggle()

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		
		camera_pivot.rotation.y -= event.relative.x * Settings.sensitivity/10000.0
		camera_pivot.rotation.y = wrapf(camera_pivot.rotation.y, 0.0, TAU)
		
		camera_pivot.rotation.x -= event.relative.y * Settings.sensitivity/10000.0
		# -PI/2 = min vertical angle, PI/4 = max vertical angle
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/2, PI/1.75)
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
			

func perspective_toggle():
	if spring_arm.spring_length <= 1:
		perspective = "first"
		spring_arm_length = 3
		
	match perspective:
		"first":
			camera_pivot.rotation.y = rad_to_deg(180)
			if spring_arm.spring_length >= 1:
				perspective = "third"
				return
			spring_arm.spring_length = spring_arm_length
			perspective = "second"
		"second":
			spring_arm.spring_length = spring_arm_length
			camera_pivot.rotation.y = rad_to_deg(0)
			perspective = "third"
		"third":
			spring_arm.spring_length = -1
			perspective = "first"


func _on_grab_buffer_timer_timeout() -> void:
	Signalbus.grab_buffer_expired.emit()
