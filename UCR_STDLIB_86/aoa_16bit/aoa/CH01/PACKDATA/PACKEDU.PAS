(*****************************************************************************)
(*                                                                           *)
(* PackData                                                                  *)
(*                                                                           *)
(* 11/4/95                                                                   *)
(* Randall L. Hyde                                                           *)
(* Copyright 1995, All Rights Reserved Unless Otherwise Noted                *)
(*                                                                           *)
(* This program allows the user to input a month value (1..12), a day	     *)
(* value (1..31), and a year value (0..99).  It packs these three values     *)
(* into 16 bits and displays the results.				     *)
(*                                                                           *)
(* Runs under Windows 3.1, Windows 95, and Windows NT.                       *)
(* Source Code: Borland Delphi (object Pascal).                              *)
(*                                                                           *)
(*****************************************************************************)

unit Packedu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,

  { Useful conversion routines: bin <-> dec <-> hexadecimal	}

  Converts;

type
  TPackedData = class(TForm)
    Panel1: TPanel;
    BoundingBox: TGroupBox;

    { Button objects }

    ExitBtn: TButton;
    AboutBtn: TButton;

    { Data Entry Text Boxes }

    MonthBin: TEdit;
    DayBin: TEdit;
    YearBin: TEdit;
    MonthDec: TEdit;
    DayDec: TEdit;
    YearDec: TEdit;

    { Data output strings }

    BinResult: TLabel;
    HexResult: TLabel;

    { Labels appearing on the form }

    MonthLbl: TLabel;
    DayLbl: TLabel;
    YearLbl: TLabel;
    DataPackLbl: TLabel;
    DecimalLbl: TLabel;
    BinaryLbl: TLabel;
    PackResLbl: TLabel;

    { Methods to handle various events }

    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure MonthBinKeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure MonthDecKeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure DayDecKeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure DayBinKeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure YearDecKeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure YearBinKeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure BoundingBoxClick(Sender: TObject);

  private
  public
  end;

var
  PackedData: TPackedData;

implementation

{$R *.DFM}



{ RangeUnsigned checks the first parameter (a string of decimal digits)	}
{ to see if it is a legal unsigned decimal number.  If it is, then it	}
{ converts the value to an integer and checks to make sure it is in the	}
{ range start..stop.  The function returns true if this is the case,	}
{ false otherwise.							}

function RangeUnsigned(const value:string; start, stop:integer):boolean;
var intValue:word;
begin
	result := CheckUnsigned(value);
        if result then begin

        	intValue := StrToInt(Value);
                result := (intValue >= Start) and (intValue <= Stop);

        end;

end;


{ RangeBin is like RangeUnsigned above, except it checks for binary	}
{ values rather than decimal values.					}

function RangeBin(const value:string; start, stop:integer):boolean;
var intValue:word;
begin
	result := CheckBin(value);
        if result then begin

        	intValue := BinToInt(Value);
                result := (intValue >= Start) and (intValue <= Stop);

        end;
end;

{ The program executes the following procedure when the user hits the	}
{ QUIT button.								}

procedure TPackedData.ExitBtnClick(Sender: TObject);
begin
     Halt;
end;


{ The program executes the following procedure when the user hits the	}
{ ABOUT button.								}

procedure TPackedData.AboutBtnClick(Sender: TObject);
begin

    MessageDlg(
       'Packed Data Demonstration, Copyright 1995 by Randall Hyde',
       mtInformation, [mbOk], 0);

end;




{ MonthDecKeyUp-							}
{ The program calls this procedure whenever the user presses and re-	}
{ leases a key in the decimal month data entry text box.  This routine	}
{ converts the new string to an integer, verifies that it is in the	}
{ range 1..12, packs the new month value into packed data object, and	}
{ then displays the new packed data.					}
{ This procedure turns the decimal month background red if there is a	}
{ user input error.							}

procedure TPackedData.MonthDecKeyUp(	Sender:TObject;
					var Key:Word;
                                        Shift:TShiftState
				    );
var
	Year,
        Month,
        Day	:word;
begin

     {First, see if this is a legal decimal value in the range 1..12	}

     if (RangeUnsigned(MonthDec.Text, 1, 12)) then begin

        { Okay, convert the month, day, and year values into integers	}
        { so we can pack them into a 16-bit value.			}

        Month := StrToInt(MonthDec.Text);
        Day := StrToInt(DayDec.Text);
        Year := StrToInt(YearDec.Text);

        { Since the month has just changed, update the binary represen-	}
        { tation of the month.						}

        MonthBin.Text := IntToBin(Month,4);

        { Output the packed data to the appropriate fields on the form.	}

        BinResult.Caption:=IntToBin((Month shl 12) or (Day shl 7) or Year, 16);
        HexResult.Caption:=IntToHex((Month shl 12) or (Day shl 7) or Year, 4);

        { Since there was no error, clear any red background that may	}
        { have previously appeared in this field.			}

        MonthDec.Color := clWindow;
        MonthBin.Color := clWindow;

     end
     else begin

     	  { Come down here if the month just typed is illegal or out of	}
          { range.  Beep the speaker and color the background red.	}

          MessageBeep($ffff);
          MonthDec.Color := clRed;

     end;

