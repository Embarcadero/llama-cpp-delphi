unit LlamaCpp.Common.Chat.Formatter.Alpaca;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TAlpacaChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TAlpacaChatFormatter }

function TAlpacaChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSeparator: string;
  LSeparator2: string;
  LSystemMessage: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
begin
  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '### Instruction');
    LRoles.Add('assistant', '### Response');

    LSeparator := sLineBreak + sLineBreak;
    LSeparator2 := '</s>';

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LPrompt := TLlamaChatFormat.FormatAddColonTwo(
      LSystemMessage, LMessages, LSeparator, LSeparator2);

    Result := TChatFormatterResponse.Create(LPrompt);
  finally
    LRoles.Free();
  end;
end;

end.
