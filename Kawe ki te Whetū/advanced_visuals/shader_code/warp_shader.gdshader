shader_type canvas_item;

// Time and Animation Controls
uniform float warp_speed : hint_range(0.1, 20.0, 0.1) = 6.0;        // Speed of the jump
uniform float spin_speed : hint_range(-5.0, 5.0, 0.1) = 0.5;        // Rotation speed
uniform float streak_density : hint_range(10.0, 200.0, 1.0) = 80.0; // How many stars
uniform float streak_length : hint_range(0.01, 2.0, 0.01) = 0.5;    // How long the light trails are
uniform float blur_amount : hint_range(0.01, 1.0, 0.01) = 0.8;      // Motion blur softness

// Colors
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.03, 1.0); 
uniform vec4 fringe_color : source_color = vec4(0.0, 0.4, 1.0, 1.0);      
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);        

// Simple pseudo-random function
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
    // Center UV coordinates to [-0.5, 0.5]
    vec2 uv = UV - vec2(0.5);

    // Polar coordinates
    float radius = length(uv);
    
    // Add TIME * spin_speed to the angle to make the tunnel rotate
    float angle = atan(uv.y, uv.x) + (TIME * spin_speed); 

    // Discretize the angle so we get distinct separate streaks
    float angle_snapped = floor(angle * streak_density) / streak_density;

    // Create a 3D depth effect (1.0 / radius)
    float z = 1.0 / (radius + 0.0001); 

    // Changed to PLUS (+) TIME so the stars fly OUT toward the camera
    float current_z = z + (TIME * warp_speed);

    // Segment the Z space to create individual star trail lengths
    float z_snapped = floor(current_z * streak_length);

    // Generate a random value for each specific streak segment
    float streak_noise = hash(vec2(angle_snapped, z_snapped));

    // Shape the streak and apply motion blur based on the blur_amount parameter
    float z_fract = fract(current_z * streak_length);
    float streak_shape = smoothstep(0.0, blur_amount, z_fract) * smoothstep(1.0, 1.0 - blur_amount, z_fract);

    // Soften the side-to-side edges of the streaks slightly based on blur
    float streak_mask = smoothstep(0.85 - (blur_amount * 0.15), 0.95, streak_noise);

    // Combine mask and shape for the final streak intensity
    float intensity = streak_mask * streak_shape;

    // Add a bright blinding core at the very center vanishing point
    float center_glow = smoothstep(0.15, 0.0, radius);

    // Start with a completely opaque solid background color
    vec3 final_rgb = background_color.rgb;
    
    // Add the blue fringing to the streaks
    final_rgb = mix(final_rgb, fringe_color.rgb, intensity * 0.8);
    
    // Add the sharp white core to the center of the streaks
    final_rgb = mix(final_rgb, core_color.rgb, pow(intensity, 2.0)); 
    
    // Add the center vanishing point glow
    final_rgb += core_color.rgb * center_glow;

    // Output with 1.0 Alpha (No transparent parts)
    COLOR = vec4(final_rgb, 1.0);
}