#version 450

in vec2 vertexPosition;
in vec2 texPosition;

in vec4 vertexColor;
in mat4 mvpMatrix;
in vec2 texOffset;

out vec2 tcoord;
out vec4 color;

void main() {
	gl_Position =  mvpMatrix * vec4(vertexPosition, 0.0, 1.0);
	tcoord = texPosition + texOffset;
	color = vertexColor;
}
