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
unit OBJLoader;

{$MODE Delphi}

interface

uses
  SysUtils,
  Classes,
  Resource,
  Mathematics,
  ResourceUtils,
  Mesh, FileUtil;

function LoadOBJResource(const aName : String): TResource;

implementation

uses
  Base;

function LoadOBJResource(const aName : String): TResource;
var
	iFile      : TMemoryStream;
  iMesh      : TMesh;
  iI         : Integer;
  iVertices  : array of TVector3f;
  iNormals   : array of TVector3f;
  iUVS       : array of TVector2f;
  iStr       : String;
  iCurMat    : String;
  iCurSurf   : Integer;

procedure ParseFace(const aStr : String);
var
  iJ, iCount : Integer;
  iSubStr : String;
  iIdx : array[0..2] of integer;
begin
  iSubStr := '';
  iCount := 0;
  for iJ := 1 to length(aStr) do
  begin
    if aStr[iJ] <> '/' then
    begin
      iSubStr := iSubStr + aStr[iJ];
    end
    else
    begin
      if iSubStr = '' then
         iIdx[iCount] := -1
      else
      begin
        iIdx[iCount] := StrToInt(iSubStr)-1;
        iSubStr := '';
      end;
      Inc(iCount);
    end;
  end;
  iIdx[iCount] := StrToInt(iSubStr)-1;

  iMesh.Vertices.Data.AddVector3f( iVertices[iIdx[0]] );
  if iIdx[1] = -1 then
    iMesh.UVS.Data.AddVector2f(Vector2f(1,1))
  else
    iMesh.UVS.Data.AddVector2f(iUVS[iIdx[1]]);
  iMesh.Normals.Data.AddVector3f( iNormals[iIdx[2]] );

  iMesh.Surfaces.get(iCurSurf).Data.Add( iMesh.Vertices.Data.CountVector3f() );
end;

begin
  try
    //check if the file exists
    if Not(FileExistsUTF8(Engine.BasePath + aName ) { *Converted from FileExists* }) then
      Raise Exception.Create(Engine.BasePath + aName + ' doesn`t exists');

    //create the filestream
    iFile := TMemoryStream.Create();
    iFile.LoadFromFile(Engine.BasePath + aName);

    //init the mesh
    iMesh := TMesh.Create();
    iMesh.Name := aName;

    //set the comment string
    CommentString := '//';

    while (iFile.Position < iFile.Size) do
    begin
      iStr := GetNextToken(iFile);
      if iStr = 'mtllib' then //read the material lib
      begin
        Engine.Resources.Load( ExtractFilePath(aName) + GetNextToken(iFile) );
        continue;
      end
      else if iStr = 'v' then //read a vertex
      begin
        iMesh.Vertices.Used := true;
        setLength( iVertices, Length(iVertices) + 1);
        iI := Length(iVertices)-1;
        iVertices[iI].x := StrToFloat(GetNextToken(iFile));
        iVertices[iI].y := StrToFloat(GetNextToken(iFile));
        iVertices[iI].z := StrToFloat(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'vt' then //read a uv
      begin
        iMesh.UVS.Used := true;
        setLength( iUVS, Length(iUVS) + 1);
        iI := Length(iUVS)-1;
        iUVS[iI].x :=  StrToFloat(GetNextToken(iFile));
        iUVS[iI].y :=  -StrToFloat(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'vn' then //read a normal
      begin
        iMesh.Normals.Used := true;
        setLength( iNormals, Length(iNormals) + 1);
        iI := Length(iNormals)-1;
        iNormals[iI].x := StrToFloat(GetNextToken(iFile));
        iNormals[iI].y := StrToFloat(GetNextToken(iFile));
        iNormals[iI].z := StrToFloat(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'usemtl' then //read the current material for the faces
      begin
        iCurMat  :=  'mat_' + GetNextToken(iFile);
        iCurSurf := iMesh.SurfaceExists(iCurMat);
        if iCurSurf = -1 then
          iCurSurf := iMesh.AddSurface(iCurMat);
        continue;
      end
      else if iStr = 'f' then //read a face (we only support triangles)
      begin
        ParseFace(GetNextToken(iFile));
        ParseFace(GetNextToken(iFile));
        ParseFace(GetNextToken(iFile));
        continue;
      end;
    end;
    setLength(iVertices,0);
    setLength(iNormals,0);
    setLength(iUVS,0);
    FreeAndNil(iFile);
    iMesh.CalculateBoundingBox();
    iMesh.Update();
  except
    on E: Exception do
    begin
      Engine.Log.Print('OBJLoader: ', 'Failed To Load Resource: ' + Engine.BasePath + aName);
      Engine.Log.Print('OBJLoader: ', E.Message, true);
    end;
  end;
  result := iMesh;
end;

end.
