#version 450

in vec2 vertexPosition;
in vec4 vertexColor;

uniform mat3 mvpMatrix;

out vec4 fragmentColor;

void main() {
	gl_Position = vec4((mvpMatrix * vec3(vertexPosition, 1.0)).xy, 0.0, 1.0);
	fragmentColor = vertexColor;
}