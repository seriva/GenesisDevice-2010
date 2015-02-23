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
unit Model;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  Mesh,
  Mathematics,
  Resource;

type
  TWeight = record
    Joint : Integer;
    W	  : Single;
    Pos   : TVector3f;
  end;

  TModelMesh = record
    Mesh       : TMesh;
    Weights	   : array of TWeight;
    WeightData : array of array[0..1] of Integer;

    procedure Clear();
  end;

  TJoint = record
    Pos      : TVector3f;
    Quat     : TQuaternion;
    Parent   : Integer;
  end;

  TFrame = Record
    AABB    : TBoundingBox;
    AniComp : array of Single;
    Joints  : array of TJoint;

    procedure Clear();
  end;

  TAnimation = Record
    NumAniComp : Integer;
    NumFrames  : Integer;
    FrameRate  : Integer;
    Frames 	   : array of TFrame;
    BaseJoints : array of TJoint;
    JointInfo  : array of array[0..2] of Integer;

    procedure Clear();
  end;

  {$define TYPED_MAP_TEMPLATE}
  TYPED_MAP_ITEM = TAnimation;
  {$INCLUDE '..\Templates\Map.tpl'}

  TAnimationMap = class(TYPED_MAP)
  private
    procedure OnRemoveItem(var aItem : TYPED_MAP_ITEM); override;
  public
  end;

  TModel = class (TResource)
  private
  public
    Meshes     : array of TModelMesh;
    Joints     : array of TJoint;
    Animations : TAnimationMap;

    constructor Create();
    destructor  Destroy(); override;
    procedure   AddMesh();
    procedure   AddAnimation(const aName : String);

    function    GetTrisCount(): Integer;
  end;

implementation

{$INCLUDE '..\Templates\Map.tpl'}

procedure TModelMesh.Clear();
begin
  FreeAndNil(Mesh);
  setLength(Weights, 0);
  setLength(WeightData, 0);
end;

procedure TFrame.Clear();
begin
  setLength(AniComp, 0);
  setLength(Joints, 0);
end;

procedure TAnimation.Clear();
var
  iI : Integer;
begin
  for iI := 0 to Length(Frames)-1 do Frames[iI].Clear();
  setLength(Frames, 0);
  setLength(BaseJoints, 0);
  setLength(JointInfo, 0);
end;

procedure TAnimationMap.OnRemoveItem(var aItem : TAnimation);
begin
  aItem.Clear();
end;

constructor TModel.Create();
begin
  inherited Create();
  Animations := TAnimationMap.Create();
end;

destructor  TModel.Destroy();
var
  iI : Integer;
begin
  inherited Destroy();

  //clear the model meshes
  for iI := 0 to Length(Meshes)-1 do
    Meshes[iI].Clear();
  setLength(Meshes, 0);

  //clear the model joints
  setLength(Joints, 0);

  //clear the animations
  Animations.Clear();
  FreeAndNil(Animations);
end;

procedure TModel.AddMesh();
var
  iI : Integer;
begin
  SetLength(Meshes, Length(Meshes)+1);
  iI := Length(Meshes)-1;
  Meshes[iI].Mesh := TMesh.Create();
  Meshes[iI].Mesh.AddSurface('');
  Meshes[iI].Mesh.UVS.Used := true;
  FreeAndNil(Meshes[iI].Mesh.Vertices);
  FreeAndNil(Meshes[iI].Mesh.Normals);
end;

procedure TModel.AddAnimation(const aName : String);
var
  iAnimation : TAnimation;
begin
  Animations.Add( aName, iAnimation );
end;

function  TModel.GetTrisCount(): Integer;
var
  iI : Integer;
begin
  result := 0;
  for iI := 0 to Length(Meshes)-1 do
    result := result + Meshes[iI].Mesh.TrisCount;
end;

end.
