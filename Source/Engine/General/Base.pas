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
unit Base;

interface

uses
  SysUtils,
  Windows,
  Renderer,
  Timer,
  Log,
  Resources,
  Camera,
  Console,
  Stats,
  Context,
  BitmapFont;

type
  TEngine = class
  private
    FDebugCam : TCamera;
  public
    BasePath   : String;

    CurrentContext : TContext;
    CurrentCamera  : TCamera;

    DefaultFont : TBitmapFont;
    Timer       : TTimer;
    Log         : TLog;
    Console     : TConsole;
    Stats       : TStats;
    Renderer    : TRenderer;
    Resources   : TResources;

    constructor Create();
    destructor  Destroy(); override;

    procedure Update();
    procedure RenderDebug();
  end;

var
  Engine : TEngine;

procedure InitEngine(const aPath : String);
procedure ClearEngine();

implementation

uses
  OBJLoader,
  DDSLoader,
  MTLLoader,
  MD5Loader,
  GLSLLoader,
  ShaderLoader;

procedure InitEngine(const aPath : String);
begin
  //create the engine class
  Engine := TEngine.Create();

  //set the base path
  Engine.BasePath := aPath;

  //set decimal separator
  FormatSettings.DecimalSeparator := '.';

  //create global resources and systems
  Engine.Timer       := TTimer.Create();
  Engine.Log         := TLog.Create();
  Engine.Console     := TConsole.Create();
  Engine.Stats       := TStats.Create();
  Engine.Resources   := TResources.Create();
  Engine.Resources.RegisterLoader( '.VERT', LoadShaderResource );
  Engine.Resources.RegisterLoader( '.FRAG', LoadShaderResource );
  Engine.Resources.RegisterLoader( '.GEOM', LoadShaderResource );
  Engine.Resources.RegisterLoader( '.GLSL', LoadGLSLResource );
  Engine.Resources.RegisterLoader( '.OBJ', LoadOBJResource );
  Engine.Resources.RegisterLoader( '.DDS', LoadDDSResource );
  Engine.Resources.RegisterLoader( '.MTL', LoadMTLResource );
  Engine.Resources.RegisterLoader( '.MD5', LoadMD5Resource );
  Engine.Renderer    := TRenderer.Create();
  Engine.DefaultFont := TBitmapFont.Create('Lucida Console', 14);
end;

procedure ClearEngine();
begin
  FreeAndNil(Engine.DefaultFont);
  FreeAndNil(Engine.Timer);
  FreeAndNil(Engine.Renderer);
  Engine.Resources.Clear();
  FreeAndNil(Engine.Resources);
  FreeAndNil(Engine.Stats);
  FreeAndNil(Engine.Console);
  FreeAndNil(Engine.Log);
  FreeAndNil(Engine);
end;

constructor TEngine.Create();
begin
  inherited Create;
  FDebugCam := TCamera.Create();
end;

destructor  TEngine.Destroy();
begin
  inherited Destroy;
  FreeAndNil(FDebugCam);
end;

procedure TEngine.Update();
begin
  Stats.Update();
  Timer.Update();
end;

procedure TEngine.RenderDebug();
begin
  if CurrentContext = nil then exit;

  FDebugCam.SetOrthogonalProjection(0, CurrentContext.Width, CurrentContext.Height, 0, -1, 1);
  FDebugCam.Apply();

  Console.Render();
  Stats.Render();
end;

end.
