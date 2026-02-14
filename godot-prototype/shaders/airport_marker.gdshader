shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

// Airport marker: glowing ember billboard embedded in the globe surface.
// Radial gradient glow with pulsing animation based on activity.
// Billboard behavior is handled by the material (StandardMaterial3D) or by the vertex function below.

uniform vec4 marker_color : source_color = vec4(1.0, 0.75, 0.2, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.5;
uniform float pulse_speed : hint_range(0.0, 8.0) = 2.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.3;
uniform float inner_radius : hint_range(0.0, 0.5) = 0.08;
uniform float outer_radius : hint_range(0.1, 1.0) = 0.5;

void vertex() {
	// Billboard: extract scale from model matrix, apply camera-facing orientation
	float scale_x = length(MODEL_MATRIX[0].xyz);
	float scale_y = length(MODEL_MATRIX[1].xyz);

	// Get the position in view space
	vec4 world_pos = MODEL_MATRIX[3];
	vec4 view_pos = VIEW_MATRIX * world_pos;

	// Apply vertex offset in view space (billboard)
	VERTEX.x *= scale_x;
	VERTEX.y *= scale_y;
	POSITION = PROJECTION_MATRIX * (view_pos + vec4(VERTEX.xy, 0.0, 0.0));
}

void fragment() {
	// Distance from center of the quad (UV 0.5, 0.5)
	vec2 center = UV - vec2(0.5);
	float dist = length(center);

	// Discard pixels outside the glow radius
	if (dist > outer_radius) {
		discard;
	}

	// Pulse animation
	float pulse = 1.0 - pulse_amount + pulse_amount * sin(TIME * pulse_speed);

	// Radial gradient: bright core fading to transparent edge
	float core = 1.0 - smoothstep(inner_radius, outer_radius, dist);
	core = pow(core, 2.0);  // Tighter center falloff

	// Bright inner point
	float inner_glow = 1.0 - smoothstep(0.0, inner_radius * 2.0, dist);
	inner_glow = pow(inner_glow, 3.0);

	float intensity = (core * 0.6 + inner_glow * 1.0) * glow_intensity * pulse;

	ALBEDO = marker_color.rgb * intensity;
	ALPHA = core * marker_color.a * pulse;
}
