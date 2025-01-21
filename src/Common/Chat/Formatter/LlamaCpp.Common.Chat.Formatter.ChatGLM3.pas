unit LlamaCpp.Common.Chat.Formatter.ChatGLM3;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TChatGLM3ChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TChatGLM3ChatFormatter }

function TChatGLM3ChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSystemMessage: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
  LSeparator: string;
begin
  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '<|user|>');
    LRoles.Add('assistant', '<|assistant|>');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    LSystemMessage := String.Format('<|system|>'#13#10'%s', [LSystemMessage]);

    LSeparator := '</s>';

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];
  finally
    LRoles.Free();
  end;

  LPrompt := TLlamaChatFormat.FormatChatGML3(
    LSystemMessage, LMessages);

  Result := TChatFormatterResponse.Create(LPrompt, [LSeparator]);
end;

end.
