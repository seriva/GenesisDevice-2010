varying vec3 pos;
varying vec3 norm;

void main(void)
{
	gl_TexCoord[0]	= gl_MultiTexCoord0;   
	gl_Position 	= ftransform();
	vec4 tmp 		= gl_ModelViewMatrix * gl_Vertex;
	pos 			= tmp.xyz/tmp.w;
	norm 			= normalize(gl_NormalMatrix * gl_Normal);
}