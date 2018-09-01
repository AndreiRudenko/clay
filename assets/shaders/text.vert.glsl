#version 450

in vec2 a_position;
in vec2 a_texpos;
in vec4 a_color;

uniform mat3 u_mvpmatrix;

out vec2 tcoord;
out vec4 color;

void main() {
	gl_Position = vec4((u_mvpmatrix * vec3(a_position, 1.0)).xy, 0.0, 1.0);
	tcoord = a_texpos;
	color = a_color;
}
