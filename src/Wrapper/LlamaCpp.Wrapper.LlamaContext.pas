unit LlamaCpp.Wrapper.LlamaContext;

interface

uses
  System.SysUtils,
  LlamaCpp.CType.Llama,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Wrapper.LlamaBatch,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.TokenArray;

type
  TLlamaContext = class
  private
    FModel: TLlamaModel;
    FParams: TLlamaContextParams;
    FContext: PLlamaContext;
  public
    constructor Create(const AModel: TLlamaModel;
      const AParams: TLlamaContextParams);
    destructor Destroy(); override;

    procedure LoadContext();
    procedure UnloadContext();

    function NCtx(): integer;
    function PoolingType(): TLlamaPoolingType;
    procedure KVCacheClear();
    procedure KVCacheSeqRm(const ASeqID, AP0, AP1: Integer);
    procedure KVCacheSeqCp(const ASeqIDSrc, ASeqIDDst, AP0, AP1: Integer);
    procedure KVCacheSeqKeep(const ASeqID: Integer);
    procedure KVCacheSeqShift(const ASeqID, AP0, AP1, AShift: Integer);
    function GetStateSize(): Integer;
    procedure Decode(const ABatch: TLlamaBatch);
    procedure SetNThreads(const ANThreads, ANThreadsBatch: Integer);
    function GetLogits: PLogitArray;
    function GetLogitsIth(const AI: Integer): PLogitArray;
    function GetEmbeddings: PEmbdArray;

    // Sampling functions
    procedure SetRngSeed(const ASeed: Integer);
    procedure SampleRepetitionPenalties(const ACandidates: TLlamaTokenDataArray;
      const ALastTokensData: TLlamaTokenArray; const APenaltyLastN: Integer;
      const APenaltyRepeat, APenaltyFreq, APenaltyPresent: Single);
    procedure SampleSoftmax(const ACandidates: TLlamaTokenDataArray);
    procedure SampleTopK(const ACandidates: TLlamaTokenDataArray;
      const AK: Integer; const AMinKeep: Integer);
    procedure SampleTopP(const ACandidates: TLlamaTokenDataArray;
      const AP: Single; const AMinKeep: Integer);
    procedure SampleMinP(const ACandidates: TLlamaTokenDataArray;
      const AP: Single; const AMinKeep: Integer);
    procedure SampleTypical(const ACandidates: TLlamaTokenDataArray;
      const AP: Single; const AMinKeep: Integer);
    procedure SampleTemp(const ACandidates: TLlamaTokenDataArray;
      const ATemp: Single);
    procedure SampleGrammar(const ACandidates: TLlamaTokenDataArray;
      const AGrammar: ILlamaGrammar);
    function SampleTokenMirostat(const ACandidates: TLlamaTokenDataArray;
      const ATau, AEta: Single; const AM: Integer; const AMu: Pointer): Integer;
    function SampleTokenMirostatV2(const ACandidates: TLlamaTokenDataArray;
      const ATau, AEta: Single; const AMu: Pointer): Integer;
    function SampleTokenGreedy(const ACandidates: TLlamaTokenDataArray)
      : Integer;
    function SampleToken(const ACandidates: TLlamaTokenDataArray): Integer;

    // Grammar
    procedure GrammarAcceptToken(const AGrammar: ILlamaGrammar; const AToken: Integer);
    procedure ResetTimings();
    procedure PrintTimings();
  public
    class function DefaultParams(): TLlamaContextParams;
  public
    property Context: PLlamaContext read FContext;
    property Model: TLlamaModel read FModel;
  end;

implementation

uses
  System.IOUtils,
  LlamaCpp.Api.Llama;

{ TLlamaContext }

constructor TLlamaContext.Create(const AModel: TLlamaModel;
  const AParams: TLlamaContextParams);
begin
  FModel := AModel;
  FParams := AParams;
end;

destructor TLlamaContext.Destroy;
begin
  inherited;
end;

