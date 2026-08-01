shader_type canvas_item;

uniform float fade_height : hint_range(0.0, 1.0) = 0.2; 
uniform float softness : hint_range(0.0, 1.0) = 1.0;   

void fragment() {
    vec4 modulate_color = COLOR; 

    vec4 tex_color = texture(TEXTURE, UV);

    float fade = smoothstep(0.0, fade_height, UV.y);

    float alpha_mult = mix(step(fade_height, UV.y), fade, softness);

    tex_color.a *= alpha_mult;

    COLOR = tex_color * modulate_color;
}