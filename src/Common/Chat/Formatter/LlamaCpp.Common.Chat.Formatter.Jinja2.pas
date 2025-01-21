unit LlamaCpp.Common.Chat.Formatter.Jinja2;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Chat.Types,
  LlamaCpp.Common.Chat.Format;

type
  TJinja2ChatFormatter = class(TInterfacedObject, ILlamaChatFormater)
  private
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  public
    constructor Create(
      const ATemplate: string;
      const AEOSToken: string;
      const ABOSToken: string;
      const AAddGenerationPrompt: boolean = true;
      const AStopTokenIds: TArray<integer> = nil);

    function ToChatHandler(): ILlamaChatCompletionHandler;
  end;

implementation

uses
  LlamaCpp.Common.Chat.Formatter.Adapter;

{ TJinja2ChatFormatter }

constructor TJinja2ChatFormatter.Create(const ATemplate, AEOSToken,
  ABOSToken: string; const AAddGenerationPrompt: boolean;
  const AStopTokenIds: TArray<integer>);
begin
  //
end;

function TJinja2ChatFormatter.Format(
  const ASettings: TLlamaChatCompletionSettings): TChatFormatterResponse;
begin
  // Working in a Jinja2 parser...
  raise ENotImplemented.Create(
    'Please, set the "ChatFormat" option in your settings.');
end;

function TJinja2ChatFormatter.ToChatHandler: ILlamaChatCompletionHandler;
begin
  Result := TChatFormaterAdapter.ToChatCompletionHandler(Self);
end;

end.
