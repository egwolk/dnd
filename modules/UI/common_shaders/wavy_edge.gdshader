shader_type canvas_item;

uniform float amplitude = 0.03;
uniform float frequency = 12.0;
uniform float speed = 2.0;
uniform float edge_thickness = 0.15;

uniform int edge = 0; // 0 = Top, 1 = Bottom

void fragment() {
    vec2 uv = UV;

    float wave = pow(abs(sin(uv.x * frequency + TIME * speed)), 2.0);
    wave *= amplitude;

    if (edge == 0) {
        // Top
        if (uv.y < edge_thickness) {
            float fade = 1.0 - uv.y / edge_thickness;
            if (uv.y < wave * fade)
                discard;
        }
    } else {
        // Bottom
        if (uv.y > 1.0 - edge_thickness) {
            float fade = 1.0 - ((1.0 - uv.y) / edge_thickness);
            if (uv.y > 1.0 - wave * fade)
                discard;
        }
    }

    COLOR = texture(TEXTURE, uv);
}