unit LlamaCpp.Common.Chat.Formatter.RedpajamaIncite;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TRedpajamaInciteChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TRedpajamaInciteChatFormatter }

function TRedpajamaInciteChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LSystemMessage: string;
  LRoles: TDictionary<string, string>;
  LMessages: TArray<TPair<string, string>>;
  LSeparator: WideString;
  LStop: string;
  LPrompt: string;
begin
  LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);

  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '<human>');
    LRoles.Add('assistant', '<bot>');
    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];
  finally
    LRoles.Free();
  end;

  LSeparator := sLineBreak;
  LStop := '<human>';

  LPrompt := TLlamaChatFormat.FormatAddColonSingle(
    LSystemMessage, LMessages, LSeparator);

  Result := TChatFormatterResponse.Create(LPrompt, [LStop]);
end;

end.
