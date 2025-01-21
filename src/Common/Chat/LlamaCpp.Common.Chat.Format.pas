unit LlamaCpp.Common.Chat.Format;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  LlamaCpp.Wrapper.LlamaModel,
  LLamaCpp.Common.Chat.Types;

type
  TLlamaChatFormat = class
  public const
    // Source: https://huggingface.co/teknium/OpenHermes-2.5-Mistral-7B/blob/main/tokenizer_config.json
    CHATML_CHAT_TEMPLATE = '{% for message in messages %}{{''<|im_start|>'' + message[''role''] + ''\n'' + message[''content''] + ''<|im_end|>'' + ''\n''}}{% endfor %}{% if add_generation_prompt %}{{ ''<|im_start|>assistant\n'' }}{% endif %}';
    CHATML_BOS_TOKEN = '<s>';
    CHATML_EOS_TOKEN = '<|im_end|>';

    // Source: https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.1/blob/main/tokenizer_config.json
    MISTRAL_INSTRUCT_CHAT_TEMPLATE = '{{ bos_token }}{% for message in messages %}{% if (message[''role''] == ''user'') != (loop.index0 % 2 == 0) %}{{ raise_exception(''Conversation roles must alternate user/assistant/user/assistant/...'') }}{% endif %}{% if message[''role''] == ''user'' %}{{ ''[INST] '' + message[''content''] + '' [/INST]'' }}{% elif message[''role''] == ''assistant'' %}{{ message[''content''] + eos_token + '' '' }}{% else %}{{ raise_exception(''Only user and assistant roles are supported!'') }}{% endif %}{% endfor %}';
    MISTRAL_INSTRUCT_BOS_TOKEN = '<s>';
    MISTRAL_INSTRUCT_EOS_TOKEN = '</s>';

    // Source: https://huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1/blob/main/tokenizer_config.json
    MIXTRAL_INSTRUCT_CHAT_TEMPLATE = '{{ bos_token }}{% for message in messages %}{% if (message[''role''] == ''user'') != (loop.index0 % 2 == 0) %}{{ raise_exception(''Conversation roles must alternate user/assistant/user/assistant/...'') }}{% endif %}{% if message[''role''] == ''user'' %}{{ ''[INST] '' + message[''content''] + '' [/INST]'' }}{% elif message[''role''] == ''assistant'' %}{{ message[''content''] + eos_token}}{% else %}{{ raise_exception(''Only user and assistant roles are supported!'') }}{% endif %}{% endfor %}';

    // Source: https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct/blob/main/tokenizer_config.json
    LLAMA3_INSTRUCT_CHAT_TEMPLATE = '{% set loop_messages = messages %}{% for message in loop_messages %}{% set content = ''<|start_header_id|>'' + message[''role''] + ''<|end_header_id|>\n\n''+ message[''content''] | trim + ''<|eot_id|>'' %}{% if loop.index0 == 0 %}{% set content = bos_token + content %}{% endif %}{{ content }}{% endfor %}{% if add_generation_prompt %}{{ ''<|start_header_id|>assistant<|end_header_id|>\n\n'' }}{% endif %}';
  public
    class function GuessChatFormatFromGguf(const AMetadata: TMetadata)
      : string; static;

    class function GetSystemMessage(
      const AMessages: TArray<TChatCompletionRequestMessage>): string;
    class function MapRoles(
      const AMessages: TArray<TChatCompletionRequestMessage>;
      const ARoleMap: TDictionary<string, string>): TArray<TPair<string, string>>;
    class function FormatNoColonSingle(
      const ASystemMessage: string;
      const AMessages: TArray<TPair<string, string>>;
      const ASeparator: string): string;
    class function FormatAddColonTwo(
      const ASystemMessage: string;
      const AMessages: TArray<TPair<string, string>>;
      const ASeparator, ASeparator2: string): string;
    class function FormatAddColonSingle(
      const ASystemMessage: string;
      const AMessages: TArray<TPair<string, string>>;
      const ASeparator: string): string;
    class function FormatChatml(
      const ASystemMessage: string;
      const AMessages: TArray<TPair<string, string>>;
      const ASeparator: string): string;
    class function FormatChatGML3(
      const ASystemMessage: string;
      const AMessages: TArray<TPair<string, string>>): string;
  end;

implementation

uses
  System.Variants;

{ TLlamaChatFormat }

class function TLlamaChatFormat.GuessChatFormatFromGguf(const AMetadata
  : TMetadata): string;
