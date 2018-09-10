#version 450

in vec2 vertexPosition;
in vec2 texPosition;
in vec4 vertexColor;

uniform mat3 mvpMatrix;

out vec2 tcoord;
out vec4 color;

void main() {
	gl_Position = vec4((mvpMatrix * vec3(vertexPosition, 1.0)).xy, 0.0, 1.0);
	tcoord = texPosition;
	color = vertexColor;
}
