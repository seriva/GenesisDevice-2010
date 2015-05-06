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
unit Material;

{$MODE Delphi}

interface

uses
  SysUtils,
  Math,
  dglOpenGL,
  Resource,
  Mathematics,
  ShaderProgram,
  Texture;

const
  TEXTURE_COUNT = 8;

type
  TCustomMaterial = class
  private
    First     : Boolean;
  public
    GlowColor : TVector3f;
    Scale     : Single;
    Bias      : Single;

    constructor Create();
    destructor  Destroy(); override;
  end;

  {$define TYPED_ARRAY_TEMPLATE}
  TYPED_ARRAY_ITEM = TCustomMaterial;
  {$INCLUDE '..\Templates\Array.tpl'}

  TCustomMaterialArray = class(TYPED_ARRAY)
  private
    FOwnsEntities : Boolean;

    procedure OnRemoveItem(var aItem : TCustomMaterial); override;
  public
    constructor Create(OwnsEntities : Boolean = true);
    destructor  Destroy(); override;
  end;

  TMaterial = class (TResource)
  private
  public
    Shader    : TShaderProgram;
    Textures  : array[0..TEXTURE_COUNT-1] of TTexture;
    GlowColor : TVector3f;
    Scale     : Single;
    Bias      : Single;
    Alpha     : Single;

    constructor Create();
    destructor  Destroy(); override;

    procedure CopyToCustom(const aCustomMaterial : TCustomMaterial);
    procedure Apply(const aCustomMaterial : TCustomMaterial);
  end;

implementation

uses
  Base;

{$INCLUDE '..\Templates\Array.tpl'}

constructor TCustomMaterial.Create();
begin
  inherited Create();
  First     := true;
  GlowColor := Vector3f(0,0,0);
  Scale     := 0.0;
  Bias      := 0.0;
end;

destructor  TCustomMaterial.Destroy();
begin
  inherited Destroy();
end;

constructor TCustomMaterialArray.Create(OwnsEntities : Boolean);
begin
  inherited Create();
  FOwnsEntities := OwnsEntities;
end;

destructor  TCustomMaterialArray.Destroy();
begin
  inherited Destroy();
end;

procedure TCustomMaterialArray.OnRemoveItem(var aItem : TCustomMaterial);
begin
  if FOwnsEntities then
    FreeAndNil(aItem);
end;

constructor TMaterial.Create();
var
  iI : Integer;
begin
  inherited Create();
  for iI := 0 to TEXTURE_COUNT-1 do
    Textures[iI] := nil;
  GlowColor := Vector3f(0,0,0);
  Alpha := 1.0;
end;

destructor  TMaterial.Destroy();
var
  iI : Integer;
begin
  inherited Destroy();
  for iI := 0 to TEXTURE_COUNT-1 do
  begin
    if Textures[iI] <> nil then
    begin
      Engine.Resources.Remove( TResource(Textures[iI]) );
      Textures[iI] := nil;
    end;
  end;
end;

procedure TMaterial.CopyToCustom(const aCustomMaterial : TCustomMaterial);
begin
  if aCustomMaterial = nil then exit;
  if aCustomMaterial.First = false then exit;
  aCustomMaterial.GlowColor := GlowColor.Copy();
  aCustomMaterial.Scale := Scale;
  aCustomMaterial.Bias := Bias;
  aCustomMaterial.First := false;
end;

procedure TMaterial.Apply(const aCustomMaterial : TCustomMaterial);
var
  iI : Integer;
begin
  //bind shader
  Shader.Bind();

  //bind the textures
  for iI := 0 to TEXTURE_COUNT-1 do
  begin
    if Textures[iI] <> nil then
    begin
      Textures[iI].Bind(iI);
      Shader.SetInt('texture' + IntToStr(iI), iI);
    end;
  end;

  //bind other material properties
  Shader.SetFloat('alpha', Alpha);
  if aCustomMaterial <> nil then
  begin
    with aCustomMaterial do
    begin
      Shader.SetFloat3('glowColor', GlowColor.x, GlowColor.y, GlowColor.z);
      Shader.SetFloat('scale', Scale);
      Shader.SetFloat('bias', Bias);
    end;
  end
  else
  begin
    Shader.SetFloat3('glowColor', GlowColor.x, GlowColor.y, GlowColor.z);
    Shader.SetFloat('scale', Scale);
    Shader.SetFloat('bias', Bias);
  end;
end;

end.
