shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    float alpha = smoothstep(0.5, 0.4, dist);
    ALBEDO = vec3(0.0);
    ALPHA = alpha * 0.4;
}
