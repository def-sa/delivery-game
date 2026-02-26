extends Node3D


@onready var player: CharacterBody3D = $"../../game/player"


func _process(delta: float) -> void:
	global_transform = player.global_transform
