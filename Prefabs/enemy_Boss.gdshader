
shader_type canvas_item;

// Intensidade do flash (0.0 a 1.0)
uniform float flash_intensity : hint_range(0, 1) = 0.0;

// Cor do flash (RGB)
uniform vec3 flash_color : source_color = vec3(0.5, 0.0, 0.0);

// Textura original
uniform sampler2D original_texture;

void fragment() {
    // Cor original do sprite
    vec4 original = texture(TEXTURE, UV);
    
    if (flash_intensity > 0.0) {
        // Mistura com cor de flash
        vec3 flash_mix = mix(original.rgb, flash_color, flash_intensity * 0.8);
        
        // Mantém transparência original
        COLOR = vec4(flash_mix, original.a);
    } else {
        // Retorna cor normal
        COLOR = original;
    }
}