uniform sampler2D blurMap;
uniform float blurSize;
 
void main(void)
{
   float sum = 0;
 
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x - 4.0*blurSize, gl_TexCoord[0].y)).r * 0.05;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x - 3.0*blurSize, gl_TexCoord[0].y)).r * 0.09;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x - 2.0*blurSize, gl_TexCoord[0].y)).r * 0.12;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x - blurSize, gl_TexCoord[0].y)).r * 0.15;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x, gl_TexCoord[0].y)).r * 0.16;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x + blurSize, gl_TexCoord[0].y)).r * 0.15;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x + 2.0*blurSize, gl_TexCoord[0].y)).r * 0.12;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x + 3.0*blurSize, gl_TexCoord[0].y)).r * 0.09;
   sum += texture2D(blurMap, vec2(gl_TexCoord[0].x + 4.0*blurSize, gl_TexCoord[0].y)).r * 0.05;
 
   gl_FragColor.r = sum;
}