begin
  if not AMetadata.ContainsKey('tokenizer.chat_template') then
    Exit(String.Empty);

  if AMetadata.Items['tokenizer.chat_template'] = CHATML_CHAT_TEMPLATE then
    Result := 'chatml'
  else if (AMetadata.Items['tokenizer.chat_template'] = MISTRAL_INSTRUCT_CHAT_TEMPLATE) or
    (AMetadata.Items['tokenizer.chat_template'] = MIXTRAL_INSTRUCT_CHAT_TEMPLATE) then
      Result := 'mistral-instruct'
  else if AMetadata.Items['tokenizer.chat_template'] = LLAMA3_INSTRUCT_CHAT_TEMPLATE then
    Result := 'llama-3'
  else
    Result := String.Empty;
end;

class function TLlamaChatFormat.GetSystemMessage(
  const AMessages: TArray<TChatCompletionRequestMessage>): string;
var
  LMessage: TChatCompletionRequestMessage;
begin
  for LMessage in AMessages do
    if LMessage.Role = 'system' then
      Exit(VarToStr(LMessage.Content));

  Result := String.Empty;
end;

class function TLlamaChatFormat.MapRoles(
  const AMessages: TArray<TChatCompletionRequestMessage>;
  const ARoleMap: TDictionary<string, string>): TArray<TPair<string, string>>;
var
  LMessage: TChatCompletionRequestMessage;
begin
  Result := nil;

  for LMessage in AMessages do
    if ARoleMap.ContainsKey(LMessage.Role) then
      if VarIsStr(LMessage.Content) then
        Result := Result + [TPair<string, string>.Create(
          ARoleMap[LMessage.Role],
          VarToStr(LMessage.Content)
        )]
      else
        Result := Result + [TPair<string, string>.Create(
          ARoleMap[LMessage.Role],
          String.Empty
        )];
end;

class function TLlamaChatFormat.FormatNoColonSingle(
  const ASystemMessage: string; const AMessages: TArray<TPair<string, string>>;
  const ASeparator: string): string;
var
  LMessage: TPair<string, string>;
begin
  Result := ASystemMessage + ASeparator;

  for LMessage in AMessages do
  begin
    if not LMessage.Value.IsEmpty() then
      Result := Result + LMessage.Key + LMessage.Value + ASeparator
    else
      Result := Result + LMessage.Key
  end;
end;

class function TLlamaChatFormat.FormatAddColonTwo(const ASystemMessage: string;
  const AMessages: TArray<TPair<string, string>>; const ASeparator,
  ASeparator2: string): string;
var
  LSeparators: TArray<string>;
  I: Integer;
begin
  LSeparators := [ASeparator, ASeparator2];
  Result := ASystemMessage + LSeparators[0];

  for I := Low(AMessages) to High(AMessages) do
    if not AMessages[I].Value.IsEmpty() then
      Result := Result + AMessages[I].Key + ': ' + AMessages[I].Value + LSeparators[I mod 2]
    else
      Result := Result + AMessages[I].Key + ':';
end;

class function TLlamaChatFormat.FormatAddColonSingle(
  const ASystemMessage: string; const AMessages: TArray<TPair<string, string>>;
  const ASeparator: string): string;
var
  LMessage: TPair<string, string>;
begin
  Result := ASystemMessage + ASeparator;

  for LMessage in AMessages do
    if not LMessage.Value.IsEmpty() then
      Result := Result + LMessage.Key + ': ' + LMessage.Value + ASeparator
    else
      Result := Result + LMessage.Key + ':';
end;

class function TLlamaChatFormat.FormatChatml(const ASystemMessage: string;
  const AMessages: TArray<TPair<string, string>>;
  const ASeparator: string): string;
var
  LMessage: TPair<string, string>;
begin
  if ASystemMessage.IsEmpty() then
    Result := String.Empty
  else
    Result := ASystemMessage + ASeparator + sLineBreak;

  for LMessage in AMessages do
    if not LMessage.Value.IsEmpty() then
      Result := Result + LMessage.Key + sLineBreak + LMessage.Value + ASeparator + sLineBreak
    else
      Result := Result + LMessage.Key + sLineBreak;
end;

class function TLlamaChatFormat.FormatChatGML3(const ASystemMessage: string;
  const AMessages: TArray<TPair<string, string>>): string;
var
  LMessage: TPair<string, string>;
begin
  Result := String.Empty;

  if not ASystemMessage.IsEmpty() then
    Result := ASystemMessage;

  for LMessage in AMessages do
    if not LMessage.Value.IsEmpty() then
      Result := Result + LMessage.Key + sLineBreak + ' ' + LMessage.Value
    else
      Result := Result + LMessage.Key;
end;

end.
