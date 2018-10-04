#version 450

in vec2 vertexPosition;

in vec4 vertexColor;
in mat4 m;

out vec4 fragmentColor;

void main() {
	gl_Position =  m * vec4(vertexPosition, 0.0, 1.0);
	fragmentColor = vertexColor;
}