(*****************************************************************************)
(*                                                                           *)
(* HexConv                                                                   *)
(*                                                                           *)
(* 10/25/95                                                                  *)
(* Randall L. Hyde                                                           *)
(* Copyright 1995, All Rights Reserved Unless Otherwise Noted                *)
(*                                                                           *)
(* This program allows the user to enter data in signed decimal, unsigned    *)
(* decimal, unsigned hexadecimal, and unsigned binary formats (all 16 bits). *)
(* It automatically converts an input in one radix to its corresponding      *)
(* representation in the other bases.                                        *)
(*                                                                           *)
(* Runs under Windows 3.1, Windows 95, and Windows NT.                       *)
(* Source Code: Borland Delphi (object Pascal).                              *)
(*                                                                           *)
(*****************************************************************************)


unit Hexconvu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Converts;

type

  { Class definition for the conversion form }

  THexConv = class(TForm)
    BoundingBox: TGroupBox;

    BinLabel: TLabel;
    HexLabel: TLabel;
    DecLabel: TLabel;
    UnsignedDecLbl: TLabel;

    BinEntry: TEdit;     { Box into which the user enters binary data         }
    HexEntry: TEdit;     { Box into which the user enters hexadecimal data    }
    DecEntry: TEdit;     { Box into which the user enters signed decimal data }
    UnsignedEntry: TEdit;{ Box into which the user enters unsigned data       }

    ExitBtn: TButton;
    ClearBtn: TButton;
    AboutBtn: TButton;

    procedure ExitBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure DecEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HexEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BinEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UnsignedEntryKeyUp(   Sender: TObject;
                                    var Key: Word;
                                    Shift: TShiftState
                                 );
    procedure BoundingBoxClick(Sender: TObject);

  end;




{Instance variable for this form }

var
  HexConv: THexConv;




implementation

{$R *.DFM}



{ When the user presses the Quit button, the following method terminates }
{ the program.                                                           }

procedure THexConv.ExitBtnClick(Sender: TObject);
begin
     Halt;
end;

{ If the user presses the clear button, the following method sets all the }
{ fields to zeros.                                                        }

procedure THexConv.ClearBtnClick(Sender: TObject);
begin

     DecEntry.Text := '0';
     UnsignedEntry.Text := '0';
     HexEntry.Text := '0000';
     BinEntry.Text := '0000 0000 0000 0000';

end;



{ When the user presses (and releases) a key inside the decimal entry     }
{ text box, the following method checks the resulting string to see if it }
{ is a valid decimal integer value.  If so, this method updates the       }
{ strings in all the edit boxes to reflect the new value.  If the result- }
{ ing value is invalid, the following method turns the decimal data entry }
{ box red.                                                                }

procedure THexConv.DecEntryKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var  Value:integer;
begin

     if (CheckDec(DecEntry.Text)) then begin  { Legal decimal value       }

        Value := StrToInt(DecEntry.Text);     {Convert string to integer  }

        { Update the strings in the other three data entry boxes.         }

        HexEntry.Text := IntToHex(Value,4);
        BinEntry.Text := IntToBin(Value,16);
        UnsignedEntry.Text := IntToStr(word(Value));

        { Change the color back to normal in case it was red before.      }
        { Red denotes an error, a condition that no longer exists.        }

        DecEntry.Color := clWindow;

     end
     else begin        { Illegal decimal value }

          { If we have an illegal decimal value, beep the speaker and turn }
          { the background color in the text entry box to red.             }

          MessageBeep($ffff);
          DecEntry.Color := clRed;

     end;

end;


{ The following method processes keystrokes in the unsigned decimal entry  }
{ box.  This routine is nearly identical to the DecEntryKeyUp event method.}
{ Please see the comments  in that routine for more details.               }

procedure THexConv.UnsignedEntryKeyUp( Sender: TObject;
                                       var Key: Word;
                                       Shift: TShiftState);
var  Value:word;
begin

     if (CheckUnsigned(UnsignedEntry.Text)) then begin

        Value := StrToInt(UnsignedEntry.Text);
        HexEntry.Text := IntToHex(Value,4);
        DecEntry.Text := IntToStr(integer(Value));
        BinEntry.Text := IntToBin(Value,16);
        UnsignedEntry.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          UnsignedEntry.Color := clRed;

     end;

end;


{ The following method processes keystrokes in the hexadecimal entry       }
{ box.  This routine is nearly identical to the DecEntryKeyUp event method.}
{ Please see the comments  in that routine for more details.               }

procedure THexConv.HexEntryKeyUp(Sender: TObject;
                                 var Key: Word;
                                 Shift: TShiftState);
var value:integer;
begin

     if (CheckHex(HexEntry.Text)) then begin

        Value := HexToInt(HexEntry.Text);
        DecEntry.Text := IntToStr(Value);
        BinEntry.Text := IntToBin(Value,16);
        UnsignedEntry.Text := IntToStr(word(Value));
        HexEntry.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          HexEntry.Color := clRed;

     end;

end;



{ The following method processes keystrokes in the binary data entry       }
{ box.  This routine is nearly identical to the DecEntryKeyUp event method.}
{ Please see the comments  in that routine for more details.               }

procedure THexConv.BinEntryKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var value:integer;
begin

     if (CheckBin(BinEntry.Text)) then begin

        Value := BinToInt(BinEntry.Text);
        DecEntry.Text := IntToStr(Value);
        HexEntry.Text := IntToHex(Value,4);
        UnsignedEntry.Text := IntToStr(word(Value));
        BinEntry.Color := clWindow;

     end
     else begin

          MessageBeep($ffff);
          BinEntry.Color := clRed;

     end;

end;




{ Pressing the 'about' button brings up a dialog box with the copyright    }
{ information.                                                             }

procedure THexConv.AboutBtnClick(Sender: TObject);
begin

    MessageDlg(
       'Hex/Decimal/Binary Converter, Copyright 1995 by Randall Hyde',
       mtInformation, [mbOk], 0);

end;

procedure THexConv.BoundingBoxClick(Sender: TObject);
var value:word;
begin
        Value := word(BinToInt(BinEntry.Text));
        BinEntry.Text := IntToBin(Value,16);
        DecEntry.Text := IntToStr(integer(Value));
        HexEntry.Text := IntToHex(Value,4);
        UnsignedEntry.Text := IntToStr(word(Value));

end;

end.
