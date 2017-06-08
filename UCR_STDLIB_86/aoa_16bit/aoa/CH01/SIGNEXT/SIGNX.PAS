(*****************************************************************************)
(*                                                                           *)
(* SignExt                                                                   *)
(*                                                                           *)
(* 11/4/95                                                                  *)
(* Randall L. Hyde                                                           *)
(* Copyright 1995, All Rights Reserved Unless Otherwise Noted                *)
(*                                                                           *)
(* This program lets the user enter an eight-bit binary or hexadecimal value.*)
(* It then zero and sign extends this value to 16 bits and displays the res- *)
(* ults in binary and hex.						     *)
(*                                                                           *)
(* Runs under Windows 3.1, Windows 95, and Windows NT.                       *)
(* Source Code: Borland Delphi (object Pascal).                              *)
(*                                                                           *)
(*****************************************************************************)



unit Signx;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls,

  { Special unit that provides bin <-> dec <-> hex conversions.	}

  Converts;

type
  TSignExtend = class(TForm)

    { Data entry boxes for the form: }

    BinEntry1: TEdit;
    HexEntry1: TEdit;

    { The results are written to the following strings on the form: }

    SignExtBin: TLabel;
    SignExtHex: TLabel;
    ZeroExtBin: TLabel;
    ZeroExtHex: TLabel;

    { Labels and other artifacts appearing on the form: }
    DivLine: TPanel;
    MainLbl: TLabel;
    SExtLbl: TLabel;
    ZExtLbl: TLabel;
    DataEntryLbl: TLabel;

    { Buttons and various methods for this form: }

    ExitBtn: TButton;
    AboutBtn: TButton;

    procedure ExitBtnClick(Sender:TObject);
    procedure AboutBtnClick(Sender:TObject);
    procedure BinEntry1KeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure HexEntry1KeyUp(Sender:TObject; var Key:Word; Shift:TShiftState);
    procedure FormClick(Sender:TObject);
    procedure FormCreate(Sender:TObject);

  private
  public
    value1:integer;
  end;

var
  SignExtend: TSignExtend;

implementation

{$R *.DFM}




{ DoCalc-								}
{ This procedure does the sign and zero extension operations.  The pro-	}
{ gram calls this procedure whenever a value in one of the input text	}
{ boxes changes.  It updates the zero extension and sign extension	}
{ output labels on the form.						}

procedure DoCalc;
begin

  with SignExtend do begin

     { First, check to see if we've got a positive or negative 8-bit	}
     { value.								}

     if ((Value1 and $80) <> 0) then begin

     	{ Okay, we've got a negative value.  OR in $FF into the H.O.	}
        { byte for sign extension, zero out the H.O. eight bits for	}
        { zero extension.  Then  output the results to the appropriate	}
        { strings on the form.						}

        SignExtBin.Caption := IntToBin(Value1 or $FF00, 16);
        SignExtHex.Caption := IntToHex(Value1 or $FF00, 4);
        ZeroExtBin.Caption := IntToBin(Value1 and $FF, 16);
        ZeroExtHex.Caption := IntToHex(Value1 and $FF, 4);

     end
     else begin

     	{ If the input value is positive, just zero extend everything.	}

        SignExtBin.Caption := IntToBin(Value1 and $FF,16);
        SignExtHex.Caption := IntToHex(Value1 and $FF, 4);
        ZeroExtBin.Caption := SignExtBin.Caption;
        ZeroExtHex.Caption := SignExtHex.Caption;

     end;

  end;

end;





{ The program calls the following procedure when the user presses the	}
{ QUIT button.								}

procedure TSignExtend.ExitBtnClick(Sender: TObject);
begin
     Halt;
end;


{ HexEntry1KeyUp:							}
{									}
{ The program calls the following procedure whenever the users presses	}
{ and releases a key in the hexadecimal data entry box.  This procedure	}
{ checks the input to make sure it is still a valid hexadecimal value	}
{ and (if it is) then it computes the zero and sign extension values.	}
{ If the input is invalid, this procedure changes the background color	}
{ to red, signifying an illegal value.					}

procedure TSignExtend.HexEntry1KeyUp(Sender: TObject;
                                 var Key: Word;
                                 Shift: TShiftState);
begin

     { See if this is a valid hex string }

     if (CheckHex(HexEntry1.Text)) then begin

 	{ If valid, convert it to an integer, update the binary input	}
        { text box, and do the appropriate calculations.		}

        Value1 := HexToInt(HexEntry1.Text);
        BinEntry1.Text := IntToBin(Value1,8);
        HexEntry1.Color := clWindow;
        BinEntry1.Color := clWindow;
        DoCalc;

     end
     else begin

     	  { If the input was invalid, beep the speaker and set the back-}
          { ground color to red.					}

          MessageBeep($ffff);
          HexEntry1.Color := clRed;

     end;

end;


{  BinEntry1KeyUp-							}
{									}
{ This procedure is essentially the same as the one above, except it	}
{ handles data entry in the binary text entry box.			}
{ See the comments in the procedure above for details.			}

procedure TSignExtend.BinEntry1KeyUp(	Sender:TObject;
					var Key:Word;
                                        Shift:TShiftState
				     );
begin

     if (CheckBin(BinEntry1.Text)) then begin

        Value1 := BinToInt(BinEntry1.Text);
        HexEntry1.Text :=  IntToHex(Value1,2);
        BinEntry1.Color := clWindow;
        HexEntry1.Color := clWindow;
        DoCalc;

     end
     else begin

          MessageBeep($ffff);
          BinEntry1.Color := clRed;

     end;

end;


{ The following procedure displays the "About Box" whenever the user	}
{ presses the "ABOUT" button.						}

procedure TSignExtend.AboutBtnClick(Sender: TObject);
begin

    MessageDlg(
       'Sign and Zero Extension Operations, Copyright 1995 by Randall Hyde',
       mtInformation, [mbOk], 0);

end;



{ FormClick:								}
{ This procedure cleans up the data in the data entry text boxes when-	}
{ ever the user clicks on the background form.				}

procedure TSignExtend.FormClick(Sender: TObject);
begin

     HexEntry1.text := IntToHex(value1,2);
     BinEntry1.text := IntToBin(value1,8);

end;

{ This procedure executes whenever the program first starts running.	}
{ It handles any necessary initialization.				}

procedure TSignExtend.FormCreate(Sender: TObject);
begin

     Value1 := 0;
end;

end.
