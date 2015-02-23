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
unit ShaderLoader;

{$MODE Delphi}

Interface

uses
  SysUtils,
  Classes,
  dglOpenGL,
  Resource,
  ResourceUtils,
  Shader, FileUtil;

function LoadShaderResource(const aName : String): TResource;

implementation

uses
  Base;

function LoadShaderResource(const aName : String): TResource;
var
  iShader : TShader;
  iShaderFile : TStringList;
  iType : GLenum;
  iStr : String;
begin
  try
    //check if the file exists
    if Not(FileExistsUTF8(aName ) { *Converted from FileExists* }) then
      Raise Exception.Create( aName + ' doesn`t exists');
	  
    //determin the shadertype
    iStr := UpperCase(ExtractFileExt(aName));
    if iStr = '.VERT' then
      iType := GL_VERTEX_SHADER
    else if iStr = '.FRAG' then
      iType := GL_FRAGMENT_SHADER
    else if iStr = '.GEOM' then
      iType := GL_GEOMETRY_SHADER
    else
      Raise Exception.Create( aName + ' shadertype is unknown!');

    //load the shader source
    iShaderFile := TStringList.Create();
    iShaderFile.LoadFromFile( aName );
	
    //create the shader
    iShader := TShader.Create(iShaderFile.Text, iType);

    FreeAndNil(iShaderFile);
  except
    on E: Exception do
    begin
      Engine.Log.Print('ShaderLoader: ', 'Failed To Load Resource: ' + Engine.BasePath + aName);
      Engine.Log.Print('ShaderLoader: ', E.Message, true);
    end;
  end;
  iShader.Name := aName;
  result := iShader;
end;

end.
