#version 450

in vec4 outColor;
in vec2 outTexCoord;

uniform sampler2D tex;

out vec4 FragColor;

void main() {
	vec4 texColor = texture(tex, outTexCoord) * outColor;
	texColor.rgb *= outColor.a;
	FragColor = texColor;
}
