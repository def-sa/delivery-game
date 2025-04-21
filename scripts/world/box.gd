extends RigidBody3D

@export var modifiers: Array

@onready var rigidbody = $"."
var mesh
var collision
var decal

var id = 0
var tier

var is_discovered:bool = false
#var is_being_carried: bool = false
#var has_item_inside:bool = false


var is_delivered: bool = false
var in_cart: bool = false:
	set(v):
		#print("in_cart: ",v)
		in_cart = v


var is_roped: bool = false:
	set(v):
		if v == true:
			gravity_scale = 0.5
		else:
			gravity_scale = 1
		is_roped = v

#i want to pass in variables into the spawner and create the box with those variables 
#modifers x
#rarity
#texture x
#size x
#weight
#openable 

# was going to enable decal only when holing, i think its fine ? for now at least
func _ready() -> void:
	for child in rigidbody.get_children():
		if child is Decal:
			decal = child
		if child is CollisionShape3D:
			collision = child
		if child is MeshInstance3D:
			mesh = child
	
	#Signalbus.box_being_carried.connect(_box_being_carried)
	
	for modifier in modifiers:
		rigidbody.add_to_group(modifier)


#func _box_being_carried(obj):
	#decal.visible = is_being_carried
	#if obj == self:
		#is_being_carried = true
	#else:
		#is_being_carried = false
