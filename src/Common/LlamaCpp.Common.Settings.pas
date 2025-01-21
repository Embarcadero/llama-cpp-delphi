unit LlamaCpp.Common.Settings;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  LlamaCpp.CType.Llama,
  LlamaCpp.CType.Ggml,
  LlamaCpp.CType.Ggml.Cpu,
  LlamaCpp.Common.Chat.Format,
  LlamaCpp.Common.Chat.Types;

type
  TLlamaSettings = class(TPersistent)
  private
    FNGpuLayers: Integer;
    FSplitMode: TLlamaSplitMode;
    FMainGpu: Int32;
    FTensorSplit: TArray<Single>;
    FRpcServers: string;
    FVocabOnly: Boolean;
    FUseMMap: Boolean;
    FUseMLock: Boolean;
    FKVOverrides: TArray<TPair<string, Variant>>;
    FSeed: UInt32;
    FNCtx: Integer;
    FNBatch: Integer;
    FNUBatch: Integer;
    FNThreads: Integer;
    FNThreadsBatch: Integer;
    FRopeScalingType: TLlamaRopeScalingType;
    FPoolingType: TLlamaPoolingType;
    FRopeFreqBase: Single;
    FRopeFreqScale: Single;
    FYarnExtFactor: Single;
    FYarnAttnFactor: Single;
    FYarnBetaFast: Single;
    FYarnBetaSlow: Single;
    FYarnOrigCtx: Integer;
    FLogitsAll: Boolean;
    FEmbeddings: Boolean;
    FOffloadKQV: Boolean;
    FFlashAttn: Boolean;
    FLastNTokensSize: Integer;
    FLoraBase: string;
    FLoraScale: Single;
    FLoraPath: string;
    FNUMA: TGGMLNumaStrategy;
    FChatFormat: string;
    FTypeK: TGGMLType;
    FTypeV: TGGMLType;
    FSPMInfill: Boolean;
    FVerbose: Boolean;
  public
    constructor Create(const ANGpuLayers: Integer = 0;
      const ASplitMode: TLlamaSplitMode = TLlamaSplitMode.LLAMA_SPLIT_MODE_LAYER;
      const AMainGpu: Int32 = 0; const ATensorSplit: TArray<Single> = nil;
      const ARpcServers: string = ''; const AVocabOnly: Boolean = False;
      const AUseMMap: Boolean = True; const AUseMLock: Boolean = False;
      const AKVOverrides: TArray<TPair<string, Variant>> = nil;
      const ASeed: UInt32 = LlamaCpp.CType.Llama.TLlama.LLAMA_DEFAULT_SEED;
      const ANCtx: Integer = 512; const ANBatch: Integer = 512;
      const ANUBatch: Integer = 512; const ANThreads: Integer = 0;
      const ANThreadsBatch: Integer = 0;
      const ARopeScalingType: TLlamaRopeScalingType = TLlamaRopeScalingType.LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED;
      const APoolingType: TLlamaPoolingType = TLlamaPoolingType.LLAMA_POOLING_TYPE_UNSPECIFIED;
      const ARopeFreqBase: Single = 0.0; const ARopeFreqScale: Single = 0.0;
      const AYarnExtFactor: Single = -1.0; const AYarnAttnFactor: Single = 1.0;
      const AYarnBetaFast: Single = 32.0; const AYarnBetaSlow: Single = 1.0;
      const AYarnOrigCtx: Integer = 0; const ALogitsAll: Boolean = False;
      const AEmbeddings: Boolean = False; const AOffloadKQV: Boolean = True;
      const AFlashAttn: Boolean = False; const ALastNTokensSize: Integer = 64;
      const ALoraBase: string = ''; const ALoraScale: Single = 1.0;
      const ALoraPath: string = ''; const ANUMA: TGGMLNumaStrategy = TGGMLNumaStrategy.GGML_NUMA_STRATEGY_DISABLED;
      const AChatFormat: string = ''; const ATypeK: TGGMLType = TGGMLType.GGML_TYPE_F32;
      const ATypeV: TGGMLType = TGGMLType.GGML_TYPE_F32; const ASPMInfill: Boolean = False;
      const AVerbose: Boolean = True);

    // Properties
    property NGpuLayers: Integer read FNGpuLayers write FNGpuLayers;
    property SplitMode: TLlamaSplitMode read FSplitMode write FSplitMode;
    property MainGpu: Int32 read FMainGpu write FMainGpu;
    property TensorSplit: TArray<Single> read FTensorSplit write FTensorSplit;
    property RpcServers: string read FRpcServers write FRpcServers;
    property VocabOnly: Boolean read FVocabOnly write FVocabOnly;
    property UseMMap: Boolean read FUseMMap write FUseMMap;
    property UseMLock: Boolean read FUseMLock write FUseMLock;
    property KVOverrides: TArray<TPair<string, Variant>> read FKVOverrides write FKVOverrides;
    property Seed: UInt32 read FSeed write FSeed;
    property NCtx: Integer read FNCtx write FNCtx;
    property NBatch: Integer read FNBatch write FNBatch;
    property NUBatch: Integer read FNUBatch write FNUBatch;
    property NThreads: Integer read FNThreads write FNThreads;
    property NThreadsBatch: Integer read FNThreadsBatch write FNThreadsBatch;
    property RopeScalingType: TLlamaRopeScalingType read FRopeScalingType write FRopeScalingType;
    property PoolingType: TLlamaPoolingType read FPoolingType write FPoolingType;
    property RopeFreqBase: Single read FRopeFreqBase write FRopeFreqBase;
    property RopeFreqScale: Single read FRopeFreqScale write FRopeFreqScale;
    property YarnExtFactor: Single read FYarnExtFactor write FYarnExtFactor;
    property YarnAttnFactor: Single read FYarnAttnFactor write FYarnAttnFactor;
    property YarnBetaFast: Single read FYarnBetaFast write FYarnBetaFast;
    property YarnBetaSlow: Single read FYarnBetaSlow write FYarnBetaSlow;
    property YarnOrigCtx: Integer read FYarnOrigCtx write FYarnOrigCtx;
    property LogitsAll: Boolean read FLogitsAll write FLogitsAll;
    property Embeddings: Boolean read FEmbeddings write FEmbeddings;
    property OffloadKQV: Boolean read FOffloadKQV write FOffloadKQV;
    property FlashAttn: Boolean read FFlashAttn write FFlashAttn;
    property LastNTokensSize: Integer read FLastNTokensSize write FLastNTokensSize;
    property LoraBase: string read FLoraBase write FLoraBase;
    property LoraScale: Single read FLoraScale write FLoraScale;
    property LoraPath: string read FLoraPath write FLoraPath;
    property NUMA: TGGMLNumaStrategy read FNUMA write FNUMA;
    property ChatFormat: string read FChatFormat write FChatFormat;
    property TypeK: TGGMLType read FTypeK write FTypeK;
    property TypeV: TGGMLType read FTypeV write FTypeV;
    property SPMInfill: Boolean read FSPMInfill write FSPMInfill;
    property Verbose: Boolean read FVerbose write FVerbose;

    // Override Assign method
    procedure Assign(Source: TPersistent); override;
  end;

  TLlamaSamplerSettings = record
  public
    TopK: Integer;
    TopP: Single;
    MinP: Single;
    TypicalP: Single;
    Temp: Single;
    RepeatPenalty: Single;
    FrequencyPenalty: Single;
    PresencePenalty: Single;
    TfsZ: Single;
    MirostatMode: Integer;
    MirostatEta: Single;
    MirostatTau: Single;
    PenalizeNL: Boolean;
  public
    class function Create(const ATopK: Integer = 40; const ATopP: Single = 0.95;
      const AMinP: Single = 0.05; const ATypicalP: Single = 1.0;
      const ATemp: Single = 0.80; const ARepeatPenalty: Single = 1.0;
      const AFrequencyPenalty: Single = 0.0;
      const APresencePenalty: Single = 0.0; const ATfsZ: Single = 1.0;
      const AMirostatMode: Integer = 0; const AMirostatEta: Single = 0.1;
      const AMirostatTau: Single = 5.0; const APenalizeNL: Boolean = True
    ): TLlamaSamplerSettings; static;
  end;

  TLlamaCompletionSettings = record
  public
    Suffix: string;
    MaxTokens: Integer;
    Temperature: Single;
    TopP: Single;
    MinP: Single;
    TypicalP: Single;
    Logprobs: integer;
    Echo: Boolean;
    Stop: TArray<string>;
    FrequencyPenalty: Single;
    PresencePenalty: Single;
    RepeatPenalty: Single;
    TopK: Integer;
    Seed: UInt32;
    TfsZ: Single;
    MirostatMode: Integer;
    MirostatTau: Single;
    MirostatEta: Single;
    ModelName: string;
    LogitBias: TArray<TPair<integer, single>>;
  public
    class function Create(
      const ASuffix: string = '';
      AMaxTokens: Integer = 16;
      ATemperature: Single = 0.8;
      ATopP: Single = 0.95;
      AMinP: Single = 0.05;
      ATypicalP: Single = 1.0;
      ALogprobs: integer = 0;
      AEcho: Boolean = False;
      AStop: TArray<string> = nil;
      AFrequencyPenalty: Single = 0.0;
      APresencePenalty: Single = 0.0;
      ARepeatPenalty: Single = 1.0;
      ATopK: Integer = 40;
      ASeed: UInt32 = 0;
      ATfsZ: Single = 1.0;
      AMirostatMode: Integer = 0;
      AMirostatTau: Single = 5.0;
      AMirostatEta: Single = 0.1;
      AModelName: string = '';
      ALogitBias: TArray<TPair<integer, single>> = nil
    ): TLlamaCompletionSettings; static;

    function ToGeneratorSettings(): TLlamaSamplerSettings;
  end;

  TLlamaChatCompletionSettings = record
    Messages: TArray<TChatCompletionRequestMessage>;
    Functions: TArray<TChatCompletionFunction>;
    FunctionCall: TChatCompletionRequestFunctionCall;
    Tools: TArray<TChatCompletionTool>;
    ToolChoice: TChatCompletionToolChoiceOption;
    ResponseFormat: TChatCompletionRequestResponseFormat;
    Temperature: Single;
    TopP: Single;
    TopK: Integer;
    Stream: Boolean;
    Stop: TArray<string>;
    Seed: UInt32;
    MaxTokens: Integer;
    PresencePenalty: Single;
    FrequencyPenalty: Single;
    RepeatPenalty: Single;
    ModelName: string;
    LogitBias: TArray<TPair<integer, Single>>;
    MinP: Single;
    TypicalP: Single;
    TfsZ: Single;
    MirostatMode: Integer;
    MirostatTau: Single;
    MirostatEta: Single;
    Logprobs: integer;
    TopLogprobs: Integer;

    // Constructor to initialize with default values
    constructor Create(
      const AMessages: TArray<TChatCompletionRequestMessage>;
      const AFunctions: TArray<TChatCompletionFunction>;
      const AFunctionCall: TChatCompletionRequestFunctionCall;
      const ATools: TArray<TChatCompletionTool>;
      const AToolChoice: TChatCompletionToolChoiceOption;
      const AResponseFormat: TChatCompletionRequestResponseFormat;
      const ATemperature: Single = 0.2;
      const ATopP: Single = 0.95;
      const ATopK: Integer = 40;
      const AStream: Boolean = False;
      const AStop: TArray<string> = [];
      const ASeed: UInt32 = 0;
      const AMaxTokens: Integer = 0;
      const APresencePenalty: Single = 0.0;
      const AFrequencyPenalty: Single = 0.0;
      const ARepeatPenalty: Single = 1.1;
      const AModelName: string = '';
      const ALogitBias: TArray<TPair<integer, Single>> = nil;
      const AMinP: Single = 0.05;
      const ATypicalP: Single = 1.0;
      const ATfsZ: Single = 1.0;
      const AMirostatMode: Integer = 0;
      const AMirostatTau: Single = 5.0;
      const AMirostatEta: Single = 0.1;
      const ALogprobs: integer = 0;
      const ATopLogprobs: Integer = 0
    ); overload;

    constructor Create(
      const AMessages: TArray<TChatCompletionRequestMessage>); overload;

    function ToLlamaCompletionSettings(): TLlamaCompletionSettings;
  end;

