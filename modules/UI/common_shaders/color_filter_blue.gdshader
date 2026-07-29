shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;
uniform sampler2D noise_texture:repeat_enable;

uniform float posterize_levels : hint_range(2.0, 32.0) = 2.0;

uniform vec4 gradient_map_dark : source_color = vec4(0.0, 0.0, 0.3, 1.0);
uniform vec4 gradient_map_light : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float gradient_map_strength : hint_range(0.0, 1.0) = 1.0;

uniform vec4 water_tint : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;

uniform vec4 gradient_color_bottom : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform float gradient_strength_bottom : hint_range(0.0, 1.0) = 0.9;

uniform vec4 gradient_color_top : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float gradient_strength_top : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec3 noise_color = texture(noise_texture, SCREEN_UV + (TIME / 50.0)).rgb;
	vec3 color = texture(screen_texture, SCREEN_UV + (noise_color.b / 100.0)).rgb;

	color = floor(color * posterize_levels) / posterize_levels;

	float luminance = dot(color, vec3(0.299, 0.587, 0.114));
	vec3 mapped_color = mix(gradient_map_dark.rgb, gradient_map_light.rgb, luminance);
	color = mix(color, mapped_color, gradient_map_strength);

	color = mix(color, water_tint.rgb, tint_strength);

	float gradient_factor_bottom = UV.y * gradient_strength_bottom * gradient_color_bottom.a;
	color = mix(color, gradient_color_bottom.rgb, gradient_factor_bottom);

	float gradient_factor_top = (1.0 - UV.y) * gradient_strength_top * gradient_color_top.a;
	color = mix(color, gradient_color_top.rgb, gradient_factor_top);

	COLOR.rgb = color;
}
