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
unit Stats;

interface

uses
  dglOpenGL,
  Console,
  SysUtils;

type
  TStats = class
  private
    FFPSTime    : Integer;
    FLastTime   : Integer;
    FShow       : Boolean;
    FTrisCount  : Integer;
    FModelCount : Integer;
    FLightCount : Integer;
    FFPS        : Integer;
    FFPSCounter : Integer;
  public
    constructor Create();
    Destructor  Destroy(); override;

    procedure IncTris(const aTris : Integer);
    procedure IncModels(const aModels : Integer);
    procedure IncLights(const aLights : Integer);

    procedure Update();
    procedure Render();
  end;

implementation

uses
  Base;

constructor TStats.Create();
begin
  inherited Create();
  FLastTime   := Engine.Timer.Time();
  FShow       := false;
  FTrisCount  := 0;
  FModelCount := 0;
  FLightCount := 0;
  FFPS        := 0;
  FFPSCounter := 0;
  Engine.Console.AddCommand('r_stats', 'Show or hide stats', CT_BOOLEAN, @FShow);
end;

Destructor  TStats.Destroy();
begin
  inherited Create();
end;

procedure TStats.IncTris(const aTris : Integer);
begin
  FTrisCount := FTrisCount + aTris;
end;

procedure TStats.IncModels(const aModels : Integer);
begin
  FModelCount := FModelCount + aModels;
end;

procedure TStats.IncLights(const aLights : Integer);
begin
  FLightCount := FLightCount + aLights;
end;

procedure TStats.Update();
var
  iDT, iTime : Integer;
begin
  //calculate fps
  iTime        := Engine.Timer.Time();
  iDT          := iTime - FLastTime;
  FLastTime    := iTime;
  FFPSTime  := FFPSTime + iDT;
  if (FFPSTime >= 1000) then
  begin
    FFPS := FFPSCounter;
    FFPSCounter := 0;
    FFPSTime := 0;
  end;
  Inc(FFPSCounter);

  //reset some other stats
  FTrisCount  := 0;
  FModelCount := 0;
  FLightCount := 0;
end;

procedure TStats.Render();
begin
  if not(FShow) then exit;

  //background quad
  glDisable(GL_DEPTH_TEST);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  Engine.Renderer.SetColor(0.4,0.4,0.4,0.75);
  glBegin(GL_QUADS);
    glVertex2f(10,10);
    glVertex2f(205,10);
    glVertex2f(205,72);
    glVertex2f(10,72);
  glEnd();
  glDisable(GL_BLEND);
  glLineWidth(2);
  Engine.Renderer.SetColor(1,1,1,1);
  glBegin(GL_LINE_LOOP);
    glVertex2f(10,10);
    glVertex2f(205,10);
    glVertex2f(205,74);
    glVertex2f(10,74);
  glEnd();
  glLineWidth(1);

  //text
  Engine.Renderer.SetColor(1,1,1,1);
  Engine.DefaultFont.RenderText(15, 15, 'Lights : ' + IntToStr(FLightCount));
  Engine.DefaultFont.RenderText(15, 30, 'Meshes : ' + IntToStr(FModelCount));
  Engine.DefaultFont.RenderText(15, 45, 'Tris   : ' + IntToStr(FTrisCount));
  Engine.DefaultFont.RenderText(15, 60, 'Fps    : ' + IntToStr(FFPS));
  glEnable(GL_DEPTH_TEST);
end;

end.
