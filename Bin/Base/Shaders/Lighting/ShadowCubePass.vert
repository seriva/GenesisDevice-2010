uniform vec3  lightPosition;
uniform float lightRadius;

varying vec3 lightDir;

void main()
{
    gl_Position = ftransform();
	lightDir    = lightPosition - vec3(gl_ModelViewMatrix * gl_Vertex);
}