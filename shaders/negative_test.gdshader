shader_type canvas_item;

// Expose a color picker in Inspector:
uniform vec4 input_color = vec4(1.0, 1.0, 1.0, 1.0);

// (Optional) Expose a 0–1 slider for blend amount:
uniform float amount      : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec3 inv = vec3(1.0) - input_color.rgb;
    vec3 rgb = mix(input_color.rgb, inv, amount);
    COLOR = vec4(rgb, input_color.a);
}