shader_type canvas_item;

// Traffic Flow Shader - Animated chevron particles along route lines
// Used for visualizing passenger flow on route arcs

uniform float time_offset : hint_range(0.0, 1000.0) = 0.0;
uniform float flow_speed : hint_range(0.1, 5.0) = 1.0;
uniform float chevron_density : hint_range(1.0, 10.0) = 4.0;
uniform float stream_count : hint_range(1.0, 3.0) = 1.0;
uniform vec4 flow_color : source_color = vec4(0.0, 0.83, 1.0, 0.65);  // #00d4ff Cyan Primary
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.0;
uniform float chevron_size : hint_range(0.1, 0.5) = 0.2;

void fragment() {
    vec2 uv = UV;
    
    // Base line (y = 0.5 is center)
    float line_dist = abs(uv.y - 0.5);
    
    // Calculate animated chevron pattern along the line
    float time = TIME * flow_speed + time_offset;
    float x_offset = uv.x * chevron_density - time;
    
    // Create chevron shape using sawtooth wave
    float chevron = fract(x_offset);
    
    // Sharpen to create distinct chevron arrows (> shape pointing right)
    float chevron_shape = smoothstep(0.0, chevron_size, chevron) * smoothstep(chevron_size * 2.0, chevron_size, chevron);
    
    // Multiple streams for high-traffic routes (branchless for GPU efficiency)
    float alpha = 0.0;
    
    // Stream masks using step() for branchless conditionals
    float stream2_mask = step(2.0, stream_count);
    float stream3_mask = step(3.0, stream_count);
    
    // Stream 1 (center) - always active
    float stream1_dist = abs(uv.y - 0.5);
    alpha += chevron_shape * smoothstep(0.15, 0.05, stream1_dist);
    
    // Stream 2 (if stream_count >= 2) - branchless
    float stream2a_dist = abs(uv.y - 0.35);
    float stream2b_dist = abs(uv.y - 0.65);
    float chevron2 = fract(x_offset + 0.33);
    float chevron2_shape = smoothstep(0.0, chevron_size, chevron2) * smoothstep(chevron_size * 2.0, chevron_size, chevron2);
    alpha += stream2_mask * chevron2_shape * smoothstep(0.12, 0.02, stream2a_dist);
    alpha += stream2_mask * chevron2_shape * smoothstep(0.12, 0.02, stream2b_dist);
    
    // Stream 3 (if stream_count >= 3, for 5k+ pax routes) - branchless
    float stream3a_dist = abs(uv.y - 0.25);
    float stream3b_dist = abs(uv.y - 0.75);
    float chevron3 = fract(x_offset + 0.66);
    float chevron3_shape = smoothstep(0.0, chevron_size, chevron3) * smoothstep(chevron_size * 2.0, chevron_size, chevron3);
    alpha += stream3_mask * chevron3_shape * smoothstep(0.10, 0.02, stream3a_dist);
    alpha += stream3_mask * chevron3_shape * smoothstep(0.10, 0.02, stream3b_dist);
    
    // Clamp alpha
    alpha = clamp(alpha, 0.0, 1.0);
    
    // Apply glow for high-traffic routes
    vec4 glow = flow_color * glow_intensity * alpha;
    
    // Final color
    vec4 final_color = flow_color;
    final_color.a = alpha * flow_color.a;
    final_color.rgb += glow.rgb;
    
    COLOR = final_color;
}
