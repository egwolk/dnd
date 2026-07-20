shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 reveal_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 line_start = vec2(0.0, 0.0);
uniform vec2 line_end = vec2(0.0, -100.0);

varying float t;

void vertex() {
	vec2 dir = line_end - line_start;
	float len_sq = dot(dir, dir);
	float tt = 0.0;
	if (len_sq > 0.0001) {
		tt = dot(VERTEX - line_start, dir) / len_sq;
	}
	t = clamp(tt, 0.0, 1.0);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 tint = mix(base_color, reveal_color, step(t, progress));
	COLOR = tex * tint;
}