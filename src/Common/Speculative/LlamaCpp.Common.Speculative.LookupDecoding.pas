unit LlamaCpp.Common.Speculative.LookupDecoding;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  LlamaCpp.Common.Types;

type
  TLlamaPromptLookupDecoding = class(TInterfacedObject, ILlamaDraftModel)
  private
    FMaxNGramSize: Integer;
    FNumPredTokens: Integer;

    // Function to simulate "np.lib.stride_tricks.sliding_window_view"
    function CreateSlidingWindow(const AInputIds: TArray<Integer>;
      const ANgramSize: Integer): TArray<TArray<Integer>>;

    function GetNgramArray(const AInputIds: TArray<Integer>;
      const ANgramSize: Integer): TArray<Integer>;
    function CompareWindowsWithNgram(
      const SlidingWindows: TArray<TArray<Integer>>;
      const ANgramSize: TArray<Integer>): TArray<Boolean>;
    function FindMatchIndices(const AMatches: TArray<Boolean>): TList<Integer>;
    function GetPredictedTokens(const AInputIds: TArray<Integer>;
      const AMatchIndices: TList<Integer>;
      const ANgramSize: Integer): TArray<Integer>;

    function FindCandidatePredTokens(
      const AInputIds: TArray<Integer>): TArray<Integer>;
  public
    constructor Create(const AMaxNGramSize: Integer = 2;
      const ANumPredTokens: Integer = 10);

    function Execute(const AInputIds: TArray<Integer>): TArray<Integer>;
  end;

implementation

{ TLlamaPromptLookupDecoding }

constructor TLlamaPromptLookupDecoding.Create(
  const AMaxNGramSize: Integer = 2; const ANumPredTokens: Integer = 10);
begin
  inherited Create;
  FMaxNGramSize := AMaxNGramSize;
  FNumPredTokens := ANumPredTokens;
end;

function TLlamaPromptLookupDecoding.CreateSlidingWindow(
  const AInputIds: TArray<Integer>;
  const ANgramSize: Integer): TArray<TArray<Integer>>;
var
  I: integer;
  J: integer;
begin
  if Length(AInputIds) < ANgramSize then
    raise Exception.Create('Ngram size is larger than the input length.');

  SetLength(Result, Length(AInputIds) - ANgramSize + 1);

  // Create sliding windows
  for I := Low(Result) to High(Result) do
  begin
    SetLength(Result[I], ANgramSize);
    for J := 0 to ANgramSize - 1 do
    begin
      Result[I][J] := AInputIds[I + J];
    end;
  end;
end;

function TLlamaPromptLookupDecoding.GetNgramArray(
  const AInputIds: TArray<Integer>; const ANgramSize: Integer): TArray<Integer>;
var
  I: Integer;
begin
  SetLength(Result, ANgramSize);
  for I := 0 to ANgramSize - 1 do
    Result[I] := AInputIds[Length(AInputIds) - ANgramSize + I];
end;

function TLlamaPromptLookupDecoding.CompareWindowsWithNgram(
  const SlidingWindows: TArray<TArray<Integer>>;
  const ANgramSize: TArray<Integer>): TArray<Boolean>;
var
  I: Integer;
  J: Integer;
begin
  SetLength(Result, Length(SlidingWindows));
  for I := Low(SlidingWindows) to High(SlidingWindows) do
  begin
    Result[I] := True;
    for J := Low(ANgramSize) to High(ANgramSize) do
    begin
      if SlidingWindows[I][J] <> ANgramSize[J] then
      begin
        Result[I] := False;
        Break;
      end;
    end;
  end;
end;

function TLlamaPromptLookupDecoding.FindMatchIndices(
  const AMatches: TArray<Boolean>): TList<Integer>;
var
  I: Integer;
begin
  Result := TList<Integer>.Create;
  for I := 0 to High(AMatches) do
    if AMatches[I] then
      Result.Add(I);
end;

function TLlamaPromptLookupDecoding.GetPredictedTokens(
  const AInputIds: TArray<Integer>;
  const AMatchIndices: TList<Integer>;
  const ANgramSize: Integer): TArray<Integer>;
var
  LStartIdx: integer;
  LEndIdx: integer;
  I: integer;
  J: integer;
begin
  for I := 0 to AMatchIndices.Count - 1 do
  begin
    LStartIdx := AMatchIndices[I] + ANgramSize;
    LEndIdx := LStartIdx + FNumPredTokens;
    LEndIdx := Min(LEndIdx, Length(AInputIds));

    if LStartIdx < LEndIdx then
    begin
      SetLength(Result, LEndIdx - LStartIdx);
      for J := 0 to LEndIdx - LStartIdx - 1 do
        Result[J] := AInputIds[LStartIdx + J];
      Exit;
    end;
  end;

  // If no valid predicted tokens found, return an empty array
  Result := nil;
end;

function TLlamaPromptLookupDecoding.FindCandidatePredTokens(
  const AInputIds: TArray<Integer>): TArray<Integer>;
var
  LNgramSize: integer;
  LInputLength: integer;
  LSlidingWindows: TArray<TArray<integer>>;
  LNgramArray: TArray<integer>;
  LMatches: TArray<Boolean>;
  LMatchIndices: TList<integer>;
begin
  LInputLength := Length(AInputIds);

  LMatchIndices := TList<integer>.Create;
  try
    // Iterate over ngram sizes, from max size down to 1
    for LNgramSize := Min(FMaxNGramSize, LInputLength - 1) downto 1 do
    begin
      // Create the sliding windows
      LSlidingWindows := CreateSlidingWindow(AInputIds, LNgramSize);

      // Generate the n-gram array for comparison
      LNgramArray := GetNgramArray(AInputIds, LNgramSize);

      // Compare the windows with the n-gram
      LMatches := CompareWindowsWithNgram(LSlidingWindows, LNgramArray);

      // Find the match indices
      LMatchIndices := FindMatchIndices(LMatches);

      // Extract the predicted tokens based on match indices
      Result := GetPredictedTokens(AInputIds, LMatchIndices, LNgramSize);

      if Length(Result) > 0 then
        Exit;
    end;

    Result := nil;
  finally
    LMatchIndices.Free;
  end;
end;

function TLlamaPromptLookupDecoding.Execute(const AInputIds: TArray<Integer>): TArray<Integer>;
begin
  Result := FindCandidatePredTokens(AInputIds);
end;


end.
