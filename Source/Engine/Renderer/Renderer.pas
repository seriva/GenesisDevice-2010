{*******************************************************************************
*                            Genesis Device Engine                             *
*                   Copyright © 2007-2015 Luuk van Venrooij                    *
*                        http://www.luukvanvenrooij.nl                         *
********************************************************************************
*                                                                              *
*  This file is part of the Genesis Device Engine.                             *
*                                                                              *
*  The Genesis Device Engine is free software: you can redistribute            *
*  it and/or modify it under the terms of the GNU Lesser General Public        *
*  License as published by the Free Software Foundation, either version 3      *
*  of the License, or any later version.                                       *
*                                                                              *
*  The Genesis Device Engine is distributed in the hope that                   *
*  it will be useful, but WITHOUT ANY WARRANTY; without even the               *
*  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    *
*  See the GNU Lesser General Public License for more details.                 *
*                                                                              *
*  You should have received a copy of the GNU General Public License           *
*  along with Genesis Device.  If not, see <http://www.gnu.org/licenses/>.     *
*                                                                              *
*******************************************************************************}
unit Renderer;

{$MODE Delphi}

interface

uses
  SysUtils,
  Windows,
  Context,
  Mathematics,
  Console,
  Texture,
  Resource,
  Scene,
  Math,
  SBuffer,
  ShaderProgram,
  dglOpenGL;

type
  TRenderer = class
  private
    FResourceWindow : HWND;
    FSolidSphere    : GLuint;
    FWireSphere     : GLuint;
    FSolidCone      : GLuint;
    FWireCone       : GLuint;
    FScreenQuad     : GLuint;

    procedure BlurTexture(const aTexture : TTexture);
    procedure CopyTexture(const aFrom, aTo : TTexture);
    procedure InitShaderPrograms();
    procedure ClearShaders();
    procedure InitTextures();
    procedure ClearTextures();
  public
    //resource context
    ResourceContext  : TContext;

    //shadow base buffers
    ShadowBaseMaps : array[0..7] of TTexture;

    //info
    Vendor                 : String;

    //shaders
    //common shaders
    ColorShader            : TShaderProgram;
    CopyShader             : TShaderProgram;
    FontShader             : TShaderProgram;

    //light shaders
    PointLightShader       : TShaderProgram;
    SpotLightShader        : TShaderProgram;
    DirectionalLightShader : TShaderProgram;
    ShadowCubePassShader   : TShaderProgram;
    ShadowCubeMaskShader   : TShaderProgram;

    //post process shaders
    GlowShader             : TShaderProgram;
    SSAOShader             : TShaderProgram;
    FXAAShader             : TShaderProgram;
    BlurHorShader          : TShaderProgram;
    BlurVerTShaderProgram  : TShaderProgram;
    FinalPassShader        : TShaderProgram;

    //some global textures
    RandomMap : TTexture;
    WhiteMap  : TTexture;
    BlackMap  : TTexture;

    //debug
    ShowNormals      : Boolean;
    ShowTris         : Boolean;
    ShowMeshVolumes  : Boolean;
    ShowLightVolumes : Boolean;
    ShowBones        : Boolean;

    //rendering
    ShadowSize     : Integer;
    ShadowMinDist  : Integer;
    DoSSAO         : Boolean;
    SSAORadius     : Single;
    SSAOIntensity  : Single;
    SSAOScale      : Single;
    SSAOBias       : Single;
    SSAOMin        : Single;
    DoDiffuse      : Boolean;
    DoGlow         : Boolean;
    DoShadows      : Boolean;
    DoFXAA         : Boolean;

    constructor Create();
    destructor  Destroy(); override;

    procedure CheckErrors();

    procedure SetColor(const aR, aG, aB : Single); overload;
    procedure SetColor(const aR, aG, aB, aA : Single); overload;
    procedure SetColor(const aC : TVector3f); overload;
    procedure SetColor(const aC : TVector4f); overload;
    procedure RenderScreenQuad();
    procedure RenderBoundingBox(const aAABB : TBoundingBox; const aWireFrame : Boolean);
    procedure RenderBoundingSphere(const aSphere : TBoundingSphere; const aWireFrame : Boolean);
    procedure RenderCone( const aWireFrame : Boolean );
    procedure RenderScene(const aScene : TScene);
  end;

implementation

uses
  ModelEntity,
  AnimatedModelEntity,
  LightEntity,
  PointLightEntity,
  SpotLightEntity,
  GLSLLoader,
  Base;

constructor TRenderer.Create();
var
  iWndClass     : TWndClass;
  iDWStyle      : DWORD;
  iDWExStyle    : DWORD;
  iInstance     : HINST;
  iQuadric      : pGLUquadricObj;
  iI            : Integer;

function WndProc(aWnd: HWND; aMsg: UINT;  aWParam: WPARAM;  aLParam: LPARAM): LRESULT; stdcall;
begin
  Result := 1;
end;

