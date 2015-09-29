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
unit ViewPort;

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
  Mathematics,
  dglOpenGL,
  ExtCtrls,
  Buttons,
  Context,
  Base,
  Scene,
  StdCtrls,
  EditorEntity,
  Entity,
  Camera,
  StaticModelEntity,
  AnimatedModelEntity,
  PointLightEntity,
  SpotLightEntity,
  BrowserNodeData,
  ComCtrls;

type
  TViewPortType = (VPT_2D, VPT_3D);

  TViewPortForm = class(TForm)
    TopPanel: TPanel;
    ViewportLabel: TLabel;
    ResetViewSpeedButton: TSpeedButton;
    ToggleGridSpeedButton: TSpeedButton;
    ToggleLightingSpeedButton: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ResetViewSpeedButtonClick(Sender: TObject);
    procedure ToggleGridSpeedButtonClick(Sender: TObject);
    procedure ToggleLightingSpeedButtonClick(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    procedure CreateEntity(const aData : TBrowserNodeData; const aX, aY : Integer);
  public
    ViewType          : TViewPortType;
    Context           : TContext;
    LeftMousePressed  : Boolean;
    RightMousePressed : Boolean;
    ShowGrid          : Boolean;
    ShowLighting      : Boolean;
    StartMousePos     : TPoint;
    CurrentMousePos   : TPoint;
    Rectangle         : Rect;
    Name              : String;
    Camera            : TCamera;
    CameraOverlay     : TCamera;
    FSelectBuffer : array[0..256] of GLuint;

    procedure RenderLights(const aSceneQueryData : TSceneQueryData; const aForSelection : Boolean = false);
    procedure SetWindowTitle(); virtual;
    procedure ResetCamera(); virtual;
    procedure SetClearColor(); virtual;
    procedure SetupCameras(); virtual;
    procedure RenderGrid(); virtual;
    procedure DetectVisibility(); virtual;
    procedure RenderScene(const aForSelection : Boolean); virtual;
    procedure Render2DOverlay(); virtual;
    procedure RenderSelectionQuad(); virtual;
    procedure DoMouseSelection(const aX, aY : Integer);
    procedure DoQuadSelection(); virtual;
    procedure ProcessMouseSelection(const aHits : Integer); virtual;
    function  CalculateCreateEntityPos(const aX, aY : Integer): TVector3f; virtual;

    procedure UpdateViewPort();
  end;

implementation

uses
  Main;

{$R *.lfm}

procedure TViewPortForm.FormCreate(Sender: TObject);
var
  aHasGBuffer : Boolean;
begin
  //create the cameras
  formStyle     := fsMDIChild;
  Camera        := TCamera.Create();
  CameraOverlay := TCamera.Create();
  ResetCamera();
  SetupCameras();

  //the 3d context should have a GBuffer
  If ViewType = VPT_3D then
    aHasGBuffer := true
  else
    aHasGBuffer := false;

  //init some vars
  ShowGrid := true;
  ShowLighting := true;

  //create a rendering context
  Context := TContext.Create(self.Handle, ClientWidth, ClientHeight, aHasGBuffer);
  Context.Resize( ClientWidth, ClientHeight );

  //Hide the titlebar
  ViewportLabel.ControlStyle := ControlStyle + [csOpaque];
end;

procedure TViewPortForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Context);
  FreeAndNil(Camera);
  FreeAndNil(CameraOverlay);
end;

procedure TViewPortForm.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Source is TTreeView then
    CreateEntity( TBrowserNodeData(TTreeView(Source).Selected.data), X, Y);
  SetFocus();
end;

procedure TViewPortForm.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Source is TTreeView then
    Accept := true;
end;

procedure TViewPortForm.FormMouseEnter(Sender: TObject);
begin
  SetFocus();
  MainForm.UpdateViewPorts();
end;

procedure TViewPortForm.FormResize(Sender: TObject);
begin
  if Context <> nil then
  begin
    Context.Resize(ClientWidth, ClientHeight);
    SetupCameras();
    UpdateViewPort();
  end;
