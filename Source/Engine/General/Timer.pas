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
unit Timer;

interface

uses
  Windows;

type
  TTimer = class
  private
    FFreq  : Int64;
    FStart : Int64;
    FFrameStart, FFrameEnd, FFrameTime : Int64;
  public
    property FrameTime : Int64 read FFrameTime;

    constructor Create();
    destructor  Destroy(); override;

    function  Time(): Integer;
    procedure Update();
  end;

implementation

constructor TTimer.Create();
begin
  inherited Create();
  QueryPerformanceFrequency(FFreq);
  QueryPerformanceCounter(FStart);
  FFrameStart := Time();
end;

destructor  TTimer.Destroy();
begin
  inherited Destroy();
end;

function  TTimer.Time(): Integer;
var
  Count : Int64;
begin
  QueryPerformanceCounter(Count);
  Result := Trunc(1000 * ((Count - FStart) / FFreq));
end;

procedure  TTimer.Update();
begin
  FFrameEnd   := Time();
  FFrameTime  := FFrameEnd - FFrameStart;
  FFrameStart := FFrameEnd;
end;

end.
