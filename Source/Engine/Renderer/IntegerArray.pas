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
unit IntegerArray;

{$MODE Delphi}

interface

uses
  Mathematics,
  Base;

type
  {$define GD_ARRAY_TEMPLATE}
  TYPED_ARRAY_ITEM = Integer;
  {$INCLUDE '..\Templates\Array.tpl'}

  TIntegerArray = class(TYPED_ARRAY)
  private
    function  CompareItems(const aItem1, aItem2 : Integer): boolean; override;
    procedure AddArray(const aArray : array of Integer);
  public
    procedure AddVector2i(const aV : TVector2i);
    procedure AddVector3i(const aV : TVector3i);
    function  GetVector2i(const aIndex : Integer):TVector2i;
    function  GetVector3i(const aIndex : Integer):TVector3i;
    procedure RemoveVector2i(const aIndex : Integer);
    procedure RemoveVector3i(const aIndex : Integer);
    function  CountVector2i():Integer;
    function  CountVector3i():Integer;
  end;

implementation

{$INCLUDE '..\Templates\Array.tpl'}

procedure TIntegerArray.AddArray(const aArray : array of Integer);
var
  iI : Integer;
begin
  for iI := 0 to length(aArray) - 1 do
    Add(aArray[iI]);
end;

procedure TIntegerArray.AddVector2i(const aV : TVector2i);
begin
  AddArray(aV.xy);
end;

procedure TIntegerArray.AddVector3i(const aV : TVector3i);
begin
  AddArray(aV.xyz);
end;

function  TIntegerArray.GetVector2i(const aIndex : Integer):TVector2i;
var
  iI : Integer;
begin
  if (aIndex > CountVector2i()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 2;
  result.x := list[iI];
  result.y := list[iI+1];
end;

function  TIntegerArray.GetVector3i(const aIndex : Integer):TVector3i;
var
  iI : Integer;
begin
  if (aIndex > CountVector3i()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 3;
  result.x := list[iI];
  result.y := list[iI+1];
  result.z := list[iI+2];
end;

procedure TIntegerArray.RemoveVector2i(const aIndex : Integer);
var
  iI : Integer;
begin
  if (aIndex > CountVector2i()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 2;
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
end;

procedure TIntegerArray.RemoveVector3i(const aIndex : Integer);
var
  iI : Integer;
begin
  if (aIndex > CountVector3i()) then Engine.Log.Print(self.ClassName, 'Array out of bound!', true);
  iI :=  aIndex * 3;
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
  self.RemoveIdx( iI );
end;

function  TIntegerArray.CountVector2i():Integer;
begin
  result := (Count-1) div 2;
end;

function  TIntegerArray.CountVector3i():Integer;
begin
  result := (Count-1) div 3;
end;

function TIntegerArray.CompareItems(const aItem1, aItem2 : Integer): boolean;
begin
  result := (aItem1 = aItem2);
end;

end.
