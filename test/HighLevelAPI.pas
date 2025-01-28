unit HighLevelAPI;

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
  LlamaCpp.Download,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.Chat.Types;

type
  THighLevelApiTest = class(TTestCase)
  private
    class var FModelPath: string;
    class var FLogDirectory: string;
    class procedure Log(
      const ALogName: string;
      const AChat: string;
      const AOption: string = 'overwrite';
      const ANewLine: boolean = true);
    class procedure ClearLogs();
  private
    procedure LlamaBuild(const ASettings: TLlamaSettings;
      const ALlama: TProc<ILlama>;
      const ATokenizer: ILlamaTokenizer = nil;
      const AChatHandler: ILlamaChatCompletionHandler = nil;
      const ADraftModel: ILlamaDraftModel = nil;
      const ACache: ILlamaCache = nil); overload;
    procedure LlamaBuild(
      const ALlamaSettings: TProc<TLlamaSettings>;
      const ALlama: TProc<ILlama>;
      const ATokenizer: ILlamaTokenizer = nil;
      const AChatHandler: ILlamaChatCompletionHandler = nil;
      const ADraftModel: ILlamaDraftModel = nil;
      const ACache: ILlamaCache = nil); overload;
    procedure LlamaBuild(
      const ALlama: TProc<ILlama>;
      const ATokenizer: ILlamaTokenizer = nil;
      const AChatHandler: ILlamaChatCompletionHandler = nil;
      const ADraftModel: ILlamaDraftModel = nil;
      const ACache: ILlamaCache = nil); overload;
  public
    class constructor Create();
    class destructor Destroy();
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestTokenizer;
    procedure TestDetokenizer;
    procedure TestGenerator;
    procedure TestEmbed();
    procedure TestCreateEmbedding();
    procedure TestCreateEmbeddingJson();
    procedure TestCreateCompletion();
    procedure TestCreateCompletionStream();
    procedure TestCreateCompletionWithLogprobs();
    procedure TestCreateCompletionStreamWithLogprobs();
    procedure TestCreateCompletionWithStopWords();
    procedure TestCreateCompletionStreamWithStopWords();
    procedure TestCreateCompletionLogitBias();
    procedure TestCreateCompletionStoppingCriteria();
    procedure TestCreateCompletionStreamStoppingCriteria();
    procedure TestSaveAndRestoreState();
    procedure TestCreateCompletionDiskCache();
    procedure TestCreateCompletionRamCache();
    procedure TestCreateCompletionGrammar();
    procedure TestCreateCompletionSpeculativeDecoding();
    procedure TestCreateCompletionGrammarAndSpeculativeDecoding();
    procedure TestCreateChatCompletion();
    procedure TestCreateChatCompletionStream();
  end;

implementation

uses
  System.IOUtils,
  System.Variants,
  System.Diagnostics,
  FireDAC.ConsoleUI.Wait,
  Utils;

{ THighLevelApiTest }

class constructor THighLevelApiTest.Create;
var
  LModel: TArray<string>;
begin
  LModel := TLlamaDownload.Default.DownloadLlama2_Chat_7B();

  if not Assigned(LModel) then
    raise Exception.Create('Unable to run tests due to unavailable model.');

  FModelPath := LModel[0];
  TLlamaCppApis.LoadAll(TTestUtils.GetLibPath());

  FLogDirectory := TPath.Combine(TTestUtils.GetLogsFolder(), 'HighLevelAPI');

  ClearLogs();

  if not TDirectory.Exists(FLogDirectory) then
    TDirectory.CreateDirectory(FLogDirectory);
end;

class destructor THighLevelApiTest.Destroy;
begin
  TLlamaCppApis.UnloadAll();
end;

procedure THighLevelApiTest.Setup;
begin

end;

procedure THighLevelApiTest.Teardown;
begin

end;

class procedure THighLevelApiTest.Log(const ALogName, AChat: string;
  const AOption: string; const ANewLine: boolean);
var
  LHeader: string;
