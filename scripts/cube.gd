extends RigidBody3D


@onready var object:RigidBody3D = $"."
@onready var outline:MeshInstance3D = $Mesh/Outline

var outline_visible:bool = false:
	set(value):
		_set_meta("outline_visible", outline_visible)
		if value == true:
			outline.visible = true
		elif outline_visible == false:
			outline.visible = false
	get:
		return object.get_meta("outline_visible",outline_visible)


func _set_meta(str:String, variable):
	object.set_meta(str, variable)

func _ready() -> void:
	_set_meta("outline_visible", outline_visible)
