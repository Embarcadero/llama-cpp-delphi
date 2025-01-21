unit LlamaCpp.Common.Tokenizer.Base;

interface

uses
  System.SysUtils,
  LlamaCpp.Common.Types;

type
  TBaseLlamaTokenizer = class(TInterfacedObject, ILlamaTokenizer)
  public
    function Tokenize(
      const AText: TBytes;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false)
      : TArray<integer>; virtual; abstract;
    function Detokenize(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false)
      : TBytes; virtual; abstract;

    function Encode(
      const AText: string;
      const AAddSpecial: boolean = true;
      const AParseSpecial: boolean = false)
      : TArray<integer>; virtual; abstract;
    function Decode(
      const ATokens: TArray<integer>;
      const APrevTokens: TArray<integer> = nil;
      const ASpecial: boolean = false)
      : string; virtual; abstract;
  end;

implementation

end.