begin
  var LLogFile := TPath.Combine(FLogDirectory, ALogName) + '.log';

  if AOption = 'overwrite' then
    if TFile.Exists(LLogFile) then
      TFile.Delete(LLogFile);

  if not TFile.Exists(LLogFile) then
  begin
    TFile.Create(LLogFile).Free();
    LHeader := '-> Execution date/time: ' + DateTimeToStr(Now()) + sLineBreak + sLineBreak;
  end
  else
    LHeader := String.Empty;

  if AOption = 'append' then
  begin
    if ANewLine then
      TFile.AppendAllText(LLogFile, sLineBreak);

    TFile.AppendAllText(LLogFile, LHeader + AChat)
  end else
    TFile.WriteAllText(LLogFile, LHeader + AChat);
end;

class procedure THighLevelApiTest.ClearLogs;
begin
  if TDirectory.Exists(FLogDirectory) then
    TDirectory.Delete(FLogDirectory, true);
end;

procedure THighLevelApiTest.LlamaBuild(const ASettings: TLlamaSettings;
  const ALlama: TProc<ILlama>; const ATokenizer: ILlamaTokenizer;
  const AChatHandler: ILlamaChatCompletionHandler;
  const ADraftModel: ILlamaDraftModel; const ACache: ILlamaCache);
begin
  ALlama(
    TLlamaBase.Create(
      FModelPath, ASettings, ATokenizer, AChatHandler, ADraftModel, ACache));
end;

procedure THighLevelApiTest.LlamaBuild(
  const ALlamaSettings: TProc<TLlamaSettings>; const ALlama: TProc<ILlama>;
  const ATokenizer: ILlamaTokenizer;
  const AChatHandler: ILlamaChatCompletionHandler;
  const ADraftModel: ILlamaDraftModel; const ACache: ILlamaCache);
begin
  var LSettings := TLlamaSettings.Create();
  try
    ALlamaSettings(LSettings);

    LlamaBuild(LSettings, ALlama, ATokenizer, AChatHandler, ADraftModel, ACache);
  finally
    LSettings.Free();
  end;
end;

procedure THighLevelApiTest.LlamaBuild(const ALlama: TProc<ILlama>;
  const ATokenizer: ILlamaTokenizer;
  const AChatHandler: ILlamaChatCompletionHandler;
  const ADraftModel: ILlamaDraftModel; const ACache: ILlamaCache);
begin
  var LSettings := TLlamaSettings.Create();
  try
    LSettings.Seed := Random(High(Integer));
    LlamaBuild(LSettings, ALlama, ATokenizer, AChatHandler, ADraftModel, ACache);
  finally
    LSettings.Free();
  end;
end;

procedure THighLevelApiTest.TestTokenizer;
const
  PROMPT = 'Héllõ, Wôrld!';
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LTokens := (ALlama as ILlamaTokenization).Encode(PROMPT);
      Assert.IsNotNull(LTokens);

      Log('tokenizer', 'Prompt: ' + PROMPT, 'append');
      Log('tokenizer', 'Tokens: ' + TArray.ToString<integer>(LTokens), 'append');
    end);
end;

procedure THighLevelApiTest.TestDetokenizer;
const
  PROMPT = 'Héllõ, Wôrld!';
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LTokens := (ALlama as ILlamaTokenization).Encode(PROMPT);
      var LStr := (ALlama as ILlamaTokenization).Decode(LTokens);

      Assert.AreEqual('Héllõ, Wôrld!', LStr);

      Log('detokenizer', 'Prompt: ' + PROMPT, 'append');
      Log('detokenizer', 'Tokens: ' + TArray.ToString<integer>(LTokens), 'append');
      Log('detokenizer', 'Decoded: ' + LStr, 'append');
    end);
end;

