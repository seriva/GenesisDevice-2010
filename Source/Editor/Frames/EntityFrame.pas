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
unit EntityFrame;

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
  Dialogs,
  Entity,
  EditorEntity,
  StdCtrls;

type
  TEntityPropFrame = class(TFrame)
    NameLabel: TLabel;
    NameEdit: TEdit;
    PositionLabel: TLabel;
    RotationLabel: TLabel;
    ScaleLabel: TLabel;

    PosXEdit: TEdit;
    PosYEdit: TEdit;
    PosZEdit: TEdit;
    RotXEdit: TEdit;
    RotYEdit: TEdit;
    RotZEdit: TEdit;
    ScaleEdit: TEdit;

    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure NameEditChange(Sender: TObject);
    procedure ScaleEditKeyPress(Sender: TObject; var Key: Char);
    procedure RotEditKeyPress(Sender: TObject; var Key: Char);
    procedure PosEditKeyPress(Sender: TObject; var Key: Char);
    procedure ScaleEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RotEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PosEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
    Creating : Boolean;
    Entity   : TEntity;

    constructor Create(AOwner: TComponent; const aEntity : TEntity);
  end;

implementation

{$R *.lfm}

uses
  Mathematics,
  Main;

constructor TEntityPropFrame.Create(AOwner: TComponent; const aEntity : TEntity);
var
  iPos : TVector3f;
begin
  inherited Create(AOwner) ;
  Creating := true;
  Entity := aEntity;
  NameEdit.Text := Entity.Name;
  iPos := aEntity.GetPosition();
  PosXEdit.Text  := FormatFloat('0.00', iPos.x);
  PosYEdit.Text  := FormatFloat('0.00', iPos.y);
  PosZEdit.Text  := FormatFloat('0.00', iPos.z);
  RotXEdit.Text  := '0.00';
  RotYEdit.Text  := '0.00';
  RotZEdit.Text  := '0.00';
  ScaleEdit.Text := FormatFloat('0.00', aEntity.Scale);
  Creating := false;
end;

procedure TEntityPropFrame.NameEditChange(Sender: TObject);
begin
  if Creating then exit;
  Entity.Name := NameEdit.Text;
  TEditorEntity(Entity.UserData).TreeNode.Text := NameEdit.Text;
end;

procedure TEntityPropFrame.PosEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  iPos : TVector3f;
begin
  if Key <> VK_RETURN then exit;
  if Creating then exit;
  try
    if PosXEdit.Text <> '' then iPos.x := StrToFloat(PosXEdit.Text);
    if PosYEdit.Text <> '' then iPos.y := StrToFloat(PosYEdit.Text);
    if PosZEdit.Text <> '' then iPos.z := StrToFloat(PosZEdit.Text);
    Entity.SetPosition(iPos);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
  MainForm.UpdateViewPorts();
end;

procedure TEntityPropFrame.PosEditKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then Key := #0;
end;

procedure TEntityPropFrame.RotEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  iRot : Single;
begin
  if Key <> VK_RETURN then exit;
  if Creating then exit;
  try
    if RotXEdit.Text <> '' then
    begin
      iRot := StrToFloat(RotXEdit.Text);
      if iRot <> 0 then Entity.RotateAA(ER_WORLD, AxisAngle(1, 0, 0, iRot));
      RotXEdit.Text := '0.00';
    end;
    if RotYEdit.Text <> '' then
    begin
      iRot := StrToFloat(RotYEdit.Text);
      if iRot <> 0 then Entity.RotateAA(ER_WORLD, AxisAngle(0, 1, 0, iRot));
      RotYEdit.Text := '0.00';
    end;
    if RotZEdit.Text <> '' then
    begin
      iRot := StrToFloat(RotZEdit.Text);
      if iRot <> 0 then Entity.RotateAA(ER_WORLD, AxisAngle(0, 0, 1, iRot));
      RotZEdit.Text := '0.00';
    end;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
  MainForm.UpdateViewPorts();
end;

procedure TEntityPropFrame.RotEditKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then Key := #0;
end;

procedure TEntityPropFrame.ScaleEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> VK_RETURN then exit;
  if Creating then exit;
  try
    if ScaleEdit.Text <> '' then Entity.SetScale(StrToFloat(ScaleEdit.Text));
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
  MainForm.UpdateViewPorts();
end;

procedure TEntityPropFrame.ScaleEditKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then Key := #0;
end;

end.
