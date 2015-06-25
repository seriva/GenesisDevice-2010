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
unit ViewPort3D;

{$MODE Delphi}

interface

uses
  Windows,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  dglOpenGL,
  Mathematics,
  ViewPort,
  Texture,
  Entity,
  ModelEntity,
  FrameBuffer,
  RenderBuffer,
  EditorEntity,
  Base;

type
  TViewPort3DForm = class(TViewPortForm)
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    Pos : TVector3f;
    Dir : TVector3f;
    CameraRotation : TEuler;

    FrameBuffer  : TFrameBuffer;
    ColorMap     : TTexture;
    DepthBuffer  : TRenderBuffer;

    procedure InitFrameBuffer();
    procedure ClearFrameBuffer();
  public
    function  CalculateCreateEntityPos(const aX, aY : Integer): TVector3f; override;
    procedure SetWindowTitle(); override;
    procedure ResetCamera(); override;
    procedure RenderScene(const aForSelection : Boolean); override;
    procedure SetClearColor(); override;
    procedure SetupCameras(); override;
    procedure RenderGrid(); override;
    procedure DetectVisibility(); override;
    procedure ProcessMouseSelection(const aHits : Integer); override;
  end;

implementation

{$R *.lfm}

uses
  Main;

function  TViewPort3DForm.CalculateCreateEntityPos(const aX, aY : Integer): TVector3f;
var
  iDir : TVector3f;
begin
  iDir   := Dir * 5;
  result := Camera.GetPosition + iDir;
end;

procedure TViewPort3DForm.InitFrameBuffer();
begin
  if Context = nil then exit;
  Context.Apply();
  ClearFrameBuffer();
  ColorMap    := TTexture.CreateRenderTexture(ClientWidth, ClientHeight, GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE);
  DepthBuffer := TRenderBuffer.Create(ClientWidth, ClientHeight, GL_DEPTH_COMPONENT24);
  FrameBuffer := TFrameBuffer.Create();
  FrameBuffer.Bind();
  FrameBuffer.AttachRenderTexture(ColorMap, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D  );
  FrameBuffer.AttachRenderBuffer(DepthBuffer, GL_DEPTH_ATTACHMENT_EXT );
	glReadBuffer(GL_NONE);
  FrameBuffer.Status();
  FrameBuffer.Unbind();
  ColorMap.UnBind();
end;

procedure TViewPort3DForm.ClearFrameBuffer();
begin
  FreeAndNil( FrameBuffer );
  FreeAndNil( ColorMap );
  FreeAndNil( DepthBuffer );
end;

procedure TViewPort3DForm.FormCreate(Sender: TObject);
begin
  ViewType := VPT_3D;
  ResetCamera();
  inherited;
  InitFrameBuffer();
end;

procedure TViewPort3DForm.FormDestroy(Sender: TObject);
begin
  ClearFrameBuffer();
  inherited;
end;

procedure TViewPort3DForm.ResetCamera();
begin
  Name := ' Perspective';
  ShowGrid     := true;
  ShowLighting := true;
  Pos  := Vector3f(ConfigurationForm.StartPos3D.X, ConfigurationForm.StartPos3D.Y, ConfigurationForm.StartPos3D.Z);
  Dir  := Vector3f(0, 0, -1);
  CameraRotation := Euler(0,0,0);
end;

procedure TViewPort3DForm.SetClearColor();
begin
  glClearColor( ConfigurationForm.ClearColor3D.X,
                ConfigurationForm.ClearColor3D.Y,
                ConfigurationForm.ClearColor3D.Z,
                ConfigurationForm.ClearColor3D.W);
end;

procedure TViewPort3DForm.SetupCameras();
begin
  inherited;
  Camera.SetModelViewMatrix( Matrix_Identity() );
  Camera.SetPerspectiveProjection( ConfigurationForm.Fov3D, Width/Height, ConfigurationForm.NearPlane3D, ConfigurationForm.FarPlane3D );
  Camera.SetPosition( Vector3f( Pos.X, Pos.Y, Pos.Z) );
  Camera.SetRotationE(CameraRotation);
end;

procedure TViewPort3DForm.RenderGrid();
var
  iI, iSize : Single;
  iJ : Integer;
