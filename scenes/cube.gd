extends RigidBody3D

@onready var outline = $Mesh/Outline
var outline_visible = false

func _process(delta: float) -> void:
	if outline_visible == true:
		outline.visible = true
	elif outline_visible == false:
		outline.visible = false
