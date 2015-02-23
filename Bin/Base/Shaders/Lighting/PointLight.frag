uniform sampler2D positionMap, normalMap, shadowMap;
uniform vec3  lightPosition, lightDiffuse;
uniform float lightRadius, lightIntensity;
uniform int hasShadow;

void main(void)
{
	vec3 pos = texture2DProj(positionMap, gl_TexCoord[0]).xyz;
	vec3 lightDir = lightPosition - pos;
	
	float dist = length(lightDir);
	if (dist > lightRadius)
		discard;
	
	vec3 n = normalize(texture2DProj(normalMap, gl_TexCoord[0]).xyz * 2.0 - 1.0);
	vec3 l = normalize(lightDir);
	
	vec3 lDir = lightDir/lightRadius;
	float atten = max(0.0, 1.0 - dot(lDir, lDir))*lightIntensity;
	float nDotL = max(0.0, dot(n, l));
	
	float shadow = 1.0; 
	if (hasShadow == 1)
	{
		shadow = texture2DProj(shadowMap, gl_TexCoord[0]).r;
	}	
	
	gl_FragColor.rgb = lightDiffuse * atten * nDotL * shadow;
}