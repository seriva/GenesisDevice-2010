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
unit AnimatedModelEntity;

{$MODE Delphi}

interface

uses
  dglOpenGL,
  Entity,
  Model,
  Scene,
  FloatArray,
  SysUtils,
  Mathematics,
  ModelEntity,
  Stream;

type
  TAnimationEndCallBack = procedure();

  TAnimatedModelStream = class
  private
  public
    Vertices : TStream;
    Normals  : TStream;

    constructor Create();
    Destructor  Destroy(); override;
  end;

  TAnimatedModelEntity = class (TModelEntity)
  private
    UpdateVerts        : Boolean;
    LastFrameAABB      : TBoundingBox;
  public
    MeshCount          : Integer;
    Model              : TModel;
    ModelStreams       : array of TAnimatedModelStream;
    CurrentJoints      : array of TJoint;
    InterpolatedJoints : array of TJoint;

    //vars for controlling animation sequence
    StartFrame         : Integer;
    EndFrame           : Integer;
    AnimationEnd       : TAnimationEndCallBack;
    LoopAnim           : Boolean;
    PauseAnim          : Boolean;
    LastTime           : Integer;
		CurAnim            : String;
		CurFrame           : Integer;
		AnimTime	         : Single;

    constructor Create(const aScene : TScene; const aFileName : String);
    Destructor  Destroy(); override;

    procedure Update(); override;
    procedure UpdateVertices();
    procedure CalculateBoundingVolume(); override;

    procedure Render(const aMaterials, aForSelection : Boolean); override;
    procedure RenderNormals(); override;
    procedure RenderBones();

    procedure PlayAnimation(const aName : String; const aLoop : Boolean = false;
                            const aAnimationEnd : TAnimationEndCallBack = nil;
                            const aStartFrame : Integer = -1; const aEndFrame : Integer = -1);
    procedure StopAnimation();
    procedure PauseResumeAnimation(const aResume : Boolean);

    function Copy(const aScene : Pointer): TEntity; override;
  end;

implementation

uses
  Resource,
  Base;

constructor TAnimatedModelStream.Create();
begin
  inherited Create();
  Vertices       := TStream.Create();
  Vertices.Usage := GL_DYNAMIC_DRAW;
  Vertices.Used  := true;
  Normals        := TStream.Create();
  Normals.Usage	 := GL_DYNAMIC_DRAW;
  Normals.Used   := true;
end;

Destructor  TAnimatedModelStream.Destroy();
begin
  inherited Destroy();
  FreeAndNil(Vertices);
  FreeAndNil(Normals);
end;

constructor TAnimatedModelEntity.Create(const aScene : TScene; const aFileName : String );
var
  iI : Integer;
begin
  inherited Create(aFileName);
  EntityType  := ET_ANIMATEDMODEL;
  aScene.AddEntity( self );
  Model := Engine.Resources.Load( aFileName ) as TModel;
  self.Name := 'Model' + IntToStr(aScene.ModelCount);
  TrisCount := Model.GetTrisCount();

  SetLength(ModelStreams, Length(Model.Meshes));
  for iI := 0 to Length(Model.Meshes)-1 do
  begin
    TrisCount := TrisCount + Model.Meshes[iI].Mesh.TrisCount;
    ModelStreams[iI] := TAnimatedModelStream.Create();
    ModelStreams[iI].Vertices.Data.Count := Model.Meshes[iI].Mesh.UVS.Data.Count*3;
    ModelStreams[iI].Normals.Data.Count  := Model.Meshes[iI].Mesh.UVS.Data.Count*3;
  end;

  setLength(InterpolatedJoints, Length(Model.Joints));
  CurrentJoints := @Model.Joints[0];
  CurAnim   := '';
  CurFrame  := 0;
  AnimTime  := 0;
  UpdateVerts := true;
  PauseAnim   := true;
  UpdateVertices();
  CalculateBoundingVolume();
  LastTime := Engine.Timer.Time();
end;

Destructor  TAnimatedModelEntity.Destroy();
var
  iI : Integer;
begin
  inherited Destroy();
  Engine.Resources.Remove( TResource(Model) );
  CurrentJoints := nil;
  setLength(InterpolatedJoints,0);
  for iI := 0 to Length(ModelStreams)-1 do
    FreeAndNil(ModelStreams[iI]);
  setLength(ModelStreams, 0);
end;

procedure TAnimatedModelEntity.Update();
var
  iDT : Single;
  iNextFrame, iI, iTime : Integer;
  iPos1, iPos2 : TVector3f;
label
  EndAniLabel;
