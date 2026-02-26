#extends Node3D
#
#var texture: Texture2D
#var texture_uv1_scale: float
#var noise: FastNoiseLite
#var chunk_coords: Vector2i
#var chunk_size: int
#var noise_scale: float
#var noise_height_scale: float
##var biome_regions: Array = []  # Array of BiomeRegion resources
#var biome_blend_width: int  # Optional blending width at the edges of the biome
#var subdivisions: int
#
## i want to add these variables 
#var min_height := 0.0
#var max_height := 5.0
#
#
#var biome_to_color: Dictionary = {}
#
#var mesh_instance: MeshInstance3D
#var collision_shape: CollisionShape3D
#
#const BIOME_SHADER = preload("res://shaders/biome_shader.gdshader")
#
#func _ready():
	#generate_chunk()
#
## Function to generate the terrain chunk
#func generate_chunk():
	#var mesh := ArrayMesh.new()  # Create a new mesh
	#var arrays := []
#
	#var vertices: PackedVector3Array = []  # List to store all the vertex positions
	#var normals: PackedVector3Array = []   # List to store normals
	#var uvs: PackedVector2Array = []	   # UVs for textures
	#var indices: PackedInt32Array = []	 # Triangle indices for the mesh
	#var vertex_colors: PackedColorArray = []  # Colors for each vertex
#
	#var top_texture: Texture2D = texture
	#var bottom_texture: Texture2D = texture  # Default texture for bottom
#
	## Step 1: Create a subdivided plane
	#var chunk_subdivisions := subdivisions  # How many subdivisions in the plane
	#var step := float(chunk_size) / chunk_subdivisions  # Step size for subdividing the plane
#
	#self.position = Vector3(chunk_coords.x * chunk_size, 0, chunk_coords.y * chunk_size)
#
	## Loop through each subdivision and create vertices for the plane
	#for z in range(chunk_subdivisions + 1):
		#for x in range(chunk_subdivisions + 1):
			#var wx = x * step  # World X coordinate of the vertex
			#var wz = z * step  # World Z coordinate of the vertex
			#var world_x = (chunk_coords.x * chunk_size) + wx
			#var world_z = (chunk_coords.y * chunk_size) + wz
#
			## Default height using the default noise function
			#var height = noise.get_noise_2d(world_x * noise_scale, world_z * noise_scale) * noise_height_scale
#
			## Store the vertex and set default color
			#vertices.append(Vector3(wx, height, wz))
			#vertex_colors.append(Color(0.0, 0.0, 0.0))  # Default color for now
			#uvs.append(Vector2(float(x) / chunk_subdivisions * texture_uv1_scale, float(z) / chunk_subdivisions * texture_uv1_scale))
			#
			## Step 4: Adjust height based on the biome's noise function
			## Default min/max
			#var min_h := min_height
			#var max_h := max_height
#
			## Override with biome-specific min/max
			##if is_within_buffer:
				##min_h = min_height
				##max_h = max_height
			##elif overlapping_biomes.size() > 0:
				##var biome1 = overlapping_biomes[0]
				##min_h = biome1.min_height
				##max_h = biome1.max_height
##
			##var raw_noise = vertex_noise.get_noise_2d(world_x * vertex_noise_scale, world_z * vertex_noise_scale)
			##var biome_noise_height = lerp(min_h, max_h, (raw_noise + 1.0) * 0.5)  # Normalize noise from [-1, 1] to [0, 1]
#
			##vertices[z * (chunk_subdivisions + 1) + x].y = biome_noise_height
#
			## Set vertex color based on biome flag (or for default biome buffer)
			##vertex_colors[z * (chunk_subdivisions + 1) + x] = Color(biome_flag, 0, 0)
#
	## Step 5: Create triangles (indices) for the mesh
	#for z in range(chunk_subdivisions):
		#for x in range(chunk_subdivisions):
			#var i = x + z * (chunk_subdivisions + 1)
			#var i_right = i + 1
			#var i_down = i + (chunk_subdivisions + 1)
			#var i_diag = i_down + 1
#
			#indices.append(i)
			#indices.append(i_right)
			#indices.append(i_down)
#
			#indices.append(i_right)
			#indices.append(i_diag)
			#indices.append(i_down)
#
	## Step 6: Compute normals for the mesh
	#normals.resize(vertices.size())
	#for i in range(0, indices.size(), 3):
		#var a = vertices[indices[i]]
		#var b = vertices[indices[i + 1]]
		#var c = vertices[indices[i + 2]]
		#var normal = (b - a).cross(c - a).normalized()
		#normals[indices[i]] += normal
		#normals[indices[i + 1]] += normal
		#normals[indices[i + 2]] += normal
#
	#for i in range(normals.size()):
		#normals[i] = normals[i].normalized()
