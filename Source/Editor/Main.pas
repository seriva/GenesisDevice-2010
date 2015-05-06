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
  LCLIntf,
  LCLType,
  LMessages,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  comctrls,
  Controls,
  Forms,
  Dialogs,
  Menus,
  GraphType,
  IniFiles,
  ViewPort,
  ViewPortFront,
  ViewPortSide,
  ViewPortTop,
  ViewPort3D,
  dglOpenGL,
  Configuration,
  ExtCtrls,
  StdCtrls,
  Buttons,
  Scene,
  Selection,
  Texture,
  Entity,
  GLSLLoader,
  EditorEntity,
  ShaderProgram,
  DDSLoader,
  SceneIO,
  Shader,
  Progress,
  BrowserNodeData, SceneFrame,
  ImgList, FileUtil,
  Mathematics;
  
type

  { TMainForm }

  TMainForm = class(TForm)
    MenuItem1: TMenuItem;
    SelectAllMenuItem: TMenuItem;
    DeselectAllMenuItem: TMenuItem;
    PropertiesGroupBox: TGroupBox;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Edit: TMenuItem;
    ScenePanelSplitter: TSplitter;
    PropertiesScrollBox: TScrollBox;
    MainSplitter: TSplitter;
    WindowPanel: TPanel;
    New: TMenuItem;
    Open: TMenuItem;
    Save: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    DeselectAll1: TMenuItem;
    Clone1: TMenuItem;
    Delete1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolPanel: TPanel;
    Splitter: TSplitter;
    MainPageControl: TPageControl;
    AssetsTabSheet: TTabSheet;
    SceneTabSheet: TTabSheet;
    AssetTreeView: TTreeView;
    ImageList: TImageList;
    ABPopupMenu: TPopupMenu;
    Refresh1: TMenuItem;
    SaveAs1: TMenuItem;
    SceneTreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SceneTreeViewCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SceneTreeViewSelectionChanged(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure DeselectAll1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewClick(Sender: TObject);

    function MessageDlg(const Msg: string; DlgType: TMsgDlgType;
      Buttons: TMsgDlgButtons; HelpCtx: Integer): Integer;
    procedure OpenClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Delete1Click(Sender: TObject);
    procedure Clone1Click(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure AssetTreeViewStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure AssetTreeViewEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure SaveAs1Click(Sender: TObject);
    procedure AssetTreeViewDeletion(Sender: TObject; Node: TTreeNode);
    procedure SceneTreeViewEdited(Sender: TObject; Node: TTreeNode;
      var S: string);
    procedure SceneTreeViewEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure WindowPanelResize(Sender: TObject);
  private
    ViewPortsCreated : boolean;
    FullViewPort  : TViewPort3DForm;
    FrontViewPort : TViewPortFrontForm;
    TopViewPort   : TViewPortTopForm;
    SideViewPort  : TViewPortSideForm;
    PropsFrame    : TFrame;

    procedure AddEditorEntities();
    procedure ToggleDragMode(const aDragMode : TDragMode);
    procedure GetDirectories(aTree: TTreeView; aDirectory, aFileMask : string; aItem: TTreeNode);

    procedure ResetViewPorts();
    procedure ResizeViewPorts();

    procedure OpenScene();
    procedure SaveScene();
  public
    SceneName         : String;
    MainScene         : TScene;
    Selection         : TSelection;
    GridShader        : TShaderProgram;
    LightShader       : TShaderProgram;
    NoLightShader     : TShaderProgram;
    LightTexture      : TTexture;

    procedure LoadConfiguration();
    procedure SaveConfiguration();

    procedure UpdateViewPorts();
    procedure CreateViewPorts();

    procedure InitAssetBrowser();
    procedure UpdateAssetBrowser();

    procedure UpdateSceneBrowser();
    procedure AddEntityToSceneBrowser(const aEntity : TEntity);

    Procedure SetPropertiesFrame(aEntity : TEntity);
  end;

var
  MainForm          : TMainForm;
  ConfigurationForm : TConfigurationForm;
  ProgressForm      : TProgressForm;

const
  INIFILE = 'Editor.ini';

  cLight  = 1;
  cModel  = 2;
  cFolder = 3;

function RGBToColor(aC : TVector3f): TColor;
function ColorToRGB(aColor: TColor): TVector3f;

implementation

uses
  Base,
  ModelEntityFrame,
  SpotLightEntityFrame,
  LightEntityFrame;

{$R *.lfm}

function RGBToColor(aC : TVector3f): TColor;
begin
  Result:= Round(aC.y*256) Shl 16 Or Round(aC.y*256) Shl 8 Or Round(aC.x*256);
end;

function ColorToRGB(aColor: TColor): TVector3f;
begin
  result.x := (aColor and $ff)/256;
  result.y := ((aColor and $ff00) shr 8)/256;
  result.z := ((aColor and $ff0000) shr 16)/256;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //init some vars
  ViewPortsCreated := false;

  //init engine
  InitEngine(ExtractFilePath(Application.ExeName));

  //load editor resources
  GridShader    := LoadGLSLResource('Base\Shaders\Editor\Grid.glsl') as TShaderProgram;
  LightShader   := LoadGLSLResource('Base\Shaders\Editor\Light.glsl') as TShaderProgram;
  NoLightShader := LoadGLSLResource('Base\Shaders\Editor\NoLight.glsl') as TShaderProgram;
  LightTexture  := LoadDDSResource('Base\Textures\light.dds') as TTexture;

  //create editor classes and init vars
  MainScene := TScene.Create();
  AddEditorEntities();
  Selection := TSelection.Create(MainScene, SceneTreeView);
  InitAssetBrowser();
  SetPropertiesFrame(nil);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MainScene.Clear();
  Engine.Resources.Clear();

  //clear editor classes
  FreeAndNil(MainScene);
  FreeAndNil(Selection);

  //clear editor resources
  FreeAndNil(GridShader);
  FreeAndNil(LightShader);
  FreeAndNil(NoLightShader);
  FreeAndNil(LightTexture);

  //clear engine
  ClearEngine();
end;


procedure TMainForm.SceneTreeViewCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  iTV: TTreeview;
begin
  iTV:=TTreeView(Sender);
  if iTV <> self.SceneTreeView then exit;
  if cdsSelected in State then
    iTV.Canvas.Font.Bold := true
  else
    iTV.Canvas.Font.Bold := false;
  DefaultDraw := true;
end;

procedure TMainForm.WindowPanelResize(Sender: TObject);
begin
  self.ResizeViewPorts();
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfiguration();
end;

procedure TMainForm.LoadConfiguration();
var
  iIniFile : TIniFile;
begin
  if not(FileExistsUTF8(ExtractFilePath(Application.ExeName) + INIFILE )) then
  begin
    Top  := 0;
    Left := 0;
    Width := 1024;
    Height := 768;
    ToolPanel.Width := 290;
    PropertiesGroupBox.Height := 280;
  end
  else
  begin
    iIniFile := TIniFile.Create( ExtractFilePath(Application.ExeName) + INIFILE );

    Top := iIniFile.ReadInteger( 'Editor', 'Top', 0 );
    Left := iIniFile.ReadInteger( 'Editor', 'Left', 0 );
    Width := iIniFile.ReadInteger( 'Editor', 'Width', 1024 );
    Height :=  iIniFile.ReadInteger( 'Editor', 'Height', 768 );
    ToolPanel.Width := iIniFile.ReadInteger( 'Editor', 'ToolPanelWidth', 290 );
    PropertiesGroupBox.Height := iIniFile.ReadInteger( 'Editor', 'PropertiesGroupBoxHeight', 280 );

    if iIniFile.ReadBool( 'Editor', 'Maximized', false ) then
      WindowState := wsMaximized
    else
      WindowState := wsNormal;

    FreeAndNil(iIniFile);
  end;

  SceneName :=  ExtractFilePath(Application.ExeName) + ConfigurationForm.MapDir + 'noname.map';
  self.caption := 'Editor - ' + SceneName;
end;

function TMainForm.MessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Integer): Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons) do
  begin
    try
      Position := poOwnerFormCenter;
      Result := ShowModal
    finally
      Free
    end
  end;