procedure TLlamaContext.LoadContext;
begin
  FContext := TLlamaApi.Instance.llama_new_context_with_model
    (FModel.Model, FParams);

  if not Assigned(FContext) then
    raise Exception.Create('Failed to create llama_context');
end;

procedure TLlamaContext.UnloadContext;
begin
  if Assigned(FContext) then
    TLlamaApi.Instance.llama_free(FContext);

  FContext := nil;
end;

function TLlamaContext.NCtx: integer;
begin
  Result := TLlamaApi.Instance.llama_n_ctx(FContext);
end;

function TLlamaContext.PoolingType: TLlamaPoolingType;
begin
  Result := TLlamaApi.Instance.llama_pooling_type(FContext);
end;

procedure TLlamaContext.KVCacheClear;
begin
  TLlamaApi.Instance.llama_kv_cache_clear(FContext);
end;

procedure TLlamaContext.KVCacheSeqRm(const ASeqID, AP0, AP1: Integer);
begin
  TLlamaApi.Instance.llama_kv_cache_seq_rm(FContext, ASeqID, AP0, AP1);
end;

procedure TLlamaContext.KVCacheSeqCp(const ASeqIDSrc, ASeqIDDst, AP0,
  AP1: Integer);
begin
  TLlamaApi.Instance.llama_kv_cache_seq_cp(FContext, ASeqIDSrc, ASeqIDDst,
    AP0, AP1);
end;

procedure TLlamaContext.KVCacheSeqKeep(const ASeqID: Integer);
begin
  TLlamaApi.Instance.llama_kv_cache_seq_keep(FContext, ASeqID);
end;

procedure TLlamaContext.KVCacheSeqShift(const ASeqID, AP0, AP1,
  AShift: Integer);
begin
  TLlamaApi.Instance.llama_kv_cache_seq_add(FContext, ASeqID, AP0, AP1, AShift);
end;

function TLlamaContext.GetStateSize: Integer;
begin
  Result := TLlamaApi.Instance.llama_get_state_size(FContext);
end;

procedure TLlamaContext.Decode(const ABatch: TLlamaBatch);
var
  ReturnCode: Integer;
begin
  ReturnCode := TLlamaApi.Instance.llama_decode(FContext, ABatch.Batch);

  if ReturnCode <> 0 then
    raise Exception.CreateFmt('llama_decode returned %d', [ReturnCode]);
end;

procedure TLlamaContext.SetNThreads(const ANThreads, ANThreadsBatch: Integer);
begin
  TLlamaApi.Instance.llama_set_n_threads(FContext, ANThreads, ANThreadsBatch);
end;

function TLlamaContext.GetLogits: PLogitArray;
begin
  Result := TLlamaApi.Instance.llama_get_logits(FContext);
end;

function TLlamaContext.GetLogitsIth(const AI: Integer): PLogitArray;
begin
  Result := TLlamaApi.Instance.llama_get_logits_ith(FContext, AI);
end;

function TLlamaContext.GetEmbeddings: PEmbdArray;
begin
  Result := TLlamaApi.Instance.llama_get_embeddings(FContext);
end;

procedure TLlamaContext.SetRngSeed(const ASeed: Integer);
begin
  raise Exception.Create('Not implemented');
  //TLlamaApi.Instance.llama_set_rng_seed(FContext, ASeed);
end;

