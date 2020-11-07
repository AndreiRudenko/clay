#version 450

in vec4 outColor;
in vec2 outTexCoord;
in float outTexId;
in float outTexFormat;

uniform sampler2D tex[8];

out vec4 FragColor;

void main(){
	vec4 texColor;

	if(outTexId < 0.5) {
		texColor = texture(tex[0], outTexCoord);
	} else if(outTexId < 1.5) {
		texColor = texture(tex[1], outTexCoord);
	} else if(outTexId < 2.5) {
		texColor = texture(tex[2], outTexCoord);
	} else if(outTexId < 3.5) {
		texColor = texture(tex[3], outTexCoord);
	} else if(outTexId < 4.5) {
		texColor = texture(tex[4], outTexCoord);
	} else if(outTexId < 5.5) {
		texColor = texture(tex[5], outTexCoord);
	} else if(outTexId < 6.5) {
		texColor = texture(tex[6], outTexCoord);
	} else {
		texColor = texture(tex[7], outTexCoord);
	}

	if(outTexFormat < 0.5) { //RGBA32
		texColor *= outColor;
		texColor.rgb *= outColor.a;
	} else if(outTexFormat < 1.5) { //L8
		texColor = texColor.rrrr * outColor;
	}

	FragColor = texColor;
}