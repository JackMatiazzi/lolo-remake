shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// 0.0 = Acordado (Olho aberto) | 1.0 = Dormindo (Olho fechado)
uniform float factor : hint_range(0.0, 1.0) = 0.0;
uniform vec3 cor_branca_olho : source_color = vec3(0.95, 0.95, 0.95);

void fragment() {
    vec3 cor_base = COLOR.rgb;
    
    // Onde COLOR.a for 1.0 (máscara do olho), aplica o branco.
    // Onde COLOR.a for 0.0 (corpo e pupila), mantém a cor original.
    vec3 olho_aberto = mix(cor_base, cor_branca_olho, COLOR.a);
    
    // Alterna entre olho aberto (0.0) e olho fechado (1.0)
    ALBEDO = mix(olho_aberto, cor_base, factor);
}