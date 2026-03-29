unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Grids, Data.DB, Vcl.DBGrids, Vcl.Imaging.pngimage;

type
  TFMain = class(TForm)
    btnEncodeS: TButton;
    btnDecodeS: TButton;
    lblAlgorithm: TLabel;
    rbFirst: TRadioButton;
    rbSecond: TRadioButton;
    pnlSecond: TPanel;
    edtKey: TEdit;
    lblKeyS: TLabel;
    lblSourceS: TLabel;
    mmSourceS: TMemo;
    lblResultS: TLabel;
    mmResultS: TMemo;
    btnClearS: TButton;
    pnlFirst: TPanel;
    sgNumericGrid: TStringGrid;
    cmbGrilleSize: TComboBox;
    lblGrilleSize: TLabel;
    mmSourceF: TMemo;
    lblKey: TLabel;
    lblSourceF: TLabel;
    mmResultF: TMemo;
    lblResultF: TLabel;
    btnClearF: TButton;
    btnDecodeF: TButton;
    btnEncodeF: TButton;
    odMain: TOpenDialog;
    imgSourceF: TImage;
    imgSourceS: TImage;
    imgResultF: TImage;
    imgResultS: TImage;
    sdMain: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnEncodeSClick(Sender: TObject);
    procedure btnDecodeSClick(Sender: TObject);
    procedure btnClearSClick(Sender: TObject);
    procedure rbSecondClick(Sender: TObject);
    procedure rbFirstClick(Sender: TObject);
    procedure cmbGrilleSizeChange(Sender: TObject);
    procedure sgNumericGridDrawCell(Sender: TObject; ACol, ARow: LongInt;
      Rect: TRect; State: TGridDrawState);
    procedure sgNumericGridSelectCell(Sender: TObject; ACol, ARow: LongInt;
      var CanSelect: Boolean);
    procedure sgNumericGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnEncodeFClick(Sender: TObject);
    procedure btnClearFClick(Sender: TObject);
    procedure btnDecodeFClick(Sender: TObject);
    procedure imgSourceFClick(Sender: TObject);
    procedure imgSourceSClick(Sender: TObject);
    procedure imgResultSClick(Sender: TObject);
    procedure imgResultFClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

uses
  Math, UTypes, UVigenere, UGrille;

const
  RussianAlphabet: string = 'јЅ¬√ƒ≈®∆«»… ЋћЌќѕ–—“”‘’÷„ЎўЏџ№Ёёя';
  EnglishAlphabet: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

var
  GrilleMatrix: TCharMatrix;
  SelectedCellsMatrix: TIntMatrix;

procedure TFMain.btnEncodeSClick(Sender: TObject);
var
  KeyText, SourceText: string;
begin
  KeyText := FilterText(RussianAlphabet, AnsiUpperCase(edtKey.Text));
  if Length(KeyText) = 0 then
    mmResultS.Text := 'ќшибка: длина отфильтрованного ключа не может быть равна нулю!'
  else
  begin
    SourceText := FilterText(RussianAlphabet, AnsiUpperCase(mmSourceS.Text));
    if Length(SourceText) = 0 then
    begin
      mmResultS.Text := 'ќшибка: длина отфильтрованного исходного текста не может быть равна нулю!';
      Exit;
    end;
    mmResultS.Text := EncodeVigenere(RussianAlphabet, SourceText, KeyText);
  end;
end;

procedure TFMain.btnEncodeFClick(Sender: TObject);
var
  KeyCells: TCells;
  SourceText: string;
  FreeCells, MatrixSize: Integer;
