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
unit Main;

{$MODE Delphi}

interface

uses
  Windows,
  SysUtils ,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  dglOpenGL,
  Camera,
  Entity,
  StaticModelEntity,
  AnimatedModelEntity,
  PointLightEntity,
  Mathematics,
  Scene,
  Context,
  Base,
  SceneIO;

type

  { TMainForm }

  TMainForm = class(TForm)
    ApplicationEvents: TApplicationProperties;
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
  public
    FCamRot   : TEuler;
    FStats    : Boolean;
    FTris     : Boolean;
    FDiffuse  : Boolean;
    FMeshBB   : Boolean;
    FLightsBB : Boolean;
    FNormals  : Boolean;
    FBones    : Boolean;

    FContext  : TContext;
    FCamera3D : TCamera;
    FCamera2D : TCamera;
    FScene    : TScene;

    procedure Input();
    procedure Render();
  end;

  TLightFlickerData = class
  private
  public
    Up           : Boolean;
    Color        : TVector3f;
    Size         : Single;
    ColorCounter : Single;
    LightModel   : TStaticModelEntity;

    constructor Create(const aColor : TVector3f; const aSize : Single; const aLightModel : TStaticModelEntity);
  End;

implementation

{$R *.lfm}

uses
  Configuration;

//******************************************************************************
//** Scripting functions                                                      **
//******************************************************************************

constructor TLightFlickerData.Create(const aColor : TVector3f; const aSize : Single; const aLightModel : TStaticModelEntity);
begin
  Up           := true;
  ColorCounter := 0;
  Size         := aSize;
  Color        := aColor;
  LightModel   := aLightModel;
end;

procedure LightCallBack(const aEntity : TEntity; const aFrameTime : Int64);
var
  iData : TLightFlickerData;
  iColor : Single;
begin
  //get the data
  iData       := TLightFlickerData(aEntity.UserData);
  //update the color
  if iData.Up then
  begin
    iData.ColorCounter := iData.ColorCounter + (aFrameTime * (random(6)/100));
    if iData.ColorCounter > 12.5 then
    begin
      iData.ColorCounter := 12.5;
      iData.Up := False;
    end;
  end
  else
  begin
    iData.ColorCounter := iData.ColorCounter - aFrameTime * (random(6)/100);
    if iData.ColorCounter < -12.5 then
    begin
      iData.ColorCounter := -12.5;
      iData.Up := True;
    end;
  end;
  iColor := iData.ColorCounter/255;
  TPointLightEntity(aEntity).Color := iData.Color + iColor;
  TPointLightEntity(aEntity).Radius := iData.Size + ((iData.Size / 100) * (iData.ColorCounter/2));
  iData.LightModel.CustomMaterials.Get(0).GlowColor := Vector3f(0.75, 0.75, 0.75) + (iColor*2);
end;

//******************************************************************************
//** Form functions                                                           **
//******************************************************************************

procedure LoadingProgress(const aProgress, aMax : Integer);
var
  iProgress : Integer;
begin
  //if we dont have a render context then return
  if MainForm.FContext = nil then exit;

  //set the context and camera
  MainForm.FContext.Apply();
  MainForm.FCamera2D.Apply();

  //draw progressbar
  iProgress := Round(aProgress * (250/aMax));
  Engine.Renderer.SetColor(0,0,1,1);
  glBegin(GL_QUADS);
    glVertex2f(275+iProgress,275);
    glVertex2f(275+iProgress,300);
    glVertex2f(275,300);
    glVertex2f(275,275);
  glEnd();
  glLineWidth(2);
  glDisable(GL_DEPTH_TEST);
  Engine.Renderer.SetColor(1,1,1,1);
  glBegin(GL_LINE_LOOP);
    glVertex2f(275,275);
    glVertex2f(275,300);
    glVertex2f(525,300);
    glVertex2f(525,275);
  glEnd();
  glLineWidth(1);

  //swap the buffers
  MainForm.FContext.Swap();
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  iDMScreenSettings : DEVMODE;
  iI                : Integer;
  iEntity           : TEntity;
  iModelEntity      : TAnimatedModelEntity;
  iLightEntity      : TPointLightEntity;
  iIntel            : boolean;
