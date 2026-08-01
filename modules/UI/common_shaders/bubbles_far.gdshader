shader_type canvas_item;

uniform vec4 caustic_color : source_color = vec4(0.157, 0.694, 0.878, 1.0);

uniform float edge_softness : hint_range(0.0, 0.05) = 0.015;

uniform float mask_curve_strength : hint_range(-0.5, 0.5) = 0.15;
uniform float mask_curve_width : hint_range(0.1, 5.0) = 1.0;
uniform float mask_base_height : hint_range(0.0, 1.0) = 0.35;
uniform float mask_variation : hint_range(0.0, 0.5) = 0.18;
uniform float mask_noise_scale : hint_range(0.5, 10.0) = 3.0;
uniform float mask_speed : hint_range(0.0, 0.2) = 0.04;

uniform int bubble_count : hint_range(0, 30) = 10;
uniform float bubble_speed : hint_range(0.0, 1.0) = 0.15;
uniform float bubble_min_size : hint_range(0.0, 0.05) = 0.008;
uniform float bubble_max_size : hint_range(0.0, 0.08) = 0.022;
uniform float bubble_wobble : hint_range(0.0, 0.05) = 0.012;
uniform float bubble_shape_wobble : hint_range(0.0, 1.0) = 0.35;
uniform float bubble_shape_speed : hint_range(0.0, 5.0) = 1.5;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 uv) {
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 uv) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amp * noise(uv);
		uv *= 2.0;
		amp *= 0.5;
	}
	return value;
}

vec2 hash2(float n) {
	return fract(sin(vec2(n, n + 1.0)) * vec2(43758.5453, 22578.1459));
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;

	float x = (uv.x - 0.5) * 2.0 * mask_curve_width;
	float curve = x * x * mask_curve_strength;

	float edge_noise = fbm(vec2(uv.x * mask_noise_scale, t * mask_speed));
	float edge_y = mask_base_height + curve + (edge_noise - 0.5) * mask_variation;
	float mask = 1.0 - smoothstep(edge_y - edge_softness, edge_y + edge_softness, uv.y);

	float bubble_alpha = 0.0;
	for (int i = 0; i < bubble_count; i++) {
		float fi = float(i);
		vec2 seed = hash2(fi * 17.13);
		float cycle = fract(t * bubble_speed * (0.4 + seed.x) + seed.y);
		float bx = fract(seed.x * 3.1 + sin(fi) * 0.3);
		bx += sin(t * 2.0 + fi * 10.0) * bubble_wobble;
		float by = 1.0 - cycle;
		float size = mix(bubble_min_size, bubble_max_size, seed.y);

		vec2 delta = uv - vec2(bx, by);
		float angle = atan(delta.y, delta.x);
		float d = length(delta);

		float lobes = 3.0 + floor(seed.x * 3.0);
		float wob = sin(angle * lobes + t * bubble_shape_speed + seed.y * 6.283)
				  + 0.5 * sin(angle * (lobes + 2.0) - t * bubble_shape_speed * 1.3 + seed.x * 6.283);
		float r = size * (1.0 + bubble_shape_wobble * wob);

		float b = 1.0 - smoothstep(r - edge_softness, r + edge_softness, d);
		b *= (1.0 - mask);
		bubble_alpha = max(bubble_alpha, b);
	}

	COLOR = vec4(caustic_color.rgb, caustic_color.a * bubble_alpha);
}
