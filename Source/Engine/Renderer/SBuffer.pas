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
unit SBuffer;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  Texture,
  RenderBuffer,
  FrameBuffer;

type
  TShadowType = (ST_POINTSHADOW, ST_SPOTSHADOW);

  TShadow = class
  private
  public
    ShadowType    : TShadowType;
    ShadowBaseMap : TTexture;
    ShadowMap     : TTexture;
    InUse         : Boolean;

    ShadowFrameBuffer       : TFrameBuffer;
    ShadowRenderBuffer      : TRenderBuffer;
    ShadowCubeFrameBuffers  : array[0..5] of TFrameBuffer;
    ShadowCubeRenderBuffers : array[0..5] of TRenderBuffer;

    constructor Create(const aWidth, aHeight : Integer; const aShadowType : TShadowType; const aShadowMap : TTexture);
    destructor  Destroy(); override;
  end;

  TSBuffer = class
  private
    procedure Init(const aWidth, aHeight : Integer);
    procedure Clear();
  public
    Shadows                  : array[0..7] of TShadow;
    
    ShadowBlurFrameBuffer    : TFrameBuffer;
    ShadowBlurRenderBuffer   : TRenderBuffer;

    constructor Create(const aWidth, aHeight : Integer);
    destructor  Destroy(); override;
    procedure   Resize(const aWidth, aHeight : Integer);

    function  GetShadowBuffer(const aShadowType : TShadowType): TShadow;
    procedure ResetShadowUsage();
  end;

implementation

uses
  Base;

constructor TShadow.Create(const aWidth, aHeight : Integer; const aShadowType : TShadowType; const aShadowMap : TTexture);
var
  iI : Integer;
begin
  Inherited Create();
  ShadowType    := aShadowType;
  ShadowBaseMap := aShadowMap;
  ShadowMap     := TTexture.CreateRenderTexture(aWidth div 2, aHeight div 2, GL_LUMINANCE8, GL_LUMINANCE, GL_UNSIGNED_BYTE);
  InUse         := false;

  if ShadowType = ST_POINTSHADOW then

  case ShadowType of
    ST_POINTSHADOW : 
    begin  
      for iI := 0 to  5 do
        begin
        ShadowCubeFrameBuffers[iI] := TFrameBuffer.Create();
        ShadowCubeFrameBuffers[iI].Bind();
        ShadowCubeFrameBuffers[iI].AttachRenderTexture( ShadowBaseMap, GL_COLOR_ATTACHMENT0, GL_TEXTURE_CUBE_MAP_POSITIVE_X+iI );
        ShadowCubeRenderBuffers[iI] := TRenderBuffer.Create(Engine.Renderer.ShadowSize, Engine.Renderer.ShadowSize,GL_DEPTH_COMPONENT);
        ShadowCubeRenderBuffers[iI].Bind();
        ShadowCubeFrameBuffers[iI].AttachRenderBuffer( ShadowCubeRenderBuffers[iI], GL_DEPTH_ATTACHMENT );
        glReadBuffer(GL_NONE);
        ShadowCubeFrameBuffers[iI].Status();
        ShadowCubeRenderBuffers[iI].Unbind();
        ShadowCubeFrameBuffers[iI].Unbind();
      end;    
    end;
    ST_SPOTSHADOW :
    begin
      ShadowFrameBuffer := TFrameBuffer.Create();
      ShadowFrameBuffer.Bind();
      ShadowRenderBuffer := TRenderBuffer.Create(Engine.Renderer.ShadowSize, Engine.Renderer.ShadowSize,GL_DEPTH_COMPONENT);
      ShadowRenderBuffer.Bind();
      ShadowCubeFrameBuffers[iI].AttachRenderTexture( ShadowBaseMap, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D );
      ShadowFrameBuffer.AttachRenderBuffer( ShadowRenderBuffer, GL_DEPTH_ATTACHMENT );
      glReadBuffer(GL_NONE);
      ShadowCubeFrameBuffers[iI].Status();
      ShadowRenderBuffer.Unbind();
      ShadowFrameBuffer.Unbind();
    end;
  end;
end;

destructor  TShadow.Destroy();
var
  iI : Integer;
begin
  Inherited Destroy();
  ShadowBaseMap := nil;
  FreeAndNil(ShadowMap);

  case ShadowType of
    ST_POINTSHADOW :
    begin
      for iI := 0 to  5 do
      begin
        FreeAndNil(ShadowCubeFrameBuffers[iI]);
        FreeAndNil(ShadowCubeRenderBuffers[iI]);
      end;
    end;
    ST_SPOTSHADOW :
    begin
      FreeAndNil(ShadowFrameBuffer);
      FreeAndNil(ShadowRenderBuffer);
    end;
  end;
end;

constructor TSBuffer.Create(const aWidth, aHeight : Integer);
begin
  Inherited Create();
  Init(aWidth, aHeight);
end;

destructor  TSBuffer.Destroy();
begin
  Inherited Destroy();
  Clear();
end;

procedure  TSBuffer.Init(const aWidth, aHeight : Integer);
var
  iI : Integer;
begin
  //create the shadows
  Shadows[0] := TShadow.Create(aWidth, aHeight, ST_POINTSHADOW, Engine.Renderer.ShadowBaseMaps[0] );
  Shadows[1] := TShadow.Create(aWidth, aHeight, ST_POINTSHADOW, Engine.Renderer.ShadowBaseMaps[1] );
  for iI := 2 to 7 do
    Shadows[iI] := TShadow.Create(aWidth, aHeight, ST_SPOTSHADOW, Engine.Renderer.ShadowBaseMaps[iI] );

  //create the blur framebuffer
  ShadowBlurFrameBuffer := TFrameBuffer.Create();
  ShadowBlurFrameBuffer.Bind();
  ShadowBlurRenderBuffer := TRenderBuffer.Create(aWidth div 2, aHeight div 2,GL_DEPTH_COMPONENT);
  ShadowBlurRenderBuffer.Bind();
  ShadowBlurFrameBuffer.AttachRenderBuffer( ShadowBlurRenderBuffer, GL_DEPTH_ATTACHMENT );
  glReadBuffer(GL_NONE);
  ShadowBlurRenderBuffer.Unbind();
  ShadowBlurFrameBuffer.Unbind();
end;

procedure  TSBuffer.Clear();
var
  iI : Integer;
begin
  for iI := 0 to 7 do
    FreeAndNil(Shadows[iI]);
  FreeAndNil(ShadowBlurFrameBuffer);
  FreeAndNil(ShadowBlurRenderBuffer);
end;

procedure TSBuffer.Resize(const aWidth, aHeight : Integer);
begin
  Clear();
  Init(aWidth, aHeight);
end;

function TSBuffer.GetShadowBuffer(const aShadowType : TShadowType): TShadow;
var
  iI : Integer;
begin
  iI := 0;
  result := nil;
  while ((iI < 8) and (result = nil)) do
  begin
    if (Shadows[iI].InUse = false) and (Shadows[iI].ShadowType = aShadowType) then
    begin
      Shadows[iI].InUse := true;
      result := Shadows[iI];
    end;
    iI := iI + 1;
  end;
end;

procedure TSBuffer.ResetShadowUsage();
var
  iI : Integer;
begin
  for iI := 0 to 7 do
    Shadows[iI].InUse := false;
end;

end.