end;

procedure TViewPortForm.FormActivate(Sender: TObject);
begin
  MainForm.UpdateViewPorts();
end;

procedure TViewPortForm.FormPaint(Sender: TObject);
begin
  UpdateViewPort();
end;

procedure TViewPortForm.ResetViewSpeedButtonClick(Sender: TObject);
begin
  ResetCamera();
  SetupCameras();
  UpdateViewPort();
end;

procedure TViewPortForm.ToggleGridSpeedButtonClick(Sender: TObject);
begin
  ShowGrid := not(ShowGrid);
  UpdateViewPort();
end;

procedure TViewPortForm.ToggleLightingSpeedButtonClick(Sender: TObject);
begin
  ShowLighting := not(ShowLighting);
  UpdateViewPort();
end;

procedure TViewPortForm.SetWindowTitle();
begin
  //do nothing
end;

procedure TViewPortForm.ResetCamera();
begin
  //do nothing
end;

procedure TViewPortForm.SetClearColor();
begin
  //do nothing
end;

procedure TViewPortForm.SetupCameras();
begin
  CameraOverlay.SetOrthogonalProjection(0, ClientWidth, ClientHeight, 0, -1, 1);
end;

procedure TViewPortForm.RenderGrid();
begin
  //do nothing
end;

procedure TViewPortForm.DetectVisibility();
begin
  //do nothing
end;

procedure TViewPortForm.RenderScene(const aForSelection : Boolean);
begin
  //do nothing
end;

procedure TViewPortForm.Render2DOverlay();
begin
  //do nothing
end;

procedure TViewPortForm.RenderSelectionQuad();
begin
  //do nothing
end;

procedure TViewPortForm.DoQuadSelection();
begin
  //do nothing
end;

procedure TViewPortForm.ProcessMouseSelection(const aHits : Integer);
begin
  //do nothing
end;

function TViewPortForm.CalculateCreateEntityPos(const aX, aY : Integer): TVector3f;
begin
    //do nothing
end;

procedure TViewPortForm.DoMouseSelection(const aX, aY : Integer);
var
  iHits, iClosestIdx : integer;
  iViewPort : TVector4i;
  iProj : TMatrix4x4;
begin
  glGetIntegerv (GL_VIEWPORT, @iViewPort);
  glSelectBuffer(255, @FSelectBuffer);
  glRenderMode(GL_SELECT);
  glInitNames();
  glPushName(0);
  iProj := Camera.GetProjectionModelViewMatrix();

  glMatrixMode (GL_PROJECTION);
  glPushMatrix();
    glLoadIdentity ();
    gluPickMatrix(aX, (iViewPort[3] - aY), 3.0, 3.0, iViewPort);
    glMultMatrixf(@iProj.data[0]);
    glMatrixMode(GL_MODELVIEW);
    glUseProgramObjectARB(0);

    RenderScene(true);

  glMatrixMode (GL_PROJECTION);
  glPopMatrix();
  iHits := glRenderMode(GL_RENDER);
  ProcessMouseSelection(iHits);

  MainForm.UpdateViewPorts();
end;

procedure TViewPortForm.RenderLights(const aSceneQueryData : TSceneQueryData; const aForSelection : Boolean = false);
var
  iI : Integer;
  iV : TVector3f;
