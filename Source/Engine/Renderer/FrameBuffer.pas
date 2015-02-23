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
unit FrameBuffer;

{$MODE Delphi}

interface

uses
  RenderBuffer,
  Texture,
  dglOpenGL;

type
  TFrameBuffer = class
  private
  public
    BufferID : GLuint;

    constructor Create();
    destructor  Destroy(); override;
    procedure   Bind();
    procedure   Unbind();
    procedure   AttachRenderTexture(const aTexture : TTexture; const aAttachement, aTexTarget : cardinal);
    procedure   AttachRenderBuffer(const aRenderBuffer : TRenderBuffer; const aAttachement : cardinal);
    procedure   Status();
  end;

implementation

uses
  Base;

constructor TFrameBuffer.Create();
begin
  inherited Create();
  glGenFrameBuffers(1, @BufferID);
end;

destructor TFrameBuffer.Destroy();
begin
  inherited Destroy();
  glDeleteFrameBuffers(1, @BufferID);
end;

procedure TFrameBuffer.Bind();
begin
  glBindFramebuffer(GL_FRAMEBUFFER, BufferID);
end;

procedure TFrameBuffer.Unbind();
begin
  glBindFramebufferEXT(GL_FRAMEBUFFER, 0);
end;

procedure TFrameBuffer.AttachRenderTexture(const aTexture : TTexture; const aAttachement, aTexTarget : cardinal);
begin
  glFramebufferTexture2D(GL_FRAMEBUFFER, aAttachement, aTexTarget, aTexture.BufferID, 0);
end;

procedure TFrameBuffer.AttachRenderBuffer(const aRenderBuffer : TRenderBuffer; const aAttachement : cardinal);
begin
  glFramebufferRenderbuffer(GL_FRAMEBUFFER,aAttachement,GL_RENDERBUFFER,aRenderBuffer.BufferID);
end;

procedure TFrameBuffer.Status();
var
  iM: GLenum;
begin
  iM := glCheckFramebufferStatus(GL_FRAMEBUFFER);
  case iM of
    GL_FRAMEBUFFER_COMPLETE:
      Exit;
    GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
      Engine.Log.Print(self.ClassName, 'Incomplete attachment', true);
    GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
      Engine.Log.Print(self.ClassName, 'Incomplete attachment', true);
    GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT:
      Engine.Log.Print(self.ClassName, 'Duplicate attachment', true);
    GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
      Engine.Log.Print(self.ClassName, 'Incomplete dimensions', true);
    GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
      Engine.Log.Print(self.ClassName, 'Incomplete formats', true);
    GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
      Engine.Log.Print(self.ClassName, 'Incomplete draw buffer', true);
    GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
      Engine.Log.Print(self.ClassName, 'Incomplete read buffer', true);
    GL_FRAMEBUFFER_UNSUPPORTED_EXT:
      Engine.Log.Print(self.ClassName, 'Framebuffer unsupported', true);
    else
      Engine.Log.Print(self.ClassName, 'Framebuffer unsupported', true);
  end;
end;

end.
