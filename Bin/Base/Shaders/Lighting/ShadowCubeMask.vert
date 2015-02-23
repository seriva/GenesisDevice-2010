varying vec4 screenPos;

void main(void)
{
	vec4 pos 	= ftransform();
	gl_Position = pos;
	screenPos 	= pos;
}