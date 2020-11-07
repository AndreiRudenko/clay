#version 450

in vec2 position;
in vec4 color;

uniform mat3 projectionMatrix;

out vec4 outColor;

void main() {
	gl_Position = vec4((projectionMatrix * vec3(position, 1.0)).xy, 0.0, 1.0);
	outColor = color;
}
