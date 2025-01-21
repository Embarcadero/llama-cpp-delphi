unit ChatFormatters;

interface

uses
  System.Sysutils,
  System.Classes,
  System.Generics.Collections,
  TestFramework,
  DUnitX.TestFramework,
  LlamaCpp.Api,
  LlamaCpp.Types,
  LlamaCpp.Llama,
  LlamaCpp.Common.Chat.Types;

type
  { **************************************************************************

                        !!!! WARNING !!!!

               >>>>>>>> THIS IS HUGE!!!!!! <<<<<<<<<

             This test will download many BIG models

    ************************************************************************** }
  TChatFormattersTest = class(TTestCase)
  private
    class var FLogDirectory: string;
    class procedure Log(
      const AModel: string;
      const AIdentifier: string;
      const AChat: string);
    class procedure ClearLogs();
  private
    procedure TestChat(const AModelPath, AChatFormat: string);
  public
    class constructor Create();
    class destructor Destroy();
  published
    procedure TestLlama2();
    procedure TestLlama3();
    procedure TestAlpaca();
    procedure TestQwen();
    procedure TestVicuna();
    procedure TestMistrallite();
    procedure TestZephyr();
    procedure TestSaiga();
    procedure TestGemma();
  end;

implementation

uses
  System.Variants,
  System.IOUtils,
  LlamaCpp.Download,
  Utils;

{ TChatFormattersTest }

class constructor TChatFormattersTest.Create;
begin
  FLogDirectory := TPath.Combine(TTestUtils.GetLogsFolder(), 'ChatFormatters');
  
  TLlamaCppApis.LoadAll(TTestUtils.GetLibPath());
  
  ClearLogs();
  
  if not TDirectory.Exists(FLogDirectory) then
    TDirectory.CreateDirectory(FLogDirectory);
end;

class destructor TChatFormattersTest.Destroy;
begin
  TLlamaCppApis.UnloadAll();
end;

class procedure TChatFormattersTest.ClearLogs;
begin
  if TDirectory.Exists(FLogDirectory) then
    TDirectory.Delete(FLogDirectory, true);
end;

class procedure TChatFormattersTest.Log(const AModel, AIdentifier, AChat: string);
begin
  var LLogFile := TPath.Combine(FLogDirectory, AIdentifier) + '.log';
  
  if TFile.Exists(LLogFile) then
    TFile.Delete(LLogFile);
  
  TFile.Create(LLogFile).Free();
  
  var LHeader := '-> Execution date/time: ' + DateTimeToStr(Now()) + sLineBreak;
  LHeader := LHeader + '-> Model: ' + AModel + sLineBreak + sLineBreak;
  
  TFile.WriteAllText(
    LLogFile,
    LHeader + AChat);
end;

procedure TChatFormattersTest.TestChat(const AModelPath, AChatFormat: string);
begin
  var LSettings := TLlamaSettings.Create();
  try
    LSettings.Seed := Random(High(Integer));
    LSettings.ChatFormat := AChatFormat;

    var Llama: ILlama := TLlamaBase.Create(AModelPath, LSettings);
    var LChatCompletion := LLama as ILlamaChatCompletion;

    var LMessages: TArray<TChatCompletionRequestMessage> := [
      TChatCompletionRequestMessage.System(
        'You are a master in the Delphi programming language.'),
      TChatCompletionRequestMessage.User(
        'What is Delphi?')
    ];

    var LCompletion := LChatCompletion.CreateChatCompletion(
      TLlamaChatCompletionSettings.Create(LMessages));

    Assert.IsNotNull(LCompletion.Choices);
    Assert.IsNotEmpty(VarToStr(LCompletion.Choices[0].Message.Content));

    LMessages := LMessages + [
      TChatCompletionRequestMessage.Assistant(
        VarToStr(LCompletion.Choices[0].Message.Content))];

    Log(AModelPath, AChatFormat, TChatCompletionRequestMessage.ToString(LMessages));
  finally
    LSettings.Free();
  end;
end;

procedure TChatFormattersTest.TestLlama2;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadLlama2_Chat_7B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'llama-2');
end;

procedure TChatFormattersTest.TestLlama3;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadLlama3_Chat_30B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'llama-3');
end;

procedure TChatFormattersTest.TestAlpaca;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadAlpaca_Chat_7B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'alpaca');
end;

procedure TChatFormattersTest.TestQwen;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadQwen_Chat_7B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'qwen');
end;

procedure TChatFormattersTest.TestVicuna;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadVicuna_Chat_13B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'vicuna');
end;

procedure TChatFormattersTest.TestMistrallite;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadMistrallite_7B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'mistrallite');
end;

procedure TChatFormattersTest.TestZephyr;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadZephyr_Chat();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'zephyr');
end;

procedure TChatFormattersTest.TestSaiga;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadSaiga_7B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'saiga');
end;

procedure TChatFormattersTest.TestGemma;
begin
  var LModelPaths := TSimpleDownload.Default.DownloadGemma_9B();
  Assert.IsNotNull(LModelPaths);

  TestChat(LModelPaths[0], 'gemma');
end;

initialization
  RegisterTest(TChatFormattersTest.Suite);

end.
