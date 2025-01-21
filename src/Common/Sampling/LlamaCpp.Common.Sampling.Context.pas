unit LlamaCpp.Common.Sampling.Context;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LLamaCpp.CType.Llama,
  LlamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Sampling.Params;

type
  TLlamaSamplingContext = class
  private
    FParams: TLlamaSamplingParams;
    FMirostatMu: Single;
    FGrammar: ILlamaGrammar;
    FPrev: TList<Int32>;
    FCur: TList<TLlamaTokenData>;
  public
    constructor Create;
    destructor Destroy; override;

    // Properties
    property Params: TLlamaSamplingParams read FParams write FParams;
    property MirostatMu: Single read FMirostatMu write FMirostatMu;
    property Grammar: ILlamaGrammar read FGrammar write FGrammar;
    property Prev: TList<Int32> read FPrev write FPrev;
    property Cur: TList<TLlamaTokenData> read FCur write FCur;

    // Methods
    procedure Reset;
    function Copy: TLlamaSamplingContext;
    function Last: Int32;
    function PrevStr(CtxMain: TLlamaContext; N: Int32): string;
    function Sample(const ACtxMain: TLlamaContext; const AIdx: Int32 = 0;
      ALogitsArray: TArray<Single> = nil): Int32;
    procedure Accept(ACtxMain: TLlamaContext; AId: Int32; AApplyGrammar: Boolean);
  end;

implementation

uses
  System.Math,
  LlamaCpp.Helper, LlamaCpp.Common.TokenArray;

type
  TListHelper = class helper for TList<Int32>
    function Skip(Count: Integer): TArray<Int32>;
  end;

{ TListHelper }

function TListHelper.Skip(Count: Integer): TArray<Int32>;
var
  LList: TList<Int32>;
  i: Integer;
begin
  LList := TList<Int32>.Create;
  try
    for i := Count to Self.Count - 1 do
      LList.Add(Self[i]);

    Result := LList.ToArray();
  finally
    LList.Free;
  end;
end;

{ TLlamaSamplingContext }

constructor TLlamaSamplingContext.Create;
begin
  inherited Create;
  FParams := TLlamaSamplingParams.Create;
  FMirostatMu := 0.0;
  FGrammar := nil;
  FPrev := TList<Int32>.Create;
  FCur := TList<TLlamaTokenData>.Create;
end;

destructor TLlamaSamplingContext.Destroy;
begin
  FParams.Free;
  FPrev.Free;
  FCur.Free;
  inherited Destroy;
end;

procedure TLlamaSamplingContext.Reset;
begin
  FPrev.Clear;
  FCur.Clear;
  if Assigned(FGrammar) then
    FGrammar.Reset;
end;

function TLlamaSamplingContext.Copy: TLlamaSamplingContext;
begin
  Result := TLlamaSamplingContext.Create;
  Result.Params := FParams;
  Result.MirostatMu := FMirostatMu;
  Result.Grammar := FGrammar;
  Result.Prev := TList<Int32>.Create(FPrev);
  Result.Cur := TList<TLlamaTokenData>.Create(FCur);
end;

function TLlamaSamplingContext.Last: Int32;
begin
  if FPrev.Count > 0 then
    Result := FPrev.Last
  else
    Result := -1;
end;

function TLlamaSamplingContext.PrevStr(CtxMain: TLlamaContext; N: Int32): string;
var
  Tokens: TArray<Int32>;
begin
  Tokens := FPrev.Skip(FPrev.Count - N);
  Result := TEncoding.UTF8.GetString(CtxMain.Model.Detokenize(Tokens));
end;

function TLlamaSamplingContext.Sample(const ACtxMain: TLlamaContext;
  const AIdx: Int32 = 0; ALogitsArray: TArray<Single> = nil): Int32;
var
  I: integer;
  LNVocab: integer;
  LLogits: PLogitArray;
  LLogitsArray: TArray<single>;
  LLogitPair: TPair<integer, single>;
  LTokenDataArray: TLlamaTokenDataArray;
  LNlToken: Integer;
  LNlLogit: Single;
  LLastTokens: TArray<integer>;
  LLastTokensSize: Integer;
  LMirostatM: Integer;
  LMinKeep: Integer;
begin
  LNVocab := ACtxMain.Model.NVocab();

  if not Assigned(ALogitsArray) then
  begin
    LLogits := ACtxMain.GetLogitsIth(AIdx);
    SetLength(LLogitsArray, SizeOf(single) * LNVocab);
    for I := Low(LLogitsArray) to High(LLogitsArray) do
      {$R-}
      LLogitsArray[I] := LLogits[I];
      {$R+}
  end;

  for LLogitPair in FParams.LogitBias do
  begin
    LLogitsArray[LLogitPair.Key] := LLogitsArray[LLogitPair.Key]
      + LLogitPair.Value;
  end;

  LTokenDataArray := TLlamaTokenDataArray.Create(LNVocab);
  try
    LTokenDataArray.CopyLogits(LLogitsArray);

    if FPrev.Count > 0 then
    begin
      LNlToken := ACtxMain.Model.TokenNL();
      LNlLogit := LLogitsArray[LNlToken];
      LLastTokens := TArrayHelper.Slice<integer>(FPrev.ToArray(), - FParams.PenaltyLastN);
      LLastTokensSize := Min(Length(LLastTokens), FParams.PenaltyLastN);

      if LLastTokensSize > 0 then
        ACtxMain.SampleRepetitionPenalties(
          LTokenDataArray,
          TLlamaTokenArray(LLastTokens[0]),
          LLastTokensSize,
          FParams.PenaltyRepeat,
          FParams.PenaltyFreq,
          FParams.PenaltyPresent
        );

      if not FParams.PenalizeNL then
        LTokenDataArray.CandidatesData[LNlToken].Logit := LNlLogit;
    end;

    if Assigned(FGrammar) then
      ACtxMain.SampleGrammar(LTokenDataArray, FGrammar);

    if FParams.Temp < 0 then
    begin
      ACtxMain.SampleSoftmax(LTokenDataArray);
      Result := LTokenDataArray.CandidatesData[0].Id;
    end
    else if FParams.Temp = 0 then
      Result := ACtxMain.SampleTokenGreedy(LTokenDataArray)
    else
    begin
      if FParams.Mirostat = 1 then
      begin
        LMirostatM := 100;
        ACtxMain.SampleTemp(LTokenDataArray, FParams.Temp);
        Result := ACtxMain.SampleTokenMirostat(
          LTokenDataArray,
          FParams.MirostatTau,
          FParams.MirostatEta,
          LMirostatM,
          @FMirostatMu
        );
      end
      else
      begin
        LMinKeep := Max(1, FParams.NProbs);
        ACtxMain.SampleTopK(LTokenDataArray, FParams.TopK, LMinKeep);
        ACtxMain.SampleTypical(LTokenDataArray, FParams.TypicalP, LMinKeep);
        ACtxMain.SampleTopP(LTokenDataArray, FParams.TopP, LMinKeep);
        ACtxMain.SampleMinP(LTokenDataArray, FParams.MinP, LMinKeep);
        ACtxMain.SampleTemp(LTokenDataArray, FParams.Temp);
        Result := ACtxMain.SampleToken(LTokenDataArray);
      end;
    end;
  finally
    LTokenDataArray.Free();
  end;
end;

procedure TLlamaSamplingContext.Accept(ACtxMain: TLlamaContext; AId: Int32; AApplyGrammar: Boolean);
begin
  if AApplyGrammar and Assigned(FGrammar) then
    ACtxMain.GrammarAcceptToken(FGrammar, AId);
  FPrev.Add(AId);
end;

end.
