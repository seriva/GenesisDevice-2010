uniform sampler2D colorMap, lightMap, ssaoMap, glowMap, glowBlurMap;

void main(void)
{ 
	vec4 color 		= texture2D(colorMap,gl_TexCoord[0].st);
	vec4 light 		= texture2D(lightMap,gl_TexCoord[0].st);
	vec4 ssao  		= texture2D(ssaoMap,gl_TexCoord[0].st);
	vec4 glow  		= texture2D(glowMap,gl_TexCoord[0].st);
	vec4 glowBlur  	= texture2D(glowBlurMap,gl_TexCoord[0].st);
	gl_FragColor	= (color * light * ssao) + (glow + glowBlur); 
}