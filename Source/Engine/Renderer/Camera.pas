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
unit Camera;

{$MODE Delphi}

interface

uses
  dglOpenGL,
  Mathematics;

type
  TCamera = class
  private
    FProjectionMatrix : TMatrix4x4;
    FModelviewMatrix  : TMatrix4x4;
    FPlanes           : array[0..5] of TPlane;

    function GetInvModelViewMatrix() : TMatrix4x4;
  public
    constructor Create();
    Destructor  Destroy(); override;

    procedure SetPerspectiveProjection(const aFov, aAspect, aNearPlane, aFarPlane : single);
    procedure SetOrthogonalProjection(const aLeft, aRight, aTop, aBottom, aNearPlane, aFarPlane : single);
    procedure SetModelViewMatrix(const aMatrix : TMatrix4x4);
    function  GetModelViewMatrix(): TMatrix4x4;
    function  GetProjectionModelViewMatrix(): TMatrix4x4;

    procedure SetPosition(const aP : TVector3f);
    function  GetPosition(): TVector3f;
    function  GetDirection(): TVector3f;

    procedure SetRotationE(const aR : TEuler);
    function  GetRotationE(): TEuler;
    procedure SetRotationAA(const aR : TAxisAngle);
    function  GetRotationAA(): TAxisAngle;

    procedure Translate(const aP : TVector3f);
    procedure RotateE(const aR : TEuler);
    procedure RotateAA(const aR : TAxisAngle);

    procedure Apply();

    function  PointInFrustum(const aPoint : TVector3f): Boolean;
    function  SphereInFrustum(const aSphere : TBoundingSphere): Boolean;
    function  BoxInFrustum(const aBox : TBoundingBox): Boolean;
  end;

implementation

uses
  Base;

constructor TCamera.Create();
begin
  inherited Create();
  FModelviewMatrix := Matrix_Identity();
  SetPerspectiveProjection(60, 4/3, 0.1, 50);
end;

Destructor  TCamera.Destroy();
begin
  inherited Destroy();
end;

procedure TCamera.SetPerspectiveProjection(const aFov, aAspect, aNearPlane, aFarPlane : single);
begin
  FProjectionMatrix := Matrix_CreatePerspective(aFov, aAspect, aNearPlane, aFarPlane);
end;

procedure TCamera.SetOrthogonalProjection(const aLeft, aRight, aTop, aBottom, aNearPlane, aFarPlane : single);
begin
  FProjectionMatrix := Matrix_CreateOrtho(aLeft, aRight, aBottom, aTop, aNearPlane, aFarPlane);
end;

function TCamera.GetInvModelViewMatrix() : TMatrix4x4;
begin
  result := Matrix_Copy(FModelviewMatrix);
  Matrix_Inverse(result);
end;

procedure TCamera.SetModelViewMatrix(const aMatrix : TMatrix4x4);
begin
  FModelviewMatrix := Matrix_Copy( aMatrix );
end;

function  TCamera.GetProjectionModelViewMatrix(): TMatrix4x4;
begin
  result := GetInvModelViewMatrix();
  result  := Matrix_Multiply(result, FProjectionMatrix);
end;

function  TCamera.GetModelViewMatrix(): TMatrix4x4;
begin
  result := Matrix_Copy( FModelviewMatrix );
end;

procedure TCamera.SetPosition(const aP : TVector3f);
begin
  Matrix_SetTranslation( FModelviewMatrix, aP );
end;

function  TCamera.GetPosition(): TVector3f;
begin
  result := Matrix_GetTranslation( FModelviewMatrix );
end;

function  TCamera.GetDirection(): TVector3f;
var
  iM : TMatrix4x4;
  iE : TEuler;
begin
  result.SetValues(0,0,-1);
  iE := Matrix_GetRotationE(FModelviewMatrix);
  iM := Matrix_CreateRotationE( iE );
  result := Matrix_ApplyToVector3f( iM, result );
  result.Normalize();
end;

procedure TCamera.SetRotationE(const aR : TEuler);
begin
  Matrix_SetRotationE(FModelviewMatrix, aR);
end;

function  TCamera.GetRotationE(): TEuler;
begin
  result := Matrix_GetRotationE(FModelviewMatrix);
end;

procedure TCamera.SetRotationAA(const aR : TAxisAngle);
begin
  Matrix_SetRotationAA(FModelviewMatrix, aR);
end;

function  TCamera.GetRotationAA(): TAxisAngle;
begin
  result := Matrix_GetRotationAA(FModelviewMatrix);
end;

procedure TCamera.Translate(const aP : TVector3f);
begin
  Matrix_Translate( FModelviewMatrix, aP );
