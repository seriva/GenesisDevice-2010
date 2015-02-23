uniform sampler2D texture0, texture1, texture2;
uniform vec3 glowColor;
uniform float alpha;

varying vec3 pos;
varying vec3 norm;

mat3 computeTangentFrame(vec3 normal, vec3 position, vec2 texCoord)
{
	vec3 dpx = dFdx(position);
    vec3 dpy = dFdy(position);
    vec2 dtx = dFdx(texCoord);
    vec2 dty = dFdy(texCoord);
    vec3 tangent  = normalize(dpy * dtx.t - dpx * dty.t);
    vec3 binormal = cross(tangent, normal);
	return mat3(tangent.x, binormal.x, normal.x,
				tangent.y, binormal.y, normal.y,
				tangent.z, binormal.z, normal.z);
}

void main(void)
{
	vec4 color = texture2D(texture0, gl_TexCoord[0].st);
	if (color.a < alpha) discard;
	gl_FragData[0].rgb = color.rgb;
	gl_FragData[1].rgb = pos;
	
	mat3 tbnMatrix = computeTangentFrame( normalize(norm), normalize(pos), gl_TexCoord[0].st);
	vec4 norm1 	   = texture2D(texture1, gl_TexCoord[0].st);
	vec3 norm2 	   = normalize(2.0 * norm1.rgb - 1.0);
	vec3 norm3	   = norm2 * tbnMatrix; 
	
	gl_FragData[2].rgb = normalize(norm3) * 0.5 + 0.5;
	gl_FragData[3].rgb = texture2D(texture2, gl_TexCoord[0].st).rgb * glowColor;
}