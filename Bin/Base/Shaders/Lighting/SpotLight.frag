uniform sampler2D positionMap, normalMap, shadowMap;
uniform vec3  lightPosition, lightDirection, lightDiffuse;
uniform float lightRadius, lightOuterAngle, lightInnerAngle, lightIntensity;
uniform int hasShadow;

void main(void)
{
	vec3 pos = texture2DProj(positionMap, gl_TexCoord[0]).xyz;
	vec3 lightDir = lightPosition - pos;
	
	float dist    = length(lightDir);
	vec3 l 		  = normalize(lightDir);
	float spotDot = dot(normalize(lightDirection), -l);
	
	if (dist > lightRadius || spotDot < lightOuterAngle)
		discard;
		
	vec3 n = normalize(texture2DProj(normalMap, gl_TexCoord[0]).xyz * 2.0 - 1.0);
	
	float atten = clamp((spotDot - lightOuterAngle) / (lightInnerAngle-lightOuterAngle), 0.0, 1.0);
	float nDotL = max(0.0, dot(n, l));
	
	float shadow = 1.0; 
	if (hasShadow == 1)
	{
		shadow = texture2DProj(shadowMap, gl_TexCoord[0]).r;
	}	
	
	gl_FragColor.rgb = lightDiffuse * atten * nDotL * shadow;
}