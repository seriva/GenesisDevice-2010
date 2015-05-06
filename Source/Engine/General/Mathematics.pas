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
unit Mathematics;

interface

uses
  Math;

type
  TEuler = record
    pitch, yaw, roll: Single;

    function  Copy(): TEuler;
    class operator Equal(const aE1, aE2 : TEuler): boolean;
  end;

  TAxisAngle = record
    x, y, z  : Single;
    angle : Single;

    function  Copy(): TAxisAngle;
    class operator Equal(const aAA1, aAA2 : TAxisAngle): boolean;
  end;

  TVector2f = record
    procedure SetValues(const aX, aY : Single);
    function  Copy(): TVector2f;
    procedure Invert();
    procedure AbsV();
    procedure Max();
    procedure Min();
    function  Length(): single;
    procedure Normalize();
    function  Distance(const aV : TVector2f): single;
    function  Dot(const aV : TVector2f): single;
    function  Angle(const aV : TVector2f) : single;
    function  Spacing(const aV : TVector2f): Single;
    function  Interpolate(aV : TVector2f; const aK: single): TVector2f;
    procedure Rotate(const aAngle : Single);
    procedure RotateCenter(const aCenter: TVector2f; const aAngle : Single);

    class operator Equal(const aV1, aV2 : TVector2f): boolean;
    class operator Add(const aV1, aV2: TVector2f): TVector2f;
    class operator Add(const aV: TVector2f; const aF : Single): TVector2f;
    class operator Subtract(const aV1, aV2: TVector2f): TVector2f;
    class operator Subtract(const aV: TVector2f; const aF : Single): TVector2f;
    class operator Multiply(const aV1, aV2: TVector2f): TVector2f;
    class operator Multiply(const aV: TVector2f; const aF : Single): TVector2f;
    class operator Divide(const aV1, aV2: TVector2f): TVector2f;
    class operator Divide(const aV: TVector2f; const aF : Single): TVector2f;

    case Boolean of
      TRUE: ( x, y: Single; );
      FALSE: ( xy: array [0..1] of Single; );
  end;

  TVector3f = record
    procedure SetValues(const aX, aY, aZ : Single);
    function  Copy(): TVector3f;
    procedure Invert();
    procedure AbsV();
    procedure Max();
    procedure Min();
    function  Length(): single;
    procedure Normalize();
    function  Distance(const aV : TVector3f): single;
    function  Dot(const aV : TVector3f): single;
    function  Cross(const aV : TVector3f): TVector3f;
    function  Angle(const aV : TVector3f) : single;
    function  Spacing(const aV : TVector3f): Single;
    function  Interpolate(const aV : TVector3f; const aK: single): TVector3f;
    procedure RotateX(const aAngle : Single);
    procedure RotateCenterX(const aCenter : TVector3f; const aAngle : Single);
    procedure RotateY(const aAngle : Single);
    procedure RotateCenterY(const aCenter : TVector3f; const aAngle : Single);
    procedure RotateZ(const aAngle : Single);
    procedure RotateCenterZ(const aCenter : TVector3f; const aAngle : Single);
    procedure RotateE(const aE : TEuler);
    procedure RotateCenterE(const aCenter : TVector3f; const aE : TEuler);
    procedure RotateAA(const aAA : TAxisAngle);
    procedure RotateCenterAA(const aCenter : TVector3f;  const aAA : TAxisAngle);

    class operator Equal(const aV1, aV2 : TVector3f): boolean;
    class operator Add(const aV1, aV2: TVector3f): TVector3f;
    class operator Add(const aV: TVector3f; const aF : Single): TVector3f;
    class operator Subtract(const aV1, aV2: TVector3f): TVector3f;
    class operator Subtract(const aV: TVector3f; const aF : Single): TVector3f;
    class operator Multiply(const aV1, aV2: TVector3f): TVector3f;
    class operator Multiply(const aV: TVector3f; const aF : Single): TVector3f;
    class operator Divide(const aV1, aV2: TVector3f): TVector3f;
    class operator Divide(const aV: TVector3f; const aF : Single): TVector3f;

    case Boolean of
      TRUE: ( x, y, z: Single; );
      FALSE: ( xyz: array [0..2] of Single; );
  end;

  TVector4f = record
    procedure SetValues(const aX, aY, aZ, aW : Single);
    function  Copy(): TVector4f;
    procedure Invert();
    procedure AbsV();
    procedure Max();
    procedure Min();
    function  Length(): single;
    procedure Normalize();
    function  Distance(const aV : TVector4f): single;
    function  Dot(const aV : TVector4f): single;
    function  Cross(const aV : TVector4f): TVector4f;
    function  Angle(const aV : TVector4f) : single;
    function  Spacing(const aV : TVector4f): Single;
    function  Interpolate(const aV : TVector4f; const aK: single): TVector4f;
    procedure RotateX(const aAngle : Single);
    procedure RotateCenterX(const aCenter : TVector4f; const aAngle : Single);
    procedure RotateY(const aAngle : Single);
    procedure RotateCenterY(const aCenter : TVector4f; const aAngle : Single);
    procedure RotateZ(const aAngle : Single);
    procedure RotateCenterZ(const aCenter : TVector4f; const aAngle : Single);
    procedure RotateE(const aE : TEuler);
    procedure RotateCenterE(const aCenter : TVector4f; const aE : TEuler);
    procedure RotateAA(const aAA : TAxisAngle);
    procedure RotateCenterAA(const aCenter : TVector4f;  const aAA : TAxisAngle);

    class operator Equal(const aV1, aV2 : TVector4f): boolean;
    class operator Add(const aV1, aV2: TVector4f): TVector4f;
    class operator Add(const aV: TVector4f; const aF : Single): TVector4f;
    class operator Subtract(const aV1, aV2: TVector4f): TVector4f;
    class operator Subtract(const aV: TVector4f; const aF : Single): TVector4f;
    class operator Multiply(const aV1, aV2: TVector4f): TVector4f;
    class operator Multiply(const aV: TVector4f; const aF : Single): TVector4f;
    class operator Divide(const aV1, aV2: TVector4f): TVector4f;
    class operator Divide(const aV: TVector4f; const aF : Single): TVector4f;

    case Boolean of
      TRUE: ( x, y, z, w: Single; );
      FALSE: ( xyzw: array [0..3] of Single; );
  end;

  TMatrix4x4  = record
    data : array[0..3,0..3] of single;
  end;

  TQuaternion = record
    procedure FromEuler(const aE : TEuler);
    procedure FromAxisAngle(const aAA : TAxisAngle);
    procedure FromMatrix(const aM : TMatrix4x4);
    function  ToEuler(): TEuler;
    function  ToAxisAngle(): TAxisAngle;
    function  ToMatrix(): TMatrix4x4;
    function  Copy(): TQuaternion;
    procedure Invert();
    procedure Normalize();
    procedure BuildW();
    procedure SLerp(const aQ : TQuaternion; const aT : Single );
    function  RotateVector(const aV : TVector3f): TVector3f;

    class operator Equal(const aQ1, aQ2 : TQuaternion): boolean;
    class operator Add(const aQ1, aQ2 : TQuaternion):TQuaternion;
    class operator Subtract(const aQ1, aQ2 : TQuaternion): TQuaternion;
    class operator Multiply(const aQ1, aQ2 : TQuaternion): TQuaternion;
    class operator Multiply(const aQ : TQuaternion; const aV : TVector3f): TQuaternion;

    case Boolean of
      TRUE: ( w, x, y, z: Single; );
      FALSE: ( wxyz: array [0..3] of Single; );
  end;

  TVector2i = record
    case Boolean of
      TRUE: ( x, y: Integer; );
      FALSE: ( xy: array [0..1] of Integer; );
  end;

  TVector3i = record
    case Boolean of
      TRUE: ( x, y, z: Integer; );
      FALSE: ( xyz: array [0..2] of Integer; );
  end;

  TLine = record
    p1 : TVector3f;
    p2 : TVector3f;
  end;

  TPlane = record
    case Boolean of
      TRUE: ( a, b, c, d: Single; );
      FALSE: ( normal : TVector3f; dist: Single; );
  end;

  TBoundingBox = record
    min    : TVector3f;
    max    : TVector3f;
    center : TVector3f;
  end;

  TBoundingSphere = record
    radius : Single;
    center : TVector3f;
  end;

const
  EPSILON1   = 0.0001; // for compare of types
  EPSILON2   = 0.01;   // margin to allow for rounding errors
  EPSILON3   = 0.1;    // margin to distinguish between 0 and 180

  MIN_SINGLE = 1.5e-45;
  MAX_SINGLE = 3.4e+38;

  PI         = 3.14159265358979;
  TWOPI      = 6.28318530717958;
  PIDIV2     = 1.57079632679489;

function Euler(const aPitch, aYaw, aRoll : Single): TEuler;
function AxisAngle(const aX, aY, aZ, aAngle: Single): TAxisAngle;
function Vector2f(const aX, aY : Single): TVector2f;
function Vector3f(const aX, aY, aZ : Single): TVector3f;
function Vector4f(const aX, aY, aZ, aW : Single): TVector4f;
function Quaternion(const aW, aX, aY, aZ: Single): TQuaternion;