end;

procedure TMainForm.SaveConfiguration();
var
  iIniFile : TIniFile;
begin
  //we want to rewrite it completely so delete it
  DeleteFileUTF8(ExtractFilePath(Application.ExeName) + INIFILE);

  //create a new inifile
  iIniFile := TIniFile.Create( ExtractFilePath(Application.ExeName) + INIFILE );

  //save the main settings
  iIniFile.WriteInteger( 'Editor', 'Top', Top );
  iIniFile.WriteInteger( 'Editor', 'Left', Left );
  iIniFile.WriteInteger( 'Editor', 'Width', Width );
  iIniFile.WriteInteger( 'Editor', 'Height', Height );
  iIniFile.WriteInteger( 'Editor', 'ToolPanelWidth', ToolPanel.Width );
  iIniFile.WriteInteger( 'Editor', 'PropertiesGroupBoxHeight', PropertiesGroupBox.Height );
  if WindowState = wsNormal then
    iIniFile.WriteBool( 'Editor', 'Maximized', false )
  else
    iIniFile.WriteBool( 'Editor', 'Maximized', true );

  FreeAndNil(iIniFile);
end;

procedure TMainForm.AddEditorEntities();
var
  iI : Integer;
  iEE : TEditorEntity;
begin
  for iI := 0 to MainScene.Entities.Count-1 do
  begin
    iEE := TEditorEntity.Create();
    iEE.SelectID := iI;
    MainScene.Entities.Get(iI).UserData := iEE;
  end;
