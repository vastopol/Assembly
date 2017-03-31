unit Eqnentry;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, SysUtils, LogicEV, Help1;

type
  TEqnDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    InputEqn: TEdit;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure InputEqnChange(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var

  LastEqn:string;
  EqnDlg: TEqnDlg;




procedure DrawTruths(var TTbl:TruthType);


implementation


var
   thisTruth:TruthType;

{$R *.DFM}




{ RmvBlanks- Removes all spaces from a string.	}

procedure RmvBlanks(var Equation:string);
var dest:integer;
    i:integer;

begin

    dest := 1;
    for i := 1 to length(Equation) do
    	if (Equation[i] <> ' ') then begin

        	Equation[dest] := Equation[i];
                dest := dest + 1;

        end;

end;




{ DrawTruths- This procedure takes a truth table as a parameter and 	}
{ draws that truth table on the CREATE page.  Zero variable functions	}
{ produce a blank truth table, one-variable functions produce a 1x2	}
{ truth table, two-variable functions produce a 2x2 table, three-	}
{ variable functions produce a 2x4 table, and four-variable functions	}
{ produce a 4x4 table.							}

procedure DrawTruths(var TTbl:TruthType);
var
    i,j,
    a,b,c,d,
    Clk		:integer;

    { ToDigit converts the integer value at the given spot in the truth	}
    { table to a '0' or '1' character and returns this character.	}

    function ToDigit(clk,d,c,b,a:integer):char;
    begin

    	result := chr(ord('0') + TTbl.tt[clk,d,c,b,a]);

    end;

begin {DrawTruth}

	{Initialize all the truth table labels to spaces.  We will fill	}
        {in the necessary ones later.					}

	with LogicEval do begin

            ba00.Caption := '';
            ba01.Caption := '';
            ba10.Caption := '';
            ba11.Caption := '';

            dc00.Caption := '';
            dc01.Caption := '';
            dc10.Caption := '';
            dc11.Caption := '';

            dc200.Caption := '';
            dc201.Caption := '';
            dc210.Caption := '';
            dc211.Caption := '';

        end;

        { Clear all the labels in the truth table.  For functions with	}
        { less than four variables, the unused squares need to be blank.}
        { We will fill in the non-blank ones later.			}

        for clk := 0 to 1 do
          for a:= 0 to 1 do
            for b := 0 to 1 do
              for c := 0 to 1 do
                for d := 0 to 1 do
                begin

                	tt[clk,d,c,b,a].Caption := '';

                end;

        { Okay, fill in the truth tables and attach appropriate labels	}
        { down here.  Since functions of different numbers of variables	}
        { each produce completely different truth tables, the following	}
        { case statement divides up the work depending on the number	}
        { of variables in the function.					}

	case TTbl.NumVars of

        { Handle functions of a single variable here.  Produce a 1x2	}
        { truth table.							}

        1:  begin

        	for Clk := 0 to 1 do
                  for a := 0 to 1 do
                    tt[Clk,0,0,0,a].Caption := ToDigit(Clk,0,0,0,a);

                with LogicEval do begin

                    ba00.Caption := ' ' + TTbl.theVars[0] + '''';
                    ba01.Caption := ' ' + TTbl.theVars[0];

                end;

            end;

        { Handle functions of two variables here, producing a 2x2	}
        { truth table.  Note that this code swaps the B and C variables	}
        { in the actual truth table to get a 2x2 format rather than a	}
        { 1x4 format.							}

        2:  begin

        	for clk := 0 to 1 do
                  for a:= 0 to 1 do
                    for b:= 0 to 1 do
                      tt[clk,0,b,0,a].Caption := ToDigit(clk,0,0,b,a);

                with LogicEval do begin

                    ba00.Caption := ' ' + TTbl.theVars[0] + '''';
                    ba01.Caption := ' ' + TTbl.theVars[0];

                    dc00.Caption := ' ' + TTbl.theVars[1] + '''';
                    dc01.Caption := ' ' + TTbl.theVars[1];

                    dc200.Caption := ' ' + TTbl.theVars[1] + '''';
                    dc201.Caption := ' ' + TTbl.theVars[1];

                end;

            end;


        { Process three-variable functions down here.  This code pro-	}
        { duces a 2x4 truth table.					}

        3:  begin

        	for clk := 0 to 1 do
                  for c := 0 to 1 do
                    for b := 0 to 1 do
                      for a := 0 to 1 do
                      begin

                    	tt[clk,0,c,b,a].Caption := ToDigit(clk,0,c,b,a);

                      end;

                with LogicEval do begin

                    ba00.Caption := TTbl.theVars[1] + '''' +
                    			TTbl.theVars[0] + '''';
                    ba01.Caption := TTbl.theVars[1] + '''' +
                    			TTbl.theVars[0];
                    ba10.Caption := TTbl.theVars[1] +
                    			TTbl.theVars[0] + '''';
                    ba11.Caption := TTbl.theVars[1] +
                    			TTbl.theVars[0];

                    dc00.Caption := ' ' + TTbl.theVars[2] + '''';
                    dc01.Caption := ' ' + TTbl.theVars[2];

                    dc200.Caption := ' ' + TTbl.theVars[2] + '''';
                    dc201.Caption := ' ' + TTbl.theVars[2];

                end;


            end;


        { Produce a 4x4 truth table for functions of four variables.	}

        4:  begin

        	for clk := 0 to 1 do
                  for d := 0 to 1 do
                    for c := 0 to 1 do
                      for b := 0 to 1 do
                      	for a := 0 to 1 do
                        begin

                    		tt[clk,d,c,b,a].Caption :=
                                		ToDigit(clk,d,c,b,a);

                        end;

                with LogicEval do begin

                    ba00.Caption := TTbl.theVars[1] + '''' +
                    			TTbl.theVars[0] + '''';
                    ba01.Caption := TTbl.theVars[1] + '''' +
                    			TTbl.theVars[0];
                    ba10.Caption := TTbl.theVars[1] +
                    			TTbl.theVars[0] + '''';
                    ba11.Caption := TTbl.theVars[1] +
                    			TTbl.theVars[0];

                    dc00.Caption := TTbl.theVars[3] + '''' +
                    			TTbl.theVars[2] + '''';
                    dc01.Caption := TTbl.theVars[3] + '''' +
                    			TTbl.theVars[2];
                    dc10.Caption := TTbl.theVars[3] +
                    			TTbl.theVars[2] + '''';
                    dc11.Caption := TTbl.theVars[3] +
                    			TTbl.theVars[2];

                    dc200.Caption := TTbl.theVars[3] + '''' +
                    			TTbl.theVars[2] + '''';
                    dc201.Caption := TTbl.theVars[3] + '''' +
                    			TTbl.theVars[2];
                    dc210.Caption := TTbl.theVars[3] +
                    			TTbl.theVars[2] + '''';
                    dc211.Caption := TTbl.theVars[3] +
                    			TTbl.theVars[2];

                end;


            end;

        end;

end;



{ ParseEqn-	This function checks to see if an equation input by the	}
{		user is syntactically correct.  If not, this function	}
{		returns false.  If so, this function constructs the	}
{		truth table for the equation by evaluating the function	}
{		for all possible values of the clock, a, b, c, and d.	}

function ParseEqn:boolean;
var
    a,b,c,d,
    clk,
    i		:integer;
    CurChar	:integer;
    Equation	:string;
    TruthVars	: set of char;


    { Parse- Parses the "Equation" string and evaluates it.	}
    { Returns true if expression is legal, returns		}
    { false if the equation is syntactically incorrect.		}
    {								}
    { Grammar:							}
    {		S -> X + S | X					}
    {		X -> YX | Y					}
    {		Y -> Y' | Z					}
    {		Z -> a .. z | # | ( S )				}

    function S:boolean;

    	function X:boolean;
        var dummy:boolean;

        	function Y:boolean;

                	function Z:boolean;
                        begin

                            case (Equation[CurChar]) of

                            { The following case handles parenthesized	}
                            { expressions.				}

                            '(': begin

                            	inc(CurChar); { Skip the parenthesis.	}
                                Result := S;  { Check internal expr.	}

                                { Be sure the expression ends with a	}
                                { closing parenthesis.			}

                                if (Equation[CurChar] <> ')') then
                                	Result := false
                                else	inc(CurChar);

                            end;


                            { If this term is a variable name, we need	}
                            { check a couple of things.  First of all,	}
                            { equations cannot have more than four dif-	}
                            { ferent variables.  The TruthVars set con-	}
                            { tains the variables found in the equation	}
                            { up to this point.  If the current vari-	}
                            { able is not in this set, add it to the	}
                            { set and bump the variable counter by one.	}
                            { If the variable is already in the set,	}
                            { then we've already counted it towards our	}
                            { maximum of four variables.		}
                            { We return true if we haven't exceeded our	}
                            { four variable maximum.			}

                            'A'..'Z': begin

                                if (not (Equation[CurChar] in TruthVars)) then
                                begin

                                    thisTruth.theVars[thisTruth.NumVars]:=
                                	Equation[CurChar];
                                    TruthVars := TruthVars +
                                    			[Equation[CurChar]];
                                    Result := thisTruth.NumVars < 4;
                                    if Result then inc(thisTruth.NumVars);

                                end
                                else Result := true;
                            	inc(CurChar);

                            end;


                            { The clock value ("#") and the zero and	}
                            { one constants do not need any special	}
                            { handling.  Just skip over them and return	}
                            { true as the function result.		}

                            '#','0','1': begin

                            	Result := true;
                                Inc(CurChar);

                            end;

                            { If not one of the above symbols, we've	}
                            { got an illegal symbol in the equation.	}
                            { Return an error if this occurs.		}

                            else Result := false;

                            end;
                        end;

                { Y handles all sub-expressions of the form <var>'.	}

                begin {Y}

                    { Note: This particular operation is left recursive	}
                    { and would require considerable grammar transform-	}
                    { ation to repair.  However, a simple trick is to	}
                    { note that the result would have tail recursion	}
                    { which we can solve iteratively rather than recur-	}
                    { sively.  Hence the while loop in the following	}
                    { code.						}

                    Result := Z;
                    while (Result) and (Equation[CurChar] = '''') do
                        inc(CurChar);

                end;

        { X handles all subexpressions containing concatenated values	}
        { (i.e., logical AND operations).				}

        begin {X}

        	Result := Y;
		if Result and
                   (Equation[CurChar] in ['A'..'Z','0','1','#','(']) then
                	result := X;

        end;


    { S handles all general expressions and, in particular, those tak-	}
    { ing the form <var> + <var>.					}

    begin {S}

    	Result := X;
        if Result and (Equation[CurChar] = '+') then
        begin

        	inc(CurChar);
        	Result := S;
        end;

    end;




    { These functions actually process an equation in order to	}
    { generate the appropriate truth tables. The grammar is the	}
    { same as the above, this code simply has sematic rules to	}
    { actually compute results.					}

    function E(a,b,c,d,clk:integer; Ach, Bch, Cch, Dch:char):integer;

    	function F:integer;

        	function G:integer;

                	function H:integer;
                        var ch:char;
                        begin

                        	ch := Equation[CurChar];
                                case (ch) of

                		'(': begin

                                	inc(CurChar);
                                        Result := E(a,b,c,d,clk,
                                        	    Ach, Bch, Cch, Dch);
                                        inc(CurChar);

                                     end;

                                'A'..'Z': begin

                                	if (ch = Ach) then
                                           Result := a
                                        else if (ch = Bch) then
                                           Result := b
                                        else if (ch = Cch) then
                                           Result := c
                                        else if (ch = Dch) then
                                           Result := d;
                                        inc(CurChar);

                                     end;

                                '#':  begin

                                        Result := clk;
                                	Inc(CurChar);

                                     end;


                                '0':  begin

                                        Result := 0;
                                	Inc(CurChar);

                                     end;


                                '1': begin

                                        Result := 1;
                                	Inc(CurChar);

                                     end;

                                end;
                        end;

                begin {G}

                    Result := H;
                    while (Equation[CurChar] = '''') do
                    begin

                        inc(CurChar);
                        Result := Result xor 1;

                    end;

                end;

        begin {F}


        	Result := G;
                if (Equation[CurChar] in ['A'..'Z', '(', '#', '0','1']) then
                	Result := Result and F;	{YX case}
        end;

    begin {E}

    	Result := F;
        if (Equation[CurChar] = '+') then
        begin

        	inc(CurChar);
        	Result := Result or E(a,b,c,d,clk,
                			Ach, Bch, Cch, Dch);
        end;

    end;





    { Swap swaps characters in the "theVars" array.  ParseEqn uses this	}
    { function when it sorts the "theVars" array.			}

    procedure swap(pos1,pos2:integer);
    var
        ch:char;
    begin

    	ch := thisTruth.theVars[pos1];
        thisTruth.theVars[pos1] := thisTruth.theVars[pos2];
        thisTruth.theVars[pos2] := ch;

    end;


begin {ParseEqn}

    { Note that the input equation only contains uppercase characters	}
    { at this point.  The code calling this function has seen to that.	}
    { This statement appends a zero byte to the end of the string	}
    { for use as a sentinel value.					}

    Equation :=  EqnDlg.InputEqn.Text + chr(0);

    { Remove any spaces present in the string }

    RmvBlanks(Equation);

    { Some truth table initialization before we parse this equation:	}

    thisTruth.NumVars := 0;
    TruthVars := [];


    { At a minimum, the equation must have four characters: "F=A" plus	}
    { a zero terminating byte.  If it has fewer than four characters,	}
    { it cannot possibly be correct.					}

    if (length(Equation) < 4) then
    begin

    	MessageDlg(
            'Syntax error, functions take the form "<var> = <expr>".',
            mtWarning, [mbok], 0);
        result := false;
        exit;

    end

    { Functions must take the form "<var> = <expr>".			}

    else if (Equation[2] <> '=') or not (Equation[1] in ['A'..'Z', '#']) then
    begin

    	MessageDlg(
            'Syntax error, functions take the form "<var> = <expr>".',
            mtWarning, [mbok], 0);
        result := false;
        exit;

    end

    { Variables A..D and "#" are read-only, no functions can redefine	}
    { them.  Check that here.						}

    else if (Equation[1] in ['A'..'D','#']) then
    begin

    	MessageDlg(
            'A-D and # are read-only and may not appear to the left of "=".',
            mtWarning, [mbok], 0);
        result := false;
        exit;

    end

    { Okay, now all that's left to check is the expression.		}

    else begin

        { Set up the variable array.  Fill the fifth element with the	}
        { name of the function we are defining.				}

    	for i := 0 to 3 do thisTruth.theVars[i] := chr(0);
    	thisTruth.theVars[4] := Equation[1];

        { Start just past the "<var>=" portion of the equation and	}
        { check to see if this equation is syntactically correct.	}

    	CurChar := 3;
	Result := S;

        { If we've got too may variables, complain about that here.	}

        if (thisTruth.NumVars > 4) then
        begin

           MessageDlg('Too many variables in equation (max=4).',
                      mtWarning, [mbok], 0);
           result := false;

        end

        { Be sure there's no junk at the end of the equation.  If we're	}
        { currently pointing at the sentinel character (the zero byte)	}
        { then we've processed the entire equation.  If not, then there	}
        { is junk at the end of the equation and we need to complain	}
        { about this.							}

        else if (Equation[CurChar] <> chr(0))then
        begin

           MessageDlg('Syntax Error', mtWarning, [mbok], 0);
           result := false;

        end;


        if not Result then exit;


        { Sort the array of characters used in this truth table.  This	}
        { is a simple unrolled bubble sort of four elements.		}

        with thisTruth do begin

        	if (NumVars >= 2) then
                begin

                    if theVars[0] > theVars[1] then swap(0,1);

                    if (NumVars >= 3) then
                    begin

                    	if theVars[1] > theVars[2] then swap(1,2);
        		if theVars[0] > theVars[1] then swap(0,1);

                        if (NumVars = 4) then
                        begin

                	    if theVars[2] > theVars[3] then swap(2,3);
                            if theVars[1] > theVars[2] then swap(1,2);
                            if theVars[0] > theVars[1] then swap(0,1);

                        end;
                    end;
                end;



                { Evaluate the function for all possible values of Clk,	}
                { A, B, C, and D.  Store the results away into the	}
                { truth tables.						}

                for Clk := 0 to 1 do
                  for a := 0 to 1 do
                    for b := 0 to 1 do
                      for c := 0 to 1 do
                        for d := 0 to 1 do
                        begin

                          CurChar := 3;
                          tt[Clk,d,c,b,a] := e(a,b,c,d,Clk,
                          			theVars[0],
                                                theVars[1],
                                                theVars[2],
                                                theVars[3]);
                        end;


                { After building the truth tables, draw them.		}

                DrawTruths(thisTruth);

        end;


    end;

end;








{ If the user presses the OKAY button, then we need to parse the func-	}
{ tion the user has entered and, if it's correct, build the truth table	}
{ for that function.							}

procedure TEqnDlg.OKBtnClick(Sender: TObject);
var
   ii:  integer;
   ch:	char;
begin

    { Convert all the characters in the equation to upper case.		}

    InputEqn.Text := UpperCase(InputEqn.Text);

    { Get the name of the function we are defining.			}

    ch := InputEqn.Text[1];



    with LogicEval do begin

       { See if this function is syntactically correct.  If it is, then	}
       { ParseEqn also constructs the truth table for the equation.	}

       if (not ParseEqn) then
       begin

            messagebeep($ffff);
            InputEqn.Color := clRed;

       end
       else begin

	  InputEqn.Color := clWhite;

          { EqnSet is the set of all function names we're defined up to	}
          { this point.  If the current function name is in this set,	}
          { then the user has just entered a name of a pre-existing	}
          { function.  Ask the user if they want to replace the exist-	}
          { ing function with the new one.				}

          if (ch in EqnSet) then
          begin

              if MessageDlg('Okay to replace existing function?',
                      mtWarning, [mbYes, mbNo], 0) = mrYes then
              begin

                { Search for the equation in the equation list.		}

                ii := 0;
                while (EqnList.Items[ii][1] <> ch) do inc(ii);

                { Replace the equation and its truth table.		}

              	EqnList.Items[ii] := InputEqn.Text;
              	TruthTbls[thisTruth.theVars[4]] := thisTruth;

              end

              { If the user elected not to replace the function, set	}
              { thisTruth to the original truth table so we will draw	}
              { the correct truth table (the original one) when we exit.}

              else begin

               	thisTruth := TruthTbls[InputEqn.Text[1]];

              end;

          end

          { If this isn't a duplicate function definition, enter the	}
          { new function into the system down here.			}

          else begin

              LastEqn := InputEqn.Text;
              TruthTbls[ch] := thisTruth;
              EqnSet := EqnSet + [ch];
              EqnList.Items.add(LastEqn);

          end;

          { Draw the truth table and close the equation editor dialog box. }

          DrawTruths(thisTruth);
          EqnDlg.Close;

       end;

    end;

end;


{ If the user presses the cancel button, close the equation editor	}
{ dialog box and restore the default equation to the last equation	}
{ entered in the editor (rather than the junk that is in there now).	}

procedure TEqnDlg.CancelBtnClick(Sender: TObject);
begin

     InputEqn.Text := LastEqn;
     Close;

end;


{ If there was a syntax error, the equation input box will have a red	}
{ background.  The moment the user changes the equation the following	}
{ code will restore a white background.					}

procedure TEqnDlg.InputEqnChange(Sender: TObject);
begin

     InputEqn.Color := clWhite;

end;



procedure TEqnDlg.HelpBtnClick(Sender: TObject);
begin
	HelpBox.Show;
end;



end.
