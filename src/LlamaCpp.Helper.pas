unit LlamaCpp.Helper;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  LlamaCpp.Common.Types;

type
  TEmbedding = record
  public
    class function Normalize(const AEmbedding: TArray<Single>)
      : TArray<Single>; overload; static;
    class function Normalize(const AEmbeddings: TArray<TArray<Single>>)
      : TArray<TArray<Single>>; overload; static;
  end;

  TLogits = record
  public
    // https://docs.scipy.org/doc/scipy/reference/generated/scipy.special.log_softmax.html
    class function ToLogprobs(const ALogits: TArray<TArray<Single>>;
      const AAxis: integer = -1): TArray<TArray<Single>>; static;
  end;

  TArrayHelper = record
  public
    class function Slice<T>(const AArray: TArray<T>; AStart, AStop, 
      AStep: TInteger): TArray<T>; overload; static;
    class function Slice<T>(const AArray: TArray<T>; AStart, AStop: TInteger)
      : TArray<T>; overload; static;
    class function Slice<T>(const AArray: TArray<T>; AStart: TInteger)
      : TArray<T>; overload; static;
    class function Slice<T>(const AArray: TArray<T>)
      : TArray<T>; overload; static;
      
    class function Slice<T>(const AArray: TArray<TArray<T>>;
      A1DStart: TInteger; A1DStop: TInteger; A1DStep: TInteger;
      A2DStart: TInteger; A2DStop: TInteger; A2DStep: TInteger)
      : TArray<TArray<T>>; overload; static;
  end;

  TStringHelper = record
  public
    class function Slice(const AString: string; AStart, AStop, 
      AStep: TInteger): string; overload; static;
    class function Slice(const AString: string; AStart, AStop: TInteger)
      : string; overload; static;
  end;

  TInputIdHelper = record
  public
    class function InputId(const AInputId: TArray<integer>;
      const ANumberOfTokens: integer): TArray<integer>; static;
  end;

  TScoresHelper = record
  public
    class function Scores(const AScores: TArray<TArray<single>>;
      const ANumberOfTokens: integer): TArray<TArray<single>>; static;
  end;

implementation

uses
  System.Math;

class function TEmbedding.Normalize(const AEmbedding: TArray<Single>)
  : TArray<Single>;
var
  LNorm: Single;
  LIdx: Integer;
begin
  LNorm := 0.0;
  for LIdx := 0 to High(AEmbedding) do
    LNorm := LNorm + AEmbedding[LIdx] * AEmbedding[LIdx];

  LNorm := Sqrt(LNorm);

  if LNorm = 0.0 then
    Result := AEmbedding
  else
  begin
    SetLength(Result, Length(AEmbedding));
    for LIdx := 0 to High(AEmbedding) do
      Result[LIdx] := AEmbedding[LIdx] / LNorm;
  end;
end;

class function TEmbedding.Normalize(const AEmbeddings: TArray<TArray<Single>>)
  : TArray<TArray<Single>>;
var
  LIdx: Integer;
begin
  SetLength(Result, Length(AEmbeddings));
  for LIdx := 0 to High(AEmbeddings) do
    Result[LIdx] := Normalize(AEmbeddings[LIdx]);
end;

{ TArrayHelper }

class function TArrayHelper.Slice<T>(const AArray: TArray<T>;
  AStart, AStop, AStep: TInteger): TArray<T>;
var
  I: integer;
  J: Integer;
begin
  if AStep.IsNull then
    AStep := 1;
    
  if (AStep = 0) then
    raise Exception.Create('Invalid slice parameters.');

  if AStart.IsNull then
    AStart := 0
  else if AStart = 0 then
    AStart := Low(AArray)
  else if AStart < 0 then
    AStart := Max(Length(AArray) + AStart, 0)
  else if AStart >= Length(AArray) then
    Exit(nil);

  if AStop.IsNull then
    AStop := Length(AArray)
  else if AStop = 0 then
    AStop := Low(AArray)
  else if AStop < 0 then
    AStop := Length(AArray) + AStop
  else if AStop > Length(AArray) then
    AStop := Length(AArray);

  // Calculate the size of the result array
  if (AStart < AStop) and (AStep > 0) then
    J := ((AStop - AStart - 1) div AStep) + 1
  else if (AStart > AStop) and (AStep < 0) then
    J := ((AStart - AStop - 1) div Abs(AStep)) + 1
  else
    J := 0;

  SetLength(Result, J);

  J := 0;
  for I := AStart to AStop - 1 do
    if (I - AStart) mod AStep = 0 then
    begin
      Result[J] := AArray[I];
      Inc(J);
    end;
end;

class function TArrayHelper.Slice<T>(const AArray: TArray<T>; AStart,
  AStop: TInteger): TArray<T>;
begin
  Result := Slice<T>(AArray, AStart, AStop, TInteger.Null());
end;

class function TArrayHelper.Slice<T>(const AArray: TArray<T>;
  AStart: TInteger): TArray<T>;
begin
  Result := Slice<T>(AArray, AStart, TInteger.Null());
end;

class function TArrayHelper.Slice<T>(const AArray: TArray<T>): TArray<T>;
begin
  Result := Slice<T>(AArray, TInteger.Null(), TInteger.Null());
end;

class function TArrayHelper.Slice<T>(const AArray: TArray<TArray<T>>; 
  A1DStart: TInteger; A1DStop: TInteger; A1DStep: TInteger;
  A2DStart: TInteger; A2DStop: TInteger; A2DStep: TInteger): TArray<TArray<T>>;
var
  I: Integer;
