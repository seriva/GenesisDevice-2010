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
unit Scene;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  Camera,
  Mathematics,
  Entity;

const
  SQD_MODELS = 1;
  SQD_LIGHTS = 2;

type
  TSceneQueryData = class
  private
  public
    All            : TEntityArray;
    Models         : TEntityArray;
    StaticModels   : TEntityArray;
    AnimatedModels : TEntityArray;
    Lights         : TEntityArray;
    PointLights    : TEntityArray;
    SpotLights     : TEntityArray;

    constructor Create();
    destructor  Destroy(); override;

    procedure   Add(const aEntity : TEntity);
    procedure   Clear();
  end;

  TScene = class
  private
  public
    ModelCount      : Integer;
    PointLightCount : Integer;
    SpotLightCount  : Integer;

    Ambient         : TVector3f;
    Entities        : TEntityArray;
    VisibleEntities : TSceneQueryData;

    constructor Create();
    destructor  Destroy(); override;
    procedure   Clear();

    procedure AddEntity(const aEntity : TEntity);
    procedure RemoveEntity(const aEntity : TEntity);

    procedure EntitiesInView(const aQueryData  : TSceneQueryData; const aFlags : Integer);
    procedure EntitiesIntersectSphere(const aSphere : TBoundingSphere; const aQueryData : TSceneQueryData; const aFlags : Integer;  const aInsideOnly : boolean = false; const aLightsAsPoints : boolean = false);
    procedure EntitiesIntersectBox(const aBox : TBoundingBox; const aQueryData : TSceneQueryData; const aFlags : Integer; const aInsideOnly : boolean = false; const aLightsAsPoints : boolean = false);

    procedure Update();
  end;

implementation

uses
  Base,
  Renderer,
  ModelEntity,
  StaticModelEntity,
  AnimatedModelEntity,
  LightEntity,
  PointLightEntity,
  SpotLightEntity;

constructor TSceneQueryData.Create();
begin
  inherited Create();
  All            := TEntityArray.Create(false);
  Models         := TEntityArray.Create(false);
  StaticModels   := TEntityArray.Create(false);
  AnimatedModels := TEntityArray.Create(false);
  Lights         := TEntityArray.Create(false);
  PointLights    := TEntityArray.Create(false);
  SpotLights     := TEntityArray.Create(false);
end;

destructor TSceneQueryData.Destroy();
begin
  inherited Destroy();
  FreeAndNil(All);
  FreeAndNil(Models);
  FreeAndNil(StaticModels);
  FreeAndNil(AnimatedModels);
  FreeAndNil(Lights);
  FreeAndNil(PointLights);
  FreeAndNil(SpotLights);
end;

procedure TSceneQueryData.Add(const aEntity : TEntity);
begin
  All.Add(aEntity);
  case aEntity.EntityType of
    ET_STATICMODEL   : begin
                         StaticModels.Add(aEntity);
                         Models.Add(aEntity);
                       end;
    ET_ANIMATEDMODEL : begin
                         AnimatedModels.Add(aEntity);
                         Models.Add(aEntity);
                       end;
    ET_POINTLIGHT    : begin
                         PointLights.Add(aEntity);
                         Lights.Add(aEntity);
                       end;
    ET_SPOTLIGHT     : begin
                         SpotLights.Add(aEntity);
                         Lights.Add(aEntity);
                       end;
  end;
end;

procedure TSceneQueryData.Clear();
begin
  All.Clear();
  Models.Clear();
  StaticModels.Clear();
  AnimatedModels.Clear();
  Lights.Clear();
  PointLights.Clear();
  SpotLights.Clear();
end;

constructor TScene.Create();
begin
  inherited Create();
  ModelCount      := 0;
  PointLightCount := 0;
  SpotLightCount  := 0;
  Ambient         := Vector3f(0.2, 0.2, 0.2);
  Entities        := TEntityArray.Create(true);
  VisibleEntities := TSceneQueryData.Create();
end;

destructor  TScene.Destroy();
begin
  inherited Destroy();
  FreeAndNil(Entities);
  FreeAndNil(VisibleEntities);
end;

procedure TScene.Clear();
begin
  ModelCount      := 0;
  PointLightCount := 0;
  SpotLightCount  := 0;
  Entities.Clear();
  VisibleEntities.Clear();
end;

procedure TScene.AddEntity(const aEntity : TEntity);
begin
  if aEntity = nil then exit;
  Entities.Add( aEntity );
  case aEntity.EntityType of
    ET_STATICMODEL, ET_ANIMATEDMODEL : inc(ModelCount);
    ET_POINTLIGHT : inc(PointLightCount);
    ET_SPOTLIGHT  : inc(SpotLightCount);
  end;
end;

procedure TScene.RemoveEntity(const aEntity : TEntity);
begin
  if aEntity = nil then exit;
  case aEntity.EntityType of
    ET_STATICMODEL, ET_ANIMATEDMODEL : dec(ModelCount);
    ET_POINTLIGHT : dec(PointLightCount);
    ET_SPOTLIGHT  : dec(SpotLightCount);
  end;
  Entities.RemoveItm(aEntity);
end;

