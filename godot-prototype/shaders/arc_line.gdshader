shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_opaque;

// Glowing fiber-optic route arc shader.
// Uses additive blending for the luminous neon look from the mockups.

uniform vec4 line_color : source_color = vec4(0.3, 0.7, 1.0, 0.8);
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 0.8;
uniform float flow_speed : hint_range(0.0, 10.0) = 2.0;
uniform float flow_density : hint_range(1.0, 50.0) = 12.0;
uniform float glow_width_multiplier : hint_range(0.0, 3.0) = 1.0;

void fragment() {
	// Subtle pulse animation
	float pulse = 0.85 + 0.15 * sin(TIME * pulse_speed);

	// Flow animation along the arc (UV.x = 0..1 along arc length)
	float flow = sin((UV.x * flow_density - TIME * flow_speed) * 3.14159) * 0.5 + 0.5;
	float flow_factor = 0.7 + 0.3 * flow;

	// Core brightness falls off from center of the strip (UV.y = 0..1 across width)
	float center_dist = abs(UV.y - 0.5) * 2.0;  // 0 at center, 1 at edge
	float core = 1.0 - smoothstep(0.0, 1.0, center_dist);
	core = pow(core, 1.5);  // sharper falloff

	float intensity = glow_intensity * pulse * flow_factor * core * glow_width_multiplier;

	ALBEDO = line_color.rgb * intensity;
	ALPHA = line_color.a * core * pulse;
}
