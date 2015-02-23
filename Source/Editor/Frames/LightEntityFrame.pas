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
unit LightEntityFrame;

{$MODE Delphi}

interface

uses
  LCLIntf,
  LCLType,
  LMessages,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Entity,
  EntityFrame,
  LightEntity,
  ComCtrls,
  ExtCtrls;

type
  TLightEntityPropFrame = class (TEntityPropFrame)
    ShadowsLabel: TLabel;
    CastShadowsCheckBox: TCheckBox;
    IntensityLabel: TLabel;
    ColorLabel: TLabel;
    ColorTrackBar: TTrackBar;
    ColorPanel: TPanel;
    ColorDialog: TColorDialog;
    procedure CastShadowsCheckBoxClick(Sender: TObject);
    procedure ColorTrackBarChange(Sender: TObject);
    procedure ColorPanelClick(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent; const aEntity : TEntity);
  end;

implementation

{$R *.lfm}

uses
  Main,
  Mathematics;

constructor TLightEntityPropFrame.Create(AOwner: TComponent; const aEntity : TEntity);
begin
  inherited Create(AOwner, aEntity);
  Creating := true;
  CastShadowsCheckBox.Checked :=  TLightEntity(Entity).CastShadows;
  ColorTrackBar.Position := Round(TLightEntity(Entity).Intensity*100);
  ColorPanel.Color := RGBToColor(TLightEntity(Entity).Color);
  Creating := false;
end;

procedure TLightEntityPropFrame.CastShadowsCheckBoxClick(Sender: TObject);
begin
  if Creating then exit;
  TLightEntity(Entity).CastShadows := CastShadowsCheckBox.Checked;
  TLightEntity(Entity).ShadowBuffer := nil;
  MainForm.UpdateViewPorts();
end;

procedure TLightEntityPropFrame.ColorTrackBarChange(Sender: TObject);
begin
  if Creating then exit;
  TLightEntity(Entity).Intensity := ColorTrackBar.Position/100;
  MainForm.UpdateViewPorts();
end;

procedure TLightEntityPropFrame.ColorPanelClick(Sender: TObject);
begin
  inherited;
  ColorDialog.Color := ColorPanel.Color;
  if ColorDialog.Execute() then
  begin
    ColorPanel.Color := ColorDialog.Color;
    ColorPanel.Repaint();
    TLightEntity(Entity).Color := ColorToRGB(ColorPanel.Color);
    MainForm.UpdateViewPorts();
  end;
end;

end.
