unit UVigenere;

interface

function FilterText(const Alphabet, Text: string): string;
function EncodeVigenere(const Alphabet, Text, Key: string): string;
function DecodeVigenere(const Alphabet, Text, Key: string): string;

implementation

function FilterText(const Alphabet, Text: string): string;
var
  Symbol: Char;
begin
  Result := '';
  for Symbol in Text do
  begin
    if Pos(Symbol, Alphabet) > 0 then
      Result := Result + Symbol;
  end;
end;

function GetNextLetter(const Alphabet: string; Letter: Char): Char;
var
  Index: Integer;
begin
  if Letter = Alphabet[High(Alphabet)] then
    Exit(Alphabet[Low(Alphabet)]);

  Index := Pos(Letter, Alphabet) + 1;
  Result := Alphabet[Index];
end;

function GetNextKey(const Alphabet, Key: string): string;
var
  I: Integer;
begin
  SetLength(Result, Length(Key));
  for I := Low(Result) to High(Result) do
    Result[I] := GetNextLetter(Alphabet, Key[I]);
end;

function GetFullKey(const Alphabet, Key: string; FullKeyLength: Integer): string;
var
  I: Integer;
  CurrKey: string;
begin
  SetLength(Result, 0);
  
  CurrKey := Copy(Key, Low(Key), Length(Key));
  for I := 1 to FullKeyLength div Length(Key) do
  begin
    Result := Result + CurrKey;
    CurrKey := GetNextKey(Alphabet, CurrKey);
  end;
  Result := Result + Copy(CurrKey, 1, FullKeyLength mod Length(Key));
end;

function GetEncodedLetter(const Alphabet: string; TextLetter, KeyLetter: Char): Char;
begin
  Result := Alphabet[(Pos(KeyLetter, Alphabet) - 1 +
    Pos(TextLetter, Alphabet) - 1) mod Length(Alphabet) + 1];
end;

function GetDecodedLetter(const Alphabet: string; TextLetter, KeyLetter: Char): Char;
var
  Index: Integer;
begin
  Index := Pos(TextLetter, Alphabet) - Pos(KeyLetter, Alphabet);
  if Index < 0 then
    Index := Length(Alphabet) + Index;
  Result := Alphabet[Index + 1];
end;

function DecodeVigenere(const Alphabet, Text, Key: string): string;
var
  FullKey: String;
  I: Integer;
begin
  FullKey := GetFullKey(Alphabet, Key, Length(Text));

  SetLength(Result, Length(Text));
  for I := Low(Result) to High(Result) do
    Result[I] := GetDecodedLetter(Alphabet, Text[I], FullKey[I]);
end;

function EncodeVigenere(const Alphabet, Text, Key: string): string;
var
  FullKey: String;
  I: Integer;
begin
  FullKey := GetFullKey(Alphabet, Key, Length(Text));

  SetLength(Result, Length(Text));
  for I := Low(Result) to High(Result) do
    Result[I] := GetEncodedLetter(Alphabet, Text[I], FullKey[I]);
end;

end.