procedure THighLevelApiTest.TestGenerator;
const
  PROMPT = 'Héllõ, Wôrld!';
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCount := 0;
      var LTokens := TArray<integer>.Create();

      (ALlama as ILlamaGenerator).Generate(
        (ALlama as ILlamaTokenization).Encode(PROMPT),
        TLlamaSamplerSettings.Create(),
        function(const AToken: integer; var AContinue: boolean): TArray<integer>
        begin
          Assert.AreNotEqual(AToken, 0);
          LTokens := LTokens + [AToken];
          Inc(LCount);
          AContinue := LCount < 100;
          Result := nil;
        end);

      Assert.AreEqual(100, LCount);
      var LStr := (ALlama as ILlamaTokenization).Decode(LTokens);

      Log('generator', 'Prompt: ' + PROMPT, 'append');
      Log('generator', 'Tokens: ' + TArray.ToString<integer>(LTokens), 'append');
      Log('generator', 'Decoded: ' + LStr, 'append');
    end);
end;

procedure THighLevelApiTest.TestEmbed;
const
  PROMPT = 'Héllõ, Wôrld!';
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.Embeddings := true;
    end,
    procedure(ALlama: ILlama)
    var
      LReturnCount: integer;
    begin
      var LMatrix := (ALlama as ILlamaEmbedding).Embed([PROMPT], LReturnCount);

      Assert.IsNotNull(LMatrix);
      Assert.AreEqual<integer>(Length(LMatrix), LReturnCount);
      Assert.AreEqual<integer>(
        Length(LMatrix),
        Length((ALlama as ILlamaTokenization).Encode('Héllõ, Wôrld!')));

      Log('embeddings', 'Prompt: ' + PROMPT, 'append');
      for var LDim in LMatrix do
        Log('embeddings', 'Matrix: ' + TArray.ToString<single>(LDim), 'append');
   end);
end;

procedure THighLevelApiTest.TestCreateEmbedding;
const
  PROMPT = 'Héllõ, Wôrld!';
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.Embeddings := true;
    end,
    procedure(ALlama: ILlama)
    var
      I: integer;
    begin
      var LEmbedding := (ALlama as ILlamaEmbedding).CreateEmbedding([PROMPT]);

      Assert.AreEqual(LEmbedding.&Object, 'list');
      Assert.AreEqual(LEmbedding.Model, FModelPath);
      Assert.IsTrue(Length(LEmbedding.Data) > 0);
      Assert.IsTrue(LEmbedding.Usage.TotalTokens > 0);

      for I := Low(LEmbedding.Data) to High(LEmbedding.Data) do
      begin
        var LEmbd := LEmbedding.Data[I];
        Assert.AreEqual(LEmbd.&Object, 'embedding');
        Assert.IsTrue(Length(LEmbd.Embedding) > 0);
      end;

      Log('embeddings_json', 'Prompt: ' + PROMPT, 'append');
      Log('embeddings_json', 'Matrix: ' + LEmbedding.ToJsonString(), 'append');
    end);
end;

procedure THighLevelApiTest.TestCreateEmbeddingJson;
const
  PROMPT = 'Héllõ, Wôrld!';
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.Embeddings := true;
    end,
    procedure(ALlama: ILlama)
    begin
      var LEmbeddings := (ALlama as ILlamaEmbedding).CreateEmbedding([PROMPT]);
      var LJson := LEmbeddings.ToJsonString();
      var LDeserialized := LEmbeddings.FromJsonString(LJson);

      Assert.AreEqual(LEmbeddings.&Object, LDeserialized.&Object);
      Assert.AreEqual(LEmbeddings.Model, LDeserialized.Model);
      Assert.AreEqual<integer>(Length(LEmbeddings.Data), Length(LDeserialized.Data));
      Assert.AreEqual<integer>(LEmbeddings.Usage.TotalTokens, LDeserialized.Usage.TotalTokens);
    end);
end;

