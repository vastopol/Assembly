unit Canonu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Aboutu;

type

  TLogEqns = class(TForm)
    InputEqn: TEdit;
    Label1: TLabel;

    tt00: TPanel;
    tt01: TPanel;
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

    ba00: TLabel;
    ba01: TLabel;
    ba10: TLabel;
    ba11: TLabel;
    dc00: TLabel;
    dc01: TLabel;
    dc10: TLabel;
    dc11: TLabel;
    ExitBtn: TButton;
    AboutBtn: TButton;
    ComputeBtn: TButton;
    Eqn1: TLabel;
    Eqn2: TLabel;
    PrintBtn: TButton;
    PrintDialog: TPrintDialog;
    procedure FormCreate(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ComputeBtnClick(Sender: TObject);
    procedure InputEqnChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LogEqns: TLogEqns;

implementation

type

  TPType = array [0..1,0..1,0..1,0..1] of TPanel;

var
  tt: TPType;


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

      with LogEqns do begin

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

    with LogEqns do begin


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



procedure TLogEqns.FormCreate(Sender: TObject);
begin

	tt[0,0,0,0] := tt00;
	tt[0,0,0,1] := tt01;
	tt[0,0,1,0] := tt02;
	tt[0,0,1,1] := tt03;

	tt[0,1,0,0] := tt10;
	tt[0,1,0,1] := tt11;
	tt[0,1,1,0] := tt12;
	tt[0,1,1,1] := tt13;

	tt[1,0,0,0] := tt20;
	tt[1,0,0,1] := tt21;
	tt[1,0,1,0] := tt22;
	tt[1,0,1,1] := tt23;

	tt[1,1,0,0] := tt30;
	tt[1,1,0,1] := tt31;
	tt[1,1,1,0] := tt32;
	tt[1,1,1,1] := tt33;

end;

procedure TLogEqns.ExitBtnClick(Sender: TObject);
begin

	Halt;

end;

procedure TLogEqns.AboutBtnClick(Sender: TObject);
begin
	AboutBox.Show;
end;

procedure TLogEqns.PrintBtnClick(Sender: TObject);
begin

	if (PrintDialog.Execute) then
        	LogEqns.Print;

end;

procedure TLogEqns.ComputeBtnClick(Sender: TObject);
var
    Equation :	string;
    CurChar  :	integer;
    dest,
    i:		integer;

    { Parse- Parses the "Equation" string and evaluates it.	}
    { Returns the equation's value if legal expression, returns	}
    { -1 if the equation is syntactically incorrect.		}
    {								}
    { Grammar:							}
    {		S -> X + S | X					}
    {		X -> YX | Y					}
    {		Y -> Y' | Z					}
    {		Z -> a | b | c | d | ( S )			}

    function parse(D, C, B, A:integer):integer;

    	function X(D,C,B,A:integer):integer;

        	function Y(D,C,B,A:integer):integer;

                	function Z(D,C,B,A:integer):integer;
                        begin

                                case (Equation[CurChar]) of

                		'(': begin

                                	CurChar := CurChar + 1;
                                        Result := parse(D,C,B,A);
                                        if (Equation[CurChar] <> ')') then
                                        	Result := -1
                                        else	CurChar := CurChar + 1;

                                     end;

                                'a': begin

                                	CurChar := CurChar + 1;
                                        Result := A;

                                     end;

                                'b': begin

                                	CurChar := CurChar + 1;
                                        Result := B;

                                     end;

                                'c': begin

                                	CurChar := CurChar + 1;
                                        Result := C;

                                     end;

                                'd': begin

                                	CurChar := CurChar + 1;
                                        Result := D;

                                     end;


                                '0': begin

                                	CurChar := CurChar + 1;
                                        Result := 0;

                                     end;


                                '1': begin

                                	CurChar := CurChar + 1;
                                        Result := 1;

                                     end;

                                else Result := -1;

                                end;
                        end;

                begin {Y}

                    { Note: This particular operation is left recursive	}
                    { and would require considerable grammar transform-	}
                    { ation to repair.  However, a simple trick is to	}
                    { note that the result would have tail recursion	}
                    { which we can solve iteratively rather than recur-	}
                    { sively.  Hence the while loop in the following	}
                    { code.						}

                    Result := Z(D,C,B,A);
                    while (Result <> -1) and (Equation[CurChar] = '''') then
                    begin

                        Result := Result xor 1;
                        CurChar := CurChar + 1;

                    end;
                end;

        begin {X}

        	Result := Y(D,C,B,A);
                if (Result <> -1) and (Equation[CurChar] <> chr(0)) then
                	Result := Result AND X(D,C,B,A);
        end;

    begin

    	Result := X(D,C,B,A);
        if (Result <> -1) and (Equation[CurChar] = '+') then begin

        	CurChar := CurChar + 1;
        	Result := Result OR parse(D, C, B, A);
        end;

    end;


var
	a, b, c, d:integer;

begin {ComputeBtnClick}

    Equation :=  LowerCase(InputEqn.Text) + chr(0);

    { Remove any spaces present in the string }

    dest := 1;
    for i := 1 to length(Equation) do
    	if (Equation[i] <> ' ') then begin

        	Equation[dest] := Equation[i];
                dest := dest + 1;

        end;

    { Okay, see if this string is syntactically legal.	}

    CurChar := 1;	{Start at position 1 in string	}

    if (Parse(0,0,0,0) <> -1) then begin

    	{ Compute the values for each of the squares in	}
        { the truth table.				}

    	for d := 0 to 1 do
          for c := 0 to 1 do
            for b := 0 to 1 do
              for a := 0 to 1 do begin

                CurChar := 1;
                if (parse(d,c,b,a) = 0) then
                	tt[d,c,b,a].Caption := '0'
                else	tt[d,c,b,a].Caption := '1';

              end;

        ComputeEqn;
    	InputEqn.Color := clWindow;

    end
    else InputEqn.Color := clRed;


end;


procedure TLogEqns.InputEqnChange(Sender: TObject);
begin
	ComputeBtn.Default := true;
end;

end.
