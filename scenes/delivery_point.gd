extends Node3D

@export var player:CharacterBody3D
@onready var delivery_point = $"."
@onready var text_mesh:MeshInstance3D = $text
@onready var outline_mesh = $outline
@onready var particles_delivered = $GPUParticles3D


var elapsed_time = 0.0
var target_time = 0.5 # Time in seconds
var toggle_text_flash = false

func _process(delta: float) -> void:
	look_at(player.global_position)
	rotate_y(deg_to_rad(90))
	rotation.x = 0
	
	elapsed_time += delta
	if elapsed_time >= target_time:
		elapsed_time = 0.0 #reset timer
		if toggle_text_flash:
			toggle_text_flash = false
		else:
			toggle_text_flash = true
		
	if toggle_text_flash:
		text_mesh.mesh.text = "! [delivery point] !
		 |
		V"
	else:
		text_mesh.mesh.text = "[delivery point]
		 |
		V"


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("deliverable"):
		body.queue_free()
		particles_delivered.emitting = true
		Global.add_score(10)
