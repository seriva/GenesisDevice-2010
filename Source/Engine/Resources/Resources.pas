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
unit Resources;

{$MODE Delphi}

interface

uses
  SysUtils,
  Resource;

type
  TLoadingFunction  = function(const aName : String): TResource;

  {$define TYPED_MAP_TEMPLATE}
  TYPED_MAP_ITEM = TLoadingFunction;
  {$INCLUDE '..\Templates\Map.tpl'}

  TLoaderMap = class(TYPED_MAP)
  private
  public
  end;

  TResources = class
  private
    FResources : TResourceMap;
    FLoaders   : TLoaderMap;
  public
    constructor Create();
    destructor  Destroy(); override;

    procedure RegisterLoader(const aExtension : String; const aLoadingFunction : TLoadingFunction);
    function  Load(const aName : String): TResource;
    procedure Remove(var aResource : TResource);
    procedure Add(const aName : String; const aResource : TResource);
    function  Exists(const aName : String): Boolean;
    function  Get(const aName : String): TResource;
    procedure Clear();
  end;

implementation

uses
  Base;

{$INCLUDE '..\Templates\Map.tpl'}

constructor TResources.Create();
begin
  inherited Create();
  FResources := TResourceMap.Create();
  FLoaders  := TLoaderMap.Create();
end;

destructor  TResources.Destroy();
begin
  FResources.Clear();
  FreeAndNil(FResources);
  FreeAndNil(FLoaders);
  inherited Destroy();
end;

procedure TResources.RegisterLoader(const aExtension : String; const aLoadingFunction : TLoadingFunction);
begin
  FLoaders.Add(aExtension, aLoadingFunction);
end;

function TResources.Load(const aName : String): TResource;
var
  iStr : String;
  iLoadFunction : TLoadingFunction;
begin
  result := nil;
  if FResources.Exists( aName ) then
  begin
    result := FResources.Get( aName );
    result.RefCounter :=  result.RefCounter + 1
  end
  else
  begin
    iStr := UpperCase(ExtractFileExt(aName));
    If FLoaders.Exists( iStr ) then
    begin
      iLoadFunction := FLoaders.Get(iStr);
      result := iLoadFunction(aName);
      FResources.Add(aName, result);
    end
    else
      Engine.Log.Print(self.ClassName, 'Resource type ' + iStr + ' isn`t supported!', true);
  end;
end;

procedure TResources.Remove(var aResource : TResource);
begin
  if (aResource = nil) or ( aResource.Name = '') then exit;
  aResource.RefCounter := aResource.RefCounter - 1;
  if aResource.RefCounter = 0 then
    FResources.Remove( aResource.Name );
  aResource := nil;
end;

procedure TResources.Add(const aName : String; const aResource : TResource);
begin
  FResources.Add(aName, aResource);
end;

function TResources.Exists(const aName : String): Boolean;
begin
  result := FResources.Exists( aName )
end;

function TResources.Get(const aName : String): TResource;
begin
  result := FResources.Get(aName);
end;

procedure TResources.Clear();
begin
  FResources.Clear();
  Engine.Log.Print(self.ClassName, 'Resources Cleared', false);
end;

end.
