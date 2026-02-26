// res://shaders/terrain_height_world.gdshader
shader_type spatial;
render_mode cull_back, depth_draw_opaque, world_vertex_coords;

uniform sampler2D heightmap;
uniform sampler2D albedo_tex;
uniform vec2	  resolution;	// heightmap resolution (width, height)
uniform float	 tile_size	= 4.0;  // world units per detail-texture repeat
uniform float	 height_scale = 10.0; // vertical exaggeration

// carry UV-like world coords from vertex → fragment
varying vec2 v_world_uv;

void vertex() {
	// VERTEX is already in world space thanks to world_vertex_coords
	v_world_uv = VERTEX.xz / resolution;

	// displace along Y by sampling the global heightmap
	float h = texture(heightmap, v_world_uv).r;
	VERTEX.y += h * height_scale;
}

void fragment() {
	// reconstruct normal from displaced world-space position
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	NORMAL = normalize(cross(dpdx, dpdy));

	// sample a tileable detail texture in world space
	ALBEDO = texture(albedo_tex, v_world_uv / tile_size).rgb;
}