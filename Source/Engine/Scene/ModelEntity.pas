unit ModelEntity;

{$MODE Delphi}

interface

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
uses
  dglOpenGL,
  Math,
  Entity,
  Scene,
  SysUtils,
  Mathematics;

type
  TModelEntity = class (TEntity)
  private
  public
    FileName   : String;
    TrisCount   : Integer;
    CastShadows : Boolean;
    BoundingBox : TBoundingBox;

    constructor Create(const aFileName : String);
    Destructor  Destroy(); override;

    function  IsVisible(): Boolean; override;
    procedure RenderBoundingVolume(); override;

    procedure Render(const aMaterials, aForSelection : Boolean); virtual;
    procedure RenderNormals(); virtual;
  end;

implementation

uses
  Base;

constructor TModelEntity.Create(const aFileName : String);
begin
  inherited Create();
  FileName := aFileName;
  CastShadows := true;
end;

Destructor  TModelEntity.Destroy();
begin
  inherited Destroy();
end;

function TModelEntity.IsVisible(): Boolean;
begin
  result := Engine.CurrentCamera.BoxInFrustum(BoundingBox);
end;

procedure TModelEntity.RenderBoundingVolume();
begin
  Engine.Renderer.RenderBoundingBox(BoundingBox, true);
end;

procedure TModelEntity.Render(const aMaterials, aForSelection : Boolean);
begin
  //do nothing
end;

procedure TModelEntity.RenderNormals();
begin
  //do nothing
end;

end.
