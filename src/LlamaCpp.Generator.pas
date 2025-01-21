unit LlamaCpp.Generator;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Types;

type
  TLlamaGenerator = class(TInterfacedObject, ILlamaGenerator)
  private
    FContext: TLlamaContext;
    FDraftModel: ILlamaDraftModel;
    FSampler: ILlamaSampler;
    FEvaluator: ILlamaEvaluator;
    [weak]
    FLlama: ILlama;
  public
    constructor Create(const ALlama: ILlama);

    procedure Generate(
            ATokens: TArray<integer>;
      const ASettings: TLlamaSamplerSettings;
      const ACallback: TGeneratorCallback;
      const AReset: boolean = true;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil);
  end;

implementation

uses
  System.Math,
  LlamaCpp.Common.Sampling.Sampler,
  LlamaCpp.Helper;

{ TLlamaGenerator }

constructor TLlamaGenerator.Create(const ALlama: ILlama);
begin
  FContext := ALlama.Context;
  FDraftModel := ALlama.DraftModel;
  FSampler := ALlama as ILlamaSampler;
  FEvaluator := ALlama as ILlamaEvaluator;
  FLlama := ALlama;
end;

procedure TLlamaGenerator.Generate(ATokens: TArray<integer>;
  const ASettings: TLlamaSamplerSettings; const ACallback: TGeneratorCallback;
  const AReset: boolean; const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
var
  I: integer;
  J: integer;
  LReset: boolean;
  LLongestPrefix: integer;
  LSampleIdx: integer;
  LTokens: TList<integer>;
  LToken: integer;
  LContinue: boolean;
  LInputIds: TArray<integer>;
  LScores: TArray<TArray<single>>;
  LTokensOrNone: TArray<integer>;
  LDraftTokens: TArray<integer>;
  LSampler: TLlamaSampler;
begin
  Assert(Assigned(ACallback), 'Param "ACallback" not assigned.');

  //FMirostatMu := 2.0 * ASettings.MirostatTau;
  LReset := AReset;
  LContinue := true;
  LInputIds := TInputIdHelper.InputId(FLlama.InputIds, FLlama.NumberOfTokens);
  LScores := TScoresHelper.Scores(FLlama.Scores, FLlama.NumberOfTokens);

  LSampler := TLlamaSampler.Create();
  try
    FSampler.InitSampler(
      LInputIds, ASettings, LSampler, ALogitsProcessor, AGrammar);

    if LReset and (FLlama.NumberOfTokens > 0) then
    begin
      LLongestPrefix := 0;
      for I := 0 to Min(High(LInputIds), High(ATokens) - 1) do
      begin
        if LInputIds[I] = ATokens[I] then
          Inc(LLongestPrefix)
        else
          Break;
      end;

      if LLongestPrefix > 0 then
      begin
        LReset := false;
        ATokens := TArrayHelper.Slice<integer>(ATokens, LLongestPrefix);
        FLlama.NumberOfTokens := LLongestPrefix;
      end;
    end;

    if LReset then
      FLlama.Reset();

    LSampleIdx := FLlama.NumberOfTokens + Length(ATokens) - 1;
    LTokens := TList<integer>.Create(ATokens);
    try
      while true do
      begin
        FEvaluator.Eval(LTokens.ToArray());

        while LSampleIdx < FLlama.NumberOfTokens do
        begin
          LToken := FSampler.Sample(FLlama.NumberOfTokens, ASettings, LSampler, LSampleIdx);
          Inc(LSampleIdx);

          if Assigned(AStoppingCriteria) then
          begin
            LInputIds := TInputIdHelper.InputId(FLlama.InputIds, FLlama.NumberOfTokens);
            if AStoppingCriteria.Execute(
                TArrayHelper.Slice<integer>(LInputIds, Low(LInputIds), LSampleIdx),
                LScores[LSampleIdx - FLlama.NumberOfTokens]
            ) then
              Exit;
          end;

          LTokensOrNone := ACallback(LToken, LContinue);

          if not LContinue then
            Exit;

          //SetLength(LTokensOrNone, 0);
          LTokens.Clear;
          LTokens.Add(LToken);

          if Assigned(LTokensOrNone) then
            LTokens.AddRange(LTokensOrNone);

          if (LSampleIdx < FLlama.NumberOfTokens) and (LToken <> LInputIds[LSampleIdx]) then
          begin
            FLlama.NumberOfTokens := LSampleIdx;
            FContext.KvCacheSeqRm(-1, FLlama.NumberOfTokens, -1);
            Break;
          end;
        end;

        if Assigned(FDraftModel) then
        begin
          J := 0;
          for I := FLlama.NumberOfTokens to FLlama.NumberOfTokens + LTokens.Count - 1 do
          begin
            FLlama.InputIds[I] := LTokens[J];
            Inc(J);
          end;

          LDraftTokens := FDraftModel.Execute(
            TArrayHelper.Slice<integer>(
              FLlama.InputIds, Low(FLlama.InputIds), FLlama.NumberOfTokens + LTokens.Count)
          );

          if Assigned(LDraftTokens) then
            LTokens.AddRange(
              TArrayHelper.Slice<integer>(
                LDraftTokens,
                Low(LDraftTokens),
                FContext.NCtx() - FLlama.NumberOfTokens - LTokens.Count
              )
            );
        end;
      end;
    finally
      LTokens.Free;
    end;
  finally
    LSampler.Free();
  end;
end;

end.