end;

procedure TMainForm.GetDirectories(aTree: TTreeView; aDirectory, aFileMask : string; aItem: TTreeNode);
var
  iSearchRec : TSearchRec;
  iItemTemp : TTreeNode;
begin
  aTree.Items.BeginUpdate;
  if aDirectory[length(aDirectory)] <> '\' then aDirectory := aDirectory + '\';
  if FindFirstUTF8(aDirectory + '*.*',faDirectory,iSearchRec) = 0 then
  begin
    repeat
    begin
      if (iSearchRec.Attr and faDirectory = faDirectory) and (iSearchRec.Name[1] <> '.') then
      begin
        if (iSearchRec.Attr and faDirectory > 0) then
        begin
          aItem := aTree.Items.AddChild(aItem, iSearchRec.Name);
          aItem.StateIndex := 3;
        end;
        iItemTemp := aItem.Parent;
        GetDirectories(aTree, aDirectory + iSearchRec.Name, aFileMask, aItem);
        if iItemTemp.Count > 0 then
          if not(iItemTemp.Items[iItemTemp.Count-1].HasChildren) then
            iItemTemp.Items[iItemTemp.Count-1].Delete();
        aItem := iItemTemp
      end
      else
      begin
        if iSearchRec.Name[1] <> '.' then
        begin
          if AnsiPos(LowerCase(ExtractFileExt(iSearchRec.Name)), LowerCase(aFileMask)) > 0 then
          begin
            iItemTemp := aTree.Items.AddChild(aItem, iSearchRec.Name);
            iItemTemp.StateIndex := 1;
            iItemTemp.Data := TBrowserNodeData.Create( NT_MODEL, aDirectory + iSearchRec.Name );
          end;
        end;
      end;
    end;
    until FindNextUTF8(iSearchRec) <> 0;
      FindCloseUTF8(iSearchRec);
    end;
  aTree.Items.EndUpdate;
end;

procedure TMainForm.UpdateSceneBrowser();
var
  iI : Integer;
begin
  SceneTreeView.Items.Clear();
  SceneTreeView.Items.BeginUpdate;
  for iI := 0 to MainScene.Entities.Count-1 do
    AddEntityToSceneBrowser(MainScene.Entities.Get(iI));
  SceneTreeView.Items.EndUpdate;
end;

procedure TMainForm.AddEntityToSceneBrowser(const aEntity : TEntity);
var
  iImage : Integer;
  iNode  : TTreeNode;
begin
  case aEntity.EntityType of
    ET_STATICMODEL, ET_ANIMATEDMODEL : iImage := 1;
    ET_POINTLIGHT, ET_SPOTLIGHT      : iImage := 2;
  end;
  iNode := SceneTreeView.Items.Add(nil, aEntity.Name);
  iNode.StateIndex := iImage;
  TEditorEntity(aEntity.UserData).TreeNode := iNode;
  iNode.Data := aEntity;
end;

procedure TMainForm.InitAssetBrowser();
begin
  AssetTreeView.Items[0].Items[0].Data := TBrowserNodeData.Create( NT_POINTLIGHT, '' );
  AssetTreeView.Items[0].Items[1].Data := TBrowserNodeData.Create( NT_SPOTLIGHT, '' );
end;

procedure TMainForm.UpdateAssetBrowser();
begin
  AssetTreeView.Items[3].DeleteChildren();
  GetDirectories( AssetTreeView, ExtractFilePath(Application.ExeName) + ConfigurationForm.ModelDir, '.obj;.md5',  AssetTreeView.Items[3]);
  AssetTreeView.Items[3].Expand(false);
end;

procedure TMainForm.AssetTreeViewDeletion(Sender: TObject; Node: TTreeNode);
var
  iData : TBrowserNodeData;
begin
  if Node.data <> nil then
  begin
    iData := TBrowserNodeData(Node.data);
    FreeAndNil(iData);
  end;
end;

procedure TMainForm.AssetTreeViewStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if TTreeView(Sender).Selected <> nil then
  begin
    if TTreeView(Sender).Selected.Data = nil then
      CancelDrag()
    else
      ToggleDragMode(dmAutomatic);
  end;
