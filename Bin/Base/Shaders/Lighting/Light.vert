void main(void)
{
	vec4 pos = ftransform();
	gl_Position = pos;
	gl_TexCoord[0].s = (pos.x + pos.w) * 0.5;
	gl_TexCoord[0].t = (pos.y + pos.w) * 0.5;
	gl_TexCoord[0].q = pos.w;
}