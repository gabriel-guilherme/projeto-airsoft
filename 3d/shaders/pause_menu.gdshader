shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_size : hint_range(0.0, 10.0);
uniform vec4 tint_color; // sem inicialização aqui

void fragment() {
    vec4 sum = vec4(0.0);

    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * blur_size * 0.001;
            sum += texture(SCREEN_TEXTURE, SCREEN_UV + offset);
        }
    }

    vec4 blurred = sum / 25.0;

    // Mistura com a cor semi-transparente
    COLOR = mix(blurred, tint_color, tint_color.a);
}