procedure TScene.EntitiesInView(const aQueryData  : TSceneQueryData; const aFlags : Integer);
var
  iI : Integer;
  iEntity : TEntity;
begin
  //first clear old lists.
  aQueryData.Clear();

  //get data for rendering and updating
  for iI := 0 to  Entities.Count-1 do
  begin
    iEntity := Entities.Get(iI);
    if iEntity.IsVisible() then
    begin
      case Entities.Get(iI).EntityType of
        ET_STATICMODEL, ET_ANIMATEDMODEL : if (aFlags and SQD_MODELS) <> 0 then aQueryData.Add( iEntity );
        ET_POINTLIGHT, ET_SPOTLIGHT      : if (aFlags and SQD_LIGHTS) <> 0 then aQueryData.Add( iEntity );
      end;
    end;
  end;
end;

procedure TScene.EntitiesIntersectSphere(const aSphere : TBoundingSphere; const aQueryData  : TSceneQueryData; const aFlags : Integer; const aInsideOnly : boolean = false; const aLightsAsPoints : boolean = false);
var
  iI : Integer;
  iEntity : TEntity;
begin
  //first clear old lists.
  aQueryData.Clear();

  //get data for rendering and updating
  for iI := 0 to  Entities.Count-1 do
  begin
    iEntity := Entities.Get(iI);
    case iEntity.EntityType of
    ET_STATICMODEL, ET_ANIMATEDMODEL :
                    if (aFlags and SQD_MODELS) <> 0 then
                    begin
                      if aInsideOnly then
                      begin
                        If Intersect_BoxInsideSphere( TModelEntity(iEntity).BoundingBox, aSphere ) then
                          aQueryData.Add( iEntity );
                      end
                      else
                      begin
                        If Intersect_BoxSphere( TModelEntity(iEntity).BoundingBox, aSphere ) then
                          aQueryData.Add( iEntity );
                      end;
                    end;
    ET_POINTLIGHT, ET_SPOTLIGHT :
                    if (aFlags and SQD_LIGHTS) <> 0 then
                    begin
                      if aLightsAsPoints then
                      begin
                        If Intersect_PointInsideSphere( iEntity.getPosition(), aSphere ) then
                          aQueryData.Add( iEntity );
                      end
                      else
                      begin
                        if aInsideOnly then
                        begin
                          If Intersect_SphereInsideSphere( TLightEntity(iEntity).BoundingSphere, aSphere ) then
                            aQueryData.Add( iEntity );
                        end
                        else
                        begin
                          If Intersect_SphereSphere( TLightEntity(iEntity).BoundingSphere, aSphere ) then
                            aQueryData.Add( iEntity );
                        end;
                      end;
                    end;
    end;
  end;
end;

procedure TScene.EntitiesIntersectBox(const aBox : TBoundingBox; const aQueryData  : TSceneQueryData; const aFlags : Integer; const aInsideOnly : boolean = false; const aLightsAsPoints : boolean = false);
var
  iI : Integer;
  iEntity : TEntity;
begin
  //first clear old lists.
  aQueryData.Clear();

  //get data for rendering and updating
  for iI := 0 to  Entities.Count-1 do
  begin
    iEntity := Entities.Get(iI);
    case iEntity.EntityType of
    ET_STATICMODEL, ET_ANIMATEDMODEL :
                    if (aFlags and SQD_MODELS) <> 0 then
                    begin
                      if aInsideOnly then
                      begin
                        If Intersect_BoxInsideBox( aBox, TModelEntity(iEntity).BoundingBox ) then
                          aQueryData.Add( iEntity );
                      end
                      else
                      begin
                        If Intersect_BoxBox( TModelEntity(iEntity).BoundingBox, aBox ) then
                          aQueryData.Add( iEntity );
                      end;
                    end;
    ET_POINTLIGHT, ET_SPOTLIGHT : if (aFlags and SQD_LIGHTS) <> 0 then
                    begin
                      if aLightsAsPoints then
                      begin
                        If Intersect_PointInsideBox( iEntity.getPosition(), aBox ) then
                          aQueryData.Add( iEntity );
                      end
                      else
                      begin
                        if aInsideOnly then
                        begin
                          If Intersect_SphereInsideBox( TLightEntity(iEntity).BoundingSphere, aBox ) then
                            aQueryData.Add( iEntity );
                        end
                        else
                        begin
                          If Intersect_BoxSphere( aBox, TLightEntity(iEntity).BoundingSphere ) then
                            aQueryData.Add( iEntity );
                        end;
                      end;
                    end;
    end;
  end;
end;

procedure TScene.Update();
var
  iI : Integer;
begin
  if (Engine.CurrentCamera = nil) then
  begin
    Engine.Log.Print(self.ClassName, 'No camera set for scene update!', false);
    exit;
  end;

  //update all entities in the scene
  for iI := 0 to  Entities.Count-1 do
    Entities.Get(iI).Update();

  //get the visible entities in view.
  EntitiesInView(VisibleEntities, SQD_MODELS or SQD_LIGHTS);

  //update posible animated entities.
  for iI := 0 to  VisibleEntities.AnimatedModels.Count-1 do
    (VisibleEntities.AnimatedModels.Get(iI) as TAnimatedModelEntity).UpdateVertices();
end;

end.
