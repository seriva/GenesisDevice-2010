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
program Editor;

{$MODE Delphi}

uses
  Forms, Interfaces,
  Main in 'Main.pas' {MainForm},
  Configuration in 'Configuration.pas' {ConfigurationForm},
  ViewPort in 'ViewPort.pas' {ViewPortForm},
  ViewPort2D in 'ViewPort2D.pas' {ViewPort2DForm},
  ViewPort3D in 'ViewPort3D.pas' {ViewPort3DForm},
  ViewPortFront in 'ViewPortFront.pas' {ViewPortFrontForm},
  ViewPortSide in 'ViewPortSide.pas' {ViewPortSideForm},
  ViewPortTop in 'ViewPortTop.pas' {ViewPortTopForm},
  dglOpenGL in '..\Libraries\OpenGL\dglOpenGL.pas',
  Model in '..\Engine\Animation\Model.pas',
  Console in '..\Engine\General\Console.pas',
  Base in '..\Engine\General\Base.pas',
  Log in '..\Engine\General\Log.pas',
  Timer in '..\Engine\General\Timer.pas',
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
  MD5Loader in '..\Engine\Resources\MD5Loader.pas',
  MTLLoader in '..\Engine\Resources\MTLLoader.pas',
  OBJLoader in '..\Engine\Resources\OBJLoader.pas',
  Resources in '..\Engine\Resources\Resources.pas',
  ResourceUtils in '..\Engine\Resources\ResourceUtils.pas',
  ShaderLoader in '..\Engine\Resources\ShaderLoader.pas',
  Entity in '..\Engine\Scene\Entity.pas',
  LightEntity in '..\Engine\Scene\LightEntity.pas',
  StaticModelEntity in '..\Engine\Scene\StaticModelEntity.pas',
  AnimatedModelEntity in '..\Engine\Scene\AnimatedModelEntity.pas',
  PointLightEntity in '..\Engine\Scene\PointLightEntity.pas',
  Scene in '..\Engine\Scene\Scene.pas',
  SpotLightEntity in '..\Engine\Scene\SpotLightEntity.pas',
  Selection in 'Selection.pas',
  EditorEntity in 'EditorEntity.pas',
  SceneIO in '..\Engine\Resources\SceneIO.pas',
  Progress in 'Progress.pas' {ProgressForm},
  GLSLLoader in '..\Engine\Resources\GLSLLoader.pas',
  Resource in '..\Engine\Resources\Resource.pas',
  ModelEntity in '..\Engine\Scene\ModelEntity.pas',
  BrowserNodeData in 'BrowserNodeData.pas',
  DDSLoader in '..\Engine\Resources\DDSLoader.pas',
  EntityFrame in 'Frames\EntityFrame.pas' {EntityPropFrame: TFrame},
  SceneFrame in 'Frames\SceneFrame.pas' {ScenePropFrame: TFrame},
  ModelEntityFrame in 'Frames\ModelEntityFrame.pas' {ModelEntityPropFrame: TFrame},
  LightEntityFrame in 'Frames\LightEntityFrame.pas' {LightEntityPropFrame: TFrame},
  SpotLightEntityFrame in 'Frames\SpotLightEntityFrame.pas' {Frame1: TFrame},
  Stats in '..\Engine\General\Stats.pas',
  Mathematics in '..\Engine\General\Mathematics.pas',
  FloatArray in '..\Engine\Renderer\FloatArray.pas',
  IntegerArray in '..\Engine\Renderer\IntegerArray.pas',
  DirectDraw in '..\Libraries\DirectX\DirectDraw.pas';

begin
  //init the application
  Application.Initialize;

  //create the base forms
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfigurationForm, ConfigurationForm);
  Application.CreateForm(TProgressForm, ProgressForm);
  MainForm.LoadConfiguration();
  MainForm.UpdateAssetBrowser();
  MainForm.CreateViewPorts();

  //Run the application
  Application.Run();
end.
