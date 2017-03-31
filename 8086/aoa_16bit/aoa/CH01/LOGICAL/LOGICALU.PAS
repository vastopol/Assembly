(************************************************************************)
(*                                                                      *)
(* Logical.EXE                                                          *)
(*                                                                      *)
(* This program is a logical operations calculator.  It lets the user	*)
(* enter two binary or hexadecimal values and it will compute the logi-	*)
(* cal AND, OR, or XOR of these two numbers.  This calculator also sup-	*)
(* ports several unary operations including NOT, NEG, SHL, SHR, ROL and	*)
(* ROR.									*)
(*									*)
(* Randall L. Hyde							*)
(* 11/3/95								*)
(* Copyright 1995, All Rights Reserved.					*)
(*									*)
(************************************************************************)

unit logicalu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,

  (* Converts is a special unit developed for this program that	*)
  (* provides decimal <-> binary <-> hexadecimal conversions	*)
  (* and data checking.						*)

  Converts;


  (* The Delphi Class for this form *)

type
  TLogicalOps = class(TForm)
    BinEntry1: TEdit; 		{Entry box for first binary value	}
    BinEntry2: TEdit;		{Entry box for second binary value	}
    HexEntry1: TEdit;		{Entry box for first hexadecimal value	}
    HexEntry2: TEdit;		{Entry box for second hexadecimal value	}

    BinResult: TLabel;		{Binary result goes here		}
    HexResult: TLabel;		{Hexadecimal result goes here		}

    Panel1: TPanel;

    { Buttons that appear on the form: }

    ExitBtn: TButton;
    AboutBtn: TButton;
    AndBtn: TButton;
    OrBtn: TButton;
    XorBtn: TButton;
    NotBtn: TButton;
    NegBtn: TButton;
    SHLBtn: TButton;
    SHRBtn: TButton;
    ROLBtn: TButton;
    RORBtn: TButton;

    { These labels hold text that appears on the form }

    Label1: TLabel;
    CurOpLbl: TLabel;
    CurrentOp: TLabel;

    { The methods that handle events occurring on this form }

    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure BinEntry1KeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure BinEntry2KeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure HexEntry1KeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure HexEntry2KeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure AndBtnClick(Sender: TObject);
    procedure OrBtnClick(Sender: TObject);
    procedure XorBtnClick(Sender: TObject);
    procedure NotBtnClick(Sender: TObject);
    procedure NegBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SHLBtnClick(Sender: TObject);
    procedure SHRBtnClick(Sender: TObject);
    procedure ROLBtnClick(Sender: TObject);
    procedure RORBtnClick(Sender: TObject);
    procedure FormClick(Sender: TObject);

  private
  public

    { Value1 and Value2 hold the results obtained by converting between	}
    { hex/binary and integer forms.					}

    value1,
    value2:integer;
  end;




var
  LogicalOps: TLogicalOps;

implementation

{$R *.DFM}


{ The types of operations this calculator is capable of appear in the	}
{ following enumerated list.						}

type
    operations = (ANDop, ORop, XORop, NOTop, NEGop, SHLop, SHRop, ROLop, RORop);


var
   operation: operations;



{ DoCalc-  This function does the currently specified operation on	}
{ the value1 and value2 fields.  It displays the results in the binary	}
{ and hexadecimal result fields.					}

procedure DoCalc;
var unsigned:integer;
    carry:boolean;
