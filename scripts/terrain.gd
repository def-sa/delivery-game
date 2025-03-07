extends Node3D

var seed: String = "bruh"

@export var chunk_scene: PackedScene
@export var chunk_size: float = 50.0
@export var view_distance: int = 16
@export var block_size: int = 12
@export var room_scenes : Array[PackedScene] = []
## The corridor room is a special room scene which must be a 1x1x1 (in voxels) scene inheriting DungeonRoom which is used to connect all the placed rooms.
@export var corridor_room_scene : PackedScene
@export var house_size := Vector3i(3,3,3)
#@export var right_structures: Array[PackedScene]
var house_structure_chance:float = 0.5
#@export var left_structures: Array[PackedScene]
var shop_structure_chance:float = 1

@onready var player = $"../Player"
 
var chunks = {}
var current_block_index: int = 0
var current_chunk_index: int = 0
var initial = null

#TODO: when creating chunks, would it be more efficient to use multithreading? idk how that workz

func _ready():
	
	Signalbus.render_distance_updated.connect(_render_distance_updated)
	initial = true
	_generate_initial_chunks()

func _process(delta):
	_update_chunks()

func _generate_initial_chunks():
	for i in range(-view_distance, view_distance):
		for j in range(-1, 2):  # Create three lanes (-1, 0, 1)
			var z = -i * chunk_size
			var x = j * chunk_size
			_create_chunk(Vector3(x, 0, z), 1)
	initial = false

func _update_chunks():
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	if new_chunk_index != current_chunk_index:
		current_chunk_index = new_chunk_index
		current_block_index = -current_chunk_index % block_size
		print("BLOCK: in chunk (", current_block_index, " of ", block_size, ")")
		#_update_fog(current_chunk_index)
		_generate_chunks_from_index(current_chunk_index)
		_free_outside_chunks(current_chunk_index)

##BUG: fog doesnt update based on consecutive blocks entered, only new blocks. going backwards will progress fog color 
#func _update_fog(current_chunk_index):
	##clamp number to size of color array
	#var chunk_index_by_fog = -current_chunk_index % block_fog_color.size()
	#if chunk_index_by_fog == 0: #for each new block entered
		#$"../WorldEnvironment".environment.set_fog_light_color(block_fog_color[current_fog_color_index])
		#current_fog_color_index = current_fog_color_index + 1

func _generate_chunks_from_index(index):
		for i in range(-view_distance, view_distance):
			for j in range(-1, 2):  # Update three lanes
				var z = (index - i) * chunk_size
				var x = j * chunk_size
				var chunk_position = Vector3(x, 0, z)
				if chunk_position not in chunks:
					_create_chunk(chunk_position, index)

func _free_outside_chunks(index):
	var positions_to_remove = []
	var player_z = player.global_transform.origin.z
	for position in chunks.keys():
		if abs(position.z - player_z) > view_distance * chunk_size:
			positions_to_remove.append(position)
	for position in positions_to_remove:
		#if is not spawn chunk
		if index != 0:
			chunks[position].queue_free()
			#print("/REMOVED/ chunk removed : ", position)
			chunks.erase(position)

func _create_chunk(position: Vector3, index):
	var chunk = chunk_scene.instantiate()
	chunk.global_transform.origin = position
	add_child(chunk)
	chunks[position] = chunk
	#if not spawn chunk
	if index != 0:
		#print("block index : ",(position.z / chunk_size) / -block_size)
		#if (position.z / chunk_size) / block_size <= -2:
			#$"../WorldEnvironment".environment.set_fog_light_color(Color("#000000"))
		#var structure_pool
		if position.x > 0: #add structures to the rightmost chunk
			#add houses, debris, objectives, ect
			_create_structure(chunk, house_structure_chance, index)
		if position.x < 0: #add structures to the leftmost chunk
			#add shops, refill stations, abandoned warehouse, ect
			
			#if last chunk before new block
			if current_block_index == block_size - 1:
				#shop
				_create_structure(chunk, shop_structure_chance, index)

func _create_structure(chunk, chance, index):
	for i in range(0, int(randf() * 10)):
		if randf() < chance:
			#var structure = structure_pool[randi() % structure_pool.size()].instantiate()
			var dungeon_generator = DungeonGenerator3D.new()
			dungeon_generator.generate_on_ready = false
			dungeon_generator.position = Vector3(1, 5 + (house_size.y * 5), 1)
			#honestly not sure if this is more efficient but it seems to cause less lag spikes and more consistant lag
			dungeon_generator.visualize_generation_progress = true
			if initial == false:
				dungeon_generator.visualize_generation_wait_between_iterations = 250
			else:
				dungeon_generator.visualize_generation_wait_between_iterations = 250
			
			dungeon_generator.max_retries = 3
			#dungeon_generator.generate_threaded = true
			#dungeon_generator.room_cost_multiplier = 2
			#dungeon_generator.room_cost_at_end_for_required_doors = 2
			#dungeon_generator.show_debug_in_game = true
			dungeon_generator.room_scenes = room_scenes 
			dungeon_generator.corridor_room_scene = corridor_room_scene
			dungeon_generator.dungeon_size = house_size
			chunk.add_child(dungeon_generator)
			dungeon_generator.generate(chunk.position.z)
			
			# uhhhhhh generate in an efficient way idek
			# BUG: this is called multiple times? for some reason?
			dungeon_generator.done_generating.connect(_populate_house_items.bind(dungeon_generator))

#BUG: all of this vvvvv
func _populate_house_items(dungeon):
	print(dungeon, " done generating")
	#this is fucking disgusting, dont ever do this
	var spawner = get_node_with_group_spawner(dungeon.get_children()[1].get_children()[0].get_children()[0])
	if spawner:
		spawner.visible = true

func get_node_with_group_spawner(node):
	if node is Node and node != null:
		if node.is_inside_tree():
			for child in node.get_children():
				if child.is_in_group("spawner"):
					return child
	return null



#settings slider changed
func _render_distance_updated(is_default, value):
	view_distance = value
	var player_z = player.global_transform.origin.z
	var new_chunk_index = int(player_z / chunk_size)
	_generate_chunks_from_index(new_chunk_index)
	_free_outside_chunks(new_chunk_index)
