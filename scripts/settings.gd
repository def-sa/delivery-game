extends Node

var camera_fov:int = 90
var default_camera_fov

var sensitivity:float = 44.0
var default_sensitivity 

func _ready() -> void:
	init_fov()
	init_sensitivity()


func init_fov():
	#variables are passed automatically since its a callable (no parentheses)
	Signalbus.fov_updated.connect(_update_fov)
	default_camera_fov = camera_fov

func _update_fov(is_default, value):
	if is_default:
		camera_fov = default_camera_fov
	else:
		camera_fov = value



func init_sensitivity():
	Signalbus.sensitivity_updated.connect(_update_sensitivity)
	default_sensitivity = sensitivity
		
func _update_sensitivity(is_default, value):
	if is_default:
		sensitivity = default_sensitivity
	else:
		sensitivity = value
