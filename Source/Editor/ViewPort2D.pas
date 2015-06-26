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
unit ViewPort2D;

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
  EditorEntity,
  Entity,
  ModelEntity,
  dglOpenGL,
  ViewPort,
  Scene,
  Mathematics;

type
  TViewPort2DType = (VPT2D_TOP, VPT2D_FRONT, VPT2D_SIDE);

  TViewPort2DForm = class(TViewPortForm)
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
  public
    View2DType : TViewPort2DType;
    Zoom : Single;
    Axis1, Axis2   : String;
    MouseX, MouseY : Single;
    Color1, Color2 : TVector3f;
    VisibleEntities : TSceneQueryData;
    WidthOffsetPos, WidthOffsetNeg : Single;
    HeightOffsetPos, HeightOffsetNeg : Single;
    DoingSelection, CtrPressed : Boolean;
    StartX, StartY, EndX, EndY : Integer;
    LastSelectIdx : Integer;

    procedure SetWindowTitle(); override;
    procedure ResetCamera(); override;
    procedure SetClearColor(); override;
    procedure SetupCameras(); override;
    procedure DetectVisibility(); override;
    procedure RenderGrid(); override;
    procedure Render2DOverlay(); override;
    procedure RenderSelectionQuad(); override;
    procedure CalculatePosAtMouse(aX, aY : Integer); virtual;
    procedure MoveViewWithMouse();
    procedure RenderMeshEntities(const aForSelection : Boolean);
    function  MakeSelectionBox(): TBoundingBox; virtual;
    procedure DoQuadSelection(); override;
    procedure ProcessMouseSelection(const aHits : Integer); override;
  end;

implementation

{$R *.lfm}

uses
  Base,
  Main;

procedure TViewPort2DForm.FormCreate(Sender: TObject);
begin
  inherited;
  ViewType := VPT_2D;
  DoingSelection := false;
  CtrPressed := false;
  LastSelectIdx := -1;
  ResetCamera();
  VisibleEntities := TSceneQueryData.Create();
end;

procedure TViewPort2DForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeAndNil(VisibleEntities);
end;

procedure TViewPort2DForm.ResetCamera();
begin
  Zoom := ConfigurationForm.Scale;
  Camera.SetPosition( Vector3f(0, 0, 0) );
  SetupCameras();
  ShowGrid     := true;
  ShowLighting := true;
  UpdateViewPort();
end;

procedure TViewPort2DForm.SetClearColor();
begin
  glClearColor( ConfigurationForm.ClearColor2D.X,
                ConfigurationForm.ClearColor2D.Y,
                ConfigurationForm.ClearColor2D.Z,
                ConfigurationForm.ClearColor2D.W);
end;

procedure TViewPort2DForm.SetupCameras();
var
  iWidth, iHeight : Single;
begin
  inherited;
  iHeight  := ((ClientHeight)/2) * Zoom;
  iWidth   := (ClientWidth/2) * Zoom;
  if (iWidth = 0) or (iHeight = 0) then exit;
  Camera.SetOrthogonalProjection(-iWidth, iWidth, iHeight, -iHeight, -100000, 100000);
end;

procedure TViewPort2DForm.DetectVisibility();
var
  iWidth, iHeight : Single;
  iVec : TVector3f;
begin
  iVec     := Camera.GetPosition();
  iHeight  := (ClientHeight/2) * Zoom;
  iWidth   := (ClientWidth/2) * Zoom;
  WidthOffsetPos  := iVec.X + iWidth;
  WidthOffsetNeg  := iVec.X - iWidth;
  HeightOffsetPos := iVec.Y + iHeight;
  HeightOffsetNeg := iVec.Y - iHeight;
end;

procedure TViewPort2DForm.RenderGrid();
var
  iI, iEnd : Single;
