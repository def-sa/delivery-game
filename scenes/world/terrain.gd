extends Node3D

var seed_name: String = "wasgajahhjfukfhkfhkyfujk"

@export var chunk_scene: PackedScene
@export var false_chunk_scene: PackedScene
@export var chunk_size: float = 50.0
@export var view_distance: int = Settings.render_distance_default
@export var block_size: int = 12
#@export var room_scenes : Array[PackedScene] = []
#@export var house_size := Vector3i(1,2,1)
#@export var shop_size := Vector3i(2,2,2)
#@export var right_structures: Array[PackedScene]
var house_structure_chance:float = 0.5
#@export var left_structures: Array[PackedScene]
var shop_structure_chance:float = 1

@onready var player: CharacterBody3D = $"../Player"

var chunks = {}

var current_block_index: int = 0
var current_chunk_index: int = 0
var initial = null

const house = preload("res://scenes/house.tscn")

func _ready():
	_set_seed(seed_name)
	
	Signalbus.render_distance_updated.connect(_render_distance_updated)
	initial = true
	_generate_initial_chunks()

func _set_seed(seed_name):
	var seed_to_use : int
	if seed_name:
		seed_to_use = hash(seed_name)
	else:
		seed_to_use = randi()
	seed(seed_to_use)

#func _process(delta):
	#_update_chunks()
#
#func _generate_initial_chunks():
	#for i in range(-view_distance, view_distance):
		#for j in range(-2, 3):  # Create three lanes (-1, 0, 1)
			#var z = -i * chunk_size
			#var x = j * chunk_size
			#_create_chunk(Vector3(x, 0, z), chunk_scene)
	#var outside_position = Vector3(3 * chunk_size, 0, 0)  # Example: far right of the lane system.
	#_create_chunk(outside_position, false_chunk_scene)
	#initial = false
#
#func _update_chunks():
	#var player_z = player.global_transform.origin.z
	#var new_chunk_index = int(player_z / chunk_size)
	#if new_chunk_index != current_chunk_index:
		#current_chunk_index = new_chunk_index
		#var block_index = -int(floor(float(current_chunk_index) / block_size))
		#var chunk_in_block = -current_chunk_index % block_size
		#if chunk_in_block < 0:
			#chunk_in_block += block_size
		#print("/UPDATED/: block #", block_index, " (", chunk_in_block, "/", block_size,")")
		#
		#_generate_chunks_from_index(current_chunk_index)
		#_free_outside_chunks()
#
#func _generate_chunks_from_index(index):
		#for i in range(-view_distance, view_distance):
			#for j in range(-2, 3):  # -1 & 2 is 3 lanes
				#var z = (index - i) * chunk_size
				#var x = j * chunk_size
				#var chunk_position = Vector3(x, 0, z)
				#if chunk_position not in chunks:
					#_create_chunk(chunk_position, chunk_scene)
#
#func _free_outside_chunks():
	#var positions_to_remove = []
	#var player_z = player.global_transform.origin.z
	#for position in chunks.keys():
		#if abs(position.z - player_z) > view_distance * chunk_size:
			#positions_to_remove.append(position)
	#for pos in positions_to_remove:
		#if chunks.has(pos):  # Safety check in case it was already removed
			#chunks[pos].queue_free()
			#chunks.erase(pos)
			#print("/REMOVED/ chunk removed: ", pos)
#
#func _create_chunk(position: Vector3,chunk_scene):
	#var chunk = chunk_scene.instantiate()
	#chunk.position = position
	#chunks[position] = chunk
	#
	#if position.x == -16: #left chunk
		#if randf() < .1:
			#var house = house.instantiate()
			#house.rotate_y(deg_to_rad(90))
			#chunk.add_child(house)
	#
	#if position.x == 16: #right chunk
		#if randf() < .5:
			#var house = house.instantiate()
			#house.rotate_y(deg_to_rad(-90))
			#chunk.add_child(house)
	#
		#
	#add_child(chunk)
	##print(chunk.name)

