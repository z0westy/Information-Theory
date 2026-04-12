unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Mask;

type
  TfMain = class(TForm)
    mmText: TMemo;
    odMain: TFileOpenDialog;
    imgOpen: TImage;
    lblText: TLabel;
    mmKey: TMemo;
    lblKey: TLabel;
    mmResultText: TMemo;
    Label1: TLabel;
    btnEncode: TButton;
    meReg: TMaskEdit;
    lblReg: TLabel;
    sdMain: TSaveDialog;
    imgSave: TImage;
    btnDecode: TButton;
    btnClear: TButton;
    procedure FormCreate(Sender: TObject);
    procedure imgOpenClick(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    procedure meRegKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure meRegKeyPress(Sender: TObject; var Key: Char);
    procedure imgSaveClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
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
  System.Math;

const
  M = 27;

type
  MByteArray = array[1..M] of Byte;
  ByteArray = array of Byte;

var
  Polynom: MByteArray;
  PrimaryText, ResultText: ByteArray;

procedure InitPolynom(var Polynom: MByteArray);
begin
  Polynom[1] := 1;
  Polynom[7] := 1;
  Polynom[8] := 1;
  Polynom[27] := 1;
end;

function ByteToBits(Num: Byte): ByteArray;
var
  I: Integer;
begin
  SetLength(Result, 8);
  for I := 7 downto 0 do
    if (Num and (1 shl I)) > 0 then
      Result[7 - I] := 1
    else Result[7 - I] := 0;
end;

function BitsToByte(const Bits: ByteArray): Byte;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to 7 do
    Inc(Result, Bits[7 - I] shl I);
end;

function GetKey(const Reg, Polynom: MByteArray; KeyLen, M: Integer): ByteArray;
var
  I, J: Integer;
  TempBitArray, TempResult: ByteArray;
begin
  SetLength(TempResult, KeyLen * 8);

  if KeyLen <= M then
    Move(Reg[1], TempResult[0], KeyLen)
  else
  begin
    Move(Reg[1], TempResult[0], M);
    for I := M to KeyLen * 8 - 1 do
    begin
      TempResult[I] := Polynom[M] * TempResult[I - 1];
      for J := 1 to M - 1 do
        TempResult[I] := TempResult[I] xor (Polynom[J] * TempResult[I - M + J - 1]);
    end;
  end;

  SetLength(Result, KeyLen);
  SetLength(TempBitArray, 8);
  for I := Low(Result) to High(Result) do
  begin
    Move(TempResult[I * 8], TempBitArray[0], 8);
    Result[I] := BitsToByte(TempBitArray);
  end;
end;

function EncodeText(const Text, Key: ByteArray): ByteArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Text));

  for I := Low(Text) to High(Text) do
    Result[I] := Text[I] xor Key[I];
end;

procedure WriteTextToMemo(const Memo: TMemo; const Text: ByteArray);
const
  MaxCharsInMemo = 16384;
var
  Len, I, J: Integer;
  TempStr: String;
  TempBitArray, TempLittleBitArray: ByteArray;
begin
  if (Length(Text) > MaxCharsInMemo) or (Length(Text) * 8 > MaxCharsInMemo) then
    Len := MaxCharsInMemo
  else Len := Length(Text) * 8;

  SetLength(TempBitArray, Len);
  for I := 0 to Len div 8 - 1 do
  begin
    TempLittleBitArray := ByteToBits(Text[I]);
    Move(TempLittleBitArray[0], TempBitArray[I * 8], 8);
  end;

  for I := 0 to Len div 8 - 1 do
  begin
    for J := 0 to 7 do
      TempStr := TempStr + IntToStr(TempBitArray[I * 8 + J]);
    TempStr := TempStr + ' ';
  end;
  Memo.Text := TempStr;

  if Len = MaxCharsInMemo then
  begin
    Memo.Lines.Add('');
    Memo.Text := Memo.Text + 'TMemo не может полностью отобразить содержимое!';
  end;
end;

procedure TfMain.imgOpenClick(Sender: TObject);
var
  F: File;
  BufSize: Integer;
begin
  if not odMain.Execute then Exit;

  AssignFile(F, odMain.FileName);
  Reset(F, 1);
  BufSize := FileSize(F);
  SetLength(PrimaryText, BufSize);
  BlockRead(F, PrimaryText[0], BufSize);
  CloseFile(F);

  WriteTextToMemo(mmText, PrimaryText);
end;

procedure TfMain.imgSaveClick(Sender: TObject);
var
  F: File;
begin
  if not sdMain.Execute then Exit;

  AssignFile(F, sdMain.FileName);
  Rewrite(F, 1);
  BlockWrite(F, ResultText[0], Length(ResultText));
  CloseFile(F);
end;

procedure TfMain.meRegKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not (Key in [Ord('0'), Ord('1'), VK_LEFT, VK_RIGHT]) then
    Key := 0;
end;

procedure TfMain.meRegKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0', '1']) then
    Key := #0;
end;

procedure TfMain.btnClearClick(Sender: TObject);
begin
  mmText.Text := '';
  mmKey.Text := '';
  mmResultText.Text := '';
  meReg.Text := '000000000000000000000000000';
end;

procedure TfMain.btnEncodeClick(Sender: TObject);
var
  I: Integer;
  Reg: MByteArray;
  Key: ByteArray;
begin
  if Length(PrimaryText) = 0 then Exit;

  for I := Low(Reg) to High(Reg) do
    Reg[I] := StrToInt(meReg.Text[I]);

  Key := GetKey(Reg, Polynom, Length(PrimaryText), M);
  WriteTextToMemo(mmKey, Key);

  ResultText := EncodeText(PrimaryText, Key);
  WriteTextToMemo(mmResultText, ResultText);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  InitPolynom(Polynom);
end;

end.
