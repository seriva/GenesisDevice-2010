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
unit ViewPortFront;

{$MODE Delphi}

interface

uses
  LCLIntf,
  LCLType,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Scene,
  FloatArray,
  ViewPort2D,
  dglOpenGL,
  Mathematics;

type
  TViewPortFrontForm = class(TViewPort2DForm)
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
  Main;

{$R *.lfm}

function  TViewPortFrontForm.CalculateCreateEntityPos(const aX, aY : Integer): TVector3f;
begin
  CalculatePosAtMouse(aX, aY);
  result.x := MouseX;
  result.y := MouseY;
  result.z := 0;
end;

procedure TViewPortFrontForm.FormCreate(Sender: TObject);
begin
  inherited;
  Name  := ' Front';
  Axis1 := 'X';
  Axis2 := 'Y';
  Color1 := Vector3f(1,0,0);
  Color2 := Vector3f(0,1,0);
  View2DType := VPT2D_FRONT;
  Align := alClient;
end;

procedure TViewPortFrontForm.DetectVisibility();
var
  iBoundingBox : TBoundingBox;
begin
  inherited;

  //do we have the visible entities jet?
  if VisibleEntities = nil then exit;

  //create the bounding box
  iBoundingBox.min.x := WidthOffsetNeg;
  iBoundingBox.min.y := HeightOffsetNeg;
  iBoundingBox.min.z := -1024;
  iBoundingBox.max.x := WidthOffsetPos;
  iBoundingBox.max.y := HeightOffsetPos;
  iBoundingBox.max.z := 1024;

  //get the entities in view.
  MainForm.MainScene.EntitiesIntersectBox( iBoundingBox, VisibleEntities, SQD_MODELS or SQD_LIGHTS );
end;

function  TViewPortFrontForm.MakeSelectionBox(): TBoundingBox;
var
  iVerts : TFloatArray;
begin
  iVerts := TFloatArray.Create();
  CalculatePosAtMouse(StartX, StartY);
  iVerts.AddVector3f(  Vector3f(MouseX, MouseY, -1024) );
  CalculatePosAtMouse(EndX, EndY);
  iVerts.AddVector3f(  Vector3f(MouseX, MouseY, 1024) );
  result := iVerts.CalculateBoundingBox();
  FreeAndNil(iVerts);
end;

procedure TViewPortFrontForm.RenderScene(const aForSelection : Boolean);
begin
  if not(aForSelection) then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  RenderMeshEntities(aForSelection);
  if not(aForSelection) then MainForm.Selection.RenderSelection(ShowLighting);
  RenderLights(VisibleEntities, aForSelection);
end;

end.