begin
  glDisable(GL_DEPTH_TEST);
  //render the small lines
  Engine.Renderer.SetColor(ConfigurationForm.SmallGridColor2D);
  glBegin(GL_LINES);
    iEnd  := round(WidthOffsetPos / ConfigurationForm.SmallGridStep2D) * ConfigurationForm.SmallGridStep2D;
    iI    := round(WidthOffsetNeg / ConfigurationForm.SmallGridStep2D) * ConfigurationForm.SmallGridStep2D;
    while iI <= iEnd do
    begin
      glVertex2f(iI, HeightOffsetPos);
      glVertex2f(iI, HeightOffsetNeg);
      iI := iI + ConfigurationForm.SmallGridStep2D
    end;
    iEnd  := round(HeightOffsetPos / ConfigurationForm.SmallGridStep2D) * ConfigurationForm.SmallGridStep2D;
    iI    := round(HeightOffsetNeg / ConfigurationForm.SmallGridStep2D) * ConfigurationForm.SmallGridStep2D;;
    while iI <= iEnd do
    begin
      glVertex2f(WidthOffsetPos, iI);
      glVertex2f(WidthOffsetNeg, iI);
      iI := iI + ConfigurationForm.SmallGridStep2D
    end;
  glEnd();

  //render the large lines
  Engine.Renderer.SetColor(ConfigurationForm.LargeGridColor2D);
  glBegin(GL_LINES);
    iEnd := round(WidthOffsetPos / ConfigurationForm.LargeGridStep2D) * ConfigurationForm.LargeGridStep2D;
    iI   := round(WidthOffsetNeg / ConfigurationForm.LargeGridStep2D) * ConfigurationForm.LargeGridStep2D;
    while iI <= iEnd do
    begin
      glVertex2f(iI, HeightOffsetPos);
      glVertex2f(iI, HeightOffsetNeg);
      iI := iI + ConfigurationForm.LargeGridStep2D
    end;
    iEnd  := round(HeightOffsetPos / ConfigurationForm.LargeGridStep2D) * ConfigurationForm.LargeGridStep2D;
    iI    := round(HeightOffsetNeg / ConfigurationForm.LargeGridStep2D) * ConfigurationForm.LargeGridStep2D;
    while iI <= iEnd do
    begin
      glVertex2f(WidthOffsetPos, iI);
      glVertex2f(WidthOffsetNeg, iI);
      iI := iI + ConfigurationForm.LargeGridStep2D
    end;
  glEnd();

  //render the main lines
  Engine.Renderer.SetColor(Color1);
  glBegin(GL_LINES);
    glVertex2f(WidthOffsetPos, 0);
    glVertex2f(WidthOffsetNeg, 0);
  glEnd();
  Engine.Renderer.SetColor(Color2);
  glBegin(GL_LINES);
    glVertex2f(0, HeightOffsetPos);
    glVertex2f(0, HeightOffsetNeg);
  glEnd();
end;

procedure TViewPort2DForm.SetWindowTitle();
begin
  if Focused then
    ViewportLabel.Caption := Name + ' - ('+ Axis1 + ', ' + Axis2 + ' : '
                                   + FormatFloat('0.0', MouseX)
                                   + ', ' + FormatFloat('0.0', MouseY) + ')'
  else
    ViewportLabel.Caption := Name;
end;

procedure TViewPort2DForm.Render2DOverlay();
begin
  //Axis 1
  Engine.Font.Render(Color1.x, Color1.y, Color1.z, 54, 7, 0.2, Axis1);
  glBegin(GL_LINES);
    glVertex2f(10,10);
    glVertex2f(50,10);
  glEnd();

  //Axis 2
  Engine.Font.Render(Color2.x, Color2.y, Color2.z, 7, 54, 0.2, Axis2);
  glBegin(GL_LINES);
    glVertex2f(10,10);
    glVertex2f(10,50);
  glEnd();
end;

procedure TViewPort2DForm.RenderSelectionQuad();
begin
  if DoingSelection then
  begin
    Engine.Renderer.SetColor(0,1,0,0);
    glLineWidth(2);
    glBegin(GL_LINE_LOOP);
      glVertex2f(StartX,ClientHeight-StartY);
      glVertex2f(StartX,ClientHeight-EndY);
      glVertex2f(EndX,ClientHeight-EndY);
      glVertex2f(EndX,ClientHeight-StartY);
    glEnd();
    glLineWidth(1);
  end;
end;

procedure TViewPort2DForm.CalculatePosAtMouse(aX, aY : Integer);
var
  iNewX, iNewY : Single;
  iHeight, iWidth : Single;
  iVec : TVector3f;
begin
  iVec    := Camera.GetPosition();
  iHeight := (ClientHeight/2) * Zoom;
  iWidth  := (ClientWidth/2) * Zoom;
  iNewX   := (-ClientWidth / 2) + aX;
  iNewY   := (ClientHeight /2) + -aY;
  MouseX  := iNewX * iWidth / (ClientWidth / 2) + iVec.X;
  MouseY  := iNewY * iHeight / (ClientHeight / 2) + iVec.Y;
end;

procedure TViewPort2DForm.MoveViewWithMouse();
var
  iDifX, iDifY : Integer;
begin
  if DoingSelection then exit;
  if not(RightMousePressed) then exit;
  getCursorPos(CurrentMousePos);
  SetCursorPos(StartMousePos.X, StartMousePos.Y);
  iDifX := StartMousePos.X - CurrentMousePos.X;
  iDifY := StartMousePos.Y - CurrentMousePos.Y;
  Camera.Translate( Vector3f(iDifX * Zoom, -iDifY * Zoom, 0) );
end;

procedure TViewPort2DForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
  if DoingSelection then exit;
  Zoom := Zoom + ConfigurationForm.ZoomStep2D;
  if Zoom > ConfigurationForm.ZoomMax2D then
    Zoom := ConfigurationForm.ZoomMax2D;
  SetupCameras();
  UpdateViewPort();
