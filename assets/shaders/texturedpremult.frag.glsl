#version 450

in vec2 tcoord;
in vec4 color;

uniform sampler2D tex;

out vec4 FragColor;

void main() {
	vec4 texcolor = texture(tex, tcoord) * color;
	texcolor.rgb *= color.a;
	FragColor = texcolor;
}
