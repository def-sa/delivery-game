extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var camera_mode = "first"


@onready var player := $"."
@onready var pivot := $camerapivot
@onready var camera := $camerapivot/Camera3D


func _process(delta: float) -> void:
	
	camera.fov = Settings.camera_fov
	
	if Input.is_action_just_pressed("perspective"):
		match camera_mode:
			"first":
				print("first")
				$camerapivot.position.y = 0
				$camerapivot.position.z = 0
				camera_mode = "second"
			"second":
				print("second")
				$camerapivot.position.y = 3
				$camerapivot.position.z = -3
				camera.look_at(player.global_transform.origin)
				camera_mode = "third"
			"third":
				print("third")
				$camerapivot.position.y = 3
				$camerapivot.position.z = 3
				camera.look_at(player.global_transform.origin)
				camera_mode = "first"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			#if event.relative.x != 0:
				#pivot.rotate_object_local(Vector3.UP, event.relative.x * Settings.sensitivity)
			#if event.relative.y != 0:
				#pivot.rotate_object_local(Vector3.RIGHT, event.relative.y * Settings.sensitivity)
			pivot.rotate_y(-event.relative.x * Settings.sensitivity/5000)
			camera.rotate_x(-event.relative.y * Settings.sensitivity/5000)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
			

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
