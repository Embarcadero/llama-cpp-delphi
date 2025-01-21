unit LlamaCpp.Sampler;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Types,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Sampling.Sampler;

type
  TLlamaSampler = class(TInterfacedObject, ILlamaSampler)
  private
    FSettings: TLlamaSettings;
    FModel: TLlamaModel;
    FContext: TLlamaContext;
  public
    constructor Create(const ALlama: ILlama);

    procedure InitSampler(
      const AInputIds: TArray<integer>;
      const ASettings: TLlamaSamplerSettings;
      const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
      const ALogitsProcessor: ILogitsProcessorList;
      const AGrammar: ILlamaGrammar);

    function Sample(
      const ANumberOfTokens: integer;
      const ASettings: TLlamaSamplerSettings;
      const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
      const AIdx: integer = -1): integer;
  end;

implementation

uses
  System.Math,
  LlamaCpp.CType.Llama;

{ TLlamaSampler }

constructor TLlamaSampler.Create(const ALlama: ILlama);
begin
  FModel := ALlama.Model;
  FContext := ALlama.Context;
  FSettings := ALlama.Settings;
end;

procedure TLlamaSampler.InitSampler(const AInputIds: TArray<integer>;
  const ASettings: TLlamaSamplerSettings;
  const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
var
  NProbs: integer;
  MinKeep: integer;
begin
  if Assigned(ALogitsProcessor) then
    ASampler.AddCustom(
      procedure(const ATokenDataArray: PLlamaTokenDataArray)
      var
        I: Integer;
        LSize: integer;
        LDataSOA: PLlamaTokenData;
        LLogits: TList<single>;
        LCustomLogits: TArray<single>;
      begin
        LSize := ATokenDataArray.Size;

        LLogits := TList<single>.Create();
        try
          LDataSOA := ATokenDataArray.Data;
          for I := 0 to LSize - 1 do
          begin
            LLogits.Add(LDataSOA^.logit);
            Inc(LDataSOA);
          end;

          LCustomLogits := LLogits.ToArray();
        finally
          LLogits.Free();
        end;

        ALogitsProcessor.Execute(AInputIds, LCustomLogits);

        LDataSOA := ATokenDataArray.Data;
        for I := 0 to Min(LSize, Length(LCustomLogits)) - 1 do
        begin
          LDataSOA^.logit := LCustomLogits[I];
          Inc(LDataSOA);
        end;
      end);

  ASampler.AddPenalties(
    FModel.NVocab, FModel.TokenEOS, FModel.TokenNL, FSettings.LastNTokensSize,
    ASettings.RepeatPenalty, ASettings.FrequencyPenalty,
    ASettings.PresencePenalty, ASettings.PenalizeNL, false);

  if Assigned(AGrammar) then
    ASampler.AddGrammar(FModel, AGrammar);

  if ASettings.Temp < 0.0 then
  begin
    ASampler.AddSoftmax;
    ASampler.AddDist(FSettings.Seed);
  end
  else if ASettings.Temp = 0.0 then
  begin
    ASampler.AddGreedy;
  end
  else
  begin
    if ASettings.MirostatMode = 1 then
    begin
      ASampler.AddMirostat(FModel.NVocab, FSettings.Seed, ASettings.MirostatTau,
        ASettings.MirostatEta, 100);
    end
    else if ASettings.MirostatMode = 2 then
    begin
      ASampler.AddMirostatV2(FSettings.Seed, ASettings.MirostatTau,
        ASettings.MirostatEta);
    end
    else
    begin
      NProbs := 0;
      MinKeep := Max(1, NProbs);
      ASampler.AddTopK(ASettings.TopK);
      ASampler.AddTypical(ASettings.TypicalP, MinKeep);
      ASampler.AddTopP(ASettings.TopP, MinKeep);
      ASampler.AddMinP(ASettings.MinP, MinKeep);
      ASampler.AddTemp(ASettings.Temp);
      ASampler.AddDist(FSettings.Seed);
    end;
  end;
end;

function TLlamaSampler.Sample(const ANumberOfTokens: integer;
  const ASettings: TLlamaSamplerSettings;
  const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
  const AIdx: integer): integer;
var
  LIdx: integer;
begin
  Assert(ANumberOfTokens > 0, 'No tokens available for sampling.');

  if AIdx >= 0 then
    LIdx := AIdx - ANumberOfTokens
  else
    LIdx := -1;

  Assert(Assigned(FContext), 'Context is not initialized.');

  Result := ASampler.Sample(FContext, LIdx);
end;

end.