begin

     { Compute the result of "Value1 op Value2" (for AND, OR, XOR) or	}
     { "op Value1" (for the other operations) and leave the result in	}
     { the "unsigned" variable.						}

     case Operation of

          ANDop: unsigned := LogicalOps.value1 and LogicalOps.value2;
          ORop: unsigned := LogicalOps.value1 or LogicalOps.value2;
          XORop: unsigned := LogicalOps.value1 xor LogicalOps.value2;
          NOTop: unsigned := not LogicalOps.value2;
          NEGop: unsigned := -LogicalOps.value2;
          SHLop: unsigned := LogicalOps.value2 shl 1;
          SHRop: unsigned := LogicalOps.value2 shr 1;
          ROLop: begin
                      carry := (LogicalOps.value2 and $8000) = $8000;
                      unsigned := LogicalOps.value2 shl 1;
                      if carry then inc(unsigned);
                 end;

          RORop: begin
                      carry := odd(LogicalOps.value2);
                      unsigned := LogicalOps.value2 shr 1;
                      if carry then
                         unsigned := unsigned or $8000;
                 end;

     end;

     { Output results to the binary and hexadecimal result fields on	}
     { the form.							}

     LogicalOps.BinResult.Caption := IntToBin(unsigned, 16);
     LogicalOps.HexResult.Caption := IntToHex(unsigned,4);

     end;


{ Reformat is a short utility procedure that redraws all the input	}
{ values whenever the user clicks on one of the operation buttons.	}

procedure Reformat;
begin

     LogicalOps.HexEntry1.text := IntToHex(LogicalOps.value1,4);
     LogicalOps.HexEntry2.text := IntToHex(LogicalOps.value2,4);
     LogicalOps.BinEntry1.text := IntToBin(LogicalOps.value1,16);
     LogicalOps.BinEntry2.text := IntToBin(LogicalOps.value2,16);

end;



{ The following procedure executes when the program first runs.  It	}
{ simply initializes the value1 and value2 variables.			}

procedure TLogicalOps.FormCreate(Sender: TObject);
begin

     Value1 := 0;
     Value2 := 0;

end;



{ The following procedure terminates the program whenever the user	}
{ presses the QUIT button.						}

procedure TLogicalOps.ExitBtnClick(Sender: TObject);
begin
     Halt;
end;



{ Whenever the user releases a key pressed in the first hex data entry	}
{ box, the following procedure runs to convert the string appearing in	}
{ that box to its corresonding integer value.  This procedure also re-	}
{ computes the result using the current operation and updates any nec-	}
{ cessary fields on the form.						}

procedure TLogicalOps.HexEntry1KeyUp(Sender: TObject;
                                 var Key: Word;
                                 Shift: TShiftState);
