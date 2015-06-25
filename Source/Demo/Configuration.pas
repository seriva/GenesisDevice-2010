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
unit Configuration;

{$MODE Delphi}

interface

uses
  Windows,
  SysUtils,
  Classes,
  multimon,
  StdCtrls,
  Controls,
  ExtCtrls,
  ComCtrls,
  Graphics,
  Forms,
  Dialogs,
  IniFiles,
  Main;

type
  TDisplayMode = record
    Width: LongInt;
    Height: LongInt;
  end;

  { TConfigurationForm }

  TConfigurationForm = class(TForm)
    PageControl: TPageControl;
    WindowTabSheet: TTabSheet;
    WindowPanel: TPanel;
    Resolutionlable: TLabel;
    ResolutionsComboBox: TComboBox;
    FullScreenCheckBox: TCheckBox;
    VerticalSyncCheckBox: TCheckBox;
    RunButton: TButton;
    MobitorLabel: TLabel;
    MonitorComboBox: TComboBox;
    RenderingTabSheet: TTabSheet;
    Panel1: TPanel;
    BloomCheckBox: TCheckBox;
    AmbientOcclusionCheckBox: TCheckBox;
    FXAACheckBox: TCheckBox;
    ShadowsCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MonitorComboBoxChange(Sender: TObject);
  private
    FIniFile : TIniFile;

    procedure DetectDisplays();
    procedure DetectDisplayModi();
    procedure LoadSettings();
    procedure SaveSettings();
  public
    FMonitorInfos  : array of TMonitorInfoEx;
    FAvailableModi : array of TDisplayMode;
  end;

var
  ConfigurationForm : TConfigurationForm;
  MainForm          : TMainForm;

const
  INIFILE = 'Demo.ini';

implementation

{$R *.lfm}

procedure TConfigurationForm.FormCreate(Sender: TObject);
begin
  //set some form basics
  Application.Title := 'Demo';
  self.Caption := 'Configuration';

  //detect monitors
  DetectDisplays();

  //detect resolutions
  DetectDisplayModi();

  //create the inifile
  FIniFile := TIniFile.Create( ExtractFilePath(Application.ExeName) + INIFILE);

  //load the settings
  LoadSettings();

  //show the form and set the focus
  self.Show();
  RunButton.SetFocus();
end;

procedure TConfigurationForm.FormShow(Sender: TObject);
begin
  self.Left:=10;
  self.Top:=10;
end;

procedure TConfigurationForm.FormDestroy(Sender: TObject);
begin
  SaveSettings();
  FreeAndNil(FIniFile);
  SetLength( FMonitorInfos, 0 );
  SetLength( FAvailableModi, 0 );
end;

procedure TConfigurationForm.MonitorComboBoxChange(Sender: TObject);
begin
  DetectDisplayModi();
end;

procedure TConfigurationForm.RunButtonClick(Sender: TObject);
begin
  SaveSettings();
  Visible := false;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.ShowOnTop();
  MainForm.Visible := true;
  MainForm.Repaint();
  MainForm.Show();
end;

procedure TConfigurationForm.LoadSettings();
begin
  //window
  MonitorComboBox.ItemIndex     := FIniFile.ReadInteger('Window', 'Monitor', 0);
  ResolutionsComboBox.ItemIndex := FIniFile.ReadInteger('Window', 'Resolution', 0);
  FullScreenCheckBox.Checked    := FIniFile.ReadBool('Window', 'Fullscreen', false);
  VerticalSyncCheckBox.Checked  := FIniFile.ReadBool('Window', 'VerticalSync', false);

  //rendering
  BloomCheckBox.Checked            := FIniFile.ReadBool('Rendering', 'Bloom', true);
  AmbientOcclusionCheckBox.Checked := FIniFile.ReadBool('Rendering', 'AmbientOcclusion', true);
  FXAACheckBox.Checked             := FIniFile.ReadBool('Rendering', 'FXAA', true);
  ShadowsCheckBox.Checked          := FIniFile.ReadBool('Rendering', 'Shadows', true);
end;

procedure TConfigurationForm.SaveSettings();
begin
  //window
  FIniFile.WriteInteger('Window', 'Monitor', MonitorComboBox.ItemIndex);
  FIniFile.WriteInteger('Window', 'Resolution', ResolutionsComboBox.ItemIndex);
  FIniFile.WriteBool('Window', 'Fullscreen', FullScreenCheckBox.Checked);
  FIniFile.WriteBool('Window', 'VerticalSync', VerticalSyncCheckBox.Checked);

  //rendering
  FIniFile.WriteBool('Rendering', 'Bloom', BloomCheckBox.Checked );
  FIniFile.WriteBool('Rendering', 'AmbientOcclusion', AmbientOcclusionCheckBox.Checked );
  FIniFile.WriteBool('Rendering', 'FXAA', FXAACheckBox.Checked);
  FIniFile.WriteBool('Rendering', 'Shadows', ShadowsCheckBox.Checked);
end;

procedure TConfigurationForm.DetectDisplays();
var
  iI : Integer;
begin
  MonitorComboBox.Clear();
  for iI := 0 to Screen.MonitorCount-1 do
  begin
    if Screen.Monitors[iI].Primary then
      MonitorComboBox.Items.Add('Monitor ' + IntToStr(iI+1) + ' (Primary)')
    else
      MonitorComboBox.Items.Add('Monitor ' + IntToStr(iI+1));
    SetLength(FMonitorInfos, Length(FMonitorInfos) + 1);
    FMonitorInfos[High(FMonitorInfos)].cbSize := SizeOf(TMonitorInfoEx);
    GetMonitorInfo(Screen.Monitors[iI].Handle, @FMonitorInfos[High(FMonitorInfos)]);
  end;
  MonitorComboBox.ItemIndex := 0;    ;
end;

procedure TConfigurationForm.DetectDisplayModi();
var
 iDevMode: TDeviceMode;
 iModes: array of TDisplayMode;
 iModeIdx, iI: LongInt;
 iStr: string;
begin
  //fill resolutions combobox
  SetLength(iModes, 0);
  SetLength(FAvailableModi, 0);
  iModeIdx := 0;
  while EnumDisplaySettings( @FMonitorInfos[MonitorComboBox.ItemIndex].szDevice[0], iModeIdx, iDevMode) do
  begin
    if (iDevMode.dmBitsPerPel = 32) and (iDevMode.dmPelsWidth >= 800) and (iDevMode.dmPelsHeight >= 600) then
    begin
      SetLength(iModes, Length(iModes) + 1);
      with iModes[High(iModes)] do
      begin
        Width        := iDevMode.dmPelsWidth;
        Height       := iDevMode.dmPelsHeight;
      end;
    end;
    Inc(iModeIdx);
  end;

  ResolutionsComboBox.Items.Clear;
  for iI := Low(iModes) to High(iModes) do
  with iModes[iI] do
  begin
    iStr := IntToStr(Width) + ' x ' + IntToStr(Height);
    if ResolutionsComboBox.Items.IndexOf(iStr) < 0 then
    begin
      ResolutionsComboBox.Items.Add(iStr);
      SetLength(FAvailableModi, Length(FAvailableModi) + 1);
      FAvailableModi[High(FAvailableModi)] := iModes[iI];
    end;
  end;
  SetLength(iModes, 0);

  ResolutionsComboBox.ItemIndex := 0;
end;

end.
