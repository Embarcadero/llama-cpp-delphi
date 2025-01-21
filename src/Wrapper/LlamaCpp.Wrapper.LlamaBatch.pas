unit LlamaCpp.Wrapper.LlamaBatch;

interface

uses
  System.SysUtils,
  LlamaCpp.CType.Llama;

type
  TLlamaBatch = class
  private
    FBatch: LlamaCpp.CType.Llama.TLlamaBatch;
    FNTokens: Integer;
    FEmbeddings: Integer;
    FNSeqMax: Integer;
    function HasBatch(): boolean;
  public
    constructor Create(const ANTokens, AEmbeddings, ANSeqMax: Integer);
    destructor Destroy(); override;

    procedure LoadBatch();
    procedure UnloadBatch();

    function NTokens: Integer;
    procedure Reset;
    procedure SetBatch(const ABatch: TArray<Integer>; ANPast: Integer; ALogitsAll: Boolean);
    procedure AddSequence(const ABatch: TArray<Integer>; ASeqID: Integer; ALogitsAll: Boolean);
  public
    property Batch: LlamaCpp.CType.Llama.TLlamaBatch read FBatch;
  end;

implementation

uses
  System.IOUtils,
  LlamaCpp.Api.Llama;

{ TLlamaBatch }

constructor TLlamaBatch.Create(const ANTokens, AEmbeddings, ANSeqMax: Integer);
begin
  FNTokens := ANTokens;
  FEmbeddings := AEmbeddings;
  FNSeqMax := ANSeqMax;
end;

destructor TLlamaBatch.Destroy;
begin
  inherited;
end;

function TLlamaBatch.HasBatch: boolean;
begin
  Result := Assigned(FBatch.n_seq_id);
end;

procedure TLlamaBatch.LoadBatch;
begin
  FBatch := TLlamaApi.Instance.llama_batch_init(FNTokens, FEmbeddings, FNSeqMax);

  if not HasBatch() then  
    raise Exception.Create('Failed to create llama_batch');
end;

procedure TLlamaBatch.UnloadBatch;
begin
  if HasBatch() then
    TLlamaApi.Instance.llama_batch_free(FBatch);
end;

function TLlamaBatch.NTokens: Integer;
begin
  Result := FBatch.n_tokens;
end;

procedure TLlamaBatch.Reset;
begin
  FBatch.n_tokens := 0;
end;

procedure TLlamaBatch.SetBatch(const ABatch: TArray<Integer>; ANPast: Integer; ALogitsAll: Boolean);
var
  i, n_tokens: Integer;
begin
  n_tokens := Length(ABatch);
  FBatch.n_tokens := n_tokens;
  {$R-}
  for i := 0 to n_tokens - 1 do
  begin
    FBatch.token^[i] := ABatch[i];
    FBatch.pos^[i] := ANPast + i;
    FBatch.seq_id^[i][0] := 0;
    FBatch.n_seq_id^[i] := 1;
    FBatch.logits^[i] := ShortInt(ALogitsAll);
  end;
  FBatch.logits^[n_tokens - 1] := ShortInt(true);
  {$R+}
end;

procedure TLlamaBatch.AddSequence(const ABatch: TArray<Integer>; ASeqID: Integer; ALogitsAll: Boolean);
var
  i, j, n_tokens, n_tokens0: Integer;
begin
  n_tokens := Length(ABatch);
  n_tokens0 := FBatch.n_tokens;
  FBatch.n_tokens := FBatch.n_tokens + n_tokens;
  {$R-}
  for i := 0 to n_tokens - 1 do
  begin
    j := n_tokens0 + i;
    FBatch.token^[j] := ABatch[i];
    FBatch.pos^[j] := i;
    FBatch.seq_id^[j][0] := ASeqID;
    FBatch.n_seq_id^[j] := 1;
    FBatch.logits^[j] := ShortInt(ALogitsAll);
  end;
  FBatch.logits^[n_tokens - 1] := ShortInt(true);
  {$R+}
end;

end.
