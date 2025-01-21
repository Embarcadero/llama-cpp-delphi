unit LlamaCpp.Common.Chat.Formatter.Gemma;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TGemmaChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TGemmaChatFormatter }

function TGemmaChatFormatter.Format(
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
    LRoles.Add('user', '<start_of_turn>user' + sLineBreak);
    LRoles.Add('assistant', '<start_of_turn>model' + sLineBreak);

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];
  finally
    LRoles.Free();
  end;

  LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);

  LSeparator := '<end_of_turn>' + sLineBreak;

  LPrompt := TLlamaChatFormat.FormatNoColonSingle(
    LSystemMessage, LMessages, LSeparator);

  Result := TChatFormatterResponse.Create(LPrompt, [LSeparator]);
end;

end.
