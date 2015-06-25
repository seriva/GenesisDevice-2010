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
unit Context;

{$MODE Delphi}

interface

uses
  SysUtils,
  Classes,
  Windows,
  dglOpenGL,
  GBuffer,
  SBuffer,
  FrameBuffer,
  RenderBuffer;

type
  TContext = class
  private
  public
    WND        : HWND;
    DC         : HDC;
    RC         : HGLRC;
    Width      : Integer;
    Height     : Integer;
    HasBuffers : Boolean;
    GBuffer    : TGBuffer;
    SBuffer    : TSBuffer;

    constructor Create(const aWindowHandle : HWND; const aWidth, aHeight : Integer; const aCreateBuffers : Boolean);
    destructor  Destroy(); override;

    procedure Resize( const aWidth, aHeight : Integer );
    procedure Apply();
    procedure Swap();
  end;
  
implementation

uses
  Base;

constructor TContext.Create(const aWindowHandle : HWND; const aWidth, aHeight : Integer; const aCreateBuffers : Boolean);
var
  iI : Integer;
begin
  inherited Create();
  try
    //set window handle
    WND := aWindowHandle;

    //get the device context
    DC := GetDC(WND);
    if (DC = 0) then
      Raise Exception.Create('Failed to get a device context');

    //Create the OpenGL rendering context
    RC := CreateRenderingContext(DC, [opDoubleBuffered, opStereo], 32, 32, 0, 0, 0, 0);;
    if (RC = 0) then
      Raise Exception.Create('Failed to create a rendering context');

    //activate the rendering context
    ActivateRenderingContext(DC, RC);

    //couple this context to the resource context
    if Engine.Renderer <> nil then
      if Engine.Renderer.ResourceContext <> nil then
        wglShareLists(Engine.Renderer.ResourceContext.RC, RC);

    //init some basic gl states
    glClearColor(0,0,0,0);
    glDepthFunc(GL_LESS);
    glClearDepth(1.0);
    glEnable(GL_DEPTH_TEST);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    for iI := 0 to 15 do
    begin
      glActiveTexture(GL_TEXTURE0+iI);
      glEnable(GL_TEXTURE_2D);
    end;

    Width  := aWidth;
    Height := aHeight;
    HasBuffers := aCreateBuffers;
    if HasBuffers then
    begin
      GBuffer := TGBuffer.Create(Width, Height);
      if Engine.Renderer.DoShadows then
         SBuffer := TSBuffer.Create(Width, Height);
    end;
  except
    on E: Exception do
    begin
      Engine.Log.Print(self.ClassName, E.Message, true);
    end;
  end;
end;

destructor  TContext.Destroy();
begin
  inherited Destroy();
  try
    FreeAndNil(GBuffer);
    FreeAndNil(SBuffer);
    DeactivateRenderingContext();
    DestroyRenderingContext(RC);
  except
    on E: Exception do
    begin
      Engine.Log.Print(self.ClassName, E.Message, true);
    end;
  end;
end;

procedure TContext.Resize( const aWidth, aHeight : Integer );
begin
  Apply();
  Width  := aWidth;
  Height := aHeight;
  if HasBuffers then
  begin
    GBuffer.Resize( Width, Height );
    if Engine.Renderer.DoShadows then
      SBuffer.Resize( Width, Height );
  end;
end;

procedure TContext.Apply();
begin
  Engine.CurrentContext := self;
  wglMakeCurrent(DC, RC);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glViewPort(0,0,Width,Height);
  if HasBuffers and Engine.Renderer.DoShadows then
    SBuffer.ResetShadowUsage();
end;

procedure TContext.Swap();
begin
  SwapBuffers(DC);
  Engine.Renderer.CheckErrors();
end;

end.
