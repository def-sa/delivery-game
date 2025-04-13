extends Area3D

@onready var player: CharacterBody3D = $"../Player"

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		player.health -= 10