procedure TLlamaContext.SampleRepetitionPenalties(const ACandidates
  : TLlamaTokenDataArray; const ALastTokensData: TLlamaTokenArray;
  const APenaltyLastN: Integer; const APenaltyRepeat, APenaltyFreq,
  APenaltyPresent: Single);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_repetition_penalties(
  // FContext,
  // TLlamaApi.byref(ACandidates.Candidates),
  // ALastTokensData,
  // APenaltyLastN,
  // APenaltyRepeat,
  // APenaltyFreq,
  // APenaltyPresent
  // );
end;

procedure TLlamaContext.SampleSoftmax(const ACandidates: TLlamaTokenDataArray);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_softmax(FContext, TLlamaApi.byref(ACandidates.Candidates));
end;

procedure TLlamaContext.SampleTopK(const ACandidates: TLlamaTokenDataArray;
  const AK: Integer; const AMinKeep: Integer);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_top_k(FContext, TLlamaApi.byref(ACandidates.Candidates), AK, AMinKeep);
end;

procedure TLlamaContext.SampleTopP(const ACandidates: TLlamaTokenDataArray;
  const AP: Single; const AMinKeep: Integer);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_top_p(FContext, TLlamaApi.byref(ACandidates.Candidates), AP, AMinKeep);
end;

procedure TLlamaContext.SampleMinP(const ACandidates: TLlamaTokenDataArray;
  const AP: Single; const AMinKeep: Integer);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_min_p(FContext, TLlamaApi.byref(ACandidates.Candidates), AP, AMinKeep);
end;

procedure TLlamaContext.SampleTypical(const ACandidates: TLlamaTokenDataArray;
  const AP: Single; const AMinKeep: Integer);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_typical(FContext, TLlamaApi.byref(ACandidates.Candidates), AP, AMinKeep);
end;

procedure TLlamaContext.SampleTemp(const ACandidates: TLlamaTokenDataArray;
  const ATemp: Single);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_temp(FContext, TLlamaApi.byref(ACandidates.Candidates), ATemp);
end;

procedure TLlamaContext.SampleGrammar(const ACandidates: TLlamaTokenDataArray;
  const AGrammar: ILlamaGrammar);
begin
  raise Exception.Create('Not implemented');
  // TLlamaApi.Instance.llama_sample_grammar(FContext, TLlamaApi.byref(ACandidates.Candidates), AGrammar.Grammar);
end;

function TLlamaContext.SampleTokenMirostat(const ACandidates
  : TLlamaTokenDataArray; const ATau, AEta: Single; const AM: Integer;
  const AMu: Pointer): Integer;
begin
  raise Exception.Create('Not implemented');
  // Result := TLlamaApi.Instance.llama_sample_token_mirostat(FContext,
  // TLlamaApi.byref(ACandidates.Candidates), ATau, AEta, AM, AMu);
end;

function TLlamaContext.SampleTokenMirostatV2(const ACandidates
  : TLlamaTokenDataArray; const ATau, AEta: Single; const AMu: Pointer)
  : Integer;
begin
  raise Exception.Create('Not implemented');
  // Result := TLlamaApi.Instance.llama_sample_token_mirostat_v2(FContext,
  // TLlamaApi.byref(ACandidates.Candidates), ATau, AEta, AMu);
end;

function TLlamaContext.SampleTokenGreedy(const ACandidates
  : TLlamaTokenDataArray): Integer;
begin
  raise Exception.Create('Not implemented');
  // Result := TLlamaApi.Instance.llama_sample_token_greedy(FContext,
  // TLlamaApi.byref(ACandidates.Candidates));
end;

function TLlamaContext.SampleToken(const ACandidates
  : TLlamaTokenDataArray): Integer;
begin
  raise Exception.Create('Not implemented');
  // Result := TLlamaApi.Instance.llama_sample_token(FContext,
  // TLlamaApi.byref(ACandidates.Candidates));
end;

procedure TLlamaContext.GrammarAcceptToken(const AGrammar: ILlamaGrammar; const AToken: Integer);
begin
  raise Exception.Create('Not implemented');
//  TLlamaApi.Instance.llama_grammar_accept_token(AGrammar.Grammar, FContext, AToken);
end;

procedure TLlamaContext.ResetTimings;
begin
  TLlamaApi.Instance.llama_perf_context_reset(FContext);
end;

procedure TLlamaContext.PrintTimings;
begin
  TLlamaApi.Instance.llama_perf_context_print(FContext);
end;

class function TLlamaContext.DefaultParams: TLlamaContextParams;
begin
  Result := TLlamaApi.Instance.llama_context_default_params();
end;

end.
