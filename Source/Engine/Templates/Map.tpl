{$IFNDEF TEMPLATE_IMPLEMENTATION}

type
  TBucket = class
    Key: string;
    Item: TYPED_MAP_ITEM;
    Next: TBucket;
    Previous: TBucket;

    constructor Create();
    destructor  Destroy(); override;
  end;

  TYPED_MAP = class
  protected
    FStart : TBucket;
    FLast  : TBucket;
    FCur   : TBucket;
  private
    procedure OnRemoveItem(var aItem : TYPED_MAP_ITEM); virtual;
    function  GetBucket(const aKey: string): TBucket;
  public
    constructor Create();
    destructor  Destroy(); override;

    procedure Add(const aKey: string; const aItem : TYPED_MAP_ITEM);
    function  Get(const aKey: string): TYPED_MAP_ITEM;
    procedure Remove(const aKey: string);
    function  Exists(const aKey: string): boolean;
    procedure Clear();

    procedure Restart();
    function  Next(): boolean;
    function  Previous(): boolean;
    function  CurrentKey(): string;
  end;

  //Make sure that the next time the file is included,
  //the implementation part is included
  {$DEFINE TEMPLATE_IMPLEMENTATION} 

{$ELSE}

constructor TBucket.Create();
begin
  Key := '';
  Next := nil;
  Previous := nil;
end;

destructor TBucket.Destroy();
begin
  inherited;
end;

procedure TYPED_MAP.OnRemoveItem(var aItem : TYPED_MAP_ITEM);
begin
  //do nothing
end;

constructor TYPED_MAP.Create();
begin
  inherited Create;
  FStart := nil;
end;

destructor TYPED_MAP.Destroy();
begin
  Clear();
  inherited;
end;

procedure TYPED_MAP.Add(const aKey: string; const aItem : TYPED_MAP_ITEM);
var
  iBucket : TBucket;
begin
  Assert( Exists(aKey), 'Key already exists in the map!');

  iBucket := TBucket.Create();
  iBucket.Key := aKey;
  iBucket.Item := aItem;

  if FStart = nil then
  begin
    FStart := iBucket;
    FLast := FStart;
    exit;
  end
  else
  begin
    FLast.Next := iBucket;
    iBucket.Previous := FLast;
    FLast := iBucket;
  end;
end;

function TYPED_MAP.GetBucket(const aKey: string): TBucket;
begin
  Restart();
  while Next() do
  begin
    if CurrentKey() = aKey  then
    begin
      result := FCur;
      exit;
    end;
  end;
  Assert( true, 'Cannot find the key value!');
end;

function TYPED_MAP.Get(const aKey: string): TYPED_MAP_ITEM;
begin
 result := GetBucket(aKey).Item;
end;

procedure TYPED_MAP.Remove(const aKey: string);
var
  iBucket : TBucket;
begin
  iBucket := GetBucket(aKey);

  if (iBucket.Previous = nil) and (iBucket.Next <> nil) then
  begin
    FStart := iBucket.Next;
    FStart.Previous := nil;
  end
  else if (iBucket.Previous <> nil) and (iBucket.Next = nil) then
  begin
    FLast := iBucket.Previous;
    FLast.Next := nil;
  end
  else if (iBucket.Previous <> nil) and (iBucket.Next <> nil) then
  begin
    iBucket.Previous.Next := iBucket.Next;
    iBucket.Next.Previous := iBucket.Previous;
  end
  else if (iBucket.Previous = nil) and (iBucket.Next = nil) then
  begin
    FStart := nil;
    FLast  := nil;
  end;

  OnRemoveItem(iBucket.Item);
  FreeAndNil(iBucket);
end;

function TYPED_MAP.Exists(const aKey: string): boolean;
begin
  Restart();
  while Next() do
  begin
    if CurrentKey() = aKey  then
    begin
      result := true;
      exit;
    end;
  end;
  result := false;
end;

procedure TYPED_MAP.Clear();
begin
  Restart();
  while Previous() do
    Remove(CurrentKey());
end;

procedure TYPED_MAP.Restart();
begin
  FCur := nil;
end;

function TYPED_MAP.Next(): boolean;
begin
  result := true;
  if FCur <> nil then
  begin
    if FCur.Next <> nil then
    begin
      FCur := FCur.Next;
      exit;
    end;
  end
  else if FStart <> nil then
  begin
    FCur := FStart;
    exit;
  end;

  result := false;
end;

function TYPED_MAP.Previous(): boolean;
begin
  result := true;
  if FCur <> nil then
  begin
    if FCur.Previous <> nil then
    begin
      FCur := FCur.Previous;
      exit;
    end;
  end
  else if FLast <> nil then
  begin
    FCur := FLast;
    exit;
  end;

  result := false;
end;

function TYPED_MAP.CurrentKey(): string;
begin
  Result := FCur.Key;
end;

{$ENDIF}
