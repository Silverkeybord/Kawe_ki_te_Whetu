shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, unshaded;

group_uniforms Colors;
uniform vec4 inner_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.6, 0.2, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 10.0) = 2.0;

group_uniforms Transparency;
uniform float overall_alpha : hint_range(0.0, 1.0) = 0.8;

group_uniforms Shape;
uniform float fresnel_power : hint_range(0.1, 8.0) = 2.0;
uniform float core_size : hint_range(0.1, 5.0) = 1.5;

group_uniforms Spikes;
uniform float spike_scale : hint_range(1.0, 50.0) = 12.0;
uniform float spike_speed : hint_range(0.0, 10.0) = 2.5;
uniform float spike_displacement : hint_range(0.0, 1.0) = 0.2;
uniform float spike_roughness : hint_range(0.1, 5.0) = 2.0;

float hash(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

float noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
            mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
        mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
            mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y),
        f.z
    );
}

void vertex() {
    vec3 pos = VERTEX * spike_scale + vec3(0.0, TIME * spike_speed, 0.0);
    float n = pow(noise3D(pos), spike_roughness);
    VERTEX += NORMAL * n * spike_displacement;
}

void fragment() {
    float n_dot_v = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float fresnel = pow(1.0 - n_dot_v, fresnel_power);
    float core = pow(n_dot_v, core_size);

    // Mix colors normally so they don't blow out to white
    vec3 base_rgb = mix(glow_color.rgb, inner_color.rgb, core);

    ALBEDO = base_rgb;
    // Apply intensity ONLY to the rim emission
    EMISSION = base_rgb * (fresnel * glow_intensity + core);
    ALPHA = clamp(fresnel + core, 0.0, 1.0) * overall_alpha;
}