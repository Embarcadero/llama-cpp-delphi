unit LlamaCpp.Llama;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  System.Math,
  System.Variants,
  System.Generics.Defaults,
  System.Generics.Collections,
  LlamaCpp.CType.Llama,
  LlamaCpp.CType.Ggml,
  LlamaCpp.CType.Ggml.Cpu,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Wrapper.LlamaBatch,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.State,
  LlamaCpp.Common.Tokenizer,
  LlamaCpp.Common.TokenArray,
  LlamaCpp.Common.Cache.Ram,
  LlamaCpp.Common.Cache.Disk,
  LlamaCpp.Common.Speculative.LookupDecoding,
  LlamaCpp.Common.Grammar,
  LlamaCpp.Common.Chat.Format,
  LlamaCpp.Common.Processor.LogitsScore,
  LlamaCpp.Common.Processor.StoppingCriteria,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Sampling.Sampler,
  LlamaCpp.Types, System.Types;

type
  // Settings
  TLlamaSettings = LlamaCpp.Common.Settings.TLlamaSettings;
  TLlamaSamplerSettings = LlamaCpp.Common.Settings.TLlamaSamplerSettings;
  TLlamaCompletionSettings = LlamaCpp.Common.Settings.TLlamaCompletionSettings;
  TLlamaChatCompletionSettings = LlamaCpp.Common.Settings.TLlamaChatCompletionSettings;
  // Processors
  TDefaultLogitsScoreList = LlamaCpp.Common.Processor.LogitsScore.TDefaultLogitsScoreList;
  TDefaultStoppingCriteriaList = LlamaCpp.Common.Processor.StoppingCriteria.TDefaultStoppingCriteriaList;
  // Cache
  TLlamaDiskCache = LlamaCpp.Common.Cache.Disk.TLlamaDiskCache;
  TLlamaRamCache = LlamaCpp.Common.Cache.Ram.TLlamaRAMCache;
  // Speculative decodings
  TLlamaPromptLookupDecoding = LlamaCpp.Common.Speculative.LookupDecoding.TLlamaPromptLookupDecoding;
  // Grammar
  TLlamaGrammar = LlamaCpp.Common.Grammar.TLlamaGrammar;
  // Chat and completion
  TCreateCompletionResponse = LlamaCpp.Common.Chat.Types.TCreateCompletionResponse;
  TChatCompletionStreamResponse = LlamaCpp.Common.Chat.Types.TChatCompletionStreamResponse;
  TChatCompletionRequestMessage = LlamaCpp.Common.Chat.Types.TChatCompletionRequestMessage;

  TLlamaBase = class(
    TInterfacedObject,
    ILlamaTokenization,
    ILlamaEvaluator,
    ILlamaSampler,
    ILlamaGenerator,
    ILlamaEmbedding,
    ILlamaCompletion,
    ILlamaChatCompletion,
    ILlama)
  private
    class var FBackendInitialized: boolean;
  private
    // Delegations
    FTokenization: ILlamaTokenization;
    FEvaluator: ILlamaEvaluator;
    FSampler: ILlamaSampler;
    FGenerator: ILlamaGenerator;
    FEmbedding: ILlamaEmbedding;
    FCompletion: ILlamaCompletion;
    FChatCompletion: ILlamaChatCompletion;
  private
    FModelPath: string;
    FSettings: TLlamaSettings;
    FChatHandler: ILlamaChatCompletionHandler;
    FDraftModel: ILlamaDraftModel;
    FCache: ILlamaCache;
    FModelParams: TLlamaModelParams;
    FContextParams: TLlamaContextParams;
    FKVOverrides: TArray<TLlamaModelKVOverride>;
    FModel: TLlamaModel;
    FContext: TLlamaContext;
    FBatch: TLlamaBatch;
    FLoraAdapter: PLlamaLoraAdapter;
    FCandidates: TLlamaTokenDataArray;
    FNTokens: integer;
    FInputIDs: TArray<integer>;
    FScores: TArray<TArray<Single>>;
    FMirostatMu: Single;
    FMetadata: TMetadata;
    FEosToken: string;
    FBosToken: string;
    FTemplateChoices: TDictionary<string, string>;
    FChatHandlers: TDictionary<string, ILlamaChatCompletionHandler>;
    procedure ParseKVOverrides();
  private
    // ILlamaCore private implementation
    function GetModelPath(): string;
    function GetMetadata(): TMetadata;
    function GetBOSToken(): string;
    function GetEOSToken(): string;
    function GetNumberOfTokens(): integer;
    procedure SetNumberOfTokens(const ANumberOfTokens: integer);
    function GetNumberOfBatches(): integer;
    function GetInputIds(): TArray<integer>;
    procedure SetInputIds(const AInputIds: TArray<integer>);
    function GetScores(): TArray<TArray<single>>;
    procedure SetScores(const AScores: TArray<TArray<single>>);
    function GetModelParams(): TLlamaModelParams;
    function GetModel(): TLlamaModel;
    function GetContextParams(): TLlamaContextParams;
    function GetContext(): TLlamaContext;
    function GetBatch(): TLlamaBatch;
    function GetSettings(): TLlamaSettings;
    function GetTokenizer(): ILlamaTokenizer;
    function GetChatHandler(): ILlamaChatCompletionHandler;
    function GetDraftModel(): ILlamaDraftModel;
    function GetCache(): ILlamaCache;
    function GetTemplateChoices(): TDictionary<string, string>;
    function GetChatHandlers(): TDictionary<string, ILlamaChatCompletionHandler>;
    procedure Reset();
  public
    // ILlamaCore public implementation
    function SaveState(): TLlamaState;
    procedure LoadState(const AState: TLlamaState);
  public
    // Delegations
    property Tokenization: ILlamaTokenization read FTokenization
      implements ILlamaTokenization;
    property Evaluator: ILlamaEvaluator read FEvaluator
      implements ILlamaEvaluator;
    property Sampler: ILlamaSampler read FSampler
      implements ILlamaSampler;
    property Generator: ILlamaGenerator read FGenerator
      implements ILlamaGenerator;
    property Embedding: ILlamaEmbedding read FEmbedding
      implements ILlamaEmbedding;
    property Completion: ILlamaCompletion read FCompletion
      implements ILlamaCompletion;
    property ChatCompletion: ILlamaChatCompletion read FChatCompletion
      implements ILlamaChatCompletion;
  public
    constructor Create(); overload;
    constructor Create(
      const AModelPath: string;
      const ASettings: TLlamaSettings;
      const ATokenizer: ILlamaTokenizer = nil;
      const AChatHandler: ILlamaChatCompletionHandler = nil;
      const ADraftModel: ILlamaDraftModel = nil;
      const ACache: ILlamaCache = nil); overload;
    destructor Destroy(); override;

    procedure Init(
      const AModelPath: string;
      const ASettings: TLlamaSettings;
      const ATokenizer: ILlamaTokenizer = nil;
      const AChatHandler: ILlamaChatCompletionHandler = nil;
      const ADraftModel: ILlamaDraftModel = nil;
      const ACache: ILlamaCache = nil);
  end;

  TLlamaLoadModel = procedure(
          Sender: TObject;
      var AModelPath: string;
    const ASettings: TLlamaSettings) of object;

  TLLamaCompletionStream = procedure(
          Sender: TObject;
    const AResponse: TCreateCompletionResponse;
      var AContinue: boolean) of object;

  TLlamaChatCompletionStream = procedure(
          Sender: TObject;
    const AResponse: TChatCompletionStreamResponse;
      var AContinue: boolean) of object;
  TLlamaChatCompletionStreamComplete = procedure(Sender: TObject) of object;

  [ComponentPlatforms(pfidWindows or pfidOSX or pfidLinux)]
  TLlama = class(TComponent)
  private
    FLlamaBase: ILlama;
    FAutoLoad: boolean;
    FModelPath: string;
    FSettings: TLlamaSettings;
    FDraftModel: ILlamaDraftModel;
    FTokenizer: ILlamaTokenizer;
    FCache: ILlamaCache;
    FChatHandler: ILlamaChatCompletionHandler;
    FOnLoadModel: TLlamaLoadModel;
    FOnCompletionStream: TLlamaCompletionStream;
    FOnChatCompletionStream: TLlamaChatCompletionStream;
    FOnChatCompletionStreamComplete: TLlamaChatCompletionStreamComplete;
    procedure SetSettings(const Value: TLlamaSettings);
  protected
    procedure Loaded(); override;
  protected type
    TLlamaTaskAsyncResult = class(TBaseAsyncResult)
    private
      FTask: TProc;
      FCallback: TProc;
      FCancelled: PBoolean;
    protected
      procedure Complete(); override;
      procedure Schedule(); override;
      procedure AsyncDispatch(); override;
      function DoCancel(): boolean; override;
    public
      constructor Create(const ATask, ACallback: TProc;
        const ACancelled: PBoolean);
    end;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure Init();

    // Tokenization
    function Tokenize(
      const AText: TBytes;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false): TArray<integer>;
    function Detokenize(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false): TBytes; overload;
    // Evaluation
    procedure Eval(
      const ATokens: TArray<integer>);
    // Embeddings
    function Embed(
      const AInput: TArray<string>;
        out AReturnCount: integer;
      const ANormalize: boolean = false;
      const ATruncate: boolean = true)
      : TArray<TArray<Single>>;
    function CreateEmbedding(const AInput: TArray<string>;
      AModelName: string = '')
      : TCreateEmbeddingResponse;
    // Sampling
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
    // Generator
    procedure Generate(
            ATokens: TArray<integer>;
      const ASettings: TLlamaSamplerSettings;
      const ACallback: TGeneratorCallback;
      const AReset: boolean = true;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil);
    // Completion
    function CreateCompletion(
      const APrompt: string;
            ASettings: TLlamaCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
    : TCreateCompletionResponse; overload;
    procedure CreateCompletion(
      const APrompt: string;
            ASettings: TLlamaCompletionSettings;
      const ACallback: TCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
    function CreateCompletion(
      const ATokens: TArray<integer>;
            ASettings: TLlamaCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
    : TCreateCompletionResponse; overload;
    procedure CreateCompletion(
      const ATokens: TArray<integer>;
            ASettings: TLlamaCompletionSettings;
      const ACallback: TCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
    procedure CreateCompletionStream(
      const ATokens: TArray<integer>;
            ASettings: TLlamaCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
    // Chat Completion
    function CreateChatCompletion(
      const ASettings: TLlamaChatCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
      : TCreateChatCompletionResponse; overload;
    procedure CreateChatCompletion(
      const ASettings: TLlamaChatCompletionSettings;
      const ACallback: TChatCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
    function CreateChatCompletionStream(
      const ASettings: TLlamaChatCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil): IAsyncResult;
  published
    property AutoLoad: boolean read FAutoLoad write FAutoLoad default false;
    property ModelPath: string read FModelPath write FModelPath;
    property Settings: TLlamaSettings read FSettings write SetSettings;

    property Tokenizer: ILlamaTokenizer read FTokenizer write FTokenizer;
    property ChatHandler: ILlamaChatCompletionHandler read FChatHandler write FChatHandler;
    property DraftModel: ILlamaDraftModel read FDraftModel write FDraftModel;
    property Cache: ILlamaCache read FCache write FCache;

    property OnLoadModel: TLlamaLoadModel read FOnLoadModel write FOnLoadModel;
    property OnCompletionStream: TLlamaCompletionStream read FOnCompletionStream write FOnCompletionStream;
    property OnChatCompletionStream: TLlamaChatCompletionStream read FOnChatCompletionStream write FOnChatCompletionStream;
    property OnChatCompletionStreamComplete: TLlamaChatCompletionStreamComplete read FOnChatCompletionStreamComplete write FOnChatCompletionStreamComplete;
  end;

implementation

uses
  System.AnsiStrings,
  LlamaCpp.Api.Llama,
  LlamaCpp.Exception,
  LlamaCpp.Helper,
  LlamaCpp.Tokenization,
  LlamaCpp.Embedding,
  LlamaCpp.Evaluator,
  LlamaCpp.Sampler,
  LlamaCpp.Generator,
  LLamaCpp.Completion,
  LLamaCpp.ChatCompletion,
  LlamaCpp.Common.Chat.Formatter.Jinja2;

{ TLlamaBase }

constructor TLlamaBase.Create;
begin
  FSettings := TLlamaSettings.Create();
  FChatHandlers := TDictionary<string, ILlamaChatCompletionHandler>.Create();
  FTemplateChoices := TDictionary<string, string>.Create();
end;

constructor TLlamaBase.Create(const AModelPath: string;
  const ASettings: TLlamaSettings; const ATokenizer: ILlamaTokenizer;
  const AChatHandler: ILlamaChatCompletionHandler;
  const ADraftModel: ILlamaDraftModel; const ACache: ILlamaCache);
begin
  Create();
  Init(AModelPath, ASettings, ATokenizer, AChatHandler, ADraftModel, ACache);
end;

destructor TLlamaBase.Destroy;
begin
  if Assigned(FLoraAdapter) then
    TLlamaApi.Instance.llama_lora_adapter_free(FLoraAdapter);

  if Assigned(FBatch) then
    FBatch.UnloadBatch();

  if Assigned(FContext) then
    FContext.UnloadContext();

  if Assigned(FModel) then
    FModel.UnloadModel();

  FChatHandlers.Free();
  FTemplateChoices.Free();
  FMetadata.Free();
  FBatch.Free();
  FContext.Free();
  FModel.Free();
  FSettings.Free();
  inherited;
end;

procedure TLlamaBase.Init(const AModelPath: string;
  const ASettings: TLlamaSettings;
  const ATokenizer: ILlamaTokenizer;
  const AChatHandler: ILlamaChatCompletionHandler;
  const ADraftModel: ILlamaDraftModel;
  const ACache: ILlamaCache);
var
  LItem: TPair<string, string>;
  LTemplateChoice: TPair<string, string>;
begin
  FModelPath := AModelPath;
  FSettings.Assign(ASettings);
  FChatHandler := AChatHandler;
  FDraftModel := ADraftModel;
  FCache := ACache;

  if not FBackendInitialized then
    TLlamaApi.Instance.llama_backend_init();
  FBackendInitialized := true;

  if FSettings.NUMA <> TGGMLNumaStrategy.GGML_NUMA_STRATEGY_DISABLED then
    TLlamaApi.Instance.llama_numa_init(FSettings.NUMA);

  FModelParams := TLlamaApi.Instance.llama_model_default_params();

  if FSettings.NGpuLayers = -1 then
    FModelParams.NGpuLayers := High(Int32)
  else
    FModelParams.NGpuLayers := FSettings.NGpuLayers;

  FModelParams.SplitMode := FSettings.SplitMode;
  FModelParams.MainGpu := FSettings.MainGpu;

  if not FSettings.RpcServers.IsEmpty() then
    FModelParams.RpcServers := PAnsiChar(UTF8Encode(FSettings.RpcServers));

  if Assigned(FSettings.TensorSplit) then
  begin
    if Length(FSettings.TensorSplit) > LlamaCpp.CType.Llama.TLlama.LLAMA_MAX_DEVICES
    then
      raise ETensorSplitExceed.CreateFmt
        ('Attempt to split tensors that exceed maximum supported devices. Current LLAMA_MAX_DEVICES=%d',
        [LlamaCpp.CType.Llama.TLlama.LLAMA_MAX_DEVICES]);

    FModelParams.TensorSplit := @TTensorSplit(FSettings.TensorSplit[0]);
  end;

  FModelParams.VocabOnly := FSettings.VocabOnly;

  if not FSettings.LoraPath.IsEmpty() then
    FModelParams.UseMMap := false;

  FModelParams.UseMLock := FSettings.UseMLock;

  if Assigned(FSettings.KVOverrides) then
    ParseKVOverrides();

  FSettings.NBatch := Min(FSettings.NCtx, FSettings.NBatch);

  if FSettings.NThreads <= 0 then
    FSettings.NThreads := Max(TThread.ProcessorCount div 2, 1);

  if FSettings.NThreadsBatch <= 0 then
    FSettings.NThreadsBatch := TThread.ProcessorCount;

  FContextParams := TLlamaApi.Instance.llama_context_default_params();
  FContextParams.NContext := FSettings.NCtx;
  FContextParams.NBatch := FSettings.NBatch;
  FContextParams.NUBatch := FSettings.NUBatch;
  FContextParams.NThreads := FSettings.NThreads;
  FContextParams.NThreadsBatch := FSettings.NThreadsBatch;
  FContextParams.RopeScalingType := FSettings.RopeScalingType;
  FContextParams.PoolingType := FSettings.PoolingType;
  FContextParams.RopeFreqBase := FSettings.RopeFreqBase;
  FContextParams.RopeFreqScale := FSettings.RopeFreqScale;
  FContextParams.YarnExtFactor := FSettings.YarnExtFactor;
  FContextParams.YarnAttnFactor := FSettings.YarnAttnFactor;
  FContextParams.YarnBetaFast := FSettings.YarnBetaFast;
  FContextParams.YarnBetaSlow := FSettings.YarnBetaSlow;
  FContextParams.YarnOrigCtx := FSettings.YarnOrigCtx;

  if not Assigned(FDraftModel) then
    FContextParams.LogitsAll := FSettings.LogitsAll
  else
    FContextParams.LogitsAll := true;

  FContextParams.Embeddings := FSettings.Embeddings;
  FContextParams.OffloadKQV := FSettings.OffloadKQV;
  FContextParams.FlashAttn := FSettings.FlashAttn;
  FContextParams.TypeK := FSettings.TypeK;
  FContextParams.TypeV := FSettings.TypeV;
  FContextParams.DefragThreshold := -1;

  FModel := TLlamaModel.Create(AModelPath, FModelParams);
  FModel.LoadModel();

  if FSettings.NCtx = 0 then
  begin
    FSettings.NCtx := FModel.NCtxTrain();
    FSettings.NBatch := Min(FSettings.NCtx, FSettings.NBatch);

    FContextParams.NContext := FSettings.NCtx;
    FContextParams.NBatch := FSettings.NBatch;
    FContextParams.NUBatch := Min(FSettings.NBatch, FSettings.NUBatch);
  end;

  FContext := TLlamaContext.Create(FModel, FContextParams);
  FContext.LoadContext();

  FBatch := TLlamaBatch.Create(FSettings.NBatch, 0, FContextParams.NContext);
  FBatch.LoadBatch();

  if not FSettings.LoraPath.IsEmpty() then
  begin
    FLoraAdapter := TLlamaApi.Instance.llama_lora_adapter_init(FModel.Model,
      PAnsiChar(UTF8Encode(FSettings.LoraPath)));

    if not Assigned(FLoraAdapter) then
      raise ELoraAdapterInitFailure.CreateFmt
        ('Failed to initialize LoRA adapter from lora path: %s',
        [FSettings.LoraPath]);

    if TLlamaApi.Instance.llama_lora_adapter_set(FContext.Context, FLoraAdapter,
      FSettings.LoraScale) = -1 then
      raise ELoraAdapterSetFailure.CreateFmt(
        'Failed to set LoRA adapter from lora path: %s',
        [FSettings.LoraPath]);
  end;

  // if self.verbose:
  // print(llama_cpp.llama_print_system_info().decode("utf-8"), file=sys.stderr)

  FCandidates := TLlamaTokenDataArray.Create(FModel.NVocab());
  FNTokens := 0;

  SetLength(FInputIDs, FContext.NCtx());

  if FSettings.LogitsAll then
    SetLength(FScores, FSettings.NCtx, FModel.NVocab())
  else
    SetLength(FScores, FSettings.NBatch, FModel.NVocab());

  FMirostatMu := 2.0 * 5.0;

  try
    FMetadata := FModel.Metadata();
  except
    FMetadata := TMetadata.Create();
  end;

  if FModel.TokenEOS() <> -1 then
    FEosToken := FModel.TokenGetText(FModel.TokenEOS());

  if FModel.TokenBOS() <> -1 then
    FBosToken := FModel.TokenGetText(FModel.TokenBOS());

  for LItem in FMetadata.ToArray() do
    if LItem.Key.StartsWith('tokenizer.chat_template.') then
      FTemplateChoices.Add(LItem.Key.Substring(10), LItem.Value);

  if FMetadata.ContainsKey('tokenizer.chat_template') then
    FTemplateChoices.AddOrSetValue(
      'chat_template.default',
      FMetadata.Items['tokenizer.chat_template']);

  for LTemplateChoice in FTemplateChoices do
    FChatHandlers.AddOrSetValue(
      LTemplateChoice.Key,
      TJinja2ChatFormatter.Create(
        LTemplateChoice.Value,
        GetEOSToken(),
        GetBOSToken(),
        true,
        [FModel.TokenEOS()]
      ).ToChatHandler()
    );

  if FSettings.ChatFormat.IsEmpty() and not Assigned(FChatHandler) and
    FTemplateChoices.ContainsKey('chat_template.default') then
  begin
    FSettings.ChatFormat := TLlamaChatFormat.GuessChatFormatFromGguf(FMetadata);

    if FSettings.ChatFormat.IsEmpty() then
      FSettings.ChatFormat := 'chat_template.default';
  end;

  if FSettings.ChatFormat.IsEmpty() and not Assigned(FChatHandler) then
    FSettings.ChatFormat := 'llama-2';

  // Delegators
  FTokenization := TLlamaTokenization.Create(Self);
  FEmbedding := TLlamaEmbedding.Create(Self);
  FEvaluator := TLlamaEvaluator.Create(Self);
  FSampler := TLlamaSampler.Create(Self);
  FGenerator := TLlamaGenerator.Create(Self);
  FCompletion := TLlamaCompletion.Create(Self);
  FChatCompletion := TLlamaChatCompletion.Create(Self);
end;


procedure TLlamaBase.ParseKVOverrides;
var
  I: integer;
  LItem: TPair<string, Variant>;
begin
  SetLength(FKVOverrides, Length(FSettings.KVOverrides) + 1);

  for I := Low(FSettings.KVOverrides) to High(FSettings.KVOverrides) do
  begin
    LItem := FSettings.KVOverrides[I];

    System.AnsiStrings.StrLCopy(FKVOverrides[I].Key,
      PAnsiChar(UTF8Encode(LItem.Key)), SizeOf(TLlamaModelKVOverrideKey));

    case VarType(LItem.Value) of
      varBoolean:
        begin
          FKVOverrides[I].Tag :=
            TLlamaModelKvOverrideType.LLAMA_KV_OVERRIDE_TYPE_BOOL;
          FKVOverrides[I].Value.ValBool := LItem.Value;
        end;
      varInteger:
        begin
          FKVOverrides[I].Tag :=
            TLlamaModelKvOverrideType.LLAMA_KV_OVERRIDE_TYPE_INT;
          FKVOverrides[I].Value.ValInt64 := LItem.Value;
        end;
      varDouble, varSingle:
        begin
          FKVOverrides[I].Tag :=
            TLlamaModelKvOverrideType.LLAMA_KV_OVERRIDE_TYPE_FLOAT;
          FKVOverrides[I].Value.ValFloat64 := LItem.Value;
        end;
      varString:
        begin
          FKVOverrides[I].Tag :=
            TLlamaModelKvOverrideType.LLAMA_KV_OVERRIDE_TYPE_STR;
          System.AnsiStrings.StrLCopy(FKVOverrides[I].Value.ValStr,
            PAnsiChar(UTF8Encode(LItem.Value)),
            SizeOf(TLLamaModelKVOverrideValueString));
        end;
    else
      raise EUnknownValueForKVOverrides.CreateFmt(
        'Unknown value type for %s', [
        LItem.Key]);
    end;
  end;

  FKVOverrides[Length(FKVOverrides)].Key := #0;

  FModelParams.KVOverrides := @TLlamaModelKVOverrideArray(FKVOverrides[0]);
end;

function TLlamaBase.GetBatch: TLlamaBatch;
begin
  Result := FBatch;
end;

function TLlamaBase.GetBOSToken: string;
begin
  Result := FBOSToken;
end;

function TLlamaBase.GetCache: ILlamaCache;
begin
  Result := FCache;
end;

function TLlamaBase.GetChatHandler: ILlamaChatCompletionHandler;
begin
  Result := FChatHandler;
end;

function TLlamaBase.GetChatHandlers: TDictionary<string, ILlamaChatCompletionHandler>;
begin
  Result := FChatHandlers;
end;

function TLlamaBase.GetContext: TLlamaContext;
begin
  Result := FContext;
end;

function TLlamaBase.GetContextParams: TLlamaContextParams;
begin
  Result := FContextParams;
end;

function TLlamaBase.GetDraftModel: ILlamaDraftModel;
begin
  Result := FDraftModel;
end;

function TLlamaBase.GetEOSToken: string;
begin
  Result := FEOSToken;
end;

function TLlamaBase.GetInputIds: TArray<integer>;
begin
  Result := FInputIds;
end;

function TLlamaBase.GetMetadata: TMetadata;
begin
  Result := FMetadata;
end;

function TLlamaBase.GetModel: TLlamaModel;
begin
  Result := FModel;
end;

function TLlamaBase.GetModelParams: TLlamaModelParams;
begin
  Result := FModelParams;
end;

function TLlamaBase.GetModelPath: string;
begin
  Result := FModelPath;
end;

function TLlamaBase.GetNumberOfBatches: integer;
begin
  Result := FSettings.NBatch;
end;

function TLlamaBase.GetNumberOfTokens: integer;
begin
  Result := FNTokens;
end;

function TLlamaBase.GetTokenizer: ILlamaTokenizer;
begin
  Result := TLlamaTokenizer.Create(FModel);
end;

function TLlamaBase.GetTemplateChoices: TDictionary<string, string>;
begin
  Result := FTemplateChoices;
end;

function TLlamaBase.GetScores: TArray<TArray<single>>;
begin
  Result := FScores;
end;

function TLlamaBase.GetSettings: TLlamaSettings;
begin
  Result := FSettings;
end;

procedure TLlamaBase.SetInputIds(const AInputIds: TArray<integer>);
begin
  FInputIds := AInputIds;
end;

procedure TLlamaBase.SetNumberOfTokens(const ANumberOfTokens: integer);
begin
  FNTokens := ANumberOfTokens;
end;

procedure TLlamaBase.SetScores(const AScores: TArray<TArray<single>>);
begin
  FScores := AScores;
end;

function TLlamaBase.SaveState: TLlamaState;
var
  state_size: NativeInt;
  llama_state: TArray<ShortInt>;
  n_bytes: NativeInt;
begin
  state_size := TLlamaApi.Instance.llama_get_state_size(FContext.Context);
  SetLength(llama_state, state_size);
  n_bytes := TLlamaApi.Instance.llama_copy_state_data(FContext.Context, @llama_state[0]);

  if n_bytes > state_size then
    raise ESaveStateCopy.Create('Failed to copy llama state data');

  //if FSettings.Verbose then
  //  print("Llama.save_state: saving [n_bytes] bytes of llama state." )

  Result := TLlamaState.Create(
    FInputIds,
    TScoresHelper.Scores(FScores, FNTokens),
    FNTokens,
    llama_state,
    n_bytes,
    FSettings.Seed
  );
end;

procedure TLlamaBase.LoadState(const AState: TLlamaState);
var
  I: integer;
  J: integer;
begin
  TArray.Copy<TArray<single>>(AState.Scores, FScores, AState.NTokens);
  for I := AState.NTokens to High(FScores) do
    for J := Low(FScores[I]) to High(FScores[I]) do      
      if (FScores[I][J] > 0) then
        FScores[I][J] := 0;   

  FInputIds := AState.InputIds;
  FNTokens := AState.NTokens;
  FSettings.Seed := AState.Seed;

  if TLlamaApi.Instance.llama_set_state_data(
    FContext.Context, @AState.LlamaState[0]) <> AState.LlamaStateSize then
      raise ESaveStateSet.Create('Failed to set llama state data');
end;

procedure TLlamaBase.Reset;
begin
  FNTokens := 0;
end;

{ TLlama }

constructor TLlama.Create(AOwner: TComponent);
begin
  inherited;
  FLlamaBase := TLlamaBase.Create();
  FSettings := TLlamaSettings.Create();
end;

destructor TLlama.Destroy;
begin
  FSettings.Free();
  inherited;
end;

procedure TLlama.SetSettings(const Value: TLlamaSettings);
begin
  FSettings.Assign(Value);
end;

procedure TLlama.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    if FAutoLoad then
      Init();
end;

procedure TLlama.Init();
begin
  if Assigned(FOnLoadModel) then
    FOnLoadModel(Self, FModelPath, FSettings);

  (FLlamaBase as TLlamaBase).Init(
    FModelPath, FSettings, FTokenizer, FChatHandler, FDraftModel, FCache);
end;

function TLlama.Tokenize(const AText: TBytes; const AAddSpecial,
  AParseSpecial: boolean): TArray<integer>;
begin
  Result := (FLlamaBase as ILlamaTokenization).Tokenize(
    AText, AAddSpecial, AParseSpecial);
end;

function TLlama.Detokenize(const ATokens, APrevTokens: TArray<integer>;
  const ASpecial: boolean): TBytes;
begin
  Result := (FLlamaBase as ILlamaTokenization).Detokenize(
    ATokens, APrevTokens, ASpecial);
end;

procedure TLlama.Eval(const ATokens: TArray<integer>);
begin
  (FLlamaBase as ILlamaEvaluator).Eval(ATokens);
end;

function TLlama.Embed(const AInput: TArray<string>; out AReturnCount: integer;
  const ANormalize, ATruncate: boolean): TArray<TArray<Single>>;
begin
  Result := (FLlamaBase as ILlamaEmbedding).Embed(
    AInput, AReturnCount, ANormalize, ATruncate);
end;

function TLlama.CreateEmbedding(const AInput: TArray<string>;
  AModelName: string): TCreateEmbeddingResponse;
begin
  Result := (FLlamaBase as ILlamaEmbedding).CreateEmbedding(
    AInput, AModelName);
end;

procedure TLlama.InitSampler(const AInputIds: TArray<integer>;
  const ASettings: TLlamaSamplerSettings;
  const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
begin
  (FLlamaBase as ILlamaSampler).InitSampler(
    AInputIds, ASettings, ASampler, ALogitsProcessor, AGrammar);
end;

function TLlama.Sample(const ANumberOfTokens: integer;
  const ASettings: TLlamaSamplerSettings;
  const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
  const AIdx: integer): integer;
begin
  Result := (FLlamaBase as ILlamaSampler).Sample(
    ANumberOfTokens, ASettings, ASampler, AIdx);
end;

procedure TLlama.Generate(ATokens: TArray<integer>;
  const ASettings: TLlamaSamplerSettings; const ACallback: TGeneratorCallback;
  const AReset: boolean; const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
begin
  (FLlamaBase as ILlamaGenerator).Generate(
    ATokens, ASettings, ACallback, AReset, AStoppingCriteria, ALogitsProcessor,
    AGrammar);
end;

function TLlama.CreateCompletion(const APrompt: string;
  ASettings: TLlamaCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList;
  const AGrammar: ILlamaGrammar): TCreateCompletionResponse;
begin
  Result := (FLlamaBase as ILlamaCompletion).CreateCompletion(
    APrompt, ASettings, AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

procedure TLlama.CreateCompletion(const APrompt: string;
  ASettings: TLlamaCompletionSettings; const ACallback: TCompletionCallback;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
begin
  (FLlamaBase as ILlamaCompletion).CreateCompletion(
    APrompt, ASettings, ACallback, AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

function TLlama.CreateCompletion(const ATokens: TArray<integer>;
  ASettings: TLlamaCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList;
  const AGrammar: ILlamaGrammar): TCreateCompletionResponse;
begin
  Result := (FLlamaBase as ILlamaCompletion).CreateCompletion(
    ATokens, ASettings, AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

procedure TLlama.CreateCompletion(const ATokens: TArray<integer>;
  ASettings: TLlamaCompletionSettings; const ACallback: TCompletionCallback;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
begin
  (FLlamaBase as ILlamaCompletion).CreateCompletion(
    ATokens, ASettings, ACallback, AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

procedure TLlama.CreateCompletionStream(const ATokens: TArray<integer>;
  ASettings: TLlamaCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
begin
  Assert(Assigned(FOnCompletionStream), 'Event "OnCompletionStream" not assigned.');

  (FLlamaBase as ILlamaCompletion).CreateCompletion(
    ATokens, ASettings,
    procedure(const AResponse: TCreateCompletionResponse; var AContinue: boolean)
    begin
      FOnCompletionStream(Self, AResponse, AContinue);
    end,
    AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

function TLlama.CreateChatCompletion(
  const ASettings: TLlamaChatCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList;
  const AGrammar: ILlamaGrammar): TCreateChatCompletionResponse;
begin
  (FLlamaBase as ILlamaChatCompletion).CreateChatCompletion(
    ASettings, AStoppingCriteria, ALogitsProcessor);
end;

procedure TLlama.CreateChatCompletion(
  const ASettings: TLlamaChatCompletionSettings;
  const ACallback: TChatCompletionCallback;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList; const AGrammar: ILlamaGrammar);
begin
  (FLlamaBase as ILlamaChatCompletion).CreateChatCompletion(
    ASettings, ACallback, AStoppingCriteria, ALogitsProcessor);
end;

function TLlama.CreateChatCompletionStream(
  const ASettings: TLlamaChatCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList;
  const ALogitsProcessor: ILogitsProcessorList;
  const AGrammar: ILlamaGrammar): IAsyncResult;
var
  LCancelled: boolean;
begin
  Assert(Assigned(FOnChatCompletionStream), 'Event "OnChatCompletionStream" not assigned.');

  LCancelled := false;

  Result := TLlamaTaskAsyncResult.Create(
    procedure()
    begin
      (FLlamaBase as ILlamaChatCompletion).CreateChatCompletion(
        ASettings,
        procedure(const AResponse: TChatCompletionStreamResponse; var AContinue: boolean)
        begin
          FOnChatCompletionStream(Self, AResponse, AContinue);

          if LCancelled then
            AContinue := false;
        end,
        AStoppingCriteria, ALogitsProcessor);
    end,
    procedure()
    begin
      if Assigned(FOnChatCompletionStreamComplete) then
        FOnChatCompletionStreamComplete(Self);
    end,
    @LCancelled).Invoke();
end;

{ TLlama.TLlamaTaskAsyncResult }

constructor TLlama.TLlamaTaskAsyncResult.Create(const ATask, ACallback: TProc;
  const ACancelled: PBoolean);
begin
  FTask := ATask;
  FCallback := ACallback;
  FCancelled := ACancelled;
end;

procedure TLlama.TLlamaTaskAsyncResult.AsyncDispatch;
begin
  FTask();
end;

procedure TLlama.TLlamaTaskAsyncResult.Complete;
begin
  inherited;
  if Assigned(FCallback) then
    FCallback();
end;

function TLlama.TLlamaTaskAsyncResult.DoCancel: boolean;
begin
  FCancelled^ := true;

  Result := true;
end;

procedure TLlama.TLlamaTaskAsyncResult.Schedule;
begin
  TTask.Run(DoAsyncDispatch);
end;

end.
