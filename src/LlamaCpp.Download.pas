unit LlamaCpp.Download;

interface

uses
  System.SysUtils;

type
  TSimpleDownload = class
  public
    class var Default: TSimpleDownload;
  public
    Root: string;
  public
    constructor Create(const ARoot: string = String.Empty);

    class constructor Create();
    class destructor Destroy();

    function Download(
      const AUrl: string;
      const ARepoName: string;
      const ABranch: string = String.Empty;
      const AFiles: TArray<string> = nil)
    : TArray<string>;

    /// <summary>
    /// Default model: llama-2-7b.Q4_K_M.gguf - Size: 4.08 GB - Max RAM/VRAM required: 6.58 GB
    ///</summary>
    function DownloadLlama2_Chat_7B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: llama-30b.Q4_K_M.gguf - Size: 4.92 GB
    ///</summary>
    function DownloadLlama3_Chat_30B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: moxin-alpaca-chat-7b.Q4_K_M.gguf - Size: 4.89 GB
    ///</summary>
    function DownloadAlpaca_Chat_7B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: qwen1_5-7b-chat-q4_k_m.gguf - Size: 4.77 GB
    ///</summary>
    function DownloadQwen_Chat_7B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: Featherlite-Vicuna-13B-chat.Q4_K_M.gguf - Size: 7.87 GB
    ///</summary>
    function DownloadVicuna_Chat_13B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: mistrallite.Q4_K_M.gguf - Size: 4.37 GB - Max RAM/VRAM required: 6.87 GB
    ///</summary>
    function DownloadMistrallite_7B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: FsfairX-Zephyr-Chat-v0.1.Q4_K_M.gguf - Size: 4.37 GB
    ///</summary>
    function DownloadZephyr_Chat(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: model-q4_K.gguf - Size: 4.37 GB
    ///</summary>
    function DownloadSaiga_7B(AFiles: TArray<string> = nil): TArray<string>;
    /// <summary>
    /// Default model: Gemma-The-Writer-Mighty-Sword-9B-D_AU-Q4_k_m.gguf - Size: 5.64 GB
    ///</summary>
    function DownloadGemma_9B(AFiles: TArray<string> = nil): TArray<string>;
  end;

implementation

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFDEF POSIX}
  Posix.Base, Posix.Fcntl,
  {$ENDIF POSIX}
  System.Classes,
  System.IOUtils;

type
  TStreamHandle = pointer;

{$IFDEF MSWINDOWS}
procedure RunGitCommand(const AGitCommand: string; const AWorkingDirectory: string);
var
  LStartupInfo: TStartupInfo;
  LProcessInfo: TProcessInformation;
begin
  FillChar(LStartupInfo, SizeOf(TStartupInfo), 0);
  FillChar(LProcessInfo, SizeOf(TProcessInformation), 0);

  // Initialize startup info
  LStartupInfo.cb := SizeOf(TStartupInfo);
  LStartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  LStartupInfo.wShowWindow := SW_HIDE;

  var LCmd := 'cmd.exe /C "' + AGitCommand + '"';
  UniqueString(LCmd);

  // Run Git command
  SetEnvironmentVariable('GIT_LFS_SKIP_SMUDGE', '1');
  if not CreateProcess(
    nil,
    PChar(LCmd),
    nil,
    nil,
    false,
    0,
    nil,
    PChar(AWorkingDirectory),
    LStartupInfo,
    LProcessInfo
  ) then
    raise Exception.Create('Failed to execute Git command');

  // Wait for the process to finish
  WaitForSingleObject(LProcessInfo.hProcess, INFINITE);

  // Close handles
  CloseHandle(LProcessInfo.hProcess);
  CloseHandle(LProcessInfo.hThread);
end;
{$ENDIF MSWINDOWS}

{$IFDEF POSIX}
function popen(const command: MarshaledAString;
  const _type: MarshaledAString): TStreamHandle;
  cdecl; external libc name _PU + 'popen';

function pclose(filehandle: TStreamHandle): int32;
  cdecl; external libc name _PU + 'pclose';

function fgets(buffer: pointer; size: int32; Stream: TStreamHAndle): pointer;
  cdecl; external libc name _PU + 'fgets';

function BufferToString(const ABuffer: pointer; AMaxSize: UInt32): string;
var
  LCursor: ^uint8;
  LEndOfBuffer: nativeuint;
begin
  Result := '';

  if not Assigned(ABuffer) then
    Exit;

  LCursor := ABuffer;
  LEndOfBuffer := NativeUint(LCursor) + AMaxSize;
  while (NativeUInt(LCursor) < LEndOfBuffer) and (LCursor^ <> 0) do begin
    Result := Result + chr(LCursor^);
    LCursor := pointer(Succ(NativeUInt(LCursor)));
  end;
end;

procedure RunGitCommand(const AGitCommand: string; const AWorkingDirectory: string);
var
  LHandle: TStreamHandle;
  LData: array[0..511] of uint8;
  LMarshaller: TMarshaller;
begin
  var LDir := TDirectory.GetCurrentDirectory();
  try
    TDirectory.SetCurrentDirectory(AWorkingDirectory);
    try
      LHandle := popen(LMarshaller.AsAnsi('GIT_LFS_SKIP_SMUDGE=1 ' + AGitCommand).ToPointer(),'r');
      try
        while fgets(@LData[0], SizeOf(LData), LHandle)<>nil do begin
          Write(BufferToString(@LData[0], SizeOf(LData)));
        end;
      finally
        pclose(LHandle);
      end;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  finally
    TDirectory.SetCurrentDirectory(LDir);
  end;
