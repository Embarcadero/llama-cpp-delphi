unit LlamaCpp.Tokenization;

interface

uses
  System.SysUtils,
  LlamaCpp.Types,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Common.Types;

type
  TLlamaTokenization = class(TInterfacedObject, ILlamaTokenization)
  private
    FTokenizer: ILlamaTokenizer;
  public
    constructor Create(const ALlama: ILlama);

    function Tokenize(
      const AText: TBytes;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false): TArray<integer>;
    function Detokenize(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false): TBytes; overload;

    function Encode(
      const AText: string;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false)
      : TArray<integer>;
    function Decode(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false)
      : string;
  end;

implementation

uses
  LlamaCpp.Common.Tokenizer;

{ TLlamaTokenization }

constructor TLlamaTokenization.Create(const ALlama: ILlama);
begin
  if not Assigned(ALlama.Tokenizer) then
    FTokenizer := TLlamaTokenizer.Create(ALlama.Model)
  else
    FTokenizer := ALlama.Tokenizer;
end;

function TLlamaTokenization.Tokenize(const AText: TBytes;
  const AAddSpecial: boolean; const AParseSpecial: boolean): TArray<integer>;
begin
  Result := FTokenizer.Tokenize(AText, AAddSpecial, AParseSpecial);
end;

function TLlamaTokenization.Detokenize(const ATokens,
  APrevTokens: TArray<integer>; const ASpecial: boolean): TBytes;
begin
  Result := FTokenizer.Detokenize(ATokens, APrevTokens, ASpecial);
end;

function TLlamaTokenization.Encode(const AText: string; const AAddSpecial,
  AParseSpecial: boolean): TArray<integer>;
begin
  Result := FTokenizer.Encode(AText, AAddSpecial, AParseSpecial);
end;

function TLlamaTokenization.Decode(const ATokens: TArray<integer>;
  const APrevTokens: TArray<integer> = nil;
  const ASpecial: boolean = false): string;
begin
  Result := FTokenizer.Decode(ATokens);
end;


end.