procedure THighLevelApiTest.TestCreateCompletion;
const
  PROMPT = '''
  // Delphi loop
  for i := 0 to
  ''';
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 5;

      var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
        PROMPT,
        LCompletionSettings);

      Assert.IsTrue(Assigned(LCompletion.Choices));
      Assert.IsFalse(LCompletion.Choices[0].Text.IsEmpty());
      Assert.IsFalse(LCompletion.Choices[0].FinishReason.IsEmpty());

      Log('create_completion', 'Prompt: ' + PROMPT, 'append');
      Log('create_completion', 'Response: ' + LCompletion.Choices[0].Text, 'append');

      Log('create_completion_json', 'Prompt: ' + PROMPT, 'append');
      Log('create_completion_json', 'Response: ' + LCompletion.ToJsonString(), 'append');
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionStream;
const
  PROMPT = '''
  // Delphi loop
  for i := 0 to
  ''';
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 20;

      Log('create_completion_stream', 'Prompt: ' + PROMPT, 'append');
      Log('create_completion_stream', 'Response: ', 'append');

      Log('create_completion_stream_json', 'Prompt: ' + PROMPT, 'append');
      Log('create_completion_stream_json', 'Response: ', 'append');

      var LResponse := String.Empty;
      var LFinishReason := String.Empty;
      (ALlama as ILlamaCompletion).CreateCompletion(
        PROMPT,
        LCompletionSettings,
        procedure(const AResponse: TCreateCompletionResponse; var AContinue: boolean)
        begin
          Assert.IsTrue(Assigned(AResponse.Choices));

          LResponse := AResponse.Choices[0].Text.Replace(LResponse, '');
          LFinishReason := AResponse.Choices[0].FinishReason;

          Log('create_completion_stream', LResponse, 'append', false);
          Log('create_completion_stream_json', AResponse.ToJsonString(), 'append');
        end
      );

      Assert.IsFalse(LFinishReason.IsEmpty());
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionWithLogprobs;
const
  PROMPT = '''
  // Delphi loop 5 elements
  for i := 0 to
  ''';
begin
  var LCreateCompletion := procedure(const ALlama: ILlama) begin
    var LCompletionSettings := TLlamaCompletionSettings.Create();
    LCompletionSettings.MaxTokens := 5;
    LCompletionSettings.LogProbs := 2;

    var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      PROMPT,
      LCompletionSettings);

    Assert.IsTrue(Assigned(LCompletion.Choices));
    Assert.IsTrue(Assigned(LCompletion.Choices[0].Logprobs.TopLogprobs));
    Assert.IsFalse(LCompletion.Choices[0].Text.IsEmpty());

    Log('create_completion_logprobs_json', 'Prompt: ' + PROMPT, 'overwrite');
    Log('create_completion_logprobs_json', 'Response: ' + LCompletion.ToJsonString(), 'append');
  end;

  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
    end,
    procedure(ALlama: ILlama) begin
      Assert.WillRaise(
        procedure() begin
          LCreateCompletion(ALlama);
        end)
    end);

  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := true;
    end,
    procedure(ALlama: ILlama) begin
      LCreateCompletion(ALlama)
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionStreamWithLogprobs;
const
  PROMPT = '''
  // Delphi loop 5 elements
  for i := 0 to
  ''';
