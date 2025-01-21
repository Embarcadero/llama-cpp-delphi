unit LlamaCpp.Common.Cache.Base;

interface

uses
  LlamaCpp.Common.Types,
  LlamaCpp.Common.State;

type
  TBaseLlamaCache = class(TInterfacedObject, ILlamaCache)
  public
    CapacityBytes: Int64;
  protected
    function GetCacheSize: Int64; virtual; abstract;
    function FindLongestPrefixKey(const AKey: TArray<Integer>): TArray<integer>; virtual; abstract;
    function GetItem(const AKey: TArray<Integer>): TLlamaState;  virtual; abstract;
    function Contains(const AKey: TArray<Integer>): Boolean; virtual; abstract;
    procedure SetItem(const AKey: TArray<Integer>; const AValue: TLlamaState); virtual; abstract;
  protected
    function LongestTokenPrefix(const A, B: TArray<integer>): integer;
  public
    constructor Create(ACapacityBytes: Int64);
  end;

implementation

uses
  System.Math;

{ TBaseLlamaCache }

constructor TBaseLlamaCache.Create(ACapacityBytes: Int64);
begin
  inherited Create;
  CapacityBytes := ACapacityBytes;
end;

function TBaseLlamaCache.LongestTokenPrefix(const A,
  B: TArray<integer>): integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Min(Length(A), Length(B)) - 1 do
    if A[I] = B[I] then
      Inc(Result)
    else
      Break;
end;

end.
