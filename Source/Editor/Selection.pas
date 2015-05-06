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
unit Selection;

{$MODE Delphi}

interface

uses
  SysUtils,
  dglOpenGL,
  EditorEntity,
  Scene,
  Entity,
  ModelEntity,
  Commctrl,
  ComCtrls;

Type
  TSelection = class
  private
    FTreeView : TTreeView;
    FScene : TScene;
  public
    Selecting : Boolean;

    constructor Create(const aScene : TScene; const aTreeView : TTreeView);
    destructor  Destroy(); override;

    procedure SetProperties();
    procedure AddEntity(const aEntity : TEntity );
    procedure RemoveEntity(const aEntity : TEntity );
    procedure AddSceneQueryData(const aSceneQuery : TSceneQueryData );

    procedure DeleteSelection();
    procedure CopySelection();
    procedure SelectAll();
    procedure DeselectAll();

    procedure RenderSelection(const aRenderLights : Boolean);
  end;

implementation

uses
  Base,
  Main;

constructor TSelection.Create(const aScene : TScene; const aTreeView : TTreeView);
begin
  FScene := aScene;
  FTreeView := aTreeView;
  Selecting := false;
end;

destructor TSelection.Destroy();
begin
  FScene := nil;
  FTreeView := nil;
end;

procedure TSelection.SetProperties();
var
  iNode : TTreeNode;
begin
  if FTreeView.SelectionCount = 0 then
    MainForm.SetPropertiesFrame(nil)
  else
  begin
    iNode := FTreeView.Selections[FTreeView.SelectionCount-1];
    MainForm.SetPropertiesFrame(TEntity(iNode.Data));
  end;
end;

procedure TSelection.AddEntity(const aEntity : TEntity );
begin
  TEditorEntity(aEntity.UserData).TreeNode.MultiSelected := true;
end;

procedure TSelection.RemoveEntity(const aEntity : TEntity  );
begin
  TEditorEntity(aEntity.UserData).TreeNode.MultiSelected := false;
end;

procedure TSelection.AddSceneQueryData(const aSceneQuery : TSceneQueryData );
var
  iI : Integer;
begin
  Selecting := true;
  for iI := 0 to aSceneQuery.All.Count-1 do AddEntity( aSceneQuery.All.Get(iI) );
  SetProperties();
  Selecting := false;
end;

procedure TSelection.SelectAll();
var
  iI : Integer;
begin
  Selecting := true;
  for iI := 0 to MainForm.SceneTreeView.Items.Count-1  do
  begin
    FTreeView.Items[iI].MultiSelected := true;
  end;
  SetProperties();
  Selecting := false;
end;

procedure TSelection.DeselectAll();
begin
  Selecting := true;
  FTreeView.ClearSelection();
  SetProperties();
  Selecting := false;
end;

procedure TSelection.DeleteSelection();
var
  iI : Integer;
  iEntity : TEntity;
begin
  for iI := 0 to FTreeView.SelectionCount-1 do
  begin
    if FTreeView.Selections[iI].Data <> nil then
    begin
      iEntity := TEntity(FTreeView.Selections[iI].Data);
      FScene.RemoveEntity( iEntity );
    end;
  end;

  FTreeView.ClearSelection();
  MainForm.UpdateSceneBrowser();
  SetProperties();
end;

procedure TSelection.CopySelection();
var
  iI : Integer;
  iEntity : TEntity;
  iEntityArray : TEntityArray;
begin
  iEntityArray := TEntityArray.Create(false);

  for iI := 0 to FTreeView.SelectionCount-1 do
  begin
    if FTreeView.Selections[iI].Data <> nil then
    begin
      iEntity := TEntity(FTreeView.Selections[iI].Data).Copy(FScene);
      iEntity.UserData := TEditorEntity.Create();
      iEntityArray.Add(iEntity);
    end;
  end;

  FTreeView.ClearSelection();
  MainForm.UpdateSceneBrowser();
  Selecting := true;
  for iI := 0 to iEntityArray.Count-1 do
    AddEntity(iEntityArray.Get(iI));
  Selecting := false;
  SetProperties();

  FreeAndNil(iEntityArray);
end;

procedure TSelection.RenderSelection(const aRenderLights : Boolean);
var
  iI : Integer;
  iEntity : TEntity;
begin
  Engine.Renderer.SetColor(ConfigurationForm.MeshSelectColor);
  glDisable(GL_DEPTH_TEST);
  glPolygonMode(GL_FRONT, GL_LINE);
  for iI := 0 to FTreeView.SelectionCount-1 do
  begin
    if FTreeView.Selections[iI].Data <> nil then
    begin
      iEntity := TEntity(FTreeView.Selections[iI].Data);
      case iEntity.EntityType of
        ET_STATICMODEL, ET_ANIMATEDMODEL : (iEntity as TModelEntity).Render(false, false);
        ET_POINTLIGHT, ET_SPOTLIGHT : if aRenderLights then iEntity.RenderBoundingVolume();
      end;
    end;
  end;
  glPolygonMode(GL_FRONT, GL_FILL);
  glEnable(GL_DEPTH_TEST);
end;

end.
