unit LlamaCpp.Common.Chat.Formatter.Llama3;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TLlama3ChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TLlama3ChatFormatter }

function TLlama3ChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSeparator: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
begin
  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('system',
      '<|start_header_id|>system<|end_header_id|>' + sLineBreak + sLineBreak);
    LRoles.Add('user',
      '<|start_header_id|>user<|end_header_id|>'  + sLineBreak + sLineBreak);
    LRoles.Add('assistant',
      '<|start_header_id|>assistant<|end_header_id|>'  + sLineBreak + sLineBreak);

    LSeparator := '<|eot_id|>';

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];

    LPrompt := TLlamaChatFormat.FormatNoColonSingle('', LMessages, LSeparator);

    Result := TChatFormatterResponse.Create(LPrompt, [LSeparator]);
  finally
    LRoles.Free();
  end;
end;

end.