begin
  inherited Create();
  Engine.Log.Print(self.ClassName, 'Initializing renderer...');

  //create resource window
  try
    iInstance := GetModuleHandle(nil);
    ZeroMemory(@iWndClass, SizeOf(wndClass));

    with iWndClass do
    begin
      style         := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
      lpfnWndProc   := @WndProc;
      hInstance     := iInstance;
      hCursor       := LoadCursor(0, IDC_ARROW);
      lpszClassName := 'OpenGL';
    end;

    if (RegisterClass(iWndClass) = 0) then
      Raise Exception.Create('Failed to register reource windows class');

    iDWStyle   := WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
    iDWExStyle := WS_EX_APPWINDOW or WS_EX_WINDOWEDGE;
    FResourceWindow := CreateWindowEx(iDWExStyle,
                                'OpenGL',
                                'Window',
                                iDWStyle,
                                0, 0,
                                50, 50,
                                0,
                                0,
                                iInstance,
                                nil);

    if FResourceWindow = 0 then
      Raise Exception.Create('Failed to create resource window');
  except
    on E: Exception do
    begin
      Engine.Log.Print(self.ClassName, E.Message, true);
    end;
  end;
  Engine.Log.Print(self.ClassName, 'Created resource window');

  //create the resource context
  ResourceContext := TContext.Create(FResourceWindow, 0, 0, false);
  Engine.Log.Print(self.ClassName, 'Created resource context');

  //get some renderer info
  Vendor := String(AnsiString(glGetString(GL_VENDOR)));
  Engine.Log.Print(self.ClassName, 'Vendor: ' + Vendor);
  Engine.Log.Print(self.ClassName, 'Renderer: ' + String(AnsiString(glGetString(GL_RENDERER))));
  Engine.Log.Print(self.ClassName, 'Version: ' + String(AnsiString(glGetString(GL_VERSION))));

  //debug
  ShowNormals      := false;
  ShowTris         := false;
  ShowMeshVolumes  := false;
  ShowLightVolumes := false;
  ShowBones        := false;

  //rendering
  ShadowSize     := 2048;
  ShadowMinDist  := 50;
  SSAORadius     := 0.65;
  SSAOIntensity  := 3.0;
  SSAOScale      := 1.0;
  SSAOBias       := 0.05;
  SSAOMin        := 4;
  DoSSAO         := true;
  DoDiffuse      := true;
  DoGlow         := true;
  DoShadows      := true;
  DoFXAA         := true;

  //register console commands
  Engine.Console.AddCommand( 'r_normals', 'Show or hide normals', CT_BOOLEAN, @ShowNormals );
  Engine.Console.AddCommand( 'r_tris', 'Show or hide wireframe',  CT_BOOLEAN, @ShowTris );
  Engine.Console.AddCommand( 'r_modelbv', 'Show or hide mesh and model bounding volumes',  CT_BOOLEAN, @ShowMeshVolumes );
  Engine.Console.AddCommand( 'r_lightbv', 'Show or hide light volumes', CT_BOOLEAN, @ShowLightVolumes );
  Engine.Console.AddCommand( 'r_bones', 'Show or hide model bones', CT_BOOLEAN, @ShowBones );
  Engine.Console.AddCommand( 'r_ssao', 'Enable or disable screen space ambient occlusion post proces pass', CT_BOOLEAN, @DoSSAO );
  Engine.Console.AddCommand( 'r_ssaorad', 'Set SSAO radius', CT_FLOAT, @SSAORadius );
  Engine.Console.AddCommand( 'r_ssaoint', 'Set SSAO intensity', CT_FLOAT, @SSAOIntensity );
  Engine.Console.AddCommand( 'r_ssaoscale', 'Set SSAO scale', CT_FLOAT, @SSAOScale );
  Engine.Console.AddCommand( 'r_ssaobias', 'Set SSAO bias', CT_FLOAT, @SSAOBias );
  Engine.Console.AddCommand( 'r_ssaomin', 'Set SSAO minimum distance', CT_FLOAT, @SSAOMin );
  Engine.Console.AddCommand( 'r_diffuse', 'Enable or disable diffuse pass', CT_BOOLEAN, @DoDiffuse );
  Engine.Console.AddCommand( 'r_glow', 'Enable or disable glow pass', CT_BOOLEAN, @DoGlow );
  Engine.Console.AddCommand( 'r_shadows', 'Enable or disable shadows', CT_BOOLEAN, @DoShadows );
  Engine.Console.AddCommand( 'r_fxaa', 'Enable or disable antialiasing', CT_BOOLEAN, @DoFXAA );

  //create some volumes for rendering
  //solid sphere
  iQuadric := gluNewQuadric();
	gluQuadricNormals(iQuadric, GLU_NONE);
	gluQuadricTexture(iQuadric,GLboolean(GLboolean(false)));
  gluQuadricDrawStyle( iQuadric,  GLU_FILL );
  FSolidSphere := glGenLists(1);
  glNewList(FSolidSphere,GL_COMPILE);
    gluSphere(iQuadric,1.0,16,16);
  glEndList();
  gluDeleteQuadric(iQuadric);

  //wire sphere
  iQuadric := gluNewQuadric();
  gluQuadricOrientation(iQuadric, GLU_OUTSIDE);
  gluQuadricTexture(iQuadric,GLboolean(GLboolean(false)));
  gluQuadricDrawStyle(iQuadric, GLU_LINE);
  FWireSphere := glGenLists(1);
  glNewList(FWireSphere,GL_COMPILE);
    gluSphere(iQuadric,1.0,16,16);
  glEndList();
  gluDeleteQuadric(iQuadric);

  //solid cone
  FSolidCone := glGenLists(1);
  glNewList(FSolidCone,GL_COMPILE);
    iQuadric := gluNewQuadric();
	  gluQuadricNormals(iQuadric, GLU_NONE);
	  gluQuadricTexture(iQuadric,GLboolean(GLboolean(false)));
    gluQuadricDrawStyle( iQuadric,  GLU_FILL );
    gluCylinder(iQuadric,0.0,1.0,1.0,50,1);
    gluDeleteQuadric(iQuadric);

    iQuadric := gluNewQuadric();
	  gluQuadricNormals(iQuadric, GLU_NONE);
	  gluQuadricTexture(iQuadric,GLboolean(GLboolean(false)));
    gluQuadricDrawStyle( iQuadric,  GLU_FILL );
    glPushMatrix();
      glTranslatef(0, 0, 1);
      gluDisk(iQuadric,0,1,50,1);
    glPopMatrix();
    gluDeleteQuadric(iQuadric);
  glEndList();

  //wire cone
  FWireCone := glGenLists(1);
  glNewList(FWireCone,GL_COMPILE);
    iQuadric := gluNewQuadric();
    gluQuadricOrientation(iQuadric, GLU_OUTSIDE);
    gluQuadricTexture(iQuadric,GLboolean(GLboolean(false)));
    gluQuadricDrawStyle(iQuadric, GLU_LINE);
    gluCylinder(iQuadric,0.0,1.0,1.0,16,1);
    gluDeleteQuadric(iQuadric);
  glEndList();

  //screen quad
  FScreenQuad := glGenLists(1);
  glNewList(FScreenQuad,GL_COMPILE);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    glBegin(GL_QUADS);
      glTexCoord2f(0, 0);   glVertex2f(-1, -1);
      glTexCoord2f(1, 0);   glVertex2f( 1, -1);
      glTexCoord2f(1, 1);   glVertex2f( 1, 1);
      glTexCoord2f(0, 1);   glVertex2f(-1, 1);
    glEnd;

    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
  glEndList();

  //shadow base buffers
  ShadowBaseMaps[0] := TTexture.CreateRenderCubemap(ShadowSize, GL_LUMINANCE16F_ARB, GL_LUMINANCE, GL_FLOAT);
  ShadowBaseMaps[1] := TTexture.CreateRenderCubemap(ShadowSize, GL_LUMINANCE16F_ARB, GL_LUMINANCE, GL_FLOAT);
  for iI := 2 to 7 do
    ShadowBaseMaps[iI] := TTexture.CreateRenderTexture(ShadowSize, ShadowSize, GL_LUMINANCE16F_ARB, GL_LUMINANCE, GL_FLOAT);
  CheckErrors();


  //load shaders
  InitShaderPrograms();

  //load base textures
  InitTextures();

  //check for errors during creation
  CheckErrors();

  Engine.Log.Print(self.ClassName, 'Initialized renderer successful');
