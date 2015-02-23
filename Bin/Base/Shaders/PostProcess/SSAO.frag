#version 120

uniform sampler2D positionMap, normalMap, randomMap;
uniform vec2 screenSize;
uniform vec3 camPosition;
uniform float radius	= 0.65; //between 0.5 and 2.0 
uniform float intensity	= 2.3;	//3
uniform float scale 	= 1.0;	//between 1.0 and 2.0;
uniform float bias 		= 0.05; //0.05
uniform float min 		= 1;

float randomSize = 64;

vec3 getPosition(in vec2 uv)
{
	return texture2D(positionMap, uv).xyz;
}

vec3 getNormal(in vec2 uv)
{
	return normalize(texture2D(normalMap, uv).xyz * 2.0 - 1.0);
}

vec2 getRandom(in vec2 uv)
{
	return normalize( texture2D(randomMap, screenSize * uv / randomSize).xy * 2.0 - 1.0);
}

float doAmbientOcclusion(in vec2 tc, in vec2 uv, in vec3 pos, in vec3 norm)
{
	vec3 diff = getPosition(tc + uv) - pos;
	vec3 v    = normalize(diff);
	float d   = length(diff) * scale;
	return max(0.0, dot(norm, v) - bias) * ( 1.0/(1.0 + d) ) * intensity;
}

void main()
{
	vec2 vec[4] = vec2[](vec2(1,0), vec2(-1,0), vec2(0,1), vec2(0,-1));
	
	vec3 position = getPosition(gl_TexCoord[0].st);
	vec3 normal   = getNormal(gl_TexCoord[0].st);
	vec2 rand     = getRandom(gl_TexCoord[0].st);
	
	float ao = 0.0;
	float rad = radius / -position.z; //mayby this must be positive?

	const int iterations = 4;		
	for (int j = 0; j < iterations; ++j)
	{
		vec2 coord1 = reflect(vec[j],rand)*rad;
		vec2 coord2 = vec2(coord1.x*0.707 - coord1.y*0.707, coord1.x*0.707 + coord1.y*0.707);
		
		ao += doAmbientOcclusion(gl_TexCoord[0].st, coord1*0.25, position, normal);
		ao += doAmbientOcclusion(gl_TexCoord[0].st, coord2*0.5,  position, normal);
		ao += doAmbientOcclusion(gl_TexCoord[0].st, coord1*0.75, position, normal);
		ao += doAmbientOcclusion(gl_TexCoord[0].st, coord2,      position, normal);		
	} 
	
	ao /= iterations * 4.0;

	float result = 0;
	float l = length(position-camPosition);
	if(l < min)
	{
		result = 1 - (ao * (l/min));
	}	
	else
	{
		result = 1-ao;
	}
	
	gl_FragColor = vec4(result, result, result, 1);
}