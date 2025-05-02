shader_type canvas_item;

//place this shader on a color rect that fills the screen

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform bool color_bleed_enabled = true;
uniform bool chromatic_abberation_enabled = true;
uniform bool film_grain_enabled = true;
uniform bool sharpness_enabled = true;

group_uniforms chromatic_abberation;
uniform float chromatic_abberation_seperation : hint_range(0.0, 0.1, 0.001) = 0.016;
uniform float chromatic_abberation_intensity : hint_range(0.0, 3.0, 0.1) = 1.5;
uniform float chromatic_abberation_blur_strength : hint_range(0.0, 2.0, 1.0) = 1.0;

group_uniforms film_grain;
uniform sampler2D film_grain_noise : filter_linear_mipmap, repeat_enable;
uniform float film_grain_intensity : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float grain_size : hint_range(0.0, 3.0, 0.1) = 2.0;
uniform float darkness_clamp : hint_range(0.0, 0.5, 0.01) = 0.28;

group_uniforms sharpness;
uniform float sharpness_size : hint_range(0.0, 10.0, 1.0) = 1.0;
uniform float sharpness_intensity : hint_range(0.0, 20000.0, 0.01) = 0.7;

group_uniforms color_bleed;
uniform float color_bleed_seperation : hint_range(0.0, 1.0, 0.001) = 0.02;
uniform float color_bleed_intensity : hint_range(0.0, 3.0, 0.01) = 0.2;
uniform float anti_bleed_intensity : hint_range(0.0, 15.0, 0.01) = 1.8;
uniform float color_bleed_blur_strength : hint_range(0.0, 16.0, 1.0) = 1.0;
uniform int color_bleed_quality : hint_range(1, 64, 1) = 5;

uniform float blend_factor;

void fragment() {

	vec4 screenColor = texture(screen_texture, SCREEN_UV);
	//float screenGrayscale = screenColor.r * 0.299 + screenColor.g * 0.587 + screenColor.b * 0.114;
	vec4 screenColorLOD = textureLod(screen_texture, SCREEN_UV, 1.0);

	if (sharpness_enabled || sharpness_size <= 0.0001){ //a very cheap sharpness effect using texture LODs
		vec4 newColor = screenColor - textureLod(screen_texture, SCREEN_UV, sharpness_size);
		screenColor += (newColor) * sharpness_intensity;
	}

	if (film_grain_enabled || film_grain_intensity <= 0.0001){
		vec2 newUV = (3.5 - grain_size) * SCREEN_UV;
		float grainR = texture(film_grain_noise, newUV + vec2(sin(TIME * 11.01321) + 13.0, cos(TIME * 11.01321))).r;
		float grainG = texture(film_grain_noise, newUV + vec2(sin(TIME * 12.2124) + 5.0, cos(TIME * 12.2124))).g;
		float grainB = texture(film_grain_noise, newUV + vec2(sin(TIME * 11.5315) + 2.0, cos(TIME * 11.5315))).b;
		vec3 grainColor = mix(vec3(grainR, grainG, grainB), vec3(0.5), 1.0 - film_grain_intensity);
		float screenAveraged = (screenColorLOD.r + screenColorLOD.g + screenColorLOD.b)/3.0;
		screenColor *= mix(grainR, 1.0, 0.95);
		screenColor += clamp(vec4(grainColor, 1.0), 0.0, 1.0) * clamp(darkness_clamp - screenAveraged, 0.0, darkness_clamp) * 0.5;
	}
	else{
		float screenAveraged = (screenColorLOD.r + screenColorLOD.g + screenColorLOD.b)/3.0;
		screenColor += clamp(darkness_clamp - screenAveraged, 0.0, darkness_clamp) * 0.25;
	}

	if (color_bleed_enabled){ //shares a good chunk of code with chromatic aberration
		float strength = color_bleed_seperation;
		float intensity = color_bleed_intensity;

		vec4 bloom = vec4(0.0);
		int amount = color_bleed_quality;
		for (int i = 0; i < amount; i++){
			float mul = float(i + 1)/float(amount);
			float blurShift = float(i*2)/float(amount);

			vec2 UVLeftShift = vec2(SCREEN_UV.x - mul * strength, SCREEN_UV.y);
			vec2 UVRightShift = vec2(SCREEN_UV.x + mul * strength, SCREEN_UV.y);
			vec4 leftBleedCol1 = textureLod(screen_texture, UVLeftShift, color_bleed_blur_strength + blurShift)/float(amount * 2);
			vec4 rightBleedCol1 = textureLod(screen_texture, UVRightShift, color_bleed_blur_strength + blurShift)/float(amount * 2);
			bloom += leftBleedCol1 + rightBleedCol1;
		}
		bloom -= texture(screen_texture, SCREEN_UV) * (anti_bleed_intensity);
		bloom = clamp(bloom, vec4(0.0), vec4(1.0));
		screenColor += bloom * intensity;
	}

	if (chromatic_abberation_enabled){
		float strength = (chromatic_abberation_seperation * distance(SCREEN_UV, vec2(0.5)));
		float intensity = chromatic_abberation_intensity * distance(SCREEN_UV, vec2(0.5));

		vec2 UV1 = (SCREEN_UV - vec2(0.5)) * (1.0 + strength) + vec2(0.5);
		vec2 UV2 = (SCREEN_UV - vec2(0.5)) * (1.0 - strength) + vec2(0.5);

		float redCol = textureLod(screen_texture, UV1, chromatic_abberation_blur_strength).r;
		float greenCol = textureLod(screen_texture, UV2, chromatic_abberation_blur_strength).g;
		float blueCol = textureLod(screen_texture, SCREEN_UV, chromatic_abberation_blur_strength).b;
		vec4 newColor = vec4(redCol, greenCol, blueCol, 1.0);
		newColor -= textureLod(screen_texture, SCREEN_UV, chromatic_abberation_blur_strength);
		screenColor += newColor * vec4(vec3(intensity), 1.0);
	}

	COLOR = screenColor;

	COLOR = mix(screenColor, vec4(0.0, 0.0, 0.0, 0.0), blend_factor);
}