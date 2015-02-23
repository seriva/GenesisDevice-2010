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
unit Console;

interface

uses
  Classes,
  Windows,
  SysUtils,
  MMSystem,
  Mathematics,
  Camera,
  ResourceUtils,
  dglOpenGL;

type
  TCommandType = (CT_BOOLEAN, CT_INTEGER, CT_FLOAT, CT_FUNCTION);

  PBoolean  = ^Boolean;
  PInteger  = ^Integer;
  PFloat    = ^Single;
  PFunction = procedure();

  TCommand = record
    Command     : String;
    Help        : String;
    CommandType : TCommandType;
    Bool        : PBoolean;
    Int         : PInteger;
    Float       : PFloat;
    Func        : PFunction;
  end;

  {$define TYPED_MAP_TEMPLATE}
  TYPED_MAP_ITEM = TCommand;
  {$INCLUDE '..\Templates\Map.tpl'}

  TCommandMap = class(TYPED_MAP)
  private
  public
  end;

  TConsole = class
  private
    FAniHeight     : Integer;
    FRow           : integer;
    FCursorPos     : integer;
    FCommandRow    : integer;
    FCommandString : String;
    FCommandList   : TStringList;
    FLastTime      : Integer;
    FCursorTime    : Integer;
    FShowTime      : Boolean;
    FCommandMap    : TCommandMap;
  public
    Show : Boolean;

    constructor Create();
    destructor  Destroy(); override;

    procedure ExecuteCommand(const aCommand : String);
    procedure Render();
    procedure AddChar(const aChar : Char );
    procedure Control(const aKey : Integer );
    procedure AddCommand(const aCommand, aHelp : String; const aType : TCommandType; const aPointer : Pointer );
  end;

implementation

uses
  Base;

{$INCLUDE '..\Templates\Map.tpl'}

procedure ListCommands();
var
  iStr : String;
  iI, iJ, iK : Integer;
  iCommand : TCommand;
  iList : TStringList;
begin
  iList := TStringList.Create();
  with Engine.Console do
  begin
    Engine.Log.Print('', '');
    Engine.Log.Print('', 'Commandlist:');
    FCommandMap.Restart();
    while FCommandMap.Next() do
      iList.Add( FCommandMap.CurrentKey );
    iList.Sort();
    for iK := 0 to iList.Count-1 do
    begin
      iCommand := FCommandMap.Get( iList.Strings[iK] );
      iStr := iCommand.Command;
      iJ := 15 - Length(iStr);
      for iI := 1 to iJ do iStr := iStr + ' ';
      iStr := iStr + ': ' + iCommand.Help;
      Engine.Log.Print('', iStr);
    end;
    Engine.Log.Print('', '');
  end;
  FreeAndNil(iList);
end;

constructor TConsole.Create();
begin
  Show          := False;
  FAniHeight    := 593;
  FLastTime     := Engine.Timer.Time();
  FCommandList  := TStringList.Create();
  FCommandMap   := TCommandMap.Create();
  self.AddCommand('list', 'Print list of commands', CT_FUNCTION, @ListCommands);
end;

destructor  TConsole.Destroy();
begin
  FreeAndNil(FCommandList);
  FreeAndNil(FCommandMap);
end;

procedure TConsole.Render();
var
  iI,iJ  : Integer;
  iDT, iTime : Integer;
  iRowCount : Integer;
  iW, iHDiv2, iH : Integer;
