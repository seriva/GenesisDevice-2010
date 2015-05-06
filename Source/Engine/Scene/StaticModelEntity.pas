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
unit StaticModelEntity;

{$MODE Delphi}

interface

uses
  dglOpenGL,
  Entity,
  Mesh,
  Scene,
  SysUtils,
  FloatArray,
  Material,
  Mathematics,
  ModelEntity;

type
  TStaticModelEntity = class (TModelEntity)
  private
  public
    Mesh            : TMesh;
    CustomMaterials : TCustomMaterialArray;

    constructor Create(const aScene : TScene; const aFileName : String);
    Destructor  Destroy(); override;

    procedure Update(); override;
    procedure CalculateBoundingVolume(); override;

    procedure Render(const aMaterials, aForSelection : Boolean); override;
    procedure RenderNormals(); override;

    function Copy(const aScene : Pointer): TEntity; override;
  end;

implementation

uses
  Resource,
  Base;

constructor TStaticModelEntity.Create(const aScene : TScene; const aFileName : String );
var
  iI : Integer;
begin
  inherited Create(aFileName);
  EntityType  := ET_STATICMODEL;
  aScene.AddEntity( self );
  Mesh := Engine.Resources.Load( aFileName ) as TMesh;
  self.Name := 'Model' + IntToStr(aScene.ModelCount);
  TrisCount := Mesh.TrisCount;
  CustomMaterials := TCustomMaterialArray.Create();
  for iI := 0 to Mesh.Surfaces.Count-1 do
    CustomMaterials.Add(TCustomMaterial.Create());
end;

Destructor  TStaticModelEntity.Destroy();
begin
  inherited Destroy();
  Engine.Resources.Remove( TResource(Mesh) );
  FreeAndNil(CustomMaterials);
end;

procedure TStaticModelEntity.Update();
begin
  inherited Update();
end;

procedure TStaticModelEntity.Render(const aMaterials, aForSelection : Boolean);
begin
  glPushMatrix();
    glMultMatrixf( @Matrix.data[0] );
    glScalef(Scale, Scale, Scale );
    Mesh.CustomMaterials := CustomMaterials;
    Mesh.Render(aMaterials, aForSelection);
    Mesh.CustomMaterials := nil;
  glPopMatrix();
end;

procedure TStaticModelEntity.RenderNormals();
begin
  glPushMatrix();
    glMultMatrixf( @Matrix.data[0] );
    glScalef(Scale, Scale, Scale );
    Mesh.RenderNormals(Scale);
  glPopMatrix();
end;

procedure TStaticModelEntity.CalculateBoundingVolume();
var
  iI : Integer;
  iVertexArray : TFloatArray;
begin
  if Dirty = false then exit;
  if Usage = EU_DYNAMIC then
    BoundingBox := CalculateAABBFromAABB(Mesh.BoundingBox)
  else
  begin
    iVertexArray := TFloatArray.Create();
    for iI := 0 to Mesh.Vertices.Data.CountVector3f() do
      iVertexArray.AddVector3f( Matrix_ApplyToVector3f( Matrix, (Mesh.Vertices.Data.GetVector3f(iI) * Scale) ));
    BoundingBox := iVertexArray.CalculateBoundingBox();
    FreeAndNil(iVertexArray);
  end;
  Dirty := false;
end;

function TStaticModelEntity.Copy(const aScene : Pointer): TEntity;
var
  iEntity : TStaticModelEntity;
begin
  iEntity := TStaticModelEntity.Create(TScene(aScene), self.FileName);
  CopyBase(iEntity);
  iEntity.CastShadows := CastShadows;
  result := iEntity;
end;

end.
