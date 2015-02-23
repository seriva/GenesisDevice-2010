uniform sampler2D lightMap;
 
void main(void)
{
	gl_FragColor = texture2D(lightMap, gl_TexCoord[0].xy);
}