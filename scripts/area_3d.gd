extends Area3D

@onready var player: CharacterBody3D = $".."

func _on_body_entered(body: Node3D) -> void:
	_is_body_valid(body, "DETECTED")

func _on_body_exited(body: Node3D) -> void:
	_is_body_valid(body, "UNDETECTED")

func _is_body_valid(body, to_state):
	if body == player: return
	if not body is physics_item: return
	
	var box_overlay = body.box_overlay
	if body.is_being_held == true: return
	box_overlay.overlay_state = box_overlay.OVERLAY_STATES[to_state]
	
