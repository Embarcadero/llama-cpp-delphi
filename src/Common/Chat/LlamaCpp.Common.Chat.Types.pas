unit LlamaCpp.Common.Chat.Types;

interface

uses
  System.SysUtils,
  System.Variants,
  System.TypInfo,
  System.Rtti,
  System.Generics.Collections,
  System.JSON.Types,
  System.JSON.Serializers,
  System.JSON.Readers,
  System.JSON.Writers;

type
  TVariantConverter = class(TJsonConverter)
  public
    function ReadJson(const AReader: TJsonReader; ATypeInf: PTypeInfo;
      const AExistingValue: TValue; const ASerializer: TJsonSerializer)
      : TValue; override;
    procedure WriteJson(const AWriter: TJsonWriter; const AValue: TValue;
      const ASerializer: TJsonSerializer); override;
  end;

  TNullableConverter = class(TVariantConverter);

  TDict<K, V> = array of TPair<K, V>;

  TNullable = variant;

  TEmbedding<T> = record
  public
    [JsonName('index')]
    Index: integer;
    [JsonName('object')]
    &Object: string;
    [JsonName('embedding')]
    Embedding: T;
  end;

  TEmbeddingUsage = record
  public
    [JsonName('prompt_tokens')]
    PromptTokens: integer;
    [JsonName('total_tokens')]
    TotalTokens: integer;
  end;

  TCreateEmbeddingResponse = record
  public
    [JsonName('object')]
    &Object: string;
    [JsonName('model')]
    Model: string;
    [JsonName('data')]
    Data: TArray<TEmbedding<TArray<Single>>>;
    [JsonName('usage')]
    Usage: TEmbeddingUsage;
  public
    constructor Create(const AModelName: string; const AData: TArray<Tarray<Single>>;
      const ATotalTokens: integer);

    function ToJsonString(): string;
    class function FromJsonString(const AJson: string): TCreateEmbeddingResponse; static;
  end;

  TChatFormatterResponse = record
  public
    [JsonName('prompt')]
    Prompt: string;
    [JsonName('stop')]
    Stop: TArray<string>;
    [JsonName('stopping_criteria')]
    //StoppingCriteria: IStoppingCriteriaList;
    [JsonName('added_special')]
    AddedSpecial: boolean;
  public
    constructor Create(const APrompt: string; const AStop: TArray<string> = nil);
  end;

  TCompletionLogprobs = record
  public
    [JsonName('text_offset')]
    TextOffset: TArray<integer>;
    [JsonName('token_logprobs')]
    TokenLogprobs: TArray<Single>;
    [JsonName('tokens')]
    Tokens: TArray<string>;
    [JsonName('top_logprobs')]
    TopLogprobs: TArray<TDict<string, Single>>;
  public
    constructor Create(const ATextOffset: TArray<Integer>;
      const ATokenLogprobs: TArray<Single>; const ATokens: TArray<string>;
      const ATopLogprobs: TArray<TDict<string, Single>>);
  end;

  TCompletionChoice = record
  public
    [JsonName('text')]
    Text: string;
    [JsonName('index')]
    Index: integer;
    [JsonName('logprobs')]
    Logprobs: TCompletionLogprobs;
    [JsonName('finish_reason')]
    FinishReason: string;
  public
    constructor Create(const AText: string; AIndex: Integer;
      const ALogprobs: TCompletionLogprobs;
      const AFinishReason: string = String.Empty); overload;
    constructor Create(const AText: string; AIndex: Integer;
      const AFinishReason: string = String.Empty); overload;
  end;

  TCompletionUsage = record
  public
    [JsonName('prompt_tokens')]
    PromptTokens: integer;
    [JsonName('completion_tokens')]
    CompletionTokens: integer;
    [JsonName('total_tokens')]
    TotalTokens: integer;
  public
    constructor Create(APromptTokens, ACompletionTokens, ATotalTokens: Integer);
  end;

  TCreateCompletionResponse = record
  public
    [JsonName('id')]
    ID: string;
    [JsonName('object')]
    &Object: string;
    [JsonName('created')]
    Created: Int64;
    [JsonName('model')]
    Model: string;
    [JsonName('choices')]
    Choices: TArray<TCompletionChoice>;
    [JsonName('usage')]
    Usage: TCompletionUsage;
  public
    constructor Create(const AID, AObject, AModel: string; ACreated: Int64;
      const AChoices: TArray<TCompletionChoice>; const AUsage: TCompletionUsage); overload;
    constructor Create(const AID, AObject, AModel: string; ACreated: Integer;
      const AChoices: TArray<TCompletionChoice>); overload;

    function ToJsonString(): string;
    class function FromJsonString(const AJson: string): TCreateCompletionResponse; static;
  end;

  TChatCompletionResponseFunctionCall = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('arguments')]
    Arguments: string;
  public
    constructor Create(const AName, AArguments: string);
  end;

  TChatCompletionMessageToolCallFunction = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('arguments')]
    Arguments: string;
  public
    constructor Create(const AName, AArguments: string);
  end;

  TChatCompletionMessageToolCall = record
  public
    [JsonName('id')]
    ID: string;
    [JsonName('type')]
    &Type: string;
    [JsonName('function')]
    &Function: TChatCompletionMessageToolCallFunction;
  public
    constructor Create(const AId, AType: string;
      const AFunction: TChatCompletionMessageToolCallFunction);
  end;

  TChatCompletionMessageToolCalls = TArray<TChatCompletionMessageToolCall>;

  TChatCompletionResponseMessage = record
  public
    [JsonName('content')]
    [JsonConverter(TNullableConverter)]
    Content: variant;
    [JsonName('tool_calls')]
    ToolCalls: TChatCompletionMessageToolCalls;
    [JsonName('role')]
    Role: string;
    [JsonName('function_call')]
    FunctionCall: TChatCompletionResponseFunctionCall;
  public
    constructor Create(const AContent: variant; const ARole: string;
      const AFunctionCall: TChatCompletionResponseFunctionCall;
      const AToolCalls: TChatCompletionMessageToolCalls);
  end;

  TChatCompletionFunction = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('description')]
    [JsonConverter(TNullableConverter)]
    Description: variant;
    [JsonName('parameters')]
    Parameters: TDict<string, variant>;
  end;

  TChatCompletionResponseChoice = record
  public
    [JsonName('index')]
    Index: integer;
    [JsonName('message')]
    &Message: TChatCompletionResponseMessage;
    [JsonName('logprobs')]
    Logprobs: TCompletionLogprobs;
    [JsonName('finish_reason')]
    [JsonConverter(TNullableConverter)]
    FinishReason: variant;
  public
    constructor Create(const AIndex: integer;
      const AMessage: TChatCompletionResponseMessage;
      const ALogprobs: TCompletionLogprobs; const AFinishReason: variant);
  end;

  TCreateChatCompletionResponse = record
  public type
    TCreateChatCompletionResponseChoices = TArray<TChatCompletionResponseChoice>;
  public
    [JsonName('id')]
    ID: string;
    [JsonName('object')]
    &Object: string;
    [JsonName('created')]
    Created: Int64;
    [JsonName('model')]
    Model: string;
    [JsonName('choices')]
    Choices: TCreateChatCompletionResponseChoices;
    [JsonName('usage')]
    Usage: TCompletionUsage;
  public
    constructor Create(const AId, AObject: string; const ACreated: Int64;
      const AModel: string; const AChoices: TCreateChatCompletionResponseChoices;
      const AUsage: TCompletionUsage);

    function ToJsonString(): string;
    class function FromJsonString(const AJson: string): TCreateChatCompletionResponse; static;
  end;

  TChatCompletionTopLogprobToken = record
  public
    [JsonName('token')]
    Token: string;
    [JsonName('logprob')]
    Logprob: single;
    [JsonName('bytes')]
    Bytes: TArray<integer>;
  public
    constructor Create(const AToken: string; const ALogprob: single;
      const ABytes: TArray<integer>);
  end;

  TChatCompletionLogprobToken = record
  public
    [JsonName('top_logprobs_token')]
    TopLogprobToken: TChatCompletionTopLogprobToken;
    [JsonName('top_logprobs')]
    TopLogprobs: TArray<TChatCompletionTopLogprobToken>;
  public
    constructor Create(
      const ATopLogprobToken: TChatCompletionTopLogprobToken;
      const ATopLogprobs: TArray<TChatCompletionTopLogprobToken>);
  end;

  TChatCompletionLogprobs = record
  public
    [JsonName('content')]
    Content: TArray<TChatCompletionLogprobToken>;
    [JsonName('refusal')]
    Refusal: TArray<TChatCompletionLogprobToken>;
  public
    constructor Create(const AContent: TArray<TChatCompletionLogprobToken>;
      const ARefusal: TArray<TChatCompletionLogprobToken>);
  end;

  TChatCompletionMessageToolCallChunkFunction = record
  public
    [JsonName('name')]
    [JsonConverter(TNullableConverter)]
    Name: variant;
    [JsonName('arguments')]
    Arguments: string;
  public
    constructor Create(const AName: variant; const AArguments: string);
  end;

  TChatCompletionMessageToolCallChunk = record
  public
    [JsonName('index')]
    Index: integer;
    [JsonName('id')]
    [JsonConverter(TNullableConverter)]
    ID: variant;
    [JsonName('type')]
    &Type: string;  // Assuming "function" is represented as a string
    [JsonName('function')]
    &Function: TChatCompletionMessageToolCallChunkFunction;
  public
    constructor Create(const AIndex: integer; const AId: variant;
      const AType: string; const AFunction: TChatCompletionMessageToolCallChunkFunction);
  end;

  TChatCompletionStreamResponseDeltaEmpty = record
  public
    // Empty record with no fields
  end;

  TChatCompletionStreamResponseDeltaFunctionCall = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('arguments')]
    Arguments: string;
  public
    constructor Create(const AName, AArguments: string);
  end;

  TChatCompletionStreamResponseDelta = record
  public type
    TChatCompletionMessageToolCallsChunk = TArray<TChatCompletionMessageToolCallChunk>;
  public
    [JsonName('content')]
    [JsonConverter(TNullableConverter)]
    Content: variant;
    [JsonName('function_call')]
    FunctionCall: TChatCompletionStreamResponseDeltaFunctionCall;
    [JsonName('tool_calls')]
    ToolCalls: TChatCompletionMessageToolCallsChunk;
    [JsonName('role')]
    [JsonConverter(TNullableConverter)]
    Role: variant;
  public
    constructor Create(const AContent: variant;
      const AFunctionCall: TChatCompletionStreamResponseDeltaFunctionCall;
      const AToolCalls: TChatCompletionMessageToolCallsChunk;
      const ARole: variant);
  end;

  TChatCompletionStreamResponseChoice = record
  public
    [JsonName('index')]
    Index: integer;
    [JsonName('delta')]
    Delta: TChatCompletionStreamResponseDelta; // TChatCompletionStreamResponseDelta or TChatCompletionStreamResponseDeltaEmpty
    [JsonName('finish_reason')]
    [JsonConverter(TNullableConverter)]
    FinishReason: variant;
    [JsonName('logprobs')]
    Logprobs: TChatCompletionLogprobs;
  public
    constructor Create(const AIndex: integer; const ADelta: TChatCompletionStreamResponseDelta;
      const AFinishReason: variant; const ALogprobs: TChatCompletionLogprobs);
  end;

  TCreateChatCompletionStreamResponse = record
  public
    [JsonName('id')]
    ID: string;
    [JsonName('model')]
    Model: string;
    [JsonName('object')]
    &Object: string;
    [JsonName('created')]
    Created: integer;
    [JsonName('choices')]
    Choices: TArray<TChatCompletionStreamResponseChoice>;
  public
    constructor Create(const AId, AModel, AObject: string; const ACreated: Int64;
      const AChoices: TArray<TChatCompletionStreamResponseChoice>);

    function ToJsonString(): string;
    class function FromJsonString(const AJson: string): TCreateChatCompletionStreamResponse; static;
  end;

  TChatCompletionFunctions = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('description')]
    [JsonConverter(TNullableConverter)]
    Description: variant;
    [JsonName('parameters')]
    Parameters: TDict<string, variant>;
  end;

  TChatCompletionFunctionCallOption = record
  public
    [JsonName('name')]
    Name: string;
  end;

  TChatCompletionRequestResponseFormat = record
  public
    [JsonName('type')]
    &Type: string;
    [JsonName('schema')]
    [JsonConverter(TNullableConverter)]
    Schema: variant;
  end;

  TChatCompletionRequestMessageContentPartText = record
  public
    [JsonName('type')]
    &Type: string;
    [JsonName('text')]
    Text: string;
  end;

  TChatCompletionRequestMessageContentPartImageImageUrl = record
  public
    [JsonName('url')]
    URL: string;
    [JsonName('detail')]
    [JsonConverter(TNullableConverter)]
    Detail: variant;
  end;

  TChatCompletionRequestMessageContentPartImage = record
  public
    [JsonName('type')]
    &Type: string;
    [JsonName('image_url')]
    [JsonConverter(TVariantConverter)]
    ImageURL: variant; //string or TChatCompletionRequestMessageContentPartImageImageUrl
  end;

  //TChatCompletionRequestMessageContentPartText,
  //TChatCompletionRequestMessageContentPartImage,
  TChatCompletionRequestMessageContentPart = record
  public
    [JsonName('type')]
    &Type: string;
    [JsonName('text')]
    [JsonConverter(TNullableConverter)]
    Text: variant;  // Nullable, for TChatCompletionRequestMessageContentPartText
    [JsonName('image_url')]
    [JsonConverter(TVariantConverter)]
    ImageURL: variant;  // Nullable, for TChatCompletionRequestMessageContentPartImage (//string or TChatCompletionRequestMessageContentPartImageImageUrl)
  end;

  TChatCompletionRequestSystemMessage = record
  public
    [JsonName('role')]
    Role: string;
    [JsonName('content')]
    [JsonConverter(TNullableConverter)]
    Content: variant;
  end;

  TChatCompletionRequestUserMessage = record
  public
    [JsonName('role')]
    Role: string;
    [JsonName('content')]
    [JsonConverter(TVariantConverter)]
    Content: variant;  // String or TArray<TChatCompletionRequestMessageContentPart>
  end;

  TChatCompletionRequestAssistantMessageFunctionCall = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('arguments')]
    Arguments: string;
  end;

  TChatCompletionRequestAssistantMessage = record
  public
    [JsonName('role')]
    Role: string;
    [JsonName('content')]
    [JsonConverter(TNullableConverter)]
    Content: variant;
    [JsonName('tool_calls')]
    ToolCalls: TChatCompletionMessageToolCalls;
    [JsonName('function_call')]
    FunctionCall: TChatCompletionRequestAssistantMessageFunctionCall;
  end;

  TChatCompletionRequestToolMessage = record
  public
    [JsonName('role')]
    Role: string;
    [JsonName('content')]
    [JsonConverter(TNullableConverter)]
    Content: variant;
    [JsonName('tool_call_id')]
    ToolCallID: string;
  end;

  TChatCompletionRequestFunctionMessage = record
  public
    [JsonName('role')]
    Role: string;
    [JsonName('content')]
    [JsonConverter(TNullableConverter)]
    Content: variant;
    [JsonName('name')]
    Name: string;
  end;

  //TChatCompletionRequestSystemMessage,
  //TChatCompletionRequestUserMessage,
  //TChatCompletionRequestAssistantMessage,
  //TChatCompletionRequestUserMessage,
  //TChatCompletionRequestToolMessage,
  //TChatCompletionRequestFunctionMessage,
  TChatCompletionRequestMessage = record
  public
    [JsonName('role')]
    Role: string;  // "system", "user", "assistant", "tool", "function" represented as strings
    [JsonName('content')]
    [JsonConverter(TVariantConverter)]
    Content: variant;
    [JsonName('tool_calls')]
    ToolCalls: TChatCompletionMessageToolCalls;  // For tool-related messages
    [JsonName('tool_call_id')]
    ToolCallID: string;  // For tool message
    [JsonName('name')]
    Name: string;  // For function messages
    [JsonName('function_call')]
    FunctionCall: TChatCompletionRequestAssistantMessageFunctionCall;
  public
    class function System(const AContent: variant)
      : TChatCompletionRequestMessage; static;
    class function User(const AContent: variant)
      : TChatCompletionRequestMessage; static;
    class function Assistant(const AContent: variant;
      const AToolCalls: TChatCompletionMessageToolCalls;
      const AFunctionCall: TChatCompletionRequestAssistantMessageFunctionCall)
        : TChatCompletionRequestMessage; overload; static;
    class function Assistant(const AContent: variant)
        : TChatCompletionRequestMessage; overload; static;
    class function Tool(const AContent: variant; const AToolCallId: string)
      : TChatCompletionRequestMessage; static;
    class function &Function(const AContent: variant; const AName: string)
      : TChatCompletionRequestMessage; static;

    // Helper methods
    class function ToString(
      const AMessages: TArray<TChatCompletionRequestMessage>): string; static;
  end;

  TChatCompletionRequestFunctionCallOption = record
  public
    [JsonName('name')]
    Name: string;
  public
    constructor Create(const AName: string);
  end;

  //"none", "auto", TChatCompletionRequestFunctionCallOption
  TChatCompletionRequestFunctionCall = record
  public
    [JsonName('name')]
    Option: TChatCompletionRequestFunctionCallOption;
  public
    constructor Create(const AOption: TChatCompletionRequestFunctionCallOption);
  end;

  TChatCompletionFunctionParameters = TDict<string, variant>;

  TChatCompletionToolFunction = record
  public
    [JsonName('name')]
    Name: string;
    [JsonName('description')]
    [JsonConverter(TNullableConverter)]
    Description: variant;  // Nullable, description can be a string or absent
    [JsonName('parameters')]
    Parameters: TChatCompletionFunctionParameters;  // Dictionary of function parameters
  public
    constructor Create(const AName: string; const ADescription: string;
      const AParameters: TChatCompletionFunctionParameters);
  end;

  TChatCompletionTool = record
  public
    [JsonName('type')]
    &Type: string;  // "function" represented as a string
    [JsonName('function')]
    &Function: TChatCompletionToolFunction;
  public
    constructor Create(const AFunction: TChatCompletionToolFunction;
      const AType: string = 'function');
  end;

  TChatCompletionNamedToolChoiceFunction = record
  public
    [JsonName('name')]
    Name: string;
  public
    constructor Create(const AName: string);
  end;

  TChatCompletionNamedToolChoice = record
  public
    [JsonName('type')]
    &Type: string;  // "function" represented as a string
    [JsonName('function')]
    &Function: TChatCompletionNamedToolChoiceFunction;
  public
    constructor Create(const AFunction: TChatCompletionNamedToolChoiceFunction;
      const AType: string = 'function');
  end;

  //"none", "auto", "required", TChatCompletionNamedToolChoice
  TChatCompletionToolChoiceOption = record
  public
    [JsonName('name')]
    Choice: TChatCompletionNamedToolChoice;
  public
    constructor Create(const AChoice: TChatCompletionNamedToolChoice);
  end;

  TEmbeddingData = TEmbedding<TArray<TArray<Single>>>;
  TCompletionChunk = TCreateCompletionResponse;
  TCompletion = TCreateCompletionResponse;
  TCreateCompletionStreamResponse = TCreateCompletionResponse;
  TChatCompletionMessage = TChatCompletionResponseMessage;
  TChatCompletionChoice = TChatCompletionResponseChoice;
  TChatCompletion = TCreateChatCompletionResponse;
  TChatCompletionChunkDeltaEmpty = TChatCompletionStreamResponseDeltaEmpty;
  TChatCompletionChunkChoice = TChatCompletionStreamResponseChoice;
  TChatCompletionChunkDelta = TChatCompletionStreamResponseDelta;
  TChatCompletionChunk = TCreateChatCompletionStreamResponse;
  TChatCompletionStreamResponse = TCreateChatCompletionStreamResponse;
  TChatCompletionResponseFunction = TChatCompletionFunction;
  TChatCompletionFunctionCall = TChatCompletionResponseFunctionCall;

  TChatCompletionFunctionParametersHelper = record helper for TChatCompletionFunctionParameters
  public
    function ToJsonString(): string;
  end;

