unit LlamaCpp.Common.Chat.Formatter.Pygmalion;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TPygmalionChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TPygmalionChatFormatter }

function TPygmalionChatFormatter.Format(
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
    LRoles.Add('assistant', '<|model|>');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    LSystemMessage := String.Format('<|system|>%s', [LSystemMessage]);

    LSeparator := sLineBreak;

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
