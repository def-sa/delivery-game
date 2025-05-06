extends Node3D

var seed_name: String = "abcd"

@export var chunk_scene: PackedScene
@export var false_chunk_scene: PackedScene
@export var big_house: PackedScene
@export var house: PackedScene
@export var tutorial_warehouse: PackedScene
@export var sidewalk_pavement: PackedScene
@export var rod_of_god_scene: PackedScene


@export var chunk_size: int = 64
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
var chunks_in_current_block = {}

var current_block_index: int = 0
var current_chunk_index: int = 0
var initial = null



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


@export var lane_min_index: int = -1		   # Lane region start index
@export var middle_lane_index: int = 0
@export var lane_max_index: int = 1			# Lane region end index

var current_chunk_index_x: int = 0
var current_chunk_index_z: int = 0

func _process(delta):
	_update_chunks()

func _generate_initial_chunks():
	var player_pos = player.global_transform.origin
	var player_x_index = int(player_pos.x / chunk_size)
	var player_z_index = int(player_pos.z / chunk_size)
	
	# Loop over rows and columns to fill a square grid.
	for dz in range(-view_distance, view_distance + 1):
		var z = (player_z_index + dz) * chunk_size
		for dx in range(-view_distance/3, view_distance/3 + 1):
			var x_index = player_x_index + dx
			var x = x_index * chunk_size
			var pos = Vector3(x, 0, z)
			
			# Create a lane chunk if within the designated lane indices;
			# otherwise, create an outside (false) chunk.
			if x_index >= lane_min_index and x_index <= lane_max_index:
				_handle_inside_chunks(pos)
			else:
				_handle_outside_chunks(pos)


func _update_chunks():
	var player_pos = player.global_transform.origin
	#print(player_pos)
	var new_chunk_index_x = int(player_pos.x / chunk_size)
	var new_chunk_index_z = int(player_pos.z / chunk_size)
	
	if new_chunk_index_x != current_chunk_index_x or new_chunk_index_z != current_chunk_index_z:
		current_chunk_index_x = new_chunk_index_x
		current_chunk_index_z = new_chunk_index_z
		_generate_chunks_from_index(current_chunk_index_x, current_chunk_index_z)
		_free_chunks()


func _generate_chunks_from_index(center_x_index: int, center_z_index: int):
	for dz in range(-view_distance, view_distance + 1):
		var z = (center_z_index + dz) * chunk_size
		for dx in range(-view_distance/3, view_distance/3 + 1):
			var x_index = center_x_index + dx
			var x = x_index * chunk_size
			var pos = Vector3(x, 0, z)
			if not chunks.has(pos):
				if x_index >= lane_min_index and x_index <= lane_max_index:
					_handle_inside_chunks(pos)
				else:
					_handle_outside_chunks(pos)


func _free_chunks():
	var player_pos = player.global_transform.origin
	var positions_to_remove = []
	
	for pos in chunks.keys():
		if abs(pos.x - player_pos.x) > view_distance * chunk_size or abs(pos.z - player_pos.z) > view_distance * chunk_size:
			positions_to_remove.append(pos)
			
	for pos in positions_to_remove:
		if chunks.has(pos):
			chunks[pos].queue_free()
			chunks.erase(pos)


func _create_chunk(position: Vector3, scene: PackedScene):
	var chunk = scene.instantiate()
	chunk.position = position
	chunks[position] = chunk
	#print("Creating chunk at ", position, " with scene ", scene)
	
	# Only the lane chunks get additional modifications.
	if scene == chunk_scene:
		var left_lane_x = lane_min_index * chunk_size
		var right_lane_x = lane_max_index * chunk_size
		
		if position.z == 0 and position.x == left_lane_x:
			var tutorial_inst = tutorial_warehouse.instantiate()
			tutorial_inst.rotate_y(deg_to_rad(90))
			chunk.add_child(tutorial_inst)
			add_child(chunk)
			return
		
		if position.x == middle_lane_index:
			var sidewalk_pavement_inst = sidewalk_pavement.instantiate()
			#sidewalk_pavement_inst.rotate_y(deg_to_rad(90))
			chunk.add_child(sidewalk_pavement_inst)
		
		# If this chunk sits exactly at a lane boundary, add houses or other features.
		if position.x == left_lane_x:
			if randf() < 0.1:
				#var amount_of_scenes = 2
				#if randf() < 1/amount_of_scenes:
				var big_house_inst = big_house.instantiate()
				big_house_inst.rotate_y(deg_to_rad(90))
				chunk.add_child(big_house_inst)
				
		
		if position.x == right_lane_x:
			if randf() < 0.5:
				var scenes = [big_house, house]
				var random_scene = scenes.pick_random()
				
				var scene_inst = random_scene.instantiate()
				scene_inst.rotate_y(deg_to_rad(-90))
				chunk.add_child(scene_inst)
	# For both lane and outside chunks, add the chunk to the scene tree.
	add_child(chunk)

func _handle_outside_chunks(pos):
	var chunks: Array = [false_chunk_scene]
	_create_chunk(pos, chunks.pick_random())

func _handle_inside_chunks(pos):
	_create_chunk(pos, chunk_scene)


#settings slider changed
func _render_distance_updated(value):
	view_distance = value
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	_generate_chunks_from_index(new_chunk_index, 0)
	_free_chunks()
