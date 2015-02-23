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
unit SpotLightEntityFrame;

{$MODE Delphi}

interface

uses
  LCLIntf,
  LCLType, LMessages,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  LightEntityFrame,
  SpotLightEntity,
  Entity,
  ExtCtrls,
  ComCtrls,
  StdCtrls;

type
  TSpotLightEntityPropFrame = class(TLightEntityPropFrame)
    InnerConeLabel: TLabel;
    OuterConeLabel: TLabel;
    InnerConeTrackBar: TTrackBar;
    OuterConeTrackBar: TTrackBar;
    procedure InnerConeTrackBarChange(Sender: TObject);
    procedure OuterConeTrackBarChange(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent; const aEntity : TEntity);
  end;

implementation

{$R *.lfm}

Uses
  Main;

constructor TSpotLightEntityPropFrame.Create(AOwner: TComponent; const aEntity : TEntity);
begin
  inherited Create(AOwner, aEntity);
  Creating := true;
  InnerConeTrackBar.Position := Round(TSpotLightEntity(Entity).InnerAngle);
  OuterConeTrackBar.Position := Round(TSpotLightEntity(Entity).OuterAngle);
  Creating := false;
end;

procedure TSpotLightEntityPropFrame.InnerConeTrackBarChange(Sender: TObject);
begin
  if Creating then exit;
  if InnerConeTrackBar.Position >= OuterConeTrackBar.Position then
    OuterConeTrackBar.Position := InnerConeTrackBar.Position;
  TSpotLightEntity(Entity).InnerAngle := InnerConeTrackBar.Position;
  MainForm.UpdateViewPorts();
end;

procedure TSpotLightEntityPropFrame.OuterConeTrackBarChange(Sender: TObject);
begin
  inherited;
  if Creating then exit;
  if OuterConeTrackBar.Position <= InnerConeTrackBar.Position then
    InnerConeTrackBar.Position := OuterConeTrackBar.Position;
  TSpotLightEntity(Entity).OuterAngle := OuterConeTrackBar.Position;
  MainForm.UpdateViewPorts();
end;

end.
