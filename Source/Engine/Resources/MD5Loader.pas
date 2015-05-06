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
unit MD5Loader;

{$MODE Delphi}

interface

uses
  SysUtils,
  Classes,
  Resource,
  Mathematics,
  ResourceUtils,
  Model, FileUtil;

function LoadMD5Resource(const aName : String): TResource;

implementation

uses
  Base;

var
  NumJoints    : Integer;
  NumMeshes    : Integer;
  MeshCounter  : Integer;
  FrameCounter : Integer;
  CurAni       : String;

procedure ReadFloatBlock(const aFile : TMemoryStream; const aSize : Integer; var aData : array of Single);
var
  iI : Integer;
begin
  if GetNextToken(aFile) <> '(' then
    raise Exception.Create('"(" token expected!');

  for iI := 0 to aSize - 1 do
    aData[iI] := StrToFloat(GetNextToken(aFile));

  if GetNextToken(aFile) <> ')' then
    raise Exception.Create('")" token expected!');
end;

procedure ReadCommandLine(const aFile : TMemoryStream);
var
  iC : AnsiChar;
begin
  aFile.Read(iC, 1);
  while Not(iC = #10) and (aFile.Position < aFile.Size) do
    aFile.Read(iC, 1);
end;

procedure ReadJoints(const aFile : TMemoryStream; var aModel : TModel);
var
  iI, iParent   : Integer;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected after "joints"!');

  //now read al the joints
  for iI := 0 to NumJoints - 1 do
  begin
    with aModel do
    begin
      with Joints[iI] do
      begin
        GetNextToken(aFile);
        Parent := StrToInt(GetNextToken(aFile));
        ReadFloatBlock(aFile, 3, Pos.xyz);
        ReadFloatBlock(aFile, 3, Quat.wxyz);
        Quat.BuildW();
      end;
    end;
  end;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected, joint count is incorrect!');
end;

procedure ReadMesh(const aFile : TMemoryStream; var aModel : TModel);
var
  iStr : String;
  iI   : Integer;
  iUV  : TVector2f;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected after "mesh"!');

  while (aFile.Position < aFile.Size) do
  begin
    iStr := GetNextToken(aFile);

    with aModel do
    begin
      if iStr = 'shader' then //read the mesh shader
      begin
        iStr := GetNextToken(aFile);
        Meshes[MeshCounter].Mesh.Surfaces.get(0).MatName :=  'mat_' + iStr;
        continue;
      end
      else if iStr = 'numverts' then //read the mesh vertex count
      begin
        iI := StrToInt(GetNextToken(aFile));
        setLength(Meshes[MeshCounter].WeightData, iI);
        Meshes[MeshCounter].Mesh.UVS.Data.Count := iI*2;
        continue;
      end
      else if iStr = 'numtris' then //read the mesh triangle count
      begin
        iI := StrToInt(GetNextToken(aFile));
        Meshes[MeshCounter].Mesh.Surfaces.get(0).Data.Count := iI*3;
        continue;
      end
      else if iStr = 'numweights' then //read the mesh weights count
      begin
        setLength(Meshes[MeshCounter].Weights, StrToInt(GetNextToken(aFile)));
        continue;
      end
      else if iStr = 'vert' then //read a vertex in the mesh
      begin
        iI := StrToInt(GetNextToken(aFile));
        if iI > Length(Meshes[MeshCounter].Mesh.UVS.Data.List) div 2 then
          raise Exception.Create('Mesh vert index is incorrect!');
        ReadFloatBlock(aFile, 2, iUV.XY);
        Meshes[MeshCounter].Mesh.UVS.Data.SetVector2f(iI, iUV);
        Meshes[MeshCounter].WeightData[iI][0] := StrToInt(GetNextToken(aFile));
        Meshes[MeshCounter].WeightData[iI][1] := StrToInt(GetNextToken(aFile));
        continue;
      end
      else if iStr = 'tri' then //read a triangle in the mesh
      begin
        iI := StrToInt(GetNextToken(aFile));
        if iI > Length(Meshes[MeshCounter].Mesh.Surfaces.get(0).Data.List) div 3  then
          raise Exception.Create('Mesh triangle index is incorrect!');
        Meshes[MeshCounter].Mesh.Surfaces.get(0).Data.List[(iI * 3)+2] := StrToInt(GetNextToken(aFile));
        Meshes[MeshCounter].Mesh.Surfaces.get(0).Data.List[(iI * 3)+1] := StrToInt(GetNextToken(aFile));
        Meshes[MeshCounter].Mesh.Surfaces.get(0).Data.List[(iI * 3)]   := StrToInt(GetNextToken(aFile));
        continue;
      end
      else if iStr = 'weight' then //read a weight in the mesh
      begin
        iI := StrToInt(GetNextToken(aFile));
        if iI > Length(Meshes[MeshCounter].Weights) then
          raise Exception.Create('Mesh weight index is incorrect!');
        Meshes[MeshCounter].Weights[iI].Joint := StrToInt(GetNextToken(aFile));
        Meshes[MeshCounter].Weights[iI].W     := StrToFloat(GetNextToken(aFile));
        ReadFloatBlock(aFile, 3, Meshes[MeshCounter].Weights[iI].Pos.xyz);
        continue;
      end
      else if iStr = '}' then //end token found
      begin
        break;
      end
      else
        raise Exception.Create('Unknown token used in mesh data: "' + iStr + '"!');
    end;
  end;

  if iStr <> '}' then
    raise Exception.Create('"}" token expected,  mesh data is incorrect!');
end;

procedure BuildFrames(var aAnimation : TAnimation);
var
  iI, iJ, iM : Integer;
  iPos : TVector3f;
  iOri : TQuaternion;
  iRotPos : TVector3f;
  iParentJoint : TJoint;
begin
  with aAnimation do
  begin
    for iI := 0 to NumFrames - 1 do
    begin
      for iJ := 0 to NumJoints - 1 do
      begin
        with BaseJoints[iJ] do
        begin
          iPos := Pos.Copy();
          iOri := Quat.Copy();

          iM := 0;
          if (JointInfo[iJ][1] and 1) <> 0 then
          begin
            iPos.xyz[0] := Frames[iI].AniComp[ JointInfo[iJ][2] + iM ];
            Inc(iM);
          end;

          if (JointInfo[iJ][1] and 2) <> 0 then
          begin
            iPos.xyz[1] := Frames[iI].AniComp[ JointInfo[iJ][2] + iM ];
            Inc(iM);
          end;

          if (JointInfo[iJ][1] and 4) <> 0 then
          begin
            iPos.xyz[2] := Frames[iI].AniComp[ JointInfo[iJ][2] + iM ];
            Inc(iM);
          end;

          if (JointInfo[iJ][1] and 8) <> 0 then
          begin
            iOri.wxyz[0] := Frames[iI].AniComp[ JointInfo[iJ][2] + iM ];
            Inc(iM);
          end;

          if (JointInfo[iJ][1] and 16) <> 0 then
          begin
            iOri.wxyz[1] := Frames[iI].AniComp[ JointInfo[iJ][2] + iM ];
            Inc(iM);
          end;

          if (JointInfo[iJ][1] and 32) <> 0 then
          begin
            iOri.wxyz[2] := Frames[iI].AniComp[ JointInfo[iJ][2] + iM ];
            Inc(iM);
          end;
          iOri.BuildW();

          with Frames[iI].Joints[iJ] do
          begin
            Parent := JointInfo[iJ][0];
            if (  JointInfo[iJ][0] < 0 )then
            begin
              Pos := iPos.Copy();
              Quat := iOri.Copy();
            end
            else
            begin
              iParentJoint := Frames[iI].Joints[ Frames[iI].Joints[iJ].Parent ];
              iRotPos := iParentJoint.Quat.RotateVector(iPos);
              Pos := iRotPos + iParentJoint.Pos;
              Quat := iParentJoint.Quat * iOri;
              Quat.Normalize();
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure ReadHierarchy(const aFile : TMemoryStream; var aAnimation : TAnimation);
var
  iI   : Integer;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected after "hierarchy"!');

  //now read al the hierarchies
  for iI := 0 to NumJoints - 1 do
  begin
    with aAnimation do
    begin
      GetNextToken(aFile);
      JointInfo[iI][0] := StrToInt(GetNextToken(aFile));
      JointInfo[iI][1] := StrToInt(GetNextToken(aFile));
      JointInfo[iI][2] := StrToInt(GetNextToken(aFile));
    end;
  end;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected, hierarchy count is incorrect!');
end;

procedure ReadBounds(const aFile : TMemoryStream; var aAnimation : TAnimation);
var
  iI   : Integer;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected after "bounds"!');

  for iI := 0 to aAnimation.NumFrames - 1 do
  begin
    with aAnimation.Frames[iI] do
    begin
      ReadFloatBlock(aFile, 3, AABB.Min.xyz);
      ReadFloatBlock(aFile, 3, AABB.Max.xyz);
    end;
  end;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected, bound count is incorrect!');
end;

procedure ReadBaseFrame(const aFile : TMemoryStream; var aAnimation : TAnimation);
var
  iI   : Integer;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected after "baseframe"!');

  //now read in the base frame
  for iI := 0 to NumJoints - 1 do
  begin
    with aAnimation.BaseJoints[iI] do
    begin
      ReadFloatBlock(aFile, 3, Pos.xyz);
      ReadFloatBlock(aFile, 3, Quat.wxyz);
      Quat.BuildW();
    end;
  end;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected, baseframe count is incorrect!');
end;

procedure ReadFrame(const aFile : TMemoryStream; var aAnimation : TAnimation);
var
  iI   : Integer;
  iFrameNr : Integer;
begin
  iFrameNr := StrToInt(GetNextToken(aFile));

  if iFrameNr > aAnimation.NumFrames then
    raise Exception.Create('Frame index is incorrect!');

  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected after "frame"!');

  setLength(aAnimation.Frames[iFrameNr].AniComp, aAnimation.NumAniComp);
  setLength(aAnimation.Frames[iFrameNr].Joints, NumJoints);

  for iI := 0 to aAnimation.NumAniComp - 1 do
    aAnimation.Frames[iFrameNr].AniComp[iI] := StrToFloat(GetNextToken(aFile));

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected, frame count is incorrect!');
end;

procedure LoadAnimation(const aName : String; var aModel : TModel);
var
	iFile : TMemoryStream;
  iStr  : String;
  iI    : Integer;
  iAni  : TAnimation;
begin
  //reset some stuff
  FrameCounter := 0;

  //check if the file exists
  if Not(FileExistsUTF8(aName) { *Converted from FileExists* }) then
    raise Exception.Create(aName + ' doesn`t exits!');

  //load the file into a stream
  iFile := TMemoryStream.Create();
  iFile.LoadFromFile(aName);

  //read the file
  while (iFile.Position <= iFile.Size) do
  begin
    iStr := GetNextToken(iFile);

    if iStr = 'MD5Version' then //read and check version
    begin
      iStr := GetNextToken(iFile);
      if iStr <> '10' then
        raise Exception.Create('MD5 version isn`t correct! Loader only supports MD5 version 1.0!');
      continue;
    end
    else if iStr = 'commandline' then //read and ignore commandline
    begin
        ReadCommandLine(iFile);
        continue;
    end
    else if iStr = 'numJoints' then //read the number of joints and check them against the meshfile
    begin
      iI := StrToInt(GetNextToken(iFile));
      if (NumJoints <> iI) then
        raise Exception.Create('Animation and Mesh have different joint counts!');

      setLength( iAni.JointInfo, NumJoints);
      setLength( iAni.BaseJoints, NumJoints);
      continue;
    end
    else if iStr = 'numMeshes' then //read the number of meshes and check them against the meshfile
    begin
      if (NumMeshes <> StrToInt(GetNextToken(iFile))) then
        raise Exception.Create('Animation and Mesh have different mesh counts!');
      continue;
    end
    else if iStr = 'numFrames' then //read the number of frames
    begin
      iAni.NumFrames := StrToInt(GetNextToken(iFile));;
      setLength(iAni.Frames, iAni.NumFrames);
      continue;
    end
    else if iStr = 'frameRate' then //read the framerate
    begin
      iAni.FrameRate := StrToInt(GetNextToken(iFile));
      continue;
    end
    else if iStr = 'numAnimatedComponents' then //read the number of animated components
    begin
      iAni.NumAniComp := StrToInt(GetNextToken(iFile));
      continue;
    end
    else if iStr = 'hierarchy' then //read hierarchy
    begin
      ReadHierarchy(iFile, iAni);
      continue;
    end
    else if iStr = 'bounds' then //read bounds
    begin
      ReadBounds(iFile, iAni);
      continue;
    end
    else if iStr = 'baseframe' then //read baseframe
    begin
      ReadBaseFrame(iFile, iAni);
      continue;
    end
    else if iStr = 'frame' then //read a frame
    begin
      inc(FrameCounter);
      if ((FrameCounter = 0) or (FrameCounter > iAni.NumFrames)) then
        raise Exception.Create('MD5 has undefined frames!');
      ReadFrame(iFile, iAni);
      continue;
    end
    else
    begin //handle with unknown character or end of file.
      if (iFile.Position = iFile.Size) then
        break
      else
        raise Exception.Create('Unknown token used: "' + iStr + '"!');
    end;
  end;

  BuildFrames(iAni);
  if aModel.Animations.Exists(CurAni) then
    Raise Exception.Create('Animation name ' + CurAni + 'already in use!');
  aModel.Animations.Add( CurAni, iAni);

  FreeAndNil(iFile);
end;

procedure LoadModel(const aName : String; var aModel : TModel );
var
	iFile : TMemoryStream;
  iStr  : String;
  iI    : Integer;
begin
  //reset some stuff
  NumJoints := 0;
  NumMeshes := 0;
  MeshCounter := -1;

  //check if the file exists
  if Not(FileExistsUTF8(aName) { *Converted from FileExists* }) then
    raise Exception.Create(aName + ' doesn`t exits!');

  //load the file into a stream
  iFile := TMemoryStream.Create();
  iFile.LoadFromFile(aName);

  //read the file
  while (iFile.Position <= iFile.Size) do
  begin
    iStr := GetNextToken(iFile);

    if iStr = 'MD5Version' then //read and check version
    begin
      iStr := GetNextToken(iFile);
      if iStr <> '10' then
        raise Exception.Create('MD5 version isn`t correct! Loader only supports MD5 version 1.0!');
      continue;
    end
    else if iStr = 'commandline' then //read and ignore commandline
    begin
      ReadCommandLine(iFile);
      continue;
    end
    else if iStr = 'numJoints' then //read the number of joints
    begin
      NumJoints := StrToInt(GetNextToken(iFile));
      setLength( aModel.Joints, NumJoints );
      continue;
    end
    else if iStr = 'numMeshes' then //read the number of meshes
    begin
      NumMeshes := StrToInt(GetNextToken(iFile));
      for iI := 0 to NumMeshes-1 do
        aModel.AddMesh();
      continue;
    end
    else if iStr = 'joints' then //read the joints
    begin
      if NumJoints = 0 then
        raise Exception.Create('MD5 has undefined joints!');
      ReadJoints(iFile, aModel);
      continue;
    end
    else if iStr = 'mesh' then //read a mesh
    begin
      inc(MeshCounter);
      if ((NumMeshes = 0) or (MeshCounter > NumMeshes)) then
        raise Exception.Create('MD5 has undefined meshes!');
      ReadMesh(iFile, aModel);
      aModel.Meshes[MeshCounter].Mesh.Update();
      continue;
    end
    else
    begin //handle with unknown character or end of file.
      if (iFile.Position = iFile.Size) then
        break
      else
        raise Exception.Create('Unknown token used: "' + iStr + '"!');
    end;
  end;
  FreeAndNil(iFile);
end;

function LoadMD5Resource(const aName : String): TResource;
var
  iFile  : TMemoryStream;
  iStr   : String;
  iModel : TModel;
begin
  try
    //check if the file exists
    if Not(FileExistsUTF8(Engine.BasePath + aName ) { *Converted from FileExists* }) then
      Raise Exception.Create(Engine.BasePath + aName + ' doesn`t exists');

    //create the filestream
    iFile := TMemoryStream.Create();
    iFile.LoadFromFile(Engine.BasePath + aName);

    //set the comment string
    CommentString := '//';
    iModel := TModel.Create();
    iModel.Name := aName;

    while (iFile.Position < iFile.Size) do
    begin
      iStr := GetNextToken(iFile);
      if iStr = 'mesh' then //read the md5 mesh
      begin
        LoadModel( ExtractFilePath(aName) + GetNextToken(iFile), iModel);
        continue;
      end
      else if iStr = 'anim' then //read the md5 animation
      begin
        CurAni := GetNextToken(iFile);
        LoadAnimation( ExtractFilePath(aName) + GetNextToken(iFile), iModel);
        continue;
      end
      else if iStr = 'mtllib' then //read the material lib
      begin
        Engine.Resources.Load( ExtractFilePath(aName) + GetNextToken(iFile) );
        continue;
      end
    end;
  except
    on E: Exception do
    begin
      Engine.Log.Print('MD5Loader: ', 'Failed To Load Resource: ' + Engine.BasePath + aName);
      Engine.Log.Print('MD5Loader: ', E.Message, true);
    end;
  end;
  FreeAndNil(iFile);
  result := iModel;
end;

end.