//TODO: convert these to record methods.
function  Matrix(Const aC1R1, aC2R1, aC3R1, aC4R1, aC1R2, aC2R2, aC3R2, aC4R2, aC1R3, aC2R3, aC3R3, aC4R3, aC1R4, aC2R4, aC3R4, aC4R4: Single): TMatrix4x4;
function  Matrix_Empty(): TMatrix4x4;
function  Matrix_Identity(): TMatrix4x4;
function  Matrix_Copy(const aM : TMatrix4x4): TMatrix4x4;
function  Matrix_Compare(const aM1, aM2 : TMatrix4x4): boolean;
function  Matrix_CreateLinearTexGen(): TMatrix4x4;
function  Matrix_CreatePerspective(const aFov, aAspect, aNearPlane, aFarPlane : Single): TMatrix4x4;
function  Matrix_CreateOrtho(const aLeft, aRight, aBottom, aTop, aZNear, aZFar: Single): TMatrix4x4;
function  Matrix_CreateRotationX(const aAngleX : single): TMatrix4x4;
function  Matrix_CreateRotationY(const aAngleY : single): TMatrix4x4;
function  Matrix_CreateRotationZ(const aAngleZ : single): TMatrix4x4;
function  Matrix_CreateRotationE(const aE : TEuler ): TMatrix4x4;
function  Matrix_CreateRotationAA(const aAA : TAxisAngle): TMatrix4x4;
function  Matrix_CreateScaleV(const aSc: TVector3f): TMatrix4x4;
function  Matrix_CreateScaleF(const aSc: Single): TMatrix4x4;
function  Matrix_CreateTranslation(const aT: TVector3f): TMatrix4x4;
function  Matrix_CreateScaleAndTranslation(const aSc,aT : TVector3f): TMatrix4x4;
procedure Matrix_RotateE(var aM : TMatrix4x4; const aE : TEuler);
procedure Matrix_RotateAA(var aM : TMatrix4x4; const aAA : TAxisAngle);
procedure Matrix_ScaleAll(var aM : TMatrix4x4; aSc: Single);
procedure Matrix_ScaleV(var aM : TMatrix4x4; const aSc: TVector3f);
procedure Matrix_ScaleF(var aM : TMatrix4x4; const aSc: Single);
procedure Matrix_Translate(var aM : TMatrix4x4; const aT: TVector3f);
procedure Matrix_SetRotationE(var aM : TMatrix4x4; const aE : TEuler);
procedure Matrix_SetRotationAA(var aM : TMatrix4x4; const aAA : TAxisAngle);
procedure Matrix_SetScaleV(var aM : TMatrix4x4; const aSc: TVector3f);
procedure Matrix_SetScaleF(var aM : TMatrix4x4; const aSc: Single);
procedure Matrix_SetTranslation(var aM : TMatrix4x4; const aT: TVector3f);
function  Matrix_GetRotationE(const aM: TMatrix4x4): TEuler;
function  Matrix_GetRotationAA(const aM: TMatrix4x4): TAxisAngle;
function  Matrix_GetScale(const aM: TMatrix4x4): TVector3f;
function  Matrix_GetTranslation(const aM: TMatrix4x4): TVector3f;
function  Matrix_Add(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
function  Matrix_Subtract(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
function  Matrix_Multiply(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
function  Matrix_Divide(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
function  Matrix_Determinant(const aM: TMatrix4x4): Single;
procedure Matrix_Transpose(var aM : TMatrix4x4);
procedure Matrix_Inverse(var aM : TMatrix4x4);
procedure Matrix_Adjoint(var aM: TMatrix4x4);
function  Matrix_ApplyToVector3f(const aM : TMatrix4x4; const aV : TVector3f ): TVector3f;
function  Matrix_ApplyToVector4f(const aM : TMatrix4x4; const aV : TVector4f ): TVector4f;

function Line(const aP1, aP2 : TVector3f): TLine;
function Line_Copy(const aLine : TLine): TLine;
function Line_Compare(const aLine1, aLine2 : TLine): boolean;

function  Plane_ABCD(const aA, aB, aC, aD: Single): TPlane;
function  Plane_NormalD(const aNormal: TVector3f; const aD: Single): TPlane;
function  Plane_Copy(const aP : TPlane): TPlane;
function  Plane_Compare(const aP1, aP2 : TPlane): boolean;
procedure Plane_Normalize(var aPlane : TPlane);
function  Plane_FromPoints3f(const aP1, aP2, aP3 : TVector3f): TPlane;
function  Plane_FromPoints4f(const aP1, aP2, aP3 : TVector4f): TPlane;
function  Plane_Vec3fDist(const aPlane : TPlane; const aP : TVector3f): Single;
function  Plane_Vec4fDist(const aPlane : TPlane; const aP : TVector4f): Single;

function Intersect_PointInsideBox( const aPoint : TVector3f;  const aBox : TBoundingBox ): boolean;
function Intersect_PointInsideSphere( const aPoint : TVector3f; const aSphere : TBoundingSphere ): boolean;
function Intersect_BoxInsideBox( const aBox1, aBox2 : TBoundingBox ): boolean;
function Intersect_BoxInsideSphere( const aBox : TBoundingBox; const aSphere : TBoundingSphere ): boolean;
function Intersect_SphereInsideSphere( const aSphere1, aSphere2 : TBoundingSphere): boolean;
function Intersect_SphereInsideBox( const aSphere : TBoundingSphere; const aBox : TBoundingBox ): boolean;
function Intersect_BoxBox( const aBox1, aBox2 : TBoundingBox  ): boolean;
function Intersect_SphereSphere( const aSphere1, aSphere2 : TBoundingSphere ): boolean;
function Intersect_BoxSphere( const aBox : TBoundingBox; const aSphere : TBoundingSphere ): boolean;
function Intersect_LineBox(const aLine : TLine; const aBox : TBoundingBox): boolean;
function Intersect_LineSphere(const aLine : TLine; const aSphere : TBoundingSphere): boolean;

function BoundingBox_Copy(const aBox : TBoundingBox): TBoundingBox;
function BoundingSphere_Copy(const aSphere : TBoundingSphere): TBoundingSphere;

implementation

Function atan2(y : extended; x : extended): Extended;
asm
  fld [y]
  fld [x]
  fpatan
end;

function Euler(const aPitch, aYaw, aRoll: Single): TEuler;
begin
  result.pitch := aPitch;
  result.yaw   := aYaw;
  result.roll  := aRoll;
end;

function  TEuler.Copy(): TEuler;
begin
  result.pitch := Pitch;
  result.yaw   := Yaw;
  result.roll  := Roll;
end;

class operator TEuler.Equal(const aE1, aE2 : TEuler): boolean;
begin
  Result := (Abs(aE1.pitch - aE2.pitch) < EPSILON1) and
            (Abs(aE1.yaw - aE2.yaw)     < EPSILON1) and
            (Abs(aE1.roll - aE2.roll)   < EPSILON1);
end;

 function AxisAngle(const aX, aY, aZ, aAngle: Single): TAxisAngle;
 begin
   result.x := aX;
   result.y := aY;
   result.z := aZ;
   result.angle := aAngle;
 end;

 function  TAxisAngle.Copy(): TAxisAngle;
 begin
   result.x := x;
   result.y := y;
   result.z := z;
   result.angle := angle;
 end;

class operator TAxisAngle.Equal(const aAA1, aAA2 : TAxisAngle): boolean;
begin
   Result := (Abs(aAA1.x - aAA2.x) < EPSILON1) and
             (Abs(aAA1.y - aAA2.y) < EPSILON1) and
             (Abs(aAA1.z - aAA2.x) < EPSILON1) and
             (Abs(aAA1.angle - aAA2.angle)   < EPSILON1);
end;

function  Vector2f(const aX, aY : Single): TVector2f;
begin
  result.X := aX;
  result.Y := aY;
end;

procedure  TVector2f.SetValues(const aX, aY : Single);
begin
  X := aX;
  Y := aY;
end;

function  TVector2f.Copy(): TVector2f;
begin
  result.X := X;
  result.Y := Y;
end;

procedure TVector2f.Invert();
begin
  X := -X;
  Y := -Y;
end;

procedure TVector2f.AbsV();
begin
  X := Abs(X);
  Y := Abs(Y);
end;

procedure  TVector2f.Max();
begin
  X := MAX_SINGLE;
  Y := MAX_SINGLE;
end;

procedure TVector2f.Min();
begin
  X := MIN_SINGLE;
  Y := MIN_SINGLE;
end;

function  TVector2f.Length(): single;
begin
  Result := sqrt((X * X) + (Y * Y));
end;

procedure TVector2f.Normalize();
var
  iMag, iLength : Single;
begin
  iMag := Length();
  if (iMag > 0.0) then
  begin
    iLength := 1.0 / iMag;
    self := self * iLength;
	end
end;

function  TVector2f.Distance(const aV : TVector2f): single;
begin
  Result := sqrt(sqr(aV.X - X) + sqr(aV.Y - Y));
end;

function  TVector2f.Dot(const aV : TVector2f): single;
begin
  Result := ((x*aV.x) + (y*aV.y));
end;

function  TVector2f.Angle(const aV : TVector2f) : single;
var
  iDotProduct : Single;
  iVectorsMagnitude : Single;
  iAngle : real;
begin
  iDotProduct       := Dot(aV);
  iVectorsMagnitude := Length() * aV.Length();
	iAngle            := arccos( iDotProduct / iVectorsMagnitude );
	if(isnan(iAngle)) then
    result := 0
  else
    result :=  iAngle;
end;

function  TVector2f.Spacing(const aV : TVector2f): Single;
begin
  Result:=Abs(aV.x-x)+Abs(aV.y-y);
end;

function  TVector2f.Interpolate(aV : TVector2f; const aK: single): TVector2f;
var
  iX : single;
begin
  iX := 1/aK;
  Result := (self + ((aV - self) * iX));
end;

procedure  TVector2f.Rotate(const aAngle : Single);
begin
  x := x*cos(aAngle) - y*sin(aAngle);
  y := y*cos(aAngle) + x*sin(aAngle);
end;

procedure TVector2f.RotateCenter(const aCenter: TVector2f; const aAngle : Single);
var
  iV: TVector2f;
begin
  iV := (self - aCenter);
  iV.Rotate(aAngle);
  self := (iV + aCenter);
end;

class operator TVector2f.Equal(const aV1, aV2 : TVector2f): boolean;
begin
  Result := (Abs(aV1.x - aV2.x) < EPSILON1) and
            (Abs(aV1.y - aV2.y) < EPSILON1);
end;

class operator TVector2f.Add(const aV1, aV2: TVector2f): TVector2f;
begin
  result.X := aV1.X + aV2.X;
  result.Y := aV1.Y + aV2.Y;
end;

class operator TVector2f.Add(const aV: TVector2f; const aF : Single): TVector2f;
begin
  result.X := aV.X + aF;
  result.Y := aV.Y + aF;
end;

class operator TVector2f.Subtract(const aV1, aV2: TVector2f): TVector2f;
begin
  result.X := aV1.X - aV2.X;
  result.Y := aV1.Y - aV2.Y;
end;

class operator TVector2f.Subtract(const aV: TVector2f; const aF : Single): TVector2f;
begin
  result.X := aV.X - aF;
  result.Y := aV.Y - aF;
end;

class operator TVector2f.Multiply(const aV1, aV2: TVector2f): TVector2f;
begin
  result.X := aV1.X * aV2.X;
  result.Y := aV1.Y * aV2.Y;
end;

class operator TVector2f.Multiply(const aV: TVector2f; const aF : Single): TVector2f;
begin
  result.X := aV.X * aF;
  result.Y := aV.Y * aF;
end;

class operator TVector2f.Divide(const aV1, aV2: TVector2f): TVector2f;
begin
  result.X := aV1.X / aV2.X;
  result.Y := aV1.Y / aV2.Y;
end;

class operator TVector2f.Divide(const aV: TVector2f; const aF : Single): TVector2f;
begin
  result.X := aV.X / aF;
  result.Y := aV.Y / aF;
end;

function Vector3f(const aX, aY, aZ : Single): TVector3f;
begin
  result.X := aX;
  result.Y := aY;
  result.z := aZ;
end;

procedure TVector3f.SetValues(const aX, aY, aZ : Single);
begin
  X := aX;
  Y := aY;
  z := aZ;
end;

function  TVector3f.Copy(): TVector3f;
begin
  result.X := X;
  result.Y := Y;
  result.Z := Z;
end;

procedure TVector3f.Invert();
begin
  X := -X;
  Y := -Y;
  Z := -Z;
end;

procedure TVector3f.AbsV();
begin
  X := Abs(X);
  Y := Abs(Y);
  Z := Abs(Z);
end;

procedure  TVector3f.Max();
begin
  X := MAX_SINGLE;
  Y := MAX_SINGLE;
  z := MAX_SINGLE;
end;

procedure TVector3f.Min();
begin
  X := MIN_SINGLE;
  Y := MIN_SINGLE;
  z := MIN_SINGLE;
end;

function  TVector3f.Length(): single;
begin
  Result := sqrt((X * X) + (Y * Y) + (Z * Z));
end;

procedure TVector3f.Normalize();
var
  iMag, iLength : Single;
begin
  iMag := Length();
  if (iMag > 0.0) then
  begin
    iLength := 1.0 / iMag;
    self := self * iLength;
	end
end;

function  TVector3f.Distance(const aV : TVector3f): single;
begin
  Result := sqrt(sqr(aV.X - X) + sqr(aV.Y - Y) +sqr(aV.Z - Z));
end;

function  TVector3f.Dot(const aV : TVector3f): single;
begin
  Result := ( (X * aV.X) + (Y * aV.Y) + (Z * aV.Z) );
end;

function  TVector3f.Cross(const aV : TVector3f): TVector3f;
begin
	Result.X := ((Y * aV.Z) - (Z * aV.Y));
	Result.Y := ((Z * aV.X) - (X * aV.Z));
	Result.Z := ((X * aV.Y) - (Y * aV.X));
end;

function  TVector3f.Angle(const aV : TVector3f) : single;
var
  iDotProduct : Single;
  iVectorsMagnitude : Single;
  iAngle : real;
begin
  iDotProduct       := Dot(aV);
  iVectorsMagnitude := Length() * aV.Length();
	iAngle            := arccos( iDotProduct / iVectorsMagnitude );
	if(isnan(iAngle)) then
    result := 0
  else
    result :=  iAngle;
end;

function  TVector3f.Spacing(const aV : TVector3f): Single;
begin
  Result:=Abs(aV.x-x)+Abs(aV.y-y)+Abs(aV.z-z);
end;

function  TVector3f.Interpolate(const aV : TVector3f; const aK: single): TVector3f;
var
  iX : single;
begin
  iX := 1/aK;
  Result := self + ( (aV - self) * iX);
end;

procedure TVector3f.RotateX(const aAngle : Single);
begin
  self := Matrix_ApplyToVector3f(Matrix_CreateRotationX(aAngle), self );
end;

procedure TVector3f.RotateCenterX(const aCenter : TVector3f; const aAngle : Single);
var
  iV: TVector3f;
begin
  iV := self - aCenter;
  iV.RotateX( aAngle );
  self := iV + aCenter;
end;

procedure TVector3f.RotateY(const aAngle : Single);
begin
  self := Matrix_ApplyToVector3f(Matrix_CreateRotationY(aAngle), self );
end;

procedure TVector3f.RotateCenterY(const aCenter : TVector3f; const aAngle : Single);
var
  iV: TVector3f;
begin
  iV := self - aCenter;
  iV.RotateY( aAngle );
  self := iV + aCenter;
end;

procedure TVector3f.RotateZ(const aAngle : Single);
begin
  self := Matrix_ApplyToVector3f(Matrix_CreateRotationZ(aAngle), self );
end;

procedure TVector3f.RotateCenterZ(const aCenter : TVector3f; const aAngle : Single);
var
  iV: TVector3f;
begin
  iV := self - aCenter;
  iV.RotateZ( aAngle );
  self := iV + aCenter;
end;

procedure TVector3f.RotateE(const aE : TEuler);
begin
  self := Matrix_ApplyToVector3f(Matrix_CreateRotationE(aE), self );
end;

procedure TVector3f.RotateCenterE(const aCenter : TVector3f; const aE : TEuler);
var
  iV: TVector3f;
begin
  iV := self - aCenter;
  iV.RotateE( aE );
  self := iV + aCenter;
end;

procedure TVector3f.RotateAA(const aAA : TAxisAngle);
begin
  self := Matrix_ApplyToVector3f(Matrix_CreateRotationAA(aAA), self );
end;

procedure TVector3f.RotateCenterAA(const aCenter : TVector3f;  const aAA : TAxisAngle);
var
  iV : TVector3f;
begin
  iV :=  self - aCenter;
  iV.RotateAA( aAA );
  self := iV + aCenter;
end;

class operator TVector3f.Equal(const aV1, aV2 : TVector3f): boolean;
begin
  Result := (Abs(aV1.x - aV2.x) < EPSILON1) and
            (Abs(aV1.y - aV2.y) < EPSILON1) and
            (Abs(aV1.z - aV2.z) < EPSILON1);
end;

class operator TVector3f.Add(const aV1, aV2: TVector3f): TVector3f;
begin
  result.X := aV1.X + aV2.X;
  result.Y := aV1.Y + aV2.Y;
  result.Z := aV1.Z + aV2.Z;
end;

class operator TVector3f.Add(const aV: TVector3f; const aF : Single): TVector3f;
begin
  result.X := aV.X + aF;
  result.Y := aV.Y + aF;
  result.Z := aV.Z + aF;
end;

class operator TVector3f.Subtract(const aV1, aV2: TVector3f): TVector3f;
begin
  result.X := aV1.X - aV2.X;
  result.Y := aV1.Y - aV2.Y;
  result.Z := aV1.Z - aV2.Z;
end;

class operator TVector3f.Subtract(const aV: TVector3f; const aF : Single): TVector3f;
begin
  result.X := aV.X - aF;
  result.Y := aV.Y - aF;
  result.Z := aV.Z - aF;
end;

class operator TVector3f.Multiply(const aV1, aV2: TVector3f): TVector3f;
begin
  result.X := aV1.X * aV2.X;
  result.Y := aV1.Y * aV2.Y;
  result.Z := aV1.Z * aV2.Z;
end;

class operator TVector3f.Multiply(const aV: TVector3f; const aF : Single): TVector3f;
begin
  result.X := aV.X * aF;
  result.Y := aV.Y * aF;
  result.Z := aV.Z * aF;
end;

class operator TVector3f.Divide(const aV1, aV2: TVector3f): TVector3f;
begin
  result.X := aV1.X / aV2.X;
  result.Y := aV1.Y / aV2.Y;
  result.Z := aV1.Z / aV2.Z;
end;

class operator TVector3f.Divide(const aV: TVector3f; const aF : Single): TVector3f;
begin
  result.X := aV.X / aF;
  result.Y := aV.Y / aF;
  result.Z := aV.Z / aF;
end;

function  Vector4f(const aX, aY, aZ, aW : Single): TVector4f;
begin
  result.X := aX;
  result.Y := aY;
  result.z := aZ;
  result.w := aW;
end;

procedure  TVector4f.SetValues(const aX, aY, aZ, aW : Single);
begin
  X := aX;
  Y := aY;
  Z := aZ;
  W := aW;
end;

function  TVector4f.Copy(): TVector4f;
begin
  result.X := X;
  result.Y := Y;
  result.Z := Z;
  result.W := W;
end;

procedure TVector4f.Invert();
begin
  X := -X;
  Y := -Y;
  Z := -Z;
  W := 1;
end;

procedure TVector4f.AbsV();
begin
  X := Abs(X);
  Y := Abs(Y);
  Z := Abs(Z);
  W := 1;
end;

procedure TVector4f.Max();
begin
  X := MAX_SINGLE;
  Y := MAX_SINGLE;
  z := MAX_SINGLE;
  w := MAX_SINGLE;
end;

procedure TVector4f.Min();
begin
  X := MIN_SINGLE;
  Y := MIN_SINGLE;
  z := MIN_SINGLE;
  w := MIN_SINGLE;
end;

function  TVector4f.Length(): single;
begin
  Result := sqrt((X * X) + (Y * Y) + (Z * Z));
end;

procedure TVector4f.Normalize();
var
  iMag, iLength : Single;
begin
  iMag := Length();
  if (iMag > 0.0) then
  begin
    iLength := 1.0 / iMag;
    self := self * iLength;
	end
end;

function  TVector4f.Distance(const aV : TVector4f): single;
begin
  Result := sqrt(sqr(aV.X - X) + sqr(aV.Y - Y) +sqr(aV.Z - Z));
end;

function  TVector4f.Dot(const aV : TVector4f): single;
begin
  Result := ( (X * aV.X) + (Y * aV.Y) + (Z * aV.Z) + (W * aV.W));
end;

function  TVector4f.Cross(const aV : TVector4f): TVector4f;
begin
  Result.X := ((Y * aV.Z) - (Z * aV.Y));
  Result.Y := ((Z * aV.X) - (X * aV.Z));
  Result.Z := ((X * aV.Y) - (Y * aV.X));
  Result.w := 1;
end;

function  TVector4f.Angle(const aV : TVector4f) : single;
var
  iDotProduct : Single;
  iVectorsMagnitude : Single;
  iAngle : real;
begin
  iDotProduct       := Dot(aV);
  iVectorsMagnitude := Length() * aV.Length();
  iAngle            := arccos( iDotProduct / iVectorsMagnitude );
  if(isnan(iAngle)) then
    result := 0
  else
    result :=  iAngle;
end;

function  TVector4f.Spacing(const aV : TVector4f): Single;
begin
  Result:=Abs(aV.x-x)+Abs(aV.y-y)+Abs(aV.z-z)+Abs(aV.w-w);
end;

function  TVector4f.Interpolate(const aV : TVector4f; const aK: single): TVector4f;
var
  iX : single;
begin
  iX := 1/aK;
  Result := self + ( (aV - self) * iX);
end;

procedure TVector4f.RotateX(const aAngle : Single);
begin
  self := Matrix_ApplyToVector4f(Matrix_CreateRotationX(aAngle), self );
end;

procedure TVector4f.RotateCenterX(const aCenter : TVector4f; const aAngle : Single);
var
  iV: TVector4f;
begin
  iV := self - aCenter;
  iV.RotateX( aAngle );
  self := iV + aCenter;
end;

procedure TVector4f.RotateY(const aAngle : Single);
begin
  self := Matrix_ApplyToVector4f(Matrix_CreateRotationY(aAngle), self );
end;

procedure TVector4f.RotateCenterY(const aCenter : TVector4f; const aAngle : Single);
var
  iV: TVector4f;
begin
  iV := self - aCenter;
  iV.RotateY( aAngle );
  self := iV + aCenter;
end;

procedure TVector4f.RotateZ(const aAngle : Single);
begin
  self := Matrix_ApplyToVector4f(Matrix_CreateRotationZ(aAngle), self );
end;

procedure TVector4f.RotateCenterZ(const aCenter : TVector4f; const aAngle : Single);
var
  iV: TVector4f;
begin
  iV := self - aCenter;
  iV.RotateZ( aAngle );
  self := iV + aCenter;
end;

procedure TVector4f.RotateE(const aE : TEuler);
begin
  self := Matrix_ApplyToVector4f(Matrix_CreateRotationE(aE), self );
end;

procedure TVector4f.RotateCenterE(const aCenter : TVector4f; const aE : TEuler);
var
  iV: TVector4f;
begin
  iV := self - aCenter;
  iV.RotateE( aE );
  self := iV + aCenter;
end;

procedure TVector4f.RotateAA(const aAA : TAxisAngle);
begin
  self := Matrix_ApplyToVector4f(Matrix_CreateRotationAA(aAA), self );
end;

procedure TVector4f.RotateCenterAA(const aCenter : TVector4f;  const aAA : TAxisAngle);
var
  iV : TVector4f;
begin
  iV :=  self - aCenter;
  iV.RotateAA( aAA );
  self := iV + aCenter;
end;

class operator TVector4f.Equal(const aV1, aV2 : TVector4f): boolean;
begin
  Result := (Abs(aV1.x - aV2.x) < EPSILON1) and
            (Abs(aV1.y - aV2.y) < EPSILON1) and
            (Abs(aV1.z - aV2.z) < EPSILON1) and
            (Abs(aV1.w - aV2.w) < EPSILON1);
end;

class operator TVector4f.Add(const aV1, aV2: TVector4f): TVector4f;
begin
  result.X := aV1.X + aV2.X;
  result.Y := aV1.Y + aV2.Y;
  result.Z := aV1.Z + aV2.Z;
  result.W := 1;
end;

class operator TVector4f.Add(const aV: TVector4f; const aF : Single): TVector4f;
begin
  result.X := aV.X + aF;
  result.Y := aV.Y + aF;
  result.Z := aV.Z + aF;
  result.W := 1;
end;

class operator TVector4f.Subtract(const aV1, aV2: TVector4f): TVector4f;
begin
  result.X := aV1.X - aV2.X;
  result.Y := aV1.Y - aV2.Y;
  result.Z := aV1.Z - aV2.Z;
  result.W := 1;
end;

class operator TVector4f.Subtract(const aV: TVector4f; const aF : Single): TVector4f;
begin
  result.X := aV.X - aF;
  result.Y := aV.Y - aF;
  result.Z := aV.Z - aF;
  result.W := 1;
end;

class operator TVector4f.Multiply(const aV1, aV2: TVector4f): TVector4f;
begin
  result.X := aV1.X * aV2.X;
  result.Y := aV1.Y * aV2.Y;
  result.Z := aV1.Z * aV2.Z;
  result.W := 1;
end;

class operator TVector4f.Multiply(const aV: TVector4f; const aF : Single): TVector4f;
begin
  result.X := aV.X * aF;
  result.Y := aV.Y * aF;
  result.Z := aV.Z * aF;
  result.W := 1;
end;

class operator TVector4f.Divide(const aV1, aV2: TVector4f): TVector4f;
begin
  result.X := aV1.X / aV2.X;
  result.Y := aV1.Y / aV2.Y;
  result.Z := aV1.Z / aV2.Z;
  result.W := 1;
end;

class operator TVector4f.Divide(const aV: TVector4f; const aF : Single): TVector4f;
begin
  result.X := aV.X / aF;
  result.Y := aV.Y / aF;
  result.Z := aV.Z / aF;
  result.W := 1;
end;

function Quaternion(const aW, aX, aY, aZ: Single): TQuaternion;
begin
  result.w := aW;
  result.x := aX;
  result.y := aY;
  result.z := aZ;
end;

procedure TQuaternion.FromEuler(const aE : TEuler);
var
  iCX, iCY, iCZ, iSX, iSY, iSZ, iCYCZ, iSYSZ, iCYSZ, iSYCZ : Single;
  iPitch, iYaw, iRoll : Single;
begin
   iPitch := 0.5 * DegToRad(aE.pitch);
   iYaw   := 0.5 * DegToRad(aE.yaw);
   iRoll  := 0.5 * DegToRad(aE.roll);

   iCX := cos(iPitch);
   iCY := cos(iYaw);
   iCZ := cos(iRoll);

   iSX := sin(iPitch);
   iSY := sin(iYaw);
   iSZ := sin(iRoll);

   iCYCZ := iCY * iCZ;
   iSYSZ := iSY * iSZ;
   iCYSZ := iCY * iSZ;
   iSYCZ := iSY * iCZ;

   w := iCX * iCYCZ + iSX * iSYSZ;
   x := iSX * iCYCZ - iCX * iSYSZ;
   y := iCX * iSYCZ + iSX * iCYSZ;
   z := iCX * iCYSZ - iSX * iSYCZ;
end;

procedure TQuaternion.FromAxisAngle(const aAA : TAxisAngle);
var
  iSinA, iRad : Single;
  iAxis : TVector3f;
Begin
  iAxis.SetValues( aAA.x, aAA.y, aAA.z );
  iAxis.Normalize();
  iRad := DegToRad(aAA.angle) * 0.5;
  iSinA := sin(iRad);
  w := cos(iRad);
  x := iAxis.x * iSinA;
  y := iAxis.y * iSinA;
  z := iAxis.z * iSinA;
end;

procedure TQuaternion.FromMatrix(const aM : TMatrix4x4);
var
  iTr, iSt : single;
  iI, iJ, iK : integer;
  iQ    : array[0..3] of single;
  iNext : array[0..2] of integer;
begin
  iNext[0] := 1;
  iNext[1] := 2;
  iNext[2] := 0;
  iTr := aM.data[0,0] + aM.data[1,1] + aM.data[2,2];

  if iTr>0 then
  begin
    iSt := sqrt(iTr+1);
    w:=iSt/2;
    iSt := 0.5/iSt;
    x := (aM.data[1,2] - aM.data[2,1]) * iSt;
    y := (aM.data[2,0] - aM.data[0,2]) * iSt;
    z := (aM.data[0,1] - aM.data[1,0]) * iSt;
  end
  else
  begin
    iI := 0;
    if (aM.data[1,1] > aM.data[0,0]) then iI := 1;
    if (aM.data[2,2] > aM.data[iI,iI]) then iI := 2;
    iJ := iNext[iI];
    iK := iNext[iJ];
    iSt := sqrt((aM.data[iI,iI] - aM.data[iJ,iJ] + aM.data[iK,iK]))+1;
    iQ[iI] := iSt*0.5;
    if (iSt<>0) then iSt := 0.5/iSt;
    iQ[3]  := (aM.data[iJ,iK] - aM.data[iK,iJ]) * iSt;
    iQ[iJ] := (aM.data[iI,iJ] - aM.data[iJ,iI]) * iSt;
    iQ[iK] := (aM.data[iI,iK] - aM.data[iJ,iI]) * iSt;
    x := iQ[0];
    y := iQ[1];
    z := iQ[2];
    w := iQ[3];
  end;
end;

function TQuaternion.ToEuler(): TEuler;
var
  iSQX, iSQY, iSQZ : Single;
  iTest : Single;
begin
  iTest := x * y + z * w;
  if (iTest > 0.499) then
  begin
    result.roll  := RadToDeg(2 * atan2(x,w));
    result.yaw   := RadToDeg(PI/2);
    result.pitch := 0;
    exit;
  end;

  if (iTest < -0.499) then
  begin
    result.roll  := RadToDeg(-2 * atan2(x, w));
    result.yaw   := RadToDeg(-PI/2);
    result.pitch := 0;
    exit;
  end;

  iSQX := x * x;
  iSQY := y * y;
  iSQZ := z * z;

  result.roll  := RadToDeg(arcsin(-(2*iTest)));
	result.yaw   := RadToDeg(-atan2(2*y*w-2*x*z , 1 - 2*iSQY - 2*iSQZ));
	result.pitch := RadToDeg(-atan2(2*x*w-2*y*z , 1 - 2*iSQX - 2*iSQZ));
end;

function TQuaternion.ToAxisAngle(): TAxisAngle;
var
  iScale : Single;
begin
  iScale := sqrt(x * x + y * y + z * z);
  result.x := x / iScale;
  result.y := y / iScale;
  result.z := z / iScale;
  result.angle  := RadToDeg(ArcCos(w) * 2.0);
end;

function TQuaternion.ToMatrix(): TMatrix4x4;
var
  iXY2, iXZ2, iXW2, iYZ2, iYW2, iZW2 : Single;
  iXSqr2, iYSqr2, iZSqr2 : Single;
Begin
  iXY2   := 2*x*y;
  iXZ2   := 2*x*Z;
  iXW2   := 2*x*w;
  iYZ2   := 2*y*Z;
  iYW2   := 2*y*w;
  iZW2   := 2*Z*w;
  iXSqr2 := 2*sqr(x);
  iYSqr2 := 2*sqr(y);
  iZSqr2 := 2*sqr(Z);

  With Result do
  begin
    data[0, 0] := 1 - iYSqr2 - iZSqr2;
    data[0, 1] := iXY2 + iZW2;
    data[0, 2] := iXZ2 - iYW2;
    data[0, 3] := 0;

    data[1, 0] := iXY2 - iZW2;
    data[1, 1] := 1 - iXSqr2 - iZSqr2;
    data[1, 2] := iYZ2 + iXW2;
    data[1, 3] := 0;

    data[2, 0] := iXZ2 + iYW2;
    data[2, 1] := iYZ2 - iXW2;
    data[2, 2] := 1 - iXSqr2 - iYSqr2;
    data[2, 3] := 0;

    data[3, 0] := 0;
    data[3, 1] := 0;
    data[3, 2] := 0;
    data[3, 3] := 1;
  end;
end;

function TQuaternion.Copy(): TQuaternion;
begin
  result.w := w;
  result.x := x;
  result.y := y;
  result.z := z;
end;

procedure TQuaternion.Invert();
begin
  w := -w;
  x := -x;
  y := -y;
  wxyz[3] :=  wxyz[3];
end;

procedure TQuaternion.Normalize();
var
  iMag : Single;
  iLength : Single;
begin
  iMag := sqrt((x*x)+(y*y)+(z*z)+(w*w));
  if (iMag > 0.0) then
  begin
    iLength := 1.0 / iMag;
    x := x * iLength;
    y := y * iLength;
    z := z * iLength;
    w := w * iLength;
  end
end;

procedure TQuaternion.BuildW();
var
  iW : Single;
begin
  iW := 1.0 - (W * W) - (X * X) - (Y * Y);

  if (iW < 0) then
    iW := 0
  else
    iW := -sqrt(iW);

  Z := iW;
end;

procedure TQuaternion.SLerp(const aQ : TQuaternion; const aT : Single );
var
  iQ : array [0..3] of Single;
  iOmega, iCosom, iSinom, iScale0, iScale1: Single;
begin
  iCosom := x * aQ.x + y * aQ.y + z * aQ.z + w * aQ.w;

  if iCosom < 0 then
  begin
    iCosom  := -iCosom;
    iQ[0] := -aQ.x;
    iQ[1] := -aQ.y;
    iQ[2] := -aQ.z;
    iQ[3] := -aQ.w;
  end
  else
  begin
    iQ[0] := aQ.x;
    iQ[1] := aQ.y;
    iQ[2] := aQ.z;
    iQ[3] := aQ.w;
  end;

  if (1 - iCosom) > EPSILON1 then
  begin
    iOmega := ArcCos(iCosom);
    iSinom := sin(iOmega);
    iScale0 := sin((1.0 - aT) * iOmega) / iSinom;
    iScale1 := sin(aT * iOmega) / iSinom;
  end
  else
  begin
    iScale0 := 1 - aT;
    iScale1 := aT;
  end;

  x := (iScale0 * x) + (iScale1 * iQ[0]);
  y := (iScale0 * y) + (iScale1 * iQ[1]);
  z := (iScale0 * z) + (iScale1 * iQ[2]);
  w := (iScale0 * w) + (iScale1 * iQ[3]);
end;

function TQuaternion.RotateVector(const aV : TVector3f): TVector3f;
var
  iInvQ, iTempQ, iFinal : TQuaternion;
begin
  iInvQ := self.Copy();
  iInvQ.Invert();
  iInvQ.Normalize();
  iTempQ := self * aV;
  iFinal := iTempQ * iInvQ;
  result.x := iFinal.wxyz[0];
  result.y := iFinal.wxyz[1];
  result.z := iFinal.wxyz[2];
end;

class operator TQuaternion.Equal(const aQ1, aQ2 : TQuaternion): boolean;
begin
  Result := (Abs(aQ1.w - aQ2.w) < EPSILON1) and
            (Abs(aQ1.x - aQ2.x) < EPSILON1) and
            (Abs(aQ1.y - aQ2.y) < EPSILON1) and
            (Abs(aQ1.z - aQ2.z) < EPSILON1);
end;

class operator TQuaternion.Add(const aQ1, aQ2 : TQuaternion): TQuaternion;
var
  iI : Integer;
begin
  For iI := 0 to 3 do
    Result.wxyz[iI] := aQ1.wxyz[iI] + aQ2.wxyz[iI];
end;

class operator TQuaternion.Subtract(const aQ1, aQ2 : TQuaternion): TQuaternion;
var
  iI : Integer;
begin
  For iI := 0 to 3 do
    Result.wxyz[iI] := aQ1.wxyz[iI] - aQ2.wxyz[iI];
end;

class operator TQuaternion.Multiply(const aQ1, aQ2 : TQuaternion):TQuaternion;
begin
  result.z := (aQ1.z*aQ2.z)-(aQ1.w*aQ2.w)-(aQ1.x*aQ2.x)-(aQ1.y*aQ2.y);
  result.w := (aQ1.w*aQ2.z)+(aQ1.z*aQ2.w)+(aQ1.x*aQ2.y)-(aQ1.y*aQ2.x);
  result.x := (aQ1.x*aQ2.z)+(aQ1.z*aQ2.x)+(aQ1.y*aQ2.w)-(aQ1.w*aQ2.y);
  result.y := (aQ1.y*aQ2.z)+(aQ1.z*aQ2.y)+(aQ1.w*aQ2.x)-(aQ1.x*aQ2.w);
end;

class operator TQuaternion.Multiply(const aQ : TQuaternion; const aV : TVector3f): TQuaternion;
begin
  result.z := - (aQ.w * aV.x) - (aQ.x * aV.y) - (aQ.y * aV.z);
  result.w :=   (aQ.z * aV.x) + (aQ.x * aV.z) - (aQ.y * aV.y);
  result.x :=   (aQ.z * aV.y) + (aQ.y * aV.x) - (aQ.w * aV.z);
  result.y :=   (aQ.z * aV.z) + (aQ.w * aV.y) - (aQ.x * aV.x);
end;

































































funCtion  Matrix(Const aC1R1, aC2R1, aC3R1, aC4R1,
                       aC1R2, aC2R2, aC3R2, aC4R2,
                       aC1R3, aC2R3, aC3R3, aC4R3,
                       aC1R4, aC2R4, aC3R4, aC4R4: Single): TMatrix4x4;
begin
  with result do
  begin
    data[0, 0] := aC1R1;
    data[1, 0] := aC2R1;
    data[2, 0] := aC3R1;
    data[3, 0] := aC4R1;

    data[0, 1] := aC1R2;
    data[1, 1] := aC2R2;
    data[2, 1] := aC3R2;
    data[3, 1] := aC4R2;

    data[0, 2] := aC1R3;
    data[1, 2] := aC2R3;
    data[2, 2] := aC3R3;
    data[3, 2] := aC4R3;

    data[0, 3] := aC1R4;
    data[1, 3] := aC2R4;
    data[2, 3] := aC3R4;
    data[3, 3] := aC4R4;
  end;
end;

function Matrix_Copy(const aM : TMatrix4x4): TMatrix4x4;
begin
  with result do
  begin
    data[0, 0] := aM.data[0, 0];
    data[1, 0] := aM.data[1, 0];
    data[2, 0] := aM.data[2, 0];
    data[3, 0] := aM.data[3, 0];

    data[0, 1] := aM.data[0, 1];
    data[1, 1] := aM.data[1, 1];
    data[2, 1] := aM.data[2, 1];
    data[3, 1] := aM.data[3, 1];

    data[0, 2] := aM.data[0, 2];
    data[1, 2] := aM.data[1, 2];
    data[2, 2] := aM.data[2, 2];
    data[3, 2] := aM.data[3, 2];

    data[0, 3] := aM.data[0, 3];
    data[1, 3] := aM.data[1, 3];
    data[2, 3] := aM.data[2, 3];
    data[3, 3] := aM.data[3, 3];
  end;
end;

function  Matrix_Empty(): TMatrix4x4;
var
  iR, iC: Integer;
begin
  for iR := 0 to 3 do
    for iC := 0 to 3 do
      Result.data[iR,iC] := 0;
end;

function  Matrix_Identity(): TMatrix4x4;
begin
  with result do
  begin
    data[0, 0] := 1;
    data[1, 0] := 0;
    data[2, 0] := 0;
    data[3, 0] := 0;

    data[0, 1] := 0;
    data[1, 1] := 1;
    data[2, 1] := 0;
    data[3, 1] := 0;

    data[0, 2] := 0;
    data[1, 2] := 0;
    data[2, 2] := 1;
    data[3, 2] := 0;

    data[0, 3] := 0;
    data[1, 3] := 0;
    data[2, 3] := 0;
    data[3, 3] := 1;
  end;
end;

function  Matrix_Compare(const aM1, aM2 : TMatrix4x4): boolean;
var
  iR, iC: Integer;
begin
  Result := TRUE;
  for iR := 0 to 3 do
  begin
    for iC := 0 to 3 do
    begin
      if Abs(aM1.data[iR,iC] - aM2.data[iR,iC]) > EPSILON1 then
      begin
        Result := FALSE;
        Exit;
      end;
    end;
  end;
end;

function  Matrix_CreateLinearTexGen(): TMatrix4x4;
begin
  with result do
  begin
    data[0, 0] := 0.5;
    data[1, 0] := 0;
    data[2, 0] := 0;
    data[3, 0] := 0.5;

    data[0, 1] := 0;
    data[1, 1] := 0.5;
    data[2, 1] := 0;
    data[3, 1] := 0.5;

    data[0, 2] := 0;
    data[1, 2] := 0;
    data[2, 2] := 0.5;
    data[3, 2] := 0.5;

    data[0, 3] := 0;
    data[1, 3] := 0;
    data[2, 3] := 0;
    data[3, 3] := 1;
  end;
end;

function  Matrix_CreatePerspective(const aFov, aAspect, aNearPlane, aFarPlane : Single): TMatrix4x4;
var
  n, f, r, l, t, b : Single;
begin
  Result := Matrix_Identity();

	n := aNearPlane;
	f := aFarPlane;
	r := tan(DegToRad(aFov * 0.5)) * n;
	l := -r;
	t := r / aAspect;
  b := -t;

  with Result do
  begin
	  data[0, 0] := 2*n/(r-l);
    data[0, 1] := 0;
    data[0, 2] := 0;
    data[0, 3] := 0;

	  data[1, 0] := 0;
    data[1, 1] := 2*n/(t-b);
    data[1, 2] := 0;
    data[1, 3] := 0;

	  data[2, 0] := (r+l)/(r-l);
    data[2, 1] := (t+b)/(t-b);
    data[2, 2] := -(f+n)/(f-n);
    data[2, 3] := -1;

	  data[3, 0] := 0;
    data[3, 1] := 0;
    data[3, 2] := -2*n*f/(f-n);
    data[3, 3] := 0;
  end;
end;

function  Matrix_CreateOrtho(const aLeft, aRight, aBottom, aTop, aZNear, aZFar: Single): TMatrix4x4;
begin
  result := Matrix_Identity();

  with Result do
  begin
    data[0, 0] := 2 / (aRight - aLeft);
    data[0, 1] := 0;
    data[0, 2] := 0;
    data[0, 3] := 0;

    data[1, 0] := 0;
    data[1, 1] := 2 / (aTop - aBottom);
    data[1, 2] := 0;
    data[1, 3] := 0;

    data[2, 0] := 0;
    data[2, 1] := 0;
    data[2, 2] := -2 / (aZFar - aZNear);
    data[2, 3] := 0;

    data[3, 0] := -((aRight + aLeft) / (aRight - aLeft));
    data[3, 1] := -((aTop + aBottom) / (aTop - aBottom));
    data[3, 2] := -((aZFar + aZNear) / (aZFar - aZNear));
    data[3, 3] := 1;
  end;
end;

function  Matrix_CreateRotationX(const aAngleX : single): TMatrix4x4;
var
  iRX : Single;
begin
  iRX := DegToRad(aAngleX);
  result := Matrix_Identity;
  result.data[1,1] := cos(iRX);
  result.data[2,1] := sin(iRX);
  result.data[1,2] := -sin(iRX);
  result.data[2,2] := cos(iRX);
end;

function  Matrix_CreateRotationY(const aAngleY : single): TMatrix4x4;
var
  iRY : Single;
begin
  iRY := DegToRad(aAngleY);
  result := Matrix_Identity;
  result.data[0,0] := cos(iRY);
  result.data[0,2] := sin(iRY);
  result.data[2,0] := -sin(iRY);
  result.data[2,2] := cos(iRY);
end;

function  Matrix_CreateRotationZ(const aAngleZ : single): TMatrix4x4;
var
  iRZ : Single;
begin
  iRZ := DegToRad(aAngleZ);
  result := Matrix_Identity;
  result.data[0,0] := cos(iRZ);
  result.data[1,0] := sin(iRZ);
  result.data[0,1] := -sin(iRZ);
  result.data[1,1] := cos(iRZ);
end;

function  Matrix_CreateRotationE(const aE : TEuler): TMatrix4x4;
var
  iM, iMX, iMY, iMZ : TMatrix4x4;
begin
  iMX := Matrix_CreateRotationX(aE.pitch);
  iMY := Matrix_CreateRotationY(aE.yaw);
  iMZ := Matrix_CreateRotationZ(aE.roll);
  iM  := Matrix_Multiply(iMZ,iMY);
  result := Matrix_Multiply(iMX,iM);
end;

function  Matrix_CreateRotationAA(const aAA : TAxisAngle): TMatrix4x4;
var
  iCosA, iSinA, iAngle : Single;
begin
  iAngle := DegToRad(aAA.angle);
  Result := Matrix_Identity();
  iCosA := cos(iAngle);
  iSinA := sin(iAngle);
  Result.data[0,0] := iCosA + (1 - iCosA)*aAA.x*aAA.x;
  Result.data[1,0] := (1 - iCosA)*aAA.x*aAA.y - aAA.z*iSinA;
  Result.data[2,0] := (1 - iCosA)*aAA.x*aAA.z + aAA.y*iSinA;
  Result.data[0,1] := (1 - iCosA)*aAA.x*aAA.z + aAA.z*iSinA;
  Result.data[1,1] := iCosA + (1 - iCosA)*aAA.y*aAA.y;
  Result.data[2,1] := (1 - iCosA)*aAA.y*aAA.z - aAA.x*iSinA;
  Result.data[0,2] := (1 - iCosA)*aAA.x*aAA.z - aAA.y*iSinA;
  Result.data[1,2] := (1 - iCosA)*aAA.y*aAA.z + aAA.x*iSinA;
  Result.data[2,2] := iCosA + (1 - iCosA)*aAA.z*aAA.z;
end;

function Matrix_CreateScaleV(const aSc: TVector3f): TMatrix4x4;
begin
  Result := Matrix_Identity;
  Result.data[0, 0] := aSc.X;
  Result.data[1, 1] := aSc.Y;
  Result.data[2, 2] := aSc.Z;
end;

function  Matrix_CreateScaleF(const aSc: Single): TMatrix4x4;
begin
  Result := Matrix_Identity;
  Result.data[0, 0] := aSc;
  Result.data[1, 1] := aSc;
  Result.data[2, 2] := aSc;
end;

function Matrix_CreateTranslation(const aT : TVector3f): TMatrix4x4;
begin
  Result := Matrix_Identity;
  Result.data[3, 0] := aT.X;
  Result.data[3, 1] := aT.Y;
  Result.data[3, 2] := aT.Z;
end;

function  Matrix_CreateScaleAndTranslation(const aSc,aT : TVector3f): TMatrix4x4;
begin
  Result := Matrix_Identity;
  Result.data[0, 0] := aSc.X;
  Result.data[1, 1] := aSc.Y;
  Result.data[2, 2] := aSc.Z;
  Result.data[3, 0] := aT.X;
  Result.data[3, 1] := aT.Y;
  Result.data[3, 2] := aT.Z;
end;

procedure Matrix_RotateE(var aM : TMatrix4x4; const aE : TEuler);
var
  iM : TMatrix4x4;
begin
  iM := Matrix_CreateRotationE(aE);
  aM := Matrix_Multiply(iM, aM)
end;

procedure Matrix_RotateAA(var aM : TMatrix4x4; const aAA : TAxisAngle);
var
  iM : TMatrix4x4;
begin
  iM := Matrix_CreateRotationAA(aAA);
  aM := Matrix_Multiply(iM, aM)
end;

procedure Matrix_ScaleAll(var aM : TMatrix4x4; aSc: Single);
var
 iI, iJ: Integer;
begin
  for iI := 0 to 3 do
    for iJ := 0 to 3 do aM.data[iI, iJ] := aM.data[iI, iJ] * aSc;
end;

procedure Matrix_ScaleV(var aM : TMatrix4x4; const aSc: TVector3f);
begin
   aM.data[0][0] := aM.data[0][0] + aSc.x;
   aM.data[1][1] := aM.data[1][1] + aSc.y;
   aM.data[2][2] := aM.data[2][2] + aSc.z;
end;

procedure Matrix_ScaleF(var aM : TMatrix4x4; const aSc: Single);
begin
   aM.data[0][0] := aM.data[0][0] + aSc;
   aM.data[1][1] := aM.data[1][1] + aSc;
   aM.data[2][2] := aM.data[2][2] + aSc;
end;

procedure Matrix_Translate(var aM : TMatrix4x4; const aT: TVector3f);
begin
   aM.data[3][0] := aM.data[3][0] + aT.x;
   aM.data[3][1] := aM.data[3][1] + aT.y;
   aM.data[3][2] := aM.data[3][2] + aT.z;
end;

procedure Matrix_SetRotationE(var aM : TMatrix4x4; const aE : TEuler);
var
  iM : TMatrix4x4;
begin
  iM := Matrix_CreateRotationE(aE);
  Matrix_Translate( iM,  Matrix_GetTranslation(aM) );
  aM := Matrix_Copy(iM);
end;

procedure Matrix_SetRotationAA(var aM : TMatrix4x4; const aAA : TAxisAngle);
var
  iM : TMatrix4x4;
begin
  iM := Matrix_CreateRotationAA(aAA);
  Matrix_Translate( iM,  Matrix_GetTranslation(aM) );
  aM := Matrix_Copy(iM);
end;

procedure Matrix_SetScaleV(var aM : TMatrix4x4; const aSc: TVector3f);
begin
   aM.data[0][0] := aSc.x;
   aM.data[1][1] := aSc.y;
   aM.data[2][2] := aSc.z;
end;

procedure Matrix_SetScaleF(var aM : TMatrix4x4; const aSc: Single);
begin
   aM.data[0][0] := aSc;
   aM.data[1][1] := aSc;
   aM.data[2][2] := aSc;
end;

procedure Matrix_SetTranslation(var aM : TMatrix4x4; const aT: TVector3f);
begin
   aM.data[3][0] := aT.x;
   aM.data[3][1] := aT.y;
   aM.data[3][2] := aT.z;
end;

function  Matrix_GetRotationE(const aM: TMatrix4x4): TEuler;
var
  iQ : TQuaternion;
begin
  iQ.FromMatrix(aM);
  result := iQ.ToEuler();
end;

function  Matrix_GetRotationAA(const aM: TMatrix4x4): TAxisAngle;
var
  iQ : TQuaternion;
begin
  iQ.FromMatrix(aM);
  result := iQ.ToAxisAngle();
end;

function  Matrix_GetScale(const aM: TMatrix4x4): TVector3f;
begin
  result.x := aM.data[0, 0];
  result.y := aM.data[1, 1];
  result.z := aM.data[2, 2];
end;

function  Matrix_GetTranslation(const aM: TMatrix4x4): TVector3f;
begin
  result.x := aM.data[3, 0];
  result.y := aM.data[3, 1];
  result.z := aM.data[3, 2];
end;

function Matrix_Add(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
var
  iR, iC: Integer;
begin
  for iR := 0 to 3 do
  begin
    for iC := 0 to 3 do
    begin
     result.data[iR,iC] := aM1.data[iR,iC] + aM2.data[iR,iC];
    end;
  end;
end;

function  Matrix_Subtract(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
var
  iR, iC: Integer;
begin
  for iR := 0 to 3 do
  begin
    for iC := 0 to 3 do
    begin
     result.data[iR,iC] := aM1.data[iR,iC] - aM2.data[iR,iC];
    end;
  end;
end;

function  Matrix_Multiply(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
begin
  result.data[0,0]:=aM1.data[0,0]*aM2.data[0,0]+aM1.data[0,1]*aM2.data[1,0]+aM1.data[0,2]*aM2.data[2,0]+aM1.data[0,3]*aM2.data[3,0];
  result.data[0,1]:=aM1.data[0,0]*aM2.data[0,1]+aM1.data[0,1]*aM2.data[1,1]+aM1.data[0,2]*aM2.data[2,1]+aM1.data[0,3]*aM2.data[3,1];
  result.data[0,2]:=aM1.data[0,0]*aM2.data[0,2]+aM1.data[0,1]*aM2.data[1,2]+aM1.data[0,2]*aM2.data[2,2]+aM1.data[0,3]*aM2.data[3,2];
  result.data[0,3]:=aM1.data[0,0]*aM2.data[0,3]+aM1.data[0,1]*aM2.data[1,3]+aM1.data[0,2]*aM2.data[2,3]+aM1.data[0,3]*aM2.data[3,3];
  result.data[1,0]:=aM1.data[1,0]*aM2.data[0,0]+aM1.data[1,1]*aM2.data[1,0]+aM1.data[1,2]*aM2.data[2,0]+aM1.data[1,3]*aM2.data[3,0];
  result.data[1,1]:=aM1.data[1,0]*aM2.data[0,1]+aM1.data[1,1]*aM2.data[1,1]+aM1.data[1,2]*aM2.data[2,1]+aM1.data[1,3]*aM2.data[3,1];
  result.data[1,2]:=aM1.data[1,0]*aM2.data[0,2]+aM1.data[1,1]*aM2.data[1,2]+aM1.data[1,2]*aM2.data[2,2]+aM1.data[1,3]*aM2.data[3,2];
  result.data[1,3]:=aM1.data[1,0]*aM2.data[0,3]+aM1.data[1,1]*aM2.data[1,3]+aM1.data[1,2]*aM2.data[2,3]+aM1.data[1,3]*aM2.data[3,3];
  result.data[2,0]:=aM1.data[2,0]*aM2.data[0,0]+aM1.data[2,1]*aM2.data[1,0]+aM1.data[2,2]*aM2.data[2,0]+aM1.data[2,3]*aM2.data[3,0];
  result.data[2,1]:=aM1.data[2,0]*aM2.data[0,1]+aM1.data[2,1]*aM2.data[1,1]+aM1.data[2,2]*aM2.data[2,1]+aM1.data[2,3]*aM2.data[3,1];
  result.data[2,2]:=aM1.data[2,0]*aM2.data[0,2]+aM1.data[2,1]*aM2.data[1,2]+aM1.data[2,2]*aM2.data[2,2]+aM1.data[2,3]*aM2.data[3,2];
  result.data[2,3]:=aM1.data[2,0]*aM2.data[0,3]+aM1.data[2,1]*aM2.data[1,3]+aM1.data[2,2]*aM2.data[2,3]+aM1.data[2,3]*aM2.data[3,3];
  result.data[3,0]:=aM1.data[3,0]*aM2.data[0,0]+aM1.data[3,1]*aM2.data[1,0]+aM1.data[3,2]*aM2.data[2,0]+aM1.data[3,3]*aM2.data[3,0];
  result.data[3,1]:=aM1.data[3,0]*aM2.data[0,1]+aM1.data[3,1]*aM2.data[1,1]+aM1.data[3,2]*aM2.data[2,1]+aM1.data[3,3]*aM2.data[3,1];
  result.data[3,2]:=aM1.data[3,0]*aM2.data[0,2]+aM1.data[3,1]*aM2.data[1,2]+aM1.data[3,2]*aM2.data[2,2]+aM1.data[3,3]*aM2.data[3,2];
  result.data[3,3]:=aM1.data[3,0]*aM2.data[0,3]+aM1.data[3,1]*aM2.data[1,3]+aM1.data[3,2]*aM2.data[2,3]+aM1.data[3,3]*aM2.data[3,3];
end;

function  Matrix_Divide(const aM1, aM2 : TMatrix4x4): TMatrix4x4;
var
  iR, iC: Integer;
begin
  for iR := 0 to 3 do
  begin
    for iC := 0 to 3 do
    begin
     result.data[iR,iC] := aM1.data[iR,iC] / aM2.data[iR,iC];
    end;
  end;
end;

procedure Matrix_Transpose(var aM : TMatrix4x4);
var
  iI, iJ : Integer;
  iTM : TMatrix4x4;
begin
  for iI := 0 to 3 do
    for iJ := 0 to 3 do iTM.data[iJ, iI] := aM.data[iI, iJ];
  aM := iTM;
end;

function Matrix_Determinant(const aM: TMatrix4x4): Single;

function Matrix_DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
begin
  Result := a1 * (b2 * c3 - b3 * c2) -
            b1 * (a2 * c3 - a3 * c2) +
            c1 * (a2 * b3 - a3 * b2);
end;

var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4  : Single;
begin
  a1 := aM.data[0, 0];  b1 := aM.data[0, 1];  c1 := aM.data[0, 2];  d1 := aM.data[0, 3];
  a2 := aM.data[1, 0];  b2 := aM.data[1, 1];  c2 := aM.data[1, 2];  d2 := aM.data[1, 3];
  a3 := aM.data[2, 0];  b3 := aM.data[2, 1];  c3 := aM.data[2, 2];  d3 := aM.data[2, 3];
  a4 := aM.data[3, 0];  b4 := aM.data[3, 1];  c4 := aM.data[3, 2];  d4 := aM.data[3, 3];
  Result := a1 * Matrix_DetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4) -
            b1 * Matrix_DetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4) +
            c1 * Matrix_DetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4) -
            d1 * Matrix_DetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
end;

procedure Matrix_Inverse(var aM : TMatrix4x4);
var
  iDet : Single;
begin
  iDet := Matrix_Determinant(aM);
  if Abs(iDet) < EPSILON1 then
    aM := Matrix_Identity
  else
  begin
    Matrix_Adjoint(aM);
    Matrix_ScaleAll(aM, 1 / iDet);
  end;
end;

procedure Matrix_Adjoint(var aM: TMatrix4x4);
var a1, a2, a3, a4,
    b1, b2, b3, b4,
    c1, c2, c3, c4,
    d1, d2, d3, d4: Single;

function Matrix_DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3: Single): Single;
begin
  Result := a1 * (b2 * c3 - b3 * c2) -
            b1 * (a2 * c3 - a3 * c2) +
            c1 * (a2 * b3 - a3 * b2);
end;

begin
    a1 := aM.data[0, 0]; b1 := aM.data[0, 1];
    c1 := aM.data[0, 2]; d1 := aM.data[0, 3];
    a2 := aM.data[1, 0]; b2 := aM.data[1, 1];
    c2 := aM.data[1, 2]; d2 := aM.data[1, 3];
    a3 := aM.data[2, 0]; b3 := aM.data[2, 1];
    c3 := aM.data[2, 2]; d3 := aM.data[2, 3];
    a4 := aM.data[3, 0]; b4 := aM.data[3, 1];
    c4 := aM.data[3, 2]; d4 := aM.data[3, 3];
    aM.data[0, 0] :=  Matrix_DetInternal(b2, b3, b4, c2, c3, c4, d2, d3, d4);
    aM.data[1, 0] := -Matrix_DetInternal(a2, a3, a4, c2, c3, c4, d2, d3, d4);
    aM.data[2, 0] :=  Matrix_DetInternal(a2, a3, a4, b2, b3, b4, d2, d3, d4);
    aM.data[3, 0] := -Matrix_DetInternal(a2, a3, a4, b2, b3, b4, c2, c3, c4);
    aM.data[0, 1] := -Matrix_DetInternal(b1, b3, b4, c1, c3, c4, d1, d3, d4);
    aM.data[1, 1] :=  Matrix_DetInternal(a1, a3, a4, c1, c3, c4, d1, d3, d4);
    aM.data[2, 1] := -Matrix_DetInternal(a1, a3, a4, b1, b3, b4, d1, d3, d4);
    aM.data[3, 1] :=  Matrix_DetInternal(a1, a3, a4, b1, b3, b4, c1, c3, c4);
    aM.data[0, 2] :=  Matrix_DetInternal(b1, b2, b4, c1, c2, c4, d1, d2, d4);
    aM.data[1, 2] := -Matrix_DetInternal(a1, a2, a4, c1, c2, c4, d1, d2, d4);
    aM.data[2, 2] :=  Matrix_DetInternal(a1, a2, a4, b1, b2, b4, d1, d2, d4);
    aM.data[3, 2] := -Matrix_DetInternal(a1, a2, a4, b1, b2, b4, c1, c2, c4);
    aM.data[0, 3] := -Matrix_DetInternal(b1, b2, b3, c1, c2, c3, d1, d2, d3);
    aM.data[1, 3] :=  Matrix_DetInternal(a1, a2, a3, c1, c2, c3, d1, d2, d3);
    aM.data[2, 3] := -Matrix_DetInternal(a1, a2, a3, b1, b2, b3, d1, d2, d3);
    aM.data[3, 3] :=  Matrix_DetInternal(a1, a2, a3, b1, b2, b3, c1, c2, c3);
end;

function  Matrix_ApplyToVector3f(const aM : TMatrix4x4; const aV : TVector3f ): TVector3f;
begin
  result.X := aV.X * aM.data[0,0] + aV.Y * aM.data[1,0] + aV.Z * aM.data[2,0] + aM.data[3,0];
  result.Y := aV.X * aM.data[0,1] + aV.Y * aM.data[1,1] + aV.Z * aM.data[2,1] + aM.data[3,1];
  result.Z := aV.X * aM.data[0,2] + aV.Y * aM.data[1,2] + aV.Z * aM.data[2,2] + aM.data[3,2];
end;

function  Matrix_ApplyToVector4f(const aM : TMatrix4x4; const aV : TVector4f ): TVector4f;
begin
  result.X := aV.X * aM.data[0,0] + aV.Y * aM.data[1,0] + aV.Z * aM.data[2,0] + aM.data[3,0];
  result.Y := aV.X * aM.data[0,1] + aV.Y * aM.data[1,1] + aV.Z * aM.data[2,1] + aM.data[3,1];
  result.Z := aV.X * aM.data[0,2] + aV.Y * aM.data[1,2] + aV.Z * aM.data[2,2] + aM.data[3,2];
  result.W := 1;
end;

function Line(const aP1, aP2 : TVector3f): TLine;
begin
  result.p1 :=  aP1.Copy();
  result.p2 :=  aP2.Copy();
end;

function Line_Copy(const aLine : TLine): TLine;
begin
  result.p1 := aLine.p1.Copy();
  result.p2 := aLine.p2.Copy();
end;

function Line_Compare(const aLine1, aLine2 : TLine): boolean;
begin
  result := false;
  if ( aLine1.p1 = aLine2.p1) and
     ( aLine2.p1 = aLine2.p2) then
    result := true;
end;

function  Plane_ABCD(const aA, aB, aC, aD: Single): TPlane;
begin
  Result.a := aA;
  Result.b := aB;
  Result.c := aC;
  Result.d := aD;
end;

function  Plane_NormalD(const aNormal: TVector3f; const aD: Single): TPlane;
begin
  Result.normal := aNormal;
  Result.dist   := aD;
end;

function  Plane_Copy(const aP : TPlane): TPlane;
begin
  Result.normal := aP.normal.Copy();
  Result.dist   := aP.dist;
end;

function Plane_Compare(const aP1, aP2 : TPlane): boolean;
begin
  Result := (Abs(aP1.a - aP2.a) < EPSILON1) and
            (Abs(aP1.b - aP2.b) < EPSILON1) and
            (Abs(aP1.c - aP2.c) < EPSILON1) and
            (Abs(aP1.d - aP2.d) < EPSILON1);
end;

function  Plane_FromPoints3f(const aP1, aP2, aP3 : TVector3f): TPlane;
var
  iNormal : TVector3f;
begin
  iNormal := (aP2 - aP1).Cross((aP3 - aP1) );
  iNormal.Normalize();
  with Result do
  begin
    a := iNormal.x;
    b := iNormal.y;
    c := iNormal.z;
    d := -(a * iNormal.x + b * iNormal.y + c * iNormal.z);
  end;
end;

function  Plane_FromPoints4f(const aP1, aP2, aP3 : TVector4f): TPlane;
var
  iNormal : TVector4f;
begin
  iNormal := (aP2 - aP1).Cross((aP3 - aP1) );
  iNormal.Normalize();
  with Result do
  begin
    a := iNormal.x;
    b := iNormal.y;
    c := iNormal.z;
    d := -(a * iNormal.x + b * iNormal.y + c * iNormal.z);
  end;
end;

procedure Plane_Normalize(var aPlane : TPlane);
var
  iMag : Single;
begin
  iMag := aPlane.normal.Length();
  aPlane.a := aPlane.a / iMag;
  aPlane.b := aPlane.b / iMag;
  aPlane.c := aPlane.c / iMag;
  aPlane.d := aPlane.d / iMag;
end;

function  Plane_Vec3fDist(const aPlane : TPlane; const aP : TVector3f): Single;
begin
  Result := aPlane.normal.x * aP.x + aPlane.normal.y * aP.y + aPlane.normal.z * aP.z + aPlane.dist;
end;

function  Plane_Vec4fDist(const aPlane : TPlane; const aP : TVector4f): Single;
begin
  Result := aPlane.a * aP.x + aPlane.b * aP.y + aPlane.c * aP.z + aPlane.d;
end;

function Intersect_PointInsideBox( const aPoint : TVector3f;  const aBox : TBoundingBox ): boolean;
begin
  result := false;
  If (aBox.min.X <= aPoint.X) and (aBox.min.Y <= aPoint.Y) and (aBox.min.Z <= aPoint.Z) and
     (aBox.max.X >= aPoint.X) and (aBox.max.Y >= aPoint.Y) and (aBox.max.Z >= aPoint.Z) then
    result := true
end;

function Intersect_PointInsideSphere( const aPoint : TVector3f; const aSphere : TBoundingSphere ): boolean;
var
  iDist : Single;
  iV : TVector3f;
begin
  result := true;
  iV := aPoint;
  iV := iV - aSphere.center;
  iDist := iV.Length();
  if iDist > aSphere.radius then
    result := false
end;

function Intersect_BoxInsideBox( const aBox1, aBox2 : TBoundingBox ): boolean;
begin
  result := false;
  If (aBox1.min.X <= aBox2.min.X) and (aBox1.min.Y <= aBox2.min.Y) and (aBox1.min.Z <= aBox2.min.Z) and
     (aBox1.max.X >= aBox2.max.X) and (aBox1.max.Y >= aBox2.max.Y) and (aBox1.max.Z >= aBox2.max.Z) then
    result := true
end;

function Intersect_BoxInsideSphere( const aBox : TBoundingBox; const aSphere : TBoundingSphere ): boolean;
begin
  result := false;
end;

function Intersect_SphereInsideSphere( const aSphere1, aSphere2 : TBoundingSphere ): boolean;
var
  iDist : Single;
  iV    : TVector3f;
begin
  result := true;
  iV := aSphere2.center;
  iV := iV - aSphere1.center;
  iDist := iV.Length() + aSphere2.radius;
  if iDist > aSphere1.radius then
    result := false
end;

function Intersect_SphereInsideBox( const aSphere : TBoundingSphere; const aBox : TBoundingBox ): boolean;
begin
  result := false;
end;

function Intersect_BoxBox( const aBox1, aBox2 : TBoundingBox  ): boolean;
begin
  result := true;
  if (aBox1.min.x > aBox2.max.x) or (aBox1.max.x < aBox2.min.x) or (aBox1.min.y > aBox2.max.y) or
     (aBox1.max.y < aBox2.min.y) or (aBox1.min.z > aBox2.max.z) or (aBox1.max.z < aBox2.min.z) then
    result := false;
end;

function Intersect_SphereSphere( const aSphere1, aSphere2 : TBoundingSphere ): boolean;
Var
  iR,iRR  : Single;
  iV : TVector3f;
begin
  Result := false;
  iR  := (aSphere1.radius + aSphere2.radius);
  iV  := aSphere2.center - aSphere1.center;
  iRR := iV.Length();
  if iRR < iR then Result := True;
end;

function Intersect_BoxSphere( const aBox : TBoundingBox; const aSphere : TBoundingSphere ): boolean;
var
  iD :single;
begin
  iD := 0;
  if (aSphere.center.x < aBox.min.x) then iD := iD + abs(aSphere.center.x - aBox.min.x);
  if (aSphere.center.x > aBox.max.x) then iD := iD + abs(aSphere.center.x - aBox.max.x);
  if (aSphere.center.y < aBox.min.y) then iD := iD + abs(aSphere.center.y - aBox.min.y);
  if (aSphere.center.y > aBox.max.y) then iD := iD + abs(aSphere.center.y - aBox.max.y);
  if (aSphere.center.z < aBox.min.z) then iD := iD + abs(aSphere.center.z - aBox.min.z);
  if (aSphere.center.z > aBox.max.z) then iD := iD + abs(aSphere.center.z - aBox.max.z);
  result := (iD  <=  aSphere.radius);
end;

function Intersect_LineBox(const aLine : TLine; const aBox : TBoundingBox): boolean;
var
  iDir, iLineDir, iLD, iLineCenter, iCenter, iExtents, iCross : TVector3f;
begin
  Result := False;

  iCenter     := ((aBox.min + aBox.max) * 0.5);
  iExtents    := aBox.max - iCenter;
  iLineDir    := ((aLine.p2 - aLine.p1) * 0.5);
  iLineCenter := aLine.p1 + iLineDir;
  iDir        := iLineCenter - iCenter;

  iLD.x := Abs(iLineDir.x);
  if Abs(iDir.x) > (iExtents.x + iLD.x) then Exit;
  iLD.y := Abs(iLineDir.y);
  if Abs(iDir.y) > (iExtents.y + iLD.y) then Exit;
  iLD.z := Abs(iLineDir.z);
  if Abs(iDir.z) > (iExtents.z + iLD.z) then Exit;

  iCross := iLineDir.Cross(iLD);
  if Abs(iCross.x) > ((iExtents.y * iLD.z) + (iExtents.z * iLD.y)) then Exit;
  if Abs(iCross.y) > ((iExtents.x * iLD.z) + (iExtents.z * iLD.x)) then Exit;
  if Abs(iCross.z) > ((iExtents.x * iLD.y) + (iExtents.y * iLD.x)) then Exit;

  Result := True;
end;

function Intersect_LineSphere(const aLine : TLine; const aSphere : TBoundingSphere): boolean;
var
  iA, iB, iC : Single;
  iBB4AC : Single;
  iDP : TVector3f;
begin
  result := true;
  iDP := aLine.p2 - aLine.p1;
  iA := iDP.x * iDP.x + iDP.y * iDP.y + iDP.z * iDP.z;
  iB := 2 * (iDP.x * (aLine.p1.x - aSphere.center.x) + iDP.y * (aLine.p1.y - aSphere.center.y) + iDP.z * (aLine.p1.z - aSphere.center.z));
  iC := aSphere.center.x * aSphere.center.x + aSphere.center.y * aSphere.center.y + aSphere.center.z * aSphere.center.z;
  iC := iC + (aLine.p1.x * aLine.p1.x + aLine.p1.y * aLine.p1.y + aLine.p1.z * aLine.p1.z);
  iC := iC - (2 * (aSphere.center.x * aLine.p1.x + aSphere.center.y * aLine.p1.y + aSphere.center.z * aLine.p1.z));
  iC := iC - (aSphere.radius * aSphere.radius);
  iBB4AC := iB * iB - 4 * iA * iC;
  if ((ABS(iA) < EPSILON1) or (iBB4AC < 0)) then
    result := false;
end;

function BoundingBox_Copy(const aBox : TBoundingBox): TBoundingBox;
begin
  result.min    := aBox.min.Copy();
  result.max    := aBox.max.Copy();
  result.center := aBox.center.Copy();
end;

function BoundingSphere_Copy(const aSphere : TBoundingSphere): TBoundingSphere;
begin
  result.radius := aSphere.radius;
  result.center := aSphere.center.Copy();
end;

end.
