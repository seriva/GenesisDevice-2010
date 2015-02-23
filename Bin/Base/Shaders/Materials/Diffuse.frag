uniform sampler2D texture0, texture1;
uniform vec3 glowColor;
uniform float alpha;

varying vec3 pos, normal;

void main(void)
{
	vec4 color = texture2D(texture0, gl_TexCoord[0].st);
	if (color.a < alpha) discard;
	gl_FragData[0].rgb = color.rgb;
	gl_FragData[1].rgb = pos;
	gl_FragData[2].rgb = normal;
	gl_FragData[3].rgb = texture2D(texture1, gl_TexCoord[0].st).rgb * glowColor;
}