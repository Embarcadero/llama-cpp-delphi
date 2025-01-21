unit LlamaCpp.ChatCompletion;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Types;

type
  TLlamaChatCompletion = class(TInterfacedObject, ILlamaChatCompletion)
  private
    FSettings: TLlamaSettings;
    FTokenization: ILlamaTokenization;
    FCompletion: ILlamaCompletion;
    FChatHandler: ILlamaChatCompletionHandler;
    FChatHandlers: TDictionary<string, ILlamaChatCompletionHandler>;
  private
    function TokenizationTask(
      const AText: string;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false)
      : TArray<integer>;
    function CreateCompletionTask(
      const ATokens: TArray<integer>;
      ASettings: TLlamaCompletionSettings;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
      : TCreateCompletionResponse;
    procedure CreateCompletionTaskAsync(
      const ATokens: TArray<integer>;
      ASettings: TLlamaCompletionSettings;
      const ACallback: TCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil);

    function GetChatCompletionHandler(): ILlamaChatCompletionHandler;
  public
    constructor Create(const ALlama: ILlama);

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

implementation

uses
  LlamaCpp.Common.Chat.Completion.Collection;

{ TLlamaChatCompletion }

constructor TLlamaChatCompletion.Create(const ALlama: ILlama);
begin
  FSettings := ALlama.Settings;
  FChatHandler := ALlama.ChatHandler;
  FChatHandlers := ALlama.ChatHandlers;
  FTokenization := (ALlama as ILlamaTokenization);
  FCompletion := (ALlama as ILlamaCompletion);
end;

function TLlamaChatCompletion.TokenizationTask(const AText: string;
  const AAddSpecial, AParseSpecial: boolean): TArray<integer>;
begin
  Result := FTokenization.Encode(AText, AAddSpecial, AParseSpecial);
end;

function TLlamaChatCompletion.CreateCompletionTask(
  const ATokens: TArray<integer>;
  ASettings: TLlamaCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList = nil;
  const ALogitsProcessor: ILogitsProcessorList = nil;
  const AGrammar: ILlamaGrammar = nil): TCreateCompletionResponse;
begin
  Result := FCompletion.CreateCompletion(ATokens, ASettings,
    AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

procedure TLlamaChatCompletion.CreateCompletionTaskAsync(
  const ATokens: TArray<integer>; ASettings: TLlamaCompletionSettings;
  const ACallback: TCompletionCallback;
  const AStoppingCriteria: IStoppingCriteriaList = nil;
  const ALogitsProcessor: ILogitsProcessorList = nil;
  const AGrammar: ILlamaGrammar = nil);
begin
  FCompletion.CreateCompletion(ATokens, ASettings, ACallback,
    AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

function TLlamaChatCompletion.GetChatCompletionHandler: ILlamaChatCompletionHandler;
begin
  if Assigned(FChatHandler) then
    Result := FChatHandler
  else if FChatHandlers.ContainsKey(FSettings.ChatFormat) then
    Result := FChatHandlers[FSettings.ChatFormat]
  else
    Result := TLlamaChatCompletionCollection
      .Instance.GetChatCompletionHandler(FSettings.ChatFormat);
end;

function TLlamaChatCompletion.CreateChatCompletion(
  const ASettings: TLlamaChatCompletionSettings;
  const AStoppingCriteria: IStoppingCriteriaList = nil;
  const ALogitsProcessor: ILogitsProcessorList = nil;
  const AGrammar: ILlamaGrammar = nil): TCreateChatCompletionResponse;
var
  LHandler: ILlamaChatCompletionHandler;
begin
  LHandler := GetChatCompletionHandler();

  Result := LHandler.Handle(
    ASettings, TokenizationTask, CreateCompletionTask,
    AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

procedure TLlamaChatCompletion.CreateChatCompletion(
  const ASettings: TLlamaChatCompletionSettings;
  const ACallback: TChatCompletionCallback;
  const AStoppingCriteria: IStoppingCriteriaList = nil;
  const ALogitsProcessor: ILogitsProcessorList = nil;
  const AGrammar: ILlamaGrammar = nil);
var
  LHandler: ILlamaChatCompletionHandler;
begin
  LHandler := GetChatCompletionHandler();

  LHandler.Handle(
    ASettings, TokenizationTask, CreateCompletionTaskAsync, ACallback,
    AStoppingCriteria, ALogitsProcessor, AGrammar);
end;

end.
