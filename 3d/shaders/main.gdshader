shader_type spatial;

uniform vec3 color1 : source_color = vec3(0.5, 0.5, 0.5);
uniform vec3 color2 : source_color = vec3(0.5, 0.5, 0.5);
uniform float scale = 1.0;

void fragment() {
    vec2 uv = UV * scale;
    int check = int(floor(uv.x) + floor(uv.y)) % 2;
    vec3 col = mix(color1, color2, float(check));
    ALBEDO = col;
}
