unit UGrille;

interface

uses
  UTypes;

procedure ClearMatrix(var Matrix: TIntMatrix);
function GetKeyCells(const SelectedCellsMatrix: TIntMatrix; MatrixSize: Integer): TCells;
function GetNumericMatrix(MatrixSize: Integer): TIntMatrix;
function EncodeGrille(const Alphabet, Text: string; var KeyCells: TCells;
                      MatrixSize: Integer): string;
function DecodeGrille(const Alphabet, Text: string; var KeyCells: TCells; MatrixSize: Integer): string;

implementation

uses
  System.SysUtils;

procedure ClearMatrix(var Matrix: TIntMatrix);
var
  N, I, J: Integer;
begin
  N := Length(Matrix);
  for I := 0 to N - 1 do
    for J := 0 to N - 1 do
      Matrix[I, J] := 0;
  if N mod 2 <> 0 then
    Matrix[N div 2, N div 2] := -1;
end;

function GetKeyCells(const SelectedCellsMatrix: TIntMatrix; MatrixSize: Integer): TCells;
var
  I, J: Integer;
  TempCell: TCell;
begin
  Result := [];
  for I := 0 to MatrixSize - 1 do
    for J := 0 to MatrixSize - 1 do
    begin
      if SelectedCellsMatrix[I, J] = 1 then
      begin
        TempCell[1] := I;
        TempCell[2] := J;
        Result := Result + [TempCell];
      end;
    end;
end;

function GetRotatedCell(const Cell: TCell; MatrixSize: Integer): TCell;
begin
  Result[1] := Cell[2];
  Result[2] := MatrixSize - Cell[1] - 1;
end;

function GetNumericMatrix(MatrixSize: Integer): TIntMatrix;
var
  I, J, K, Counter: Integer;
  CurrCell: TCell;
begin
  SetLength(Result, MatrixSize, MatrixSize);

  Counter := 0;
  for I := 0 to MatrixSize - 1 do
    for J := 0 to MatrixSize - 1 do
    begin
      if Result[I, J] = 0 then
      begin
        Inc(Counter);
        CurrCell[1] := I;
        CurrCell[2] := J;
        for K := 1 to 4 do
        begin
          Result[CurrCell[1], CurrCell[2]] := Counter;
          CurrCell := GetRotatedCell(CurrCell, MatrixSize);
        end;
      end;
    end;
end;

procedure SortKeyCells(var KeyCells: TCells);
var
  TempCell: TCell;
  I, J, MinInd: Integer;
begin
  for I := Low(KeyCells) to High(KeyCells) do
  begin
    MinInd := I;
    for J := I + 1 to High(KeyCells) do
    begin
      if (KeyCells[J, 1] < KeyCells[MinInd, 1]) or
         ((KeyCells[J, 1] = KeyCells[MinInd, 1]) and (KeyCells[J, 2] < KeyCells[MinInd, 2])) then
      MinInd := J;
    end;
    TempCell := KeyCells[I];
    KeyCells[I] := KeyCells[MinInd];
    KeyCells[MinInd] := TempCell;
  end;
end;

function DecodeGrille(const Alphabet, Text: string; var KeyCells: TCells; MatrixSize: Integer): string;
var
  Matrix: TCharMatrix;
  I, J, Index: Integer;
  KeyCell: TCell;
begin
  SetLength(Matrix, MatrixSize, MatrixSize);
  Index := Low(Text);

  for I := 0 to Length(Text) div MatrixSize - 1 do
    for J := 0 to MatrixSize - 1 do
    begin
      Matrix[I, J] := Text[Index];
      Inc(Index);
    end;

  I := Length(Text) div MatrixSize;
  for J := 1 to Length(Text) mod MatrixSize do
  begin
    Matrix[I, J - 1] := Text[Index];
    Inc(Index);
  end;

  Index := Low(Alphabet);
  for I := I to MatrixSize - 1 do
    for J := 0 to MatrixSize - 1 do
      if Ord(Matrix[I, J]) = 0 then
      begin
        Matrix[I, J] := Alphabet[Index];
        Inc(Index);
        if Index > High(Alphabet) then
          Index := Low(Alphabet);
      end;

  SortKeyCells(KeyCells);
  SetLength(Result, Length(KeyCells) * 4);
  Index := Low(Result);

  for I := 1 to 4 do
  begin
    for KeyCell in KeyCells do
    begin
      Result[Index] := Matrix[KeyCell[1], KeyCell[2]];
      Inc(Index);
    end;

    for J := 0 to Length(KeyCells) - 1 do
      KeyCells[J] := GetRotatedCell(KeyCells[J], MatrixSize);
    SortKeyCells(KeyCells);
  end;
end;

function EncodeGrille(const Alphabet, Text: string; var KeyCells: TCells;
                      MatrixSize: Integer): string;
var
  Matrix: TCharMatrix;
  Letter: Char;
  KeyCellsLen, Index, Index_2, I, J: Integer;
begin
  SetLength(Matrix, MatrixSize, MatrixSize);

  Index := 0;
  KeyCellsLen := Length(KeyCells);
  SortKeyCells(KeyCells);
  for Letter in Text do
  begin
    Matrix[KeyCells[Index, 1], KeyCells[Index, 2]] := Letter;
    Inc(Index);

    if Index = KeyCellsLen then
    begin
      Index := 0;
      for I := 0 to KeyCellsLen - 1 do
        KeyCells[I] := GetRotatedCell(KeyCells[I], MatrixSize);
      SortKeyCells(KeyCells);
    end;
  end;

  SetLength(Result, MatrixSize * MatrixSize);
  Index := 1;
  Index_2 := Low(Alphabet);
  for I := 0 to MatrixSize - 1 do
    for J := 0 to MatrixSize - 1 do
    begin
      if Ord(Matrix[I, J]) = 0 then
      begin
        Matrix[I, J] := Alphabet[Index_2];
        Inc(Index_2);
        if Index_2 > High(Alphabet) then
          Index_2 := Low(Alphabet);
      end;
      Result[Index] := Matrix[I, J];
      Inc(Index);
    end;
end;

end.