begin
  MatrixSize := cmbGrilleSize.ItemIndex + 2;
  SourceText := FilterText(EnglishAlphabet, AnsiUpperCase(mmSourceF.Text));

  if Length(SourceText) = 0 then
  begin
    mmResultF.Text := 'ќшибка: длина отфильтрованного исходного текста не может быть равна нулю!';
    Exit;
  end;
  
  FreeCells := Floor(Power(MatrixSize, 2));
  if MatrixSize mod 2 <> 0 then
    Dec(FreeCells);

  if Length(SourceText) > FreeCells then
  begin
    mmResultF.Text := 'ќшибка: длина отфильтрованного исходного текста не может превышать количество клеток в решЄтке!';
    Exit;
  end;

  KeyCells := GetKeyCells(SelectedCellsMatrix, MatrixSize);
  if Length(KeyCells) < Floor(Power(MatrixSize, 2) / 4) then
  begin
    mmResultF.Text := 'ќшибка: ключ заполнен не полностью!';
    Exit;
  end;

  mmResultF.Text := EncodeGrille(EnglishAlphabet, SourceText, KeyCells, MatrixSize);
end;

procedure TFMain.btnClearFClick(Sender: TObject);
begin
  mmSourceF.Text := '';
  mmResultF.Text := '';
  cmbGrilleSizeChange(Sender);
end;

procedure TFMain.btnClearSClick(Sender: TObject);
begin
  edtKey.Text := '';
  mmSourceS.Text := '';
  mmResultS.Text := '';
end;

procedure TFMain.btnDecodeFClick(Sender: TObject);
var
  KeyCells: TCells;
  SourceText: string;
  MatrixSize: Integer;
begin
  MatrixSize := cmbGrilleSize.ItemIndex + 2;
  SourceText := FilterText(EnglishAlphabet, AnsiUpperCase(mmSourceF.Text));

  if Length(SourceText) = 0 then
  begin
    mmResultF.Text := 'ќшибка: длина отфильтрованного исходного текста не может быть равна нулю!';
    Exit;
  end;

  if Length(SourceText) > Power(MatrixSize, 2) then
  begin
    mmResultF.Text := 'ќшибка: длина отфильтрованного исходного текста не может превышать количество клеток в решЄтке!';
    Exit;
  end;

  KeyCells := GetKeyCells(SelectedCellsMatrix, MatrixSize);
  if Length(KeyCells) < Floor(Power(MatrixSize, 2) / 4) then
  begin
    mmResultF.Text := 'ќшибка: ключ заполнен не полностью!';
    Exit;
  end;

  mmResultF.Text := DecodeGrille(EnglishAlphabet, SourceText, KeyCells, MatrixSize);
end;

procedure TFMain.btnDecodeSClick(Sender: TObject);
var
  KeyText, SourceText: string;
begin
  KeyText := FilterText(RussianAlphabet, AnsiUpperCase(edtKey.Text));
  if Length(KeyText) = 0 then
    mmResultS.Text := 'ќшибка: длина отфильтрованного ключа не может быть равна нулю!'
  else
  begin
    SourceText := FilterText(RussianAlphabet, AnsiUpperCase(mmSourceS.Text));
    if Length(SourceText) = 0 then
    begin
      mmResultS.Text := 'ќшибка: длина отфильтрованного исходного текста не может быть равна нулю!';
      Exit;
    end;
    mmResultS.Text := DecodeVigenere(RussianAlphabet, SourceText, KeyText);
  end;
end;

procedure TFMain.rbFirstClick(Sender: TObject);
begin
  pnlSecond.Visible := False;
  pnlFirst.Visible := True;
end;

procedure TFMain.rbSecondClick(Sender: TObject);
begin
  pnlFirst.Visible := False;
  pnlSecond.Visible := True;
end;

procedure TFMain.cmbGrilleSizeChange(Sender: TObject);
var
  GrilleSize: Integer;
  NumericMatrix: TIntMatrix;
  I, J: Integer;
