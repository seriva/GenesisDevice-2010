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
unit GBuffer;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  Texture,
  RenderBuffer,
  FrameBuffer;

type
  TGBuffer = class
  private
    procedure Init(const aWidth, aHeight : Integer);
    procedure Clear();
  public
    //main GBuffer
    FrameBuffer       : TFrameBuffer;
    PositionMap       : TTexture;
    NormalMap         : TTexture;
    ColorMap          : TTexture;
    GlowMap           : TTexture;
    DepthBuffer       : TRenderBuffer;

    //diffuse buffers
    LightFrameBuffer  : TFrameBuffer;
    LightMap          : TTexture;

    //post process helper buffers.
    PostFrameBuffer   : TFrameBuffer;
    BlurShadowMap     : TTexture;
    BlurColorMap      : TTexture;
    FXAAMap           : TTexture;

    //some post process buffers
    SSAOMap           : TTexture;
    GlowBlurMap       : TTexture;

    constructor Create(const aWidth, aHeight : Integer);
    destructor  Destroy(); override;
    procedure   Resize(const aWidth, aHeight : Integer);
  end;

implementation

constructor TGBuffer.Create(const aWidth, aHeight : Integer);
begin
  Inherited Create();
  Init(aWidth, aHeight);
end;

destructor  TGBuffer.Destroy();
begin
  Inherited Destroy();
  Clear();
end;

procedure  TGBuffer.Init(const aWidth, aHeight : Integer);
var
  iBuffers : array[0..4] of GLEnum;
begin
  //setup the main framebuffer
  PositionMap := TTexture.CreateRenderTexture(aWidth, aHeight, GL_RGB16F, GL_RGB, GL_FLOAT);
  NormalMap   := TTexture.CreateRenderTexture(aWidth, aHeight, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
  ColorMap    := TTexture.CreateRenderTexture(aWidth, aHeight, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
  GlowMap     := TTexture.CreateRenderTexture(aWidth, aHeight, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
  DepthBuffer := TRenderBuffer.Create(aWidth, aHeight, GL_DEPTH_COMPONENT24);
  ColorMap.Bind(0);
  PositionMap.Bind(1);
  NormalMap.Bind(2);
  GlowMap.Bind(3);
  FrameBuffer := TFrameBuffer.Create();
  FrameBuffer.Bind();
  FrameBuffer.AttachRenderTexture(ColorMap, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D  );
  FrameBuffer.AttachRenderTexture(PositionMap, GL_COLOR_ATTACHMENT1_EXT, GL_TEXTURE_2D  );
  FrameBuffer.AttachRenderTexture(NormalMap, GL_COLOR_ATTACHMENT2_EXT, GL_TEXTURE_2D  );
  FrameBuffer.AttachRenderTexture(GlowMap, GL_COLOR_ATTACHMENT3_EXT, GL_TEXTURE_2D  );
  FrameBuffer.AttachRenderBuffer(DepthBuffer, GL_DEPTH_ATTACHMENT_EXT );
  iBuffers[0] := GL_COLOR_ATTACHMENT0_EXT;
  iBuffers[1] := GL_COLOR_ATTACHMENT1_EXT;
  iBuffers[2] := GL_COLOR_ATTACHMENT2_EXT;
  iBuffers[3] := GL_COLOR_ATTACHMENT3_EXT;
	glDrawBuffers(4, @iBuffers);
	glReadBuffer(GL_NONE);
  FrameBuffer.Status();
  FrameBuffer.Unbind();
  ColorMap.UnBind();
  PositionMap.UnBind();
  NormalMap.UnBind();

  //setup light buffer
  LightMap := TTexture.CreateRenderTexture(aWidth, aHeight, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
  LightFrameBuffer := TFrameBuffer.Create();
  LightFrameBuffer.Bind();
  LightMap.Bind(0);
  LightFrameBuffer.AttachRenderTexture(LightMap, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D  );
  LightFrameBuffer.UnBind();
  LightMap.Unbind();

  //post process helper buffers
  PostFrameBuffer := TFrameBuffer.Create();
  BlurShadowMap   := TTexture.CreateRenderTexture(aWidth div 2, aHeight div 2, GL_LUMINANCE8, GL_LUMINANCE, GL_UNSIGNED_BYTE);
  BlurColorMap    := TTexture.CreateRenderTexture(aWidth div 2, aHeight div 2, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
  FXAAMap         := TTexture.CreateRenderTexture(aWidth, aHeight, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);

  //some post process buffers
  SSAOMap         := TTexture.CreateRenderTexture(aWidth div 2, aHeight div 2, GL_LUMINANCE8, GL_LUMINANCE, GL_UNSIGNED_BYTE);
  GlowBlurMap     := TTexture.CreateRenderTexture(aWidth div 2, aHeight div 2, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
end;

procedure  TGBuffer.Clear();
begin
  //main GBuffer
  FreeAndNil(FrameBuffer);
  FreeAndNil(PositionMap);
  FreeAndNil(NormalMap);
  FreeAndNil(ColorMap);
  FreeAndNil(GlowMap);
  FreeAndNil(DepthBuffer);

  //light map
  FreeAndNil(LightMap);
  FreeAndNil(LightFrameBuffer);

  //post process helper buffers
  FreeAndNil(PostFrameBuffer);
  FreeAndNil(BlurShadowMap);
  FreeAndNil(BlurColorMap);
  FreeAndNil(FXAAMap);

  //some post process buffers
  FreeAndNil(SSAOMap);
  FreeAndNil(GlowBlurMap);
end;

procedure TGBuffer.Resize(const aWidth, aHeight : Integer);
begin
  Clear();
  Init(aWidth, aHeight);
end;

end.