end;

destructor  TRenderer.Destroy();
var
  iInstance : HINST;
  iI        : Integer;
begin
  //clear shadow base buffers
  for iI := 0 to 7 do
    FreeAndNil(ShadowBaseMaps[iI]);

  //clear the shaders
  clearShaders();

  //clear textures
  ClearTextures();

  //clear basic resources
  glDeleteLists(FSolidSphere, 1);
  glDeleteLists(FWireSphere, 1);
  glDeleteLists(FSolidCone, 1);
  glDeleteLists(FWireCone, 1);
  glDeleteLists(FScreenQuad, 1);

  //clear the resource context
  FreeAndNil(ResourceContext);

  //destroy resource window
  try
    //destroy the window
    if ((FResourceWindow <> 0) and (not DestroyWindow(FResourceWindow))) then
      Raise Exception.Create('Failed to destroy window');

    iInstance := GetModuleHandle(nil);
    if (not UnRegisterClass('OpenGL', iInstance)) then
      Raise Exception.Create('Failed to unregister window class');
  except
    on E: Exception do
    begin
      Engine.Log.Print(self.ClassName, E.Message, true);
    end;
  end;

  Engine.Log.Print(self.ClassName, 'Destroyed Renderer successful');
  
  inherited Destroy();
end;

procedure TRenderer.CheckErrors();
var
 iError : Integer;
begin
  iError := glGetError();
  case iError of
    GL_NO_ERROR          : ;
    GL_INVALID_ENUM      : Engine.Log.Print(self.ClassName, 'Invalid operation found');
    GL_INVALID_VALUE     : Engine.Log.Print(self.ClassName, 'Invalid value found');
    GL_INVALID_OPERATION : Engine.Log.Print(self.ClassName, 'Stack overflow found');
    GL_STACK_OVERFLOW    : Engine.Log.Print(self.ClassName, 'Stack underflow found');
    GL_STACK_UNDERFLOW   : Engine.Log.Print(self.ClassName, 'Incomplete attachment');
    GL_OUT_OF_MEMORY     : Engine.Log.Print(self.ClassName, 'Stack out of memory');
    GL_TABLE_TOO_LARGE   : Engine.Log.Print(self.ClassName, 'Table too large');
  end;
end;

