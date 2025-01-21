unit LlamaCpp.Api.Ggml;

interface

uses
  System.SysUtils,
  LlamaCpp.Api;

type
  TGgmlApiAccess = class(TLlamaCppLibraryLoader)
  protected
    procedure DoLoadLibrary(const ALibAddr: THandle); override;
  end;

  TGgmlApi = class(TGgmlApiAccess)
  private
    class var FInstance: TGgmlApi;
  public
    class constructor Create();
    class destructor Destroy();

    class property Instance: TGgmlApi read FInstance;
  end;

implementation

{ TGgmlApiAccess }

procedure TGgmlApiAccess.DoLoadLibrary(const ALibAddr: THandle);
begin
  inherited;
  //
end;

{ TGgmlApi }

class constructor TGgmlApi.Create;
begin
  FInstance := TGgmlApi.Create();
end;

class destructor TGgmlApi.Destroy;
begin
  FInstance.Free();
end;

end.
