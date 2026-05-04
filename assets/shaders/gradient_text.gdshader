shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 cor_topo = vec3(1.0, 0.85, 0.85);
	vec3 cor_base = vec3(0.75, 0.0, 0.2);
	vec3 gradiente = mix(cor_topo, cor_base, UV.y);
	COLOR = vec4(gradiente, tex.a);
}
