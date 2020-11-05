#version 450

in vec2 tcoord;
in vec4 color;
in float tId;

uniform sampler2D tex[32];

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
	} else if(tId < 15.5) {
		texcolor = vec4(color.rgb, texture(tex[15], tcoord).r * color.a);
	} else if(tId < 16.5) {
		texcolor = vec4(color.rgb, texture(tex[16], tcoord).r * color.a);
	} else if(tId < 17.5) {
		texcolor = vec4(color.rgb, texture(tex[17], tcoord).r * color.a);
	} else if(tId < 18.5) {
		texcolor = vec4(color.rgb, texture(tex[18], tcoord).r * color.a);
	} else if(tId < 19.5) {
		texcolor = vec4(color.rgb, texture(tex[19], tcoord).r * color.a);
	} else if(tId < 20.5) {
		texcolor = vec4(color.rgb, texture(tex[20], tcoord).r * color.a);
	} else if(tId < 21.5) {
		texcolor = vec4(color.rgb, texture(tex[21], tcoord).r * color.a);
	} else if(tId < 22.5) {
		texcolor = vec4(color.rgb, texture(tex[22], tcoord).r * color.a);
	} else if(tId < 23.5) {
		texcolor = vec4(color.rgb, texture(tex[23], tcoord).r * color.a);
	} else if(tId < 24.5) {
		texcolor = vec4(color.rgb, texture(tex[24], tcoord).r * color.a);
	} else if(tId < 25.5) {
		texcolor = vec4(color.rgb, texture(tex[25], tcoord).r * color.a);
	} else if(tId < 26.5) {
		texcolor = vec4(color.rgb, texture(tex[26], tcoord).r * color.a);
	} else if(tId < 27.5) {
		texcolor = vec4(color.rgb, texture(tex[27], tcoord).r * color.a);
	} else if(tId < 28.5) {
		texcolor = vec4(color.rgb, texture(tex[28], tcoord).r * color.a);
	} else if(tId < 29.5) {
		texcolor = vec4(color.rgb, texture(tex[29], tcoord).r * color.a);
	} else if(tId < 30.5) {
		texcolor = vec4(color.rgb, texture(tex[30], tcoord).r * color.a);
	} else {
		texcolor = vec4(color.rgb, texture(tex[31], tcoord).r * color.a);
	}

	FragColor = texcolor;
}