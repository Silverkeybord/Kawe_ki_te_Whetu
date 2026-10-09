shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform vec4 cube_color : source_color = vec4(0.0, 1.0, 1.0, 0.2); // Cyan
uniform float emission_strength : hint_range(0.0, 5.0) = 0.1;

void vertex() {
    // COLOR.a comes from the ParticleProcessMaterial ColorRamp.
    // As the particle gets older and fades out, we use that value to scale the vertices down.
    VERTEX *= COLOR.a; 
}

void fragment() {
    ALBEDO = cube_color.rgb;
    EMISSION = cube_color.rgb * emission_strength;
    
    // Use the particle system's fading alpha
    ALPHA = COLOR.a; 
}