procedure TRenderer.IniTShaderPrograms();
begin
  //common shaders
  ColorShader            := LoadGLSLResource('Base\Shaders\Common\Color.glsl') as TShaderProgram;
  CopyShader             := LoadGLSLResource('Base\Shaders\Common\Copy.glsl') as TShaderProgram;
  FontShader             := LoadGLSLResource('Base\Shaders\Common\font.glsl') as TShaderProgram;

  //light shaders
  PointLightShader       := LoadGLSLResource('Base\Shaders\Lighting\PointLight.glsl') as TShaderProgram;
  SpotLightShader        := LoadGLSLResource('Base\Shaders\Lighting\SpotLight.glsl') as TShaderProgram;
  DirectionalLightShader := LoadGLSLResource('Base\Shaders\Lighting\DirectionalLight.glsl') as TShaderProgram;
  ShadowCubePassShader   := LoadGLSLResource('Base\Shaders\Lighting\ShadowCubePass.glsl') as TShaderProgram;
  ShadowCubeMaskShader   := LoadGLSLResource('Base\Shaders\Lighting\ShadowCubeMask.glsl') as TShaderProgram;

  //post process shaders
  GlowShader             := LoadGLSLResource('Base\Shaders\PostProcess\Glow.glsl') as TShaderProgram;
  SSAOShader             := LoadGLSLResource('Base\Shaders\PostProcess\SSAO.glsl') as TShaderProgram;
  FXAAShader             := LoadGLSLResource('Base\Shaders\PostProcess\FXAA.glsl') as TShaderProgram;
  BlurHorShader          := LoadGLSLResource('Base\Shaders\PostProcess\BlurHorizontal.glsl') as TShaderProgram;
  BlurVerTShaderProgram  := LoadGLSLResource('Base\Shaders\PostProcess\BlurVertical.glsl') as TShaderProgram;
  FinalPassShader        := LoadGLSLResource('Base\Shaders\PostProcess\FinalPass.glsl') as TShaderProgram;

  Engine.Log.Print(self.ClassName, 'Loaded base shaders successful');
end;

procedure TRenderer.ClearShaders();
begin
  //common shaders
  FreeAndNil(ColorShader);
  FreeAndNil(CopyShader);
  FreeAndNil(FontShader);

  //light shaders
  FreeAndNil(PointLightShader);
  FreeAndNil(SpotLightShader);
  FreeAndNil(DirectionalLightShader);
  FreeAndNil(ShadowCubePassShader);
  FreeAndNil(ShadowCubeMaskShader);

  //post process shaders
  FreeAndNil(GlowShader);
  FreeAndNil(SSAOShader);
  FreeAndNil(FXAAShader);
  FreeAndNil(BlurHorShader);
  FreeAndNil(BlurVerTShaderProgram);
  FreeAndNil(FinalPassShader);
end;

procedure TRenderer.InitTextures();
begin
  RandomMap := Engine.Resources.Load('Base\Textures\noise.dds') as TTexture;
  WhiteMap  := Engine.Resources.Load('Base\Textures\white.dds') as TTexture;
  BlackMap  := Engine.Resources.Load('Base\Textures\black.dds') as TTexture;
  Engine.Log.Print(self.ClassName, 'Loaded base textures successful');
end;

procedure TRenderer.ClearTextures();
begin
  Engine.Resources.Remove( TResource(RandomMap) );
  Engine.Resources.Remove( TResource(WhiteMap) );
  Engine.Resources.Remove( TResource(BlackMap) );;
end;

procedure TRenderer.RenderBoundingBox(const aAABB : TBoundingBox; const aWireFrame : Boolean);
begin
  With aAABB do
  begin
    if aWireFrame then
    begin
      glBegin(GL_LINE_LOOP);
        glVertex3f(min.x, max.y, min.z);
        glVertex3f(min.x, max.y, max.z);
        glVertex3f(max.x, max.y, max.z);
        glVertex3f(max.x, max.y, min.z);
        glVertex3f(max.x, min.y, min.z);
        glVertex3f(max.x, min.y, max.z);
        glVertex3f(min.x, min.y, max.z);
        glVertex3f(min.x, min.y, min.z);
      glEnd();
      glBegin(GL_LINES);
        glVertex3f(min.x, min.y, max.z);
        glVertex3f(min.x, max.y, max.z);
        glVertex3f(max.x, min.y, max.z);
        glVertex3f(max.x, max.y, max.z);
        glVertex3f(min.x, min.y, min.z);
        glVertex3f(max.x, min.y, min.z);
        glVertex3f(min.x, max.y, min.z);
        glVertex3f(max.x, max.y, min.z);
      glEnd();
    end
    else
    begin

    end;
  end;
end;

procedure TRenderer.RenderBoundingSphere(const aSphere : TBoundingSphere;  const aWireFrame : Boolean);
begin
  glPushMatrix();
    glTranslatef(aSphere.center.x, aSphere.center.y, aSphere.center.z);
    glRotatef(90,1,0,0);
    glScalef(aSphere.radius, aSphere.radius, aSphere.radius);
    if aWireFrame then
      glCallList(FWireSphere)
    else
      glCallList(FSolidSphere);
  glPopMatrix();
end;

procedure TRenderer.RenderCone(const aWireFrame : Boolean );
begin
  glPushMatrix();
    glScalef(1, 1, -1);
    if aWireFrame then
      glCallList(FWireCone)
    else
      glCallList(FSolidCone);
  glPopMatrix();
end;

procedure TRenderer.RenderScreenQuad();
begin
  glCallList(FScreenQuad);
end;