# Constants to define lane boundaries and generation ranges:
const lane_min_index = -1	# Lane area starts at this x index.
const lane_max_index = 1	 # Lane area ends at this x index.
#var horizontal_range = 5	 # How many chunks to generate left/right relative to the player's x position.
# We now track the player’s current chunk index in both directions.
var current_chunk_index_x = 0
var current_chunk_index_z = 0

func _process(delta):
	_update_chunks()


# Initial generation now creates a full grid around the player.
func _generate_initial_chunks():
	# Get the player's current chunk index (assuming player's position is near (0,0) initially)
	var player_x_index = int(player.global_transform.origin.x / chunk_size)
	var player_z_index = int(player.global_transform.origin.z / chunk_size)
	
	# Loop over the z (row) direction:
	for dz in range(-view_distance, view_distance):
		var z = (player_z_index + dz) * chunk_size
		# Loop over the full horizontal range around the player:
		for dx in range(-view_distance, view_distance + 1):
			var x_index = player_x_index + dx
			var x = x_index * chunk_size
			var pos = Vector3(x, 0, z)
			# Use the normal lane chunk if we're in the central lane region;
			# otherwise, use the outside chunk scene.
			if x_index >= lane_min_index and x_index <= lane_max_index:
				_create_chunk(pos, chunk_scene)
			else:
				_create_chunk(pos, false_chunk_scene)
	initial = false


# Update chunks now checks both the x and z positions of the player.
func _update_chunks():
	var player_pos = player.global_transform.origin
	var new_chunk_index_x = int(player_pos.x / chunk_size)
	var new_chunk_index_z = int(player_pos.z / chunk_size)
	# If the player has advanced enough in either x or z, update the grid.
	if new_chunk_index_x != current_chunk_index_x or new_chunk_index_z != current_chunk_index_z:
		current_chunk_index_x = new_chunk_index_x
		current_chunk_index_z = new_chunk_index_z
		_generate_chunks_from_index(current_chunk_index_x, current_chunk_index_z)
		_free_chunks()


# Generates chunks in a rectangular region around the player.
func _generate_chunks_from_index(center_x_index: int, center_z_index: int):
	for dz in range(-view_distance, view_distance + 1):
		var z = (center_z_index + dz) * chunk_size
		for dx in range(-view_distance, view_distance + 1):
			var x_index = center_x_index + dx
			var x = x_index * chunk_size
			var pos = Vector3(x, 0, z)
			if not chunks.has(pos):
				if x_index >= lane_min_index and x_index <= lane_max_index:
					_create_chunk(pos, chunk_scene)
				else:
					_create_chunk(pos, false_chunk_scene)


# Frees any chunks that are too far from the player (both in x and z).
func _free_chunks():
	var player_pos = player.global_transform.origin
	var positions_to_remove = []
	for pos in chunks.keys():
		if abs(pos.z - player_pos.z) > view_distance * chunk_size or abs(pos.x - player_pos.x) > view_distance * chunk_size:
			positions_to_remove.append(pos)
	for pos in positions_to_remove:
		if chunks.has(pos):  # Safety check.
			chunks[pos].queue_free()
			chunks.erase(pos)
			print("/REMOVED/ chunk removed: ", pos)


# Your chunk creation function remains largely the same.
func _create_chunk(position: Vector3, chunk_scene):
	var chunk = chunk_scene.instantiate()
	chunk.position = position
	chunks[position] = chunk
	
	# Example: add houses only to lane chunks (at x positions of -16 and 16 if chunk_size == 16)
	# Adjust these conditions to match your lane design.
	if position.x == -16:  # left lane chunk
		if randf() < 0.1:
			var house_inst = house.instantiate()
			house_inst.rotate_y(deg_to_rad(90))
			chunk.add_child(house_inst)
	elif position.x == 16:  # right lane chunk
		if randf() < 0.5:
			var house_inst = house.instantiate()
			house_inst.rotate_y(deg_to_rad(-90))
			chunk.add_child(house_inst)
	
	add_child(chunk)








#settings slider changed
func _render_distance_updated(value):
	view_distance = value
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	_generate_chunks_from_index(new_chunk_index, 0)
	_free_chunks()
