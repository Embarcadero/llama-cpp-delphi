unit LlamaCpp.Common.Chat.Formatter.Qwen;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TQwenChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TQwenChatFormatter }

function TQwenChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSystemMessage: string;
  LMessages: TArray<TPair<string, string>>;
  LSeparator: string;
  LPrompt: string;
  LSeparator2: string;
begin
  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '<|im_start|>user');
    LRoles.Add('assistant', '<|im_start|>assistant');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    if LSystemMessage.IsEmpty() then
      LSystemMessage := 'You are a helpful assistant.';
    LSystemMessage := '<|im_start|>system' + sLineBreak + LSystemMessage;

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];

    LSeparator := '<|im_end|>';

    LPrompt := TLlamaChatFormat.FormatChatml(LSystemMessage, LMessages, LSeparator);

    LSeparator2 := '<|endoftext|>';

    Result := TChatFormatterResponse.Create(LPrompt, [LSeparator2]);
  finally
    LRoles.Free();
  end;
end;

end.
