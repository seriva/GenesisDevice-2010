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
unit LightEntity;

{$MODE Delphi}

interface

uses
  dglOpenGL,
  Math,
  Entity,
  Scene,
  SBuffer,
  SysUtils,
  Mathematics;

type
  TLightEntity = class (TEntity)
  private
  public
    ShadowBuffer   : TShadow;
    CastShadows    : Boolean;
    Color          : TVector3f;
    Intensity      : Single;
    BoundingSphere : TBoundingSphere;

    property Radius : Single read Scale write setScale;

    constructor Create(const aScene : TScene; const aIntensity : Single; const aColor : TVector3f; const aCastShadows : Boolean);
    Destructor  Destroy(); override;

    function  IsVisible(): Boolean; override;
    procedure Render();
  end;

implementation

uses
  Base;

constructor TLightEntity.Create(const aScene : TScene; const aIntensity : Single; const aColor : TVector3f; const aCastShadows : Boolean);
begin
  inherited Create();
  CastShadows  := aCastShadows;
  Intensity    := aIntensity;
  Color        := aColor;
end;

Destructor  TLightEntity.Destroy();
begin
  inherited Destroy();
end;

function  TLightEntity.IsVisible(): Boolean;
begin
  result := Engine.CurrentCamera.SphereInFrustum(BoundingSphere);
end;

procedure TLightEntity.Render();
begin
  Engine.Renderer.RenderBoundingSphere(BoundingSphere, false);
end;

end.