end;

procedure TViewPort2DForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
  if DoingSelection then exit;
  Zoom := Zoom - ConfigurationForm.ZoomStep2D;
  if Zoom < ConfigurationForm.ZoomMin2D then
    Zoom := ConfigurationForm.ZoomMin2D;
  SetupCameras();
  UpdateViewPort();
end;

procedure TViewPort2DForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  GetWindowRect(Handle, Rectangle);
  Rectangle.Left   := Rectangle.Left + 10;
  Rectangle.Top    := Rectangle.Top + TopPanel.Height + 10;
  Rectangle.Right  := Rectangle.Right - 10;
  Rectangle.Bottom := Rectangle.Bottom - 10;
  ClipCursor(@Rectangle);
  GetCursorPos(StartMousePos);
  SetFocus();

  //if we are already doing selection then exit
  if DoingSelection then exit;

  //leftmouse down with shift for selection
  if (Button = mbLeft) and (ssShift in Shift) then
  begin
    if ssCtrl in Shift then CtrPressed := true;
    DoingSelection := true;
    StartX  := X;
    StartY  := Y;
    EndX  := X;
    EndY  := Y;
  end;

  //rightbutton down
  if Button = mbRight then
  begin
    RightMousePressed := true;
    ShowCursor(false);
    MainForm.Repaint();
  end;

  //update the view
  UpdateViewPort();
end;

procedure TViewPort2DForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  ClipCursor(nil);

  //leftmouse down for selection
  if (Button = mbLeft) and DoingSelection then
  begin
    if (StartX = EndX) and (StartY = EndY) then
      DoMouseSelection(X,Y)
    else
      DoQuadSelection();
    DoingSelection := false;
    CtrPressed     := false;
  end;

  //rightmouse up
  if Button = mbRight then
  Begin
    ShowCursor(true);
    RightMousePressed := false;
  end;

  //update the view
  UpdateViewPort();
end;

procedure TViewPort2DForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if DoingSelection then
  begin
    EndX := X;
    EndY := Y;
  end;

  CalculatePosAtMouse(X, Y);
  MoveViewWithMouse();
  UpdateViewPort();
end;

procedure TViewPort2DForm.RenderMeshEntities(const aForSelection : Boolean);
var
  iI : Integer;
  iEntity : TEntity;
begin
  //do we have the visible entities jet?
  if VisibleEntities = nil then exit;

  //models
  if not(aForSelection) then Engine.Renderer.SetColor(ConfigurationForm.MeshColor2D);
  for iI := 0 to VisibleEntities.Models.Count-1 do
  begin
    iEntity := VisibleEntities.Models.Get(iI);

    if aForSelection then
      if TEditorEntity(iEntity.UserData).TreeNode.Selected and CtrPressed then continue
    else
      if TEditorEntity(iEntity.UserData).TreeNode.Selected then continue;

    if aForSelection then glLoadName(TEditorEntity(iEntity.UserData).SelectID);
       (iEntity as TModelEntity).Render(false, aForSelection);
  end;
end;

function  TViewPort2DForm.MakeSelectionBox(): TBoundingBox;
begin
  //do nothing
end;

procedure TViewPort2DForm.DoQuadSelection();
var
  iBoundingBox : TBoundingBox;
  iSelEntities : TSceneQueryData;
  iSelection   : Integer;
begin
  if CtrPressed = false then MainForm.Selection.DeselectAll();

  iSelEntities := TSceneQueryData.Create();
  iBoundingBox := MakeSelectionBox();
  if ShowLighting then
    iSelection := SQD_MODELS or SQD_LIGHTS
  else
    iSelection := SQD_MODELS;
  MainForm.MainScene.EntitiesIntersectBox( iBoundingBox, iSelEntities, iSelection, true, true );
  MainForm.Selection.AddSceneQueryData( iSelEntities );
  FreeAndNil(iSelEntities);
  MainForm.UpdateViewPorts();
end;

procedure TViewPort2DForm.ProcessMouseSelection(const aHits : Integer);
var
  iI, iClosestIdx : integer;
  iMinDepth : GLuint;
begin
  if CtrPressed then
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
      MainForm.Selection.AddEntity( MainForm.MainScene.Entities.Get(iClosestIdx) );
    end;
  end
  else
  begin
    if aHits = 0 then
      MainForm.Selection.DeselectAll()
    else
    begin
      LastSelectIdx := LastSelectIdx + 1;
      if LastSelectIdx > aHits-1 then
        LastSelectIdx := 0;
      MainForm.Selection.DeselectAll();
      MainForm.Selection.AddEntity( MainForm.MainScene.Entities.Get( FSelectBuffer[(LastSelectIdx*4)+3] ) );
    end;
  end;
end;

end.
