unit LlamaCpp.Common.Chat.Formatter.Adapter;

interface

uses
  System.Rtti,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types;

type
  TChatFormaterAdapter = class(TInterfacedObject, ILlamaChatCompletionHandler)
  private type
    TConversionData = record
      First: boolean;
      Last: boolean;
      Id: string;
      Created:Int64;
      ModelName: string;
      ToolId: string;
    end;
  private
    FChatFormatter: ILlamaChatFormater;
  private
    function GrammarForJson(): ILlamaGrammar;
    function GrammarForJsonSchema(const AJsonSchema: string;
      const AFallbackToJson: boolean = true): ILlamaGrammar;
    function GrammarForResponseFormat(
      const AResponseFormat: TChatCompletionRequestResponseFormat): ILlamaGrammar;

    function ConvertTextCompletionLogprobsToChat(
      const ALogprobs: TCompletionLogprobs): TChatCompletionLogprobs;

    function ConvertTextCompletionToChat(
      const ACompletion: TCreateCompletionResponse): TCreateChatCompletionResponse;
    procedure ConvertTextCompletionChunksToChat(
      [ref] AConversionData: TConversionData;
      const ACompletion: TCreateCompletionStreamResponse;
      const ACallback: TChatCompletionCallback;
        var AContinue: boolean);

    function ConvertCompletionToChat(
      const ACompletion: TCreateCompletionResponse): TCreateChatCompletionResponse; overload;
    procedure ConvertCompletionToChat(
      [ref] AConversionData: TConversionData;
      const ACompletion: TCreateCompletionStreamResponse;
      const ACallback: TChatCompletionCallback;
        var AContinue: boolean); overload;

    function ConvertCompletionToChatFunction(const AToolName: string;
      const ACompletion: TCreateCompletionResponse): TCreateChatCompletionResponse; overload;
    procedure ConvertCompletionToChatFunction(const AToolName: string;
      [ref] AConversionData: TConversionData;
      const ACompletion: TCreateCompletionStreamResponse;
      const ACallback: TChatCompletionCallback); overload;

    procedure Prepare(
      ASettings: TLlamaChatCompletionSettings;
      const ATokenizationTask: TokenizationTask;
      out APrompt: TArray<integer>;
      out ATool: TChatCompletionTool;
      out AToolFound: boolean;
      var AGrammar: ILlamaGrammar);
  private
    function Handle(
      ASettings: TLlamaChatCompletionSettings;
      const ATokenizationTask: TokenizationTask;
      const ACreateCompletionTask: TCreateCompletionTask;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
      : TCreateChatCompletionResponse; overload;
    procedure Handle(
      ASettings: TLlamaChatCompletionSettings;
      const ATokenizationTask: TokenizationTask;
      const ACreateCompletionTask: TCreateCompletionTaskAsync;
      const ACallback: TChatCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
  private
    constructor Create(const AChatFormatter: ILlamaChatFormater);
  public
    class function ToChatCompletionHandler(
      const AChatFormatter: ILlamaChatFormater): ILlamaChatCompletionHandler; static;
  end;

implementation

uses
  System.Math,
  System.Variants,
  LlamaCpp.Common.Grammar;

{ TChatFormaterAdapter }

constructor TChatFormaterAdapter.Create(const AChatFormatter: ILlamaChatFormater);
begin
  FChatFormatter := AChatFormatter;
end;

function TChatFormaterAdapter.GrammarForJson: ILlamaGrammar;
begin
  Result := TLlamaGrammar.FromString(LlamaCpp.Common.Grammar.JSON_GBNF);
end;

function TChatFormaterAdapter.GrammarForJsonSchema(const AJsonSchema: string;
  const AFallbackToJson: boolean): ILlamaGrammar;
begin
  try
    Result := TLlamaGrammar.FromJsonSchema(AJsonSchema);
  except
    on E: Exception do
    begin
      if AFallbackToJson then
        Result := GrammarForJson()
      else
        raise;
    end;
  end;
end;

function TChatFormaterAdapter.GrammarForResponseFormat(
  const AResponseFormat: TChatCompletionRequestResponseFormat): ILlamaGrammar;
begin
  if AResponseFormat.&Type = 'json_object' then
    Result := nil
  else if not VarIsNull(AResponseFormat.Schema) then
    Result := GrammarForJsonSchema(AResponseFormat.Schema)
  else
    Result := GrammarForJson();
end;

function TChatFormaterAdapter.ConvertTextCompletionLogprobsToChat(
  const ALogprobs: TCompletionLogprobs): TChatCompletionLogprobs;
var
  I: integer;
  LMin: integer;
  LContent: TArray<TChatCompletionLogprobToken>;
  LTopLogprob: TPair<string, single>;
  LToplogprobs: TArray<TChatCompletionTopLogprobToken>;
begin
  LContent := nil;

  LMin := Min(Min(
    Length(ALogprobs.TopLogprobs),
    Length(ALogprobs.TokenLogprobs)),
    Length(ALogprobs.Tokens));

  if (LMin > 0) then
    for I := Low(ALogprobs.TopLogprobs) to LMin do
    begin
      LToplogprobs := nil;

      for LTopLogprob in ALogprobs.TopLogprobs[I] do
      begin
        LToplogprobs := LToplogprobs + [
          TChatCompletionTopLogprobToken.Create(
            LTopLogprob.Key,
            LTopLogprob.Value,
            nil
          )
        ];
      end;

      LContent := LContent + [
        TChatCompletionLogprobToken.Create(
          TChatCompletionTopLogprobToken.Create(
            ALogprobs.Tokens[I],
            ALogprobs.TokenLogprobs[I],
            nil
          ),
          LToplogprobs
        )
      ];
    end;

  Result := TChatCompletionLogprobs.Create(LContent, nil);
end;

procedure TChatFormaterAdapter.ConvertTextCompletionChunksToChat(
  [ref] AConversionData: TConversionData;
  const ACompletion: TCreateCompletionStreamResponse;
  const ACallback: TChatCompletionCallback;
  var AContinue: boolean);
var
  LResponse: TCreateChatCompletionStreamResponse;
  LContent: variant;
begin
  if AConversionData.First then
  begin
    LResponse := TCreateChatCompletionStreamResponse.Create(
      'chat' + ACompletion.ID,
      ACompletion.Model,
      'chat.completion.chunk',
      ACompletion.Created,
      [
        TChatCompletionStreamResponseChoice.Create(
          0,
          TChatCompletionStreamResponseDelta.Create(
            Null,
            Default(TChatCompletionStreamResponseDeltaFunctionCall),
            nil,
            'assistant'
          ),
          ACompletion.Choices[0].FinishReason,
          ConvertTextCompletionLogprobsToChat(ACompletion.Choices[0].Logprobs)
        )
      ]
    );

    AConversionData.First := false;

    ACallback(LResponse, AContinue);
  end;

  if ACompletion.Choices[0].FinishReason.IsEmpty() then
    LContent := ACompletion.Choices[0].Text
  else
    LContent := Null;

  LResponse := TCreateChatCompletionStreamResponse.Create(
    'chat' + ACompletion.ID,
    ACompletion.Model,
    'chat.completion.chunk',
    ACompletion.Created,
    [
      TChatCompletionStreamResponseChoice.Create(
        0,
        TChatCompletionStreamResponseDelta.Create(
          LContent,
          Default(TChatCompletionStreamResponseDeltaFunctionCall),
          nil,
          'assistant'
        ),
        ACompletion.Choices[0].FinishReason,
        ConvertTextCompletionLogprobsToChat(ACompletion.Choices[0].Logprobs)
      )
    ]
  );

  ACallback(LResponse, AContinue);
end;

function TChatFormaterAdapter.ConvertTextCompletionToChat(
  const ACompletion: TCreateCompletionResponse): TCreateChatCompletionResponse;
begin
  Result := TCreateChatCompletionResponse.Create(
    'chat' + ACompletion.ID,
    'chat.completion',
    ACompletion.Created,
    ACompletion.Model,
    [
      TChatCompletionResponseChoice.Create(
        0,
        TChatCompletionResponseMessage.Create(
          ACompletion.Choices[0].Text,
          'assistant',
          Default(TChatCompletionResponseFunctionCall),
          Default(TChatCompletionMessageToolCalls)
        ),
        ACompletion.Choices[0].Logprobs,
        ACompletion.Choices[0].FinishReason
      )
    ],
    ACompletion.Usage
  );
end;

function TChatFormaterAdapter.ConvertCompletionToChat(
  const ACompletion: TCreateCompletionResponse): TCreateChatCompletionResponse;
begin
  Result := ConvertTextCompletionToChat(ACompletion);
end;

procedure TChatFormaterAdapter.ConvertCompletionToChat(
  [ref] AConversionData: TConversionData;
  const ACompletion: TCreateCompletionStreamResponse;
  const ACallback: TChatCompletionCallback;
  var AContinue: boolean);
begin
  ConvertTextCompletionChunksToChat(
    AConversionData, ACompletion, ACallback, AContinue);
end;

function TChatFormaterAdapter.ConvertCompletionToChatFunction(
  const AToolName: string;
  const ACompletion: TCreateCompletionResponse): TCreateChatCompletionResponse;
var
  LToolId: string;
begin
  LToolId := 'call_' + '_0_' + AToolName + '_' + ACompletion.ID;

  Result := TCreateChatCompletionResponse.Create(
    'chat' + ACompletion.ID,
    'chat.completion',
    ACompletion.Created,
    ACompletion.Model,
    [
      TChatCompletionResponseChoice.Create(
        0,
        TChatCompletionResponseMessage.Create(
          Null,
          'assistant',
          TChatCompletionResponseFunctionCall.Create(
            AToolName,
            ACompletion.Choices[0].Text
          ),
          [
          TChatCompletionMessageToolCall.Create(
            LToolId,
            'function',
            TChatCompletionMessageToolCallFunction.Create(
              AToolName,
              ACompletion.Choices[0].Text
            )
          )
          ]
        ),
        ACompletion.Choices[0].Logprobs,
        'tool_calls'
      )
    ],
    ACompletion.Usage
  );
end;

procedure TChatFormaterAdapter.ConvertCompletionToChatFunction(
  const AToolName: string;
  [ref] AConversionData: TConversionData;
  const ACompletion: TCreateCompletionStreamResponse;
  const ACallback: TChatCompletionCallback);
var
  LContinue: Boolean;
begin
  LContinue := true;

  if AConversionData.First then
  begin
    AConversionData.Id := 'chat' + ACompletion.Id;
    AConversionData.Created := ACompletion.Created;
    AConversionData.ModelName := ACompletion.Model;
    AConversionData.ToolId := 'call_' + '_0_' + AToolName + '_' + ACompletion.Id;

    ACallback(
      TChatCompletionStreamResponse.Create(
        AConversionData.Id,
        AConversionData.ModelName,
        'chat.completion.chunk',
        AConversionData.Created,
        [
          TChatCompletionStreamResponseChoice.Create(
            0,
            TChatCompletionStreamResponseDelta.Create(
              Null,
              Default(TChatCompletionStreamResponseDeltaFunctionCall),
              nil,
              Null
            ),
            Null,
            Default(TChatCompletionLogprobs)
          )
        ]
      ),
      LContinue
    );

    ACallback(
      TChatCompletionStreamResponse.Create(
        'chat' + ACompletion.Id,
        ACompletion.Model,
        'chat.completion.chunk',
        ACompletion.Created,
        [
          TChatCompletionStreamResponseChoice.Create(
            0,
            TChatCompletionStreamResponseDelta.Create(
              Null,
              TChatCompletionStreamResponseDeltaFunctionCall.Create(
                AToolName,
                ACompletion.Choices[0].Text
              ),
              [
                TChatCompletionMessageToolCallChunk.Create(
                  0,
                  AConversionData.ToolId,
                  'function',
                  TChatCompletionMessageToolCallChunkFunction.Create(
                    AToolName,
                    ACompletion.Choices[0].Text
                  )
                )
              ],
              Null
            ),
            Null,
            ConvertTextCompletionLogprobsToChat(ACompletion.Choices[0].Logprobs)
          )
        ]
      ),
      LContinue
    );

    AConversionData.First := false;
  end
  else if AConversionData.Last then
  begin
    if AConversionData.Id.IsEmpty() or (AConversionData.Created <= 0) or AConversionData.ModelName.IsEmpty then
      Exit;

    ACallback(
      TChatCompletionStreamResponse.Create(
        AConversionData.Id,
        AConversionData.ModelName,
        'chat.completion.chunk',
        AConversionData.Created,
        [
          TChatCompletionStreamResponseChoice.Create(
            0,
            TChatCompletionStreamResponseDelta.Create(
              Null,
              Default(TChatCompletionStreamResponseDeltaFunctionCall),
              nil,
              Null
            ),
            'tools_calls',
            Default(TChatCompletionLogprobs)
          )
        ]
      ),
      LContinue
    );
  end
  else
  begin
    ACallback(
      TChatCompletionStreamResponse.Create(
        'chat' + ACompletion.Id,
        ACompletion.Model,
        'chat.completion.chunk',
        ACompletion.Created,
        [
          TChatCompletionStreamResponseChoice.Create(
            0,
            TChatCompletionStreamResponseDelta.Create(
              Null,
              TChatCompletionStreamResponseDeltaFunctionCall.Create(
                AToolName,
                ACompletion.Choices[0].Text
              ),
              [
                TChatCompletionMessageToolCallChunk.Create(
                  0,
                  AConversionData.ToolId,
                  'function',
                  TChatCompletionMessageToolCallChunkFunction.Create(
                    AToolName,
                    ACompletion.Choices[0].Text
                  )
                )
              ],
              Null
            ),
            Null,
            ConvertTextCompletionLogprobsToChat(ACompletion.Choices[0].Logprobs)
          )
        ]
      ),
      LContinue
    );
  end;
end;

procedure TChatFormaterAdapter.Prepare(ASettings: TLlamaChatCompletionSettings;
  const ATokenizationTask: TokenizationTask; out APrompt: TArray<integer>;
  out ATool: TChatCompletionTool; out AToolFound: boolean;
  var AGrammar: ILlamaGrammar);
var
  LFormat: TChatFormatterResponse;
  LFunction: TChatCompletionFunction;
  LTool: TChatCompletionTool;
  LSchema: TChatCompletionFunctionParameters;
begin
  LFormat := FChatFormatter.Format(ASettings);

  APrompt := ATokenizationTask(LFormat.Prompt, not LFormat.AddedSpecial, true);

  if Assigned(LFormat.Stop) then
    ASettings.Stop := ASettings.Stop + LFormat.Stop;

  if ASettings.ResponseFormat.&Type = 'json_object' then
    AGrammar := GrammarForResponseFormat(ASettings.ResponseFormat);

  // Convert legacy functions to tools
  if Assigned(ASettings.Functions) then
    for LFunction in ASettings.Functions do
      ASettings.Tools := ASettings.Tools + [
        TChatCompletionTool.Create(
          TChatCompletionToolFunction.Create(
            LFunction.Name,
            LFunction.Description,
            LFunction.Parameters
          )
        )
      ];

  // Convert legacy function_call to tool_choice
  if (not ASettings.FunctionCall.Option.Name.IsEmpty()) then
    ASettings.ToolChoice := TChatCompletionToolChoiceOption.Create(
      TChatCompletionNamedToolChoice.Create(
        TChatCompletionNamedToolChoiceFunction.Create(
          ASettings.FunctionCall.Option.Name
        )
      )
    );

  AToolFound := false;
  for LTool in ASettings.Tools do
    if LTool.&Function.Name = ASettings.ToolChoice.Choice.&Function.Name then
    begin
      AToolFound := true;
      Break;
    end;

  if AToolFound then
  begin
    LSchema := LTool.&Function.Parameters;
    if Assigned(LSchema) then
      try
        AGrammar := TLlamaGrammar.FromJsonSchema(LSchema.ToJsonString())
      except
        on E: Exception do
          AGrammar := TLlamaGrammar.FromString(JSON_GBNF);
      end
    else
      AGrammar := TLlamaGrammar.FromString(JSON_GBNF);
  end;

  ATool := LTool;
end;

function TChatFormaterAdapter.Handle(ASettings: TLlamaChatCompletionSettings;
  const ATokenizationTask: TokenizationTask;
  const ACreateCompletionTask: TCreateCompletionTask;
  const AStoppingCriteria: IStoppingCriteriaList = nil;
  const ALogitsProcessor: ILogitsProcessorList = nil;
  const AGrammar: ILlamaGrammar = nil): TCreateChatCompletionResponse;
var
  LPrompt: TArray<integer>;
  LTool: TChatCompletionTool;
  LToolFound: boolean;
  LGrammar: ILlamaGrammar;
  LCompletion: TCreateCompletionResponse;
begin
  Assert(Assigned(ATokenizationTask), 'Argument "ATokenizationTask" is null.');
  Assert(Assigned(ACreateCompletionTask), 'Argument "ACreateCompletionTask" is null.');

  LGrammar := AGrammar;

  Prepare(ASettings, ATokenizationTask, LPrompt, LTool, LToolFound, LGrammar);

  LCompletion := ACreateCompletionTask(
    LPrompt, ASettings.ToLlamaCompletionSettings(),
    AStoppingCriteria, ALogitsProcessor, AGrammar);

  if LToolFound then
    Result := ConvertCompletionToChatFunction(LTool.&Function.Name, LCompletion)
  else
    Result := ConvertCompletionToChat(LCompletion);
end;

procedure TChatFormaterAdapter.Handle(
  ASettings: TLlamaChatCompletionSettings;
  const ATokenizationTask: TokenizationTask;
  const ACreateCompletionTask: TCreateCompletionTaskAsync;
  const ACallback: TChatCompletionCallback;
  const AStoppingCriteria: IStoppingCriteriaList = nil;
  const ALogitsProcessor: ILogitsProcessorList = nil;
  const AGrammar: ILlamaGrammar = nil);
var
  LPrompt: TArray<integer>;
  LTool: TChatCompletionTool;
  LToolFound: boolean;
  LGrammar: ILlamaGrammar;
  LConversionData: TConversionData;
begin
  Assert(Assigned(ATokenizationTask), 'Argument "ATokenizationTask" is null.');
  Assert(Assigned(ACreateCompletionTask), 'Argument "ACreateCompletionTask" is null.');

  LGrammar := AGrammar;

  Prepare(ASettings, ATokenizationTask, LPrompt, LTool, LToolFound, LGrammar);

  LConversionData := Default(TConversionData);
  LConversionData.First := true;

  ACreateCompletionTask(LPrompt, ASettings.ToLlamaCompletionSettings(),
    procedure(const AResponse: TCreateCompletionResponse; var AContinue: boolean)
    begin

      if LToolFound then
        ConvertCompletionToChatFunction(
          LTool.&Function.Name, LConversionData, AResponse, ACallback)
      else
        ConvertCompletionToChat(
          LConversionData, AResponse, ACallback, AContinue);

    end, AStoppingCriteria, ALogitsProcessor, AGrammar);

  if LToolFound then
  begin
    LConversionData.Last := true;
    ConvertCompletionToChatFunction(
      LTool.&Function.Name,
      LConversionData,
      Default(TCreateCompletionResponse),
      ACallback);
  end;
end;

class function TChatFormaterAdapter.ToChatCompletionHandler(
  const AChatFormatter: ILlamaChatFormater): ILlamaChatCompletionHandler;
begin
  Result := TChatFormaterAdapter.Create(AChatFormatter);
end;

end.
