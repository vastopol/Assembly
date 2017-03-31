(*****************************************************************************)
(*                                                                           *)
(* Truth                                                                     *)
(*                                                                           *)
(* 10/25/95                                                                  *)
(* Randall L. Hyde                                                           *)
(* Copyright 1995, All Rights Reserved Unless Otherwise Noted                *)
(*                                                                           *)
(* This program converts truth tables into logic equations.                  *)
(*                                                                           *)
(* Runs under Windows 3.1, Windows 95, and Windows NT.                       *)
(* Source Code: Borland Delphi (object Pascal).                              *)
(*                                                                           *)
(*****************************************************************************)


unit Truthu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Converts, Aboutp;

type

  { Class definition for the conversion form }

  TTruthTbl = class(TForm)

    tt00: TPanel;	{These panels correspond to the entries in the	}
    tt01: TPanel;	{truth table, e.g., tt[0..3][0..3]		}
    tt02: TPanel;
    tt03: TPanel;
    tt10: TPanel;
    tt11: TPanel;
    tt12: TPanel;
    tt13: TPanel;
    tt20: TPanel;
    tt21: TPanel;
    tt22: TPanel;
    tt23: TPanel;
    tt30: TPanel;
    tt31: TPanel;
    tt32: TPanel;
    tt33: TPanel;

    Line1: TPanel;
    Line2: TPanel;

    dc00: TLabel;
    dc01: TLabel;
    dc10: TLabel;
    dc11: TLabel;
    ba00: TLabel;
    ba01: TLabel;
    ba10: TLabel;
    ba11: TLabel;

    Eqn1: TLabel;	{This is where we store the logic eqn string	}
    Eqn2: TLabel;

    TwoVarsBtn: TButton;
    ThreeVarsBtn: TButton;
    FourVarsBtn: TButton;
    ExitBtn: TButton;
    AboutBtn: TButton;
    PrintBtn: TButton;
    PrintDialog: TPrintDialog;

    procedure TwoVarsBtnClick(Sender: TObject);
    procedure ThreeVarsBtnClick(Sender: TObject);
    procedure FourVarsBtnClick(Sender: TObject);
    procedure tClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);


  end;




{Instance variable for this form }

var
  TruthTbl: TTruthTbl;




implementation


{$R *.DFM}



(* ComputeEqn-	Computes the logic equation string from the current	*)
(* 		truth table entries.					*)