procedure TRenderer.BlurTexture(const aTexture : TTexture);
begin
  With Engine.CurrentContext do
  begin
    //horizontal blur
    GBuffer.PostFrameBuffer.AttachRenderTexture(GBuffer.BlurShadowMap,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D);
    GBuffer.PostFrameBuffer.Status();
    aTexture.Bind(0);
    BlurHorShader.Bind();
    BlurHorShader.SetInt('blurMap', 0);
    BlurHorShader.SetFloat('blurSize', 1 / (Width div 2));
    glCallList(FScreenQuad);
    BlurHorShader.Unbind();

    //vertical blur
    GBuffer.PostFrameBuffer.AttachRenderTexture(aTexture,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D);
    GBuffer.PostFrameBuffer.Status();
    GBuffer.BlurShadowMap.Bind(0);
    BlurVerTShaderProgram.Bind();
    BlurVerTShaderProgram.SetInt('blurMap', 0);
    BlurVerTShaderProgram.SetFloat('blurSize', 1 / (Height div 2));
    glCallList(FScreenQuad);
    BlurVerTShaderProgram.Unbind();
  end;
end;

procedure TRenderer.CopyTexture(const aFrom, aTo : TTexture);
begin
  With Engine.CurrentContext do
  begin
    //horizontal blur
    GBuffer.PostFrameBuffer.AttachRenderTexture(aTo,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D);
    GBuffer.PostFrameBuffer.Status();
    aFrom.Bind(0);
    CopyShader.Bind();
    CopyShader.SetInt('copyMap', 0);
    glCallList(FScreenQuad);
    CopyShader.Unbind();
    aFrom.Unbind();
  end;
end;

procedure TRenderer.SetColor(const aR, aG, aB : Single);
begin
  ColorShader.Bind();
  ColorShader.SetFloat4('color', aR, aG, aB, 1);
end;

procedure TRenderer.SetColor(const aR, aG, aB, aA : Single);
begin
  ColorShader.Bind();
  ColorShader.SetFloat4('color', aR, aG, aB, aA);
end;

procedure TRenderer.SetColor(const aC : TVector3f);
begin
  ColorShader.Bind();
  ColorShader.SetFloat4('color', aC.x, aC.y, aC.z, 1);
end;

procedure TRenderer.SetColor(const aC : TVector4f);
begin
  ColorShader.Bind();
  ColorShader.SetFloat4('color', aC[0], aC[1], aC[2], aC[3]);
end;

procedure TRenderer.RenderScene(const aScene : TScene);

//fills the gbuffer
procedure GBufferPass();
var
  iI : Integer;
begin
  With Engine.CurrentContext do
  begin
    //set some states
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GLboolean(GLboolean(TRUE))); { *Converted from glDepthMask* } { *Converted from glDepthMask* }

    //bind and clear the deferred framebuffer
    GBuffer.FrameBuffer.Bind();
    glViewport(0, 0, Width, Height);
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    //render the visible scene
    with aScene.VisibleEntities do
    begin
      //render the basic scene
      for iI := 0 to Models.Count-1 do
      begin
        Engine.Stats.IncTris((Models.Get(iI) as TModelEntity).TrisCount);
        (Models.Get(iI) as TModelEntity).Render(true, false);
      end;
    end;

    //unbind the framebuffer and shaders
    GBuffer.FrameBuffer.UnBind();
  end;
end;

//updates the shadows
procedure ShadowPass();
var
  iQueryData : TSceneQueryData;

procedure UpdatePointLights();
var
  iI : Integer;

procedure UpdatePointLightShadow(const aPointLight : TPointLightEntity);
var
  iI, iJ : Integer;
  iLength : Double;
  iPos : TVector3f;
  iShadowBuffer : TShadow;
begin
  //if we dont cast shadows then exit.
  if aPointLight.CastShadows = false then exit;

  //reset the current shadow buffer
  aPointLight.ShadowBuffer := nil;

  //if the lightsource is to far away then stop the update
  iLength := ( aPointLight.GetPosition() - Engine.CurrentCamera.GetPosition()).Length();
  if iLength > ShadowMinDist then exit;

  //get an available shadow cube.
  iShadowBuffer := Engine.CurrentContext.SBuffer.GetShadowBuffer(ST_POINTSHADOW);

  //if we dont have a free buffer skip the shadowmap
  if iShadowBuffer = nil then exit;

  //set the shadowbuffer for the light
  aPointLight.ShadowBuffer := iShadowBuffer;

  //query the data in range of the light
  aScene.EntitiesIntersectSphere( aPointLight.BoundingSphere, iQueryData, SQD_MODELS );

  //update the shadowcube.
	glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  gluPerspective(90,1,0.1,aPointLight.Radius);
  iPos := aPointLight.GetPosition();

  for iI := 0 to 5 do begin
    //bind the shadow texture to the shadow blur framebuffer
    with Engine.CurrentContext do
    begin
      iShadowBuffer.ShadowCubeFrameBuffers[iI].Bind();
      glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
	    glMatrixMode(GL_PROJECTION);
      glPushMatrix();
      case iI of
      0:
        begin
              glRotatef(180, 0, 0, 1);
              glRotatef(90, 0, 1, 0);
        end;
      1:
        begin
              glRotatef(180, 0, 0, 1);
              glRotatef(-90, 0, 1, 0);
        end;
      2: glRotatef(-90,1,0,0);
      3: glRotatef( 90,1,0,0);
      4: glRotatef(180,1,0,0);
      5: glRotatef(180,0,0,1);
      end;
      glTranslatef(-iPos.xyz[0],-iPos.xyz[1],-iPos.xyz[2]);
      glMatrixMode(GL_MODELVIEW);
      ShadowCubePassShader.SetFloat('lightRadius', aPointLight.Radius);
      ShadowCubePassShader.SetFloat3('lightPosition', iPos.xyz[0], iPos.xyz[1], iPos.xyz[2]);

      //render the scene
      with iQueryData do
      begin
        for iJ := 0 to Models.Count-1 do
          if (Models.Get(iJ) as TModelEntity).CastShadows then
            (Models.Get(iJ) as TModelEntity).Render(false, false);
      end;

      iShadowBuffer.ShadowCubeFrameBuffers[iI].UnBind();
    end;
	  glMatrixMode(GL_PROJECTION);
    glPopMatrix();
  end;

  glMatrixMode(GL_PROJECTION);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);
