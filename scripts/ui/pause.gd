extends Control

var paused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = !paused
		$".".visible = paused
		## TODO: get proper pause working
		#get_tree().set_pause(paused)
		
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif !paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
