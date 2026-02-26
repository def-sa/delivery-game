shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform sampler2D default_texture;
uniform sampler2D biome_texture;
uniform float texture_uv_scale = 8.0;

void fragment() {
	float biome_flag = COLOR.r; // 0.0 = default, 1.0 = biome
	vec2 uv_scaled = UV * texture_uv_scale;

	vec3 default_tex = texture(default_texture, uv_scaled).rgb;
	vec3 biome_tex = texture(biome_texture, uv_scaled).rgb;

	ALBEDO = mix(default_tex, biome_tex, biome_flag); // blend based on biome flag
}