begin
  Result := Slice<TArray<T>>(AArray, A1DStart, A1DStop, A1DStep);
  for I := Low(Result) to High(Result) do
    Result[I] := Slice<T>(AArray[I], A2DStart, A2DStop, A2DStep);
end;

{ TStringHelper }

class function TStringHelper.Slice(const AString: string; AStart, AStop,
  AStep: TInteger): string;
var
  I: integer;
  LResultLength: integer;
  LStartPos: integer;
begin
  if AStep.IsNull then
    AStep := 1;
    
  if (AStep = 0) then
    raise Exception.Create('Invalid slice parameters.');

  if AStart.IsNull then
    AStart := Low(AString)
  else if AStart = 0 then
    AStart := Low(AString)
  else if AStart < 0 then
    AStart := Length(AString) + AStart
  else if AStart > Length(AString) then
    Exit(String.Empty);
    
  if AStop.IsNull then
    AStop := Length(AString)
  else if AStop = 0 then
    AStop := Low(AString)
  else if AStop < 0 then
    AStop := Length(AString) + AStop
  else if AStop > Length(AString) then
    AStop := Length(AString);     

  if (AStart > AStop) and (AStep > 0) or (AStart < AStop) and (AStep < 0) then
    Exit(String.Empty);

  if (AStart = AStop) then
    LResultLength := 1
  else if (AStart < AStop) and (AStep > 0) then
    LResultLength := ((AStop - AStart) div AStep) + 1
  else if (AStart > AStop) and (AStep < 0) then
    LResultLength := ((AStart - AStop) div Abs(AStep)) + 1
  else
    LResultLength := 0;

  SetLength(Result, LResultLength);

  I := 1;
  for LStartPos := AStart to AStop do
    if (LStartPos - AStart) mod AStep = 0 then
    begin
      Result[I] := AString[LStartPos];
      Inc(I);
    end;
end;

class function TStringHelper.Slice(const AString: string; AStart,
  AStop: TInteger): string;
begin
  Result := Slice(AString, AStart, AStop, TInteger.Null());
end;

{ TLogits }

class function TLogits.ToLogprobs(const ALogits: TArray<TArray<Single>>;
  const AAxis: Integer): TArray<TArray<Single>>;
var
  LMaxLogits, LSumExp: Single;
  LSubtractMaxs, LExpArray: TArray<Single>;
  LRowIndex, LColIndex: Integer;
begin
  // Initialize the result array with the same dimensions as ALogits
  SetLength(Result, Length(ALogits));

  // Loop over each row in the 2D array
  for LRowIndex := Low(ALogits) to High(ALogits) do
  begin
    // Step 1: Find the maximum value across the axis (columns or rows)
    LMaxLogits := -Infinity;

    if AAxis = 0 then
    begin
      // Axis = 0 means find the max across each column (for each row)
      for LColIndex := 0 to High(ALogits[LRowIndex]) do
        LMaxLogits := Max(LMaxLogits, ALogits[LRowIndex][LColIndex]);
    end
    else
    begin
      // Axis = 1 means find the max across each row (for each column)
      LMaxLogits := ALogits[LRowIndex][0];
      for LColIndex := 1 to High(ALogits[LRowIndex]) do
        LMaxLogits := Max(LMaxLogits, ALogits[LRowIndex][LColIndex]);
    end;

    // Step 2: Handle infinite values for LMaxLogits (NaN or Inf)
    if IsInfinite(LMaxLogits) then
      LMaxLogits := 0;

    // Step 3: Subtract the maximum logits value from each element to avoid overflow
    SetLength(LSubtractMaxs, Length(ALogits[LRowIndex]));
    for LColIndex := 0 to High(ALogits[LRowIndex]) do
      LSubtractMaxs[LColIndex] := ALogits[LRowIndex][LColIndex] - LMaxLogits;

    // Step 4: Calculate the exponentials of the subtracted logits
    SetLength(LExpArray, Length(LSubtractMaxs));
    for LColIndex := 0 to High(LSubtractMaxs) do
      LExpArray[LColIndex] := Exp(LSubtractMaxs[LColIndex]);

    // Step 5: Sum the exponentials to calculate the denominator
    LSumExp := 0;
    for LColIndex := 0 to High(LExpArray) do
      LSumExp := LSumExp + LExpArray[LColIndex];

    // Step 6: Calculate ln(LSumExp) (suppressing divide-by-zero errors)
    if LSumExp > 0 then
      LSumExp := Ln(LSumExp)
    else
      LSumExp := 0;

    // Step 7: Compute logprobs by subtracting the log of the sum from each element
    SetLength(Result[LRowIndex], Length(LSubtractMaxs));
    for LColIndex := 0 to High(LSubtractMaxs) do
      Result[LRowIndex][LColIndex] := LSubtractMaxs[LColIndex] - LSumExp;
  end;
end;

{ TInputIdHelper }

class function TInputIdHelper.InputId(const AInputId: TArray<integer>;
  const ANumberOfTokens: integer): TArray<integer>;
begin
  Result := TArrayHelper.Slice<integer>(
    AInputId, Low(AInputId), ANumberOfTokens);
end;

{ TScoresHelper }

class function TScoresHelper.Scores(const AScores: TArray<TArray<single>>;
  const ANumberOfTokens: integer): TArray<TArray<single>>;
var
  I: Integer;
begin
  SetLength(Result, ANumberOfTokens + 1);
  for I := Low(AScores) to ANumberOfTokens do
  begin
    SetLength(Result[I], Length(AScores[I]));
    TArray.Copy<single>(
      AScores[I], Result[I], Low(AScores[I]), Low(Result[I]), Length(AScores[I]));
  end;
end;

end.