begin
  if CurAnim <> '' then
  begin
    iTime := Engine.Timer.Time();
    if (iTime - LastTime >= 1000/60) then
    begin
      if PauseAnim then
      begin
        iDT := (iTime - LastTime) / 1000.0;
        LastTime := iTime;

        with Model.Animations.Get(CurAnim) do
        begin
          if CurFrame >= EndFrame - 1 then
            iNextFrame := StartFrame
          else
            iNextFrame := CurFrame + 1;

          AnimTime := AnimTime + (iDT*FrameRate);

          if ( AnimTime > 1.0 ) then
          begin
            while ( AnimTime > 1.0 ) do
              AnimTime := AnimTime - 1.0;

            CurFrame := iNextFrame;
            if CurFrame >= EndFrame - 1 then
            begin
              if Not(LoopAnim) then
              begin
                if assigned(AnimationEnd) then AnimationEnd();
                StopAnimation();
                goto EndAniLabel;
              end;
              iNextFrame := StartFrame
            end
            else
              iNextFrame := CurFrame + 1;
          end;

          for iI := 0 to Length(Model.Joints) - 1 do
          begin
            iPos1 := Frames[CurFrame].Joints[iI].Pos;
            iPos2 := Frames[iNextFrame].Joints[iI].Pos;
            InterpolatedJoints[iI].Pos := (iPos1 + ((iPos2 - iPos1) * AnimTime));
            InterpolatedJoints[iI].Quat := Frames[CurFrame].Joints[iI].Quat.Copy();
            InterpolatedJoints[iI].Quat.SLerp( Frames[iNextFrame].Joints[iI].Quat, AnimTime );
            InterpolatedJoints[iI].Parent := Frames[CurFrame].Joints[iI].Parent;
          end;

          Dirty := true;
        end;
        UpdateVerts := true;
      end;
    end;
  end;
EndAniLabel:
  TrisCount := Model.GetTrisCount();
  inherited Update();
end;

procedure  TAnimatedModelEntity.CalculateBoundingVolume();
var
  iI, iJ : Integer;
  iVertexArray : TFloatArray;
begin
  if Dirty = false then exit;
  if Usage = EU_DYNAMIC then
  begin
    if CurAnim = '' then
      BoundingBox := CalculateAABBFromAABB(LastFrameAABB)
    else
    begin
      BoundingBox   := CalculateAABBFromAABB(Model.Animations.Get(CurAnim).Frames[CurFrame].AABB);
      LastFrameAABB := BoundingBox_Copy(Model.Animations.Get(CurAnim).Frames[CurFrame].AABB);
    end;
  end
  else
  begin
    iVertexArray := TFloatArray.Create();
    for iJ := 0 to Length(ModelStreams)-1 do
      for iI := 0 to ModelStreams[iJ].Vertices.Data.CountVector3f() do
        iVertexArray.AddVector3f(Matrix_ApplyToVector3f( Matrix,  (ModelStreams[iJ].Vertices.Data.GetVector3f(iI) * Scale) ));
    BoundingBox := iVertexArray.CalculateBoundingBox();
    LastFrameAABB := BoundingBox_Copy(BoundingBox);
    FreeAndNil(iVertexArray);
  end;
  Dirty := false;
end;

procedure TAnimatedModelEntity.Render(const aMaterials, aForSelection : Boolean);
var
  iI : Integer;
begin
  glPushMatrix();
    glMultMatrixf( @Matrix.data[0] );
    glScalef(Scale, Scale, Scale);
    for iI := 0 to Length(Model.Meshes)-1 do
    begin
      with Model.Meshes[iI].Mesh do
      begin
        Vertices := ModelStreams[iI].Vertices;
        Normals  := ModelStreams[iI].Normals;
        Render(aMaterials, aForSelection);
        Vertices := nil;
        Normals  := nil;
      end;
    end;
  glPopMatrix();
end;

procedure TAnimatedModelEntity.RenderNormals();
var
  iI : Integer;
begin
  glPushMatrix();
    glMultMatrixf( @Matrix.data[0] );
    glScalef(Scale, Scale, Scale );
    for iI := 0 to Length(Model.Meshes)-1 do
    begin
      with Model.Meshes[iI].Mesh do
      begin
        Vertices := ModelStreams[iI].Vertices;
        Normals  := ModelStreams[iI].Normals;
        RenderNormals(scale);
        Vertices := nil;
        Normals  := nil;
      end;
    end;
  glPopMatrix();
end;

procedure TAnimatedModelEntity.RenderBones();
var
  iI : Integer;
begin
  glPushMatrix();
    glMultMatrixf( @Matrix.data[0] );
    glScalef(Scale, Scale, Scale );
    glPointSize(5.0);
    Engine.Renderer.SetColor(1.0, 0.0, 0.0, 1.0);
    glBegin (GL_POINTS);
      for iI := 0 to Length(CurrentJoints) - 1 do
        glVertex3fv(@CurrentJoints[iI].Pos.x);
    glEnd ();
    glPointSize (1.0);

    Engine.Renderer.SetColor(0.0, 1.0, 0.0, 1.0);
    glBegin (GL_LINES);
      for iI := 0 to Length(CurrentJoints) - 1 do
      begin
        if (CurrentJoints[iI].parent <> -1) then
        begin
          glVertex3fv(@CurrentJoints[CurrentJoints[iI].parent].pos.x);
	        glVertex3fv(@CurrentJoints[iI].pos.x);
        end;
      end;
    glEnd();
  glPopMatrix();