implementation

var
  GlobalSerializer: TJSONSerializer;

{ TVariantConverter }

function TVariantConverter.ReadJson(const AReader: TJsonReader;
  ATypeInf: PTypeInfo; const AExistingValue: TValue;
  const ASerializer: TJsonSerializer): TValue;
begin
  var
  LData := AReader.Value.AsType<variant>;

  if VarIsEmpty(LData) or VarIsNull(LData) then
    Exit(TValue.FromVariant(Null));

  case System.Variants.VarType(LData) of
    varInteger, varShortInt, varWord, varByte, varLongWord:
      Result := TValue.FromVariant(LData);
    varString, varUString:
      Result := TValue.FromVariant(LData);
  end;
end;

procedure TVariantConverter.WriteJson(const AWriter: TJsonWriter;
  const AValue: TValue; const ASerializer: TJsonSerializer);
begin
  var
  LData := AValue.AsType<variant>;

  if VarIsEmpty(LData) or VarIsNull(LData) then
    Exit();

  case System.Variants.VarType(LData) of
    varInteger, varShortInt, varWord, varByte, varLongWord:
      AWriter.WriteValue(integer(LData));
    varString, varUString:
      AWriter.WriteValue(VarToStr(LData));
  end;
end;

{ TCreateEmbeddingResponse }

