shader_type canvas_item;

uniform bool debug = false;
uniform float border_scale = 2.0;
uniform vec2 shadow_offset = vec2(-1.0, -1.0);  // SMALL VALUES ONLY!
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float shadow_scale = 1.5;
uniform bool disable_rotating = false;

varying flat vec4 modulate;
varying flat float sprite_rotation;

void vertex() {
    float final_scale = max(border_scale, border_scale * shadow_scale);
    VERTEX.xy *= vec2(final_scale);
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

vec4 apply_gaussian_blur(sampler2D tex, vec2 uv, vec2 pixel_size) {
    if (blur_amount <= 0.0) return sample_texture_safe(tex, uv);
    
    vec4 color_blur = vec4(0.0);
    float total_weight = 0.0;
    int kernel_size = int(blur_amount);
    
    for (int x = -kernel_size; x <= kernel_size; x++) {
        for (int y = -kernel_size; y <= kernel_size; y++) {
            vec2 blur_offset = vec2(float(x), float(y)) * pixel_size;
            float weight = exp(-0.5 * (float(x * x + y * y)) / (blur_amount * blur_amount + 0.01));
            color_blur += sample_texture_safe(tex, uv + blur_offset) * weight;
            total_weight += weight;
        }
    }
    
    return total_weight > 0.0 ? color_blur / total_weight : vec4(0.0);
}

void fragment() {
    float final_scale = max(border_scale, border_scale * shadow_scale);
    vec2 scaled_uv = UV * final_scale - (0.5 * (final_scale - 1.0));
    
    // Main texture
    vec4 main_texture = sample_texture_safe(TEXTURE, scaled_uv) * modulate;
    
    // Shadow position - using the working calculation
    vec2 adjusted_offset = disable_rotating ? shadow_offset : rotate_point(shadow_offset, -sprite_rotation);
    vec2 shadow_uv = scaled_uv + adjusted_offset * TEXTURE_PIXEL_SIZE;
    
    // Shadow with optional blur
    vec4 shadow_sample = apply_gaussian_blur(TEXTURE, shadow_uv, TEXTURE_PIXEL_SIZE);
    vec4 shadow = vec4(color.rgb, shadow_sample.a * color.a);
    
    // Blend shadow behind main texture
    COLOR = mix(shadow, main_texture, main_texture.a);
    
    if (debug) {
        COLOR = mix(COLOR, vec4(1.0, 0.0, 0.0, 0.3), 0.3);
    }
}