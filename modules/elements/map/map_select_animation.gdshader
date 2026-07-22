shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float start_angle_degrees : hint_range(0.0, 360.0) = 35.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec2 centered = UV - vec2(0.5);

    float angle_cw = atan(centered.x, -centered.y);
    if (angle_cw < 0.0) {
        angle_cw += TAU;
    }

    float start = radians(start_angle_degrees);
    float delta = mod(start - angle_cw, TAU);

    if (delta > progress * TAU) {
        tex.a = 0.0;
    }
    COLOR = tex;
}