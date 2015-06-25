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
unit Configuration;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Mathematics;

type
  TConfigurationForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
  public
    //viewport global
    Scale            : Single;
    MeshSelectColor  : TVector3f;

    //viewport 3D
    ClearColor3D     : TVector4f;
    GridSize3D       : Single;
    GridStep3D       : Single;
    Fov3D            : Single;
    NearPlane3D      : Single;
    FarPlane3D       : Single;
    GridColor3D      : TVector3f;
    StartPos3D       : TVector3f;
    ZoomStep3D       : Single;

    //viewport 3D
    ZoomMin2D        : Single;
    ZoomMax2D        : Single;
    ZoomStep2D       : Single;
    ClearColor2D     : TVector4f;
    LargeGridStep2D  : Single;
    SmallGridStep2D  : Single;
    LargeGridColor2D : TVector3f;
    SmallGridColor2D : TVector3f;
    MeshColor2D      : TVector3f;

    //global editor vars
    MapDir : String;
    ModelDir : String;

    procedure Reset();
  end;
  
implementation

{$R *.lfm}

procedure TConfigurationForm.FormCreate(Sender: TObject);
begin
  Reset();
end;

procedure TConfigurationForm.Reset();
begin
  //viewport global
  Scale            := 0.06;
  MeshSelectColor  := Vector3f(1, 0, 0);

  //viewport 3D
  ClearColor3D     := Vector4f(0,0,0,0);
  GridSize3D       := 256;
  GridStep3D       := 1;
  Fov3D            := 45;
  NearPlane3D      := 0.1;
  FarPlane3D       := 128;
  GridColor3D      := Vector3f(0, 0, 0.4);
  StartPos3D.X     := 0;
  StartPos3D.Y     := 2;
  StartPos3D.Z     := 0;
  ZoomStep3D       := 2;

  //viewport 2D
  ZoomMin2D        := 0.005;
  ZoomMax2D        := 0.200;
  ZoomStep2D       := 0.005;
  ClearColor2D     := Vector4f(0.25, 0.25, 0.25, 1);
  LargeGridStep2D  := 4;
  SmallGridStep2D  := 0.5;
  LargeGridColor2D := Vector3f(0.5, 0.5, 0.5);
  SmallGridColor2D := Vector3f(0.35, 0.35, 0.35);
  MeshColor2D      := Vector3f(1, 1, 1);

  //global editor vars
  MapDir := 'Maps\';
  ModelDir := 'Models\'
end;

end.