begin
  //do we have the visible entities jet?
  if aSceneQueryData = nil then exit;

  if not(ShowLighting) then exit;

  glPointSize(20);
  glDisable(GL_DEPTH_TEST);

  if aForSelection = false then
  begin
    glEnable(GL_POINT_SPRITE_ARB);
    MainForm.LightShader.Bind();
    MainForm.LightShader.SetInt('lightMap', 0);
    MainForm.LightTexture.Bind(0);
    glTexEnvi(GL_POINT_SPRITE_ARB,GL_COORD_REPLACE_ARB, 1);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
  end;

  for iI := 0 to aSceneQueryData.Lights.Count-1 do
  begin
    iV := aSceneQueryData.Lights.Get(iI).GetPosition();
    if aForSelection then
      glLoadName(TEditorEntity(aSceneQueryData.Lights.Get(iI).UserData).SelectID);
    glBegin(GL_POINTS);
      glVertex3fv(@iV.x);
    glEnd();
  end;

  glPointSize(1);
  glEnable(GL_DEPTH_TEST);

  if aForSelection = false then
  begin
    MainForm.LightShader.Unbind();
    glDisable(GL_BLEND);
    glDisable(GL_POINT_SPRITE_ARB);
  end;
end;

procedure TViewPortForm.UpdateViewPort();
begin
  //if we dont have a render context then return
  if Context = nil then exit;

  //make the window current and clear the window
  Context.Apply();

  //set the clearcolor
  SetClearColor();

  //setup the camera
  Camera.Apply();

  //detect visibility
  DetectVisibility();

  //when 2d render the grid first
  if ShowGrid then RenderGrid();

  //render the scene
  RenderScene(false);

  //setup the matrix for rendering the 2d overlay
  CameraOverlay.Apply();

  //render the outlay when selected
  if Focused then
    Engine.Renderer.SetColor(0,1,0,1)
  else
    Engine.Renderer.SetColor(0.9375,0.9375,0.9375,1);

  glLineWidth(4);
  glDisable(GL_DEPTH_TEST);
  glBegin(GL_LINE_LOOP);
    glVertex2f(1,1);
    glVertex2f(1,ClientHeight-TopPanel.Height-1);
    glVertex2f(ClientWidth-1,ClientHeight-TopPanel.Height-1);
    glVertex2f(ClientWidth-1,1);
  glEnd();
  glLineWidth(1);

  //render the other 2D stuff
  Render2DOverlay();

  //render possible 2D selection quad
  RenderSelectionQuad();

  //swap the buffers
  Context.Swap();

  //check GL errors
  Engine.Renderer.CheckErrors();

  //update the label
  SetWindowTitle();
  ViewportLabel.Refresh();
end;

procedure TViewPortForm.CreateEntity(const aData : TBrowserNodeData; const aX, aY : Integer);
var
  iPos : TVector3f;
  iEntity : TEntity;
  iStr : String;
begin
  MainForm.Selection.DeselectAll();
  iPos := CalculateCreateEntityPos(aX, aY);
  if aData = nil then exit;
  case aData.NodeType of
    NT_MODEL :
    begin
      Cursor := crHourGlass;
      iStr := aData.FileName;
      Delete(iStr, 1, Length(ExtractFilePath(Application.ExeName)));
      if LowerCase(ExtractFileExt(iStr)) = '.obj' then
        iEntity := TStaticModelEntity.Create(MainForm.MainScene, iStr)
      else if LowerCase(ExtractFileExt(iStr)) = '.md5' then
        iEntity := TAnimatedModelEntity.Create(MainForm.MainScene, iStr);
      Cursor := crDefault;
    end;
    NT_POINTLIGHT :
    begin
      iEntity := TPointLightEntity.Create(MainForm.MainScene, 1, Vector3f(1,1,1), true);
      iEntity.SetScale(5);
    end;
    NT_SPOTLIGHT :
    begin
      iEntity := TSpotLightEntity.Create(MainForm.MainScene, 1, 30, 15, Vector3f(1,1,1), true);
      iEntity.SetScale(5);
      iEntity.RotateAA(ER_LOCAL, AxisAngle(1,0,0,-90));
    end;
  end;

  iEntity.SetPosition(iPos);
  iEntity.UserData := TEditorEntity.Create();
  TEditorEntity(iEntity.UserData).SelectID := MainForm.MainScene.Entities.Count-1;
  MainForm.AddEntityToSceneBrowser(iEntity);
  MainForm.Selection.AddEntity( iEntity );
  MainForm.UpdateViewPorts();
end;

end.
