shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
    vec4 screen_c = texture(SCREEN_TEXTURE, SCREEN_UV);
    COLOR.rgb = screen(COLOR.rgb, screen_c.rgb);
}