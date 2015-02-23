unit RenderBuffer;

{$MODE Delphi}

interface

uses
  dglOpenGL;

Type
  TRenderBuffer = class
  private
  public
    BufferID : GLuint;

    constructor Create(const aWidth, aHeight : Integer; const aFormat  : cardinal);
    destructor  Destroy(); override;
    procedure   Bind();
    procedure   Unbind();
  end;

implementation

constructor TRenderBuffer.Create(const aWidth, aHeight : Integer; const aFormat : cardinal);
begin
  inherited Create();
  glGenRenderBuffers(1, @BufferID);
  glBindRenderbuffer(GL_RENDERBUFFER, BufferID);
  glRenderbufferStorage(GL_RENDERBUFFER, aFormat,aWidth, aHeight);
end;

destructor  TRenderBuffer.Destroy();
begin
  inherited Destroy();
  glDeleteRenderBuffers(1, @BufferID);
end;

procedure TRenderBuffer.Bind();
begin
  glBindRenderBuffer(GL_RENDERBUFFER, BufferID);
end;

procedure TRenderBuffer.Unbind();
begin
  glBindRenderBuffer(GL_RENDERBUFFER, 0);
end;

end.