begin

     { First, see if this is a legal hex value }

     if (CheckHex(HexEntry1.Text)) then begin

        { If legal, convert it to an integer, update the binary field,	}
        { and then calculate the result.  Change the field's background	}
        { colors back to normal since we've got an okay input value.	}

        Value1 := HexToInt(HexEntry1.Text);
        BinEntry1.Text := IntToBin(Value1,16);
        HexEntry1.Color := clWindow;
        BinEntry1.Color := clWindow;
        DoCalc;

     end
     else begin

          { If there was a data entry error, beep the speaker and set	}
          { the background color to red.				}

          MessageBeep($ffff);
          HexEntry1.Color := clRed;

     end;

end;


{ This function handles key up events in the first binary data entry	}
{ field.  It is very similar to HexEntry1KeyUp, so see the comments in	}
{ that procedure for details on how this operates.			}

procedure TLogicalOps.BinEntry1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

     if (CheckBin(BinEntry1.Text)) then begin

        Value1 := BinToInt(BinEntry1.Text);
        HexEntry1.Text := IntToHex(Value1,4);
        BinEntry1.Color := clWindow;
        HexEntry1.Color := clWindow;
        DoCalc;

     end
     else begin

          MessageBeep($ffff);
          BinEntry1.Color := clRed;

     end;
end;


{HexEntry2KeyUp handle key up events in the second hex entry text win-	}
{dow.  See HexEntry1KeyUp for operational details.			}

procedure TLogicalOps.HexEntry2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

     if (CheckHex(HexEntry2.Text)) then begin

        Value2 := HexToInt(HexEntry2.Text);
        BinEntry2.Text := IntToBin(Value2,16);
        HexEntry2.Color := clWindow;
        BinEntry2.Color := clWindow;
        DoCalc;

     end
     else begin

          MessageBeep($ffff);
          HexEntry2.Color := clRed;

     end;
end;


{BinEntry2KeyUp handles key up events in the second binary data entry	}
{window.  See the HexEntry1KeyUp procedure for operational details.	}

procedure TLogicalOps.BinEntry2KeyUp( Sender: TObject;
                                       var Key: Word;
                                       Shift: TShiftState);
begin

     if (CheckBin(BinEntry2.Text)) then begin

        Value2 := BinToInt(BinEntry2.Text);
        HexEntry2.Text := IntToHex(Value2,4);
        BinEntry2.Color := clWindow;
        HexEntry2.Color := clWindow;
        DoCalc;

     end
     else begin

          MessageBeep($ffff);
          BinEntry2.Color := clRed;

     end;

end;







{ The following procedure executes whenever the user presses the	}
{ "ABOUT" button on the form.						}

procedure TLogicalOps.AboutBtnClick(Sender: TObject);
begin

    MessageDlg(
       'Logical Operations Calculator, Copyright 1995 by Randall Hyde',
       mtInformation, [mbOk], 0);

end;


{ The "AndBtnClick" method runs whenever the user presses the AND but-	}
{ ton on the form.  It sets the global operation to logical AND, enables}
{ input in both data entry text box sets (since this is a dyadic opera-	}
{ tion), and it recalculates results.					}

procedure TLogicalOps.AndBtnClick(Sender: TObject);
begin

     Operation := ANDop;	{Set operation to logical AND.		}
     BinEntry1.Enabled := true;	{Allow entry in the binary entry 1 and	}
     HexEntry1.Enabled := true;	{hex entry 1 text boxes.		}
     DoCalc;			{Recalculate results.			}
     Reformat;			{Reformat the current input values.	}
     CurrentOp.Caption := 'AND';{Display "AND" on the FORM.		}

end;




{ Same as above, but for the logical OR operation.			}

procedure TLogicalOps.OrBtnClick(Sender: TObject);
begin

     Operation := ORop;
     BinEntry1.Enabled := true;
     HexEntry1.Enabled := true;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'OR';

end;


{ Same as above, except this one handles the XOR button.		}

procedure TLogicalOps.XorBtnClick(Sender: TObject);
begin

     Operation := XORop;
     BinEntry1.Enabled := true;
     HexEntry1.Enabled := true;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'XOR';

end;



{ Like the above, but the logical NOT operation is unary only, remember. }
{ Of course, unary vs. binary is handled in the DoCalc procedure.	 }

procedure TLogicalOps.NotBtnClick(Sender: TObject);
begin

     Operation := NOTop;
     BinEntry1.Enabled := false;
     HexEntry1.Enabled := false;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'NOT';

end;


{ Procedure that runs when the user presses the NOT button		}

procedure TLogicalOps.NegBtnClick(Sender: TObject);
begin

     Operation := NEGop;
     BinEntry1.Enabled := false;
     HexEntry1.Enabled := false;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'NEG';

end;


{ Procedure that runs when the user presses the SHL button		}

procedure TLogicalOps.SHLBtnClick(Sender: TObject);
begin

     Operation := SHLop;
     BinEntry1.Enabled := false;
     HexEntry1.Enabled := false;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'SHL';

end;


{ Procedure that runs when the user presses the SHR button		}

procedure TLogicalOps.SHRBtnClick(Sender: TObject);
begin

     Operation := SHRop;
     BinEntry1.Enabled := false;
     HexEntry1.Enabled := false;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'SHR';

end;


{ Procedure that runs when the user presses the ROL button		}

procedure TLogicalOps.ROLBtnClick(Sender: TObject);
begin

     Operation := ROLop;
     BinEntry1.Enabled := false;
     HexEntry1.Enabled := false;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'ROL';

end;


{ Procedure that runs when the user presses the ROR button		}

procedure TLogicalOps.RORBtnClick(Sender: TObject);
begin

     Operation := RORop;
     BinEntry1.Enabled := false;
     HexEntry1.Enabled := false;
     DoCalc;
     Reformat;
     CurrentOp.Caption := 'ROR';

end;


procedure TLogicalOps.FormClick(Sender: TObject);
begin
	Reformat;
end;

end.
