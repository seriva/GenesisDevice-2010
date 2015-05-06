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
unit Resource;

{$MODE Delphi}

interface

uses
  SysUtils;

Type
  TResource = class
  private
  public
    Name       : String;
    RefCounter : Integer;

    constructor Create();
    destructor  Destroy(); override;
  end;

  {$define TYPED_MAP_TEMPLATE}
  TYPED_MAP_ITEM = TResource;
  {$INCLUDE '..\Templates\Map.tpl'}

  TResourceMap = class(TYPED_MAP)
  private
    procedure OnRemoveItem(var aItem : TYPED_MAP_ITEM); override;
  public
  end;

implementation

uses
  Base;

{$INCLUDE '..\Templates\Map.tpl'}

constructor TResource.Create();
begin
  inherited Create();
  Name       := '';
  RefCounter := 1;
end;

destructor  TResource.Destroy();
begin
  inherited Destroy();
end;

procedure TResourceMap.OnRemoveItem(var aItem : TResource);
begin
  FreeAndNil(aItem)
end;

end.
