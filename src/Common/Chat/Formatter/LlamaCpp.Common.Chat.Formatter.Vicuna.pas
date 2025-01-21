unit LlamaCpp.Common.Chat.Formatter.Vicuna;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TVicunaChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TVicunaChatFormatter }

function TVicunaChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSystemMessage: string;
  LSeparator: string;
  LSeparator2: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
begin
  LRoles := TDictionary<string, string>.Create();
  try
    LSystemMessage := 'A chat between a curious user and an artificial intelligence assistant. The assistant gives helpful, detailed, and polite answers to the user''s questions.';

    LRoles.Add('user', 'USER');
    LRoles.Add('assistant', 'ASSISTANT');

    LSeparator := ' ';
    LSeparator2 := '</s>';

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];

    LPrompt := TLlamaChatFormat.FormatAddColonTwo(LSystemMessage, LMessages, LSeparator, LSeparator2);

    Result := TChatFormatterResponse.Create(LPrompt);
  finally
    LRoles.Free();
  end;
end;

end.
