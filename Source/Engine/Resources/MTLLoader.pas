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
unit MTLLoader;

{$MODE Delphi}

interface

uses
  SysUtils,
  Classes,
  dglOpenGL,
  Texture,
  Material,
  Resource,
  ShaderProgram,
  ResourceUtils,
  Mathematics,
  Base, FileUtil;

function LoadMTLResource(const aName : String): TResource;

implementation

function LoadMTLResource(const aName : String): TResource;
var
	iFile : TMemoryStream;
  iStr  : String;
  iMat  : TMaterial;
begin
  try
    //check if the file exists
    if Not(FileExistsUTF8(Engine.BasePath + aName ) { *Converted from FileExists* }) then
      Raise Exception.Create(Engine.BasePath + aName + ' doesn`t exists.');

    //create the filestream and material map
    iFile := TMemoryStream.Create();
    iFile.LoadFromFile(Engine.BasePath + aName);

    //set some stuff
    iMat := nil;

    //parse the material library
    while (iFile.Position < iFile.Size) do
    begin
      iStr := GetNextToken(iFile);
      if iStr = 'material' then //read the material
      begin
        if iMat <> nil then
          raise Exception.Create('"}" token expected before "material"!');

        if GetNextToken(iFile) <> '{' then
          raise Exception.Create('"{" token expected after "material"!');

        if GetNextToken(iFile) <> 'name' then
          raise Exception.Create('"name" token expected after "{"!');

        iStr  := GetNextToken(iFile);
        if Engine.Resources.Exists( 'mat_' + iStr ) then
          iMat := nil
        else
        begin
          iMat := TMaterial.Create();
          iMat.Name := 'mat_' + iStr;
        end;
        continue;
      end
      else if iStr = '}' then //end token
      begin
        if iMat <> nil then
        begin
          Engine.Resources.Add( iMat.Name, iMat as TResource);
          iMat := nil
        end;
        continue;
      end
      else if iStr = 'shader' then //read the shader
      begin
        if iMat <> nil then
          iMat.Shader := TShaderProgram(Engine.Resources.Load( GetNextToken(iFile) ));
        continue;
      end

      //load textures.
      else if iStr = 'texture0' then //read texture0
      begin
        if iMat <> nil then
          iMat.Textures[0] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture1' then //read texture1
      begin
        if iMat <> nil then
          iMat.Textures[1] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture2' then //read texture2
      begin
        if iMat <> nil then
          iMat.Textures[2] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture3' then //read texture3
      begin
        if iMat <> nil then
          iMat.Textures[3] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture4' then //read texture4
      begin
        if iMat <> nil then
          iMat.Textures[4] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture5' then //read texture5
      begin
        if iMat <> nil then
          iMat.Textures[5] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture6' then //read texture6
      begin
        if iMat <> nil then
          iMat.Textures[6] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end
      else if iStr = 'texture7' then //read texture7
      begin
        if iMat <> nil then
          iMat.Textures[7] :=  TTexture( Engine.Resources.Load(  ExtractFilePath(aName) + GetNextToken(iFile) ) );
        continue;
      end

      else if iStr = 'scale' then //read the material and load the texture
      begin
        if iMat <> nil then
          iMat.Scale := StrToFloat(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'bias' then //read the material and load the texture
      begin
        if iMat <> nil then
          iMat.Bias := StrToFloat(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'alpha' then //read the material and load the texture
      begin
        if iMat <> nil then
          iMat.Alpha := StrToFloat(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'glowcolor' then //read the material and load the texture
      begin
        if iMat <> nil then
          iMat.GlowColor := Vector3f( StrToFloat(GetNextToken(iFile)),
                                      StrToFloat(GetNextToken(iFile)),
                                      StrToFloat(GetNextToken(iFile)) );
        continue;
      end;
    end;

    FreeAndNil(iFile);
  except
    on E: Exception do
    begin
      Engine.Log.Print('MTLLoader: ', 'Failed To Load Resource: ' + Engine.BasePath + aName);
      Engine.Log.Print('MTLLoader: ', E.Message, true);
    end;
  end;

  iMat := nil;
  result := TResource.Create();
  result.Name := aName;
end;

end.