end;

procedure UpdatePointLightShadowMask(const aPointLight : TPointLightEntity);
var
  iPos : TVector3f;
begin
  //if we dont cast shadows then exit.
  if (aPointLight.CastShadows = false) or (aPointLight.ShadowBuffer = nil) then exit;

  //update the shadowposition
  with aPointLight.ShadowBuffer do
  begin
    //bind the shadow texture to the shadow blur framebuffer
    with Engine.CurrentContext do
    begin
      SBuffer.ShadowBlurFrameBuffer.AttachRenderTexture( ShadowMap, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D );
      SBuffer.ShadowBlurFrameBuffer.Status();
    end;

    //clear the framebuffer
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    //bind the texture
    ShadowBaseMap.Bind(1);

    //set some shader parameters
    iPos := aPointLight.GetPosition();
    ShadowCubeMaskShader.SetFloat3('lightPosition', iPos.xyz[0], iPos.xyz[1], iPos.xyz[2] );

    //render the light
    aPointLight.Render();

    //unbind the texture
    ShadowBaseMap.UnBind();
  end;
end;

begin
  //1: update the required shadowmaps.
  glViewport(0, 0, ShadowSize, ShadowSize);
  ShadowCubePassShader.Bind();
  with aScene.VisibleEntities do
  begin
    for iI := 0 to PointLights.Count-1 do
      UpdatePointLightShadow(TPointLightEntity(PointLights.Get(iI)));
  end;

  //2: update the screenspace shadowmaps for each active light
  //set some states
  with Engine.CurrentContext do
  begin
    //bind shadowblur framebuffer and set some settings
    SBuffer.ShadowBlurFrameBuffer.Bind();
    glViewport(0, 0, Width div 2, Height div 2);
    glCullFace(GL_FRONT);
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GLboolean(GLboolean(FALSE))); { *Converted from glDepthMask* } { *Converted from glDepthMask* }

    //enable shader
    ShadowCubeMaskShader.Bind();
    ShadowCubeMaskShader.SetInt('positionMap', 0);
    ShadowCubeMaskShader.SetInt('shadowCube', 1);

    //set textures
    Engine.CurrentContext.GBuffer.PositionMap.Bind(0);

    //render light masks
    with aScene.VisibleEntities do
    begin
      for iI := 0 to PointLights.Count-1 do
        UpdatePointLightShadowMask(TPointLightEntity(PointLights.Get(iI)));
    end;

    //unbind textures
    GBuffer.PositionMap.UnBind();

    //disable shader
    ShadowCubeMaskShader.Unbind;

    //unbind shadowblur framebuffer
    SBuffer.ShadowBlurFrameBuffer.Unbind();

    //3: Blur the screenspace shadowmaps
    //bind the framebuffer
    GBuffer.PostFrameBuffer.Bind();

    //set some states
    glCullFace(GL_BACK);

    //blur the textures
    for iI := 0 to 7 do
      if Engine.CurrentContext.SBuffer.Shadows[iI].InUse then
        BlurTexture(SBuffer.Shadows[iI].ShadowMap);

    //unbind the framebuffer
    GBuffer.PostFrameBuffer.Unbind();
  end;
end;

procedure UpdateSpotLights();
begin

end;

procedure UpdateDirectionalLights();
begin

end;

begin
  if Not(DoShadows) then exit;

  //scene query data for the stuff in view of the light
  iQueryData := TSceneQueryData.Create();

  //update shadows for different lights
  UpdatePointLights();
  UpdateSpotLights();
  UpdateDirectionalLights();

  //free the query data
  FreeAndNil(iQueryData);
end;

//calculates the lighting
procedure LightingPass();

procedure RenderPointLight();
var
  iI : Integer;
  iPos : TVector3f;
  iPointLight : TPointLightEntity;
begin
  //enable shader
  PointLightShader.Bind;
  PointLightShader.SetInt('positionMap', 0);
  PointLightShader.SetInt('normalMap', 1);
  PointLightShader.SetInt('shadowMap', 2);

  //render light
  //render the visible scene
  with aScene.VisibleEntities do
  begin
    for iI := 0 to PointLights.Count-1 do
    begin
      iPointLight := PointLights.Get(iI) as TPointLightEntity;
      iPos :=  iPointLight.GetPosition();
      PointLightShader.SetFloat3('lightPosition', iPos.x, iPos.y, iPos.z );
      PointLightShader.SetFloat3('lightDiffuse', iPointLight.Color.x, iPointLight.Color.y, iPointLight.Color.z );
      PointLightShader.SetFloat('lightIntensity', iPointLight.Intensity);
      PointLightShader.SetFloat('lightRadius', iPointLight.Radius);
      if (iPointLight.ShadowBuffer = nil) or Not(DoShadows) then
        PointLighTShader.SetInt('hasShadow', 0)
      else
      begin
        PointLightShader.SetInt('hasShadow', 1);
        iPointLight.ShadowBuffer.ShadowMap.Bind(2);
      end;
      iPointLight.Render();
    end;
  end;