begin
  //create the engine global systems
  InitEngine(ExtractFilePath(Application.ExeName));

  //set some settings stuff.
  iIntel := pos('Intel', Engine.Renderer.Vendor) > 0;
  if iIntel then
    Engine.Log.Print(self.ClassName, 'Intel graphics detected, disabling shadows and SSOA', false);
  if ConfigurationForm.BloomCheckBox.Checked = false then
    Engine.Console.ExecuteCommand('r_glow 0');
  if (ConfigurationForm.AmbientOcclusionCheckBox.Checked = false) or iIntel then
    Engine.Console.ExecuteCommand('r_ssao 0');
  if ConfigurationForm.FXAACheckBox.Checked = false then
    Engine.Console.ExecuteCommand('r_fxaa 0');
  if (ConfigurationForm.ShadowsCheckBox.Checked = false) or iIntel then
    Engine.Console.ExecuteCommand('r_shadows 0');

  //create a rendering context
  FContext := TContext.Create(Handle, Width, Height, true);

  //make it fullscreen
  try
    If ConfigurationForm.FullScreenCheckBox.Checked then
    begin
      ZeroMemory(@iDMScreenSettings, SizeOf(iDMScreenSettings));
      with iDMScreenSettings do begin
              dmSize       := SizeOf(iDMScreenSettings);
              dmPelsWidth  := ConfigurationForm.FAvailableModi[ConfigurationForm.ResolutionsComboBox.ItemIndex].Width;
              dmPelsHeight := ConfigurationForm.FAvailableModi[ConfigurationForm.ResolutionsComboBox.ItemIndex].Height;
              dmBitsPerPel := 32;
              dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
      end;

      if (ChangeDisplaySettingsEx( @ConfigurationForm.FMonitorInfos[ConfigurationForm.MonitorComboBox.ItemIndex].szDevice[0], &iDMScreenSettings, 0, CDS_FULLSCREEN, nil) <> DISP_CHANGE_SUCCESSFUL) then
        Raise Exception.Create('Unable to make window fullscreen');

      SetWindowLong(self.Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) and not WS_BORDER and not WS_SIZEBOX and not WS_DLGFRAME );
      SetWindowPos(self.Handle, HWND_TOP, 0,
                                          Screen.Monitors[ConfigurationForm.MonitorComboBox.ItemIndex].Left,
                                          ConfigurationForm.FAvailableModi[ConfigurationForm.ResolutionsComboBox.ItemIndex].Width,
                                          ConfigurationForm.FAvailableModi[ConfigurationForm.ResolutionsComboBox.ItemIndex].Height,
                                          SWP_FRAMECHANGED);

      //remove the border, place and size window.
      SetWindowLong(self.Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) and not WS_BORDER and not WS_SIZEBOX and not WS_DLGFRAME );
      self.Top    := 0;
      self.Left   := Screen.Monitors[ConfigurationForm.MonitorComboBox.ItemIndex].Left;
      WindowState:=wsMaximized;
    end
    else
    begin
      //remove the border, place and size window.
      self.Top    := 0;
      self.Left   := Screen.Monitors[ConfigurationForm.MonitorComboBox.ItemIndex].Left;
      self.Width  := ConfigurationForm.FAvailableModi[ConfigurationForm.ResolutionsComboBox.ItemIndex].Width;
      self.Height := ConfigurationForm.FAvailableModi[ConfigurationForm.ResolutionsComboBox.ItemIndex].Height;
    end;
  except
    on E: Exception do
    begin
      Engine.Log.Print(self.ClassName, E.Message, true);
    end;
  end;

  if ConfigurationForm.VerticalSyncCheckBox.Checked and WGL_EXT_swap_control then
  begin
    iI := wglGetSwapIntervalEXT;
    if iI<>1 then
      wglSwapIntervalEXT(1);
  end;

  //init other variables
  ShowCursor(False);
  FStats    := false;
  FTris     := false;
  FDiffuse  := false;
  FMeshBB   := false;
  FLightsBB := false;
  FNormals  := false;
  FBones    := false;

  //show form font
  self.ShowOnTop();
  self.Visible := true;
  self.Show();
  self.Repaint();

  //init the camera`s
  FCamera3D := TCamera.Create();
  FCamera3D.SetPerspectiveProjection(60, Width/Height, 0.01, 50);
  FCamera3D.SetPosition( Vector3f(0, 1, 0) );
  FCamRot.yaw := 180;
  FCamera2D := TCamera.Create();
  FCamera2D.SetOrthogonalProjection(0, 800, 600, 0, -1, 1);

  //create a test scene
  LoadingProgress(0, 0);
  FScene := TScene.Create();
  LoadMap('Maps\Test.map', FScene, @LoadingProgress);
  for iI := 0 to FScene.Entities.Count-1 do
    begin
    iEntity := FScene.Entities.Get(iI);
    if iEntity.Name = 'Guard1' then
    begin
      iModelEntity := iEntity as TAnimatedModelEntity;
      iModelEntity.Usage := EU_DYNAMIC;
      iModelEntity.PlayAnimation('all', true, nil, 1, 49);
    end
    else if (iEntity.Name = 'Female1') or (iEntity.Name = 'Female2')  then
    begin
      iModelEntity := iEntity as TAnimatedModelEntity;
      iModelEntity.Usage := EU_DYNAMIC;
      iModelEntity.PlayAnimation('all', true);
    end
    else if iEntity.Name = 'FlickeringLight' then
    begin
      iLightEntity := iEntity as TPointLightEntity;
      iLightEntity.RotateAA(ER_LOCAL, AxisAngle(0,1,0,45));
      iLightEntity.UserData := TLightFlickerData.Create(iLightEntity.Color, iLightEntity.Radius, FScene.Entities.Get(iI+1) as TStaticModelEntity);
      iLightEntity.UpdateCallBack := @LightCallBack;
    end;
  end;

  //reset the cursor
  SetCursorPos(Width div 2,Height div 2);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ChangeDisplaySettings(devmode(nil^), 0);
  ShowCursor(true);

  FreeAndNil(FCamera3D);
  FreeAndNil(FCamera2D);
  FreeAndNil(FScene);
  FreeAndNil(FContext);
  ClearEngine();

  ConfigurationForm.Visible := true;
  ConfigurationForm.PageControl.SetFocus();
  ConfigurationForm.Repaint();
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if FContext <> nil then
    FContext.Resize(Width, Height);

  if FCamera3D <> nil then
    FCamera3D.SetPerspectiveProjection(60, Width/Height, 0.01, 50);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

