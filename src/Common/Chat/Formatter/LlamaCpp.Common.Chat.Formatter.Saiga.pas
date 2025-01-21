unit LlamaCpp.Common.Chat.Formatter.Saiga;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TSaigaChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TSaigaChatFormatter }

function TSaigaChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LMessageTemplate: string;
  LRoles: TDictionary<string, string>;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
  LMessage: TPair<string, string>;
begin
  LMessageTemplate := '<s>%s'#13#10'%s</s>';

  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', 'user');
    LRoles.Add('bot', 'bot');
    LRoles.Add('system', 'system');

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
  finally
    LRoles.Free();
  end;

  LPrompt := String.Empty;

  for LMessage in LMessages do
    if not LMessage.Value.IsEmpty() then
      LPrompt := LPrompt + String.Format(LMessageTemplate, [LMessage.Key, LMessage.Value])
    else
      LPrompt := LPrompt + '<s>' + LMessage.Key + sLineBreak;

  LPrompt := LPrompt + '<s>bot';

  Result := TChatFormatterResponse.Create(LPrompt.Trim());
end;

end.
