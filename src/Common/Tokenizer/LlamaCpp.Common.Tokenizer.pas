unit LlamaCpp.Common.Tokenizer;

interface

uses
  System.SysUtils,
  LlamaCpp.Wrapper.LlamaModel,
  LlamaCpp.Common.Tokenizer.Base;

type
  TLlamaTokenizer = class(TBaseLlamaTokenizer)
  private
    FModel: TLlamaModel; // Interface or class representing the llama model
  public
    constructor Create(AModel: TLlamaModel);

    function Tokenize(
      const AText: TBytes;
      const AAddSpecial: boolean;
      const AParseSpecial: boolean)
      : TArray<Integer>; override;
    function Detokenize(
      const ATokens: TArray<Integer>;
      const APrevTokens: TArray<Integer> = nil;
      const ASpecial: boolean = false)
      : TBytes; override;

    function Encode(
      const AText: string;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false): TArray<integer>; override;
    function Decode(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false)
      : string; override;
  end;

implementation

{ TLlamaTokenizer }

constructor TLlamaTokenizer.Create(AModel: TLlamaModel);
begin
  inherited Create;
  FModel := AModel;
end;

function TLlamaTokenizer.Tokenize(const AText: TBytes;
  const AAddSpecial, AParseSpecial: boolean): TArray<Integer>;
begin
  Result := FModel.Tokenize(AText, AAddSpecial, AParseSpecial);
end;

function TLlamaTokenizer.Detokenize(const ATokens: TArray<Integer>;
  const APrevTokens: TArray<Integer>; const ASpecial: boolean): TBytes;
begin
  Result := FModel.Detokenize(ATokens, ASpecial);
end;

function TLlamaTokenizer.Encode(const AText: string; const AAddSpecial,
  AParseSpecial: boolean): TArray<integer>;
begin
  Result := Tokenize(
    TEncoding.UTF8.Convert(
      TEncoding.Unicode,
      TEncoding.UTF8,
      TEncoding.Unicode.GetBytes(AText)),
    AAddSpecial,
    AParseSpecial);
end;

function TLlamaTokenizer.Decode(const ATokens: TArray<integer>;
  const APrevTokens: TArray<integer> = nil;
  const ASpecial: boolean = false): string;
begin
  try
    Result := TEncoding.UTF8.GetString(
      Detokenize(ATokens, APrevTokens, ASpecial));
  except
    on E: EEncodingError do
      Result := String.Empty;
  end;
end;

end.
