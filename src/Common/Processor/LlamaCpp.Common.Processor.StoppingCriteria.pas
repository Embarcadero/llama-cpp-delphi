unit LlamaCpp.Common.Processor.StoppingCriteria;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types;

type
  TDefaultStoppingCriteriaList = class(TInterfacedObject, IStoppingCriteriaList)
  private
    FCriterias: TList<TStoppingCriteria>;
  public
    constructor Create(); overload;
    constructor Create(const AProcessor: TStoppingCriteria); overload;
    destructor Destroy(); override;

    procedure Add(const AProcessor: TStoppingCriteria);
    function Execute(const AInputIds: TArray<Integer>; const ALogits: TArray<single>): Boolean;
  end;

implementation

{ TDefaultStoppingCriteriaList }

constructor TDefaultStoppingCriteriaList.Create;
begin
  FCriterias := TList<TStoppingCriteria>.Create();
end;

constructor TDefaultStoppingCriteriaList.Create(
  const AProcessor: TStoppingCriteria);
begin
  Create();
  Add(AProcessor);
end;

destructor TDefaultStoppingCriteriaList.Destroy;
begin
  FCriterias.Free();
  inherited;
end;

procedure TDefaultStoppingCriteriaList.Add(const AProcessor: TStoppingCriteria);
begin
  FCriterias.Add(AProcessor);
end;

function TDefaultStoppingCriteriaList.Execute(const AInputIds: TArray<Integer>; const ALogits: TArray<single>): Boolean;
var
  LStoppingCriteria: TStoppingCriteria;
begin
  for LStoppingCriteria in FCriterias do
    if LStoppingCriteria(AInputIds, ALogits) then
      Exit(true);

  Result := False;
end;

end.
