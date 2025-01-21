unit LlamaCpp.Common.Grammar;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  LlamaCpp.Common.Types;

const
  LLAMA_GRAMMAR_DEFAULT_ROOT = 'root';

type
  TLlamaGrammar = class(TInterfacedObject, ILlamaGrammar)
  private
    FGrammar: string;
    FRoot: string;
    function GetGrammar(): string;
    procedure SetGrammar(const AGrammar: string);
    function GetRoot(): string;
    procedure SetRoot(const ARoot: string);
  public
    constructor Create(const AGrammar: string); overload;

    procedure Reset();

    // Class methods
    class function FromString(const AGrammar: string): ILlamaGrammar; static;
    class function FromFile(const AFileName: string): ILlamaGrammar; static;
    class function FromJsonSchema(
      const AJsonSchema: string): ILlamaGrammar; static;
    class function JsonSchemaToGBNF(const ASchema: string;
      const APropOrder: TArray<string> = nil): string; static;
  end;

const
  JSON_GBNF: string = '''
  root   ::= object
  value  ::= object | array | string | number | ("true" | "false" | "null") ws

  object ::=
    "{" ws (
              string ":" ws value
      ("," ws string ":" ws value)*
    )? "}" ws

  array  ::=
    "[" ws (
              value
      ("," ws value)*
    )? "]" ws

  string ::=
    "\"" (
      [^"\\\x7F\x00-\x1F] |
      "\\" (["\\bfnrt] | "u" [0-9a-fA-F]{4}) # escapes
    )* "\"" ws

  number ::=
    ("-"? ([0-9] | [1-9] [0-9]{0,15})) ("." [0-9]+)? ([eE] [-+]? [0-9] [1-9]{0,15})? ws

  # Optional space: by convention, applied in this grammar after literal chars when allowed
  ws ::= | " " | "\n" [ \t]{0,20}
  ''';

implementation

{ TLlamaGrammar }

constructor TLlamaGrammar.Create(const AGrammar: string);
begin
  inherited Create;
  FGrammar := AGrammar;
  FRoot := LLAMA_GRAMMAR_DEFAULT_ROOT;
end;

function TLlamaGrammar.GetGrammar: string;
begin
  Result := FGrammar;
end;

function TLlamaGrammar.GetRoot: string;
begin
  Result := FRoot;
end;

procedure TLlamaGrammar.SetGrammar(const AGrammar: string);
begin
  FGrammar := AGrammar;
end;

procedure TLlamaGrammar.SetRoot(const ARoot: string);
begin
  FRoot := ARoot;
end;

class function TLlamaGrammar.FromString(const AGrammar: string): ILlamaGrammar;
begin
  Result := TLlamaGrammar.Create(AGrammar);
end;

class function TLlamaGrammar.FromFile(const AFileName: string): ILlamaGrammar;
var
  LGrammarFile: TStringList;
begin
  LGrammarFile := TStringList.Create;
  try
    try
      LGrammarFile.LoadFromFile(AFileName);

      if LGrammarFile.Text.Trim.IsEmpty then
        raise Exception.Create('Error: Grammar file is empty');

      Result := TLlamaGrammar.FromString(LGrammarFile.Text);
    except
      on E: Exception do
        raise Exception.CreateFmt('Error reading grammar file: %s', [E.Message]);
    end;
  finally
    LGrammarFile.Free;
  end;
end;

class function TLlamaGrammar.FromJsonSchema(const AJsonSchema: string): ILlamaGrammar;
begin
  Result := TLlamaGrammar.FromString(JsonSchemaToGBNF(AJsonSchema));
end;

class function TLlamaGrammar.JsonSchemaToGBNF(const ASchema: string;
  const APropOrder: TArray<string> = nil): string;
begin
  raise ENotImplemented.Create('Not implemented.');
end;

procedure TLlamaGrammar.Reset;
begin
  //
end;

end.