procedure ComputeEqn;

    { ApndStr-	item contains '0' or '1' -- the character in the}
    {		current truth table cell.  theStr is a string	}
    {		of characters to append to the equation if item	}
    {		is equal to '1'.				}

    procedure ApndStr(item:char; const theStr:string);
    begin

      with TruthTbl do begin

        { To make everything fit on our form, we have to break	}
        { the equation up into two lines.  If the first line	}
        { hits 66 characters, append the characters to the end	}
        { of the second string.					}

        if (length(eqn1.Caption) < 66) then begin

           { If we are appending to the end of EQN1, we have to	}
           { check to see if the string's length is zero.  If	}
           { not, then we need to stick ' + ' between the	}
           { existing string and the string we are appending.	}
           { If the string length is zero, this is the first	}
           { minterm so we don't prepend the ' + '.		}

           if (item = '1') then
        	if (length(eqn1.Caption) = 0) then
                     eqn1.Caption := theStr
        	else eqn1.Caption :=  eqn1.Caption + ' + ' + theStr;
        end
        else if (item = '1') then
        	eqn2.Caption :=  eqn2.Caption + ' + ' + theStr;

      end;

    end;


begin

    with TruthTbl do begin


        eqn1.Caption := '';
        eqn2.Caption := '';

	{ Determine if two variable truth table.  tt12	}
        { will only be visible if we've got a three or	}
        { four variable truth table.			}

        if (not tt12.Visible) then begin

            { Test the 2x2 square in the upper left	}
            { hand corner of the truth table and build	}
            { the logic equation from the values in	}
            { these squares.				}

            ApndStr(tt00.Caption[1],'B''A''');
            ApndStr(tt01.Caption[1],'B''A');
            ApndStr(tt10.Caption[1], 'BA''');
            ApndStr(tt11.Caption[1], 'BA');


        end
        else begin {We've got three or four variables here }

            { See if three or four variable truth table	}
            { tt20 will only be visible if we have a	}
            { four variable truth table.		}

            if (not tt20.Visible) then begin

            	{ Build the logic equation from the top	}
                { eight squares in the truth table.	}

                ApndStr(tt00.Caption[1],'C''B''A''');
            	ApndStr(tt01.Caption[1],'C''B''A');
            	ApndStr(tt02.Caption[1], 'C''BA''');
            	ApndStr(tt03.Caption[1], 'C''BA');

                ApndStr(tt10.Caption[1],'CB''A''');
            	ApndStr(tt11.Caption[1],'CB''A');
            	ApndStr(tt12.Caption[1], 'CBA''');
            	ApndStr(tt13.Caption[1], 'CBA');

            end
            else begin {We've got a four-variable truth table	}

            	{ Build the logic equation from all the squares	}
                { in the truth table.				}

                ApndStr(tt00.Caption[1],'D''C''B''A''');
            	ApndStr(tt01.Caption[1],'D''C''B''A');
            	ApndStr(tt02.Caption[1], 'D''C''BA''');
            	ApndStr(tt03.Caption[1], 'D''C''BA');

                ApndStr(tt10.Caption[1],'D''CB''A''');
            	ApndStr(tt11.Caption[1],'D''CB''A');
            	ApndStr(tt12.Caption[1], 'D''CBA''');
            	ApndStr(tt13.Caption[1], 'D''CBA');

                ApndStr(tt20.Caption[1],'DC''B''A''');
            	ApndStr(tt21.Caption[1],'DC''B''A');
            	ApndStr(tt22.Caption[1], 'DC''BA''');
            	ApndStr(tt23.Caption[1], 'DC''BA');

                ApndStr(tt30.Caption[1],'DCB''A''');
            	ApndStr(tt31.Caption[1],'DCB''A');
            	ApndStr(tt32.Caption[1], 'DCBA''');
            	ApndStr(tt33.Caption[1], 'DCBA');

            end;

        end;

        { If after all the above the string is empty, then we've got a	}
        { truth table that contains all zeros.  Handle that special	}
        { case down here.						}

        if (length(eqn1.Caption) = 0) then
           eqn1.Caption := '0';
    	Eqn1.Caption := 'F= ' + Eqn1.Caption;

    end;

end;


{ If the user hits the "Two Variables" button, turn off all the squares	}
{ in the truth table except the upper left 2x2 block.  Change the labels}
{ on the truth table as appropriate.					}

procedure TTruthTbl.TwoVarsBtnClick(Sender: TObject);
begin

	ba00.Caption := 'A''';
        ba01.Caption := 'A';
        ba10.Caption := '';
        ba11.Caption := '';

        dc00.Caption := 'B''';
        dc01.Caption := 'B';
        dc10.Caption := '';
        dc11.Caption := '';;

        tt02.Visible := false;
        tt03.Visible := false;

        tt12.Visible := false;
        tt13.Visible := false;

        tt20.Visible := false;
        tt21.Visible := false;
        tt22.Visible := false;
        tt23.Visible := false;

        tt30.Visible := false;
        tt31.Visible := false;
        tt32.Visible := false;
        tt33.Visible := false;

        Eqn2.Visible := false;

        tt02.Caption := '0';
        tt03.Caption := '0';
        tt12.Caption := '0';
        tt13.Caption := '0';
        tt20.Caption := '0';
        tt21.Caption := '0';
        tt22.Caption := '0';
        tt23.Caption := '0';
        tt30.Caption := '0';
        tt31.Caption := '0';
        tt32.Caption := '0';
        tt33.Caption := '0';

        ComputeEqn;

end;

{ If the user presses the "Three Variables" button, turn off the bottom	}
{ eight squares and adjust the labels as appropriate.  This code also	}
{ turns on any squares turned off by TwoVarsBtnClick above.		}

procedure TTruthTbl.ThreeVarsBtnClick(Sender: TObject);
begin
	ba00.Caption := 'B''A''';
        ba01.Caption := 'B''A';
        ba10.Caption := 'BA''';
        ba11.Caption := 'BA';

        dc00.Caption := 'C''';
        dc01.Caption := 'C';
        dc10.Caption := '';
        dc11.Caption := '';;

        tt02.Visible := true;
        tt03.Visible := true;

        tt12.Visible := true;
        tt13.Visible := true;

        tt20.Visible := false;
        tt21.Visible := false;
        tt22.Visible := false;
        tt23.Visible := false;

        tt30.Visible := false;
        tt31.Visible := false;
        tt32.Visible := false;
        tt33.Visible := false;

        Eqn2.Visible := true;

        tt20.Caption := '0';
        tt21.Caption := '0';
        tt22.Caption := '0';
        tt23.Caption := '0';
        tt30.Caption := '0';
        tt31.Caption := '0';
        tt32.Caption := '0';
        tt33.Caption := '0';
        ComputeEqn;

end;

{ This procedure turns on all the squares when the user presses	}
{ the "Four Variables" button.					}

procedure TTruthTbl.FourVarsBtnClick(Sender: TObject);
begin
	ba00.Caption := 'B''A''';
        ba01.Caption := 'B''A';
        ba10.Caption := 'BA''';
        ba11.Caption := 'BA';

        dc00.Caption := 'D''C''';
        dc01.Caption := 'D''C';
        dc10.Caption := 'DC''';
        dc11.Caption := 'DC';;

        tt02.Visible := true;
        tt03.Visible := true;

        tt12.Visible := true;
        tt13.Visible := true;

        tt20.Visible := true;
        tt21.Visible := true;
        tt22.Visible := true;
        tt23.Visible := true;

        tt30.Visible := true;
        tt31.Visible := true;
        tt32.Visible := true;
        tt33.Visible := true;

        Eqn2.Visible := true;
        ComputeEqn;
end;

{ Whenever the user clicks on one of the squares in the truth table,	}
{ this procedure toggles its label between '0' <-> '1'.			}

procedure TTruthTbl.tClick(Sender: TObject);
var t:TPanel;
begin
        t:=TPanel(Sender);
	t.Caption := chr(ord(t.Caption[1]) xor 1);
        ComputeEqn;

end;


procedure TTruthTbl.ExitBtnClick(Sender: TObject);
begin
    Halt;
end;

procedure TTruthTbl.AboutBtnClick(Sender: TObject);
begin

    AboutBox.Show;

end;

procedure TTruthTbl.PrintBtnClick(Sender: TObject);
begin
    if (PrintDialog.Execute) then
    	TruthTbl.Print;
end;

end.
