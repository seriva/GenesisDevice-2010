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
unit PointLightEntity;

{$MODE Delphi}

interface

uses
  dglOpenGL,
  Entity,
  Scene,
  SysUtils,
  Mathematics,
  LightEntity;

type
  TPointLightEntity = class (TLightEntity)
  private
  public
    constructor Create(const aScene : TScene; const aIntensity : Single; const aColor : TVector3f; const aCastShadows : Boolean);
    Destructor  Destroy(); override;

    procedure CalculateBoundingVolume(); override;
    function  IsVisible(): Boolean; override;
    procedure RenderBoundingVolume(); override;

    function Copy(const aScene : Pointer): TEntity; override;
  end;

implementation

uses
  Base;

constructor TPointLightEntity.Create(const aScene : TScene; const aIntensity : Single; const aColor : TVector3f; const aCastShadows : Boolean);
begin
  inherited Create(aScene, aIntensity, aColor, aCastShadows);
  EntityType   := ET_POINTLIGHT;
  aScene.AddEntity( self );
  self.Name := 'PointLight' + IntToStr(aScene.PointLightCount);
end;

Destructor  TPointLightEntity.Destroy();
begin
  inherited Destroy();
end;

procedure  TPointLightEntity.CalculateBoundingVolume();
begin
  if Dirty = false then exit;
  BoundingSphere.radius := Radius;
  BoundingSphere.center := self.GetPosition();
  Dirty := false;
end;

function  TPointLightEntity.IsVisible(): Boolean;
begin
  result := Engine.CurrentCamera.SphereInFrustum(BoundingSphere);
end;

procedure TPointLightEntity.RenderBoundingVolume();
begin
  Engine.Renderer.RenderBoundingSphere(BoundingSphere, True);
end;

function TPointLightEntity.Copy(const aScene : Pointer): TEntity;
var
  iEntity : TPointLightEntity;
begin
  iEntity := TPointLightEntity.Create(TScene(aScene), Intensity, Color, CastShadows);
  CopyBase(iEntity);
  result := iEntity;
end;

end.
