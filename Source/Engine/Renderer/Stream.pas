{*******************************************************************************
*                            Genesis Device Engine                             *
*                   Copyright © 2007-2015 Luuk van Venrooij                    *
*                        http://www.luukvanvenrooij.nl                         *
*                         luukvanvenrooij84@gmail.com                          *
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
unit Stream;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  FloatArray;

Type
  TStream = class
  private
  public
    Usage    : TGLenum;
    Used     : boolean;
    Dirty    : boolean;
    BufferID : GLuint;
    Data     : TFloatArray;

    constructor Create();
    Destructor  Destroy(); override;
    procedure   Update();
  end;

implementation

constructor TStream.Create();
begin
  inherited Create();
  Usage	   := GL_STATIC_DRAW;
  Used  	 := false;
  Dirty	   := true;
  BufferID := 0;
  Data	   := TFloatArray.Create();
end;

Destructor TStream.Destroy();
begin
  inherited Destroy();
  glDeleteBuffers(1, @BufferID);
  BufferID := 0;
  Dirty := true;
  Used := false;
  FreeAndNil(Data);
end;

procedure TStream.Update();
begin
  if not(Used) or (Dirty = false) then exit;
  if BufferID = 0 then glGenBuffers(1, @BufferID);
  glBindBuffer(GL_ARRAY_BUFFER, BufferID);
  glBufferData(GL_ARRAY_BUFFER, Data.Size(), Data.BasePointer(), Usage);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  Dirty := false;
end;

end.