implementation

{ TLlamaSettings }

constructor TLlamaSettings.Create(const ANGpuLayers: Integer = 0;
  const ASplitMode: TLlamaSplitMode = TLlamaSplitMode.LLAMA_SPLIT_MODE_LAYER;
  const AMainGpu: Int32 = 0; const ATensorSplit: TArray<Single> = nil;
  const ARpcServers: string = ''; const AVocabOnly: Boolean = False;
  const AUseMMap: Boolean = True; const AUseMLock: Boolean = False;
  const AKVOverrides: TArray < TPair < string, Variant >> = nil;
  const ASeed: UInt32 = LlamaCpp.CType.Llama.TLlama.LLAMA_DEFAULT_SEED;
  const ANCtx: Integer = 512; const ANBatch: Integer = 512;
  const ANUBatch: Integer = 512; const ANThreads: Integer = 0;
  const ANThreadsBatch: Integer = 0;
  const ARopeScalingType: TLlamaRopeScalingType = TLlamaRopeScalingType.
  LLAMA_ROPE_SCALING_TYPE_UNSPECIFIED;
  const APoolingType: TLlamaPoolingType = TLlamaPoolingType.
  LLAMA_POOLING_TYPE_UNSPECIFIED; const ARopeFreqBase: Single = 0.0;
  const ARopeFreqScale: Single = 0.0; const AYarnExtFactor: Single = -1.0;
  const AYarnAttnFactor: Single = 1.0; const AYarnBetaFast: Single = 32.0;
  const AYarnBetaSlow: Single = 1.0; const AYarnOrigCtx: Integer = 0;
  const ALogitsAll: Boolean = False; const AEmbeddings: Boolean = False;
  const AOffloadKQV: Boolean = True; const AFlashAttn: Boolean = False;
  const ALastNTokensSize: Integer = 64; const ALoraBase: string = '';
  const ALoraScale: Single = 1.0; const ALoraPath: string = '';
  const ANUMA: TGGMLNumaStrategy = TGGMLNumaStrategy.
  GGML_NUMA_STRATEGY_DISABLED; const AChatFormat: string = '';
  const ATypeK: TGGMLType = TGGMLType.GGML_TYPE_F32;
  const ATypeV: TGGMLType = TGGMLType.GGML_TYPE_F32;
  const ASPMInfill: Boolean = False; const AVerbose: Boolean = True);
