 shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

// Tip: This sets the default blur strenght
uniform float blur_strength : hint_range(0.0, 5.0, 0.1) = 2.5;

void fragment() {
	vec4 panel_color = COLOR;
	
	vec3 blurred_background = textureLod(
		screen_texture, 
		SCREEN_UV, 
		blur_strength
	).rgb;
	
	COLOR.rgb = mix(
		blurred_background,
		panel_color.rgb,
		panel_color.a
	);
}