shader_type canvas_item;

uniform bool debug = false;
uniform vec2 shadow_offset = vec2(-10.0, -10.0);
uniform vec4 color : source_color;
uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform bool disable_rotating = false;

varying flat vec4 modulate;
varying flat float sprite_rotation;

void vertex() {
    VERTEX.xy *= vec2(2.0);
    modulate = COLOR;
    sprite_rotation = atan(MODEL_MATRIX[0][1], MODEL_MATRIX[0][0]);
}

vec4 sample_texture_safe(sampler2D tex, vec2 uv) {
    return (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) 
        ? vec4(0.0) 
        : texture(tex, uv);
}

vec2 rotate_point(vec2 point, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(
        point.x * c - point.y * s,
        point.x * s + point.y * c
    );
}

float calculate_fade(float coord, float scale) {
    if (coord < 0.0) {
        return 1.0 + (coord / (scale - 1.0));
    } else if (coord > 1.0) {
        return 1.0 - ((coord - 1.0) / (scale - 1.0));
    }
    return 1.0;
}

vec4 process_texture(vec2 uv, sampler2D tex, bool is_main, vec2 pixel_size) {
    if (is_main) {
        return sample_texture_safe(tex, uv) * modulate;
    }
    
    vec4 sampled = sample_texture_safe(tex, uv);
    
    return vec4(color.rgb, (sampled.a * color.a) * modulate.a);
}

void fragment() {
    vec2 scaled_uv = UV * 2.0;
    
    vec4 main_texture = process_texture(scaled_uv, TEXTURE, true, TEXTURE_PIXEL_SIZE);
    
    vec2 adjusted_offset = disable_rotating ? shadow_offset : rotate_point(shadow_offset, -sprite_rotation);
    vec2 shadow_uv = scaled_uv + adjusted_offset * TEXTURE_PIXEL_SIZE;
    
    vec4 shadow = process_texture(shadow_uv, TEXTURE, false, TEXTURE_PIXEL_SIZE);
    
    vec4 main_pm = vec4(main_texture.rgb * main_texture.a, main_texture.a);
    vec4 shadow_pm = vec4(shadow.rgb * shadow.a, shadow.a);

    vec4 out_pm = shadow_pm * (1.0 - main_pm.a) + main_pm;
    vec4 res = vec4(
        out_pm.rgb / max(out_pm.a, 0.0001),
        out_pm.a
    );

    vec4 debug_layer = vec4(1.0, 0.0, 0.0, 0.3);
    COLOR = mix(debug ? debug_layer : res, res, res.a);
}
