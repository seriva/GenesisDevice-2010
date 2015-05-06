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
unit Texture;

interface

uses
  dglOpenGL,
  Resource;

type
  TTextureFilter = (TF_NONE, TF_BILINEAR, TF_TRILINEAR);

  TDDSData = record
    OutputFormat  : Word;
    Factor        : Integer;
    Width         : Integer;
    Height        : Integer;
    NumMipMaps    : Integer;
    Components    : Integer;
    Data          : array of Byte;
  end;

  TTexture = Class (TResource)
  private
  public
    BufferID : GLuint;
    CurUnit  : Integer;
    TexType  : Cardinal;

    constructor CreateDDSTexture( aDDSData : TDDSData);
    constructor CreateRenderTexture( const aSizeW, aSizeH : integer; const aInFormat, aFormat, aType : Cardinal);
    constructor CreateRenderCubemap( const aSize : integer; const aInFormat, aFormat, aType : Cardinal);
    destructor  Destroy(); override;

    procedure   SetFilter(const aFilter : TTextureFilter);
    procedure   SetAnisotropic(const aAnisotropic : Single);
    procedure   SetWrapMode( aWrapS, aWrapT, aWrapR : Integer );
    procedure   Bind( const aTU : integer );
    procedure   Unbind();
  end;

implementation

constructor TTexture.CreateDDSTexture( aDDSData : TDDSData );
var
  iBlockSize : Integer;
  iHeight    : Integer;
  iWidth     : Integer;
  iOffset    : Integer;
  iSize      : Integer;
  iI : Integer;
begin
  inherited Create();
  TexType := GL_TEXTURE_2D;
  CurUnit := 0;
  glEnable(GL_TEXTURE_2D);
  glGenTextures(1, @BufferID);
  glBindTexture(GL_TEXTURE_2D, BufferID);

  if aDDSData.OutputFormat = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT then
    iBlockSize := 8
  else
    iBlockSize := 16;

  iHeight     := aDDSData.height;
  iWidth      := aDDSData.width;
  iOffset     := 0;

  for iI :=0  to aDDSData.NumMipMaps-1 do
  begin
    if iWidth  = 0 then iWidth  := 1;
    if iHeight = 0 then iHeight := 1;

    iSize := ((iWidth+3) div 4) * ((iHeight+3) div 4) * iBlockSize;
    glCompressedTexImage2DARB( GL_TEXTURE_2D,
                               iI,
                               aDDSData.Outputformat,
                               iWidth,
                               iHeight,
                               0,
                               iSize,
                               pointer( integer(aDDSData.data) + iOffset));
    iOffset := iOffset  + iSize;
    iWidth  := (iWidth  div 2);
    iHeight := (iHeight div 2);
  end;

  Bind(0);
  setFilter(TF_TRILINEAR);
  SetWrapMode( GL_REPEAT, GL_REPEAT, GL_REPEAT );
  SetAnisotropic(16);
end;

constructor TTexture.CreateRenderTexture( const aSizeW, aSizeH : integer; const aInFormat, aFormat, aType : Cardinal);
begin
  inherited Create();
  TexType := GL_TEXTURE_2D;
  CurUnit := 0;
  glEnable(GL_TEXTURE_2D);
  glGenTextures(1, @BufferID);
  glBindTexture(GL_TEXTURE_2D, BufferID);
  glTexImage2D(GL_TEXTURE_2D, 0, aInFormat, aSizeW, aSizeH, 0, aFormat, aType, nil);
  setFilter(TF_NONE);
  SetWrapMode(GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE);
end;

constructor TTexture.CreateRenderCubemap( const aSize : integer; const aInFormat, aFormat, aType : Cardinal);
var
  iI : Integer;
begin
  inherited Create();
  TexType := GL_TEXTURE_CUBE_MAP;
  CurUnit := 0;
  glEnable(GL_TEXTURE_2D);
	glGenTextures(1,@BufferID);
	glBindTexture(GL_TEXTURE_CUBE_MAP,BufferID);
  for iI := 0 to  5 do
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X+iI,0,aInFormat,aSize,aSize,0,aFormat,aType,nil);
  setFilter(TF_NONE);
  SetWrapMode(GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE,GL_CLAMP_TO_EDGE);
end;

destructor  TTexture.Destroy();
begin
  inherited Destroy();
  glDeleteTextures(1, @BufferID);
end;

procedure TTexture.SetFilter(const aFilter : TTextureFilter);
begin
  case aFilter of
  TF_NONE :
    begin
      glTexParameteri(TexType, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri(TexType, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    end;
  TF_BILINEAR :
    begin
      glTexParameteri(TexType, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(TexType, GL_TEXTURE_MIN_FILTER,  GL_LINEAR_MIPMAP_NEAREST)
    end;
  TF_TRILINEAR :
    begin
      glTexParameteri(TexType, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(TexType, GL_TEXTURE_MIN_FILTER,  GL_LINEAR_MIPMAP_LINEAR)
    end;
  end;
end;

procedure TTexture.SetAnisotropic(const aAnisotropic : Single);
begin
  glTexParameterf(TexType, GL_TEXTURE_MAX_ANISOTROPY_EXT, aAnisotropic);
end;

procedure TTexture.SetWrapMode( aWrapS, aWrapT, aWrapR : Integer );
begin
	glTexParameteri(TexType,GL_TEXTURE_WRAP_S,aWrapS);
	glTexParameteri(TexType,GL_TEXTURE_WRAP_T,aWrapT);
	glTexParameteri(TexType,GL_TEXTURE_WRAP_R,aWrapR);
end;

procedure TTexture.Bind( const aTU : Integer );
begin
  glActiveTexture(GL_TEXTURE0+aTU);
  glBindTexture(TexType, BufferID);
  CurUnit := aTU
end;

procedure  TTexture.Unbind();
begin
  glActiveTexture(GL_TEXTURE0+CurUnit);
  glBindTexture(TexType, 0);
end;

end.
