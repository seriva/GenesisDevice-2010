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
unit Shader;

{$MODE Delphi}

interface

uses
  Classes,
  SysUtils,
  Resource,
  dglOpenGL;

type
  TShader = class (TResource)
  private
  public
    Handle : GLhandleARB;
    Source : String;

    constructor Create(const aSource : String; const aType: GLenum);
    destructor  Destroy(); override;
  end;

  {$define TYPED_ARRAY_TEMPLATE}
  TYPED_ARRAY_ITEM = TShader;
  {$INCLUDE '..\Templates\Array.tpl'}

  TShaderArray = class(TYPED_ARRAY)
  private
    FOwnsEntities : Boolean;

    procedure OnRemoveItem(var aItem : TShader); override;
  public
    constructor Create(OwnsEntities : Boolean = true);
    destructor  Destroy(); override;
  end;

  function  GetInfoLog(const aObject : GLhandleARB): String;

implementation

uses
  Base;

{$INCLUDE '..\Templates\Array.tpl'}

constructor TShaderArray.Create(OwnsEntities : Boolean);
begin
  inherited Create();
  FOwnsEntities := OwnsEntities;
end;

destructor  TShaderArray.Destroy();
begin
  inherited Destroy();
end;

procedure TShaderArray.OnRemoveItem(var aItem : TShader);
begin
  //Engine.Resources.Remove( TResource(aItem) );
end;

function GetInfoLog(const aObject : GLhandleARB): String;
var
  iBLen, iSLen: Integer;
  iInfoLog : PGLCharARB;
begin
  glGetObjectParameterivARB(aObject, GL_OBJECT_INFO_LOG_LENGTH_ARB , @iBLen);
  if iBLen > 1 then
  begin
    GetMem(iInfoLog, iBLen*SizeOf(GLCharARB));
    glGetInfoLogARB(aObject, iBLen, iSLen, iInfoLog);
    Result := String(iInfoLog);
    Dispose(iInfoLog);
  end;
end;

constructor TShader.Create(const aSource : String; const aType: GLenum);
var
  iSource : AnsiString;
  iCompiled, iLen : Integer;
begin
  inherited Create();
  Source    := aSource;
  iSource   := AnsiString(Source);
  iLen      := Length(iSource);
  Handle    := glCreateShader(aType);
  glShaderSource(Handle, 1, @iSource, @iLen);
  glCompileShader(Handle);
  glGetShaderiv(Handle, GL_COMPILE_STATUS, @iCompiled);
  if (iCompiled <> GL_TRUE) then
  begin
    case aType of
      GL_VERTEX_SHADER   : Raise Exception.Create('Failed to compile vertex shader: ' + GetInfoLog(Handle) );
      GL_FRAGMENT_SHADER : Raise Exception.Create('Failed to compile fragment shader: ' + GetInfoLog(Handle) );
      GL_GEOMETRY_SHADER : Raise Exception.Create('Failed to compile geometry shader: ' + GetInfoLog(Handle) );
    end;
  end;
end;

Destructor TShader.Destroy();
begin
  inherited Destroy();
  glDeleteShader(Handle);
end;

end.
