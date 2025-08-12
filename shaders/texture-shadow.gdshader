shader_type canvas_item;

uniform bool debug = false;
uniform float border_scale = 2.0;
uniform vec2 shadow_offset = vec2(-1.0, -1.0);
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float shadow_scale = 1.5;
uniform bool disable_rotating = false;

varying flat vec4 modulate;

void vertex() {
    // Simplified vertex transformation for TextureRect
    VERTEX *= border_scale;
    modulate = COLOR;
}

vec4 sample_texture_safe(sampler2D tex, vec2 uv) {
    return (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) 
        ? vec4(0.0) 
        : texture(tex, uv);
}

void fragment() {
    // Simplified UV handling for TextureRect
    vec2 center = vec2(0.5);
    vec2 uv = (UV - center) * border_scale + center;
    
    // Main texture
    vec4 main_texture = sample_texture_safe(TEXTURE, uv) * modulate;
    
    // Shadow position
    vec2 shadow_uv = uv + shadow_offset * TEXTURE_PIXEL_SIZE;
    
    // Shadow
    vec4 shadow_sample = sample_texture_safe(TEXTURE, shadow_uv);
    vec4 shadow = vec4(color.rgb, shadow_sample.a * color.a);
    
    // Blend
    COLOR = mix(shadow, main_texture, main_texture.a);
    
    if (debug) {
        COLOR = mix(COLOR, vec4(1.0, 0.0, 0.0, 0.3), 0.3);
    }
}