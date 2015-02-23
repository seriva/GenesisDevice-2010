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
unit Entity;

{$MODE Delphi}

interface

uses
  SysUtils,
  Math,
  Mathematics,
  Timer;

type
  TEntityType  = (ET_STATICMODEL, ET_ANIMATEDMODEL, ET_POINTLIGHT, ET_SPOTLIGHT, ET_GROUP);
  TEntityUsage = (EU_STATIC, EU_DYNAMIC);
  TEntityRotation = (ER_LOCAL, ER_WORLD);

  TEntity = class;

  TEntityUpdateCallBack = procedure(const aEntity : TEntity; const aFrameTime : Int64);

  TEntity = class
  private
    FFrameStart, FFrameEnd, FFrameTime : Int64;
  public
    Dirty          : Boolean;
    EntityType     : TEntityType;
    UserData       : Pointer;
    Usage          : TEntityUsage;
    Name           : String;
    Matrix         : TMatrix4x4;
    Scale          : Single;
    UpdateCallBack : TEntityUpdateCallBack;

    constructor Create();
    Destructor  Destroy(); override;

    function  CalculateAABBFromAABB(const aAABB : TBoundingBox): TBoundingBox;
    procedure SetMatrix(const aMatrix : TMatrix4x4);
    function  GetMatrix(): TMatrix4x4;

    procedure SetPosition(const aP : TVector3f);
    function  GetPosition(): TVector3f;
    function  GetDirection(): TVector3f;

    procedure SetRotationE(const aR : TEuler);
    function  GetRotationE(): TEuler;
    procedure SetRotationAA(const aR : TAxisAngle);
    function  GetRotationAA(): TAxisAngle;

    procedure SetScale(const aSc : Single);
    function  GetScale(): Single;

    procedure Translate(const aP : TVector3f);
    procedure RotateE(const aType : TEntityRotation; const aR : TEuler);
    procedure RotateAA(const aType : TEntityRotation; const aR : TAxisAngle);
    procedure Scaling(const aSc : Single);

    procedure Update(); Virtual;
    function  IsVisible(): Boolean; Virtual; Abstract;
    procedure CalculateBoundingVolume(); Virtual; Abstract;
    procedure RenderBoundingVolume();Virtual; Abstract;

    procedure CopyBase(const aEntity : TEntity);
    function  Copy(const aScene : Pointer): TEntity; Virtual; //I know this pointer is a dirty fix for circular referencing to scene.
  end;

  {$define TYPED_ARRAY_TEMPLATE}
  TYPED_ARRAY_ITEM = TEntity;
  {$INCLUDE '..\Templates\Array.tpl'}

  TEntityArray = class(TYPED_ARRAY)
  private
    FOwnsEntities : Boolean;

    procedure OnRemoveItem(var aItem : TEntity); override;
    function  CompareItems(const aItem1, aItem2 : TEntity): boolean; override;
  public
    constructor Create(OwnsEntities : Boolean = true);
    destructor  Destroy(); override;
  end;

implementation

uses
  Base,
  FloatArray;

{$INCLUDE '..\Templates\Array.tpl'}

constructor TEntityArray.Create(OwnsEntities : Boolean);
begin
  inherited Create();
  FOwnsEntities := OwnsEntities;
end;

destructor  TEntityArray.Destroy();
begin
  inherited Destroy();
end;

procedure TEntityArray.OnRemoveItem(var aItem : TEntity);
begin
  if FOwnsEntities then
    FreeAndNil(aItem);
end;

function TEntityArray.CompareItems(const aItem1, aItem2 : TEntity): boolean;
begin
  result := aItem1 = aItem2;
end;

constructor TEntity.Create();
begin
  inherited Create();
  Usage   := EU_STATIC;
  Dirty   := True;
  Name    := 'Entity';
  Matrix  := Matrix_Identity();
  Scale   := 1;
  UpdateCallBack := nil;
end;

Destructor TEntity.Destroy();
begin
  if assigned(UserData) then
    FreeAndNil(UserData);
  inherited Destroy();
end;

function  TEntity.CalculateAABBFromAABB(const aAABB : TBoundingBox): TBoundingBox;
var
  iVertexArray : TFloatArray;
  iI : Integer;
begin
  iVertexArray := TFloatArray.Create();
  With aAABB do
  begin
    iVertexArray.AddVector3f( Min );
    iVertexArray.AddVector3f( Max );
    iVertexArray.AddVector3f( Vector3f(Max.x, Min.Y, Min.z) );
    iVertexArray.AddVector3f( Vector3f(Max.x, Min.Y, Max.z) );
    iVertexArray.AddVector3f( Vector3f(Min.x, Min.Y, Max.z) );
    iVertexArray.AddVector3f( Vector3f(Min.x, Max.Y, Min.z) );
    iVertexArray.AddVector3f( Vector3f(Max.x, Max.Y, Min.z) );
    iVertexArray.AddVector3f( Vector3f(Min.x, Max.Y, Max.z) );
  end;
  for iI := 0 to iVertexArray.CountVector3f() do
    iVertexArray.SetVector3f( iI, Matrix_ApplyToVector3f( Matrix,  (iVertexArray.GetVector3f(iI) * Scale)));
    result := iVertexArray.CalculateBoundingBox();
  FreeAndNil(iVertexArray);
