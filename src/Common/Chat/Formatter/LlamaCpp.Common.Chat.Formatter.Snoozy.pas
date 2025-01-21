unit LlamaCpp.Common.Chat.Formatter.Snoozy;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TSnoozyChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TSnoozyChatFormatter }

function TSnoozyChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LSystemMessage: string;
  LRoles: TDictionary<string, string>;
  LSeparator: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
  LStop: string;
begin
  LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
  if LSystemMessage.IsEmpty() then
    LSystemMessage := 'The prompt below is a question to answer, a task to complete, or a conversation to respond to; decide which and write an appropriate response.';

  LSystemMessage := String.Format('### Instruction:'#13#10'%s', [
    LSystemMessage]);

  LSeparator := sLineBreak;
  LStop := '###';

  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '### Prompt');
    LRoles.Add('assistant', '### Response');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];
  finally
    LRoles.Free();
  end;

  LPrompt := TLlamaChatFormat.FormatAddColonSingle(
    LSystemMessage, LMessages, LSeparator);

  Result := TChatFormatterResponse.Create(LPrompt, [LStop]);
end;

end.
