#version 450

in vec2 tcoord;
in vec4 color;

uniform sampler2D tex;

out vec4 FragColor;

void main() {
	FragColor = vec4(color.rgb, texture(tex, tcoord).r * color.a);
	// vec4 texcolor = texture(tex, tcoord) * color;
	// texcolor.rgb *= color.a;
	// FragColor = texcolor;
}
