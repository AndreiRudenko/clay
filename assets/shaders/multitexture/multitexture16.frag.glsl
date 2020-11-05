#version 450

in vec2 tcoord;
in vec4 color;
in float tId;

uniform sampler2D tex[16];

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
	} else if(tId < 7.5) {
		texcolor = vec4(color.rgb, texture(tex[7], tcoord).r * color.a);
	} else if(tId < 8.5) {
		texcolor = vec4(color.rgb, texture(tex[8], tcoord).r * color.a);
	} else if(tId < 9.5) {
		texcolor = vec4(color.rgb, texture(tex[9], tcoord).r * color.a);
	} else if(tId < 10.5) {
		texcolor = vec4(color.rgb, texture(tex[10], tcoord).r * color.a);
	} else if(tId < 11.5) {
		texcolor = vec4(color.rgb, texture(tex[11], tcoord).r * color.a);
	} else if(tId < 12.5) {
		texcolor = vec4(color.rgb, texture(tex[12], tcoord).r * color.a);
	} else if(tId < 13.5) {
		texcolor = vec4(color.rgb, texture(tex[13], tcoord).r * color.a);
	} else if(tId < 14.5) {
		texcolor = vec4(color.rgb, texture(tex[14], tcoord).r * color.a);
	} else {
		texcolor = vec4(color.rgb, texture(tex[15], tcoord).r * color.a);
	}

	FragColor = texcolor;
}