end;

procedure TMainForm.AssetTreeViewEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  ToggleDragMode(dmManual);
end;

procedure TMainForm.ToggleDragMode(const aDragMode : TDragMode);
begin
  FullViewPort.DragMode := aDragMode;
  FrontViewPort.DragMode := aDragMode;
  TopViewPort.DragMode := aDragMode;
  SideViewPort.DragMode := aDragMode;
end;

procedure TMainForm.Refresh1Click(Sender: TObject);
begin
  UpdateAssetBrowser();
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  UpdateViewPorts();
end;

procedure TMainForm.UpdateViewPorts();
begin
  if ViewPortsCreated then
  begin
    MainForm.MainScene.Update();
    FullViewPort.UpdateViewPort();
    FrontViewPort.UpdateViewPort();
    TopViewPort.UpdateViewPort();
    SideViewPort.UpdateViewPort();
  end;
end;

procedure TMainForm.ResetViewPorts();
begin
  if ViewPortsCreated then
  begin
    FullViewPort.ResetCamera();
    FrontViewPort.ResetCamera();
    TopViewPort.ResetCamera();
    SideViewPort.ResetCamera();
  end;
end;

procedure TMainForm.ResizeViewPorts();
var
  iW, iH : integer;
begin
  if ViewPortsCreated then
  begin
    iW := WindowPanel.Width div 2;
    iH := WindowPanel.Height div 2;;

    FullViewPort.Top := iH;
    FullViewPort.Left := iW;
    FullViewPort.Width := iW;
    FullViewPort.Height := iH;

    TopViewPort.Top := 0;
    TopViewPort.Left := iW;
    TopViewPort.Width := iW;
    TopViewPort.Height := iH;

    FrontViewPort.Top := 0;
    FrontViewPort.Left := 0;
    FrontViewPort.Width := iW;
    FrontViewPort.Height := iH;

    SideViewPort.Top := iH;
    SideViewPort.Left := 0;
    SideViewPort.Width := iW;
    SideViewPort.Height := iH;
  end;
end;

procedure TMainForm.CreateViewPorts();
begin
  FullViewPort := TViewPort3DForm.Create(WindowPanel);
  FullViewPort.ParentWindow:=WindowPanel.Handle;
  FullViewPort.show;

  TopViewPort := TViewPortTopForm.Create(WindowPanel);
  TopViewPort.ParentWindow:=WindowPanel.Handle;
  TopViewPort.show;

  FrontViewPort := TViewPortFrontForm.Create(WindowPanel);
  FrontViewPort.ParentWindow:=WindowPanel.Handle;
  FrontViewPort.show;

  SideViewPort := TViewPortSideForm.Create(WindowPanel);
  SideViewPort.ParentWindow:=WindowPanel.Handle;
  SideViewPort.show;

  ViewPortsCreated := true;
  ResizeViewPorts();
end;

procedure TMainForm.SelectAll1Click(Sender: TObject);
begin
  Selection.SelectAll();
  UpdateViewPorts();
end;

procedure TMainForm.Clone1Click(Sender: TObject);
begin
  Selection.CopySelection();
  UpdateViewPorts();
end;

procedure TMainForm.Delete1Click(Sender: TObject);
var
  iButtonSelected : Integer;
begin
  if SceneTreeView.SelectionCount = 0 then exit;
  iButtonSelected := MessageDlg('Do you want to delete the current selection?', mtConfirmation, mbYesNo, 0);
  case iButtonSelected of
    mrYes : Selection.DeleteSelection();
    mrNo  : ;
  end;
  UpdateViewPorts();
end;

procedure TMainForm.DeselectAll1Click(Sender: TObject);
begin
  if SceneTreeView.SelectionCount = 0 then exit;
  Selection.DeselectAll();
  UpdateViewPorts();
end;

procedure Progress(const aProgress, aMax : Integer);
begin
  ProgressForm.ProgressBar.Position := Round(aProgress * (100/aMax));
  ProgressForm.Repaint();
end;

procedure TMainForm.OpenScene();
begin
  OpenDialog.InitialDir := ExtractFilePath(Application.ExeName) + ConfigurationForm.MapDir;
  if OpenDialog.Execute then
  begin
    SceneName := OpenDialog.FileName;
    caption := 'Editor - ' + SceneName;
    ProgressForm.StartProgress('Loading Map...');
    Selection.DeselectAll();
    SetPropertiesFrame(nil);
    MainScene.Clear();
    Engine.Resources.Clear();
    LoadMap(SceneName, MainScene, @Progress);
    AddEditorEntities();
    UpdateSceneBrowser();
    ProgressForm.EndProgress();
    ResetViewPorts();
  end;
