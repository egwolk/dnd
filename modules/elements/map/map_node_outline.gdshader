shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 32.0) = 1.5;
uniform int sample_count : hint_range(4, 64) = 8;

void fragment() {
	vec4 base = COLOR;
	vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
	float alpha = texture(TEXTURE, UV).a;

	if (alpha < 0.1) {
		float hit = 0.0;
		for (int i = 0; i < sample_count; i++) {
			float angle = float(i) / float(sample_count) * TAU;
			vec2 offset = vec2(cos(angle), sin(angle)) * px;
			hit += texture(TEXTURE, UV + offset).a;
		}
		hit = clamp(hit, 0.0, 1.0);
		COLOR = vec4(outline_color.rgb, hit * outline_color.a); 
	} else {
		COLOR = base; 
	}
}