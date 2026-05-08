shader_type canvas_item;

uniform sampler2D wood_texture : repeat_enable, filter_nearest;
uniform float scale = 2.0;

void fragment() {
    vec2 scaled_uv = UV * scale;
    COLOR = texture(wood_texture, scaled_uv);
}