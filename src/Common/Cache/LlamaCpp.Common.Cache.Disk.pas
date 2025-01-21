unit LlamaCpp.Common.Cache.Disk;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  System.Generics.Collections,
  System.IOUtils,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  LlamaCpp.Common.Types,
  LlamaCpp.Common.State,
  LlamaCpp.Common.Cache.Base;

type
  TLlamaDiskCache = class(TBaseLlamaCache)
  private const
  {$IFDEF MSWINDOWS}
    DEFAULT_CACHE_DIR = '.\cache\llama_cache';
  {$ELSE}
    DEFAULT_CACHE_DIR = './cache/llama_cache';
  {$ENDIF}
  private
    FCacheFileName: string;
    FConnection: TFDConnection;
    FDatS: TFDQuery;
    FTask: ITask;
  private
    procedure CreateCacheConnectionDefs();
    procedure CreateCacheTable();
    function Load(const AKey: TArray<integer>): TLlamaState;
    procedure Save(const AKey: TArray<integer>; const AState: TLlamaState);
    procedure Delete(const AKey: TArray<integer>);
  public
    constructor Create(const ACacheDir: string = DEFAULT_CACHE_DIR;
      ACapacityBytes: Int64 = Int64(2) shl 30);
    destructor Destroy; override;

    function GetCacheSize: Int64; override;
    function FindLongestPrefixKey(const AKey: TArray<Integer>): TArray<integer>; override;
    function GetItem(const AKey: TArray<Integer>): TLlamaState; override;
    function Contains(const AKey: TArray<Integer>): Boolean; override;
    procedure SetItem(const AKey: TArray<Integer>; const AValue: TLlamaState); override;
  end;

implementation

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  {$IFDEF MSWINDOWS}
  Windows
  {$ELSE}
  Posix.Unistd
  {$ENDIF}
  ;

type
  TCachePair = TPair<TArray<integer>, TLlamaState>;
  TCachePairs = TArray<TCachePair>;

{ TLlamaDiskCache }

constructor TLlamaDiskCache.Create(const ACacheDir: string; ACapacityBytes: Int64);
var
  LStr: string;
begin
  inherited Create(ACapacityBytes);

  if TDirectory.Exists(ACacheDir) then
  begin
    for LStr in TDirectory.GetFiles(ACacheDir, '*', TSearchOption.soAllDirectories) do
      try
        TFile.Delete(LStr); // Delete files not in use
      except
        //
      end;

    for LStr in TDirectory.GetDirectories(ACacheDir) do
      try
        TDirectory.Delete(LStr, true); // Delete files not in use
      except
        //
      end;
  end;

  {$IFDEF MSWINDOWS}
  FCacheFileName := TPath.Combine(
    TPath.GetFullPath(ACacheDir),
    GetCurrentProcessId().ToString());
  {$ELSE}
  FCacheFileName := TPath.Combine(
    TPath.GetFullPath(ACacheDir),
    GetPID().ToString());
  {$ENDIF}

  FCacheFileName := TPath.Combine(
    FCacheFileName,
    TThread.CurrentThread.ThreadID.ToString());

  FCacheFileName := TPath.Combine(FCacheFileName, 'cache.db');

  if not TDirectory.Exists(TPath.GetDirectoryName(FCacheFileName)) then
    TDirectory.CreateDirectory(TPath.GetDirectoryName(FCacheFileName));

  FConnection := TFDConnection.Create(nil);
  FDatS := TFDQuery.Create(FConnection);
  FDatS.Connection := FConnection;

  CreateCacheConnectionDefs();
  CreateCacheTable();
end;

destructor TLlamaDiskCache.Destroy;
begin
  if Assigned(FTask) then
    FTask.Wait();

  FConnection.Free();
  inherited;
end;

procedure TLlamaDiskCache.CreateCacheConnectionDefs;
begin
  FConnection.Params.Values['database'] := FCacheFileName;
  FConnection.LoginPrompt := False;
  FConnection.DriverName := 'SQLite';
  FConnection.Connected:= True;
end;

procedure TLlamaDiskCache.CreateCacheTable;
begin
  FDatS.SQL.Text := '''
    CREATE TABLE IF NOT EXISTS CACHE(
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      KEY BLOB,
      DATA BLOB
    );
  ''';
  FDatS.ExecSQL;
end;

function TLlamaDiskCache.Load(const AKey: TArray<integer>): TLlamaState;
var
  LStream: TMemoryStream;