constructor TCreateEmbeddingResponse.Create(const AModelName: string;
  const AData: TArray<Tarray<Single>>; const ATotalTokens: integer);
var
  I: integer;
  LEmbdList: TList<LlamaCpp.Common.Chat.Types.TEmbedding<TArray<Single>>>;
begin
  LEmbdList := TList<LlamaCpp.Common.Chat.Types.TEmbedding<TArray<Single>>>.Create();
  try
    for I := Low(AData) to High(AData) do
    begin
       var LEmbd := Default(LlamaCpp.Common.Chat.Types.TEmbedding<TArray<Single>>);
       LEmbd.&Object := 'embedding';
       LEmbd.Index := I;
       LEmbd.Embedding := AData[I];

       LEmbdList.Add(LEmbd);
    end;

    Self.&Object := 'list';
    Self.Model := AModelName;
    Self.Data := LEmbdList.ToArray();

    Self.Usage := Default(LlamaCpp.Common.Chat.Types.TEmbeddingUsage);
    Self.Usage.PromptTokens := ATotalTokens;
    Self.Usage.TotalTokens := ATotalTokens;
  finally
    LEmbdList.Free();
  end;
end;

function TCreateEmbeddingResponse.ToJsonString: string;
begin
  Result := GlobalSerializer.Serialize<TCreateEmbeddingResponse>(Self);
