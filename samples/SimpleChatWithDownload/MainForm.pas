unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, LlamaCpp.Llama, FMX.MultiView,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, DownloadForm;

type
  TFormMain = class(TForm)
    cbModel: TComboBox;
    ChatBox: TVertScrollBox;
    StyleBook1: TStyleBook;
    Llama1: TLlama;
    recUser: TRectangle;
    btnSend: TButton;
    memUser: TMemo;
    btnCancel: TButton;
    container: TLayout;
    MultiView1: TMultiView;
    tbMenuHeader: TToolBar;
    lbMenuHeader: TLabel;
    layModel: TLayout;
    lbModel: TLabel;
    tbHeader: TToolBar;
    btnSettings: TButton;
    layContextLength: TLayout;
    lblContextLength: TLabel;
    nbContextLength: TNumberBox;
    laySeed: TLayout;
    cbSeed: TCheckBox;
    layCPUGPU: TLayout;
    switchCPUGPU: TSwitch;
    lbCPU: TLabel;
    lbGPU: TLabel;
    lblHuggingFaceAuth: TLabel;
    layHFUserName: TLayout;
    lblHFUserName: TLabel;
    layHFToken: TLayout;
    lblHFToken: TLabel;
    edtHFToken: TEdit;
    edtHFUserName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Llama1ChatCompletionStreamComplete(Sender: TObject);
    procedure Llama1ChatCompletionStream(Sender: TObject;
      const AResponse: TChatCompletionStreamResponse; var AContinue: Boolean);
    procedure btnSendClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure memUserKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure MultiView1StartHiding(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormSaveState(Sender: TObject);
  private
    FStatus: byte; // 0 - idle/cancelling 1 - generating
    FChatMessages: TArray<TChatCompletionRequestMessage>;
    FStreamer: TProc<string>;
    FTask: IAsyncResult;
    FDownloadForm: TFormDownload;
    procedure AddUserQuestion(const AQuestion: string);
    function AddAssistantAnswer(const AAnswer: string): TProc<string>;

    procedure UpdateLayout();
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.IOUtils,
  System.Math,
  LlamaCpp.Api;

{$R *.fmx}

{ TFormMain }

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FTask) then
    if not (FTask.IsCompleted or FTask.IsCancelled) then
    begin
      Canclose := false;
      ShowMessage('Please wait until the current operation is finished or has been canceled.');
    end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  recUser.Enabled := false;
  btnCancel.Visible := false;

  FChatMessages := [
    TChatCompletionRequestMessage.System(
      'You''re a master in the Delphi programming language,')];

  FDownloadForm := TFormDownload.Create(Self);

  if SaveState.Stream.Size > 0 then begin
    var LReader := TBinaryReader.Create(SaveState.Stream);
    try
      edtHFUserName.Text := LReader.ReadString();
      edtHFToken.Text := LReader.ReadString();
    finally
      LReader.Free();
    end;
  end;
end;

procedure TFormMain.FormSaveState(Sender: TObject);
begin
  SaveState.Stream.Clear();

  var LWriter := TBinaryWriter.Create(SaveState.Stream);
  try
    LWriter.Write(edtHFUserName.Text);
    LWriter.Write(edtHFToken.Text);
  finally
    LWriter.Free();
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  MultiView1.ShowMaster();
end;

procedure TFormMain.btnCancelClick(Sender: TObject);
begin
  btnCancel.Enabled := false;
  FTask.Cancel();
end;

procedure TFormMain.btnSendClick(Sender: TObject);
begin
  if memUser.Text.IsEmpty() then
    Exit;

  FStatus := 1;
  UpdateLayout();

  AddUserQuestion(memUser.Text);

  var LChatSettings := TLlamaChatCompletionSettings.Create(FChatMessages);

  if cbSeed.IsChecked then
    LChatSettings.Seed := Random(High(Integer));

  FTask := Llama1.CreateChatCompletionStream(LChatSettings);

  FStreamer := AddAssistantAnswer(String.Empty);

  memUser.Lines.Clear();
end;

procedure TFormMain.Llama1ChatCompletionStream(Sender: TObject;
  const AResponse: TChatCompletionStreamResponse; var AContinue: Boolean);
begin
  if Assigned(FStreamer) and Assigned(AResponse.Choices) then
    FStreamer(VarToStr(AResponse.Choices[0].Delta.Content));
end;

procedure TFormMain.Llama1ChatCompletionStreamComplete(Sender: TObject);
begin
  FStatus := 0;
  FStreamer := nil;
  //FTask := nil;
  UpdateLayout();
end;

