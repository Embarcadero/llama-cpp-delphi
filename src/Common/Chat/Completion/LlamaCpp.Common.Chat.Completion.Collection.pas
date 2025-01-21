unit LlamaCpp.Common.Chat.Completion.Collection;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types;

type
  TLlamaChatCompletionCollection = class
  private
    class var FInstance: TLlamaChatCompletionCollection;
  private
    FChatCompletionHandlers: TDictionary<string, ILlamaChatCompletionHandler>;
  private
    class constructor Create();
    class destructor Destroy();
  public
    constructor Create();
    destructor Destroy(); override;

    procedure RegisterChatCompletionHandler(const AName: string;
      const AChatHandler: ILlamaChatCompletionHandler;
      const AOverwrite: boolean = false);
    procedure UnregisterChatHandler(const AName: string);

    function GetChatCompletionHandler(const AName: string)
      : ILlamaChatCompletionHandler;

    class property Instance: TLlamaChatCompletionCollection read FInstance;
  end;

implementation

uses
  LlamaCpp.Common.Chat.Formatter.Registration;

{ TLlamaChatCompletionCollection }

class constructor TLlamaChatCompletionCollection.Create;
begin
  FInstance := TLlamaChatCompletionCollection.Create();
  TChatFormatterRegistration.RegisterAll();
end;

class destructor TLlamaChatCompletionCollection.Destroy;
begin
  TChatFormatterRegistration.UnregisterAll();
  FInstance.Free();
end;

constructor TLlamaChatCompletionCollection.Create;
begin
  FChatCompletionHandlers := TDictionary<string, ILlamaChatCompletionHandler>.Create();
end;

destructor TLlamaChatCompletionCollection.Destroy;
begin
  FChatCompletionHandlers.Free();
  inherited;
end;

procedure TLlamaChatCompletionCollection.RegisterChatCompletionHandler(
  const AName: string; const AChatHandler: ILlamaChatCompletionHandler;
  const AOverwrite: boolean);
begin
  if not AOverwrite and FChatCompletionHandlers.ContainsKey(AName) then
    raise Exception.CreateFmt(
      'Formatter with name "%s" already registered. Use "AOverwrite=true" to overwrite it.', [
        AName]);

  FChatCompletionHandlers.AddOrSetValue(AName, AChatHandler);
end;

procedure TLlamaChatCompletionCollection.UnregisterChatHandler(
  const AName: string);
begin
  if not FChatCompletionHandlers.ContainsKey(AName) then
    raise Exception.CreateFmt(
      'No formatter registered under the name "%s".', [AName]);

  FChatCompletionHandlers.Remove(AName);
end;

function TLlamaChatCompletionCollection.GetChatCompletionHandler(
  const AName: string): ILlamaChatCompletionHandler;
begin
  FChatCompletionHandlers.TryGetValue(AName, Result);
end;

end.
