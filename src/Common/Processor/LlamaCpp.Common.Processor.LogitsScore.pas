unit LlamaCpp.Common.Processor.LogitsScore;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types;

type
  TDefaultLogitsScoreList = class(TInterfacedObject, ILogitsProcessorList)
  private
    FProcessors: TList<TLogitsProcessor>;
  public
    constructor Create(); overload;
    constructor Create(const AProcessor: TLogitsProcessor); overload;
    destructor Destroy(); override;

    procedure Add(const AProcessor: TLogitsProcessor);
    procedure Execute(const InputIds: TArray<Integer>;
      [ref] const Scores: TArray<Single>);
  end;

implementation

{ TDefaultLogitsScoreList }

constructor TDefaultLogitsScoreList.Create;
begin
  FProcessors := TList<TLogitsProcessor>.Create();
end;

constructor TDefaultLogitsScoreList.Create(
  const AProcessor: TLogitsProcessor);
begin
  Create();
  Add(AProcessor);
end;

destructor TDefaultLogitsScoreList.Destroy;
begin
  FProcessors.Free();
  inherited;
end;

procedure TDefaultLogitsScoreList.Add(const AProcessor: TLogitsProcessor);
begin
  FProcessors.Add(AProcessor);
end;

procedure TDefaultLogitsScoreList.Execute(const InputIds: TArray<Integer>;
  [ref] const Scores: TArray<Single>);
var
  LProcessor: TLogitsProcessor;
  LTempScores: TArray<Single>;
begin
  LTempScores := Scores;
  for LProcessor in FProcessors do
    LProcessor(InputIds, LTempScores);
end;

end.
