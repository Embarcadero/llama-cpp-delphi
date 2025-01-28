unit LlamaCpp.Registration;

interface

uses
  System.Classes,
  LlamaCpp.Llama,
  LlamaCpp.Download;

procedure Register();

implementation

procedure Register();
begin
  RegisterComponents('LlamaCpp', [TLlama, TLlamaDownload]);
end;

end.
