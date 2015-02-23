uniform sampler2D blurMap;
uniform float blurSize;
 
void main(void)
{
   float sum = 0;
 
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y - 4.0*blurSize)).r * 0.05;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y - 3.0*blurSize)).r * 0.09;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y - 2.0*blurSize)).r * 0.12;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y - blurSize)).r * 0.15;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y)).r * 0.16;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y + blurSize)).r * 0.15;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y + 2.0*blurSize)).r * 0.12;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y + 3.0*blurSize)).r * 0.09;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y + 4.0*blurSize)).r * 0.05;
 
   gl_FragColor.r = sum;
}