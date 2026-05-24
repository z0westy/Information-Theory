unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

type
  TfMain = class(TForm)
    lbMain: TLabel;
    rbEncode: TRadioButton;
    tbDecode: TRadioButton;
    pnlEncode: TPanel;
    edtEncodeP: TEdit;
    edtEncodeQ: TEdit;
    edtEncodeD: TEdit;
    mmEncode: TMemo;
    btnEncodeFile: TButton;
    edtEncodeE: TEdit;
    lblEncodeE: TLabel;
    lblEncodeFile: TLabel;
    btnEncode: TButton;
    odMain: TOpenDialog;
    imgEncode: TImage;
    sdMain: TSaveDialog;
    pnlDecode: TPanel;
    lblDecodeFile: TLabel;
    imgDecode: TImage;
    edtDecodeR: TEdit;
    edtDecodeD: TEdit;
    mmDecode: TMemo;
    btnDecodeFile: TButton;
    btnDecode: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    procedure btnEncodeFileClick(Sender: TObject);
    procedure imgEncodeClick(Sender: TObject);
    procedure rbEncodeClick(Sender: TObject);
    procedure tbDecodeClick(Sender: TObject);
    procedure imgDecodeClick(Sender: TObject);
    procedure btnDecodeClick(Sender: TObject);
    procedure btnDecodeFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

uses
  Math, IOUtils;

type
  IntCortege = array[1..3] of Integer;

var
  EncodedBuffer: TArray<Integer>;
  DecodedBuffer: TArray<Byte>;

function IsPrime(Num: Integer): Boolean;
var
  I: Integer;
begin
  if Num <= 1 then Exit(False);

  for I := 2 to Floor(Sqrt(Num)) do
  begin
    if Num mod I = 0 then
      Exit(False);
  end;

  Result := True;
end;

procedure ExchangeValues(var A, B: Integer; NewA, NewB: Integer);
begin
  A := NewA;
  B := NewB;
end;

function ExtendedEuclede(A, B: Integer): IntCortege;
var
  X_0, X_1, Y_0, Y_1, Q: Integer;
begin
  X_0 := 1; X_1 := 0;
  Y_0 := 0; Y_1 := 1;

  while B > 0 do
  begin
    Q := A div B;

    ExchangeValues(X_0, X_1, X_1, X_0 - Q * X_1);
    ExchangeValues(Y_0, Y_1, Y_1, Y_0 - Q * Y_1);
    ExchangeValues(A, B, B, A mod B);
  end;

  Result[1] := X_0;
  Result[2] := Y_0;
  Result[3] := A;
end;

function PowAndMod(X, Y, C: Integer): Integer;
var
  LogIters, I: Integer;
begin
  if Y = 0 then
    Exit(1 mod C);

  Result := X;
  LogIters := Floor(Log2(Y));

  for I := 1 to LogIters do
    Result := (Result mod C) * (Result mod C);

  Result := (Result mod C * PowAndMod(X, Y - PowAndMod(2, LogIters, C), C)) mod C;
end;

function EncodeBuffer(const Buffer: TArray<Byte>; E, R: Integer): TArray<Integer>;
var
  I: Integer;
begin
  SetLength(Result, Length(Buffer));
  for I := Low(Result) to High(Result) do
    Result[I] := PowAndMod(Buffer[I], E, R);
end;

function DecodeBuffer(const Buffer: TArray<Integer>; D, R: Integer): TArray<Byte>;
var
  I: Integer;
begin
  SetLength(Result, Length(Buffer));
  for I := Low(Result) to High(Result) do
    Result[I] := PowAndMod(Buffer[I], D, R);
end;

procedure WriteBufferToMemo(const mmMain: TMemo; const Buffer: TArray<Integer>); overload;
var
  Len, I: Integer;
begin
  mmMain.Text := '';

  Len := Min(1000, Length(Buffer));
  for I := 0 to Len - 1 do
    mmMain.Text := mmMain.Text + IntToStr(Buffer[I]) + ' ';

  if Length(Buffer) > 1000 then
  begin
    mmMain.Lines.Add('');
    mmMain.Lines.Add('Формальный конец! Дальнейший вывод может плохо закончиться');
  end;
end;

procedure WriteBufferToMemo(const mmMain: TMemo; const Buffer: TArray<Byte>); overload;
var
  Len, I: Integer;
begin
  mmMain.Text := '';

  Len := Min(1000, Length(Buffer));
  for I := 0 to Len - 1 do
    mmMain.Text := mmMain.Text + IntToStr(Buffer[I]) + ' ';

  if Length(Buffer) > 1000 then
  begin
    mmMain.Lines.Add('');
    mmMain.Lines.Add('Формальный конец! Дальнейший вывод может плохо закончиться');
  end;
end;

procedure TfMain.btnEncodeClick(Sender: TObject);
var
  P, Q, R, D, E, NumEuler: Integer;
  Buffer: TArray<Byte>;
