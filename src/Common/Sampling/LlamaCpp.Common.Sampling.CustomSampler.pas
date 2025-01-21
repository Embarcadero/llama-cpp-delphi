unit LlamaCpp.Common.Sampling.CustomSampler;

interface

uses
  System.SysUtils,
  Generics.Collections,
  LlamaCpp.CType.Llama;

type
  TApplyFunc = reference to procedure(const ATokenDataArray: PLlamaTokenDataArray);

  TCustomSampler = class
  private
    FSampler: TLlamaSampler;
    FSampelrI: TLlamaSamplerI;
    FApplyFunc: TApplyFunc;
  private
    class procedure Apply(ASmpl: PLlamaSampler; ACurrProb: PLlamaTokenDataArray); cdecl; static;
  public
    constructor Create(const AApplyFunc: TApplyFunc);
    destructor Destroy; override;

    function GetSampler: PLlamaSampler;
  end;

implementation

uses
  LlamaCpp.Api.Llama;

{ TCustomSampler }

constructor TCustomSampler.Create(const AApplyFunc: TApplyFunc);
begin
  inherited Create;
  FSampler := Default(TLlamaSampler);
  FSampelrI := Default(TLlamaSamplerI);
  FApplyFunc := AApplyFunc;

  FSampelrI.Apply := @TCustomSampler.Apply;
  FSampelrI.name := nil;
  FSampelrI.accept := nil;
  FSampelrI.reset := nil;
  FSampelrI.clone := nil;
  FSampelrI.free := nil;

  FSampler.iface := @FSampelrI;
  FSampler.ctx := Self;
end;

destructor TCustomSampler.Destroy;
begin
  inherited Destroy;
end;

class procedure TCustomSampler.Apply(ASmpl: PLlamaSampler;
  ACurrProb: PLlamaTokenDataArray);
var
  LCustomSampler: TCustomSampler;
begin
  LCustomSampler := TCustomSampler(ASmpl.Ctx);

  if Assigned(LCustomSampler.FApplyFunc) then
    LCustomSampler.FApplyFunc(ACurrProb);
end;

function TCustomSampler.GetSampler: PLlamaSampler;
begin
  Result := @FSampler;
end;

end.