begin
  FNGpuLayers := ANGpuLayers;
  FSplitMode := ASplitMode;
  FMainGpu := AMainGpu;
  FTensorSplit := ATensorSplit;
  FRpcServers := ARpcServers;
  FVocabOnly := AVocabOnly;
  FUseMMap := AUseMMap;
  FUseMLock := AUseMLock;
  FKVOverrides := AKVOverrides;
  FSeed := ASeed;
  FNCtx := ANCtx;
  FNBatch := ANBatch;
  FNUBatch := ANUBatch;
  FNThreads := ANThreads;
  FNThreadsBatch := ANThreadsBatch;
  FRopeScalingType := ARopeScalingType;
  FPoolingType := APoolingType;
  FRopeFreqBase := ARopeFreqBase;
  FRopeFreqScale := ARopeFreqScale;
  FYarnExtFactor := AYarnExtFactor;
  FYarnAttnFactor := AYarnAttnFactor;
  FYarnBetaFast := AYarnBetaFast;
  FYarnBetaSlow := AYarnBetaSlow;
  FYarnOrigCtx := AYarnOrigCtx;
  FLogitsAll := ALogitsAll;
  FEmbeddings := AEmbeddings;
  FOffloadKQV := AOffloadKQV;
  FFlashAttn := AFlashAttn;
  FLastNTokensSize := ALastNTokensSize;
  FLoraBase := ALoraBase;
  FLoraScale := ALoraScale;
  FLoraPath := ALoraPath;
  FNUMA := ANUMA;
  FChatFormat := AChatFormat;
  FTypeK := ATypeK;
  FTypeV := ATypeV;
  FSPMInfill := ASPMInfill;
  FVerbose := AVerbose;