begin
  var LCreateCompletion := procedure(const ALlama: ILlama) begin
    var LCompletionSettings := TLlamaCompletionSettings.Create();
    LCompletionSettings.MaxTokens := 5;
    LCompletionSettings.LogProbs := 2;

    Log('create_completion_stream_logprobs_json', 'Prompt: ' + PROMPT, 'overwrite');
    Log('create_completion_stream_logprobs_json', 'Response: ', 'append');

    (ALlama as ILlamaCompletion).CreateCompletion(
      PROMPT,
      LCompletionSettings,
      procedure(const AResponse: TCreateCompletionResponse; var AContinue: boolean)
      begin
        Assert.IsTrue(Assigned(AResponse.Choices));
        if AResponse.Choices[0].FinishReason.IsEmpty() then
        begin
          Assert.IsTrue(Assigned(AResponse.Choices[0].Logprobs.TopLogprobs));
          Assert.IsFalse(AResponse.Choices[0].Text.IsEmpty());

          Log('create_completion_stream_logprobs_json', AResponse.ToJsonString(), 'append');
        end;
      end
    );
  end;

  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
    end,
    procedure(ALlama: ILlama) begin
      Assert.WillRaise(procedure() begin
        LCreateCompletion(ALlama);
      end)
    end);

  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := true;
    end,
    procedure(ALlama: ILlama) begin
      LCreateCompletion(ALlama);
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionWithStopWords;
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 10;
      LCompletionSettings.Stop := [';'];

      var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi integer variable assignment
      value :=
      ''',
      LCompletionSettings);

      Assert.IsTrue(Assigned(LCompletion.Choices));
      Assert.IsFalse(LCompletion.Choices[0].Text.IsEmpty());
      Assert.IsTrue(LCompletion.Choices[0].Text.EndsWith(';'));
      Assert.AreEqual<string>(LCompletion.Choices[0].FinishReason, 'stop');
      Assert.IsTrue(LCompletion.Choices[0].Text.EndsWith(LCompletionSettings.Stop[0]));
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionStreamWithStopWords;
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 10;
      LCompletionSettings.Stop := [';'];

      var LResponse := String.Empty;
      var LFinishReason := String.Empty;
      (ALlama as ILlamaCompletion).CreateCompletion(
        '''
        // Delphi integer variable assignment
        value :=
        ''',
        LCompletionSettings,
        procedure(const AResponse: TCreateCompletionResponse; var AContinue: boolean)
        begin
          Assert.IsTrue(Assigned(AResponse.Choices));

          LResponse := LResponse + AResponse.Choices[0].Text;
          LFinishReason := AResponse.Choices[0].FinishReason;
        end
      );

      Assert.IsFalse(LResponse.IsEmpty());
      Assert.IsTrue(LResponse.EndsWith(';'));
      Assert.AreEqual<string>(LFinishReason, 'stop');
      Assert.IsTrue(LResponse.EndsWith(LCompletionSettings.Stop[0]));
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionLogitBias;
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 5;
      // Ignore EOS
      LCompletionSettings.LogitBias := [
        TPair<integer, single>.Create(ALlama.Model.TokenEOS, -Infinite)];

      var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi loop - range from 1 to 9
      for i
      ''',
      LCompletionSettings);

      Assert.IsTrue(Assigned(LCompletion.Choices));
      Assert.IsFalse(LCompletion.Choices[0].Text.IsEmpty());
      Assert.IsFalse(LCompletion.Choices[0].FinishReason.IsEmpty());
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionStoppingCriteria;
const
  PROMPT = '''
  // Delphi loop - range from 1 to 9
  for i
  ''';
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      var LStoppingCriteriaList := TDefaultStoppingCriteriaList.Create();
      var LStoppingCriteria: TStoppingCriteria := function(
        const ATokens: TArray<Integer>; const ALogits: TArray<single>): boolean
      begin
        Result := (ALlama as ILlamaTokenization).Decode(ATokens).EndsWith('do');
      end;

      LCompletionSettings.MaxTokens := 20;
      LStoppingCriteriaList.Add(LStoppingCriteria);

      var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
        PROMPT,
        LCompletionSettings,
        LStoppingCriteriaList
      );

      Assert.IsTrue(Assigned(LCompletion.Choices));
      Assert.IsFalse(LCompletion.Choices[0].Text.IsEmpty());
      Assert.IsTrue(LCompletion.Choices[0].Text.EndsWith('do'));
      Assert.AreEqual<string>(LCompletion.Choices[0].FinishReason, 'stop');

      Log('create_completion_stopping_criteria', 'Prompt:' + PROMPT);
      Log('create_completion_stopping_criteria', LCompletion.ToJsonString(), 'append');
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionStreamStoppingCriteria;
begin
  LLamaBuild(
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      var LStoppingCriteriaList := TDefaultStoppingCriteriaList.Create();

      var LStoppingCriteria: TStoppingCriteria := function(
        const ATokens: TArray<Integer>; const ALogits: TArray<single>): boolean
      begin
        Result := (ALlama as ILlamaTokenization).Decode(ATokens).EndsWith('do');
      end;

      LCompletionSettings.MaxTokens := 20;
      LStoppingCriteriaList.Add(LStoppingCriteria);

      var LResponse := String.Empty;
      var LFinishReason := String.Empty;

      (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi loop - range from 1 to 9
      for i
      ''',
      LCompletionSettings,
      procedure(const AResponse: TCreateCompletionResponse; var AContinue: boolean)
        begin
          Assert.IsTrue(Assigned(AResponse.Choices));

          LResponse := LResponse + AResponse.Choices[0].Text;
          LFinishReason := AResponse.Choices[0].FinishReason;
      end,
      LStoppingCriteriaList);

      Assert.IsFalse(LResponse.IsEmpty());
      Assert.IsTrue(LResponse.EndsWith('do'));
      Assert.AreEqual<string>(LFinishReason, 'stop');
    end);
end;

procedure THighLevelApiTest.TestSaveAndRestoreState;
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
      ASettings.NCtx := 32;
      ASettings.NBatch := 32;
      ASettings.NUBatch := 32;
      ASettings.Seed := 1337;
    end,
    procedure(ALlama: ILlama) begin
      var LState := ALlama.SaveState();
      try
        var LCompletionSettings := TLlamaCompletionSettings.Create();
        LCompletionSettings.MaxTokens := 4;
        LCompletionSettings.TopK := 50;
        LCompletionSettings.TopP := 0.9;
        LCompletionSettings.Temperature := 0.8;

        var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
        '''
        // Delphi loop
        while
        ''',
        LCompletionSettings);

        var LVal1 := LCompletion.Choices[0].Text;

        LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
        '''
        // Delphi loop
        while
        ''',
        LCompletionSettings);

        var LVal2 := LCompletion.Choices[0].Text;

        ALlama.LoadState(LState);

        LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
        '''
        // Delphi loop
        while
        ''',
        LCompletionSettings);

        var LVal3 := LCompletion.Choices[0].Text;

        Assert.AreNotEqual<string>(LVal1, LVal2);
        Assert.AreEqual<string>(LVal1, LVal3);
      finally
        LState.Free();
      end;
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionDiskCache;
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
      ASettings.NCtx := 32;
      ASettings.NBatch := 32;
      ASettings.NUBatch := 32;
      ASettings.Seed := 1337;
    end,
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 4;
      LCompletionSettings.TopK := 50;
      LCompletionSettings.TopP := 0.9;
      LCompletionSettings.Temperature := 0.8;

      var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi loop
      while
      ''',
      LCompletionSettings);

      var LVal1 := LCompletion.Choices[0].Text;

      LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi loop
      while
      ''',
      LCompletionSettings);

      var LVal2 := LCompletion.Choices[0].Text;

      Assert.AreNotEqual<string>(LVal1, LVal2);
    end, nil, nil, nil, TLlamaDiskCache.Create());
end;

procedure THighLevelApiTest.TestCreateCompletionRamCache;
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
      ASettings.NCtx := 32;
      ASettings.NBatch := 32;
      ASettings.NUBatch := 32;
      ASettings.Seed := 1337;
    end,
    procedure(ALlama: ILlama) begin
      var LCompletionSettings := TLlamaCompletionSettings.Create();
      LCompletionSettings.MaxTokens := 4;
      LCompletionSettings.TopK := 50;
      LCompletionSettings.TopP := 0.9;
      LCompletionSettings.Temperature := 0.8;

      var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi loop
      while
      ''',
      LCompletionSettings);

      var LVal1 := LCompletion.Choices[0].Text;

      LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
      '''
      // Delphi loop
      while
      ''',
      LCompletionSettings);

      var LVal2 := LCompletion.Choices[0].Text;

      Assert.AreNotEqual<string>(LVal1, LVal2);
    end, nil, nil, nil, TLlamaRamCache.Create());