end;

procedure RenderSpotLight();
var
  iI : Integer;
  iPos, iDir : TVector3f;
  iSpotLight : TSpotLightEntity;
begin
  //enable shader
  SpotLightShader.Bind;
  SpotLightShader.SetInt('positionMap', 0);
  SpotLightShader.SetInt('normalMap', 1);
  SpotLightShader.SetInt('shadowMap', 2);

  //render light
  //render the visible scene
  with aScene.VisibleEntities do
  begin
    for iI := 0 to SpotLights.Count-1 do
    begin
      iSpotLight := SpotLights.Get(iI) as TSpotLightEntity;
      iPos := iSpotLight.GetPosition();
      iDir := iSpotLight.GetDirection();

      SpotLightShader.SetFloat3('lightPosition', iPos.x, iPos.y, iPos.z );
      SpotLightShader.SetFloat3('lightDirection', iDir.x, iDir.y, iDir.z );
      SpotLightShader.SetFloat3('lightDiffuse', iSpotLight.Color.x, iSpotLight.Color.y, iSpotLight.Color.z );
      SpotLightShader.SetFloat('lightRadius', iSpotLight.MaxRadius);
      SpotLightShader.SetFloat('lightIntensity', iSpotLight.Intensity);
      SpotLightShader.SetFloat('lightOuterAngle', Cos(DegToRad(iSpotLight.OuterAngle)));
      SpotLightShader.SetFloat('lightInnerAngle', Cos(DegToRad(iSpotLight.InnerAngle)));

      //TODO: add shadows
      SpotLightShader.SetInt('hasShadow', 0);
      {
      if (iSpotLight.ShadowBuffer = nil) or Not(DoShadows) then
        SpotLightShader.SetInt('hasShadow', 0)
      else
      begin
        SpotLightShader.SetInt('hasShadow', 1);
        iSpotLight.ShadowBuffer.ShadowMap.Bind(2);
      end;
      }

      iSpotLight.Render();
    end;
  end;
end;

procedure RenderDirectionnalLight();
begin
  //todo
end;

begin
  With Engine.CurrentContext do
  begin
    //set some states
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glCullFace(GL_FRONT);

    //bind textures and buffers
    GBuffer.LightFrameBuffer.Bind();
    glViewport(0, 0, Width, Height);
    GBuffer.PositionMap.Bind(0);
    GBuffer.NormalMap.Bind(1);

    //do the scene diffuse
    glClearColor(aScene.Ambient.xyz[0], aScene.Ambient.xyz[1], aScene.Ambient.xyz[2], 1);
    glClear(GL_COLOR_BUFFER_BIT);

    //render different lights
    RenderPointLight();
    RenderSpotLight();
    RenderDirectionnalLight();

    //unbind textures and buffers
    GBuffer.PositionMap.UnBind();
    GBuffer.NormalMap.UnBind();
    GBuffer.LightFrameBuffer.UnBind();

    //reset some states
    glCullFace(GL_BACK);
    glDisable(GL_BLEND);
  end;
end;

//does al the post processing.
procedure PostProcessPass();
var
  iCamPos : TVector3f;
  iWidth, iHeight : Integer;

procedure GlowBlurPass(const aStartBuffer, aEndBuffer : TTexture);
begin
  Engine.CurrentContext.GBuffer.PostFrameBuffer.AttachRenderTexture(aEndBuffer,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D);
  aStartBuffer.Bind(0);
  glCallList(FScreenQuad);
end;

begin
  iWidth  := Engine.CurrentContext.Width;
  iHeight := Engine.CurrentContext.Height;
  With Engine.CurrentContext.GBuffer do
  begin
    PostFrameBuffer.Bind();
    glViewport(0, 0, iWidth div 2, iHeight div 2);

    //prepare ssao
    if DoSSAO then
    begin
      //bind the framebuffer and attach SSAO buffer
      PostFrameBuffer.AttachRenderTexture(SSAOMap,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D);

      //set textures
      PositionMap.Bind(0);
      NormalMap.Bind(1);
      RandomMap.Bind(2);

      //enable shader
      iCamPos := Engine.CurrentCamera.GetPosition();
      SSAOShader.Bind();
      SSAOShader.SetFloat2('screenSize', iWidth div 2, iHeight div 2);
      SSAOShader.SetFloat3('camPosition', iCamPos.x, iCamPos.y, iCamPos.z);
      SSAOShader.SetFloat('radius', SSAORadius);
      SSAOShader.SetFloat('intensity', SSAOIntensity);
      SSAOShader.SetFloat('scale', SSAOScale);
      SSAOShader.SetFloat('bias', SSAOBias);
      SSAOShader.SetFloat('min', SSAOMin);
      SSAOShader.SetInt('positionMap', 0);
      SSAOShader.SetInt('normalMap', 1);
      SSAOShader.SetInt('randomMap', 2);

      //render the scene
      glCallList(FScreenQuad);

      //unbind textures
      PositionMap.UnBind();
      NormalMap.UnBind();
      RandomMap.UnBind();

      //blur the SSAO buffer
      BlurTexture(SSAOMap);
    end;

    //prepare glow pass
    if DoGlow then
    begin
      CopyTexture(GlowMap, BlurColorMap);
      GlowShader.Bind();
      GlowShader.SetInt('blurMap', 0);
      GlowShader.SetFloat('blurScale', 0.1);

      GlowBlurPass( BlurColorMap, GlowBlurMap );
      GlowBlurPass( GlowBlurMap,  BlurColorMap );
      GlowBlurPass( BlurColorMap, GlowBlurMap );
      GlowBlurPass( GlowBlurMap,  BlurColorMap );
      GlowBlurPass( BlurColorMap, GlowBlurMap );

      GlowShader.Unbind();
    end
    else
    begin
      CopyTexture(GlowMap, GlowBlurMap);
    end;

    PostFrameBuffer.Unbind();
  end;
