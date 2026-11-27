shader_type canvas_item;
render_mode unshaded;
uniform vec3 levels = vec3(0.03137255);
void fragment() {
	vec4 mask = texture(TEXTURE, UV);
	COLOR = vec4(0.0, 0.0, dot(mask.rgb, levels), mask.a);
}
