unit LlamaCpp.Common.Sampling.Params;

interface

uses
  System.Generics.Collections;

type
  TLlamaSamplingParams = class
  private
    FNPrev: Int32;
    FNProbs: Int32;
    FTopK: Int32;
    FTopP: Single;
    FMinP: Single;
    FTFS_Z: Single;
    FTypicalP: Single;
    FTemp: Single;
    FPenaltyLastN: Int32;
    FPenaltyRepeat: Single;
    FPenaltyFreq: Single;
    FPenaltyPresent: Single;
    FMirostat: Int32;
    FMirostatTau: Single;
    FMirostatEta: Single;
    FPenalizeNL: Boolean;
    FGrammar: string;
    FCFGNegativePrompt: string;
    FCFGScale: Single;
    FLogitBias: TDictionary<Int32, Single>;
  public
    constructor Create();
    destructor Destroy(); override;

    property NPrev: Int32 read FNPrev write FNPrev;
    property NProbs: Int32 read FNProbs write FNProbs;
    property TopK: Int32 read FTopK write FTopK;
    property TopP: Single read FTopP write FTopP;
    property MinP: Single read FMinP write FMinP;
    property TFS_Z: Single read FTFS_Z write FTFS_Z;
    property TypicalP: Single read FTypicalP write FTypicalP;
    property Temp: Single read FTemp write FTemp;
    property PenaltyLastN: Int32 read FPenaltyLastN write FPenaltyLastN;
    property PenaltyRepeat: Single read FPenaltyRepeat write FPenaltyRepeat;
    property PenaltyFreq: Single read FPenaltyFreq write FPenaltyFreq;
    property PenaltyPresent: Single read FPenaltyPresent write FPenaltyPresent;
    property Mirostat: Int32 read FMirostat write FMirostat;
    property MirostatTau: Single read FMirostatTau write FMirostatTau;
    property MirostatEta: Single read FMirostatEta write FMirostatEta;
    property PenalizeNL: Boolean read FPenalizeNL write FPenalizeNL;
    property Grammar: string read FGrammar write FGrammar;
    property CFGNegativePrompt: string read FCFGNegativePrompt write FCFGNegativePrompt;
    property CFGScale: Single read FCFGScale write FCFGScale;
    property LogitBias: TDictionary<Int32, Single> read FLogitBias write FLogitBias;
  end;

implementation

{ TLlamaSamplingParams }

constructor TLlamaSamplingParams.Create;
begin
  FNPrev := 64;
  FNProbs := 0;
  FTopK := 40;
  FTopP := 0.95;
  FMinP := 0.05;
  FTFS_Z := 1.00;
  FTypicalP := 1.00;
  FTemp := 0.80;
  FPenaltyLastN := 64;
  FPenaltyRepeat := 1.0;
  FPenaltyFreq := 0.00;
  FPenaltyPresent := 0.00;
  FMirostat := 0;
  FMirostatTau := 5.00;
  FMirostatEta := 0.10;
  FPenalizeNL := True;
  FGrammar := '';
  FCFGNegativePrompt := '';
  FCFGScale := 1.00;
  FLogitBias := TDictionary<Int32, Single>.Create;
end;

destructor TLlamaSamplingParams.Destroy;
begin
  LogitBias.Free();
  inherited;
end;

end.
