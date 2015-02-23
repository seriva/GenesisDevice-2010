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
unit FloatArray;

{$MODE Delphi}

interface

uses
  Mathematics,
  Base;

type
  {$define TYPED_ARRAY_TEMPLATE}
  TYPED_ARRAY_ITEM = Single;
  {$INCLUDE '..\Templates\Array.tpl'}

  TFloatArray = class(TYPED_ARRAY)
  private
    function  CompareItems(const aItem1, aItem2 : Single): boolean; override;
    procedure AddArray(const aArray : array of single);
  public
    procedure AddVector2f(const aV : TVector2f);
    procedure AddVector3f(const aV : TVector3f);
    procedure AddVector4f(const aV : TVector4f);
    function  GetVector2f(const aIndex : Integer):TVector2f;
    function  GetVector3f(const aIndex : Integer):TVector3f;
    function  GetVector4f(const aIndex : Integer):TVector4f;
    procedure RemoveVector2f(const aIndex : Integer);
    procedure RemoveVector3f(const aIndex : Integer);
    procedure RemoveVector4f(const aIndex : Integer);
    function  CountVector2f():Integer;
    function  CountVector3f():Integer;
    function  CountVector4f():Integer;
    procedure SetVector2f(const aIndex : Integer; const aV : TVector2f);
    procedure SetVector3f(const aIndex : Integer; const aV : TVector3f);
    procedure SetVector4f(const aIndex : Integer; const aV : TVector4f);
    function  CalculateBoundingBox(): TBoundingBox;
    function  CalculateBoundingSphere(): TBoundingSphere;
  end;

implementation

{$INCLUDE '..\Templates\Array.tpl'}

procedure TFloatArray.AddArray(const aArray : array of single);
var
  iI : Integer;
begin
  for iI := 0 to length(aArray) - 1 do
    Add(aArray[iI]);
end;

procedure TFloatArray.AddVector2f(const aV : TVector2f);
begin
  AddArray(aV.xy);
end;

procedure TFloatArray.AddVector3f(const aV : TVector3f);
begin
  AddArray(aV.xyz);
end;

procedure TFloatArray.AddVector4f(const aV : TVector4f);
begin
  AddArray(aV.xyzw);
end;

function  TFloatArray.GetVector2f(const aIndex : Integer):TVector2f;
var
  iI : Integer;
begin
  if (aIndex > CountVector2f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 2;
  result := Vector2f(list[iI], list[iI+1] );
end;

function  TFloatArray.GetVector3f(const aIndex : Integer):TVector3f;
var
  iI : Integer;
begin
  if (aIndex > CountVector3f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 3;
  result := Vector3f(list[iI], list[iI+1], list[iI+2] );
end;

function  TFloatArray.GetVector4f(const aIndex : Integer):TVector4f;
var
  iI : Integer;
begin
  if (aIndex > CountVector4f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 4;
  result := Vector4f(list[iI], list[iI+1], list[iI+2], list[iI+3] );
end;

procedure TFloatArray.RemoveVector2f(const aIndex : Integer);
var
  iI : Integer;
begin
  if (aIndex > CountVector2f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 2;
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
end;

procedure TFloatArray.RemoveVector3f(const aIndex : Integer);
var
  iI : Integer;
begin
  if (aIndex > CountVector3f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 3;
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
end;

procedure TFloatArray.RemoveVector4f(const aIndex : Integer);
var
  iI : Integer;
begin
  if (aIndex > CountVector4f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 4;
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
end;

function  TFloatArray.CountVector2f():Integer;
begin
  result := (Count-1) div 2;
end;

function  TFloatArray.CountVector3f():Integer;
begin
  result := (Count-1) div 3;
end;

function  TFloatArray.CountVector4f():Integer;
begin
  result := (Count-1) div 4;
end;

procedure TFloatArray.SetVector2f(const aIndex : Integer; const aV : TVector2f);
var
  iI : Integer;
begin
  if (aIndex > CountVector2f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 2;
  list[iI]   := aV.x;
  list[iI+1] := aV.y;
end;

procedure TFloatArray.SetVector3f(const aIndex : Integer; const aV : TVector3f);
var
  iI : Integer;
begin
  if (aIndex > CountVector3f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 3;
  list[iI]   := aV.x;
  list[iI+1] := aV.y;
  list[iI+2] := aV.z;
end;

procedure TFloatArray.SetVector4f(const aIndex : Integer; const aV : TVector4f);
var
  iI : Integer;
begin
  if (aIndex > CountVector4f()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 4;
  list[iI]   := aV.x;
  list[iI+1] := aV.y;
  list[iI+2] := aV.z;
  list[iI+3] := aV.w;
end;

function TFloatArray.CompareItems(const aItem1, aItem2 : Single): boolean;
begin
  result := (aItem1 = aItem2);
end;

function TFloatArray.CalculateBoundingBox(): TBoundingBox;
var
  iI, iCount : integer;
  iVector : TVector3f;
  iCenter : TVector3f;
begin
  iCount  := CountVector3f();
  iCenter := Vector3f(0,0,0);
  for iI := 0 to iCount do
    iCenter := iCenter + GetVector3f(iI);
  iCenter := iCenter / (iCount+1);

  with result do
  begin
    min := iCenter;
    max := iCenter;

    for iI := 0 to iCount do
    begin
      iVector := GetVector3f(iI);

      If (iVector.X <= min.X) then
        min.X  := iVector.X
      else If (iVector.X >= max.X) then
            max.X  := iVector.X;

      If (iVector.Y <= min.Y) then
        min.Y  := iVector.Y
      else If (iVector.Y >= max.Y) then
            max.Y  := iVector.Y;

      If (iVector.Z <= min.Z) then
        min.Z  := iVector.Z
      else If (iVector.Z >= max.Z) then
            max.Z  := iVector.Z;
    end;

    center := max.Copy();
    center := center + result.min;
    center := center / 2;
  end;
end;

function TFloatArray.CalculateBoundingSphere(): TBoundingSphere;
var
  iV    : TVector3f;
  iAABB : TBoundingBox;
begin
  iAABB := CalculateBoundingBox();
  iV := iAABB.max - iAABB.center;
  result.radius := iV.Length();
  result.center := iAABB.center.Copy();
end;

end.
