uniform sampler2D positionMap;
uniform samplerCube shadowCube;
uniform vec3  lightPosition;

varying vec4 screenPos;

void main(void)
{
    vec2 coord 	= ((screenPos.xy/screenPos.w) * 0.5) + 0.5;
	vec3 pos 	= texture2D(positionMap, coord).xyz;
	
	vec3 lightDir = lightPosition-pos;
	float cubedepth = textureCube(shadowCube, -lightDir).x;
	if(cubedepth <  length(lightDir)) 
	{
		gl_FragColor.r = 0;
	}
	else
	{
		gl_FragColor.r = 1;
	}
}