end;

//compose the final image
procedure ComposeFinal();
var
  iWidth, iHeight : Integer;
begin
  iWidth  := Engine.CurrentContext.Width;
  iHeight := Engine.CurrentContext.Height;
  With Engine.CurrentContext.GBuffer do
  begin
    //set screen size
    glViewport(0, 0, iWidth, iHeight);

    //if fsaa then render the final image to a texture first.
    if DoFXAA then
    begin
      PostFrameBuffer.Bind();
      PostFrameBuffer.AttachRenderTexture(FXAAMap,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D);
    end;

    //bind textures
    if DoDiffuse then
      ColorMap.Bind(0)
    else
      WhiteMap.Bind(0);
    LightMap.Bind(1);
    if DoSSAO then
      SSAOMap.Bind(2)
    else
      WhiteMap.Bind(2);
    GlowMap.Bind(3);
    GlowBlurMap.Bind(4);

    //bind shader
    FinalPassShader.Bind();
    FinalPassShader.SetInt('colorMap', 0);
    FinalPassShader.SetInt('lightMap', 1);
    FinalPassShader.SetInt('ssaoMap', 2);
    FinalPassShader.SetInt('glowMap', 3);
    FinalPassShader.SetInt('glowBlurMap', 4);

    //render the scene
    glCallList(FScreenQuad);

    //unbind textures
    if DoDiffuse then
      ColorMap.UnBind()
    else
      WhiteMap.UnBind();
    LightMap.UnBind();
    if DoSSAO then
      SSAOMap.UnBind()
    else
      WhiteMap.UnBind();
    GlowMap.UnBind();
    GlowBlurMap.UnBind();

    //unbind shader
    FinalPassShader.UnBind();

    //prepare fxaa
    if DoFXAA then
    begin
      PostFrameBuffer.UnBind();
      FXAAMap.Bind(0);
      FXAAShader.Bind();
      FXAAShader.SetFloat2('screenSize',iWidth, iHeight);
      FXAAShader.SetInt('colorMap', 0);

      glCallList(FScreenQuad);

      FXAAMap.Unbind();
      FXAAShader.Unbind();
    end;
  end;
end;

//render scene debug.
procedure RenderDebug();
var
  iI     : Integer;
begin
  With Engine.Renderer do
  begin
    //render the basic scene
    with aScene.VisibleEntities do
    begin
      //render scene debug
      glDisable(GL_DEPTH_TEST);
      //wireframe
      if ShowTris then
      begin
        glPolygonMode(GL_FRONT, GL_LINE);
        SetColor( 1,1,1,1 );
          for iI := 0 to Models.Count-1 do
            (Models.Get(iI) as TModelEntity).Render(false, false);
        glPolygonMode(GL_FRONT, GL_FILL);
      end;

      //normals
      if ShowNormals then
      begin
        for iI := 0 to Models.Count-1 do
          (Models.Get(iI) as TModelEntity).RenderNormals();
      end;

      //mesh volumes
      if ShowMeshVolumes then
      begin
        SetColor( 1,0,1,1 );
        for iI := 0 to Models.Count-1 do
          Models.Get(iI).RenderBoundingVolume();
      end;

      //light volumes
      if ShowLightVolumes then
      begin
        glDisable(GL_CULL_FACE);
        for iI := 0 to Lights.Count-1 do
        begin
          SetColor((Lights.Get(iI) as TLightEntity).Color);
          Lights.Get(iI).RenderBoundingVolume();
        end;
        glEnable(GL_CULL_FACE);
      end;

      //modelbones
      if ShowBones then
      begin
        for iI := 0 to AnimatedModels.Count-1 do
          (AnimatedModels.Get(iI) as TAnimatedModelEntity).RenderBones();
      end;
      glEnable(GL_DEPTH_TEST);
    end;
  end;
end;

begin
  if (Engine.CurrentContext = nil) or (Engine.CurrentCamera = nil) then
    Engine.Log.Print(self.ClassName, 'No context or camera set for scene renderer!', true);

  if (Engine.CurrentContext.GBuffer = nil) then
    Engine.Log.Print(self.ClassName, 'The context has no GBuffer!', true);

  With Engine.Renderer do
  begin
    //update some stats
    Engine.Stats.IncModels(aScene.VisibleEntities.Models.Count);
    Engine.Stats.IncLights(aScene.VisibleEntities.Lights.Count);

    //apply the current camera
    Engine.CurrentCamera.Apply();

    //render the scene deffered
    GBufferPass();
    ShadowPass();
    LightingPass();
    PostProcessPass();
    ComposeFinal();

    //render scene debug
    RenderDebug();
  end;
end;

end.
