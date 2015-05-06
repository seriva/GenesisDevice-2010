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
unit Progress;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls;

type

  { TProgressForm }

  TProgressForm = class(TForm)
    ProgressBar: TProgressBar;
    procedure FormCreate(Sender: TObject);
  private
    procedure HideTitlebar;
  public
    procedure StartProgress(const aTitle : String);
    procedure EndProgress();
  end;

implementation

{$R *.lfm}

uses
  Main;

procedure TProgressForm.FormCreate(Sender: TObject);
begin
  HideTitlebar();
end;

procedure TProgressForm.HideTitlebar;
var
  Style: Longint;
begin
  if BorderStyle = bsNone then Exit;
  Style := GetWindowLong(Handle, GWL_STYLE);
  if (Style and WS_CAPTION) = WS_CAPTION then
  begin
    case BorderStyle of
      bsSingle,
      bsSizeable: SetWindowLong(Handle, GWL_STYLE, Style and
          (not (WS_CAPTION)) or WS_BORDER);
      bsDialog: SetWindowLong(Handle, GWL_STYLE, Style and
          (not (WS_CAPTION)) or WS_DLGFRAME);
    end;
    Height := Height - GetSystemMetrics(SM_CYCAPTION);
    Refresh;
  end;
end;

procedure TProgressForm.StartProgress(const aTitle : String);
begin
  MainForm.Enabled := false;
  Visible := true;
  Position := poOwnerFormCenter;
  ProgressBar.Min := 0;
  ProgressBar.Max := 100;
  ProgressBar.Position := 0;
  Height := Height - GetSystemMetrics(SM_CYCAPTION);
  Refresh;
  Repaint();
end;

procedure TProgressForm.EndProgress();
begin
  MainForm.Enabled := true;
  ProgressForm.Visible := false;
  self.Repaint;
end;

end.
