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
unit SceneIO;

{$MODE Delphi}

interface

uses
  SysUtils,
  Classes,
  Entity,
  ModelEntity,
  StaticModelEntity,
  AnimatedModelEntity,
  LightEntity,
  PointLightEntity,
  SpotLightEntity,
  Mathematics,
  ResourceUtils,
  Scene, FileUtil;

type
  TMapIOCallBack = procedure(const aProgress, aMax : Integer);

procedure SaveMap(const aName : String; const aScene : TScene; const aMapIOCallback : TMapIOCallBack);
procedure LoadMap(const aName : String; var aScene : TScene; const aMapIOCallback : TMapIOCallBack);

implementation

uses
  Base;

procedure SaveMap(const aName : String; const aScene : TScene; const aMapIOCallback : TMapIOCallBack);
var
  aFile : TStringList;
  iI, iTO : Integer;
  iEntity : TEntity;

function FloatArrayToStr(const aArray : array of Single): String;
var
  iI : Integer;
begin
  for iI := 0 to Length(aArray)-1 do
    Result := Result + ' ' + FloatToStr(aArray[iI]);
end;

procedure AddLine(const aStr : String);
var
  iStr : String;
  iI : Integer;
begin
  for iI := 1 to iTO do
    iStr := iStr + #9;
  aFile.Add(iStr + aStr);
end;

procedure StartBracked();
begin
  AddLine('{');
  inc(iTO);
end;

procedure EndBracked();
begin
  Dec(iTO);
  AddLine('}');
end;

procedure SaveEntityBase(const aEntity : TEntity);
begin
  AddLine('name "' + aEntity.Name + '"');
  AddLine('matrix' + FloatArrayToStr( aEntity.Matrix.data[0] ) +
                     FloatArrayToStr( aEntity.Matrix.data[1] ) +
                     FloatArrayToStr( aEntity.Matrix.data[2] ) +
                     FloatArrayToStr( aEntity.Matrix.data[3] ) );
  AddLine('scale ' + FloatToStr(aEntity.Scale));
end;

procedure SaveModelEntity(const aEntity : TModelEntity);
begin
  AddLine('model');
  StartBracked();
    SaveEntityBase(aEntity);
    if aEntity.EntityType = ET_STATICMODEL then
      AddLine('static true')
    else
      AddLine('static false' );
    AddLine('model "' + aEntity.FileName + '"' );
    if aEntity.CastShadows then
      AddLine('castshadow true' )
    else
      AddLine('castshadow false' );
  EndBracked();
end;

procedure SaveLightEntityBase(const aEntity : TLightEntity);
begin
  AddLine('color ' + FloatArrayToStr(aEntity.Color.xyz) );
  AddLine('intensity ' + FloatToStr(aEntity.Intensity) );
  if aEntity.CastShadows then
    AddLine('castshadow true' )
  else
    AddLine('castshadow false' );
end;

procedure SavePointLightEntity(const aEntity : TPointLightEntity);
begin
  AddLine('pointlight');
  StartBracked();
    SaveEntityBase(aEntity);
    SaveLightEntityBase(aEntity);
  EndBracked();
end;

procedure SaveSpotLightEntity(const aEntity : TSpotLightEntity);
begin
  AddLine('spotlight');
  StartBracked();
    SaveEntityBase(aEntity);
    SaveLightEntityBase(aEntity);
    AddLine('outerangle ' + FloatToStr(aEntity.OuterAngle) );
    AddLine('innerangle ' + FloatToStr(aEntity.InnerAngle) );
  EndBracked();
end;

begin
  try
    aFile := TStringList.Create();
    iTO := 0;
    AddLine('scene');
    StartBracked();
    AddLine('ambient' + FloatArrayToStr(aScene.Ambient.xyz) );
    AddLine('entitycount ' + IntToStr(aScene.Entities.Count) );
    for iI := 0 to aScene.Entities.Count-1 do
    begin
      iEntity := aScene.Entities.Get(iI);
      case iEntity.EntityType of
        ET_STATICMODEL, ET_ANIMATEDMODEL : SaveModelEntity(iEntity as TModelEntity);
        ET_POINTLIGHT    : SavePointLightEntity(iEntity as TPointLightEntity);
        ET_SPOTLIGHT     : SaveSpotLightEntity(iEntity as TSpotLightEntity);
      end;
      if assigned(aMapIOCallback) then
        aMapIOCallback(iI+1, aScene.Entities.Count);
    end;
    EndBracked();
    AddLine('');
    aFile.SaveToFile(aName);
    FreeAndNil( aFile );
  except
    on E: Exception do
    begin
      Engine.Log.Print('MapLoader: ', 'Failed To Load Maps: ' + aName);
      Engine.Log.Print('MapLoader: ', E.Message, true);
    end;
  end;
end;

procedure LoadMap(const aName : String; var aScene : TScene; const aMapIOCallback : TMapIOCallBack);
var
  iFile  : TMemoryStream;
  iStr   : String;
  iMax, iCounter : Integer;
  iName   : String;
  iMatrix : TMatrix4x4;
  iScale  : Single;

procedure DoProgress();
begin
  Inc(iCounter);
  if assigned(aMapIOCallback) then
    aMapIOCallback(iCounter, iMax);
end;

procedure ReadFloatBlock(const aFile : TMemoryStream; const aSize : Integer; var aData : array of Single);
var
  iI : Integer;
begin
  for iI := 0 to aSize - 1 do
    aData[iI] := StrToFloat(GetNextToken(aFile));
end;

procedure ReadEntityBase(const aFile : TMemoryStream);
var
  iM : array[0..15] of Single;