end;

procedure THighLevelApiTest.TestCreateCompletionGrammar;
const
  PROMPT = 'Pick a number from 1 to 10?';
  GRAMMAR = 'root ::= "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "10"';
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
      ASettings.NCtx := 32;
      ASettings.NBatch := 32;
      ASettings.NUBatch := 32;
    end,
    procedure(ALlama: ILlama)
    var
      LInt: integer;
    begin

      Assert.WillNotRaise(procedure() begin
        var LCompletionSettings := TLlamaCompletionSettings.Create();
        LCompletionSettings.MaxTokens := 4;
        LCompletionSettings.TopK := 50;
        LCompletionSettings.TopP := 0.9;
        LCompletionSettings.Temperature := 0.8;
        var LGrammar := TLlamaGrammar.FromString(GRAMMAR);

        var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
          PROMPT,
          LCompletionSettings, nil, nil, LGrammar);

        Assert.IsNotEmpty(LCompletion.Choices[0].Text);
        Assert.IsTrue(Integer.TryParse(LCompletion.Choices[0].Text, LInt));
        Assert.IsTrue((LInt >= 1) and (LInt <= 10));
        Assert.AreEqual<string>(LCompletion.Choices[0].FinishReason, 'stop'); // EOG

        Log('create_completion_grammar_json',
          LCompletion.ToJsonString());
        Log('create_completion_grammar',
          'Grammar: ' + GRAMMAR,
          'append');
        Log('create_completion_grammar',
          'Prompt: ' + PROMPT,
          'append');
        Log('create_completion_grammar',
          'Response: ' + LCompletion.Choices[0].Text,
          'append');
      end);
    end);
