varying vec3 lightDir;

void main()
{
	gl_FragColor.r  = length(lightDir)+0.04;
}