end;

class function TCreateEmbeddingResponse.FromJsonString(
  const AJson: string): TCreateEmbeddingResponse;
begin
  Result := GlobalSerializer.Deserialize<TCreateEmbeddingResponse>(AJson);
end;

{ TChatFormatterResponse }

constructor TChatFormatterResponse.Create(const APrompt: string;
  const AStop: TArray<string> = nil);
begin
  Prompt := APrompt;
  Stop := AStop;
end;

{ TCompletionLogprobs }

constructor TCompletionLogprobs.Create(const ATextOffset: TArray<Integer>;
  const ATokenLogprobs: TArray<Single>; const ATokens: TArray<string>;
  const ATopLogprobs: TArray<TDict<string, Single>>);
begin
  Self.TextOffset := ATextOffset;
  Self.TokenLogprobs := ATokenLogprobs;
  Self.Tokens := ATokens;
  Self.TopLogprobs := ATopLogprobs;
end;

{ TCreateCompletionResponse }

constructor TCreateCompletionResponse.Create(const AID, AObject, AModel: string;
  ACreated: Int64; const AChoices: TArray<TCompletionChoice>;
  const AUsage: TCompletionUsage);
begin
  Self.ID := AID;
  Self.&Object := AObject;
  Self.Created := ACreated;
  Self.Model := AModel;
  Self.Choices := AChoices;
  Self.Usage := AUsage;
