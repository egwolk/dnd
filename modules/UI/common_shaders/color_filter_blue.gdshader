shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;
uniform sampler2D noise_texture:repeat_enable;

uniform vec4 water_tint : source_color = vec4(0.55, 0.75, 0.95, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;

uniform vec4 gradient_color_bottom : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_strength_bottom : hint_range(0.0, 1.0) = 1.0;

uniform vec4 gradient_color_top : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_strength_top : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec3 noise_color = texture(noise_texture, SCREEN_UV + (TIME / 50.0)).rgb;
	vec3 color = texture(screen_texture, SCREEN_UV + (noise_color.b / 150.0)).rgb;

	color = mix(color, water_tint.rgb, tint_strength);

	float gradient_factor_bottom = UV.y * gradient_strength_bottom * gradient_color_bottom.a;
	color = mix(color, gradient_color_bottom.rgb, gradient_factor_bottom);

	float gradient_factor_top = (1.0 - UV.y) * gradient_strength_top * gradient_color_top.a;
	color = mix(color, gradient_color_top.rgb, gradient_factor_top);

	COLOR.rgb = color;
}
