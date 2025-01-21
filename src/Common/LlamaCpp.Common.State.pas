unit LlamaCpp.Common.State;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON.Serializers;

type
  TLlamaState = class
  private
    FInputIds: TArray<Integer>;
    FScores: TArray<TArray<Single>>;
    FNTokens: Integer;
    FLlamaState: TArray<ShortInt>;
    FLlamaStateSize: Integer;
    FSeed: UInt32;
  public
    constructor Create(); overload;
    constructor Create(
      const AInputIds: TArray<Integer>;
      const AScores: TArray<TArray<Single>>;
      const ANTokens: Integer;
      const ALlamaState: TArray<ShortInt>;
      const ALlamaStateSize: Integer;
      const ASeed: UInt32
    ); overload;

    function GetSize(): Int64;
    function Clone(): TLlamaState;

    procedure Serialize(const AStream: TStream);
    procedure Deserialize(const AStream: TStream);

    function ToJsonString(): string;
    class function FromJsonString(const AJsonString: string): TLlamaState;

    property InputIds: TArray<Integer> read FInputIds write FInputIds;
    property Scores: TArray<TArray<Single>> read FScores write FScores;
    property NTokens: Integer read FNTokens write FNTokens;
    property LlamaState: TArray<ShortInt> read FLlamaState write FLlamaState;
    property LlamaStateSize: Integer read FLlamaStateSize write FLlamaStateSize;
    property Seed: UInt32 read FSeed write FSeed;
  end;

implementation

{ TLlamaState }

constructor TLlamaState.Create;
begin
  //
end;

constructor TLlamaState.Create(
  const AInputIds: TArray<Integer>;
  const AScores: TArray<TArray<Single>>;
  const ANTokens: Integer;
  const ALlamaState: TArray<ShortInt>;
  const ALlamaStateSize: Integer;
  const ASeed: UInt32);
begin
  inherited Create;
  FInputIds := AInputIds;
  FScores := AScores;
  FNTokens := ANTokens;
  FLlamaState := ALlamaState;
  FLlamaStateSize := ALlamaStateSize;
  FSeed := ASeed;
end;

function TLlamaState.GetSize: Int64;
var
  I: Integer;
begin
  Result := (Length(FInputIds) * SizeOf(integer))
          + (Length(FLlamaState) * SizeOf(ShortInt))
          + SizeOf(FNTokens)
          + SizeOf(FLlamaStateSize)
          + SizeOf(FSeed);

  for I := Low(FScores) to High(FScores) do
    Result := Result + Length(FScores[I]) * SizeOf(Single);

  Result := Result + (Length(FScores) * SizeOf(TArray<single>));
end;

function TLlamaState.Clone: TLlamaState;
begin
  Result := TLlamaState.Create(
    FInputIds,
    FScores,
    FNTokens,
    FLlamaState,
    FLlamaStateSize,
    FSeed
  );
end;

function TLlamaState.ToJsonString: string;
var
  LSerializer: TJsonSerializer;
begin
  LSerializer := TJSonSerializer.Create();
  try
    Result := LSerializer.Serialize<TLlamaState>(Self);
  finally
    LSerializer.Free();
  end;
end;

class function TLlamaState.FromJsonString(
  const AJsonString: string): TLlamaState;
var
  LSerializer: TJsonSerializer;
begin
  LSerializer := TJSonSerializer.Create();
  try
    Result := LSerializer.Deserialize<TLlamaState>(AJsonString);
  finally
    LSerializer.Free();
  end;
end;

procedure TLlamaState.Serialize(const AStream: TStream);
var
  I: Integer;
begin
  AStream.WriteData<integer>(FNTokens);
  AStream.WriteData<integer>(FLlamaStateSize);
  AStream.WriteData<UInt32>(FSeed);

  AStream.WriteData<integer>(Length(FInputIds));
  AStream.Write(FInputIds[0], Length(FInputIds) * SizeOf(integer));

  AStream.WriteData<integer>(Length(FLlamaState));
  AStream.Write(FLlamaState[0], Length(FLlamaState) * SizeOf(ShortInt));

  AStream.WriteData<integer>(Length(FScores));
  for I := Low(FScores) to High(FScores) do
  begin
    AStream.WriteData<integer>(Length(FScores[I]));
    AStream.Write(FScores[I][0], Length(FScores[I]) * SizeOf(Single));
  end;
end;

procedure TLlamaState.Deserialize(const AStream: TStream);
var
  LLength: Integer;
  I: Integer;
begin
  AStream.ReadData(FNTokens);
  AStream.ReadData(FLlamaStateSize);
  AStream.ReadData(FSeed);

  AStream.ReadData(LLength);
  SetLength(FInputIds, LLength);
  AStream.Read(FInputIds[0], LLength * SizeOf(integer));

  AStream.ReadData(LLength);
  SetLength(FLlamaState, LLength);
  AStream.Read(FLlamaState[0], LLength * SizeOf(ShortInt));

  AStream.ReadData(LLength);
  SetLength(FScores, LLength);
  for I := Low(FScores) to High(FScores) do
  begin
    AStream.ReadData(LLength);
    SetLength(FScores[I], LLength);
    AStream.Read(FScores[I][0], LLength * SizeOf(single));
  end;
end;

end.