end;

constructor TCreateCompletionResponse.Create(const AID, AObject, AModel: string;
  ACreated: Integer; const AChoices: TArray<TCompletionChoice>);
begin
  Create(AID, AObject, AModel, ACreated, AChoices, Default(TCompletionUsage));
end;

function TCreateCompletionResponse.ToJsonString: string;
begin
  Result := GlobalSerializer.Serialize<TCreateCompletionResponse>(Self);
end;

class function TCreateCompletionResponse.FromJsonString(
  const AJson: string): TCreateCompletionResponse;
begin
  Result := GlobalSerializer.Deserialize<TCreateCompletionResponse>(AJson);
end;

{ TChatCompletionMessageToolCallFunction }

constructor TChatCompletionMessageToolCallFunction.Create(const AName,
  AArguments: string);
begin
  Name := AName;
  Arguments := AArguments;
end;

{ TChatCompletionMessageToolCall }

constructor TChatCompletionMessageToolCall.Create(const AId, AType: string;
  const AFunction: TChatCompletionMessageToolCallFunction);
begin
  Id := AId;
  &Type := AType;
  &Function := AFunction;
end;

{ TChatCompletionResponseMessage }

constructor TChatCompletionResponseMessage.Create(const AContent: variant;
  const ARole: string;
  const AFunctionCall: TChatCompletionResponseFunctionCall;
  const AToolCalls: TChatCompletionMessageToolCalls);
