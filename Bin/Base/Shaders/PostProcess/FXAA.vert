uniform vec2 screenSize;

varying vec4 posPos;

#define FXAA_SUBPIX_SHIFT (1.0/4.0)

void main(void)
{
  gl_Position = ftransform();
  gl_TexCoord[0] = gl_MultiTexCoord0;
  
  vec2 rcpFrame = vec2(1.0/screenSize.x, 1.0/screenSize.y);
  posPos.xy = gl_MultiTexCoord0.xy;
  posPos.zw = gl_MultiTexCoord0.xy - (rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT));
}