end;


procedure TLlamaSettings.Assign(Source: TPersistent);
var
  LSource: TLlamaSettings;
begin
  if Source is TLlamaSettings then
  begin
    LSource := TLlamaSettings(Source);
    FNGpuLayers := LSource.FNGpuLayers;
    FSplitMode := LSource.FSplitMode;
    FMainGpu := LSource.FMainGpu;
    FTensorSplit := Copy(LSource.FTensorSplit, 0, Length(LSource.FTensorSplit));
    FRpcServers := LSource.FRpcServers;
    FVocabOnly := LSource.FVocabOnly;
    FUseMMap := LSource.FUseMMap;
    FUseMLock := LSource.FUseMLock;
    FKVOverrides := Copy(LSource.FKVOverrides, 0, Length(LSource.FKVOverrides));
    FSeed := LSource.FSeed;
    FNCtx := LSource.FNCtx;
    FNBatch := LSource.FNBatch;
    FNUBatch := LSource.FNUBatch;
    FNThreads := LSource.FNThreads;
    FNThreadsBatch := LSource.FNThreadsBatch;
    FRopeScalingType := LSource.FRopeScalingType;
    FPoolingType := LSource.FPoolingType;
    FRopeFreqBase := LSource.FRopeFreqBase;
    FRopeFreqScale := LSource.FRopeFreqScale;
    FYarnExtFactor := LSource.FYarnExtFactor;
    FYarnAttnFactor := LSource.FYarnAttnFactor;
    FYarnBetaFast := LSource.FYarnBetaFast;
    FYarnBetaSlow := LSource.FYarnBetaSlow;
    FYarnOrigCtx := LSource.FYarnOrigCtx;
    FLogitsAll := LSource.FLogitsAll;
    FEmbeddings := LSource.FEmbeddings;
    FOffloadKQV := LSource.FOffloadKQV;
    FFlashAttn := LSource.FFlashAttn;
    FLastNTokensSize := LSource.FLastNTokensSize;
    FLoraBase := LSource.FLoraBase;
    FLoraScale := LSource.FLoraScale;
    FLoraPath := LSource.FLoraPath;
    FNUMA := LSource.FNUMA;
    FChatFormat := LSource.FChatFormat;
    FTypeK := LSource.FTypeK;
    FTypeV := LSource.FTypeV;
    FSPMInfill := LSource.FSPMInfill;
    FVerbose := LSource.FVerbose;
  end
  else
    inherited Assign(Source);
