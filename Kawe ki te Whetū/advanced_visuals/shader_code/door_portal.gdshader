shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

group_uniforms Colors;
uniform vec4 core_color : source_color = vec4(0.8, 0.95, 1.0, 1.0);   // Bright cyan/white center
uniform vec4 mid_color : source_color = vec4(0.1, 0.5, 1.0, 1.0);    // Vibrant electric blue
uniform vec4 outer_color : source_color = vec4(0.02, 0.05, 0.3, 1.0); // Deep cosmic navy blue
uniform float emission_strength : hint_range(0.0, 10.0) = 2.0;       // Glow multiplier for Bloom

group_uniforms Aspect_Ratio;
uniform vec2 uv_scale = vec2(1.0, 1.0);                               // Adjust if your door is tall (e.g. 1.0, 0.5)

group_uniforms Portal_Animation;
uniform float spiral_arms : hint_range(1.0, 10.0) = 4.0;
uniform float spiral_tightness : hint_range(1.0, 20.0) = 8.0;
uniform float rotation_speed : hint_range(-10.0, 10.0) = 3.0;
uniform float expansion_speed : hint_range(-10.0, 10.0) = -2.0;      // Negative spirals outward

// Simple procedural pseudo-noise generator
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
    // Center UV coordinates to [-0.5, 0.5] and apply scale correction for door proportions
    vec2 uv = (UV - vec2(0.5)) * uv_scale;
    
    // Convert to Polar Coordinates
    float r = length(uv) * 2.0; // Distance from center
    float angle = atan(uv.y, uv.x); // Angle in radians
    
    // Spiral pattern
    float spiral_pattern = sin(angle * spiral_arms + r * spiral_tightness + TIME * expansion_speed);
    spiral_pattern = (spiral_pattern + 1.0) * 0.5;
    
    // Rotational swirl noise
    float swirly_angle = angle + TIME * (rotation_speed * 0.2);
    vec2 noise_uv = vec2(cos(swirly_angle), sin(swirly_angle)) * r * 3.0;
    float energy_noise = noise(noise_uv + vec2(TIME * 0.5));
    
    // Combine spiral and energy noise
    float final_intensity = mix(spiral_pattern, energy_noise, 0.3);
    
    // Smoothly transition gradient out to outer_color at edges (no fading to transparent)
    vec4 gradient_color = mix(outer_color, mid_color, smoothstep(1.2, 0.3, r));
    gradient_color = mix(gradient_color, core_color, smoothstep(0.4, 0.0, r));
    
    // Center core extra glow
    float core_glow = (1.0 - smoothstep(0.0, 0.6, r)) * 0.5;
    
    // Final RGB color calculation
    vec3 final_rgb = gradient_color.rgb * (final_intensity + core_glow + 0.3);
    
    // Outputs (100% Solid Opacity)
    ALBEDO = final_rgb;
    EMISSION = final_rgb * emission_strength;
    ALPHA = 1.0;
}