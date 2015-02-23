uniform sampler2D copyMap;
 
void main(void)
{
   gl_FragColor = texture2D(copyMap, gl_TexCoord[0].xy);
}