end;

procedure TMainForm.SaveScene();
begin
  ProgressForm.StartProgress('Saving Map...');
  SaveMap(SceneName, MainScene, @Progress);
  ProgressForm.EndProgress();
end;

procedure TMainForm.SceneTreeViewSelectionChanged(Sender: TObject);
begin
  if Selection.Selecting then exit;
  Selection.SetProperties();
  UpdateViewPorts();
end;

procedure TMainForm.SceneTreeViewEdited(Sender: TObject; Node: TTreeNode;
  var S: string);
begin
  TEntity(Node.data).Name := S;
  Selection.SetProperties();
end;

procedure TMainForm.SceneTreeViewEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  if Node.data = nil then AllowEdit := false;
end;

procedure TMainForm.NewClick(Sender: TObject);
var
  iButtonSelected : Integer;

procedure ResetScene();
begin
  SceneName := ExtractFilePath(Application.ExeName) + ConfigurationForm.MapDir + 'noname.map';
  caption := 'Editor - ' + SceneName;
  Selection.DeselectAll();
  MainScene.Clear();
  Engine.Resources.Clear();
  ResetViewPorts();
  UpdateSceneBrowser();
  SetPropertiesFrame(nil);
end;

begin
  if MainScene.Entities.Count = 0 then
    ResetScene()
  else
  begin
    iButtonSelected := MessageDlg('Do you want to save the current scene?', mtConfirmation, mbYesNoCancel, 0);
    case iButtonSelected of
      mrYes : begin
                SaveClick(Sender);
                ResetScene();
              end;
      mrNo  : ResetScene();
      mrCancel : ;
    end;
  end;
end;

procedure TMainForm.OpenClick(Sender: TObject);
var
  iButtonSelected : Integer;
begin
  if MainScene.Entities.Count = 0 then
    OpenScene()
  else
  begin
    iButtonSelected := MessageDlg('Do you want to save the current scene?', mtConfirmation, mbYesNoCancel, 0);
    case iButtonSelected of
      mrYes : begin
                SaveClick(Sender);
                OpenScene();
              end;
      mrNo  : OpenScene();
      mrCancel : exit;
    end;
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  iButtonSelected : Integer;
begin
  if MainScene.Entities.Count = 0 then
    CanClose := true
  else
  begin
    iButtonSelected := MessageDlg('Do you want to save the current scene?', mtConfirmation, mbYesNoCancel, 0);
    case iButtonSelected of
      mrYes : begin
                SaveClick(Sender);
                CanClose := true;
              end;
      mrNo  : CanClose := true;
      mrCancel : CanClose := false;
    end;
  end;
end;

procedure TMainForm.SaveAs1Click(Sender: TObject);
begin
  SaveDialog.InitialDir := ExtractFilePath(Application.ExeName) + ConfigurationForm.MapDir;
  SaveDialog.FileName := SceneName;
  if SaveDialog.Execute then
  begin
    SceneName := SaveDialog.FileName;
    caption := 'Editor - ' + SceneName;
    SaveScene();
  end;
end;

procedure TMainForm.SaveClick(Sender: TObject);
begin
  if MainScene.Entities.Count > 0 then
    SaveScene();
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close();
end;

Procedure TMainForm.SetPropertiesFrame(aEntity : TEntity);
begin
  FreeAndNil(PropsFrame);
  if aEntity = Nil then
  begin
    PropertiesGroupBox.Caption := 'Scene Properties';
    PropsFrame := TScenePropFrame.Create(nil);
  end
  else
  begin
    case aEntity.EntityType of
      ET_STATICMODEL, ET_ANIMATEDMODEL :
      begin
        PropertiesGroupBox.Caption := 'Model Properties';
        PropsFrame   := TModelEntityPropFrame.Create(nil, aEntity);
      end;
      ET_POINTLIGHT :
      begin
        PropertiesGroupBox.Caption := 'Pointlight Properties';
        PropsFrame   := TLightEntityPropFrame.Create(nil, aEntity);
      end;
      ET_SPOTLIGHT :
      begin
        PropertiesGroupBox.Caption := 'Spotlight Properties';
        PropsFrame   := TSpotLightEntityPropFrame.Create(nil, aEntity);
      end;
    end;
  end;
  if PropsFrame <> nil then
  begin
    PropsFrame.Parent := PropertiesScrollBox;
  end;
  PropertiesGroupBox.Repaint;
end;

end.