end;

procedure TEntity.SetMatrix(const aMatrix : TMatrix4x4);
begin
  Matrix := Matrix_Copy( aMatrix );
  Dirty  := True;
end;

function  TEntity.GetMatrix(): TMatrix4x4;
begin
  result := Matrix_Copy( Matrix );
end;

procedure TEntity.SetPosition(const aP : TVector3f);
begin
  Matrix_SetTranslation( Matrix, aP );
  Dirty  := True;
end;

function  TEntity.GetPosition(): TVector3f;
begin
  result := Matrix_GetTranslation( Matrix );
end;

function  TEntity.GetDirection(): TVector3f;
var
  iM : TMatrix4x4;
  iE : TEuler;
begin
  result := Vector3f(0,0,-1);
  iE := Matrix_GetRotationE(Matrix);
  iM := Matrix_CreateRotationE( iE );
  result := Matrix_ApplyToVector3f( iM, result );
  result.Normalize();
end;

procedure TEntity.SetRotationE(const aR : TEuler);
begin
  Matrix_SetRotationE(Matrix, aR);
  Dirty  := True;
end;

function  TEntity.GetRotationE(): TEuler;
begin
  result := Matrix_GetRotationE(Matrix);
  if IsNaN(result.pitch) then result.pitch := 0;
  if IsNaN(result.yaw)   then result.yaw := 0;
  if IsNaN(result.roll)  then result.roll := 0;
end;

procedure TEntity.SetRotationAA(const aR : TAxisAngle);
begin
  Matrix_SetRotationAA(Matrix, aR);
  Dirty  := True;
end;

function  TEntity.GetRotationAA(): TAxisAngle;
begin
  result := Matrix_GetRotationAA(Matrix);
end;

procedure TEntity.SetScale(const aSc : Single);
begin
  Scale := aSc;
  Dirty  := True;
end;

function  TEntity.GetScale(): Single;
begin
  result := Scale;
end;

procedure TEntity.Translate(const aP : TVector3f);
begin
  Matrix_Translate( Matrix, aP );
  Dirty := True;
end;

procedure TEntity.RotateE(const aType : TEntityRotation; const aR : TEuler);
var
  iM1, iM2 : TMatrix4x4;
  iPos : TVector3f;
begin
  case aType of
    ER_LOCAL : Matrix_RotateE( Matrix, aR );
    ER_WORLD : begin
                 iM1 := Matrix_CreateRotationE(aR);
                 iM2 := GetMatrix();
                 iPos := GetPosition();
                 Matrix_SetTranslation(iM2, Vector3f(0,0,0));
                 SetMatrix( Matrix_Multiply( iM2, iM1));
                 SetPosition(iPos);
               end;
  end;
  Dirty := True;
end;

procedure TEntity.RotateAA(const aType : TEntityRotation; const aR : TAxisAngle);
var
  iM1, iM2 : TMatrix4x4;
  iPos : TVector3f;
begin
  case aType of
    ER_LOCAL :  Matrix_RotateAA( Matrix, aR );
    ER_WORLD : begin
                 iM1 := Matrix_CreateRotationAA(aR);
                 iM2 := GetMatrix();
                 iPos := GetPosition();
                 Matrix_SetTranslation(iM2, Vector3f(0,0,0));
                 SetMatrix( Matrix_Multiply( iM2, iM1));
                 SetPosition(iPos);
               end;
  end;
  Dirty := True;
end;

procedure TEntity.Scaling(const aSc : Single);
begin
  Scale := Scale + aSc;
  Dirty := True;
end;

procedure TEntity.Update();
begin
  //execute the callback
  if Assigned(UpdateCallBack) then
  begin
    FFrameEnd   := Engine.Timer.Time();
    FFrameTime  := FFrameEnd - FFrameStart;
    FFrameStart := FFrameEnd;
    UpdateCallBack(self, FFrameTime);
  end;

  //Do a posible update for the boundingbox
  CalculateBoundingVolume();
end;

procedure TEntity.CopyBase(const aEntity : TEntity);
begin
  aEntity.Name := Name + '-copy';
  aEntity.Matrix := Matrix_Copy(Matrix);
  aEntity.Scale := Scale;
end;

function TEntity.Copy(const aScene : Pointer): TEntity;
begin
  //do nothing
end;

end.
