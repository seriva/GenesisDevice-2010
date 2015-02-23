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
unit ViewPortSide;

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
  Base,
  ViewPort2D,
  FloatArray,
  dglOpenGL,
  Scene,
  Mathematics;

type
  TViewPortSideForm = class(TViewPort2DForm)
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

function  TViewPortSideForm.CalculateCreateEntityPos(const aX, aY : Integer): TVector3f;
begin
  CalculatePosAtMouse(aX, aY);
  result.x := 0;
  result.y := MouseY;
  result.z := MouseX;
end;

procedure TViewPortSideForm.FormCreate(Sender: TObject);
begin
  inherited;
  Name  := ' Side';
  Axis1 := 'Z';
  Axis2 := 'Y';
  Color1 := Vector3f(0,0,1);
  Color2 := Vector3f(0,1,0);
  View2DType := VPT2D_SIDE;
end;

procedure TViewPortSideForm.DetectVisibility();
var
  iBoundingBox : TBoundingBox;
begin
  inherited;

  //do we have the visible entities jet?
  if VisibleEntities = nil then exit;

  //create the bounding box
  iBoundingBox.min.x := -1024;
  iBoundingBox.min.y := HeightOffsetNeg;
  iBoundingBox.min.z := WidthOffsetNeg;
  iBoundingBox.max.x := 1024;
  iBoundingBox.max.y := HeightOffsetPos;
  iBoundingBox.max.z := WidthOffsetPos;

  //get the entities in view.
  MainForm.MainScene.EntitiesIntersectBox( iBoundingBox, VisibleEntities, SQD_MODELS or SQD_LIGHTS );
end;

function  TViewPortSideForm.MakeSelectionBox(): TBoundingBox;
var
  iVerts : TFloatArray;
begin
  iVerts := TFloatArray.Create();
  CalculatePosAtMouse(StartX, StartY);
  iVerts.AddVector3f(  Vector3f(-1024, MouseY, MouseX) );
  CalculatePosAtMouse(EndX, EndY);
  iVerts.AddVector3f(  Vector3f( 1024, MouseY, MouseX) );
  result := iVerts.CalculateBoundingBox();
  FreeAndNil(iVerts);
end;

procedure TViewPortSideForm.RenderScene(const aForSelection : Boolean);
begin
  if not(aForSelection) then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  glPushMatrix();
    glRotatef(90,0,1,0);
    RenderMeshEntities( aForSelection );
    if not(aForSelection) then MainForm.Selection.RenderSelection(ShowLighting);
    RenderLights(VisibleEntities, aForSelection);
  glPopMatrix();
end;

end.
