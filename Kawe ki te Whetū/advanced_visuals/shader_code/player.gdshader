shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_back, unshaded;

uniform vec4 inner_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);      // Default White core
uniform vec4 glow_color : source_color = vec4(0.7, 0.4, 1.0, 1.0);       // Default Light Purple
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.5;                // Edge sharpness
uniform float core_size : hint_range(0.1, 3.0) = 1.0;                    // Core density
uniform float glow_intensity : hint_range(1.0, 10.0) = 2.0;             // Outer brightness

void fragment() {
    // Calculate N dot V (Normal dot View direction)
    float n_dot_v = clamp(dot(NORMAL, VIEW), 0.0, 1.0);

    // Outer Fresnel rim glow
    float fresnel = pow(1.0 - n_dot_v, fresnel_power);

    // Inner core brightness
    float core = pow(n_dot_v, core_size);

    // Combine inner core color and fresnel outer glow
    vec3 final_color = (inner_color.rgb * core) + (glow_color.rgb * fresnel * glow_intensity);

    // Output final color to emission for glowing effect
    EMISSION = final_color;
    ALPHA = clamp(core + fresnel, 0.0, 1.0);
}