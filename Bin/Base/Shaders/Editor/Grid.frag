uniform sampler2D gridMap;
 
void main(void)
{
	vec4 color = texture2D(gridMap, gl_TexCoord[0].xy);
	
	if (color.r == 0.0 && color.g == 0.0 && color.b == 0.0)
		discard;
		
	gl_FragColor = color;
}