end;

{ TLlamaSamplerSettings }

class function TLlamaSamplerSettings.Create(const ATopK: Integer = 40;
  const ATopP: Single = 0.95; const AMinP: Single = 0.05;
  const ATypicalP: Single = 1.0; const ATemp: Single = 0.80;
  const ARepeatPenalty: Single = 1.0; const AFrequencyPenalty: Single = 0.0;
  const APresencePenalty: Single = 0.0; const ATfsZ: Single = 1.0;
  const AMirostatMode: Integer = 0; const AMirostatEta: Single = 0.1;
  const AMirostatTau: Single = 5.0; const APenalizeNL: Boolean = True
): TLlamaSamplerSettings;
begin
  Result := Default (TLlamaSamplerSettings);

  Result.TopK := ATopK;
  Result.TopP := ATopP;
  Result.MinP := AMinP;
  Result.TypicalP := ATypicalP;
  Result.Temp := ATemp;
  Result.RepeatPenalty := ARepeatPenalty;
  Result.FrequencyPenalty := AFrequencyPenalty;
  Result.PresencePenalty := APresencePenalty;
  Result.TfsZ := ATfsZ;
  Result.MirostatMode := AMirostatMode;
  Result.MirostatEta := AMirostatEta;
  Result.MirostatTau := AMirostatTau;
  Result.PenalizeNL := APenalizeNL;
end;

{ TLlamaCompletionSettings }

class function TLlamaCompletionSettings.Create(const ASuffix: string;
  AMaxTokens: Integer; ATemperature, ATopP, AMinP, ATypicalP: Single;
  ALogprobs: integer; AEcho: Boolean; AStop: TArray<string>; AFrequencyPenalty,
  APresencePenalty, ARepeatPenalty: Single; ATopK: Integer;
  ASeed: UInt32; ATfsZ: Single; AMirostatMode: Integer; AMirostatTau,
  AMirostatEta: Single; AModelName: string;
  ALogitBias: TArray<TPair<integer, single>>): TLlamaCompletionSettings;
begin
  Result := Default (TLlamaCompletionSettings);

  Result.Suffix := ASuffix;
  Result.MaxTokens := AMaxTokens;
  Result.Temperature := ATemperature;
  Result.TopP := ATopP;
  Result.MinP := AMinP;
  Result.TypicalP := ATypicalP;
  Result.Logprobs := ALogprobs;
  Result.Echo := AEcho;
  Result.Stop := AStop;
  Result.FrequencyPenalty := AFrequencyPenalty;
  Result.PresencePenalty := APresencePenalty;
  Result.RepeatPenalty := ARepeatPenalty;
  Result.TopK := ATopK;
  Result.Seed := ASeed;
  Result.TfsZ := ATfsZ;
  Result.MirostatMode := AMirostatMode;
  Result.MirostatTau := AMirostatTau;
  Result.MirostatEta := AMirostatEta;
  Result.ModelName := AModelName;
  Result.LogitBias := ALogitBias;
end;

