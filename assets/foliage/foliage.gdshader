shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D gradient_texture : hint_default_white;
uniform sampler2D vertical_gradient : hint_default_white;
uniform sampler2D clip_texture : hint_default_white;
uniform float clip_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float emission_strength : hint_range(0.0, 10.0) = 1.0;

varying vec3 vertex_pos;
varying vec2 uv_coords;

void vertex() {
	// Pass vertex position and UVs to fragment shader
	vertex_pos = VERTEX;
	uv_coords = UV;
}

void fragment() {
	// Sample the clip texture
	vec4 clip_sample = texture(clip_texture, UV);
	
	// Use the grayscale value (average of RGB or just red channel)
	float clip_value = clip_sample.r; // For B&W textures, r = g = b
	
	// Discard pixels below the threshold
	if (clip_value < clip_threshold) {
		discard;
	}
	
	// Sample the 2D gradient texture using the full UV coordinates
	vec4 radial_color = texture(gradient_texture, uv_coords);
	
	// Sample the 1D vertical gradient using the flipped V coordinate
	vec4 vertical_color = texture(vertical_gradient, vec2(1.0 - uv_coords.y, 0.5));
	
	// Multiply the two gradients together
	vec4 final_color = radial_color * vertical_color;
	
	ALBEDO = vec3(0.0);
	EMISSION = final_color.rgb * emission_strength;
	ALPHA = final_color.a;
}