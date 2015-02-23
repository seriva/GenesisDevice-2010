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
unit GLSLLoader;

{$MODE Delphi}

Interface

uses
  SysUtils,
  Classes,
  Resource,
  ResourceUtils,
  Shader,
  ShaderProgram, FileUtil;

function LoadGLSLResource(const aName : String): TResource;

implementation

uses
  Base;

function LoadGLSLResource(const aName : String): TResource;
var
  iFile : TMemoryStream;
  iShaderProgram : TShaderProgram;
  iStr : String;
begin
  try
    //check if the file exists
    if Not(FileExistsUTF8(aName ) { *Converted from FileExists* }) then
      Raise Exception.Create( aName + ' doesn`t exists');

    //create the filestream
    iFile := TMemoryStream.Create();
    iFile.LoadFromFile(Engine.BasePath + aName);

    //set the comment string
    CommentString := '//';

    //create shader
    iShaderProgram := TShaderProgram.Create();

    //parse the shader
    while (iFile.Position < iFile.Size) do
    begin
      iStr := GetNextToken(iFile);
      if iStr = 'vertex' then //read vertex shader
      begin
        iShaderProgram.AddShader(  TShader( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) )));
        continue;
      end
      else if iStr = 'fragment' then  //read fragement shader
      begin
        iShaderProgram.AddShader(  TShader( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) )));
        continue;
      end
      else if iStr = 'geometry' then  //read geometry shader
      begin
        iShaderProgram.AddShader(  TShader( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) )));
        continue;
      end;
    end;

    //link the shader
    iShaderProgram.Link();

    //clear the filestream
    FreeAndNil(iFile);
  except
    on E: Exception do
    begin
      Engine.Log.Print('GLSLLoader: ', 'Failed To Load Resource: ' + Engine.BasePath + aName);
      Engine.Log.Print('GLSLLoader: ', E.Message, true);
    end;
  end;
  iShaderProgram.Name := aName;
  result := iShaderProgram;
end;

end.
