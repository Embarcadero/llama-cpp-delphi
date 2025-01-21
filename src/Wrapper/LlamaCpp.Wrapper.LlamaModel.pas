unit LlamaCpp.Wrapper.LlamaModel;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.CType.Llama,
  LlamaCpp.CType.Ggml;

type
  TMetadata = TDictionary<string, string>;

  TLlamaModel = class
  private
    FPathModel: string;
    FParams: TLlamaModelParams;
    FModel: PLlamaModel;
  public
    constructor Create(const APathModel: string;
      const AParams: TLlamaModelParams);
    destructor Destroy(); override;

    procedure LoadModel();
    procedure UnloadModel();

    function VocabType(): TLlamaVocabType;
    function NVocab(): integer;
    function NCtxTrain(): integer;
    function NEmb(): integer;
    function RopeFreqScaleTrain(): Single;
    function Desc(): string;
    function Size(): integer;
    function NParams(): integer;
    function GetTensor(const AName: string): PGgmlTensor;

    // Vocab
    function TokenGetText(Token: integer): string;
    function TokenGetScore(Token: integer): Single;
    function TokenGetAttr(Token: integer): TLLamaTokenAttr;

    // Special tokens
    function TokenBOS(): integer;
    function TokenEOS(): integer;
    function TokenCLS(): integer;
    function TokenSEP(): integer;
    function TokenNL(): integer;
    function TokenPrefix(): integer;
    function TokenMiddle(): integer;
    function TokenSuffix(): integer;
    function TokenEOT(): integer;
    function AddBOSToken(): Boolean;
    function AddEOSToken(): Boolean;

    // Tokenization
    function Tokenize(const AText: TBytes; AAddSpecial, AParseSpecial: Boolean)
      : TArray<integer>; overload;
    function Tokenize(const AText: string; AAddSpecial, AParseSpecial: Boolean)
      : TArray<integer>; overload;
    function TokenToPiece(const AToken: integer;
      const ASpecial: Boolean = False): TBytes;
    function Detokenize(const ATokens: TArray<integer>;
      const ASpecial: Boolean = False): TBytes;

    // Extra
    function Metadata(): TMetadata;
  public
    class function DefaultParams(): TLlamaModelParams; static;
  public
    property Model: PLlamaModel read FModel;
  end;

implementation

uses
  System.IOUtils,
  LlamaCpp.Api.Llama;

{ TLlamaModel }

constructor TLlamaModel.Create(const APathModel: string;
  const AParams: TLlamaModelParams);
begin
  FPathModel := APathModel;
  FParams := AParams;
end;

destructor TLlamaModel.Destroy;
begin
  inherited;
end;

procedure TLlamaModel.LoadModel;
begin
  if not TFile.Exists(FPathModel) then
    raise Exception.Create('Model path does not exist.');

  FModel := TLlamaApi.Instance.llama_load_model_from_file
    (PAnsiChar(UTF8Encode(FPathModel)), FParams);

  if not Assigned(FModel) then
    raise Exception.Create('Failed to load model from file.');
end;

procedure TLlamaModel.UnloadModel;
begin
  if Assigned(FModel) then
    TLlamaApi.Instance.llama_free_model(FModel);

  FModel := nil;
end;

function TLlamaModel.VocabType: TLlamaVocabType;
begin
  Result := TLlamaApi.Instance.llama_vocab_type(FModel);
end;

function TLlamaModel.NVocab: integer;
begin
  Result := TLlamaApi.Instance.llama_n_vocab(FModel);
end;

function TLlamaModel.NCtxTrain: integer;
begin
  Result := TLlamaApi.Instance.llama_n_ctx_train(FModel);
end;

function TLlamaModel.NEmb: integer;
begin
  Result := TLlamaApi.Instance.llama_n_embd(FModel);
end;

function TLlamaModel.RopeFreqScaleTrain: Single;
begin
  Result := TLlamaApi.Instance.llama_rope_freq_scale_train(FModel);
