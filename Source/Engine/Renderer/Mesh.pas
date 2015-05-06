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
unit Mesh;

{$MODE Delphi}

interface

uses
  SysUtils,
  Classes,
  dglOpenGL,
  Mathematics,
  Resource,
  Stream,
  Surface,
  FloatArray,
  IntegerArray,
  Material;

type
  TMesh = class (TResource)
  private
  public
    BoundingBox     : TBoundingBox;
    TrisCount       : Integer;
    CustomMaterials : TCustomMaterialArray;
    Surfaces        : TSurfaceArray;
    Vertices        : TStream;
    UVS             : TStream;
    Normals         : TStream;

    constructor Create();
    destructor  Destroy(); override;

    procedure CalculateBoundingBox();
    function  SurfaceExists(const aMaterial : String): Integer;
    function  AddSurface(const aMaterial : String): Integer;
    procedure Update();
    procedure Render(const aMaterials, aForSelection : Boolean);
    procedure RenderNormals(const aScale : Single);
  end;

implementation

uses
  Base;

constructor TMesh.Create();
begin
  inherited Create();
  Surfaces  := TSurfaceArray.Create();
  Vertices  := TStream.Create();
  Normals   := TStream.Create();
  UVS       := TStream.Create();
  CustomMaterials := nil;
end;

destructor  TMesh.Destroy();
begin
  inherited Destroy();
  FreeAndNil(Surfaces);
  FreeAndNil(Vertices);
  FreeAndNil(Normals);
  FreeAndNil(UVS);
end;

procedure TMesh.CalculateBoundingBox();
begin
  BoundingBox := Vertices.Data.CalculateBoundingBox();
end;

function TMesh.SurfaceExists(const aMaterial : String): Integer;
var
  iI : Integer;
begin
  result := -1;
  for iI := 0 to Surfaces.Count - 1 do
  begin
    if Surfaces.get(iI).MatName = aMaterial then
    begin
      result := iI;
      break;
    end;
  end;
end;

function  TMesh.AddSurface(const aMaterial : String): Integer;
var
  iSurface : TSurface;
begin
  iSurface := TSurface.Create();
  iSurface.MatName := aMaterial;
  result := Surfaces.Add( iSurface );
end;

procedure TMesh.Update();
var
  iI : Integer;
begin
  //update surfaces
  for iI := 0 to Surfaces.Count - 1 do
  begin
    Surfaces.get(iI).Update();
    TrisCount := TrisCount + (Surfaces.get(iI).Data.Count div 3);
  end;
  
  //update streams
  if Vertices <> nil then if Vertices.Used then Vertices.Update();
  if Normals <> nil then if Normals.Used then Normals.Update();
  if UVS <> nil then if UVS.Used then UVS.Update();
end;

procedure TMesh.Render(const aMaterials, aForSelection : Boolean);
var
  iI, iJ : Integer;
  iSurface : TSurface;
  iIndexes : TVector3i;
  iVertex  : TVector3f;
begin
  //on nvidia glDrawElements crashes for some unknow reason so use this for now.
  //note this only supports triangles.
  if aForSelection then
  begin
    for iI := 0 to Surfaces.Count - 1 do
    begin
      iSurface := Surfaces.get(iI);
      glBegin(GL_TRIANGLES);
      for iJ := 0 to iSurface.Data.CountVector3i() - 1 do
      begin
        iIndexes := iSurface.Data.GetVector3i(iJ);
        iVertex := Vertices.Data.GetVector3f( iIndexes.x ); glVertex3fv(@iVertex.x);
        iVertex := Vertices.Data.GetVector3f( iIndexes.y ); glVertex3fv(@iVertex.x);
        iVertex := Vertices.Data.GetVector3f( iIndexes.z ); glVertex3fv(@iVertex.x);
      end;
      glEnd();
    end;
    exit;
  end;

  //enable client states and bind buffers
  //vertex
  glEnableClientState(GL_VERTEX_ARRAY);
  glBindBuffer(GL_ARRAY_BUFFER, Vertices.BufferID);
  glVertexPointer(3, GL_FLOAT, 0, nil);

  //normal
  if Normals.Used then
  begin
    glEnableClientState(GL_NORMAL_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, Normals.BufferID);
    glNormalPointer(GL_FLOAT, 0, nil);
  end;
  //uv
  if UVS.Used then
  begin
    glClientActiveTextureARB(GL_TEXTURE0);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, UVS.BufferID);
    glTexCoordPointer(2, GL_FLOAT, 0, nil);
  end;
  
  //render surfaces
  glEnableClientState(GL_INDEX_ARRAY);
  for iI := 0 to Surfaces.Count - 1 do
  begin
    iSurface := Surfaces.get(iI);
    if aMaterials then
    begin
      if CustomMaterials <> nil then
        iSurface.ApplyMaterial(CustomMaterials.Get(iI))
      else
        iSurface.ApplyMaterial(nil);
    end;

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, iSurface.BufferID);
    glDrawElements(iSurface.Primitive, iSurface.Data.Count , GL_UNSIGNED_INT, nil);
  end;
  glDisableClientState(GL_INDEX_ARRAY);
  
  //disable client states and unbind buffers
  //buffers
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);  
  //vertex
  glDisableClientState(GL_VERTEX_ARRAY);

  //normals
  if Normals.Used then glDisableClientState(GL_NORMAL_ARRAY);
  //uv
  if UVS.Used then
  begin
	    glClientActiveTextureARB(GL_TEXTURE0);
	    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  end;
end;

procedure TMesh.RenderNormals(const aScale : Single);
var
  iJ       : Integer;
  iV1, iV2 : TVector3f;
begin
  //normals
  if Normals.Used then
  begin
    Engine.Renderer.SetColor(1,0,0,1);
    glBegin(GL_LINES);
      for iJ := 0 to Vertices.Data.CountVector3f() - 1 do
      begin
        iV1 := Normals.Data.GetVector3f(iJ) / 17.5;
        iV2 := Vertices.Data.GetVector3f(iJ);
        iV1 := iV1 / aScale;
        iV1 := iV1 + iV2;
        glVertex3fv(@iV2.x);
        glVertex3fv(@iV1.x);
      end;
    glEnd();
  end;
end;

end.
