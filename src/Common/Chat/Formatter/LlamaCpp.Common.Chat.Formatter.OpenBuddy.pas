unit LlamaCpp.Common.Chat.Formatter.OpenBuddy;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TOpenBudyChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

implementation

{ TOpenBudyChatFormatter }

function TOpenBudyChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
var
  LSystemMessage: string;
  LRoles: TDictionary<string, string>;
  LMessages: TArray<TPair<string, string>>;
  LSeparator: string;
  LPrompt: string;
begin
  LSystemMessage := '''
  You are a helpful, respectful and honest INTP-T AI Assistant named Buddy. You are talking to a human User.
  Always answer as helpfully and logically as possible, while being safe. Your answers should not include any harmful, political, religious, unethical, racist, sexist, toxic, dangerous, or illegal content. Please ensure that your responses are socially unbiased and positive in nature.
  If a question does not make any sense, or is not factually coherent, explain why instead of answering something not correct. If you don't know the answer to a question, please don't share false information.
  You can speak fluently in many languages, for example: English, Chinese.
  You cannot access the internet, but you have vast knowledge, cutoff: 2021-09.
  You are trained by OpenBuddy team, (https://openbuddy.ai, https://github.com/OpenBuddy/OpenBuddy), you are based on LLaMA and Falcon transformers model, not related to GPT or OpenAI.

  ''';

  LRoles := TDictionary<string, string>.Create();
  try
    LRoles.Add('user', 'User');
    LRoles.Add('assistant', 'Assistant');
    LMessages := TLlamaChatFormat.MapRoles(ASettings.Messages, LRoles);
    LMessages := LMessages + [
      TPair<string, string>.Create(LRoles['assistant'], '')];
  finally
    LRoles.Free();
  end;

  LSeparator := sLineBreak;

  LPrompt := TLlamaChatFormat.FormatAddColonSingle(
    LSystemMessage, LMessages, LSeparator);

  Result := TChatFormatterResponse.Create(LPrompt);
end;

end.
