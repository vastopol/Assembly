(************************************************************************)
(*									*)
(* Optimize-								*)
(*									*)
(* Randall L. Hyde							*)
(* 12/20/95								*)
(* For use with "The Art of Assembly Language Programming."		*)
(* Copyright 1995, All Rights Reserved.					*)
(*									*)
(* This program lets the user enter a logic equation.  The program will	*)
(* convert the logic equation to a truth table and its canonical sum of	*)
(* minterms form.  The program will then optimize the equation (to pro-	*)
(* duce a minimal number of terms) using the carnot map method.		*)
(*									*)
(************************************************************************)


unit Optimize;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Aboutu, ExtCtrls;

type
  TEqnOptimize = class(TForm)

    PrintBtn: TButton; 	{ Buttons appearing on the form		}
    AboutBtn: TButton;
    ExitBtn: TButton;
    OptimizeBtn: TButton;

    CanonicalPanel: TGroupBox;
    OptimizedPanel: TGroupBox;
    PrintDialog: TPrintDialog;

    LogEqn: TEdit;	{Logic equation input box and label	}
    LogEqnLbl: TLabel;

    Eqn1: TLabel;	{ Strings that hold the canonical form	}
    Eqn2: TLabel;

    Eqn3: TLabel;       { Strings that hold the optimized form	}
    Eqn4: TLabel;

    dc00: TLabel;	{ Labels around the truth map	}
    dc01: TLabel;
    dc11: TLabel;
    dc10: TLabel;
    ba00: TLabel;
    ba01: TLabel;
    ba11: TLabel;
    ba10: TLabel;

    tt00: TPanel;	{ Rectangles in the truth map }
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
    StepBtn: TButton;

    procedure PrintBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure LogEqnChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OptimizeBtnClick(Sender: TObject);
    procedure StepBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EqnOptimize: TEqnOptimize;

implementation

{ Set constants for the optimization operation.	 These sets group the	}
{ cells in the truth map that combine to form simpler terms.		}

