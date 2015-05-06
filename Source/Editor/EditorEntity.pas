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
unit EditorEntity;

{$MODE Delphi}

interface

uses
  ComCtrls;

Type
  TEditorEntity = class
  private
  public
    SelectID : Integer;
    TreeNode : TTreeNode;

    constructor Create();
    destructor  Destroy(); override;
  end;

implementation

constructor TEditorEntity.Create();
begin
  inherited Create();
  SelectID := 0;
  TreeNode := nil;
end;

destructor  TEditorEntity.Destroy();
begin
  inherited Destroy();
end;

end.
