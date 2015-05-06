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
unit SpotLightEntity;

{$MODE Delphi}

interface

uses
  dglOpenGL,
  Math,
  Entity,
  Scene,
  LightEntity,
  SysUtils,
  Mathematics;

type
  TSpotLightEntity = class (TLightEntity)
  private
    //these are properties because when changed we need to set the dirty flag.
    FOuterAngle     : Single;
    FInnerAngle     : Single;

    procedure SetOuterAngle(const aOuterAngle : Single);
    procedure SetInnerAngle(const aInnerAngle: Single);
  public
    MaxRadius      : Single;

    property OuterAngle : Single read FOuterAngle write SetOuterAngle;
    property InnerAngle : Single read FInnerAngle write SetInnerAngle;

    constructor Create(const aScene : TScene; const aIntensity, aOuterAngle, aInnerAngle : Single; const aColor : TVector3f; const aCastShadows : Boolean);
    Destructor  Destroy(); override;

    procedure CalculateBoundingVolume(); override;
    function  IsVisible(): Boolean; override;
    procedure RenderBoundingVolume(); override;

    function Copy(const aScene : Pointer): TEntity; override;
  end;

implementation

uses
  Base;

procedure TSpotLightEntity.SetOuterAngle(const aOuterAngle : Single);
begin
  if aOuterAngle > 90 then
    FOuterAngle := 90
  else if aOuterAngle < 0 then
    FOuterAngle := 0
  else
    FOuterAngle := aOuterAngle;
  Dirty := true;
end;

procedure TSpotLightEntity.SetInnerAngle(const aInnerAngle: Single);
begin
  if aInnerAngle > FOuterAngle then
    FInnerAngle := FOuterAngle
  else
    FInnerAngle := aInnerAngle;
  Dirty := true;
end;

constructor TSpotLightEntity.Create(const aScene : TScene; const aIntensity, aOuterAngle, aInnerAngle : Single; const aColor : TVector3f; const aCastShadows : Boolean);
begin
  inherited Create(aScene, aIntensity, aColor, aCastShadows);
  EntityType   := ET_SPOTLIGHT;
  aScene.AddEntity( self );
  self.Name := 'SpotLight' + IntToStr(aScene.SpotLightCount);
  SetOuterAngle(aOuterAngle);
  SetInnerAngle(aInnerAngle);
end;

Destructor  TSpotLightEntity.Destroy();
begin
  inherited Destroy();
end;

procedure  TSpotLightEntity.CalculateBoundingVolume();
var
  iSize : Single;
  aDir, iPos : TVector3f;
begin
  if Dirty = false then exit;
  iSize := Radius * tan(DegToRad(FOuterAngle));
  MaxRadius := sqrt(Radius*Radius + iSize*iSize);
  aDir := GetDirection();
  aDir.RotateX(FOuterAngle);
  iPos := (GetPosition() + (aDir * MaxRadius));
  BoundingSphere.center := (GetPosition() + (GetDirection() * Radius * 0.5 ));
  BoundingSphere.radius := (iPos - BoundingSphere.center).Length();
  Dirty := false;
end;

function  TSpotLightEntity.IsVisible(): Boolean;
begin
  result := Engine.CurrentCamera.SphereInFrustum(BoundingSphere);
end;

procedure TSpotLightEntity.RenderBoundingVolume();
var
  iXYSize : Single;
begin
  glPushMatrix();
    glMultMatrixf( @Matrix.data[0] );
    iXYSize := Radius * tan(DegToRad(FOuterAngle));
    glScalef(iXYSize, iXYSize, Radius);
    Engine.Renderer.RenderCone(true);
  glPopMatrix();
end;

function TSpotLightEntity.Copy(const aScene : Pointer): TEntity;
var
  iEntity : TSpotLightEntity;
begin
  iEntity := TSpotLightEntity.Create(TScene(aScene), Intensity, FOuterAngle, FInnerAngle, Color, CastShadows);
  CopyBase(iEntity);
  result := iEntity;
end;

end.
