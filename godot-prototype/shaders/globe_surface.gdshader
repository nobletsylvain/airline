shader_type spatial;

// Tactile diorama globe: matte earth with day/night cycle, city lights, and atmospheric rim glow.
// Designed to feel like a hand-crafted desk toy, not a photorealistic rendering.

uniform sampler2D day_texture : source_color, filter_linear_mipmap;
uniform sampler2D night_texture : source_color, filter_linear_mipmap;
uniform vec3 sun_direction = vec3(1.0, 0.2, 0.0);
uniform float terminator_sharpness : hint_range(1.0, 20.0) = 8.0;
uniform float night_emission_strength : hint_range(0.0, 3.0) = 1.5;
uniform float atmosphere_intensity : hint_range(0.0, 1.0) = 0.4;
uniform vec3 atmosphere_color : source_color = vec3(0.25, 0.45, 0.9);
uniform float matte_roughness : hint_range(0.0, 1.0) = 0.85;

varying vec3 world_normal;
varying vec3 world_position;

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 day_col = texture(day_texture, UV).rgb;
	vec3 night_col = texture(night_texture, UV).rgb;

	// Day/night blending based on sun direction
	vec3 norm_sun = normalize(sun_direction);
	float sun_dot = dot(world_normal, norm_sun);

	// Smooth terminator transition
	float day_factor = smoothstep(-0.15, 0.25, sun_dot);

	// Matte surface: desaturate day texture slightly for that painted/vinyl feel
	vec3 day_matte = mix(vec3(dot(day_col, vec3(0.299, 0.587, 0.114))), day_col, 0.75);

	// Muted warm tones for land (the diorama palette)
	day_matte = mix(day_matte, day_matte * vec3(1.05, 1.0, 0.92), 0.3);

	// Night side: city lights as emissive pinpricks
	vec3 night_display = night_col * night_emission_strength;

	// Blend day and night
	vec3 surface_color = mix(night_display, day_matte, day_factor);

	// Atmospheric rim glow (Fresnel)
	float fresnel = 1.0 - max(dot(world_normal, normalize(-world_position)), 0.0);
	fresnel = pow(fresnel, 3.0);
	vec3 atmosphere = atmosphere_color * fresnel * atmosphere_intensity;

	// Slight blue tint on the terminator region
	float terminator_zone = 1.0 - abs(sun_dot);
	terminator_zone = pow(terminator_zone, 4.0) * 0.15;
	atmosphere += atmosphere_color * terminator_zone;

	ALBEDO = surface_color;
	ROUGHNESS = matte_roughness;
	METALLIC = 0.0;

	// Emission for city lights on dark side + atmospheric rim
	EMISSION = atmosphere;
	if (day_factor < 0.6) {
		EMISSION += night_col * (1.0 - day_factor) * night_emission_strength * 0.8;
	}
}
