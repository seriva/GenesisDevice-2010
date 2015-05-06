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
unit SceneFrame;

{$MODE Delphi}

interface

uses
  LCLIntf,
  LCLType,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Buttons,
  StdCtrls,
  ExtCtrls;

type
  TScenePropFrame = class(TFrame)
    AmbientLightLabel: TLabel;
    AmbientLightPanel: TPanel;
    ColorDialog: TColorDialog;
    procedure AmbientLightPanelClick(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation

{$R *.lfm}

uses
  Main;

constructor TScenePropFrame.Create(AOwner: TComponent) ;
begin
  inherited Create(AOwner) ;
  AmbientLightPanel.Color := RGBToColor(MainForm.MainScene.Ambient);
end;

procedure TScenePropFrame.AmbientLightPanelClick(Sender: TObject);
begin
  ColorDialog.Color := AmbientLightPanel.Color;
  if ColorDialog.Execute() then
  begin
    AmbientLightPanel.Color := ColorDialog.Color;
    AmbientLightPanel.Repaint();
    MainForm.MainScene.Ambient := ColorToRGB(AmbientLightPanel.Color);
    MainForm.UpdateViewPorts();
  end;
end;

end.