begin
  if Engine.CurrentContext = nil then exit;

  //do some timing
  iTime        := Engine.Timer.Time();
  iDT          := iTime - FLastTime;
  FLastTime    := iTime;

  //get some stuff
  iW := Engine.CurrentContext.Width;
  iH := Engine.CurrentContext.Height;
  iHDiv2 := (iH div 2)-7;

  //do some animation
  If Show then
    FAniHeight := FAniHeight - iDT * 2
  else
    FAniHeight := FAniHeight + iDT * 2;
  if FAniHeight < 0 then
    FAniHeight := 0;
  if FAniHeight > iHDiv2 then
  begin
    FRow       := Engine.Log.Text.Count-1;
    FCursorPos := length(FCommandString)+1;
    FAniHeight := iHDiv2;
    exit;
  end ;

  glDisable(GL_DEPTH_TEST);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  Engine.Renderer.SetColor(0.4,0.4,0.4,0.75);
  glBegin(GL_QUADS);
    glVertex2f(0, iHDiv2+FAniHeight);
    glVertex2f(iW, iHDiv2+FAniHeight);
    glVertex2f(iW, iH+FAniHeight);
    glVertex2f(0, iH+FAniHeight);
  glEnd();
  glDisable(GL_BLEND);
  glLineWidth(2);
  Engine.Renderer.SetColor(1,1,1,1);
  glBegin(GL_LINES);
    glVertex2f(0, iHDiv2+FAniHeight);
    glVertex2f(iW, iHDiv2+FAniHeight);
    glVertex2f(0, iHDiv2+20+FAniHeight);
    glVertex2f(iW, iHDiv2+20+FAniHeight);
  glEnd();
  glLineWidth(1);

  Engine.Renderer.SetColor(1,1,1,1);
  iJ := 0;
  iRowCount := iHDiv2 div 13;
  for iI := FRow downto FRow-iRowCount do
  begin
    If  (iI >= 0) then
    begin
      Engine.DefaultFont.RenderText( 2, (iHDiv2+FAniHeight+5)+18+(iJ*13), Engine.Log.Text.Strings[iI]);
      iJ := iJ + 1;
    end
  end;
  Engine.DefaultFont.RenderText( 2, (iHDiv2+FAniHeight+5), FCommandString);

  FCursorTime  := FCursorTime + iDT;
  if (FCursorTime >= 500) then
  begin
    FShowTime   := not(FShowTime);
    FCursorTime := 0;
  end;
  if FShowTime then
    Engine.DefaultFont.RenderText( ((FCursorPos-1) * 9)+2, (iHDiv2+FAniHeight+4), '_');

  glEnable(GL_DEPTH_TEST);
end;

procedure TConsole.AddChar( const aChar : Char );
begin
  If Not(Show) then exit;
  If Not(((Ord(aChar) >= 32) and (Ord(aChar) <= 126))) then Exit;
  If aChar = '`' then Exit;
  Insert(aChar, FCommandString, FCursorPos);
  FCursorPos := FCursorPos + 1;
end;

procedure TConsole.ExecuteCommand(const aCommand : String);
var
  iI : Integer;
  iCommand : TCommand;
  iCommandStr  : String;
  iCommandPara : String;
  iStrPos : Integer;

function GetNextCommand(const aStr : String): String;
var
  iC   : AnsiChar;
begin
  result := '';
  while (iStrPos <= Length(aStr)) do
  begin
    iC := AnsiChar(aStr[iStrPos]);
    if CharacterIsWhiteSpace(iC) then
    begin
      Inc(iStrPos);
      Break;
    end
    else
    begin
      result := result + String(iC);
      Inc(iStrPos);
    end;
  end;
end;