type TblSet = set of 0..15;
const
	{ If the truth table is equal to the "Full" set, then we have	}
        { the logic function "F=1".					}

	Full = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];

        { The TermSets list is a list of sets corresponding to the	}
        { cells in the truth map that contain all ones for the terms 	}
        { that we can optimize away.					}

        TermSets : array[0..79] of TblSet =
               (

               	{ Terms containing a single variable, e.g., A, A', B,	}
                { B', and so on.					}

        	[0,1,2,3,4,5,6,7],
                [4,5,6,7,8,9,10,11],
                [8,9,10,11,12,13,14,15],
                [12,13,14,15,0,1,2,3],
                [0,1,4,5,8,9,12,13],
                [1,2,5,6,9,10,13,14],
                [2,3,6,7,10,11,14,15],
                [3,0,7,4,11,8,15,12],

                { Terms containing two variables, e.g., AB, AB', A'B,	}
                { and so on.  This first set of eight values corres-	}
                { ponds to the groups of four vertical or horizontal	}
                { values.  The next group of 16 sets corresponds to the	}
                { groups of four values that form a 2x2 square in the	}
                { truth map.						}

        	[0,1,2,3],		[4,5,6,7],
                [8,9,10,11],		[12,13,14,15],
                [0,4,8,12],		[1,5,9,13],
                [2,6,10,14],		[3,7,11,15],

                [0,1,4,5],		[1,2,5,6],
                [2,3,6,7],		[3,0,7,4],

                [4,5,8,9],		[5,6,9,10],
                [6,7,10,11],		[7,4,11,8],

                [8,9,12,13],		[9,10,13,14],
                [10,11,14,15],		[11,8,15,12],

                [12,13,0,1],		[13,14,1,2],
                [14,15,2,3],		[15,12,3,0],

                { Terms containing three variables, e.g., ABC, ABC',	}
                { and so on.						}

               	[0,1],		[1,2],		[2,3],		[3,0],
                [4,5],		[5,6],		[6,7],		[7,4],
                [8,9],		[9,10],		[10,11],	[11,8],
                [12,13],	[13,14],	[14,15],	[15,12],

                [0,4],		[4,8],		[8,12],		[12,0],
                [1,5],		[5,9],		[9,13],		[13,1],
                [2,6],		[6,10],		[10,14],	[14,2],
                [3,7],		[7,11],		[11,15],	[15,3],


                { Minterms- Those terms containing four variables.	}

                [0],	[1],	[2],	[3],
                [4],	[5],	[6],	[7],
                [8],	[9],	[10],	[11],
                [12],	[13],	[14],	[15]
               );


        { Here are the corresponding strings we output for the patterns	}
        { above.							}


        TermStrs: array [0..79] of string[8] =
               	('D''', 'C', 'D', 'C''',
                 'B''', 'A', 'B', 'A''',

        	 'D''C''', 'D''C', 'DC',   'DC''',
                 'B''A''', 'B''A', 'BA',   'BA''',
                 'D''B''', 'D''A', 'D''B', 'D''A''',
                 'CB''',   'CA',   'CB',   'CA''',
                 'DB''',   'DA',   'DB',   'DA''',
                 'C''B''', 'C''A', 'C''B', 'C''A''',

		 'D''C''B''',	'D''C''A',	'D''C''B',	'D''C''A''',
		 'D''CB''',	'D''CA',	'D''CB',	'D''CA''',
		 'DCB''',	'DCA',		'DCB',		'DCA''',
		 'DC''B''',	'DC''A',	'DC''B',	'DC''A''',

                 'B''A''D''',	'B''A''C',	'B''A''D',	'B''A''C''',
                 'B''AD''',	'B''AC',	'B''AD',	'B''AC''',
                 'BAD''',	'BAC',		'BAD',		'BAC''',
                 'BA''D''',	'BA''C',	'BA''D',	'BA''C''',

               	 'D''C''B''A''','D''C''B''A',	'D''C''BA',	'D''C''BA''',
               	 'D''CB''A''',	'D''CB''A',	'DC''BA',	'DC''BA''',
               	 'DCB''A''',	'DCB''A',	'DCBA',		'DCBA''',
               	 'DC''B''A''',	'DC''B''A',	'DC''BA',	'DC''BA'''
                );



        { Transpose converts truth table indicies into truth map index-	}
        { es.  In reality, this converts binary numbers to a gray code.	}

        Transpose : array [0..15] of integer = (0, 1, 3, 2,
        					4, 5, 7, 6,
                                                12,13,15,14,
                                                8, 9, 11, 10);

var

	{ Global, static, variables that the iterator uses to step	}
        { through an optimization.					}

	IterIndex:	integer;
        FirstStep:	boolean;

    	StepSet,
    	StepLeft,
        LastSet		:TblSet;

	{ The following array provides convenient access to the truth map }

	tt: array[0..1,0..1,0..1,0..1] of TPanel;

{$R *.DFM}




{ ApndStr-	item contains '0' or '1' -- the character in the}
{		current truth table cell.  theStr is a string	}
{		of characters to append to the equation if item	}
{		is equal to '1'.				}

procedure ApndStr(item:char; const theStr:string;
		  var Eqn1, Eqn2:TLabel);
begin


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



(* ComputeEqn-	Computes the logic equation string from the current	*)
(* 		truth table entries.					*)

procedure ComputeEqn;
begin

    with EqnOptimize do begin


        eqn1.Caption := '';
        eqn2.Caption := '';


        { Build the logic equation from all the squares	}
        { in the truth table.				}

        ApndStr(tt00.Caption[1],'D''C''B''A''',Eqn1, Eqn2);
        ApndStr(tt01.Caption[1],'D''C''B''A',Eqn1, Eqn2);
        ApndStr(tt02.Caption[1], 'D''C''BA',Eqn1, Eqn2);
        ApndStr(tt03.Caption[1], 'D''C''BA''',Eqn1, Eqn2);

        ApndStr(tt10.Caption[1],'D''CB''A''',Eqn1, Eqn2);
        ApndStr(tt11.Caption[1],'D''CB''A',Eqn1, Eqn2);
        ApndStr(tt12.Caption[1], 'D''CBA',Eqn1, Eqn2);
        ApndStr(tt13.Caption[1], 'D''CBA''',Eqn1, Eqn2);

        ApndStr(tt20.Caption[1],'DCB''A''',Eqn1, Eqn2);
        ApndStr(tt21.Caption[1],'DCB''A',Eqn1, Eqn2);
        ApndStr(tt22.Caption[1], 'DCBA',Eqn1, Eqn2);
        ApndStr(tt23.Caption[1], 'DCBA''',Eqn1, Eqn2);

        ApndStr(tt30.Caption[1],'DC''B''A''',Eqn1, Eqn2);
        ApndStr(tt31.Caption[1],'DC''B''A',Eqn1, Eqn2);
        ApndStr(tt32.Caption[1], 'DC''BA',Eqn1, Eqn2);
        ApndStr(tt33.Caption[1], 'DC''BA''',Eqn1, Eqn2);


    	{ If after all the above the string is empty, then we've got a	}
	{ truth table that contains all zeros.  Handle that special	}
    	{ case down here.						}

    	if (length(eqn1.Caption) = 0) then
           eqn1.Caption := '0';
    	Eqn1.Caption := 'F= ' + Eqn1.Caption;

    end;

end;


procedure RestoreMap;
var a,b,c,d:integer;
begin

        { Restore the colors on the truth map.				}

	for d := 0 to 1 do
            for c := 0 to 1 do
            	for b := 0 to 1 do
                    for a := 0 to 1 do
                    begin

                    	tt[d,c,b,a].Color := clBtnFace;

                    end;
end;



{ InitIter-Initializes the iterator for the first optimization step.	}
{          This code enables the step button, sets all the truth table	}
{ 	   squares to gray, and sets up the global variables for the	}
{	   very first optimization operation.				}

procedure InitIter;
var
    d,c,b,a:integer;
begin

    with EqnOptimize do
    begin

	{ Initialize global variables.					}

	StepBtn.Enabled := true;
        IterIndex := 0;
        LastSet := [];

        { Restore the colors on the truth map.				}

	RestoreMap;

        { Compute the set of values in the truth map 			}

        Eqn3.Caption := '';
        Eqn4.Caption := '';
        IterIndex := 0;
        StepSet := [];
        for d := 0 to 1 do
            for c := 0 to 1 do
            	for b := 0 to 1 do
                    for a := 0 to 1 do
                    	if (tt[d,c,b,a].Caption = '1') then
                           StepSet := StepSet + [ ((b*2+a) xor b) +
                                		   ((d*2+c) xor d)*4
                                                ];
        StepLeft := StepSet;

        { Check for two special cases: F=1 and F=0.  The optimization	}
        { algorithm cannot handle F=0 and this seems like the most	}
        { appropriate place to handle F=1.  So handle these two special	}
        { cases here.							}

        if (StepSet = Full) then
        begin

        	Eqn3.Caption := 'F = 1';
                StepSet := [];

        end
        else if (StepSet = []) then Eqn3.Caption := 'F = 0';
    end;

    { Prevent a call to this routine the next time the user presses	}
    { the "Step" button.						}

    FirstStep := false;

end;


{ StepBtnClick- This event does a single optimization operation.  Each	}
{ time the user presses the "Step" button, this code does a single	}
{ optimization operation;  that is, it locates a single unprocessed	}
{ group of ones in the truth map and optimizes them to their appropri-	}
{ ate term.  It highlights the optimized group so the user can easily	}
{ following the optimization process.  This program must call InitIter	}
{ prior to the first call of this routine.  In general, that call	}
{ occurs in the event handler for the "Optimize" button.		}

procedure TEqnOptimize.StepBtnClick(Sender: TObject);
var
    a,b,c,d, i:integer;
begin

    { On the first call to this event handler (after the user presses	}
    { the "Optimize" button), we need to initialize the iterator.  The	}
    { FirstStep flag determines whether this is the first call after	}
    { the user presses optimize.					}

    if (FirstStep) then InitIter;

    with EqnOptimize do begin

    	{ The user actually has to press the "Step" button twice for	}
        { each optimization step.  On the second press, the following	}
        { code turns the squares processed on the previous depression	}
        { to dark green.  This helps visually convey the process to 	}
        { the user.							}

        if (LastSet <> []) then
        begin

        	for i := 0 to 15 do
                    if (Transpose[i] in LastSet) then
                    	tt[i shr 3, (i shr 2) and 1,
                            (i shr 1) and 1, i and 1].Color :=
                        	clgreen;
                LastSet := [];

        end

        { The following code executes on the first press of each pair	}
        { of "Step" button depressions.  It checks to see if there is	}
        { any work left to do and if so, it does exactly one optimiza-	}
        { tion step.							}

        else if (StepLeft <> []) then
        begin

        	{ IterIndex should always be less than 80, this is just	}
                { a sanity check.					}

                while (IterIndex < 80) do
                begin

                	{ If the current set of unprocessed squares	}
                        { matches one of the patterns we need to process}
                        { then add the appropriate term to our logic	}
                        { equation.					}

                	if ((TermSets[IterIndex] <= StepSet) and
                           ((TermSets[IterIndex] * StepLeft) <> [])) then begin

                        	ApndStr('1',TermStrs[IterIndex],Eqn3,Eqn4);

                                { On the first step, we need to prepend	}
                                { the string "F = " to our logic eqn.	}
                                { The following if statement handles	}
                                { this chore.				}

                                if (Eqn3.Caption[1] <> 'F') then
                                	Eqn3.Caption := 'F = ' + Eqn3.Caption;

                                { Remove the group we just processed	}
                                { from the truth map cells we've still	}
                                { got to process.			}

                                StepLeft := StepLeft - TermSets[IterIndex];

                                { Turn the cells we just processed to 	}
                                { a bright, light, blue color (aqua).	}
                                { This lets the user see which cells	}
                                { correspond to the term we just ap-	}
                                { pended to the end of the equation.	}

                                for i := 0 to 15 do
                                    if (Transpose[i] in
                                    		TermSets[IterIndex]) then
                                    	tt[i shr 3, (i shr 2) and 1,
                                           (i shr 1) and 1, i and 1].Color :=
                                           	claqua;

                                { Save this group of cells so we can	}
                                { turn them dark green on the next call	}
                                { to this routine.			}

                                LastSet := TermSets[IterIndex];
                                break;

                        end;
                        inc(IterIndex);

                end;

        end

        { After the last valid depression of the "Step" button, clear	}
        { the truth map and disable the "Step" button.			}

        else begin

        	RestoreMap;
                StepBtn.Enabled := false;

        end;

    end;

end;


{ OptEqn- This routine optimizes a boolean expression.  This code is	}
{ roughly equivalent to the "Step" event handler above except it gener-	}
{ ates the optimized equation in a single call rather than in several	}
{ distinct calls.							}

procedure OptEqn;
var
    a,b,c,d,
    i		:integer;

    TTSet,
    TLeft	:TblSet;

begin

    with EqnOptimize do begin

    	{ Generate the set of minterms we need to process.	}

	TTSet := [];
	for d := 0 to 1 do
            for c := 0 to 1 do
            	for b := 0 to 1 do
                    for a := 0 to 1 do
            		if (tt[d,c,b,a].Caption = '1') then
            			TTSet := TTSet + [ ((b*2+a) xor b) +
                                		   ((d*2+c) xor d)*4
                                 		 ];
        { Special cases for F=1 and F=0	}

        if (TTSet = Full) then
        begin

        	Eqn3.Caption := 'F = 1';
                Eqn4.Caption := '';

        end
        else if (TTSet = []) then
        begin

        	Eqn3.Caption := 'F = 0';
                Eqn4.Caption := '';

        end

        { The following code handles all other equations.  It steps	}
        { through each of the possible patterns and if it finds a	}
        { match it will add its corresponding term to the end of the	}
        { optimized logic equation.					}

        else begin

        	TLeft := TTSet;
                Eqn3.Caption := '';
                Eqn4.Caption := '';
                for i := 0 to 79 do begin

                	if ((TermSets [i] <= TTSet) and
                            ((TermSets [i] * TLeft) <> [])) then begin

                        	ApndStr('1',TermStrs[i],Eqn3,Eqn4);
                                TLeft := TLeft - TermSets[i];

                        end;

                end;

        end;

        Eqn3.Caption := 'F = ' + Eqn3.Caption;

        { Now that the user has pressed the optimize button, enable	}
        { the "Step" button so they can single step through the opti-	}
        { mization operation.						}

    	FirstStep := true;
    	StepBtn.Enabled := true;

    end;

end;


{ The following event handles "Print" button depressions.	}

procedure TEqnOptimize.PrintBtnClick(Sender: TObject);
begin

	if (PrintDialog.Execute) then
        	EqnOptimize.Print;
end;

{ The following event handles "Exit" button depressions.	}

procedure TEqnOptimize.ExitBtnClick(Sender: TObject);
begin
	Halt;
end;

{ The following event handles "About" button depressions.	}

procedure TEqnOptimize.AboutBtnClick(Sender: TObject);
begin

	AboutBox.Show;
end;

{ Whenever the user changes the logic equation, we need to	}
{ disable the step button.  The following event does just that	}
{ as well as making the "Optimize" button the default operation	}
{ when the user presses the "Enter" key.			}

procedure TEqnOptimize.LogEqnChange(Sender: TObject);
begin
	OptimizeBtn.Default := true;
        RestoreMap;
        StepBtn.Enabled := false;
end;


{ Whenever the system starts up, the following procedure does	}
{ some one-time initialization.					}

procedure TEqnOptimize.FormCreate(Sender: TObject);
begin

	{ Initialize the tt array so we can use to to access	}
        { the Truth Map as a two-dimensional array.		}

	tt[0,0,0,0] := tt00;
	tt[0,0,0,1] := tt01;
	tt[0,0,1,1] := tt02;
	tt[0,0,1,0] := tt03;

	tt[0,1,0,0] := tt10;
	tt[0,1,0,1] := tt11;
	tt[0,1,1,1] := tt12;
	tt[0,1,1,0] := tt13;

	tt[1,0,0,0] := tt30;
	tt[1,0,0,1] := tt31;
	tt[1,0,1,1] := tt32;
	tt[1,0,1,0] := tt33;

	tt[1,1,0,0] := tt20;
	tt[1,1,0,1] := tt21;
	tt[1,1,1,1] := tt22;
	tt[1,1,1,0] := tt23;

end;

{ Whenever the user presses the optimize button, the following	}
{ procedure parses the input logic equation, generates a truth	}
{ map for it, and then generates the canonical and optimized	}
{ equations.							}

procedure TEqnOptimize.OptimizeBtnClick(Sender: TObject);

var
    CurChar:integer;
    Equation:string;


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
                    while (Result <> -1) and (Equation[CurChar] = '''') do
                    begin

                        Result := Result xor 1;
                        CurChar := CurChar + 1;

                    end;
                end;

        begin {X}

        	Result := Y(D,C,B,A);
                if (Result <> -1) and
                   (Equation[CurChar] in ['a'..'d', '0', '1', '(']) then
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
        dest:integer;
        i:integer;

begin {ComputeBtnClick}

    Equation :=  LowerCase(LogEqn.Text) + chr(0);

    { Remove any spaces present in the string }

    dest := 1;
    for i := 1 to length(Equation) do
    	if (Equation[i] <> ' ') then begin

        	Equation[dest] := Equation[i];
                dest := dest + 1;

        end;

    { Okay, see if this string is syntactically legal.	}

    CurChar := 1;	{Start at position 1 in string	}

    if (Parse(0,0,0,0) <> -1) then
     if (Equation[CurChar] = chr(0)) then begin

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
        OptEqn;
    	LogEqn.Color := clWindow;
        RestoreMap;

    end
    else LogEqn.Color := clRed
   else LogEqn.Color := clRed;


end;


end.
