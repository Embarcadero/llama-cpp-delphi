unit LlamaCpp.Common.Sampling.Sampler;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  LlamaCpp.CType.Llama,
  LLamaCpp.Wrapper.LlamaModel,
  LLamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Sampling.CustomSampler;

type
  TLlamaSampler = class
  private
    FSampler: PLlamaSampler; // Pointer to the llama sampler chain
    FSamplers: TList<PLlamaSampler>;
    FCustomSamplers: TList<TPair<Integer, TCustomSampler>>;

    procedure AddSampler(Sampler: PLlamaSampler);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddGreedy;
    procedure AddDist(Seed: UInt32);
    procedure AddSoftmax;
    procedure AddTopK(K: Integer);
    procedure AddTopP(P: Single; MinKeep: Integer);
    procedure AddMinP(P: Single; MinKeep: Integer);
    procedure AddTypical(P: Single; MinKeep: Integer);
    procedure AddTemp(Temp: Single);
    procedure AddTempExt(T, Delta, Exponent: Single);
    procedure AddMirostat(NVocab, Seed: Integer; Tau, Eta: Single; M: Integer);
    procedure AddMirostatV2(Seed: Integer; Tau, Eta: Single);
    procedure AddGrammar(Model: TLlamaModel; Grammar: ILlamaGrammar);
    procedure AddPenalties(
      NVocab, SpecialEOSID, LinefeedID, PenaltyLastN: Integer;
      PenaltyRepeat, PenaltyFreq, PenaltyPresent: Single;
      PenalizeNL, IgnoreEOS: Boolean);
    procedure InitLogitBias(
      NVocab, NLogitBias: Integer; LogitBias: PLlamaLogitBias);
    procedure AddCustom(ApplyFunc: TApplyFunc);

    function GetSeed: Integer;
    function Sample(ACtx: TLlamaContext; AIdx: Integer): Integer;
    procedure Close;
  end;

implementation

uses
  LlamaCpp.Api.Llama;

constructor TLlamaSampler.Create;
var
  LParams: TLlamaSamplerChainParams;
begin
  inherited Create;
  LParams := Default(TLlamaSamplerChainParams);
  FSampler := TLlamaApi.Instance.llama_sampler_chain_init(@LParams);
  FSamplers := TList<PLlamaSampler>.Create;
  FCustomSamplers := TList<TPair<Integer, TCustomSampler>>.Create;
end;

destructor TLlamaSampler.Destroy;
begin
  Close;
  FSamplers.Free;
  FCustomSamplers.Free;
  inherited Destroy;
end;

procedure TLlamaSampler.AddGreedy;
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_greedy();
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddDist(Seed: UInt32);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_dist(Seed);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddSoftmax;
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_softmax();
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddTopK(K: Integer);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_top_k(K);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddTopP(P: Single; MinKeep: Integer);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_top_p(P, MinKeep);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddMinP(P: Single; MinKeep: Integer);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_min_p(P, MinKeep);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddTypical(P: Single; MinKeep: Integer);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_typical(P, MinKeep);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddTemp(Temp: Single);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_temp(Temp);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddTempExt(T, Delta, Exponent: Single);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_temp_ext(T, Delta, Exponent);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddMirostat(NVocab, Seed: Integer; Tau, Eta: Single; M: Integer);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_mirostat(NVocab, Seed, Tau, Eta, M);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddMirostatV2(Seed: Integer; Tau, Eta: Single);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_mirostat_v2(Seed, Tau, Eta);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddGrammar(Model: TLlamaModel; Grammar: ILlamaGrammar);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_grammar(
    Model.Model,
    PAnsiChar(UTF8Encode(Grammar.Grammar)),
    PAnsiChar(UTF8Encode(Grammar.Root))
  );
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddPenalties(
  NVocab, SpecialEOSID, LinefeedID, PenaltyLastN: Integer;
  PenaltyRepeat, PenaltyFreq, PenaltyPresent: Single;
  PenalizeNL, IgnoreEOS: Boolean);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_penalties(
    NVocab, SpecialEOSID, LinefeedID, PenaltyLastN,
    PenaltyRepeat, PenaltyFreq, PenaltyPresent,
    PenalizeNL, IgnoreEOS);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.InitLogitBias(
  NVocab, NLogitBias: Integer; LogitBias: PLlamaLogitBias);
var
  Sampler: PLlamaSampler;
begin
  Sampler := TLlamaApi.Instance.llama_sampler_init_logit_bias(NVocab, NLogitBias, LogitBias);
  AddSampler(Sampler);
end;

procedure TLlamaSampler.AddCustom(ApplyFunc: TApplyFunc);
var
  LCustomSampler: TCustomSampler;
begin
  LCustomSampler := TCustomSampler.Create(ApplyFunc);
  try
    AddSampler(LCustomSampler.GetSampler());
    FCustomSamplers.Add(TPair<Integer, TCustomSampler>.Create(
      TLlamaApi.Instance.llama_sampler_chain_n(FSampler) - 1, LCustomSampler));
  except
    on E: Exception do
    begin
      LCustomSampler.Free();
      raise;
    end;
  end;
end;

procedure TLlamaSampler.AddSampler(Sampler: PLlamaSampler);
begin
  Assert(FSampler <> nil);
  TLlamaApi.Instance.llama_sampler_chain_add(FSampler, Sampler);
  FSamplers.Add(Sampler);
end;

function TLlamaSampler.GetSeed: Integer;
begin
  Assert(FSampler <> nil);
  Result := TLlamaApi.Instance.llama_sampler_get_seed(FSampler);
end;

function TLlamaSampler.Sample(ACtx: TLlamaContext; AIdx: Integer): Integer;
begin
  Assert(FSampler <> nil);
  Result := TLlamaApi.Instance.llama_sampler_sample(FSampler, ACtx.Context, AIdx);
end;

procedure TLlamaSampler.Close;
var
  LPair: TPair<Integer, TCustomSampler>;
begin
  if FSampler <> nil then
  begin
    for LPair in FCustomSamplers do
    begin
      TLlamaApi.Instance.llama_sampler_chain_remove(FSampler, LPair.Key);
      LPair.Value.Free();
    end;

    TLlamaApi.Instance.llama_sampler_free(FSampler);
    FSampler := nil;
  end;
  FSamplers.Clear;
  FCustomSamplers.Clear;
end;

end.