#
	## Step 7: Finalize arrays for the mesh
	#arrays.resize(Mesh.ARRAY_MAX)
	#arrays[Mesh.ARRAY_VERTEX] = vertices
	#arrays[Mesh.ARRAY_NORMAL] = normals
	#arrays[Mesh.ARRAY_TEX_UV] = uvs
	#arrays[Mesh.ARRAY_INDEX] = indices
	#arrays[Mesh.ARRAY_COLOR] = vertex_colors
#
	#mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
#
	## Step 8: Set up a shader material for the mesh (biome textures)
	#var shader := BIOME_SHADER
	#var shader_material := ShaderMaterial.new()
	#shader_material.shader = shader
	#shader_material.set_shader_parameter("default_texture", bottom_texture)
	#shader_material.set_shader_parameter("biome_texture", top_texture)
	#shader_material.set_shader_parameter("texture_uv_scale", texture_uv1_scale)
#
	#mesh.surface_set_material(0, shader_material)
#
	#var mesh_instance := MeshInstance3D.new()
	#mesh_instance.mesh = mesh
	#add_child(mesh_instance)
#
	## Step 9: Create collision shapes for the chunk
	#var triangle_faces := PackedVector3Array()
	#for i in range(0, indices.size(), 3):
		#triangle_faces.append(vertices[indices[i]])
		#triangle_faces.append(vertices[indices[i + 1]])
		#triangle_faces.append(vertices[indices[i + 2]])
#
	#var shape := ConcavePolygonShape3D.new()
	#shape.data = triangle_faces
#
	#var collider := CollisionShape3D.new()
	#collider.shape = shape
#
	#var body := StaticBody3D.new()
	#body.add_child(collider)
	#add_child(body)
	



# Function to get biomes that overlap with a specific point (intersection check)
#func get_biomes_at_point(point: Vector3) -> Array:
	#var result: Array = []
#
	#for biome in biome_regions:
		#var collision_shape = biome.get_node("collision_shape_3d")
		#if collision_shape and collision_shape.shape is BoxShape3D:
			#var box := collision_shape.shape as BoxShape3D
			#var extents := box.size * 0.5
#
			## Transform point to local space of the biome region (taking rotation and position into account)
			#var local_point = biome.global_transform.affine_inverse() * point  # Transform to local space
			#if abs(local_point.x) < extents.x and abs(local_point.z) < extents.z:
				#result.append(biome)
				#
	#return result

# Function to check if a point is within the default biome buffer
#func is_within_default_biome_buffer(point: Vector3, buffer_distance: float) -> bool:
	## Get the default biome area (replace with your logic to get the actual default biome)
	#var default_biome_area = get_default_biome_area()
	#var distance_to_center = point.distance_to(default_biome_area.position)
	#return distance_to_center < buffer_distance

# Function to retrieve the area of the default biome
#func get_default_biome_area() -> AABB:
	## Assuming the first biome in the array is the default biome (this can be customized)
	#var default_biome = biome_regions[0]
	#var collision_shape = default_biome.get_node("collision_shape_3d")
	#
	#if collision_shape and collision_shape.shape is BoxShape3D:
		#var box := collision_shape.shape as BoxShape3D
		#var center = default_biome.global_transform.origin
		#var size = box.size
#
		## Create and return an AABB (box area) for the default biome's boundaries
		#return AABB(center - size * 0.5, size)
	#else:
		#print("Error: Default biome does not have a valid BoxShape3D!")
		#return AABB()  # Return an empty AABB if no valid shape is found


































extends Node3D

# === CONFIGURABLE PROPERTIES ===
var texture: Texture2D
var texture_uv1_scale: float = 1.0
var noise: FastNoiseLite
var chunk_coords: Vector2i
var chunk_size: int = 32
var noise_scale: float = 0.1
var noise_height_scale: float = 5.0
var biome_blend_width: int = 0
var subdivisions: int = 16
var min_height: float = 0.0
var max_height: float = 5.0
var biome_to_color: Dictionary = {}

var mesh_instance:MeshInstance3D
var collision_shape:CollisionShape3D
var csg: CSGMesh3D
var shader_material:ShaderMaterial
#var csg_combiner
@onready var csg_combiner_3d: CSGCombiner3D = $csg_combiner_3d


var mesh := ArrayMesh.new()

var vertices: PackedVector3Array = []
var normals: PackedVector3Array = []
var uvs: PackedVector2Array = []
var indices: PackedInt32Array = []
var vertex_colors: PackedColorArray = []

#var ready_to_build = false:
	#set(v):
		#ready_to_build = v
		#build_chunk()


const BIOME_SHADER = preload("res://shaders/biome_shader.gdshader")

# === MAIN ENTRY POINT ===
func _ready():
	generate_chunk()
	#await get_tree().process_frame
	#ready_to_build = true