function BoolToString(aBool : Boolean): String;
begin
  if aBool then
    result := '1'
  else
    result := '0';
end;

begin
  //we can always exit the demo
  if Key = VK_ESCAPE then close;

  //do some console stuff
  if Key = 192 then
  begin
    Engine.Console.Show := not(Engine.Console.Show);
    ShowCursor(Engine.Console.Show);
    SetCursorPos((Width div 2) + Left, (Height div 2) + Top);
  end;

  //add console input
  Engine.Console.Control(Key);

  //if we have console ignore rest of te input
  if Engine.Console.Show then exit;

  //handle other debug keys
  if Key = VK_F1 then
  begin
    FStats := not(FStats);
    Engine.Console.ExecuteCommand('r_stats ' + BoolToString(FStats));
  end
  else if Key = VK_F2 then
  begin
    FTris := not(FTris);
    Engine.Console.ExecuteCommand('r_tris ' + BoolToString(FTris));
  end
  else if Key = VK_F3 then
  begin
    FDiffuse := not(FDiffuse);
    Engine.Console.ExecuteCommand('r_diffuse ' + BoolToString(FDiffuse));
  end
  else if Key = VK_F4 then
  begin
    FMeshBB := not(FMeshBB);
    Engine.Console.ExecuteCommand('r_modelbv ' + BoolToString(FMeshBB));
  end
  else if Key = VK_F5 then
  begin
    FLightsBB := not(FLightsBB);
    Engine.Console.ExecuteCommand('r_lightbv ' + BoolToString(FLightsBB));
  end
  else if Key = VK_F6 then
  begin
    FNormals := not(FNormals);
    Engine.Console.ExecuteCommand('r_normals ' + BoolToString(FNormals));
  end
  else if Key = VK_F7 then
  begin
    FBones := not(FBones);
    Engine.Console.ExecuteCommand('r_bones ' + BoolToString(FBones));
  end
end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Engine.Console.AddChar(Key);
end;

procedure TMainForm.Input();
var
  iCamSpeed            : Single;
  iMove, iStrafe       : integer;
  iCamMove, iCamStrafe : TVector3f;
  iPos                 : TPoint;
  iHD, iWD             : Integer;
begin
  //pre-calculate and reset some stuff
  iCamSpeed  := Engine.Timer.FrameTime * 0.005;
  iWD := (Width div 2) + Left;
  iHD := (Height div 2) + Top;

  //exit if console is visible
  if Engine.Console.Show then
    exit;

  //rotate the camera by mouse
  GetCursorPos(iPos);
  SetCursorPos(iWD,iHD);
  FCamRot.Yaw := FCamRot.Yaw + (iPos.x - iWD) * 0.25;
  FCamRot.Pitch := FCamRot.Pitch + (iPos.y - iHD) * 0.25;
  if FCamRot.Pitch > 89.99  then FCamRot.Pitch := 90;
  if FCamRot.Pitch < -89.99 then FCamRot.Pitch := -90;
  FCamera3D.SetRotationE( FCamRot );

  //move strafe with wasd
  iCamMove   := Vector3f(0,0,-1);
  iCamStrafe := Vector3f(0,0,-1);
  iCamMove.RotateE(FCamRot);
  iCamStrafe.RotateE(Euler(0,FCamRot.yaw - 90.0, 0));
  iMove := 0; iStrafe := 0;
  if GetAsyncKeyState(Ord('W')) and $8000 <> 0 then Inc(iMove);
  if GetAsyncKeyState(Ord('S')) and $8000 <> 0 then Dec(iMove);
  if GetAsyncKeyState(Ord('A')) and $8000 <> 0 then Inc(iStrafe);
  if GetAsyncKeyState(Ord('D')) and $8000 <> 0 then Dec(iStrafe);
  iCamMove   := iCamMove * iCamSpeed * iMove;
  iCamStrafe := iCamStrafe * iCamSpeed * iStrafe;
  FCamera3D.Translate( iCamMove + iCamStrafe );
end;

procedure TMainForm.Render();
begin
  //if we dont have a render context then return
  if FContext = nil then exit;

  //set the context and camera we want to work with
  FContext.Apply();
  FCamera3D.Apply();

  //update the current scene.
  FScene.Update();

  //render the scene
  Engine.Renderer.RenderScene( FScene );

  //render debug
  Engine.RenderDebug();

  //swap the context
  FContext.Swap();
end;

procedure TMainForm.ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
begin
  Engine.Update();
  Input();
  Render();
  Done := false;
end;

end.
