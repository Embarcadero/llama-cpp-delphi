program SimpleChatWithDownload;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {FormMain},
  DownloadForm in 'DownloadForm.pas' {FormDownload};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.