begin
  GrilleSize := cmbGrilleSize.ItemIndex + 2;
  sgNumericGrid.ColCount := GrilleSize;
  sgNumericGrid.RowCount := GrilleSize;
  sgNumericGrid.DefaultColWidth := sgNumericGrid.ClientWidth div GrilleSize - 1;
  sgNumericGrid.DefaultRowHeight := sgNumericGrid.ClientHeight div GrilleSize - 1;

  NumericMatrix := GetNumericMatrix(GrilleSize);
  for I := 0 to GrilleSize - 1 do
    for J := 0 to GrilleSize - 1 do
      sgNumericGrid.Cells[I, J] := IntToStr(NumericMatrix[I, J]);

  SetLength(SelectedCellsMatrix, GrilleSize, GrilleSize);
  ClearMatrix(SelectedCellsMatrix);
end;

procedure TFMain.sgNumericGridDrawCell(Sender: TObject; ACol, ARow: LongInt;
  Rect: TRect; State: TGridDrawState);
begin
  if SelectedCellsMatrix[ARow, ACol] = 1 then
    sgNumericGrid.Canvas.Brush.Color := clBlue
  else
    sgNumericGrid.Canvas.Brush.Color := clWhite;

  sgNumericGrid.Canvas.FillRect(Rect);

  if SelectedCellsMatrix[ARow, ACol] <> -1 then
    sgNumericGrid.Canvas.TextOut((Rect.Left + Rect.Right) div 2 - 6,
                                 (Rect.Bottom + Rect.Top) div 2 - 10,
                                 sgNumericGrid.Cells[ARow, ACol]);
end;

procedure TFMain.sgNumericGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I, J, N: Integer;
begin
  if Button = mbRight then
  begin
    ClearMatrix(SelectedCellsMatrix);
    sgNumericGrid.Invalidate;
  end;
end;

procedure FreeOrBlockCells(var SelectedCellsMatrix: TIntMatrix; const TempStr: string;
                           ACol, ARow, Value: Integer);
var
  N, I, J: Integer;
begin
  N := Length(SelectedCellsMatrix);
  for I := 0 to N - 1 do
    for J := 0 to N - 1 do
    begin
      if not ((I = ARow) and (J = ACol)) and (FMain.sgNumericGrid.Cells[I, J] = TempStr) then
        SelectedCellsMatrix[I, J] := Value;
    end;
end;

procedure TFMain.sgNumericGridSelectCell(Sender: TObject; ACol, ARow: LongInt;
  var CanSelect: Boolean);
var
  TempStr: string;
  N, I, J: Integer;
begin
  if SelectedCellsMatrix[ARow, ACol] = 0 then
  begin
    SelectedCellsMatrix[ARow, ACol] := 1;
    FreeOrBlockCells(SelectedCellsMatrix, sgNumericGrid.Cells[ARow, ACol], ACol,
                     ARow, -1);
  end
  else if SelectedCellsMatrix[ARow, ACol] = 1 then
  begin
    SelectedCellsMatrix[ARow, ACol] := 0;
    FreeOrBlockCells(SelectedCellsMatrix, sgNumericGrid.Cells[ARow, ACol], ACol,
                 ARow, 0);
  end;
  sgNumericGrid.Invalidate;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  cmbGrilleSize.ItemIndex := 0;
  cmbGrilleSizeChange(Sender);
end;

procedure TFMain.imgSourceSClick(Sender: TObject);
begin
  if odMain.Execute then
    mmSourceS.Lines.LoadFromFile(odMain.FileName);
end;

procedure TFMain.imgResultFClick(Sender: TObject);
begin
  if sdMain.Execute then
    mmResultF.Lines.SaveToFile(sdMain.FileName);
end;

procedure TFMain.imgResultSClick(Sender: TObject);
begin
  if sdMain.Execute then
    mmResultS.Lines.SaveToFile(sdMain.FileName);
end;

procedure TFMain.imgSourceFClick(Sender: TObject);
begin
  if odMain.Execute then
    mmSourceF.Lines.LoadFromFile(odMain.FileName);
end;

end.
