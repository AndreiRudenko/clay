#version 450

in vec4 color;
out vec4 FragColor;

void main() {
	// FragColor = vec4(color.rgb * color.a, color.a);
	FragColor = color;
}
