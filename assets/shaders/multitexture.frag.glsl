#version 450

in vec2 tcoord;
in vec4 color;
in float tId;

uniform sampler2D tex[8];

out vec4 FragColor;

void main(void){
	vec4 texcolor;

	if(tId < 0.5) {
		texcolor = vec4(color.rgb, texture(tex[0], tcoord).r * color.a);
	} else if(tId < 1.5) {
		texcolor = vec4(color.rgb, texture(tex[1], tcoord).r * color.a);
	} else if(tId < 2.5) {
		texcolor = vec4(color.rgb, texture(tex[2], tcoord).r * color.a);
	} else if(tId < 3.5) {
		texcolor = vec4(color.rgb, texture(tex[3], tcoord).r * color.a);
	} else if(tId < 4.5) {
		texcolor = vec4(color.rgb, texture(tex[4], tcoord).r * color.a);
	} else if(tId < 5.5) {
		texcolor = vec4(color.rgb, texture(tex[5], tcoord).r * color.a);
	} else if(tId < 6.5) {
		texcolor = vec4(color.rgb, texture(tex[6], tcoord).r * color.a);
	} else {
		texcolor = vec4(color.rgb, texture(tex[7], tcoord).r * color.a);
	}

	FragColor = texcolor;
}