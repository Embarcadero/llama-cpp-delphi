unit LlamaCpp.Common.Types;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.State,
  LlamaCpp.Common.TokenArray,
  LlamaCpp.Common.Settings,
  LlamaCpp.Common.Sampling.Params,
  LlamaCpp.Common.Sampling.CustomSampler,
  LlamaCpp.Common.Chat.Types;

type
  TCompletionCallback = reference to procedure(
    const AResponse: TCreateCompletionResponse; var AContinue: boolean);
  TChatCompletionCallback = reference to procedure(
    const AResponse: TChatCompletionStreamResponse; var AContinue: boolean);

  TStoppingCriteria = reference to function(
    const ATokens: TArray<Integer>;
    const ALogits: TArray<single>): boolean;

  IStoppingCriteriaList = interface
    ['{1DFC697E-E47B-4FC9-A2AD-64F8B332B27B}']
    procedure Add(const AProcessor: TStoppingCriteria);
    function Execute(const AInputIds: TArray<Integer>;
      const ALogits: TArray<single>): boolean;
  end;

  TLogitsProcessor = reference to procedure(
    const InputIds: TArray<Integer>;
    [ref] const Scores: TArray<Single>
  );

  ILogitsProcessorList = interface
    ['{90061F97-DC6B-4FAA-B2B7-399509B21FB8}']
    procedure Add(const AProcessor: TLogitsProcessor);
    procedure Execute(const InputIds: TArray<Integer>;
      [ref] const Scores: TArray<Single>);
  end;

  ILlamaCache = Interface
    ['{F28B509B-443F-4F8F-B8EB-B9FF32D83A5D}']
    function GetCacheSize: Int64;
    function LongestTokenPrefix(const A, B: TArray<integer>): integer;
    function FindLongestPrefixKey(const AKey: TArray<Integer>): TArray<integer>;
    function GetItem(const AKey: TArray<Integer>): TLlamaState;
    function Contains(const AKey: TArray<Integer>): Boolean;
    procedure SetItem(const AKey: TArray<Integer>; const AValue: TLlamaState);

    property CacheSize: Int64 read GetCacheSize;
    property Items[const AKey: TArray<Integer>]: TLlamaState read GetItem write SetItem; default;
  end;

  ILlamaGrammar = interface
    ['{9E2B2065-9ADA-4A7A-B145-D5CE44712D20}']
    function GetGrammar(): string;
    procedure SetGrammar(const AGrammar: string);
    function GetRoot(): string;
    procedure SetRoot(const ARoot: string);

    procedure Reset();

    property Grammar: string read GetGrammar write SetGrammar;
    property Root: string read GetRoot write SetRoot;
  end;

  ILlamaTokenizer = interface
    ['{B7AF62EE-53C6-4DAF-84E3-7C46A1791232}']
    function Tokenize(
      const AText: TBytes;
      const AAddSpecial: boolean = true;
      const AParseSpecial: Boolean = true)
      : TArray<Integer>;

    function Detokenize(
      const ATokens: TArray<Integer>;
      const APrevTokens: TArray<Integer> = nil;
      const ASpecial: Boolean = False): TBytes;

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

  // Speculative decoding
  ILlamaDraftModel = interface
    ['{D28A39AB-EEC0-4DBC-AFD6-5188CDD0644E}']
    function Execute(const AInputIds: TArray<integer>): TArray<integer>;
  end;

  TokenizationTask = reference to function(
    const AText: string;
    const AAddSpecial: boolean = true;
    const AParseSpecial: boolean = false): TArray<integer>;

  TCreateCompletionTask = reference to function(
    const ATokens: TArray<integer>;
    ASettings: TLlamaCompletionSettings;
    const AStoppingCriteria: IStoppingCriteriaList = nil;
    const ALogitsProcessor: ILogitsProcessorList = nil;
    const AGrammar: ILlamaGrammar = nil)
    : TCreateCompletionResponse;

  TCreateCompletionTaskAsync = reference to procedure(
    const ATokens: TArray<integer>;
    ASettings: TLlamaCompletionSettings;
    const ACallback: TCompletionCallback;
    const AStoppingCriteria: IStoppingCriteriaList = nil;
    const ALogitsProcessor: ILogitsProcessorList = nil;
    const AGrammar: ILlamaGrammar = nil);

  ILlamaChatCompletionHandler = interface
    ['{B4354AD2-9F0F-46B2-A30C-17BB2849D348}']
    function Handle(
      ASettings: TLlamaChatCompletionSettings;
      const ATokenizationTask: TokenizationTask;
      const ACreateCompletionTask: TCreateCompletionTask;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil)
      : TCreateChatCompletionResponse; overload;
    procedure Handle(
      ASettings: TLlamaChatCompletionSettings;
      const ATokenizationTask: TokenizationTask;
      const ACreateCompletionTask: TCreateCompletionTaskAsync;
      const ACallback: TChatCompletionCallback;
      const AStoppingCriteria: IStoppingCriteriaList = nil;
      const ALogitsProcessor: ILogitsProcessorList = nil;
      const AGrammar: ILlamaGrammar = nil); overload;
  end;

  ILlamaChatFormater = interface
    ['{D4EA01ED-E8FB-4BC0-A850-6B3AF367784D}']
    function Format(const ASettings: TLlamaChatCompletionSettings)
    : TChatFormatterResponse;
  end;

  TNullable<T> = record
  private
    FValue: T;
    FIsNull: Boolean;

    function GetValue: T;
    procedure SetValue(const AValue: T);
  public
    constructor Create(const AValue: T); overload;

    procedure Clear;

    class operator Initialize(out Dest: TNullable<T>);
    class operator Finalize(var Dest: TNullable<T>);

    // Implicit and explicit conversions
    class operator Implicit(const A: TNullable<T>): T;
    class operator Implicit(const A: T): TNullable<T>;

    // Operator overloads
    class operator Add(const A, B: TNullable<T>): TNullable<T>;
    class operator Subtract(const A, B: TNullable<T>): TNullable<T>;
    class operator Multiply(const A, B: TNullable<T>): TNullable<T>;
    class operator Divide(const A, B: TNullable<T>): TNullable<T>;
    class operator IntDivide(const A, B: TNullable<T>): TNullable<T>;
    class operator Modulus(const A, B: TNullable<T>): TNullable<T>;

    // Comparison operators
    class operator Equal(const A, B: TNullable<T>): Boolean;
    class operator NotEqual(const A, B: TNullable<T>): Boolean;
    class operator GreaterThan(const A, B: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(const A, B: TNullable<T>): Boolean;
    class operator LessThan(const A, B: TNullable<T>): Boolean;
    class operator LessThanOrEqual(const A, B: TNullable<T>): Boolean;

    class function Null(): TNullable<T>; static;

    function CanCast<C>: boolean;
    function Cast<C>(): C;

    property Value: T read GetValue write SetValue;
    property IsNull: boolean read FIsNull;
  end;

  TInteger = TNullable<integer>;
  TString = TNullable<string>;

implementation

{ TNullable<T> }

constructor TNullable<T>.Create(const AValue: T);
begin
  FValue := AValue;
  FIsNull := False;
end;

function TNullable<T>.GetValue: T;
begin
  if FIsNull then
    raise Exception.Create('Attempt to access a null value');
  Result := FValue;
end;

procedure TNullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FIsNull := False;
end;

procedure TNullable<T>.Clear;
begin
  FIsNull := True;
end;

function TNullable<T>.CanCast<C>: boolean;
var
  LResult: TValue;
begin
  Result := TValue.From<T>(FValue).TryCast(TypeInfo(C), LResult);
end;

function TNullable<T>.Cast<C>: C;
begin
  Result := TValue.From<T>(FValue).AsType<C>;
end;

class operator TNullable<T>.Initialize(out Dest: TNullable<T>);
begin
  Dest.Clear();
end;

class operator TNullable<T>.Finalize(var Dest: TNullable<T>);
begin
  Dest.Clear();
end;

class operator TNullable<T>.Add(const A, B: TNullable<T>): TNullable<T>;
begin
  if A.IsNull or B.IsNull then
    Exit(Default(TNullable<T>));

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := TValue.From<integer>(A.Cast<integer> + B.Cast<integer>).AsType<T>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.Subtract(const A, B: TNullable<T>): TNullable<T>;
begin
  if A.IsNull or B.IsNull then
    Exit(Default(TNullable<T>));

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := TValue.From<integer>(A.Cast<integer> - B.Cast<integer>).AsType<T>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.Multiply(const A, B: TNullable<T>): TNullable<T>;
begin
  if A.IsNull or B.IsNull then
    Exit(Default(TNullable<T>));

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := TValue.From<integer>(A.Cast<integer> * B.Cast<integer>).AsType<T>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.Divide(const A, B: TNullable<T>): TNullable<T>;
begin
  if A.IsNull or B.IsNull then
    Exit(Default(TNullable<T>));

  if A.CanCast<integer> and B.CanCast<integer> then
  begin
    if B.Cast<integer> = 0 then
      raise Exception.Create('Division by zero is not allowed');

    Result := TValue.From<double>(A.Cast<integer> / B.Cast<integer>).AsType<T>
  end
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.IntDivide(const A, B: TNullable<T>): TNullable<T>;
begin
  if A.IsNull or B.IsNull then
    Exit(Default(TNullable<T>));

  if not A.CanCast<integer> or not B.CanCast<integer> then
    raise Exception.Create('IntDivide is supported only for integer types');

  if (B.Cast<integer> = 0) then
    raise Exception.Create('Division by zero is not allowed');

  Result := TNullable<T>.Create(
    TValue.From<integer>(A.Cast<integer> div B.Cast<integer>).AsType<T>);
end;

class operator TNullable<T>.Modulus(const A, B: TNullable<T>): TNullable<T>;
begin
  if A.IsNull or B.IsNull then
    Exit(Default(TNullable<T>));

  if not A.CanCast<integer> or not B.CanCast<integer> then
    raise Exception.Create('IntDivide is supported only for integer types');

  if (B.Cast<integer> = 0) then
    raise Exception.Create('Modulus by zero is not allowed');

  Result := TNullable<T>.Create(
    TValue.From<integer>(A.Cast<integer> mod B.Cast<integer>).AsType<T>);
end;

class operator TNullable<T>.Equal(const A, B: TNullable<T>): Boolean;
begin
  Result := false;

  if A.IsNull and B.IsNull then
    Exit(true);

  if A.IsNull or B.IsNull then
    Exit(false);

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := A.Cast<integer> = B.Cast<integer>;
end;

class operator TNullable<T>.NotEqual(const A, B: TNullable<T>): Boolean;
begin
  Result := not (A = B);
end;

class operator TNullable<T>.GreaterThan(const A, B: TNullable<T>): Boolean;
begin
  if A.IsNull or B.IsNull then
    Exit(False);

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := A.Cast<integer> > B.Cast<integer>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.GreaterThanOrEqual(const A, B: TNullable<T>): Boolean;
begin
  if A.IsNull or B.IsNull then
    Exit(False);

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := A.Cast<integer> >= B.Cast<integer>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.LessThan(const A, B: TNullable<T>): Boolean;
begin
  if A.IsNull or B.IsNull then
    Exit(False);

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := A.Cast<integer> < B.Cast<integer>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.LessThanOrEqual(const A, B: TNullable<T>): Boolean;
begin
  if A.IsNull or B.IsNull then
    Exit(False);

  if A.CanCast<integer> and B.CanCast<integer> then
    Result := A.Cast<integer> <= B.Cast<integer>
  else
    raise ENotImplemented.Create('Not implemented.');
end;

class operator TNullable<T>.Implicit(const A: TNullable<T>): T;
begin
  if A.IsNull then
    raise Exception.Create('Cannot implicitly convert a null value');

  Result := A.FValue;
end;

class operator TNullable<T>.Implicit(const A: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(A);
end;

class function TNullable<T>.Null: TNullable<T>;
begin
  Result := Default(TNullable<T>);
end;

end.
