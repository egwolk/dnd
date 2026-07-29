shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;
uniform sampler2D noise_texture:repeat_enable;

uniform vec4 water_tint : source_color = vec4(0.55, 0.75, 0.95, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec3 noise_color = texture(noise_texture, SCREEN_UV + (TIME / 50.0)).rgb;

	vec3 color = texture(screen_texture, SCREEN_UV + (noise_color.b / 150.0)).rgb;

	color = mix(color, water_tint.rgb, tint_strength);

	COLOR.rgb = color;
}
