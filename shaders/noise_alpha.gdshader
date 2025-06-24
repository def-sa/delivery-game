shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float noise_strength : hint_range(0.0, 1.0) = 0.2; // Controls the intensity of the noise effect
uniform float noise_scale : hint_range(1.0, 500.0) = 100.0;  // Determines the granularity of the noise
uniform float noise_speed : hint_range(0.0, 5.0) = 1.0;      // Adjusts how quickly the noise animates

// Pseudo-random function based on UV coordinates
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Sample the texture's color and alpha using the built-in TEXTURE
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Animate the noise by offsetting with TIME multiplied by noise_speed.
    // This makes the noise change continuously over time.
    float noise_value = rand(UV * noise_scale + vec2(TIME * noise_speed));
    
    // Apply noise only to the RGB components and preserve the original alpha
    vec3 noisy_color = tex_color.rgb + (noise_value - 0.5) * noise_strength;
    
    // Output the final color, ensuring that transparency remains intact
    COLOR = vec4(noisy_color, tex_color.a);
}