end;

procedure TAnimatedModelEntity.UpdateVertices();
var
  iI, iJ, iK : Integer;
  iWeight : TWeight;
  iJoint : TJoint;
  iVW : TVector3f;
  iV  : TVector3f;
  iN0, iN1, iN2 : TVector3f;
  iVA, iVB, iVN : TVector3f;
  iTri : TVector3i;
begin
  if  Not(UpdateVerts) then exit;
  with Model do
  begin
    for iI := 0 to Length(Meshes) - 1 do
    begin
      with ModelStreams[iI] do
      begin
        with Meshes[iI] do
        begin
          //update the vertices with the joints
          for iJ := 0 to Length(Meshes[iI].WeightData) - 1 do
          begin
            iV := Vector3f(0,0,0);
            for iK := 0 to WeightData[iJ][1] - 1 do
            begin
                iWeight := Meshes[iI].Weights[WeightData[iJ][0] + iK];
                iJoint  := TJoint(CurrentJoints[iWeight.Joint]);
                iVW     := iJoint.Quat.RotateVector( iWeight.Pos );
                iV      := (iV + ((iJoint.pos + iVW) * iWeight.w));
            end;
            ModelStreams[iI].Vertices.Data.SetVector3f(iJ, iV);
          end;

          //update the normals
          for iJ := 0 to Mesh.Surfaces.get(0).Data.CountVector3i()  do
          begin
            iTri := Mesh.Surfaces.get(0).Data.GetVector3i(iJ);
            iV   := Vertices.Data.GetVector3f( iTri.X );
            iN0  := Normals.Data.GetVector3f( iTri.X );
            iN1  := Normals.Data.GetVector3f( iTri.Y );
            iN2  := Normals.Data.GetVector3f( iTri.Z );

            iVA  := Vertices.Data.GetVector3f( iTri.Y ) - iV;
            iVB  := Vertices.Data.GetVector3f( iTri.Z ) - iV;
            iVN  := iVA.Cross(iVB);

            Normals.Data.SetVector3f( iTri.X, (iN0 + iVN) );
            Normals.Data.SetVector3f( iTri.Y, (iN1 + iVN) );
            Normals.Data.SetVector3f( iTri.Z, (iN2 + iVN) );
          end;

          //normalize the normals
          for iJ := 0 to Normals.Data.CountVector3f() do
          begin
            iV := Normals.Data.GetVector3f(iJ);
            iV.Normalize();
            Normals.Data.SetVector3f(iJ, iV);
          end;

          //uodate the streams
          Vertices.Dirty := true;
          Vertices.Update();
          Normals.Dirty := true;
          Normals.Update();
        end;
      end;
    end;
  end;
  UpdateVerts := false;
end;

procedure TAnimatedModelEntity.PlayAnimation(const aName : String; const aLoop : Boolean = false;
                                     const aAnimationEnd : TAnimationEndCallBack = nil;
                                     const aStartFrame : Integer = -1; const aEndFrame : Integer = -1);
begin
  AnimationEnd := aAnimationEnd;
  LoopAnim := aLoop;
  CurFrame := 0;
  AnimTime := 0;

  if not(Model.Animations.Exists(aName)) then
    Engine.Log.Print(self.Name, 'Animation "' + aName + '" does not exist!', true);
  CurAnim := aName;

  if aStartFrame = -1 then
    StartFrame := 0
  else
  begin
    if (aStartFrame < 0) or (aStartFrame > aEndFrame) then
      Engine.Log.Print(self.Name, 'Startframe is out of range!', true);
    StartFrame := aStartFrame;
  end;

  if aEndFrame = -1 then
    EndFrame := Model.Animations.Get(CurAnim).NumFrames
  else
  begin
    if (aEndFrame > Model.Animations.Get(CurAnim).NumFrames) or (aEndFrame < StartFrame) then
      Engine.Log.Print(self.Name, 'Endframe is out of range!', true);
    EndFrame := aEndFrame;
  end;

  CurrentJoints := @InterpolatedJoints[0];
  UpdateVertices();
end;

procedure TAnimatedModelEntity.StopAnimation();
begin
  CurAnim   := '';
  CurFrame  := 0;
  AnimTime  := 0;
end;

procedure TAnimatedModelEntity.PauseResumeAnimation(const aResume : Boolean);
begin
  PauseAnim := aResume;
end;

function TAnimatedModelEntity.Copy(const aScene : Pointer): TEntity;
var
  iEntity : TAnimatedModelEntity;
begin
  iEntity := TAnimatedModelEntity.Create(TScene(aScene), self.FileName);
  CopyBase(iEntity);
  iEntity.CastShadows := CastShadows;
  result := iEntity;
end;

end.
