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
unit BitmapFont;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType,
  dglOpenGL;

type
  TBitmapFont = class
  private
    FDPL : GLuint;
  public
    constructor Create(const aFont : String; const aSize : Integer);
    Destructor  Destroy(); override;
    procedure   RenderText(const aX, aY : Integer; const aText : String);
  end;

implementation

uses
  Base;

constructor TBitmapFont.Create(const aFont : String; const aSize : Integer);
var
  iFont: HFONT;
begin
  inherited Create();
  FDPL := glGenLists(96);
  iFont := CreateFont(aSize,0,0,0,FW_BOLD,0,0,0, ANSI_CHARSET,OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS,
                      ANTIALIASED_QUALITY, FF_DONTCARE or DEFAULT_PITCH, PChar(aFont));
  SelectObject(Engine.Renderer.ResourceContext.DC,iFont);
  wglUseFontBitmaps(Engine.Renderer.ResourceContext.DC,32,96,FDPL);
end;

destructor TBitmapFont.Destroy();
begin
  glDeleteLists(FDPL, 1);
  inherited Destroy;
end;

procedure TBitmapFont.RenderText(const aX, aY : Integer; const aText : String);
begin
  if (aText = '') or
     (aX < 0) or (aX > Engine.CurrentContext.Width) or
     (aY < 0) or (aY > Engine.CurrentContext.Height) then
    exit;
  glRasterPos2i(aX, aY);
  glListBase(FDPL-32);
  glCallLists(length(aText), GL_UNSIGNED_BYTE,  PAnsiChar(AnsiString(aText)));
  glListBase(0);
end;

end.