end;

procedure THighLevelApiTest.TestCreateCompletionSpeculativeDecoding;
const
  PROMPT = '''
  // Delphi loop
  while i <
  ''';
begin
  var LCompletionSettings := TLlamaCompletionSettings.Create();
  LCompletionSettings.MaxTokens := 4;
  LCompletionSettings.TopK := 50;
  LCompletionSettings.TopP := 0.9;
  LCompletionSettings.Temperature := 0.8;

  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
      ASettings.NCtx := 32;
      ASettings.NBatch := 32;
      ASettings.NUBatch := 32;
    end,
    procedure(ALlama: ILlama) begin

      Assert.WillNotRaise(procedure() begin
        var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
          PROMPT,
          LCompletionSettings);

        Assert.IsNotEmpty(LCompletion.Choices[0].Text);

        Log('create_completion_speculative_decoding',
          'Prompt: ' + PROMPT,
          'overwrite');
        Log('create_completion_speculative_decoding',
          LCompletion.ToJsonString(),
          'append');
      end);
    end, nil, nil, TLlamaPromptLookupDecoding.Create());;
end;

procedure THighLevelApiTest.TestCreateCompletionGrammarAndSpeculativeDecoding;
const
  PROMPT = 'Pick a number of three digits?';
  GRAMMAR = 'root ::= "123" | "234" | "345" | "456" | "567" | "678" | "789"';
begin
  LLamaBuild(
    procedure(ASettings: TLlamaSettings)
    begin
      ASettings.LogitsAll := false;
      ASettings.NCtx := 32;
      ASettings.NBatch := 32;
      ASettings.NUBatch := 32;
    end,
    procedure(ALlama: ILlama)
    var
      LInt: integer;
    begin

      Assert.WillNotRaise(procedure() begin
        var LCompletionSettings := TLlamaCompletionSettings.Create();
        LCompletionSettings.MaxTokens := 4;
        LCompletionSettings.TopK := 50;
        LCompletionSettings.TopP := 0.9;
        LCompletionSettings.Temperature := 0.8;

        var LCompletion := (ALlama as ILlamaCompletion).CreateCompletion(
          PROMPT,
          LCompletionSettings, nil, nil, TLlamaGrammar.FromString(GRAMMAR));

        Assert.IsNotEmpty(LCompletion.Choices[0].Text);
        Assert.IsTrue(Integer.TryParse(LCompletion.Choices[0].Text, LInt));
        Assert.IsTrue((LInt >= 100) and (LInt <= 999));
        Assert.AreEqual<string>(LCompletion.Choices[0].FinishReason, 'stop'); // EOG

        Log('create_completion_grammar_speculative_decoding',
          'Prompt: ' + PROMPT,
          'overwrite');
        Log('create_completion_grammar_speculative_decoding',
          'Grammar: ' + GRAMMAR,
          'append');
        Log('create_completion_grammar_speculative_decoding',
          LCompletion.ToJsonString(),
          'append');
      end);
    end, nil, nil, TLlamaPromptLookupDecoding.Create());