begin
  Content := AContent;
  Role := ARole;
  FunctionCall := AFunctionCall;
  ToolCalls := AToolCalls;
end;

{ TChatCompletionResponseChoice }

constructor TChatCompletionResponseChoice.Create(const AIndex: integer;
  const AMessage: TChatCompletionResponseMessage;
  const ALogprobs: TCompletionLogprobs; const AFinishReason: variant);
begin
  Index := AIndex;
  &Message := AMessage;
  Logprobs := ALogprobs;
  FinishReason := AFinishReason;
end;

{ TCreateChatCompletionResponse }

constructor TCreateChatCompletionResponse.Create(const AId, AObject: string;
  const ACreated: Int64; const AModel: string;
  const AChoices: TCreateChatCompletionResponseChoices;
  const AUsage: TCompletionUsage);
begin
  Id := AId;
  &Object := AObject;
  Created := ACreated;
  Model := AModel;
  Choices := AChoices;
  Usage := AUsage;
end;

function TCreateChatCompletionResponse.ToJsonString: string;
begin
  Result := GlobalSerializer.Serialize<TCreateChatCompletionResponse>(Self);
end;

class function TCreateChatCompletionResponse.FromJsonString(
  const AJson: string): TCreateChatCompletionResponse;
begin
  Result := GlobalSerializer.Deserialize<TCreateChatCompletionResponse>(AJson);