begin
  GetNextToken(iFile);
  iName := GetNextToken(iFile);
  GetNextToken(iFile);
  ReadFloatBlock(iFile, 16, iM);
  iMatrix := Matrix(iM[0], iM[4], iM[8], iM[12],
                    iM[1], iM[5], iM[9], iM[13],
                    iM[2], iM[6], iM[10], iM[14],
                    iM[3], iM[7], iM[11], iM[15]);
  GetNextToken(iFile);
  iScale := StrToFloat(GetNextToken(iFile));
end;

procedure SetEntityBase(const aEntity : TEntity);
begin
  aEntity.Name   := iName;
  aEntity.Matrix := Matrix_Copy(iMatrix);
  aEntity.Scale  := iScale;
end;

procedure ReadModel(const aFile : TMemoryStream);
var
  iName : String;
  iIsStatic, iCastShadows : Boolean;
  iStatic  : TStaticModelEntity;
  iDynamic : TAnimatedModelEntity;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected!');

  //read the mesh basics
  ReadEntityBase(aFile);

  //read static or dynamic
  iIsStatic := false;
  GetNextToken(iFile);
  if GetNextToken(iFile) = 'true' then
    iIsStatic := true;

  //read mesh name
  GetNextToken(iFile);
  iName := GetNextToken(iFile);

  //cast shadows
  iCastShadows := false;
  GetNextToken(iFile);
  if GetNextToken(iFile) = 'true' then
    iCastShadows := true;

  //create the entity
  if iIsStatic then
  begin
    iStatic := TStaticModelEntity.Create(aScene, iName);
    SetEntityBase(iStatic);
    iStatic.CastShadows := iCastShadows;
    iStatic.Dirty := true;
  end
  else
  begin
    iDynamic := TAnimatedModelEntity.Create(aScene, iName);
    SetEntityBase(iDynamic);
    iDynamic.CastShadows := iCastShadows;
    iDynamic.Dirty := true;
  end;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected!');
end;

procedure ReadPointLight(const aFile : TMemoryStream);
var
  iIntensity  : Single;
  iColor : TVector3f;
  iCastShadows : Boolean;
  iEntity : TPointLightEntity;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected!');

  //read the mesh basics
  ReadEntityBase(aFile);

  //read color
  GetNextToken(iFile);
  ReadFloatBlock(iFile, 3, iColor.xyz);

  //read in
  GetNextToken(iFile);
  iIntensity := StrToFloat(GetNextToken(iFile));

  //cast shadows
  iCastShadows := false;
  GetNextToken(iFile);
  if GetNextToken(iFile) = 'true' then
    iCastShadows := true;

  //create the entity
  iEntity := TPointLightEntity.Create(aScene, iIntensity, iColor, iCastShadows );

  //set the vars
  SetEntityBase(iEntity);
  iEntity.Dirty := true;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected!');
end;

procedure ReadSpotLight(const aFile : TMemoryStream);
var
  iIntensity : Single;
  iColor : TVector3f;
  iCastShadows : Boolean;
  iEntity : TSpotLightEntity;
  iOuterAngle, iInnerAngle : Single;
begin
  if GetNextToken(aFile) <> '{' then
    raise Exception.Create('"{" token expected!');

  //read the mesh basics
  ReadEntityBase(aFile);

  //read color
  GetNextToken(iFile);
  ReadFloatBlock(iFile, 3, iColor.xyz);

  //read in
  GetNextToken(iFile);
  iIntensity := StrToFloat(GetNextToken(iFile));

  //cast shadows
  iCastShadows := false;
  GetNextToken(iFile);
  if GetNextToken(iFile) = 'true' then
    iCastShadows := true;

  //read outerangle
  GetNextToken(iFile);
  iOuterAngle := StrToFloat(GetNextToken(iFile));

  //read innerangle
  GetNextToken(iFile);
  iInnerAngle := StrToFloat(GetNextToken(iFile));

  //create the entity
  iEntity := TSpotLightEntity.Create(aScene, iIntensity, iOuterAngle, iInnerAngle, iColor, iCastShadows );

  //set the vars
  SetEntityBase(iEntity);
  iEntity.Dirty := true;

  if GetNextToken(aFile) <> '}' then
    raise Exception.Create('"}" token expected!');
end;

begin
  try
    //check if the file exists
    if Not(FileExistsUTF8(aName ) { *Converted from FileExists* }) then
      Raise Exception.Create(aName + ' doesn`t exists');

    //create the filestream
    iFile := TMemoryStream.Create();
    iFile.LoadFromFile(aName);

    //set the comment string
    CommentString := '//';

    //Clear the current map and set some vars
    aScene.Clear();
    iCounter := 0;

    while (iFile.Position < iFile.Size) do
    begin
      iStr := GetNextToken(iFile);

      if iStr = 'ambient' then //scene ambient
      begin
        ReadFloatBlock(iFile, 3, aScene.Ambient.xyz);
        continue;
      end
      else if iStr = 'entitycount' then //scene entity count
      begin
        iMax := StrToInt(GetNextToken(iFile));
        continue;
      end
      else if iStr = 'model' then //add model to scene
      begin
        ReadModel(iFile);
        DoProgress();
        continue;
      end
      else if iStr = 'pointlight' then //add pointlight to scene
      begin
        ReadPointLight(iFile);
        DoProgress();
        continue;
      end
      else if iStr = 'spotlight' then //add pointlight to scene
      begin
        ReadSpotLight(iFile);
        DoProgress();
        continue;
      end
    end;
  except
    on E: Exception do
    begin
      Engine.Log.Print('MapWriter: ', 'Failed To Load Map: ' + aName);
      Engine.Log.Print('MapWriter: ', E.Message, true);
    end;
  end;

  aScene.Update();
  FreeAndNil(iFile);
end;

end.
