unit Utils;

interface

uses
  System.SysUtils;

type
  TTestUtils = class
  public
    class function GetLibPath(): string;
    class function GetLogsFolder(): string;
  end;

implementation

uses
  System.IOUtils;

{ TTestUtils }

class function TTestUtils.GetLibPath: string;
begin
  {$IFDEF MSWINDOWS}
  Result := 'C:\Users\lmbelo\Documents\Embarcadero\Studio\Projects\testllamacpp\Win64\Debug\llamacpp';
  {$ELSEIF DEFINED(LINUX)}
  Result := '/home/lmbelo/Documents/llama.cpp/lib';
  {$ELSEIF DEFINED(MACOS)}
  Result := '/Users/lmbelo/Documents/llamacpptest/.conda/lib/python3.11/site-packages/llama_cpp/lib';
  {$ENDIF MSWINDOWS}
end;

class function TTestUtils.GetLogsFolder: string;
begin
  Result := TPath.Combine(
    TPath.GetDocumentsPath(), 'LlamaCppDelphi', 'Tests', 'Logs');
end;

end.
