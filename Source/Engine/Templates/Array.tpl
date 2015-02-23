{$IFNDEF TEMPLATE_IMPLEMENTATION}

type
  TYPED_ARRAY = class
  private
    FCount : Integer;
    procedure SetCount(const aCount : Integer);
    function  CompareItems(const aItem1, aItem2 : TYPED_ARRAY_ITEM): boolean; virtual;
    procedure OnRemoveItem(var aItem : TYPED_ARRAY_ITEM); virtual;
  public
    List : array of TYPED_ARRAY_ITEM;
    property Count : Integer read FCount write SetCount;

    constructor Create();
    destructor Destroy; override;

    function  Add( const aItem : TYPED_ARRAY_ITEM ): integer;
    function  Get(const aIndex : Integer): TYPED_ARRAY_ITEM;
    procedure RemoveIdx( const aIndex : Integer);
    procedure RemoveItm( const aItem : TYPED_ARRAY_ITEM );
    procedure Clear();
    procedure CopyToArray(aArray : TYPED_ARRAY);

    function  Size() : Integer;
    function  BasePointer() : pointer;
  end;

  //Make sure that the next time the file is included,
  //the implementation part is included
  {$DEFINE TEMPLATE_IMPLEMENTATION} 

{$ELSE}

const
  ARRAYEXPENSION = 3;

procedure TYPED_ARRAY.SetCount(const aCount : Integer);
begin
  SetLength( List, aCount);
  FCount := aCount;
end;

function  TYPED_ARRAY.CompareItems(const aItem1, aItem2 : TYPED_ARRAY_ITEM): boolean;
begin
  result := false;
end;

procedure TYPED_ARRAY.OnRemoveItem(var aItem : TYPED_ARRAY_ITEM);
begin
  //do nothing
end;

constructor TYPED_ARRAY.Create();
begin
  inherited Create();
  SetCount(0);
end;

destructor  TYPED_ARRAY.Destroy();
begin
  Clear();
  inherited Destroy();
end;

function TYPED_ARRAY.Add(const aItem : TYPED_ARRAY_ITEM ): integer;
var
  iArrayLength : integer;
begin
  iArrayLength := Length(List);
  FCount := FCount + 1;
  if FCount > iArrayLength then
    SetLength( List, iArrayLength+ARRAYEXPENSION);
  List[ FCount-1 ] := aItem;
  result := FCount-1;
end;

function TYPED_ARRAY.Get(const aIndex : Integer): TYPED_ARRAY_ITEM;
begin
  Assert( ((aIndex >= 0) and (aIndex < FCount)), 'Array out of bound!');
  result := TYPED_ARRAY_ITEM(List[ aIndex ]);
end;

procedure TYPED_ARRAY.RemoveIdx(const aIndex : Integer);
var
  iI : Integer;
begin
  Assert( ((aIndex >= 0) and (aIndex < FCount)), 'Array out of bound!' );
  OnRemoveItem(List[aIndex]);
  for iI := aIndex to FCount-2 do
    List[iI] := List[iI+1];
  Count := Count - 1;
end;

procedure TYPED_ARRAY.RemoveItm( const aItem : TYPED_ARRAY_ITEM );
var
  iI : Integer;
  iFound : boolean;
begin
  iI := -1;
  iFound := false;
  while (iI < FCount) and not(iFound) do
  begin
    iI := iI + 1;
    if (iI >= 0) and (iI < Length(List)) then
      if CompareItems(List[iI], aItem) then
        iFound := true;
  end;
  if iFound then
    RemoveIdx(iI)
end;

procedure TYPED_ARRAY.Clear();
var
  iI : integer;
begin
  for iI := 0 to High(List) do
    OnRemoveItem(List[iI]);
  SetCount(0)
end;

procedure TYPED_ARRAY.CopyToArray(aArray : TYPED_ARRAY);
begin
  aArray.Clear();
  aArray.FCount := FCount;
  aArray.List := Copy( List, 0, FCount );
end;

function TYPED_ARRAY.Size():Integer;
begin
   result := FCount * SizeOf(TYPED_ARRAY_ITEM)
end;

function  TYPED_ARRAY.BasePointer() : pointer;
begin
  result := @List[0];
end;

{$ENDIF}


