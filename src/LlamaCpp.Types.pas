unit LlamaCpp.Types;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.CType.Llama,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Wrapper.LlamaContext,
  LlamaCpp.Wrapper.LlamaBatch,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.State,
  LlamaCpp.Common.Sampling.Sampler,
  LlamaCpp.Common.Chat.Types;

type
  ILlamaTokenization = interface
    ['{370B06E0-073B-4305-A35F-60B32DD93FA0}']
    function Tokenize(
      const AText: TBytes;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false)
      : TArray<integer>;
    function Detokenize(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false)
      : TBytes;

    function Encode(
      const AText: string;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false)
      : TArray<integer>;
    function Decode(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false)
      : string;
  end;

  ILlamaEvaluator = interface
    ['{5B29A173-C2E2-42A1-9C38-78882BE84FF2}']
    procedure Eval(const ATokens: TArray<integer>);
  end;

  ILlamaSampler = interface
    ['{2E2E3727-B735-485F-A049-736B2CEB4DE5}']
    procedure InitSampler(
      const AInputIds: TArray<integer>;
      const ASettings: TLlamaSamplerSettings;
      const ASampler: TLlamaSampler;
      const ALogitsProcessor: ILogitsProcessorList;
      const AGrammar: ILlamaGrammar);

    function Sample(
      const ANumberOfTokens: integer;
      const ASettings: TLlamaSamplerSettings;
      const ASampler: LlamaCpp.Common.Sampling.Sampler.TLlamaSampler;
      const AIdx: integer = -1): integer;
  end;

  TGeneratorCallback = reference to function(const AToken: integer;
    var AContinue: boolean): TArray<integer>;

  ILlamaGenerator = interface
    ['{9939F90B-A942-4FB2-8C6B-11ED34A1A549}']
    procedure Generate(
            ATokens: TArray<integer>;
      const ASettings: TLlamaSamplerSettings;
      const ACallback: TGeneratorCallback;
      const AReset: boolean = true;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil);
  end;

  ILlamaEmbedding = interface
    ['{5592ACB9-A0AC-4211-A0F7-4FA348E084F8}']
    function Embed(
      const AInput: TArray<string>;
        out AReturnCount: integer;
      const ANormalize: boolean = false;
      const ATruncate: boolean = true)
    : TArray<TArray<Single>>;
    function CreateEmbedding(const AInput: TArray<string>;
      AModelName: string = ''): TCreateEmbeddingResponse;
  end;

  ILlamaCompletion = interface
    ['{E945EA10-AD4D-4545-9457-E9FB0804D3E5}']
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
      const APrompt: TArray<integer>;
      ASettings: TLlamaCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
    : TCreateCompletionResponse; overload;
    procedure CreateCompletion(
      const APrompt: TArray<integer>;
      ASettings: TLlamaCompletionSettings;
      const ACallback: TCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
  end;

  ILlamaChatCompletion = interface
    ['{352133DB-4AA1-4425-B7AA-239199AC5E6E}']
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
  end;

  ILlama = interface
    ['{EF8CB1BF-678D-498E-BEA6-6CAFFC84DDE5}']
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

    function SaveState(): TLlamaState;
    procedure LoadState(const AState: TLlamaState);

    procedure Reset();

    property ModelPath: string read GetModelPath;
    property Metadata: TMetadata read GetMetadata;
    property BOSToken: string read GetBOSToken;
    property EOSToken: string read GetEOSToken;
    property NumberOfTokens: integer read GetNumberOfTokens write SetNumberOfTokens;
    property NumberOfBatches: integer read GetNumberOfBatches;
    property InputIds: TArray<integer> read GetInputIds write SetInputIds;
    property Scores: TArray<TArray<single>> read GetScores write SetScores;
    property ModelParams: TLlamaModelParams read GetModelParams;
    property Model: TLlamaModel read GetModel;
    property ContextParams: TLlamaContextParams read GetContextParams;
    property Context: TLlamaContext read GetContext;
    property Batch: TLlamaBatch read GetBatch;
    property Settings: TLlamaSettings read GetSettings;
    property Tokenizer: ILlamaTokenizer read GetTokenizer;
    property ChatHandler: ILlamaChatCompletionHandler read GetChatHandler;
    property DraftModel: ILlamaDraftModel read GetDraftModel;
    property Cache: ILlamaCache read GetCache;
    property TemplateChoices: TDictionary<string, string> read GetTemplateChoices;
    property ChatHandlers: TDictionary<string, ILlamaChatCompletionHandler> read GetChatHandlers;
  end;

implementation

end.
