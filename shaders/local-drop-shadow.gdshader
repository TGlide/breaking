shader_type canvas_item;
render_mode skip_vertex_transform;

uniform bool shadow_only = false;
uniform vec4 shadow_color : source_color;
uniform vec2 shadow_offset = vec2(5.0, 5.0);

varying vec4 modulate;

void vertex() {
	vec2 texture_size = vec2(1.0, 1.0) / TEXTURE_PIXEL_SIZE;

	// Calculate padding needed to prevent shadow clipping
	vec2 padding = abs(shadow_offset);

	VERTEX = VERTEX - texture_size * 0.5;
	VERTEX = VERTEX * (vec2(1.0, 1.0) + padding * 2.0 * TEXTURE_PIXEL_SIZE);
	VERTEX = VERTEX + texture_size * 0.5;
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;

	vec2 factor = (vec2(1.0, 1.0) + 2.0 * padding * TEXTURE_PIXEL_SIZE);
	UV = factor * UV + vec2(0.5, 0.5) - 0.5 * factor;

	modulate = COLOR;
}

vec4 padded_sample(sampler2D tex, vec2 uv) {
	vec2 t = abs(uv - vec2(0.5, 0.5));
	float b = (t.x >= 0.5 || t.y >= 0.5) ? 0.0 : 1.0;
	return b * texture(tex, uv);
}

void fragment() {
	// Sample original texture at normal UV
	vec4 original = padded_sample(TEXTURE, UV);

	// Sample shadow texture at offset UV
	vec4 shadow = padded_sample(TEXTURE, UV + shadow_offset * TEXTURE_PIXEL_SIZE);

	if (shadow_only) {
		// Only show shadow
		COLOR = shadow.a * shadow_color;
	} else {
		// Composite original over shadow
		COLOR = mix(shadow.a * shadow_color, original, original.a);
	}

	COLOR *= modulate;
}