begin
  //no command string so exit
  if aCommand = '' then exit;

  //add command string
  Engine.Log.Print(self.ToString, aCommand);
  If Not(FCommandList.Find( aCommand, iI )) then
    FCommandList.Add(aCommand);

  //get the command parameters
  iStrPos := 1;
  iCommandStr  := lowercase(GetNextCommand(aCommand));
  iCommandPara := lowercase(GetNextCommand(aCommand));
  //execute the commands
  if FCommandMap.Exists( iCommandStr )  then
  begin
    iCommand := FCommandMap.Get( iCommandStr );
    if (iCommand.Bool = nil) and (iCommand.Int = nil) and
       (iCommand.Float = nil) and not(assigned(iCommand.Func)) then
      Engine.Log.Print(self.ToString, 'Command pointer nul!')
    else
    begin
      case iCommand.CommandType of
        CT_BOOLEAN   : begin
                         if iCommandPara = '0' then
                           iCommand.Bool^ := false
                         else if iCommandPara = '1' then
                           iCommand.Bool^ := true
                         else
                          Engine.Log.Print(self.ToString, 'Unknown Parameter! (use 0 or 1 for booleans)');
                       end;
        CT_INTEGER   : begin
                         try
                           iCommand.Int^ := StrToInt(iCommandPara);
                         except
                           Engine.Log.Print(self.ToString, 'Unknown Parameter!');
                         end;
                       end;
        CT_FLOAT     : begin
                         try
                           iCommand.Float^ := StrToFloat(iCommandPara);
                         except
                           Engine.Log.Print(self.ToString, 'Unknown Parameter!');
                         end;
                       end;
        CT_FUNCTION  : begin
                         try
                           iCommand.Func();
                         except
                           Engine.Log.Print(self.ToString, 'Unknown Function!');
                         end;
                       end;
      end;
    end;
  end
  else
    Engine.Log.Print(self.ToString, 'Unknown Command!');

  //reset some stuff
  FCommandString := '';
  FRow := Engine.Log.Text.Count-1;
  FCursorPos := length(FCommandString)+1;
end;

procedure TConsole.Control(const aKey : Integer );
begin
  If Not(Show) then exit;
  case aKey of
    VK_PRIOR  : begin
                  If Engine.Log.Text.Count = 0 then exit;
                  FRow := FRow - 1;
                  If FRow < 0 then FRow := 0;
                end;
    VK_NEXT   : begin
                  If Engine.Log.Text.Count = 0 then exit;
                  FRow := FRow + 1;
                  If FRow > Engine.Log.Text.Count-1 then FRow := Engine.Log.Text.Count-1;
                end;
    VK_UP     : begin
                  If FCommandList.Count = 0 then exit;
                  FCommandRow := FCommandRow - 1;
                  If FCommandRow < 0 then
                    FCommandRow := FCommandList.Count-1;
                  FCommandString :=  FCommandList.Strings[FCommandRow];
                  FCursorPos := length(FCommandString)+1;
                end;
    VK_DOWN   : begin
                  If FCommandList.Count = 0 then exit;
                  FCommandRow := FCommandRow + 1;
                  If FCommandRow > FCommandList.Count-1 then
                    FCommandRow := 0;
                  FCommandString :=  FCommandList.Strings[FCommandRow];
                  FCursorPos := length(FCommandString)+1;
                end;
    VK_LEFT   : begin
                  if (FCursorPos = 1) then exit;
                  FCursorPos := FCursorPos - 1
                end;
    VK_RIGHT  : begin
                  if (FCursorPos = (length(FCommandString) + 1)) then exit;
                  FCursorPos := FCursorPos + 1
                end;
    VK_BACK   : begin
                  if FCursorPos = 1 then exit;
                  Delete(FCommandString, FCursorPos-1, 1);
                  FCursorPos := FCursorPos - 1;
                end;
    VK_RETURN : ExecuteCommand(FCommandString);
  end;
end;

procedure TConsole.AddCommand(const aCommand, aHelp : String; const aType : TCommandType; const aPointer : Pointer );
var
  iCommand : TCommand;
begin
  iCommand.Command      := lowercase(aCommand);
  iCommand.Help         := aHelp;
  iCommand.CommandType  := aType;
  case iCommand.CommandType of
    CT_BOOLEAN        : iCommand.Bool  := aPointer;
    CT_INTEGER        : iCommand.Int   := aPointer;
    CT_FLOAT          : iCommand.Float := aPointer;
    CT_FUNCTION       : iCommand.Func  := aPointer;
  end;
  FCommandMap.Add(aCommand,iCommand);
end;

end.
