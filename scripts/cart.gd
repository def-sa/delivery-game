extends VehicleBody3D

@export var max_steering = 0.9
@export var engine_power = 5

@onready var cart = $"."
@onready var handle_bar = $handle_bar
@onready var handle = $handle


#func _process(delta: float):
	#steering = lerp(steering, Input.get_axis("ui_right", "ui_left") * max_steering, delta * 10)
	#engine_force = Input.get_axis("ui_down", "ui_up") * engine_power
	#if $"../..".carrying == handle:
		#print("dragging cart")
