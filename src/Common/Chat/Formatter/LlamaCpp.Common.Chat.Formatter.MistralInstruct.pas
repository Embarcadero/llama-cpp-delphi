unit LlamaCpp.Common.Chat.Formatter.MistralInstruct;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TMistralInstructChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

uses
  System.Variants;

{ TMistralInstructChatFormatter }

function TMistralInstructChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
const
  EOS = '</s>';
var
  LStop: string;
  LPrompt: string;
  LMessage: TChatCompletionRequestMessage;
begin
  LStop := EOS;
  LPrompt := String.Empty;

  for LMessage in ASettings.Messages do
    if (LMessage.Role = 'user') and not VarIsNull(LMessage.Content) and VarIsStr(LMessage.Content) then
      LPrompt := LPrompt + '[INST] ' + VarToStr(LMessage.Content)
    else if (LMessage.Role = 'assistant') and not VarIsNull(LMessage.Content) then
      LPrompt := LPrompt + '[/INST] ' + VarToStr(LMessage.Content) + EOS;

  LPrompt := LPrompt + '[/INST]';

  Result := TChatFormatterResponse.Create(LPrompt, [LStop]);
end;

end.
