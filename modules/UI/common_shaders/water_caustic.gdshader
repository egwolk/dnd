shader_type canvas_item;

uniform vec4 caustic_color : source_color = vec4(0.157, 0.694, 0.878, 1.0);

uniform float scroll_speed : hint_range(0.0, 1.0) = 0.06;
uniform float noise_scale : hint_range(1.0, 20.0) = 6.0;
uniform float band_min : hint_range(0.0, 1.0) = 0.12;
uniform float band_max : hint_range(0.0, 1.0) = 0.30;
uniform float edge_softness : hint_range(0.0, 0.05) = 0.015;

uniform float mask_curve_strength : hint_range(-0.5, 0.5) = 0.15;
uniform float mask_curve_width : hint_range(0.1, 5.0) = 1.0;
uniform float mask_base_height : hint_range(0.0, 1.0) = 0.35;
uniform float mask_variation : hint_range(0.0, 0.5) = 0.18;
uniform float mask_noise_scale : hint_range(0.5, 10.0) = 3.0;
uniform float mask_speed : hint_range(0.0, 0.2) = 0.04;

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
	for (int i = 0; i < 3; i++) {
		value += amp * noise(uv);
		uv *= 2.0;
		amp *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;

	float x = (uv.x - 0.5) * 2.0 * mask_curve_width;
	float curve = x * x * mask_curve_strength;

	float edge_noise = fbm(vec2(uv.x * mask_noise_scale, t * mask_speed));
	float edge_y = mask_base_height + curve + (edge_noise - 0.5) * mask_variation;
	float mask = 1.0 - smoothstep(edge_y - edge_softness, edge_y + edge_softness, uv.y);

	vec2 flow = vec2(t * scroll_speed, t * scroll_speed * 0.6);
	float n1 = fbm(uv * noise_scale + flow);
	float n2 = fbm(uv * noise_scale - flow * 1.3 + 5.0);
	float pattern = abs(n1 - n2);
	float caustic = smoothstep(band_min - edge_softness, band_min + edge_softness, pattern)
				   - smoothstep(band_max - edge_softness, band_max + edge_softness, pattern);
	float caustic_alpha = clamp(caustic, 0.0, 1.0) * mask;

	COLOR = vec4(caustic_color.rgb, caustic_color.a * caustic_alpha);
}
