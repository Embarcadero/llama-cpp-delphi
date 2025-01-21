unit LlamaCpp.Embedding;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Api.Llama,
  LlamaCpp.CType.Llama,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Wrapper.LlamaBatch,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Types;

type
  TLlamaEmbedding = class(TInterfacedObject, ILlamaEmbedding)
  private
    FModel: TLlamaModel;
    FContext: TLlamaContext;
    FBatch: TLlamaBatch;
    FSettings: TLlamaSettings;
    FModelPath: string;
    FTokenization: ILlamaTokenization;
    [weak]
    FLlama: ILlama;
  private
    procedure DecodeBatch(const ASeqSizes: TArray<integer>;
      const ANormalize: boolean; const AData: TList<TArray<Single>>);
  public
    constructor Create(const ALlama: ILlama);

    function Embed(
      const AInput: TArray<string>;
        out AReturnCount: integer;
      const ANormalize: boolean = false;
      const ATruncate: boolean = true)
      : TArray<TArray<Single>>;
    function CreateEmbedding(const AInput: TArray<string>;
      AModelName: string = '')
      : TCreateEmbeddingResponse;
  end;

implementation

uses
  LlamaCpp.Helper;

{ TLlamaEmbedding }

constructor TLlamaEmbedding.Create(const ALlama: ILlama);
begin
  FModel := ALlama.Model;
  FContext := ALlama.Context;
  FBatch := ALlama.Batch;
  FSettings := ALlama.Settings;
  FModelPath := ALlama.ModelPath;
  FTokenization := ALlama as ILlamaTokenization;
  FLlama := ALlama;
end;

procedure TLlamaEmbedding.DecodeBatch(const ASeqSizes: TArray<integer>;
  const ANormalize: boolean; const AData: TList<TArray<Single>>);
var
  LPos: integer;
  LSize: integer;
  I: integer;
  J: integer;
  K: integer;
  LPtr: PEmbdArray;
  LEmbeddingsList: TList<TArray<single>>;
  LEmbeddings: TList<Single>;
begin
  TLlamaApi.Instance.llama_kv_cache_clear(FContext.Context);
  FContext.decode(FBatch);
  FBatch.Reset();

  LEmbeddingsList := TList<TArray<single>>.Create();
  try
    LEmbeddings := TList<Single>.Create();
    try

      if FContext.PoolingType() = TLlamaPoolingType.LLAMA_POOLING_TYPE_NONE then
      begin
        LPos := 0;

        for I := Low(ASeqSizes) to High(ASeqSizes) do
        begin
          LSize := ASeqSizes[I];
          LPtr := TLlamaApi.Instance.llama_get_embeddings(FContext.Context);

          for J := 0 to LSize - 1 do
          begin

            {$R-}
            for K := LPos + J * FModel.NEmb to LPos + (j + 1) * FModel.NEmb do
              LEmbeddings.Add(LPtr^[K]);
            {$R+}

            if ANormalize then
              LEmbeddingsList.Add(TEmbedding.Normalize(LEmbeddings.ToArray()))
            else
              LEmbeddingsList.Add(LEmbeddings.ToArray());

            LEmbeddings.Clear();
          end;

          AData.AddRange(LEmbeddingsList.ToArray());
          LEmbeddingsList.Clear();

          LPos := LPos + LSize;
        end;
      end
      else
      begin
        for I := Low(ASeqSizes) to High(ASeqSizes) do
        begin
          LPtr := TLlamaApi.Instance.llama_get_embeddings_seq(
            FContext.Context, I);

          {$R-}
          for J := 0 to FModel.NEmb do
            LEmbeddings.Add(LPtr^[J]);
          {$R+}

          if ANormalize then
            AData.Add(TEmbedding.Normalize(LEmbeddings.ToArray()))
          else
            AData.Add(LEmbeddings.ToArray());

          LEmbeddings.Clear();
        end;
      end;
    finally
      LEmbeddings.Free();
    end;
  finally
    LEmbeddingsList.Free();
  end;
end;

function TLlamaEmbedding.Embed(const AInput: TArray<string>;
  out AReturnCount: integer; const ANormalize,
  ATruncate: boolean): TArray<TArray<Single>>;
var
  LNBatch: integer;
  LTokens: TArray<integer>;
  LLogitsAll: boolean;
  LData: TList<TArray<Single>>;
  LNTokens: integer;
  LSBatch: TArray<integer>;
  LTBatch: integer;
  LPBatch: integer;
  I: integer;
begin
  LNBatch := FSettings.NBatch;
  LLogitsAll := FContext.PoolingType() = TLlamaPoolingType.LLAMA_POOLING_TYPE_NONE;

  if not FSettings.Embeddings then
    raise Exception.Create
      ('Llama model must be created with embedding=True to call this method');

  if FSettings.Verbose then
    TLlamaApi.Instance.llama_perf_context_reset(FContext.Context);

  FBatch.Reset();
  AReturnCount := 0;
  SetLength(LSBatch, 0);
  LTBatch := 0;
  LPBatch := 0;

  LData := TList <TArray<Single>>.Create();
  try
    for I := Low(AInput) to High(AInput) do
    begin
      LTokens := FTokenization.Encode(AInput[I], true, false);
      if ATruncate and (Length(LTokens) > LNBatch) then
        SetLength(LTokens, LNBatch);

      LNTokens := Length(LTokens);
      AReturnCount := AReturnCount + LNTokens;

      if LNTokens > LNBatch then
        raise Exception.CreateFmt
          ('Requested tokens (%d) exceed batch size of %d',
          [LNTokens, LNBatch]);

      if LTBatch + LNTokens > LNBatch then
      begin
        DecodeBatch(LSBatch, ANormalize, LData);
        SetLength(LSBatch, 0);
        LTBatch := 0;
        LPBatch := 0;
      end;

      FBatch.AddSequence(LTokens, LPBatch, LLogitsAll);

      SetLength(LSBatch, Length(LSBatch) + 1);
      LSBatch[High(LSBatch)] := LNTokens;
      LTBatch := LTBatch + LNTokens;
      LPBatch := LPBatch + 1;
    end;

    DecodeBatch(LSBatch, ANormalize, LData);

    if FSettings.Verbose then
      TLlamaApi.Instance.llama_perf_context_print(FContext.Context);

    Result := LData.ToArray();

    TLlamaApi.Instance.llama_kv_cache_clear(FContext.Context);

    FLlama.Reset();
  finally
    LData.Free();
  end;
end;

function TLlamaEmbedding.CreateEmbedding(const AInput: TArray<string>;
  AModelName: string): TCreateEmbeddingResponse;
var
  LTotalTokens: integer;
  LEmbeddings: TArray<TArray<Single>>;
begin
  if AModelName.IsEmpty() then
    AModelName := FModelPath;

  LEmbeddings := Embed(AInput, LTotalTokens);

  Result := TCreateEmbeddingResponse.Create(
    AModelName, LEmbeddings, LTotalTokens);
end;

end.
