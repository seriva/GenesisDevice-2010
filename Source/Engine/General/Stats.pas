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
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  Engine.Renderer.SetColor(0.4,0.4,0.4,0.75);
  glBegin(GL_QUADS);
    glVertex2f(10,10);
    glVertex2f(205,10);
    glVertex2f(205,75);
    glVertex2f(10,75);
  glEnd();
  glDisable(GL_BLEND);
  glLineWidth(1);
  Engine.Renderer.SetColor(1,1,1,1);
  glBegin(GL_LINE_LOOP);
    glVertex2f(10,10);
    glVertex2f(205,10);
    glVertex2f(205,75);
    glVertex2f(10,75);
  glEnd();
  glLineWidth(1);

  //text
  Engine.Font.Render(1, 1, 1, 15, 15, 0.2, 'Lights' );
  Engine.Font.Render(1, 1, 1, 15, 30, 0.2, 'Meshes');
  Engine.Font.Render(1, 1, 1, 15, 45, 0.2, 'Tris');
  Engine.Font.Render(1, 1, 1, 15, 60, 0.2, 'Fps');
  Engine.Font.Render(1, 1, 1, 100, 15, 0.2, ': ' + IntToStr(FLightCount));
  Engine.Font.Render(1, 1, 1, 100, 30, 0.2, ': ' + IntToStr(FModelCount));
  Engine.Font.Render(1, 1, 1, 100, 45, 0.2, ': ' + IntToStr(FTrisCount));
  Engine.Font.Render(1, 1, 1, 100, 60, 0.2, ': ' + IntToStr(FFPS));

  glEnable(GL_DEPTH_TEST);
end;

end.