begin
  if (not TryStrToInt(edtEncodeP.Text, P)) or (P <= 1) or (not IsPrime(P)) then
  begin
    mmEncode.Text := 'Параметр p некорректно введён!';
    Exit;
  end;

  if (not TryStrToInt(edtEncodeQ.Text, Q)) or (Q <= 1) or (not IsPrime(P)) then
  begin
    mmEncode.Text := 'Параметр q некорректно введён!';
    Exit;
  end;

  R := P * Q;
  NumEuler := (P - 1) * (Q - 1);

  if R < 256 then
  begin
    mmEncode.Text := 'Произведение r = p * q не может быть меньше 256!';
    Exit;
  end;

  if (not TryStrToInt(edtEncodeD.Text, D)) or (D <= 1) or (D >= NumEuler) then
  begin
    mmEncode.Text := 'Параметр d некорректно введён!';
    Exit;
  end;

  if odMain.FileName = '' then
  begin
    mmEncode.Text := 'Файл для шифрования не выбран!';
    Exit;
  end;

  E := ExtendedEuclede(D, NumEuler)[1];
  if (E <= 1) or (E >= NumEuler) or (ExtendedEuclede(E, NumEuler)[3] <> 1) then
  begin
    mmEncode.Text := 'Ошибка вычисления открытой экспоненты e!';
    Exit;
  end;
  edtEncodeE.Text := IntToStr(E);

  Buffer := TFile.ReadAllBytes(odMain.FileName);
  EncodedBuffer := EncodeBuffer(Buffer, E, R);
  WriteBufferToMemo(mmEncode, EncodedBuffer);
end;

procedure TfMain.btnDecodeClick(Sender: TObject);
var
  R, D: Integer;
  TempText: String;
  StringBuffer: TArray<String>;
  Buffer: TArray<Integer>;
  I: Integer;
begin
  if (not TryStrToInt(edtDecodeR.Text, R)) or (R <= 1) then
  begin
    mmEncode.Text := 'Параметр r некорректно введён!';
    Exit;
  end;

  if (not TryStrToInt(edtDecodeD.Text, D)) or (D <= 1) then
  begin
    mmEncode.Text := 'Параметр d некорректно введён!';
    Exit;
  end;

  TempText := TFile.ReadAllText(odMain.FileName);
  StringBuffer := TempText.Split([' ']);
  SetLength(Buffer, Length(StringBuffer));

  for I := Low(Buffer) to High(Buffer) do
    Buffer[I] := StrToInt(StringBuffer[I]);

  DecodedBuffer := DecodeBuffer(Buffer, D, R);
  WriteBufferToMemo(mmDecode, DecodedBuffer);
end;

procedure TfMain.imgEncodeClick(Sender: TObject);
var
  I: Integer;
  TempText: String;
begin
  if Length(EncodedBuffer) = 0 then
  begin
    mmEncode.Text := 'Ошибка сохранения в файл! Вы еще не сделали шифрование';
    Exit;
  end;

  if not sdMain.Execute then Exit;

  if Length(EncodedBuffer) = 0 then
    TempText := ''
  else TempText := IntToStr(EncodedBuffer[0]);

  for I := Low(EncodedBuffer) + 1 to High(EncodedBuffer) do
    TempText := TempText +  ' ' + IntToStr(EncodedBuffer[I]);

  TFile.WriteAllText(sdMain.FileName, TempText);
end;

procedure TfMain.imgDecodeClick(Sender: TObject);
begin
  if Length(DecodedBuffer) = 0 then
  begin
    mmDecode.Text := 'Ошибка сохранения в файл! Вы еще не сделали дешифрование';
    Exit;
  end;

  if not sdMain.Execute then Exit;
  TFile.WriteAllBytes(sdMain.FileName, DecodedBuffer);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  rbEncode.Checked := True;
end;

procedure TfMain.rbEncodeClick(Sender: TObject);
begin
  EncodedBuffer := [];
  odMain.Filename := '';
  sdMain.FileName := '';
  edtEncodeP.Text := '';
  edtEncodeQ.Text := '';
  edtEncodeD.Text := '';
  edtEncodeE.Text := '';
  mmEncode.Text := '';
  pnlEncode.Visible := True;
  pnlDecode.Visible := False;
end;

procedure TfMain.tbDecodeClick(Sender: TObject);
begin
  DecodedBuffer := [];
  odMain.Filename := '';
  sdMain.FileName := '';
  edtDecodeR.Text := '';
  edtDecodeD.Text := '';
  mmDecode.Text := '';
  pnlDecode.Visible := True;
  pnlEncode.Visible := False;
end;

procedure TfMain.btnEncodeFileClick(Sender: TObject);
begin
  odMain.Execute;
end;

procedure TfMain.btnDecodeFileClick(Sender: TObject);
begin
  odMain.Execute;
end;

end.