end;

{ TChatCompletionLogprobs }

constructor TChatCompletionLogprobs.Create(const AContent,
  ARefusal: TArray<TChatCompletionLogprobToken>);
begin
  Content := AContent;
  Refusal := ARefusal;
end;

{ TChatCompletionTopLogprobToken }

constructor TChatCompletionTopLogprobToken.Create(const AToken: string;
  const ALogprob: single; const ABytes: TArray<integer>);
begin
  Token := AToken;
  Logprob := ALogprob;
  Bytes := ABytes;
end;

{ TChatCompletionLogprobToken }

constructor TChatCompletionLogprobToken.Create(
  const ATopLogprobToken: TChatCompletionTopLogprobToken;
  const ATopLogprobs: TArray<TChatCompletionTopLogprobToken>);
begin
  TopLogprobToken := ATopLogprobToken;
  TopLogprobs := ATopLogprobs;
end;

{ TChatCompletionMessageToolCallChunkFunction }

constructor TChatCompletionMessageToolCallChunkFunction.Create(
  const AName: variant; const AArguments: string);
begin
  Name := AName;
  Arguments := AArguments;
end;

{ TChatCompletionMessageToolCallChunk }

constructor TChatCompletionMessageToolCallChunk.Create(const AIndex: integer;
  const AId: variant; const AType: string;
  const AFunction: TChatCompletionMessageToolCallChunkFunction);
begin
  Index := AIndex;
  Id := AId;
  &Type := AType;
  &Function := AFunction;
end;

{ TChatCompletionStreamResponseDeltaFunctionCall }

constructor TChatCompletionStreamResponseDeltaFunctionCall.Create(const AName,
  AArguments: string);
begin
  Name := AName;
  Arguments := AArguments;
end;

{ TChatCompletionStreamResponseDelta }

constructor TChatCompletionStreamResponseDelta.Create(const AContent: variant;
  const AFunctionCall: TChatCompletionStreamResponseDeltaFunctionCall;
  const AToolCalls: TChatCompletionMessageToolCallsChunk; const ARole: variant);
begin
  Content := AContent;
  FunctionCall := AFunctionCall;
  ToolCalls := AToolCalls;
  Role := ARole;
end;

{ TChatCompletionStreamResponseChoice }

constructor TChatCompletionStreamResponseChoice.Create(const AIndex: integer;
  const ADelta: TChatCompletionStreamResponseDelta; const AFinishReason: variant;
  const ALogprobs: TChatCompletionLogprobs);
begin
  Index := AIndex;
  Delta := ADelta;
  FinishReason := AFinishReason;
  Logprobs := ALogprobs;
end;

{ TCreateChatCompletionStreamResponse }

constructor TCreateChatCompletionStreamResponse.Create(const AId, AModel,
  AObject: string; const ACreated: Int64;
  const AChoices: TArray<TChatCompletionStreamResponseChoice>);
begin
  Id := AId;
  Model := AModel;
  &Object := AObject;
  Created := ACreated;
  Choices := AChoices;
end;

class function TCreateChatCompletionStreamResponse.FromJsonString(
  const AJson: string): TCreateChatCompletionStreamResponse;
begin
  Result := GlobalSerializer.Deserialize<TCreateChatCompletionStreamResponse>(AJson);
end;

function TCreateChatCompletionStreamResponse.ToJsonString: string;
begin
  Result := GlobalSerializer.Serialize<TCreateChatCompletionStreamResponse>(Self);
end;

{ TCompletionChoice }

constructor TCompletionChoice.Create(const AText: string; AIndex: Integer;
  const ALogprobs: TCompletionLogprobs; const AFinishReason: string);
begin
  Self.Text := AText;
  Self.Index := AIndex;
  Self.Logprobs := ALogprobs;
  Self.FinishReason := AFinishReason;
end;

constructor TCompletionChoice.Create(const AText: string; AIndex: Integer;
  const AFinishReason: string);
begin
  Create(AText, AIndex, Default(TCompletionLogprobs), AFinishReason);
end;

{ TCompletionUsage }

constructor TCompletionUsage.Create(APromptTokens, ACompletionTokens,
  ATotalTokens: Integer);
begin
  Self.PromptTokens := APromptTokens;
  Self.CompletionTokens := ACompletionTokens;
  Self.TotalTokens := ATotalTokens;
end;

