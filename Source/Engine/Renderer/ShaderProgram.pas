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
unit ShaderProgram;

{$MODE Delphi}

interface

uses
  Classes,
  SysUtils,
  Resource,
  Shader,
  dglOpenGL;

type
  TShaderProgram = class (TResource)
  private
    FHandle   : GLhandle;
    FShaders  : TShaderArray;
  public
    constructor Create();
    destructor  Destroy(); override;
    procedure   Bind();
    procedure   Unbind();
    procedure   AddShader(const aShader : TShader);
    procedure   Link();
    procedure   SetInt(const aVariable : String;  const aV : integer);
    procedure   SetFloat(const aVariable : String; const aV : Double);
    procedure   SetFloat2(const aVariable : String; const aV0, aV1 : Double);
    procedure   SetFloat3(const aVariable : String; const aV0, aV1, aV2 : Double);
    procedure   SetFloat4(const aVariable : String; const aV0, aV1, aV2, aV3 : Double);
    procedure   SetAttributeFloat(const aVariable : String; const aV : Single);
    procedure   SetAttributeFloat2(const aVariable : String; const aV0, aV1 : Single);
    procedure   SetAttributeFloat3(const aVariable : String; const aV0, aV1, aV2 : Single);
    procedure   SetAttributeFloat4(const aVariable : String; const aV0, aV1, aV2, aV3 : Single);
  end;

implementation

uses
  Base;

constructor TShaderProgram.Create();
begin
  inherited Create();
  FShaders := TShaderArray.Create(true);
  FHandle  := glCreateProgram();
end;

destructor TShaderProgram.Destroy();
var
  iI : Integer;
begin
  inherited Destroy();
  for iI := 0 to FShaders.Count-1 do
    glDetachShader(FHandle, FShaders.Get(iI).Handle);
  glDeleteProgram(FHandle);
  FreeAndNil(FShaders);
end;

procedure TShaderProgram.AddShader(const aShader : TShader);
begin
  FShaders.Add(aShader);
end;

procedure TShaderProgram.Link();
var
  iLinked : Integer;
  iI : Integer;
begin
  for iI := 0 to FShaders.Count-1 do
    glAttachShader(FHandle, FShaders.Get(iI).Handle);
  glLinkProgram(FHandle);
  glGetProgramiv(FHandle, GL_LINK_STATUS, @iLinked);
  if (iLinked <> GL_TRUE) then
    Raise Exception.Create('Failed to link shader: ' + GetInfoLog(FHandle) );
end;

procedure TShaderProgram.Bind();
begin
  glUseProgramObjectARB(FHandle);
end;

procedure TShaderProgram.Unbind();
begin
  glUseProgramObjectARB(0);
end;

procedure TShaderProgram.SetInt(const aVariable : String;  const aV : integer);
begin
   glUniform1iARB( glGetUniformLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV);
end;

procedure TShaderProgram.SetFloat(const aVariable : String; const aV : Double);
begin
  glUniform1fARB( glGetUniformLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV);
end;

procedure TShaderProgram.SetFloat2(const aVariable : String; const aV0, aV1 : Double);
begin
  glUniform2fARB( glGetUniformLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV0, aV1);
end;

procedure TShaderProgram.SetFloat3(const aVariable : String; const aV0, aV1, aV2 : Double);
begin
  glUniform3fARB( glGetUniformLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV0, aV1, aV2);
end;

procedure TShaderProgram.SetFloat4(const aVariable : String; const aV0, aV1, aV2, aV3 : Double);
begin
  glUniform4fARB( glGetUniformLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV0, aV1, aV2, aV3);
end;

procedure TShaderProgram.SetAttributeFloat(const aVariable : String; const aV : Single);
begin
  glVertexAttrib1fARB( glGetAttribLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV);
end;

procedure TShaderProgram.SetAttributeFloat2(const aVariable : String; const aV0, aV1 : Single);
begin
  glVertexAttrib2fARB( glGetAttribLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV0, aV1);
end;

procedure TShaderProgram.SetAttributeFloat3(const aVariable : String; const aV0, aV1, aV2 : Single);
begin
  glVertexAttrib3fARB( glGetAttribLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]), aV0, aV1, aV2);
end;

procedure TShaderProgram.SetAttributeFloat4(const aVariable : String; const aV0, aV1, aV2, aV3 : Single);
begin
  glVertexAttrib4fARB( glGetAttribLocationARB(FHandle, @PAnsiChar(AnsiString(aVariable))[0]),aV0, aV1, aV2, aV3);
end;

end.