end;

function TLlamaModel.Desc: string;
var
  LBuff: PAnsiChar;
begin
  GetMem(LBuff, 1024);
  try
    TLlamaApi.Instance.llama_model_desc(FModel, LBuff, 1024);
    Result := UTF8ToString(LBuff);
  finally
    FreeMem(LBuff);
  end;
end;

function TLlamaModel.Size: integer;
begin
  Result := TLlamaApi.Instance.llama_model_size(FModel);
end;

function TLlamaModel.NParams: integer;
begin
  Result := TLlamaApi.Instance.llama_model_n_params(FModel);
end;

function TLlamaModel.GetTensor(const AName: string): PGgmlTensor;
begin
  Result := TLlamaApi.Instance.llama_get_model_tensor(FModel,
    PAnsiChar(UTF8Encode(AName)));
end;

function TLlamaModel.TokenGetText(Token: integer): string;
var
  TextPtr: PAnsiChar;
begin
  TextPtr := TLlamaApi.Instance.llama_token_get_text(FModel, Token);
  Result := UTF8ToString(TextPtr);
end;

function TLlamaModel.TokenGetScore(Token: integer): Single;
begin
  Result := TLlamaApi.Instance.llama_token_get_score(FModel, Token);
end;

function TLlamaModel.TokenGetAttr(Token: integer): TLLamaTokenAttr;
begin
  Result := TLlamaApi.Instance.llama_token_get_attr(FModel, Token);
end;

function TLlamaModel.TokenBOS: integer;
begin
  Result := TLlamaApi.Instance.llama_token_bos(FModel);
end;

function TLlamaModel.TokenEOS: integer;
begin
  Result := TLlamaApi.Instance.llama_token_eos(FModel);
end;

function TLlamaModel.TokenCLS: integer;
begin
  Result := TLlamaApi.Instance.llama_token_cls(FModel);
end;

function TLlamaModel.TokenSEP: integer;
begin
  Result := TLlamaApi.Instance.llama_token_sep(FModel);
end;

function TLlamaModel.TokenNL: integer;
begin
  Result := TLlamaApi.Instance.llama_token_nl(FModel);
end;

function TLlamaModel.TokenPrefix: integer;
begin
  Result := TLlamaApi.Instance.llama_token_prefix(FModel);
end;

function TLlamaModel.TokenMiddle: integer;
begin
  Result := TLlamaApi.Instance.llama_token_middle(FModel);
end;

function TLlamaModel.TokenSuffix: integer;
begin
  Result := TLlamaApi.Instance.llama_token_suffix(FModel);
end;

function TLlamaModel.TokenEOT: integer;
begin
  Result := TLlamaApi.Instance.llama_token_eot(FModel);
end;

function TLlamaModel.AddBOSToken: Boolean;
begin
  Result := TLlamaApi.Instance.llama_add_bos_token(FModel);
end;

function TLlamaModel.AddEOSToken: Boolean;
begin
  Result := TLlamaApi.Instance.llama_add_eos_token(FModel);
end;

function TLlamaModel.Tokenize(const AText: TBytes;
  AAddSpecial, AParseSpecial: Boolean): TArray<integer>;
var
  LNCtx: integer;
  LTokens: array of integer;
  LNTokens: integer;
begin
  LNCtx := NCtxTrain;
  SetLength(LTokens, LNCtx);

  LNTokens := TLlamaApi.Instance.llama_tokenize(FModel, PAnsiChar(AText),
    Length(AText), @LTokens[0], LNCtx, AAddSpecial, AParseSpecial);

  if LNTokens < 0 then
  begin
    LNTokens := Abs(LNTokens);
    SetLength(LTokens, LNTokens);

    LNTokens := TLlamaApi.Instance.llama_tokenize(FModel, PAnsiChar(AText),
      Length(AText), @LTokens[0], LNTokens, AAddSpecial, AParseSpecial);

    if LNTokens < 0 then
      raise Exception.CreateFmt('Failed to tokenize: text="%s" n_tokens=%d',
        [AText, LNTokens]);
  end;

  SetLength(Result, LNTokens);
  Move(LTokens[0], Result[0], LNTokens * SizeOf(integer));
