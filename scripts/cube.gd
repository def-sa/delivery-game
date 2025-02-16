extends RigidBody3D

@onready var outline = $Mesh/Outline
var outline_visible = false:
	set(value):
		if value == true:
			outline.visible = true
		elif outline_visible == false:
			outline.visible = false
