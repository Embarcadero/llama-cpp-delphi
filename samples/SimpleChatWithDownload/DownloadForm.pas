unit DownloadForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, LlamaCpp.Llama, LlamaCpp.Download;

type
  TFormDownload = class(TForm)
    memoDownload: TMemo;
    LlamaDownload1: TLlamaDownload;
    procedure LlamaDownload1WriteData(Sender: TObject; const AText: string);

    procedure Download(const ALlama: TLlama; const ATask: TFunc<string>);
  public
    procedure DownloadAndPrepareLlama2(const ALlama: TLlama);
    procedure DownloadAndPrepareLlama3(const ALlama: TLlama);
    procedure DownloadAndPrepareMistralLite(const ALlama: TLlama);
  end;

var
  FormDownload: TFormDownload;

implementation

uses
  System.Threading;

{$R *.fmx}

{ TFormDownload }

procedure TFormDownload.Download(const ALlama: TLlama;
  const ATask: TFunc<string>);
begin
  memoDownload.Lines.Add(
    'Checking your local copy. It may take a while...'
    + sLineBreak + sLineBreak);

  TTask.Run(procedure() begin
    ALlama.ModelPath := ATask;

    TThread.Queue(nil, procedure() begin
      memoDownload.Lines.Add('Loading...');
    end);

    ALlama.Init();

    TThread.Queue(nil, procedure() begin
      memoDownload.Lines.Add(String.Empty);
      memoDownload.Lines.Add('All done!');
    end);

    TThread.ForceQueue(nil, procedure() begin
      Self.Close();
    end, 500);
  end);

  Self.ShowModal();
end;

procedure TFormDownload.DownloadAndPrepareLlama2(const ALlama: TLlama);
begin
  ALlama.Settings.ChatFormat := 'llama-2';

  Download(ALlama, function(): string begin
    Result := LlamaDownload1.DownloadLlama2_Chat_7B()[0];
  end);
end;

procedure TFormDownload.DownloadAndPrepareLlama3(const ALlama: TLlama);
begin
  ALlama.Settings.ChatFormat := 'llama-3';

  Download(ALlama, function(): string begin
    Result := LlamaDownload1.DownloadLlama3_Chat_30B()[0];
  end);
end;

procedure TFormDownload.DownloadAndPrepareMistralLite(
  const ALlama: TLlama);
begin
  ALlama.Settings.ChatFormat := 'mistrallite';

  Download(ALlama, function(): string begin
    Result := LlamaDownload1.DownloadMistrallite_7B()[0];
  end);
end;

procedure TFormDownload.LlamaDownload1WriteData(Sender: TObject;
  const AText: string);
begin
  TThread.Queue(nil, procedure() begin
    MemoDownload.Lines.Text := MemoDownload.Lines.Text + AText;
  end);
end;

end.
