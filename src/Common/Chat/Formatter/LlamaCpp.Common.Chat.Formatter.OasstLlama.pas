unit LlamaCpp.Common.Chat.Formatter.OasstLlama;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TOasstLlamaChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TOasstLlamaChatFormatter }

function TOasstLlamaChatFormatter.Format(
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
    LRoles.Add('user', '<|prompter|>');
    LRoles.Add('assistant', '<|assistant|>');

    LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);
    LSystemMessage := String.Format(
      '[INST] <<SYS>>'#13#10'%s'#13#10'<</SYS>>'#13#10#13#10'', [
      LSystemMessage]);

    LSeparator := '</s>';

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