begin
  //if we don`t have a framebuffer then exit
  if FrameBuffer = nil then exit;

  //bind the framebuffer
  FrameBuffer.Bind();
  glViewport(0, 0, ClientWidth, ClientHeight);
  glClearColor(0,0,0,0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);

  //fill the scene with the depthbuffer
  Engine.Renderer.SetColor(0, 0, 0, 0);
  With MainForm.MainScene.VisibleEntities do
  begin
    for iJ := 0 to Models.Count-1 do
      (Models.Get(iJ) as TModelEntity).Render(false, false);
  end;

  //render the grid
  iSize := ConfigurationForm.GridSize3D/2;

  //render the main gridlines
  Engine.Renderer.SetColor(ConfigurationForm.GridColor3D);
  glBegin(GL_LINES);
    iI := -iSize;
    while iI <= iSize do
    begin
      if iI <> 0 then
      begin
        glVertex3f(-iSize, 0, iI);
        glVertex3f( iSize, 0, iI);
        glVertex3f( iI, 0, -iSize);
        glVertex3f( iI, 0,  iSize);
      end;
      iI := iI + ConfigurationForm.GridStep3D;
    end;
  glEnd();

  //render the main axis
  Engine.Renderer.SetColor(1,0,0,1);
  glBegin(GL_LINES);
    glVertex3f(-iSize, 0, 0);
    glVertex3f( iSize, 0, 0);
  glEnd();
  Engine.Renderer.SetColor(0,1,0,1);
  glBegin(GL_LINES);
    glVertex3f(0, -iSize, 0);
    glVertex3f(0,  iSize, 0);
  glEnd();
  Engine.Renderer.SetColor(0,0,1,1);
  glBegin(GL_LINES);
    glVertex3f(0, 0, -iSize);
    glVertex3f(0, 0,  iSize);
  glEnd();

  //unbind the framebuffer
  FrameBuffer.Unbind();
end;

procedure TViewPort3DForm.RenderScene(const aForSelection : Boolean);
var
  iI : Integer;
  iEntity : TEntity;
begin
  if aForSelection then
  begin
    with MainForm.MainScene.VisibleEntities do
    begin
      for iI := 0 to Models.Count-1 do
      begin
        iEntity := Models.Get(iI);
        glLoadName(TEditorEntity(iEntity.UserData).SelectID);
        (iEntity as TModelEntity).Render(false, true);
      end;
    end;
  end
  else
  begin
    //render the scene
    Engine.Renderer.RenderScene( MainForm.MainScene );

    //add scene without lighting
    if Not(ShowLighting) then
    begin
      glViewport(0, 0, ClientWidth, ClientHeight);
      glDepthMask(GLboolean(TRUE));
      MainForm.NoLightShader.Bind();
      MainForm.NoLightShader.SetInt('colorMap', 0);
      Engine.CurrentContext.GBuffer.ColorMap.Bind(0);
        Engine.Renderer.RenderScreenQuad();
      Engine.CurrentContext.GBuffer.ColorMap.UnBind();
      MainForm.NoLightShader.Unbind();
    end;

    //render the actual grid
    if (ColorMap <> nil) and (ShowGrid) then
    begin
      glViewport(0, 0, ClientWidth, ClientHeight);
      glDisable(GL_DEPTH_TEST);
      glDepthMask(GLboolean(TRUE));
      MainForm.GridShader.Bind();
      MainForm.GridShader.SetInt('gridMap', 0);
      ColorMap.Bind(0);
        Engine.Renderer.RenderScreenQuad();
      ColorMap.Unbind();
      MainForm.GridShader.Unbind();
    end;

    //render the selection
    MainForm.Selection.RenderSelection(ShowLighting);
  end;

  //render lights
  RenderLights(MainForm.MainScene.VisibleEntities, aForSelection);
end;

procedure TViewPort3DForm.DetectVisibility();
begin
  MainForm.MainScene.Update();
end;

procedure TViewPort3DForm.SetWindowTitle();
begin
  if Focused then
    ViewportLabel.Caption := Name + ' - (X, Y, Z : '
                             + FormatFloat('0', Pos.X) + ', '
                             + FormatFloat('0', Pos.Y) + ', '
                             + FormatFloat('0', Pos.Z) + ')'
  else
    ViewportLabel.Caption := Name;
end;

procedure TViewPort3DForm.ProcessMouseSelection(const aHits : Integer);
var
  iI, iClosestIdx : integer;
  iEntity : TEntity;
  iMinDepth : GLuint;
begin
  if aHits = 0 then
    MainForm.Selection.DeselectAll()
  else
  begin
    iMinDepth := 4294967295;
    for iI := 0 to aHits-1 do
    begin
      if FSelectBuffer[(iI*4)+1] < iMinDepth then
      begin
        iMinDepth := FSelectBuffer[(iI*4)+1];
        iClosestIdx := FSelectBuffer[(iI*4)+3];
      end;
    end;
    iEntity := MainForm.MainScene.Entities.Get(iClosestIdx);
    if TEditorEntity(iEntity.UserData).TreeNode.MultiSelected then
      MainForm.Selection.RemoveEntity( iEntity  )
    else
      MainForm.Selection.AddEntity( iEntity  );

    MainForm.UpdateViewPorts();
  end;
