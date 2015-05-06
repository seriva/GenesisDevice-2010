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
unit DDSLoader;

interface

uses
  Windows,
  DirectDraw,
  SysUtils,
  Base,
  dglOpenGL,
  Texture,
  Resource;

function LoadDDSResource(const aName : String): TResource;

implementation

function LoadDDSResource(const aName : String): TResource;
var
  iTexture       : TTexture;
  iDDSD          : TDDSurfaceDesc2;
  iFileCode      : array[0..3] of AnsiChar;
  iBufferSize    : integer;
  iReadBufferSize: integer;
  iPFile         : THandle;
  iReadBytes     : Longword;
  iDDSData       : TDDSData;
begin
  try
    //check if the file exists
    if Not(FileExists( Engine.BasePath + aName )) then
      Raise Exception.Create(Engine.BasePath + aName + ' doesn`t exists.');

    //load the texture
    iPFile := CreateFile(PChar(aName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
    if (iPFile = INVALID_HANDLE_VALUE) then
      Raise Exception.Create('Failed to load texture ' + aName);

    //verify if it is a true DDS file
    ReadFile( iPFile, iFileCode, 4, iReadBytes, nil);
    if (iFileCode[0] + iFileCode[1] + iFileCode[2] <> 'DDS') then
      Raise Exception.Create('File ' + aName + ' is not a valid DDS file.');

    //read surface descriptor
    ReadFile( iPFile, iDDSD, sizeof(iDDSD), iReadBytes, nil );
    case iDDSD.ddpfPixelFormat.dwFourCC of
    FOURCC_DXT1 : begin
                    //DXT1's compression ratio is 8:1
                    iDDSData.OutputFormat := GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
                    iDDSData.Factor := 2;
                  end;
    FOURCC_DXT3 : begin
                    //DXT3's compression ratio is 4:1
                    iDDSData.OutputFormat := GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
                    iDDSData.Factor := 4;
                  end;
    FOURCC_DXT5 : begin
                    //DXT5's compression ratio is 4:1
                    iDDSData.OutputFormat := GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
                    iDDSData.Factor := 4;
                  end;
    else          begin
                    //Not compressed. Oh shit, didn't implement that!
                    Raise Exception.Create('File ' + aName + ' has no compression! Loading non-compressed implemented.');
                  end;
    end;

    //how big will the buffer need to be to load all of the pixel data including mip-maps?
    if( iDDSD.dwLinearSize = 0 ) then
      Raise Exception.Create('File ' + aName + ' dwLinearSize is 0.');

    //set the buffer size
    if( iDDSD.dwMipMapCount > 1 ) then
      iBufferSize := iDDSD.dwLinearSize * iDDSData.Factor
    else
      iBufferSize := iDDSD.dwLinearSize;

    //read the buffer data
    iReadBufferSize := iBufferSize * sizeof(Byte);
    setLength(iDDSData.Data, iReadBufferSize);
    if Not(ReadFile( iPFile, iDDSData.Data[0] , iReadBufferSize, iReadBytes, nil)) then
      Raise Exception.Create('Failed to read image data from file ' + aName);
    CloseHandle(iPFile);

    //more output info }
    iDDSData.Width      := iDDSD.dwWidth;
    iDDSData.Height     := iDDSD.dwHeight;
    iDDSData.NumMipMaps := iDDSD.dwMipMapCount;

    //do we have a fourth Alpha channel doc? }
    if( iDDSD.ddpfPixelFormat.dwFourCC = FOURCC_DXT1 ) then
      iDDSData.Components := 3
    else
      iDDSData.Components := 4;

    //create the texture that will hold the file.
    iTexture := TTexture.CreateDDSTexture(iDDSData);
    iTexture.Name := aName;
  except
    on E: Exception do
    begin
      Engine.Log.Print('DDSLoader: ', 'Failed To Load Resource: ' + Engine.BasePath + aName);
      Engine.Log.Print('DDSLoader: ', E.Message, true);
    end;
  end;
  result := iTexture;
end;

end.

