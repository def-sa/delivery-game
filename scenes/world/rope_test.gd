extends Node3D

func _ready():
	#create_cube()
	pass

func create_cube():
	# Bottom face of the cube
	create_line(Vector3(0, 0, 0), Vector3(1, 0, 0))  # Bottom edge 1
	create_line(Vector3(1, 0, 0), Vector3(1, 1, 0))  # Bottom edge 2
	create_line(Vector3(1, 1, 0), Vector3(0, 1, 0))  # Bottom edge 3
	create_line(Vector3(0, 1, 0), Vector3(0, 0, 0))  # Bottom edge 4

	# Top face of the cube
	create_line(Vector3(0, 0, 1), Vector3(1, 0, 1))  # Top edge 1
	create_line(Vector3(1, 0, 1), Vector3(1, 1, 1))  # Top edge 2
	create_line(Vector3(1, 1, 1), Vector3(0, 1, 1))  # Top edge 3
	create_line(Vector3(0, 1, 1), Vector3(0, 0, 1))  # Top edge 4

	# Vertical edges connecting top and bottom faces
	create_line(Vector3(0, 0, 0), Vector3(0, 0, 1))  # Vertical edge 1
	create_line(Vector3(1, 0, 0), Vector3(1, 0, 1))  # Vertical edge 2
	create_line(Vector3(1, 1, 0), Vector3(1, 1, 1))  # Vertical edge 3
	create_line(Vector3(0, 1, 0), Vector3(0, 1, 1))  # Vertical edge 4

func create_line(from:Vector3, to:Vector3):
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	surface_tool.add_vertex(from)  # Start point
	surface_tool.add_vertex(to)  # End point
	var mesh = surface_tool.commit()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0)  # Red color
	mesh_instance.material_override = material
	
	add_child(mesh_instance)