end;

procedure TViewPort3DForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if (ssShift in Shift) and (Button = mbLeft) then
    DoMouseSelection(X, Y);

  if (ssShift in Shift) then exit;

  Windows.GetWindowRect(Handle, Rectangle);
  Rectangle.Left   := Rectangle.Left + 10;
  Rectangle.Top    := Rectangle.Top + TopPanel.Height + 10;
  Rectangle.Right  := Rectangle.Right - 10;
  Rectangle.Bottom := Rectangle.Bottom - 10;
  ClipCursor(@Rectangle);
  GetCursorPos(StartMousePos);
  SetFocus();

  //rightbutton down
  if Button = mbRight then
    RightMousePressed := true;

  //leftbutton down
  if Button = mbLeft then
    LeftMousePressed := true;

  //update the view
  ShowCursor(false);
  Cursor := crNone;
  UpdateViewPort();
end;

procedure TViewPort3DForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if ssShift in Shift then exit;

  if (Button = mbLeft) and (Button = mbRight) then
  Begin
    ClipCursor(nil);
    ShowCursor(true);
    Cursor := crDefault;
    RightMousePressed := false;
    LeftMousePressed := false;
    UpdateViewPort();
    exit;
  end;

  //leftmouse up
  if Button = mbLeft then
  Begin
    ClipCursor(nil);
    ShowCursor(true);
    Cursor := crDefault;
    LeftMousePressed := false;
    UpdateViewPort();
    exit;
  end;

  //rightmouse up
  if Button = mbRight then
  Begin
    ClipCursor(nil);
    ShowCursor(true);
    Cursor := crDefault;
    RightMousePressed := false;
    UpdateViewPort();
    exit;
  end;
end;

procedure TViewPort3DForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
  Pos := Pos - (Dir * ConfigurationForm.ZoomStep3D);
  SetupCameras();
  UpdateViewPort();
end;

procedure TViewPort3DForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
  Pos := Pos + (Dir * ConfigurationForm.ZoomStep3D);
  SetupCameras();
  UpdateViewPort();
end;

procedure TViewPort3DForm.FormResize(Sender: TObject);
begin
  InitFrameBuffer();
  inherited;
end;

procedure TViewPort3DForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  iDeltaX, iDeltaY : Single;
  iV : TVector3f;
begin
  inherited;
  getCursorPos(CurrentMousePos);

  if RightMousePressed and not(LeftMousePressed) then
  begin
    SetCursorPos(StartMousePos.X, StartMousePos.Y);
    CameraRotation.yaw   := CameraRotation.yaw - ((StartMousePos.X - CurrentMousePos.X)/7.5);
    CameraRotation.pitch := CameraRotation.pitch - ((StartMousePos.Y - CurrentMousePos.Y)/7.5);
    if CameraRotation.pitch < -89.9999 then CameraRotation.pitch := -89.9999;
    if CameraRotation.pitch >  89.9999 then CameraRotation.pitch :=  89.9999;
    Dir := Vector3f(0,0,-1);
    Dir.RotateE(CameraRotation);
  end;

  if LeftMousePressed and not(RightMousePressed) then
  begin
    SetCursorPos(StartMousePos.X, StartMousePos.Y);
    CameraRotation.yaw   := CameraRotation.yaw - ((StartMousePos.X - CurrentMousePos.X)/7.5);
    iDeltaY := (StartMousePos.Y - CurrentMousePos.Y)/30;
    Dir := Vector3f(0,0,-1);
    Dir.RotateE(CameraRotation);
    iV :=  Vector3f(0,0,-1);
    iV.RotateE(Euler(0, CameraRotation.yaw, 0));
    Pos := Pos + (iV * iDeltaY);
  end;

  if RightMousePressed and LeftMousePressed then
  begin
    SetCursorPos(StartMousePos.X, StartMousePos.Y);
    iDeltaX := (StartMousePos.X - CurrentMousePos.X)/30;
    iDeltaY := (StartMousePos.Y - CurrentMousePos.Y)/30;
    iV := Vector3f(Dir.x,0,Dir.z);
    iV.RotateE(Euler(0, -90, 0));
    Pos := Pos + (iV * iDeltaX);
    Pos := Pos + (Vector3f(0,1,0) * iDeltaY);
  end;

  SetupCameras();
  UpdateViewPort();
end;

end.