begin
  FDatS.SQL.Text := 'SELECT KEY, DATA FROM CACHE WHERE KEY = :KEY';

  LStream := TMemoryStream.Create();
  try
    LStream.WriteBuffer(AKey[0], Length(AKey) * SizeOf(Integer));
    LStream.Position := 0;
    FDatS.ParamByName('KEY').LoadFromStream(LStream, TFieldType.ftBlob);
    LStream.Clear();

    FDatS.Open();

    if FDatS.IsEmpty() then
      Exit(nil);

    try
      LStream.Size := 0;
      TBlobField(FDatS.FieldByName('DATA')).SaveToStream(LStream);

      Result := TLlamaState.Create();
      try
        LStream.Position := 0;
        Result.Deserialize(LStream);
      except
        on E: Exception do
        begin
          FreeAndNil(Result);
          raise;
        end;
      end;
    finally
      FDatS.Close();
    end;

  finally
    LStream.Free;
  end;
end;

procedure TLlamaDiskCache.Save(const AKey: TArray<integer>;
  const AState: TLlamaState);
var
  LStream: TMemoryStream;
begin
  Delete(AKey);

  LStream := TMemoryStream.Create();
  try
    FDatS.SQL.Text := 'INSERT INTO CACHE (KEY, DATA) VALUES (:KEY, :DATA)';

    LStream.WriteBuffer(AKey[0], Length(AKey) * SizeOf(Integer));
    LStream.Position := 0;
    FDatS.ParamByName('KEY').LoadFromStream(LStream, TFieldType.ftBlob);

    LStream.Clear();
    LStream.Size := 0;

    AState.Serialize(LStream);
    LStream.Position := 0;
    FDatS.ParamByName('DATA').LoadFromStream(LStream, TFieldType.ftBlob);
    LStream.Clear();

    FDatS.ExecSQL();
    FConnection.Commit();
  finally
    LStream.Free;
  end;
end;

procedure TLlamaDiskCache.Delete(const AKey: TArray<integer>);
var
  LStream: TMemoryStream;
begin
  FDatS.SQL.Text := 'DELETE FROM CACHE WHERE KEY = :KEY';

  LStream := TMemoryStream.Create();
  try
    LStream.WriteBuffer(AKey[0], Length(AKey) * SizeOf(Integer));
    LStream.Position := 0;
    FDatS.ParamByName('KEY').LoadFromStream(LStream, TFieldType.ftBlob);
    LStream.Clear();

    FDatS.ExecSQL();
    FConnection.Commit();
  finally
    LStream.Free;
  end;
end;

function TLlamaDiskCache.GetCacheSize: Int64;
const
  SQL_SIZES = 'SELECT SUM(LENGTH(KEY)) + SUM(LENGTH(DATA)) FROM CACHE;';
begin
  FDatS.Open(SQL_SIZES);
  try
    Result := FDatS.Fields[0].Value;
  finally
    FDatS.Close();
  end;
end;

function TLlamaDiskCache.FindLongestPrefixKey(const AKey: TArray<Integer>): TArray<integer>;
var
  LPrefixLen: Integer;
  LMaxPrefixLen: Integer;
  LKey: TArray<integer>;
  LStream: TMemoryStream;
begin
  LMaxPrefixLen := 0;

  FDatS.Open('SELECT KEY, DATA FROM CACHE');

  if FDatS.IsEmpty() then
    Exit(nil);

  FDatS.First();

  LStream := TMemoryStream.Create();
  try
    while not FDatS.Eof do
    begin
      LStream.Clear();

      TBlobField(FDatS.FieldByName('KEY')).SaveToStream(LStream);

      LStream.Position := 0;
      SetLength(LKey, LStream.Size div SizeOf(Integer));
      LStream.ReadBuffer(LKey[0], Length(LKey) * SizeOf(Integer));

      LPrefixLen := LongestTokenPrefix(LKey, AKey);
      if LPrefixLen > LMaxPrefixLen then
      begin
        LMaxPrefixLen := LPrefixLen;
        Result := LKey;
      end;

      FDatS.Next();
    end;
  finally
    LStream.Free;
  end;

  FDatS.Close();
end;

function TLlamaDiskCache.Contains(const AKey: TArray<Integer>): Boolean;
begin
  if Assigned(FTask) then
    FTask.Wait();

  Result := Assigned(FindLongestPrefixKey(AKey));
end;

function TLlamaDiskCache.GetItem(const AKey: TArray<Integer>): TLlamaState;
var
  LFoundKey: TArray<integer>;
begin
  if Assigned(FTask) then
    FTask.Wait();

  LFoundKey := FindLongestPrefixKey(AKey);

  if not Assigned(LFoundKey) then
    raise Exception.Create('Key not found');

  Result := Load(LFoundKey);

  Delete(LFoundKey);
end;

procedure TLlamaDiskCache.SetItem(const AKey: TArray<Integer>;
  const AValue: TLlamaState);
var
  LValue: TLlamaState;
begin
  LValue := AValue.Clone();
  FTask := TTask.Run(procedure() begin
    try
      Save(AKey, LValue);
    finally
      LValue.Free();
    end;

    while (GetCacheSize() > CapacityBytes) do
      FDatS.ExecSQL('DELETE FROM CACHE WHERE ID = (SELECT MIN(ID) FROM CACHE);');

    FConnection.Commit();
  end);
end;

end.
