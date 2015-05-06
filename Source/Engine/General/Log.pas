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
unit Log;

interface

uses
  Windows,
  Classes,
  SysUtils;

Type
  TLog = class
  private
  public
    Text : TStringList;
    constructor Create();
    destructor  Destroy(); override;

    procedure Print(const aSource, aMessage : String; const aError : Boolean = false; const aNewLine : boolean = true);
    procedure Clear();
  end;

implementation

uses
  Base;

const
  LOG_NAME = 'Log.txt';

constructor TLog.Create();
var
  iDateTime : TDateTime;
begin
  inherited Create;
  Text := TStringList.Create();
  Clear();
  iDateTime := Now();
  Text.Add( 'Log started at ' + DateToStr(iDateTime) + ', ' + TimeToStr(iDateTime) );
  Text.Add( '' );
end;

destructor  TLog.Destroy();
var
  iDateTime : TDateTime;
begin
  iDateTime := Now();
  Text.Add( '' );
  Text.Add( 'Log ended at '+ DateToStr(iDateTime) + ', ' + TimeToStr(iDateTime));
  Text.SaveToFile( Engine.BasePath + LOG_NAME );
  FreeAndNil(Text);
  inherited Destroy;
end;

procedure TLog.Print(const aSource, aMessage : String; const aError : Boolean = false; const aNewLine : boolean = true);
begin
  if aNewLine then
  begin
    if aSource = '' then
      Text.Add( aMessage )
    else
      Text.Add( aSource + ': ' + aMessage );
  end
  else
    Text.Strings[ Text.Count-1] := Text.Strings[ Text.Count-1] + aMessage;

  if aError then
  begin
    MessageBox(0, 'An error occurred. See the log for more detail.', 'Error', 0 or 16);
    Text.SaveToFile( Engine.BasePath + LOG_NAME );
    Halt;
  end;

  Text.SaveToFile( Engine.BasePath + LOG_NAME );
end;

procedure TLog.Clear();
begin
  Text.Clear();
end;

end.
