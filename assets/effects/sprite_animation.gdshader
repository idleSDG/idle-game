shader_type canvas_item;

uniform vec4 overlay_color : source_color = vec4(1.0);
uniform float final_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float glow_power : hint_range(0.0, 10.0) = 1.0;
// Controls overall transparency of the TextureRect

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

    // Blend original texture with overlay color
    vec3 final_rgb = tex.rgb * overlay_color.rgb  * overlay_color.a;

    // Preserve texture alpha but allow global transparency control
    float alpha = tex.a * final_alpha;

    COLOR = vec4(COLOR.rgb * final_rgb * glow_power, alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