end;

procedure THighLevelApiTest.TestCreateChatCompletion;
begin
  LLamaBuild(
    procedure(ALlama: ILlama)
    begin
      Assert.WillNotRaise(procedure() begin

        var LText := String.Empty;

        var LMessages: TArray<TChatCompletionRequestMessage> := [
          TChatCompletionRequestMessage.System('You are a master in Geography.'),
          TChatCompletionRequestMessage.User('What is the capital of France?')
        ];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        var LCompletion := (ALlama as ILlamaChatCompletion).CreateChatCompletion(
          TLlamaChatCompletionSettings.Create(LMessages));

        LMessages := LMessages + [
          TChatCompletionRequestMessage.Assistant(
            LCompletion.Choices[0].Message.Content
          )];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        LMessages := LMessages + [
          TChatCompletionRequestMessage.User('Tell me more about the place...')];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        LCompletion := (ALlama as ILlamaChatCompletion).CreateChatCompletion(
          TLlamaChatCompletionSettings.Create(LMessages));

        LMessages := LMessages + [
          TChatCompletionRequestMessage.Assistant(
            LCompletion.Choices[0].Message.Content
          )];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        Log('create_chat_completion', LText);
      end);
    end);
end;

procedure THighLevelApiTest.TestCreateChatCompletionStream;
begin
  LLamaBuild(
    procedure(ALlama: ILlama)
    begin
      Assert.WillNotRaise(procedure() begin

        var LText := String.Empty;

        var LMessages: TArray<TChatCompletionRequestMessage> := [
          TChatCompletionRequestMessage.System('You are a master in Geography.'),
          TChatCompletionRequestMessage.User('What is the capital of France?')
        ];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        Log('create_chat_completion_stream',
          LText,
          'append');

        Log('create_chat_completion_stream',
          'assistant:' + sLineBreak,
          'append');

        var LAssistant := String.Empty;
        (ALlama as ILlamaChatCompletion).CreateChatCompletion(
          TLlamaChatCompletionSettings.Create(LMessages),
          procedure(
            const AResponse: TChatCompletionStreamResponse;
            var AContinue: boolean)
          begin
            if Assigned(AResponse.Choices) then
            begin
              LAssistant := LAssistant + VarTostr(
                AResponse.Choices[0].Delta.Content);

              Log('create_chat_completion_stream',
                VarTostr(AResponse.Choices[0].Delta.Content),
                'append',
                false);

              Sleep(50);
            end;
          end);

        LMessages := LMessages + [
          TChatCompletionRequestMessage.Assistant(
            LAssistant
          )];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        LMessages := LMessages + [
          TChatCompletionRequestMessage.User('Tell me more about the place...')];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);

        Log('create_chat_completion_stream',
          sLineBreak
          + 'user:'
          + sLineBreak
          + 'Tell me more about the place...'
          + sLineBreak,
          'append');

        Log('create_chat_completion_stream',
          'assistant:' + sLineBreak,
          'append');

        LAssistant := String.Empty;
        (ALlama as ILlamaChatCompletion).CreateChatCompletion(
          TLlamaChatCompletionSettings.Create(LMessages),
          procedure(
            const AResponse: TChatCompletionStreamResponse;
            var AContinue: boolean)
          begin
            if Assigned(AResponse.Choices) then
            begin
              LAssistant := LAssistant + VarTostr(
                AResponse.Choices[0].Delta.Content);

              Log('create_chat_completion_stream',
                VarTostr(AResponse.Choices[0].Delta.Content),
                'append',
                false);

              Sleep(50);
            end;
          end);

        LMessages := LMessages + [
          TChatCompletionRequestMessage.Assistant(
            LAssistant
          )];

        LText := TChatCompletionRequestMessage.ToString(LMessages);
        Assert.IsNotEmpty(LText);
      end);
    end);
end;

initialization
  RegisterTest(THighLevelApiTest.Suite);

end.
