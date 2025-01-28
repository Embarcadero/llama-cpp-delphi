unit LlamaCpp.Common.Cache.Ram;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Cache.Base,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.State;

type
  TLlamaRAMCache = class(TBaseLlamaCache)
  private
    const DEFAULT_CAPACITY = {$IFDEF WIN32}1_073_741_824{$ELSE}Int64(2) shl 30{$ENDIF WIN32};
  private
    FCache: TOrderedDictionary<TArray<Integer>, TLlamaState>;
  public
    constructor Create(ACapacityBytes: NativeInt = DEFAULT_CAPACITY);
    destructor Destroy; override;

    function GetCacheSize: Int64; override;
    function FindLongestPrefixKey(const AKey: TArray<Integer>): TArray<integer>; override;
    function GetItem(const AKey: TArray<Integer>): TLlamaState; override;
    function Contains(const AKey: TArray<Integer>): Boolean; override;
    procedure SetItem(const AKey: TArray<Integer>; const AValue: TLlamaState); override;
  end;

implementation

{ TLlamaRAMCache }

constructor TLlamaRAMCache.Create(ACapacityBytes: NativeInt);
begin
  inherited Create(ACapacityBytes);
  FCache := TOrderedDictionary<TArray<Integer>, TLlamaState>.Create();
end;

destructor TLlamaRAMCache.Destroy;
var
  I: Integer;
begin
  for I := 0 to FCache.Values.Count - 1 do
    FCache.ValueList[I].Free();

  FCache.Free;
  inherited;
end;

function TLlamaRAMCache.GetCacheSize: Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FCache.Count - 1 do
    Result := Result + FCache.ValueList[I].GetSize();
end;

function TLlamaRAMCache.FindLongestPrefixKey(const AKey: TArray<Integer>): TArray<integer>;
var
  LPrefixLen: Integer;
  LMaxPrefixLen: Integer;
  LCachedItem: TPair<TArray<integer>, TLlamaState>;
begin
  LMaxPrefixLen := 0;

  for LCachedItem in FCache do
  begin
    LPrefixLen := LongestTokenPrefix(LCachedItem.Key, AKey);
    if LPrefixLen > LMaxPrefixLen then
    begin
      LMaxPrefixLen := LPrefixLen;
      Result := LCachedItem.Key;
    end;
  end;
end;

function TLlamaRAMCache.Contains(const AKey: TArray<Integer>): Boolean;
begin
  Result := Assigned(FindLongestPrefixKey(AKey));
end;

function TLlamaRAMCache.GetItem(const AKey: TArray<Integer>): TLlamaState;
var
  LFoundKey: TArray<integer>;
begin
  LFoundKey := FindLongestPrefixKey(AKey);

  if not Assigned(LFoundKey) then
    raise Exception.Create('Key not found');

  Result := FCache[LFoundKey];

  FCache.Remove(LFoundKey);
end;

procedure TLlamaRAMCache.SetItem(const AKey: TArray<Integer>;
  const AValue: TLlamaState);
begin
  FCache.AddOrSetValue(AKey, AValue.Clone());

  while (GetCacheSize() > CapacityBytes) do
  begin
    FCache.ValueList[0].Free();
    FCache.Remove(FCache.KeyList[0]);
  end;
end;

end.
