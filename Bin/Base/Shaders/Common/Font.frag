uniform sampler2D texture0;
uniform vec4 color;

void main(void)
{
	gl_FragColor = texture2D(texture0, gl_TexCoord[0].xy) * color;
}