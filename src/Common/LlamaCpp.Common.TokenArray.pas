unit LlamaCpp.Common.TokenArray;

interface

uses
  System.SysUtils,
  LlamaCpp.CType.Llama;

type
  TLlamaTokenDataArray = class
  private
    FCandidatesData: TArray<LlamaCpp.CType.Llama.TLlamaTokenData>;
    FCandidates: LlamaCpp.CType.Llama.TLlamaTokenDataArray;
    FDefaultCandidatesDataID: TArray<Int32>;
    FDefaultCandidatesDataP: TArray<Single>;
    FN_Vocab: Int32;
  public
    constructor Create(const ANVocab: Int32);

    procedure CopyLogits(const ALogits: TArray<Single>);
    property Candidates: LlamaCpp.CType.Llama.TLlamaTokenDataArray read FCandidates;
    property CandidatesData: TArray<LlamaCpp.CType.Llama.TLlamaTokenData> read FCandidatesData;
  end;

implementation

{ TLlamaTokenDataArray }

constructor TLlamaTokenDataArray.Create(const ANVocab: Int32);
var
  I: Int32;
begin
  FN_Vocab := ANVocab;

  SetLength(FCandidatesData, FN_Vocab);
  SetLength(FDefaultCandidatesDataID, FN_Vocab);
  SetLength(FDefaultCandidatesDataP, FN_Vocab);
  for I := 0 to FN_Vocab - 1 do
  begin
    FDefaultCandidatesDataID[I] := I;
    FDefaultCandidatesDataP[I] := 0.0;
  end;

  // Initialize TLlamaTokenDataArray
  FCandidates.Data := @FCandidatesData[0];
  FCandidates.Size := FN_Vocab;
  FCandidates.Sorted := False;
end;

procedure TLlamaTokenDataArray.CopyLogits(const ALogits: TArray<Single>);
var
  I: Int32;
begin
  Assert(Length(ALogits) = FN_Vocab, 'Logits size must match vocabulary size.');

  for I := 0 to FN_Vocab - 1 do
  begin
    FCandidatesData[I].ID := FDefaultCandidatesDataID[I];
    FCandidatesData[I].Logit := ALogits[I];
    FCandidatesData[I].P := FDefaultCandidatesDataP[I];
  end;

  FCandidates.Sorted := False;
  FCandidates.Size := FN_Vocab;
end;

end.
