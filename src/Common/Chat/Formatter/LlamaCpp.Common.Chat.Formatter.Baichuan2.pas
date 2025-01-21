unit LlamaCpp.Common.Chat.Formatter.Baichuan2;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TBaichuan2ChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TBaichuan2ChatFormatter }

function TBaichuan2ChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSystemMessage: string;
  LSeparator: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
begin
  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '<reserved_106>');
    LRoles.Add('assistant', '<reserved_107>');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    LSeparator := '';

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];

    LPrompt := TLlamaChatFormat.FormatNoColonSingle(
      LSystemMessage, LMessages, LSeparator);

    Result := TChatFormatterResponse.Create(LPrompt);
  finally
    LRoles.Free();
  end;
end;

end.
