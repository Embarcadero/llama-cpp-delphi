unit LlamaCpp.Common.Chat.Formatter.OpenOrca;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TOpenOrcaChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TOpenOrcaChatFormatter }

function TOpenOrcaChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LRoles: TDictionary<string, string>;
  LSystemMessage: string;
  LStop: string;
  LSeparator: string;
  LMessages: TArray<TPair<string, string>>;
  LPrompt: string;
begin
  LSystemMessage :=
  '''
  You are a helpful assistant. Please answer truthfully and write out your
  thinking step by step to be sure you get the right answer. If you make a mistake or encounter
  an error in your thinking, say so out loud and attempt to correct it. If you don't know or
  aren't sure about something, say so clearly. You will act as a professional logician, mathematician,
  and physicist. You will also act as the most appropriate type of expert to answer any particular
  question or solve the relevant problem; state which expert type your are, if so. Also think of
  any particular named expert that would be ideal to answer the relevant question or solve the
  relevant problem; name and act as them, if appropriate.
  ''';

  LStop := 'User';

  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('User', 'User');
    LRoles.Add('Assistant', 'Assistant');

    LSeparator := '<|end_of_turn|>' + sLineBreak;

    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['Assistant'], '')];
  finally
    LRoles.Free();
  end;

  LPrompt := TLlamaChatFormat.FormatAddColonSingle(
    LSystemMessage, LMessages, LSeparator);

  Result := TChatFormatterResponse.Create(LPrompt, [LStop]);

end;

end.
