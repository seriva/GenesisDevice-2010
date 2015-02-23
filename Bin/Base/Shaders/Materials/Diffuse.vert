varying vec3 pos, normal;

void main(void)
{
	gl_TexCoord[0]	= gl_MultiTexCoord0;   
	gl_Position 	= ftransform();
	vec4 tmp 		= gl_ModelViewMatrix * gl_Vertex;
	pos 			= tmp.xyz/tmp.w;
	normal 			= (normalize(gl_NormalMatrix * gl_Normal)/2)+0.5;
}