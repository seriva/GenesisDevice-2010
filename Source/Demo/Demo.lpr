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
program Demo;

{$MODE Delphi}

uses
  Forms, Interfaces,
  SysUtils,
  Configuration in 'Configuration.pas' {ConfigurationForm},
  dglOpenGL in '..\Libraries\OpenGL\dglOpenGL.pas',
  Main in 'Main.pas' {MainForm},
  Resources in '..\Engine\Resources\Resources.pas',
  OBJLoader in '..\Engine\Resources\OBJLoader.pas',
  MTLLoader in '..\Engine\Resources\MTLLoader.pas',
  Log in '..\Engine\General\Log.pas',
  Timer in '..\Engine\General\Timer.pas',
  ResourceUtils in '..\Engine\Resources\ResourceUtils.pas',
  Base in '..\Engine\General\Base.pas',
  MD5Loader in '..\Engine\Resources\MD5Loader.pas',
  Console in '..\Engine\General\Console.pas',
  Model in '..\Engine\Animation\Model.pas',
  GLSLLoader in '..\Engine\Resources\GLSLLoader.pas',
  ShaderLoader in '..\Engine\Resources\ShaderLoader.pas',
  BitmapFont in '..\Engine\Renderer\BitmapFont.pas',
  Camera in '..\Engine\Renderer\Camera.pas',
  Context in '..\Engine\Renderer\Context.pas',
  FrameBuffer in '..\Engine\Renderer\FrameBuffer.pas',
  GBuffer in '..\Engine\Renderer\GBuffer.pas',
  Material in '..\Engine\Renderer\Material.pas',
  Mesh in '..\Engine\Renderer\Mesh.pas',
  OcclusionQuery in '..\Engine\Renderer\OcclusionQuery.pas',
  RenderBuffer in '..\Engine\Renderer\RenderBuffer.pas',
  Renderer in '..\Engine\Renderer\Renderer.pas',
  SBuffer in '..\Engine\Renderer\SBuffer.pas',
  Shader in '..\Engine\Renderer\Shader.pas',
  ShaderProgram in '..\Engine\Renderer\ShaderProgram.pas',
  Stream in '..\Engine\Renderer\Stream.pas',
  Surface in '..\Engine\Renderer\Surface.pas',
  Texture in '..\Engine\Renderer\Texture.pas',
  Entity in '..\Engine\Scene\Entity.pas',
  LightEntity in '..\Engine\Scene\LightEntity.pas',
  StaticModelEntity in '..\Engine\Scene\StaticModelEntity.pas',
  PointLightEntity in '..\Engine\Scene\PointLightEntity.pas',
  Scene in '..\Engine\Scene\Scene.pas',
  SpotLightEntity in '..\Engine\Scene\SpotLightEntity.pas',
  SceneIO in '..\Engine\Resources\SceneIO.pas',
  Resource in '..\Engine\Resources\Resource.pas',
  AnimatedModelEntity in '..\Engine\Scene\AnimatedModelEntity.pas',
  ModelEntity in '..\Engine\Scene\ModelEntity.pas',
  DDSLoader in '..\Engine\Resources\DDSLoader.pas',
  GroupEntity in '..\Engine\Scene\GroupEntity.pas',
  Stats in '..\Engine\General\Stats.pas',
  FloatArray in '..\Engine\Renderer\FloatArray.pas',
  IntegerArray in '..\Engine\Renderer\IntegerArray.pas',
  Mathematics in '..\Engine\General\Mathematics.pas',
  DirectDraw in '..\Libraries\DirectX\DirectDraw.pas';

begin
  Application.Initialize;
  Application.CreateForm(TConfigurationForm, ConfigurationForm);
  Application.Run;
end.
