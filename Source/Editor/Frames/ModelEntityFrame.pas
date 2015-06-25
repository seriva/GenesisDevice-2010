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
unit ModelEntityFrame;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  EntityFrame,
  Dialogs,
  Entity,
  ModelEntity,
  StdCtrls;

type
  TModelEntityPropFrame = class (TEntityPropFrame)
    ShadowsLabel: TLabel;
    CastShadowsCheckBox: TCheckBox;
    procedure CastShadowsCheckBoxClick(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent; const aEntity : TEntity);
  end;

implementation

{$R *.lfm}

uses
  Main;

constructor TModelEntityPropFrame.Create(AOwner: TComponent; const aEntity : TEntity);
begin
  inherited Create(AOwner, aEntity);
  Creating := true;
  CastShadowsCheckBox.Checked :=  TModelEntity(Entity).CastShadows;
  Creating := false;
end;

procedure TModelEntityPropFrame.CastShadowsCheckBoxClick(Sender: TObject);
begin
  if Creating then exit;
  TModelEntity(Entity).CastShadows := CastShadowsCheckBox.Checked;
  MainForm.UpdateViewPorts();
end;

end.

