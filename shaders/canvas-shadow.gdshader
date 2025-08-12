shader_type canvas_item;

// Shadow properties
uniform float shadow_offset_x : hint_range(-50.0, 50.0) = 5.0;
uniform float shadow_offset_y : hint_range(-50.0, 50.0) = 5.0;
uniform float shadow_blur : hint_range(0.0, 20.0) = 3.0;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float shadow_spread : hint_range(0.0, 10.0) = 0.0;

varying vec2 world_position;

vec4 sample_blur(sampler2D tex, vec2 uv, vec2 pixel_size, float blur_amount) {
    if (blur_amount <= 0.0) {
        return texture(tex, uv);
    }
    
    vec4 color = vec4(0.0);
    float total_weight = 0.0;
    
    int samples = int(ceil(blur_amount * 2.0));
    samples = max(samples, 1);
    
    for (int x = -samples; x <= samples; x++) {
        for (int y = -samples; y <= samples; y++) {
            vec2 offset = vec2(float(x), float(y)) * pixel_size * blur_amount;
            float distance = length(vec2(float(x), float(y)));
            
            if (distance <= blur_amount) {
                float weight = exp(-distance * distance / (2.0 * blur_amount * blur_amount));
                color += texture(tex, uv + offset) * weight;
                total_weight += weight;
            }
        }
    }
    
    if (total_weight > 0.0) {
        color /= total_weight;
    }
    
    return color;
}

void fragment() {
    vec2 screen_pixel_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 shadow_uv = SCREEN_UV - vec2(shadow_offset_x, shadow_offset_y) / screen_pixel_size;
    
    // Sample the original texture
    vec4 original_color = texture(TEXTURE, UV);
    
    // Sample the texture at shadow offset position with blur
    vec4 shadow_sample = sample_blur(TEXTURE, shadow_uv, SCREEN_PIXEL_SIZE, shadow_blur);
    
    // Create shadow mask from alpha channel
    float shadow_alpha = shadow_sample.a;
    
    // Apply shadow spread
    if (shadow_spread > 0.0) {
        float spread_samples = ceil(shadow_spread);
        float max_alpha = shadow_alpha;
        
        for (int x = -int(spread_samples); x <= int(spread_samples); x++) {
            for (int y = -int(spread_samples); y <= int(spread_samples); y++) {
                if (x == 0 && y == 0) continue;
                
                float distance = length(vec2(float(x), float(y)));
                if (distance <= shadow_spread) {
                    vec2 spread_offset = vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE;
                    float spread_alpha = texture(TEXTURE, shadow_uv + spread_offset).a;
                    max_alpha = max(max_alpha, spread_alpha);
                }
            }
        }
        shadow_alpha = max_alpha;
    }
    
    // Create the shadow color
    vec4 final_shadow = vec4(shadow_color.rgb, shadow_color.a * shadow_alpha);
    
    // Blend shadow behind original content
    // Only show shadow where there's no original content
    float shadow_visibility = (1.0 - original_color.a) * final_shadow.a;
    vec3 blended_color = mix(final_shadow.rgb, original_color.rgb, original_color.a);
    float final_alpha = max(original_color.a, shadow_visibility);
    
    COLOR = vec4(blended_color, final_alpha);
}