end;

function TLlamaModel.Tokenize(const AText: string;
  AAddSpecial, AParseSpecial: Boolean): TArray<integer>;
begin
  Result := Tokenize(TEncoding.UTF8.GetBytes(AText), AAddSpecial,
    AParseSpecial);
end;

function TLlamaModel.TokenToPiece(const AToken: integer;
  const ASpecial: Boolean = False): TBytes;
var
  LBuf: array [0 .. 31] of Byte;
begin
  TLlamaApi.Instance.llama_token_to_piece(FModel, AToken, @LBuf[0],
    Length(LBuf), 0, ASpecial);

  SetLength(Result, Length(LBuf));
  Move(LBuf[0], Result[0], Length(LBuf));
end;

function TLlamaModel.Detokenize(const ATokens: TArray<integer>;
  const ASpecial: Boolean): TBytes;
var
  LBuffer: array [0 .. 31] of Byte;
  LToken: integer;
  N: integer;
begin
  Result := nil;

  for LToken in ATokens do
  begin
    N := TLlamaApi.Instance.llama_token_to_piece(FModel, LToken, @LBuffer[0],
      Length(LBuffer), 0, ASpecial);

    Assert(N <= Length(LBuffer));

    if N <= 0 then
      Continue;

    SetLength(Result, Length(Result) + N);

    Move(LBuffer[0], Result[High(Result) - N + 1], N);
  end;

  // Adjust for leading space removal if the first token is BOS
  if (Length(ATokens) > 0) and (ATokens[0] = TokenBOS) and (Length(Result) > 0)
    and (Result[0] = Byte(' ')) then
  begin
    Result := Copy(Result, 1, Length(Result) - 1);
  end;
end;

function TLlamaModel.Metadata: TMetadata;
var
  LBufferSize: integer;
  LBuffer: PAnsiChar;
  I, LNBytes: integer;
  LKey, LValue: string;
begin
  Result := TMetadata.Create();
  try
    LBufferSize := 1024;
    GetMem(LBuffer, LBufferSize);

    try
      for I := 0 to TLlamaApi.Instance.llama_model_meta_count(FModel) - 1 do
      begin
        // Get metadata key
        FillChar(LBuffer^, LBufferSize, 0);
        LNBytes := TLlamaApi.Instance.llama_model_meta_key_by_index(FModel, I,
          LBuffer, LBufferSize);

        if LNBytes > LBufferSize then
        begin
          ReallocMem(LBuffer, LNBytes + 1);
          LBufferSize := LNBytes + 1;
          { LNBytes := }
          TLlamaApi.Instance.llama_model_meta_key_by_index(FModel, I, LBuffer,
            LBufferSize);
        end;

        LKey := UTF8ToString(LBuffer);

        // Get metadata value
        FillChar(LBuffer^, LBufferSize, 0);
        LNBytes := TLlamaApi.Instance.llama_model_meta_val_str_by_index(FModel,
          I, LBuffer, LBufferSize);

        if LNBytes > LBufferSize then
        begin
          ReallocMem(LBuffer, LNBytes + 1);
          LBufferSize := LNBytes + 1;
          { LNBytes := }
          TLlamaApi.Instance.llama_model_meta_val_str_by_index(FModel, I,
            LBuffer, LBufferSize);
        end;

        LValue := UTF8ToString(LBuffer);

        Result.Add(LKey, LValue);
      end;
    finally
      FreeMem(LBuffer);
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

class function TLlamaModel.DefaultParams: TLlamaModelParams;
begin
  Result := TLlamaApi.Instance.llama_model_default_params();
end;

end.