{ TChatCompletionRequestFunctionCallOption }

constructor TChatCompletionRequestFunctionCallOption.Create(
  const AName: string);
begin
  Name := AName;
end;

{ TChatCompletionRequestFunctionCall }

constructor TChatCompletionRequestFunctionCall.Create(
  const AOption: TChatCompletionRequestFunctionCallOption);
begin
  Option := AOption;
end;

{ TChatCompletionToolFunction }

constructor TChatCompletionToolFunction.Create(const AName,
  ADescription: string; const AParameters: TChatCompletionFunctionParameters);
begin
  Name := AName;
  Description := ADescription;
  Parameters := AParameters;
end;

{ TChatCompletionTool }

constructor TChatCompletionTool.Create(
  const AFunction: TChatCompletionToolFunction; const AType: string);
begin
  &Function := AFunction;
  &Type := AType;
end;

{ TChatCompletionNamedToolChoiceFunction }

constructor TChatCompletionNamedToolChoiceFunction.Create(const AName: string);
begin
  Name := AName;
end;

{ TChatCompletionNamedToolChoice }

constructor TChatCompletionNamedToolChoice.Create(
  const AFunction: TChatCompletionNamedToolChoiceFunction; const AType: string);
begin
  &Type := AType;
  &Function := AFunction;
end;

{ TChatCompletionToolChoiceOption }

constructor TChatCompletionToolChoiceOption.Create(
  const AChoice: TChatCompletionNamedToolChoice);
begin
  Choice := AChoice;
end;

{ TChatCompletionFunctionParametersHelper }

function TChatCompletionFunctionParametersHelper.ToJsonString: string;
begin
  Result := GlobalSerializer.Serialize<TChatCompletionFunctionParameters>(Self);
end;

{ TChatCompletionResponseFunctionCall }

constructor TChatCompletionResponseFunctionCall.Create(const AName,
  AArguments: string);
begin
  Name := AName;
  Arguments := AArguments;
end;

{ TChatCompletionRequestMessage }

class function TChatCompletionRequestMessage.System(
  const AContent: variant): TChatCompletionRequestMessage;
begin
  Result := Default(TChatCompletionRequestMessage);
  Result.Role := 'system';
  Result.Content := AContent;
end;

class function TChatCompletionRequestMessage.User(
  const AContent: variant): TChatCompletionRequestMessage;
begin
  Result := Default(TChatCompletionRequestMessage);
  Result.Role := 'user';
  Result.Content := AContent;
end;

class function TChatCompletionRequestMessage.Assistant(const AContent: variant;
  const AToolCalls: TChatCompletionMessageToolCalls;
  const AFunctionCall: TChatCompletionRequestAssistantMessageFunctionCall)
  : TChatCompletionRequestMessage;
begin
  Result := Default(TChatCompletionRequestMessage);
  Result.Role := 'assistant';
  Result.Content := AContent;
  Result.ToolCalls := AToolCalls;
  Result.FunctionCall := AFunctionCall;
end;

class function TChatCompletionRequestMessage.Assistant(
  const AContent: variant): TChatCompletionRequestMessage;
begin
  Result := Assistant(
    AContent,
    Default(TChatCompletionMessageToolCalls),
    Default(TChatCompletionRequestAssistantMessageFunctionCall)
  );
end;

class function TChatCompletionRequestMessage.Tool(const AContent: variant;
  const AToolCallId: string): TChatCompletionRequestMessage;
begin
  Result := Default(TChatCompletionRequestMessage);
  Result.Role := 'tool';
  Result.Content := AContent;
  Result.ToolCallId := AToolCallId;
end;

class function TChatCompletionRequestMessage.&Function(const AContent: variant;
  const AName: string): TChatCompletionRequestMessage;
begin
  Result := Default(TChatCompletionRequestMessage);
  Result.Role := 'function';
  Result.Content := AContent;
  Result.Name := AName;
end;

class function TChatCompletionRequestMessage.ToString(
  const AMessages: TArray<TChatCompletionRequestMessage>): string;
var
  LMessage: TChatCompletionRequestMessage;
begin
  Result := String.Empty;
  for LMessage in AMessages do
    if VarIsStr(LMessage.Content) then
      Result := Result
        + LMessage.Role + ':'
        + sLineBreak
        + VarToStr(LMessage.Content)
        + sLineBreak + sLineBreak;
end;

initialization
  GlobalSerializer := TJSONSerializer.Create();
  GlobalSerializer.Formatting := TJsonFormatting.Indented;

finalization
  GlobalSerializer := TJSONSerializer.Create();

end.
