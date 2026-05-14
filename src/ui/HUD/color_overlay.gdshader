shader_type canvas_item;

uniform vec4 overlay_color : source_color = vec4(0.0, 0.0, 0.0, 1);
// RGB = overlay color
// A = overlay strength
uniform float final_alpha : hint_range(0.0, 1.0) = 0.35;
// Controls overall transparency of the TextureRect

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Blend original texture with overlay color
    vec3 final_rgb = mix(tex.rgb, overlay_color.rgb, overlay_color.a);

    // Preserve texture alpha but allow global transparency control
    float alpha = tex.a * final_alpha;

    COLOR = vec4(final_rgb, alpha);
}