function TLlamaCompletionSettings.ToGeneratorSettings: TLlamaSamplerSettings;
begin
  Result := TLlamaSamplerSettings.Create();
  Result.TopK := Self.TopK;
  Result.TopP := Self.TopP;
  Result.MinP := Self.MinP;
  Result.TypicalP := Self.TypicalP;
  Result.Temp := Self.Temperature;
  Result.TFSZ := Self.TFSZ;
  Result.MirostatMode := Self.MirostatMode;
  Result.MirostatTau := Self.MirostatTau;
  Result.MirostatEta := Self.MirostatEta;
  Result.FrequencyPenalty := Self.FrequencyPenalty;
  Result.PresencePenalty := Self.PresencePenalty;
  Result.RepeatPenalty := Self.RepeatPenalty;
end;

{ TLlamaChatCompletionSettings }

constructor TLlamaChatCompletionSettings.Create(
  const AMessages: TArray<TChatCompletionRequestMessage>;
  const AFunctions: TArray<TChatCompletionFunction>;
  const AFunctionCall: TChatCompletionRequestFunctionCall;
  const ATools: TArray<TChatCompletionTool>;
  const AToolChoice: TChatCompletionToolChoiceOption;
  const AResponseFormat: TChatCompletionRequestResponseFormat;
  const ATemperature: Single = 0.2;
  const ATopP: Single = 0.95;
  const ATopK: Integer = 40;
  const AStream: Boolean = False;
  const AStop: TArray<string> = [];
  const ASeed: UInt32 = 0;
  const AMaxTokens: Integer = 0;
  const APresencePenalty: Single = 0.0;
  const AFrequencyPenalty: Single = 0.0;
  const ARepeatPenalty: Single = 1.1;
  const AModelName: string = '';
  const ALogitBias: TArray<TPair<integer, Single>> = nil;
  const AMinP: Single = 0.05;
  const ATypicalP: Single = 1.0;
  const ATfsZ: Single = 1.0;
  const AMirostatMode: Integer = 0;
  const AMirostatTau: Single = 5.0;
  const AMirostatEta: Single = 0.1;
  const ALogprobs: integer = 0;
  const ATopLogprobs: Integer = 0
);
begin
  Messages := AMessages;
  Functions := AFunctions;
  FunctionCall := AFunctionCall;
  Tools := ATools;
  ToolChoice := AToolChoice;
  ResponseFormat := AResponseFormat;
  Temperature := ATemperature;
  TopP := ATopP;
  TopK := ATopK;
  Stream := AStream;
  Stop := AStop;
  Seed := ASeed;
  MaxTokens := AMaxTokens;
  PresencePenalty := APresencePenalty;
  FrequencyPenalty := AFrequencyPenalty;
  RepeatPenalty := ARepeatPenalty;
  ModelName := AModelName;
  LogitBias := ALogitBias;
  MinP := AMinP;
  TypicalP := ATypicalP;
  TfsZ := ATfsZ;
  MirostatMode := AMirostatMode;
  MirostatTau := AMirostatTau;
  MirostatEta := AMirostatEta;
  Logprobs := ALogprobs;
  TopLogprobs := ATopLogprobs;
end;

constructor TLlamaChatCompletionSettings.Create(
  const AMessages: TArray<TChatCompletionRequestMessage>);
begin
  Create(
    AMessages,
    nil,
    Default(TChatCompletionRequestFunctionCall),
    nil,
    Default(TChatCompletionToolChoiceOption),
    Default(TChatCompletionRequestResponseFormat));
end;

function TLlamaChatCompletionSettings.ToLlamaCompletionSettings: TLlamaCompletionSettings;
begin
  Result := Default(TLlamaCompletionSettings);
  Result.Suffix := String.Empty;
  Result.MaxTokens := Self.MaxTokens;
  Result.Temperature := Self.Temperature;
  Result.TopP := Self.TopP;
  Result.MinP := Self.MinP;
  Result.TypicalP := Self.TypicalP;
  Result.Logprobs := Self.Logprobs;
  Result.Echo := false;
  Result.Stop := Self.Stop;
  Result.FrequencyPenalty := Self.FrequencyPenalty;
  Result.PresencePenalty := Self.PresencePenalty;
  Result.RepeatPenalty := Self.RepeatPenalty;
  Result.TopK := Self.TopK;
  Result.Seed := Self.Seed;
  Result.TfsZ := Self.TfsZ;
  Result.MirostatMode := Self.MirostatMode;
  Result.MirostatTau := Self.MirostatTau;
  Result.MirostatEta := Self.MirostatEta;
  Result.ModelName := Self.ModelName;
  Result.LogitBias := Self.LogitBias;
end;

end.
