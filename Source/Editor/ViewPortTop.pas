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
unit ViewPortTop;

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
  dglOpenGL,
  FloatArray,
  ViewPort2D,
  Mathematics,
  Base,
  Scene,
  BitmapFont;

type
  TViewPortTopForm = class(TViewPort2DForm)
    procedure FormCreate(Sender: TObject);
  private
  public
    function  CalculateCreateEntityPos(const aX, aY : Integer): TVector3f; override;
    procedure DetectVisibility(); override;
    function  MakeSelectionBox(): TBoundingBox; override;
    procedure RenderScene(const aForSelection : Boolean); override;
  end;

implementation

uses
  Main, Selection;

{$R *.lfm}

function  TViewPortTopForm.CalculateCreateEntityPos(const aX, aY : Integer): TVector3f;
begin
  CalculatePosAtMouse(aX, aY);
  result.x := MouseX;
  result.y := 0;
  result.z := MouseY;
end;

procedure TViewPortTopForm.FormCreate(Sender: TObject);
begin
  inherited;
  Name  := ' Top';
  Axis1 := 'X';
  Axis2 := 'Z';
  Color1 := Vector3f(1,0,0);
  Color2 := Vector3f(0,0,1);
  View2DType := VPT2D_TOP;
end;

procedure TViewPortTopForm.DetectVisibility();
var
  iBoundingBox : TBoundingBox;
begin
  inherited;

  //do we have the visible entities jet?
  if VisibleEntities = nil then exit;

  //create the bounding box
  iBoundingBox.min.x := WidthOffsetNeg;
  iBoundingBox.min.y := -1024;
  iBoundingBox.min.z := HeightOffsetNeg;
  iBoundingBox.max.x := WidthOffsetPos;
  iBoundingBox.max.y := 1024;
  iBoundingBox.max.z := HeightOffsetPos;

  //get the entities in view.
  MainForm.MainScene.EntitiesIntersectBox( iBoundingBox, VisibleEntities, SQD_MODELS or SQD_LIGHTS );
end;

function  TViewPortTopForm.MakeSelectionBox(): TBoundingBox;
var
  iVerts : TFloatArray;
begin
  iVerts := TFloatArray.Create();
  CalculatePosAtMouse(StartX, StartY);
  iVerts.AddVector3f(  Vector3f(MouseX, -1024, MouseY) );
  CalculatePosAtMouse(EndX, EndY);
  iVerts.AddVector3f(  Vector3f(MouseX, 1024, MouseY) );
  result := iVerts.CalculateBoundingBox();
  FreeAndNil(iVerts);
end;

procedure TViewPortTopForm.RenderScene(const aForSelection : Boolean);
begin
  if not(aForSelection) then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  glPushMatrix();
    glRotatef(-90,1,0,0);
    RenderMeshEntities(aForSelection);
    if not(aForSelection) then MainForm.Selection.RenderSelection(ShowLighting);
    RenderLights(VisibleEntities, aForSelection);
  glPopMatrix();
end;

end.