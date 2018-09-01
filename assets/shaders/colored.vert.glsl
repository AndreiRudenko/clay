#version 450

in vec2 a_position;
in vec4 a_color;

uniform mat3 u_mvpmatrix;

out vec4 v_color;

void main() {
	gl_Position = vec4((u_mvpmatrix * vec3(a_position, 1.0)).xy, 0.0, 1.0);
	v_color = a_color;
}