# === TERRAIN GENERATION ===
func generate_chunk():
	
	var top_texture: Texture2D = texture
	var bottom_texture: Texture2D = texture
	
	var step := float(chunk_size) / subdivisions
	self.position = Vector3(chunk_coords.x * chunk_size, 0, chunk_coords.y * chunk_size)

	# === STEP 1: Generate Vertices ===
	for z in range(subdivisions + 1):
		for x in range(subdivisions + 1):
			var wx = x * step
			var wz = z * step
			var world_x = (chunk_coords.x * chunk_size) + wx
			var world_z = (chunk_coords.y * chunk_size) + wz

			var height = noise.get_noise_2d(world_x * noise_scale, world_z * noise_scale) * noise_height_scale
			height = clamp(height, min_height, max_height)

			vertices.append(Vector3(wx, height, wz))
			uvs.append(Vector2(float(x) / subdivisions * texture_uv1_scale, float(z) / subdivisions * texture_uv1_scale))
			vertex_colors.append(Color(0.0, 0.0, 0.0)) # Placeholder

	# === STEP 2: Generate Triangles ===
	for z in range(subdivisions):
		for x in range(subdivisions):
			var i = x + z * (subdivisions + 1)
			var i_right = i + 1
			var i_down = i + (subdivisions + 1)
			var i_diag = i_down + 1

			indices.append_array([i, i_right, i_down, i_right, i_diag, i_down])

	# === STEP 3: Calculate Normals ===
	normals.resize(vertices.size())
	for i in range(0, indices.size(), 3):
		var a = vertices[indices[i]]
		var b = vertices[indices[i + 1]]
		var c = vertices[indices[i + 2]]
		var normal = (b - a).cross(c - a).normalized()
		normals[indices[i]] += normal
		normals[indices[i + 1]] += normal
		normals[indices[i + 2]] += normal

	for i in range(normals.size()):
		normals[i] = normals[i].normalized()

	# === STEP 4: Commit Mesh ===
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_COLOR] = vertex_colors

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	# === STEP 5: Create Shader Material ===
	shader_material = ShaderMaterial.new()
	shader_material.shader = BIOME_SHADER
	shader_material.set_shader_parameter("default_texture", bottom_texture)
	shader_material.set_shader_parameter("biome_texture", top_texture)
	shader_material.set_shader_parameter("texture_uv_scale", texture_uv1_scale)
	mesh.surface_set_material(0, shader_material)

	# === STEP 6: Wrap in CSGMesh3D ===
	csg = CSGMesh3D.new()
	
	#var mesh := ArrayMesh.new()
	## ... build mesh ...
#
	# Save it to disk
	ResourceSaver.save(mesh, "res://temp/terrain_mesh.res")

	# Load it back
	var loaded_mesh = await ResourceLoader.load("res://temp/terrain_mesh.res", "ArrayMesh")
	
	await get_tree().process_frame
	# Use in CSG
	var csg = CSGMesh3D.new()
	
	csg.mesh = loaded_mesh.duplicate()
	csg.material = shader_material
	#csg.use_collision = true
	csg.operation = CSGShape3D.OPERATION_UNION
	csg_combiner_3d.add_child(csg)
	
	#DirAccess.remove_absolute("res://temp/terrain_mesh.res")
	
	#csg.mesh = mesh
	#csg.material = shader_material
	#csg.use_collision = true
	#csg.operation = CSGShape3D.OPERATION_SUBTRACTION
	#csg_combiner_3d.add_child(csg)
	


	#csg_combiner.remove_child(csg)
	#csg_combiner.add_child(csg)
#
	#csg.owner = csg_combiner.get_owner()  # To make sure it shows up in the scene tree, optional in tool scripts

	
	#csg_combiner.request_update()
	#call_deferred("queue_free")

	# === STEP 7: Wait for CSG to Bake ===
	#await get_tree().process_frame
	#build_chunk()


#func build_chunk():
	## === STEP 8: Convert Back to MeshInstance3D ===
	#var final_mesh = csg.get_mesh()
	#if final_mesh:
		#mesh_instance = MeshInstance3D.new()
		#mesh_instance.mesh = final_mesh
		#mesh_instance.material_override = shader_material
		#add_child(mesh_instance)
		#csg.queue_free()
#
	## === STEP 9: Add Collision ===
	#var triangle_faces := PackedVector3Array()
	#for i in range(0, indices.size(), 3):
		#triangle_faces.append(vertices[indices[i]])
		#triangle_faces.append(vertices[indices[i + 1]])
		#triangle_faces.append(vertices[indices[i + 2]])
#
	#var shape := ConcavePolygonShape3D.new()
	#shape.data = triangle_faces
#
	#collision_shape = CollisionShape3D.new()
	#collision_shape.shape = shape
#
	#var static_body := StaticBody3D.new()
	#static_body.add_child(collision_shape)
	#add_child(static_body)
	#pass