end;

procedure TCamera.RotateE(const aR : TEuler);
begin
  Matrix_RotateE( FModelviewMatrix, aR );
end;

procedure TCamera.RotateAA(const aR : TAxisAngle);
begin
  Matrix_RotateAA( FModelviewMatrix, aR );
end;

procedure TCamera.Apply();
var
  iProj : TMatrix4x4;
  iA, iB, iC, iD : Single;
begin
  Engine.CurrentCamera := self;

  //get projection matrix
  iProj := GetProjectionModelViewMatrix();

  //set the opengl matrices
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf( @iProj.data[0] );
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  //right plane
  iA := iProj.data[0,3] - iProj.data[0,0];
  iB := iProj.data[1,3] - iProj.data[1,0];
  iC := iProj.data[2,3] - iProj.data[2,0];
  iD := iProj.data[3,3] - iProj.data[3,0];
  FPlanes[0] := Plane_ABCD(iA, iB, iC, iD);

  //left plane
  iA := iProj.data[0,3] + iProj.data[0,0];
  iB := iProj.data[1,3] + iProj.data[1,0];
  iC := iProj.data[2,3] + iProj.data[2,0];
  iD := iProj.data[3,3] + iProj.data[3,0];
  FPlanes[1] := Plane_ABCD(iA, iB, iC, iD);

  //bottom plane
  iA := iProj.data[0,3] + iProj.data[0,1];
  iB := iProj.data[1,3] + iProj.data[1,1];
  iC := iProj.data[2,3] + iProj.data[2,1];
  iD := iProj.data[3,3] + iProj.data[3,1];
  FPlanes[2] := Plane_ABCD(iA, iB, iC, iD);

  //top plane
  iA := iProj.data[0,3] - iProj.data[0,1];
  iB := iProj.data[1,3] - iProj.data[1,1];
  iC := iProj.data[2,3] - iProj.data[2,1];
  iD := iProj.data[3,3] - iProj.data[3,1];
  FPlanes[3] := Plane_ABCD(iA, iB, iC, iD);

  //front plane
  iA := iProj.data[0,3] - iProj.data[0,2];
  iB := iProj.data[1,3] - iProj.data[1,2];
  iC := iProj.data[2,3] - iProj.data[2,2];
  iD := iProj.data[3,3] - iProj.data[3,2];
  FPlanes[4] := Plane_ABCD(iA, iB, iC, iD);

  //back plane
  iA := iProj.data[0,3] + iProj.data[0,2];
  iB := iProj.data[1,3] + iProj.data[1,2];
  iC := iProj.data[2,3] + iProj.data[2,2];
  iD := iProj.data[3,3] + iProj.data[3,2];
  FPlanes[5] := Plane_ABCD(iA, iB, iC, iD);
end;

function TCamera.PointInFrustum(const aPoint : TVector3f): Boolean;
var
  iI : Integer;
begin
  result := false;
  for iI := 0 to 5 do
    if Plane_Vec3fDist(FPlanes[iI], aPoint) <= 0 then exit;
  result := true;
end;

function TCamera.SphereInFrustum(const aSphere : TBoundingSphere): Boolean;
var
  iI : Integer;
begin
  if((aSphere.center - self.GetPosition()).Length()) <= aSphere.radius  then
  begin
    result := true;
    exit;
  end;
  result := false;
  for iI := 0 to 5 do
    if Plane_Vec3fDist(FPlanes[iI], aSphere.center) <= -aSphere.radius*2 then exit;
  result := true;
end;

function TCamera.BoxInFrustum(const aBox : TBoundingBox): Boolean;
var
  iI : Integer;
begin
  result := false;
  with aBox do
  begin
    for iI := 0 to 5 do
    begin
      if FPlanes[iI].a * min.X + FPlanes[iI].b * min.Y + FPlanes[iI].c * min.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * max.X + FPlanes[iI].b * min.Y + FPlanes[iI].c * min.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * min.X + FPlanes[iI].b * max.Y + FPlanes[iI].c * min.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * max.X + FPlanes[iI].b * max.Y + FPlanes[iI].c * min.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * min.X + FPlanes[iI].b * min.Y + FPlanes[iI].c * max.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * max.X + FPlanes[iI].b * min.Y + FPlanes[iI].c * max.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * min.X + FPlanes[iI].b * max.Y + FPlanes[iI].c * max.Z + FPlanes[iI].d > 0 then continue;
      if FPlanes[iI].a * max.X + FPlanes[iI].b * max.Y + FPlanes[iI].c * max.Z + FPlanes[iI].d > 0 then continue;
      exit;
    end;
  end;
  result := true;
end;

end.
