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
unit OcclusionQuery;

{$MODE Delphi}

interface

uses
  dglOpenGL;

type
  TOcclusionQuery = class
  private
    FOcclusionQuery : GLuint;
  public
    constructor Create();
    destructor  Destroy(); override;

    procedure StartQuery();
    procedure EndQuery();
    function  Visible(): boolean;
    function  IsDone(): boolean;
  end;

implementation

constructor TOcclusionQuery.Create();
begin
  glGenQueries(1, @FOcclusionQuery);
end;

destructor  TOcclusionQuery.Destroy();
begin
  inherited;
  glDeleteQueries(1, @FOcclusionQuery);
end;

procedure TOcclusionQuery.StartQuery();
begin
  glBeginQuery(GL_SAMPLES_PASSED,FOcclusionQuery);
end;

procedure TOcclusionQuery.EndQuery();
begin
  glEndQuery(GL_SAMPLES_PASSED);
end;

function TOcclusionQuery.Visible(): boolean;
var
  iVisible : GLuint;
begin
  glGetQueryObjectiv(FOcclusionQuery,GL_QUERY_RESULT,@iVisible);

  If iVisible > 0 then
    result := True
  else
    result := False;
end;

function TOcclusionQuery.IsDone(): boolean;
var
  iDone : GLuint;
begin
  glGetQueryObjectiv(FOcclusionQuery,GL_QUERY_RESULT_AVAILABLE,@iDone);

  If iDone = GL_TRUE then
    result := True
  else
    result := False;
end;

end.