procedure TFormMain.memUserKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkReturn) and not (TShiftStateItem.ssShift in Shift) then
    if (FStatus = 0) then
      btnSend.OnClick(btnSend);
end;

procedure TFormMain.MultiView1StartHiding(Sender: TObject);
begin
  if not cbModel.Enabled then
    Exit;

  // HF Auth
  FDownloadForm.HFAuth(edtHFUserName.Text, edtHFToken.Text);

  Llama1.Settings.NCtx := Trunc(nbContextLength.Value);
  if switchCPUGPU.IsChecked then
    Llama1.Settings.NGpuLayers := -1
  else
    Llama1.Settings.NGpuLayers := 0;

  case cbModel.ItemIndex of
    0: begin
      FDownloadForm.DownloadAndPrepareLlama2(Llama1);
      Caption := Caption + ' (Llama-2)';
    end;
    1: begin
      FDownloadForm.DownloadAndPrepareLlama3(Llama1);
      Caption := Caption + ' (Llama-3)';
    end;
    2: begin
      FDownloadForm.DownloadAndPrepareMistralLite(Llama1);
      Caption := Caption + ' (MistralLite)';
    end;
    3: begin
      FDownloadForm.DownloadAndPrepareTinyLlama(Llama1);
      Caption := Caption + ' (TinyLlama)';
    end
    else raise Exception.Create('Select a model.');
  end;

  recUser.Enabled := true;
  cbModel.Enabled := false;
  nbContextLength.Enabled := false;
  cbSeed.Enabled := false;
  switchCPUGPU.Enabled := false;
  //MultiView1.Enabled := false;
end;

procedure TFormMain.UpdateLayout;
begin
  if (FStatus = 0) then begin
    btnCancel.Visible := false;
    btnSend.Visible := true;
  end else begin
    btnCancel.Visible := true;
    btnSend.Visible := false;
  end;

  btnCancel.Enabled := true;
end;

procedure TFormMain.AddUserQuestion(const AQuestion: string);
begin
  var LMaxWidth := (
    ChatBox.Width -
    ChatBox.Padding.Left -
    ChatBox.Padding.Right) / 2;

  var LText := TLabel.Create(ChatBox);
  LText.Parent := ChatBox;
  LText.Align := TAlignLayout.Top;
  LText.AutoSize := true;
  LText.Margins.Top := 20;
  LText.Margins.Left := LMaxWidth;
  LText.WordWrap := true;
  LText.TextSettings.HorzAlign := TTextAlign.Center;
  LText.Position.Y := ChatBox.ContentBounds.Height;
  LText.StyleLookup := 'roundedlabel';
  LText.Text := AQuestion;

  var LTextWidth := LText.Canvas.TextWidth(AQuestion);
  if LTextWidth < LMaxWidth then
    LText.Margins.Left := LMaxWidth + (LMaxWidth - LTextWidth) - 40;

  FChatMessages := FChatMessages + [
    TChatCompletionRequestMessage.User(AQuestion)];
end;

function TFormMain.AddAssistantAnswer(const AAnswer: string): TProc<string>;
begin
  var LText := TLabel.Create(ChatBox);
  LText.Parent := ChatBox;
  LText.Align := TAlignLayout.Top;
  LText.AutoSize := true;
  LText.Margins.Top := 20;
  LText.Margins.Right := 20;
  LText.Text := AAnswer;
  LText.Position.Y := ChatBox.ContentBounds.Height;
  LText.Visible := false;

  FChatMessages := FChatMessages + [
    TChatCompletionRequestMessage.Assistant(AAnswer)];

  Result := procedure(AStream: string)
  begin
    var LStr := LText.Text + AStream;

    TThread.Queue(nil, procedure() begin
      if not LText.Visible then
        LText.Visible := true;

      LText.Text := LStr;

      var LNewHeight := Max(LText.Position.Y + LText.Height, ChatBox.ContentBounds.Height);
      ChatBox.ViewportPosition := PointF(
        ChatBox.ViewportPosition.X,
        LNewHeight - ChatBox.Height);

      ChatBox.RealignContent();
    end);

    FChatMessages[High(FChatMessages)].Content := LStr;
  end;
end;

initialization
  {$IFDEF MACOS}
  TLlamaCppApis.LoadAll(
    TPath.GetDirectoryName(
      ParamStr(0)));
  {$ELSE}
  TLlamaCppApis.LoadAll(
    TPath.Combine(
      TDirectory.GetParent(
        TDirectory.GetParent(
          TPath.GetDirectoryName(
            ParamStr(0)))),
      'lib',
      'windows_x64'
    ));
  {$ENDIF MACOS}

finalization
  TLlamaCppApis.UnloadAll();

end.