end;
{$ENDIF POSIX}

{ TSimpleDownload }

constructor TSimpleDownload.Create(const ARoot: string);
begin
  Root := ARoot;
  if Root.Trim().IsEmpty() then
    Root := TPath.GetDownloadsPath();
end;

class constructor TSimpleDownload.Create;
begin
  Default := TSimpleDownload.Create();
end;

class destructor TSimpleDownload.Destroy;
begin
  Default.Free();
end;

function TSimpleDownload.Download(const AUrl, ARepoName: string;
  const ABranch: string; const AFiles: TArray<string>): TArray<string>;
const
  GIT_CLONE_POINTERS_TEMPLATE = 'git clone %s';
  GIT_CHECKOUT_BRANCH_TEMPLATE = 'git checkout %s';
  GIT_FETCH_POINTERS_TEMPLATE = 'git lfs fetch --include="%s"';
  GIT_LFS_CHECKOUT_TEMPLATE = 'git lfs checkout %s';
var
  LModelsPath: string;
  LRepoFolder: string;
  LFile: string;
begin
  LModelsPath := TPath.Combine(Root, 'LlamaCppDelphi');

  LRepoFolder := TPath.Combine(LModelsPath, ARepoName);

  if not TDirectory.Exists(LModelsPath) then
    TDirectory.CreateDirectory(LModelsPath);

  // Clone large files pointers only
  RunGitCommand(
    String.Format(GIT_CLONE_POINTERS_TEMPLATE, [AUrl]),
    LModelsPath);

  if not TDirectory.Exists(LRepoFolder) then
    raise Exception.Create('Repository folder not found.');

  // Checkout branch
  if not ABranch.Trim().IsEmpty() then
    RunGitCommand(
      String.Format(GIT_CHECKOUT_BRANCH_TEMPLATE, [ABranch]),
      LRepoFolder);

  // Clone user required pointer only
  RunGitCommand(
    String.Format(GIT_FETCH_POINTERS_TEMPLATE, [String.Join(', ', AFiles)]),
    LRepoFolder);

  // Update repo pointers
  Result := nil;
  for LFile in AFiles do
  begin
    if not TFile.Exists(TPath.Combine(LRepoFolder, LFile)) then
      Continue;

    RunGitCommand(String.Format(GIT_LFS_CHECKOUT_TEMPLATE, [LFile]), LRepoFolder);

    Result := Result + [TPath.Combine(LRepoFolder, LFile)];
  end;

  if not Assigned(Result) then
    Result := [LRepoFolder];
end;

function TSimpleDownload.DownloadLlama2_Chat_7B(AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['llama-2-7b-chat.Q4_K_M.gguf'];

  Result := Download(
    'https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF',
    'Llama-2-7B-Chat-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadLlama3_Chat_30B(AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['Meta-Llama-3-8B-Instruct.Q4_K_M.gguf'];

  Result := Download(
    'https://huggingface.co/QuantFactory/Meta-Llama-3-8B-Instruct-GGUF',
    'Meta-Llama-3-8B-Instruct-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadAlpaca_Chat_7B(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['moxin-alpaca-chat-7b.Q4_K_M.gguf'];

  Result := Download(
    'https://huggingface.co/mradermacher/moxin-alpaca-chat-7b-GGUF',
    'moxin-alpaca-chat-7b-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadQwen_Chat_7B(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['qwen1_5-7b-chat-q4_k_m.gguf'];

  Result := Download(
    'https://huggingface.co/Qwen/Qwen1.5-7B-Chat-GGUF',
    'Qwen1.5-7B-Chat-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadVicuna_Chat_13B(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['Featherlite-Vicuna-13B-chat.Q4_K_M.gguf'];

  Result := Download(
    'https://huggingface.co/mradermacher/Featherlite-Vicuna-13B-chat-GGUF',
    'Featherlite-Vicuna-13B-chat-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadMistrallite_7B(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['mistrallite.Q4_K_M.gguf'];

  Result := Download(
    'https://huggingface.co/TheBloke/MistralLite-7B-GGUF',
    'MistralLite-7B-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadZephyr_Chat(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['FsfairX-Zephyr-Chat-v0.1.Q4_K_M.gguf'];

  Result := Download(
    'https://huggingface.co/mradermacher/FsfairX-Zephyr-Chat-v0.1-GGUF',
    'FsfairX-Zephyr-Chat-v0.1-GGUF',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadSaiga_7B(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['model-q4_K.gguf'];

  Result := Download(
    'https://huggingface.co/IlyaGusev/saiga_mistral_7b_gguf',
    'saiga_mistral_7b_gguf',
    String.Empty,
    AFiles);
end;

function TSimpleDownload.DownloadGemma_9B(
  AFiles: TArray<string>): TArray<string>;
begin
  if not Assigned(AFiles) then
    AFiles := ['Gemma-The-Writer-Mighty-Sword-9B-D_AU-Q4_k_m.gguf'];

  Result := Download(
    'https://huggingface.co/DavidAU/Gemma-The-Writer-Mighty-Sword-9B-GGUF',
    'Gemma-The-Writer-Mighty-Sword-9B-GGUF',
    String.Empty,
    AFiles);
end;

end.
