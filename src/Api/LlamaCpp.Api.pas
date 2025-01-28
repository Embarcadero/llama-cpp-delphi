unit LlamaCpp.Api;

interface

uses
  System.SysUtils
{$IFDEF MSWINDOWS}
    , Winapi.Windows
{$ENDIF MSWINDOWS};

type
  TLlamaCppLibraryLoader = class
  strict private
    FLibAddr: THandle;
  protected
    function GetProcAddress(const AHandle: THandle;
      const AProcName: string): pointer;
    procedure DoLoadLibrary(const ALibAddr: THandle); virtual; abstract;
  public
    procedure Load(const ALibraryPath: string);
    procedure Unload();
  end;

  TLlamaCppApis = class
  public
    class procedure LoadAll(ALibDir: string = '');
    class procedure UnloadAll();
  end;

implementation

uses
  System.IOUtils,
  LlamaCpp.Api.Ggml,
  LlamaCpp.Api.Llava,
  LlamaCpp.Api.Llama;

{ TLlamaCppLibraryLoader }

procedure TLlamaCppLibraryLoader.Load(const ALibraryPath: string);
begin
  if not TFile.Exists(ALibraryPath) then
    raise Exception.CreateFmt('Library "%s" not found.', [ALibraryPath]);

{$IFDEF MSWINDOWS}
  FLibAddr := Winapi.Windows.LoadLibrary(PWideChar(WideString(ALibraryPath)));
{$ELSE}
  FLibAddr := System.SysUtils.LoadLibrary(PWideChar(WideString(ALibraryPath)));
{$ENDIF MSWINDOWS}
  if FLibAddr = 0 then
    raise Exception.CreateFmt('Unable to load llama library. %s', [SysErrorMessage(GetLastError)]);
  DoLoadLibrary(FLibAddr);
end;

procedure TLlamaCppLibraryLoader.Unload;
begin
{$IFDEF MSWINDOWS}
  Winapi.Windows.FreeLibrary(FLibAddr);
{$ELSE}
  System.SysUtils.FreeLibrary(FLibAddr);
{$ENDIF MSWINDOWS}
end;

function TLlamaCppLibraryLoader.GetProcAddress(const AHandle: THandle;
  const AProcName: string): pointer;
begin
{$IFDEF MSWINDOWS}
  Result := Winapi.Windows.GetProcAddress(AHandle,
    PWideChar(WideString(AProcName)));
{$ELSE}
  Result := System.SysUtils.GetProcAddress(AHandle,
    PWideChar(WideString(AProcName)));
{$ENDIF MSWINDOWS}
end;

{ TLlamaCppApis }

class procedure TLlamaCppApis.LoadAll(ALibDir: string);
const
{$IFDEF MSWINDOWS}
  LIB_LLAMA = 'llama.dll';
  LIB_GGML = 'ggml.dll';
  LIB_LAVA = 'llava_shared.dll';
{$ELSEIF DEFINED(OSX64)}
  LIB_LLAMA = 'libllama.dylib';
  LIB_GGML = 'libggml.dylib';
  LIB_LAVA = 'libllava_shared.dylib';
{$ELSE}
  LIB_LLAMA = 'libllama.so';
  LIB_GGML = 'libggml.so';
  LIB_LAVA = 'libllava_shared.so';
{$ENDIF MSWINDOWS}
begin
  if ALibDir.IsEmpty() then
    ALibDir := TPath.Combine(
      PWideChar(WideString(TPath.GetDirectoryName(ParamStr(0)))),
      'llamacpp');
{$IFDEF MSWINDOWS}
  SetDllDirectory(PWideChar(WideString(ALibDir)));
{$ENDIF MSWINDOWS}
  TLlamaApi.Instance.Load(TPath.Combine(ALibDir, LIB_LLAMA));
  TGgmlApi.Instance.Load(TPath.Combine(ALibDir, LIB_GGML));
  TLlavaApi.Instance.Load(TPath.Combine(ALibDir, LIB_LAVA));
end;

class procedure TLlamaCppApis.UnloadAll;
begin
  TLlamaApi.Instance.Unload();
  TLlavaApi.Instance.Unload();
  TGgmlApi.Instance.Unload();
end;

end.
