unit LlamaCpp.Common.Chat.Formatter.Zephyr;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TZephyrChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TZephyrChatFormatter }

function TZephyrChatFormatter.Format(
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
    LRoles.Add('user', '<|user|>'#13#10'');
    LRoles.Add('assistant', '<|assistant|>'#13#10'');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    LSystemMessage := String.Format('<|system|>'#13#10'%s', [LSystemMessage]);

    LSeparator := '</s>';

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];
  finally
    LRoles.Free();
  end;

  LPrompt := TLlamaChatFormat.FormatChatml(
    LSystemMessage, LMessages, LSeparator);

  Result := TChatFormatterResponse.Create(LPrompt, [LSeparator]);
end;

end.
