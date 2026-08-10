shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float fade_height : hint_range(0.0, 1.0) = 0.2; 
uniform float softness : hint_range(0.0, 1.0) = 1.0;   

vec3 screen(vec3 base, vec3 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
    vec4 screen_c = texture(SCREEN_TEXTURE, SCREEN_UV);
    COLOR.rgb = screen(COLOR.rgb, screen_c.rgb);
    
    vec4 modulate_color = COLOR; 
    vec4 tex_color = texture(TEXTURE, UV);
    float fade = smoothstep(0.0, fade_height, UV.y);
    float alpha_mult = mix(step(fade_height, UV.y), fade, softness);
    tex_color.a *= alpha_mult;
    COLOR = tex_color * modulate_color;

    
    
}