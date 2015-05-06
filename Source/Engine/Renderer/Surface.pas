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
unit Surface;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  Material,
  Resource,
  Mathematics,
  IntegerArray;

Type
  TSurface = class
  private
  public
    Primitive : TGLenum;
    Usage     : TGLenum;
    MatName   : String;
    Material  : TMaterial;
    Dirty     : Boolean;
    BufferID  : GLuint;
    Data      : TIntegerArray;

    constructor Create();
    Destructor  Destroy(); override;
    procedure   Update();
    procedure   ApplyMaterial(const aCustomMaterial : TCustomMaterial);
  end;

  {$define TYPED_ARRAY_TEMPLATE}
  TYPED_ARRAY_ITEM = TSurface;
  {$INCLUDE '..\Templates\Array.tpl'}

  TSurfaceArray = class(TYPED_ARRAY)
  private
    FOwnsEntities : Boolean;

    procedure OnRemoveItem(var aItem : TSurface); override;
  public
    constructor Create(OwnsEntities : Boolean = true);
    destructor  Destroy(); override;
  end;

implementation

uses
  Base;

{$INCLUDE '..\Templates\Array.tpl'}

constructor TSurfaceArray.Create(OwnsEntities : Boolean);
begin
  inherited Create();
  FOwnsEntities := OwnsEntities;
end;

destructor  TSurfaceArray.Destroy();
begin
  inherited Destroy();
end;

procedure TSurfaceArray.OnRemoveItem(var aItem : TSurface);
begin
  if FOwnsEntities then
    FreeAndNil(aItem);
end;

constructor TSurface.Create();
begin
  inherited Create();
  Primitive := GL_TRIANGLES;
  Usage	    := GL_STATIC_DRAW;
  MatName   := 'NONE';
  Material  := nil;
  Dirty	    := true;
  BufferID  := 0;
  Data      := TIntegerArray.Create();
end;

Destructor TSurface.Destroy();
begin
  glDeleteBuffers(1, @BufferID);
  BufferID := 0;
  Dirty := true;
  Engine.Resources.Remove( TResource(Material) );
  FreeAndNil(Data);
end;

procedure TSurface.Update();
begin
  if Dirty = false then exit;
  if BufferID = 0 then glGenBuffers(1, @BufferID);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, BufferID);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, Data.Size(), Data.BasePointer(), Usage);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  Dirty := false;
end;

procedure TSurface.ApplyMaterial(const aCustomMaterial : TCustomMaterial);
begin
  if Material = nil then
  begin
    if Engine.Resources.Exists( MatName ) then
    begin
      Material := TMaterial(Engine.Resources.Get( MatName ));
      Inc(Material.RefCounter);
      Material.CopyToCustom(aCustomMaterial);
      Material.Apply(aCustomMaterial);
    end;
  end
  else
  begin
     Material.CopyToCustom(aCustomMaterial);
     Material.Apply(aCustomMaterial);
  end;
end;

end.
