#version 450

in vec2 tcoord;
in vec4 color;
in float tId;

uniform sampler2D tex[8];

out vec4 FragColor;

void main(void){
	vec4 texcolor;

	if(tId < 0.5) {
		texcolor = texture(tex[0], tcoord);
	} else if(tId < 1.5) {
		texcolor = texture(tex[1], tcoord);
	} else if(tId < 2.5) {
		texcolor = texture(tex[2], tcoord);
	} else if(tId < 3.5) {
		texcolor = texture(tex[3], tcoord);
	} else if(tId < 4.5) {
		texcolor = texture(tex[4], tcoord);
	} else if(tId < 5.5) {
		texcolor = texture(tex[5], tcoord);
	} else if(tId < 6.5) {
		texcolor = texture(tex[6], tcoord);
	} else {
		texcolor = texture(tex[7], tcoord);
	}

	texcolor *= color;
	texcolor.rgb *= color.a;

	FragColor = texcolor;
}