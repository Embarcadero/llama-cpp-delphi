unit LlamaCpp.Common.Chat.Formatter.Llama2;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TLlama2ChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function FormatLlama2(const ASystemMessage: string;
      const AMessages: TArray<TPair<string, string>>;
      const ASep1, ASep2: string): string;
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TLlama2ChatFormatter }

function TLlama2ChatFormatter.FormatLlama2(const ASystemMessage: string;
  const AMessages: TArray<TPair<string, string>>; const ASep1,
  ASep2: string): string;
var
  I: Integer;
  LSeps: TArray<string>;
begin
  LSeps := [ASep1, ASep2];
  Result := ASystemMessage + ASep1;

  for I := Low(AMessages) to High(AMessages) do
  begin
    if not ASystemMessage.IsEmpty() and (I = 0) then
      Result := Result + AMessages[I].Value + LSeps[I mod 2]
    else if not AMessages[I].Value.IsEmpty() then
      Result := Result + AMessages[I].Key + AMessages[I].Value + ' ' + LSeps[I mod 2]
    else
      Result := Result + AMessages[I].Key + ' ';
  end;
end;

function TLlama2ChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LSystemTemplate: string;
  LRoles: TDictionary<string, string>;
  LMessages: TArray<TPair<string, string>>;
  LSystemMessage: string;
  LPrompt: string;
begin
  LSystemTemplate := '[INST] <<SYS>>'#13#10'%s'#13#10'<</SYS>>';

  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', '<s>[INST]');
    LRoles.Add('assistant', '[/INST]');
    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
  finally
    LRoles.Free();
  end;

  LSystemMessage := TLlamaChatFormat.GetSystemMessage(ASettings.Messages);

  if not LSystemMessage.IsEmpty() then
    LSystemMessage := String.Format(LSystemTemplate, [LSystemMessage]);

  LPrompt := FormatLlama2(LSystemMessage, LMessages, ' ', '</s>') + '[/INST]';

  Result := TChatFormatterResponse.Create(LPrompt);
end;

end.