end;


{ MonthBinKeyUp-							}
{ Just like the routine above, except this one handles binary input	}
{ rather than decimal input.  See the comments above for a running	}
{ commentary about this procedure.					}

procedure TPackedData.MonthBinKeyUp(Sender: TObject; var Key: Word;
                                    Shift: TShiftState);
var
	Year,
        Month,
        Day	:word;
begin

     if (RangeBin(MonthBin.Text, 1, 12)) then begin

        Month := BinToInt(MonthBin.Text);
        Day := BinToInt(DayBin.Text);
        Year := BinToInt(YearBin.Text);

        MonthDec.Text := IntToStr(Month);
        BinResult.Caption:=IntToBin((Month shl 12) or (Day shl 7) or Year, 6);
        HexResult.Caption:=IntToHex((Month shl 12) or (Day shl 7) or Year, 4);

        MonthBin.Color := clWindow;
        MonthDec.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          MonthBin.Color := clRed;

     end;

end;


{ DayDecKeyUp-								}
{ Like the above routines, handles a key up event in the decimal day	}
{ text entry box.							}

procedure TPackedData.DayDecKeyUp(	Sender: TObject;
					var Key: Word;
                                        Shift: TShiftState);
var
	Year,
        Month,
        Day	:word;
begin

     if (RangeUnsigned(DayDec.Text, 1, 31)) then begin

        Day := StrToInt(DayDec.Text);
        Month := StrToInt(MonthDec.Text);
        Year := StrToInt(YearDec.Text);

        DayBin.Text := IntToBin(Day, 5);
        BinResult.Caption:=IntToBin((Month shl 12) or (Day shl 7) or Year, 16);
        HexResult.Caption:=IntToHex((Month shl 12) or(Day shl 7) or Year, 4);

        DayDec.Color := clWindow;
        DayBin.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          DayDec.Color := clRed;

     end;

end;


{ Binary data entry version of the routine above.			}

procedure TPackedData.DayBinKeyUp(	Sender:TObject;
					var Key:Word;
                                        Shift:TShiftState
				  );
var
	Year,
        Month,
        Day	:word;
begin

     if (RangeBin(DayBin.Text, 1, 31)) then begin

        Day := BinToInt(DayBin.Text);
        Month := BinToInt(MonthBin.Text);
        Year := BinToInt(YearBin.Text);

        DayDec.Text := IntToStr(Day);
        BinResult.Caption:=IntToBin((Month shl 12) or (Day shl 7) or Year, 16);
	HexResult.Caption:=IntToHex((Month shl 12) or (Day shl 7) or Year, 4);

        DayBin.Color := clWindow;
        DayDec.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          DayBin.Color := clRed;

     end;

end;




{ YearDecKeyUp-								}
{ Keystroke event handler for the decimal year data entry text box.	}

procedure TPackedData.YearDecKeyUp(	Sender: TObject;
					var Key: Word;
                                        Shift: TShiftState
				   );
var
	Year,
        Month,
        Day	:word;
begin

     if (RangeUnsigned(YearDec.Text, 0, 99)) then begin

        Year := StrToInt(YearDec.Text);
        Month := StrToInt(MonthDec.Text);
        Day := StrToInt(DayDec.Text);

        YearBin.Text := IntToBin(Year, 7);
        BinResult.Caption:=IntToBin((month shl 12) or (Day shl 7) or Year, 16);
        HexResult.Caption:=IntToHex((Month shl 12) or (Day shl 7) or Year, 4);

        YearDec.Color := clWindow;
        YearBin.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          YearDec.Color := clRed;

     end;

end;

{ Binary version of the above code.					}

procedure TPackedData.YearBinKeyUp(Sender: TObject; var Key: Word;
                                           Shift: TShiftState);
var
	Year,
        Month,
        Day	:word;
begin

     if (RangeBin(DayBin.Text, 0, 99)) then begin

        Year := BinToInt(YearBin.Text);
        Month:= StrToInt(MonthDec.Text);
        Day:= StrToInt(DayDec.Text);

        YearDec.Text := IntToStr(Year);
        BinResult.Caption:=IntToBin((Month shl 12) or (Day shl 7) or Year, 16);
        HexResult.Caption:=IntToHex((Month shl 12) or (Day shl 7) or Year, 4);

        YearDec.Color := clWindow;
        YearBin.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          YearDec.Color := clRed;

     end;

end;





procedure TPackedData.BoundingBoxClick(Sender: TObject);
var
	Year,
        Month,
        Day	:word;
begin

        Year := BinToInt(YearBin.Text);
        Month:= StrToInt(MonthDec.Text);
        Day:= StrToInt(DayDec.Text);

        YearDec.Text := IntToStr(Year);
        YearBin.Text := IntToBin(Year,7);
        MonthDec.Text := IntToStr(Month);
        MonthBin.Text := IntToBin(Month,4);
        DayDec.Text := IntToStr(Day);
        DayBin.Text := IntToBin(Day,5);

end;

end.
