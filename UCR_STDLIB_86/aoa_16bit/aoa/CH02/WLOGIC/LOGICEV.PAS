unit Logicev;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, VBXCtrl, Switch, StdCtrls, Buttons, TabNotBk,
  Grids, About;

type
  TLogicEval = class(TForm)
    Screens: TTabbedNotebook;

    A: TBiSwitch;	{ Input Switches on EXECUTE form.	}
    B: TBiSwitch;
    C: TBiSwitch;
    D: TBiSwitch;

    W: TShape;		{ Four LEDs on EXECUTE form.		}
    X: TShape;
    Y: TShape;
    Z: TShape;
    WLbl: TLabel;	{Labels on the LEDs.			}
    XLbl: TLabel;
    YLbl: TLabel;
    ZLbl: TLabel;
    E: TShape;
    F: TShape;
    G: TShape;
    I: TShape;
    J: TShape;
    H: TShape;
    K: TShape;
    SevenSeg: TPanel;
    ExecVariables: TStringGrid;

    EqnList: TListBox;		{ List of equations on execute page.	}

    AInit: TGroupBox;		{ "Buttons" on the INIT page.		}
    BInit: TGroupBox;
    CInit: TGroupBox;
    DInit: TGroupBox;
    EInit: TGroupBox;
    FInit: TGroupBox;
    GInit: TGroupBox;
    Hinit: TGroupBox;
    IInit: TGroupBox;
    Jinit: TGroupBox;
    KInit: TGroupBox;
    LInit: TGroupBox;
    MInit: TGroupBox;
    NInit: TGroupBox;
    OInit: TGroupBox;
    PInit: TGroupBox;
    QInit: TGroupBox;
    RInit: TGroupBox;
    SInit: TGroupBox;
    TInit: TGroupBox;
    UInit: TGroupBox;
    VInit: TGroupBox;
    WInit: TGroupBox;
    XInit: TGroupBox;
    YInit: TGroupBox;
    ZInit: TGroupBox;

    AValue: TLabel;		{ Values displayed on the "INIT" page.	}
    BValue: TLabel;
    CValue: TLabel;
    DValue: TLabel;
    EValue: TLabel;
    FValue: TLabel;
    GValue: TLabel;
    HValue: TLabel;
    IValue: TLabel;
    JValue: TLabel;
    KValue: TLabel;
    LValue: TLabel;
    MValue: TLabel;
    NValue: TLabel;
    OValue: TLabel;
    PValue: TLabel;
    QValue: TLabel;
    RValue: TLabel;
    SValue: TLabel;
    TValue: TLabel;
    UValue: TLabel;
    VValue: TLabel;
    WValue: TLabel;
    XValue: TLabel;
    YValue: TLabel;
    ZValue: TLabel;


    Exit: TButton;	{ Various buttons appearing on the forms.	}
    ExitBtn1: TButton;
    ExitBtn: TButton;
    AboutBtn1: TButton;
    AboutBtn2: TButton;
    AboutBtn3: TButton;
    AddEqnBtn: TButton;
    DeleteBtn: TButton;
    EditBtn: TButton;
    PrintBtn: TButton;
    PrintBtn2: TButton;
    PrintBtn3: TButton;
    PulseBtn: TBitBtn;

    PrintDialog: TPrintDialog;
    InstabilityAnnunc: TPanel;

    tt30: TPanel;	{ Squares in the truth table on the create page	}
    tt31: TPanel;
    tt32: TPanel;
    tt33: TPanel;
    tt00: TPanel;
    tt01: TPanel;
    tt02: TPanel;
    tt03: TPanel;
    tt10: TPanel;
    tt20: TPanel;
    tt11: TPanel;
    tt12: TPanel;
    tt13: TPanel;
    tt21: TPanel;
    tt22: TPanel;
    tt23: TPanel;

    ctt00: TPanel;
    ctt10: TPanel;
    ctt20: TPanel;
    ctt30: TPanel;
    ctt01: TPanel;
    ctt02: TPanel;
    ctt03: TPanel;
    ctt11: TPanel;
    ctt12: TPanel;
    ctt13: TPanel;
    ctt21: TPanel;
    ctt22: TPanel;
    ctt23: TPanel;
    ctt31: TPanel;
    ctt32: TPanel;
    ctt33: TPanel;


    ba00: TLabel;	{Labels on the truth table.			}
    ba01: TLabel;
    ba10: TLabel;
    ba11: TLabel;
    dc00: TLabel;
    DC01: TLabel;
    DC10: TLabel;
    DC11: TLabel;
    dc211: TLabel;
    dc210: TLabel;
    dc201: TLabel;
    dc200: TLabel;

    RBrace1: TLabel;
    ClkLbl1: TLabel;
    RBrace2: TLabel;
    ClkLbl2: TLabel;

    InitInstrsLbl: TLabel;
    Instrs2: TLabel;
    ExecEqns: TMemo;

    procedure COn(Sender: TObject);
    procedure COff(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AOff(Sender: TObject);
    procedure AOn(Sender: TObject);
    procedure BOff(Sender: TObject);
    procedure BOn(Sender: TObject);
    procedure DOff(Sender: TObject);
    procedure DOn(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure AboutBtn2Click(Sender: TObject);
    procedure InitClick(Sender: TObject);
    procedure AddEqnBtnClick(Sender: TObject);
    procedure ValueClick(Sender: TObject);
    procedure EqnListClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure EqnListDblClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ScreensChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure PulseBtnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;



  { TruthType-	Data type that holds the binary information of a truth	}
  {		table.  NumVars is the number of variables that provide	}
  {		indexes into this truth table.  theVars[0..3] are the	}
  {		single character variable names used in this function.	}
  {		theVars[4] is where the function stores its result.	}
  {		tt[clk,d,c,b,a] is the actual truth table.		}

  TruthType = record
  		NumVars:integer;
                theVars:array [0..4] of char;
                tt:array [0..1,0..1,0..1,0..1,0..1] of integer;

  	      end;
var
  LogicEval: TLogicEval;

  { tt is an array of pointers to the panels that make up the squares	}
  { of the truth table on the create page.  It provides a convenient	}
  { way to access those panels using array notation.			}

  tt: array [0..1, 0..1, 0..1, 0..1, 0..1] of TPanel;

  { TruthTbls holds the truth tables for each of the functions the	}
  { user defines on the Create page.					}

  TruthTbls: array ['A'..'Z'] of TruthType;

  { EqnSet holds the set of variables that have been defined and for	}
  { which truth tables exist.						}

  EqnSet: set of char;









implementation

{$R *.DFM}

uses EqnEntry;


type
   variables= array ['@'..'['] of integer;

var

   { Values holds the current values of all the variables in the system	}
   { Values2 is an array of pointers that point at the labels that	}
   { display each of the values on the initialization page.		}

   Values:	variables;
   Values2:	array ['@'..'['] of TLabel;





{ FormCreate does all the initialization when the program starts.	}

procedure TLogicEval.FormCreate(Sender: TObject);
var i:integer;
    ch:char;

begin


     { Label all the variables on the EXECUTE page.  Also, set their	}
     { values all to zero.						}

     for i := 1 to 26 do
     begin

         ExecVariables.Cells[i,0] := chr(ord('@') + i);
         ExecVariables.Cells[i,1] := '0';

     end;
     ExecVariables.Cells[0,0] := '#';
     ExecVariables.Cells[0,1] := '0';

     { Initialize all the variable values to zero.			}

     for ch := '@' to '[' do Values[ch] := 0;

     { At this point there are no equations defined.  Note that here.	}

     EqnSet := [];

     { Initialize the array of Value pointers so they point at the	}
     { value labels on the initialization page.				}

     Values2['A'] := AValue;
     Values2['B'] := BValue;
     Values2['C'] := CValue;
     Values2['D'] := DValue;
     Values2['E'] := EValue;
     Values2['F'] := FValue;
     Values2['G'] := GValue;
     Values2['H'] := HValue;
     Values2['I'] := IValue;
     Values2['J'] := JValue;
     Values2['K'] := KValue;
     Values2['L'] := LValue;
     Values2['M'] := MValue;
     Values2['N'] := NValue;
     Values2['O'] := OValue;
     Values2['P'] := PValue;
     Values2['Q'] := QValue;
     Values2['R'] := RValue;
     Values2['S'] := SValue;
     Values2['T'] := TValue;
     Values2['U'] := UValue;
     Values2['V'] := VValue;
     Values2['W'] := WValue;
     Values2['X'] := XValue;
     Values2['Y'] := YValue;
     Values2['Z'] := ZValue;


     { Initialize the tt array so that each element points at the	}
     { appropriate square on the truth table on the CREATE page.	}

     tt[0, 0,0,0,0]:= tt00;
     tt[0, 0,0,0,1]:= tt01;
     tt[0, 0,0,1,0]:= tt02;
     tt[0, 0,0,1,1]:= tt03;

     tt[0, 0,1,0,0]:= tt10;
     tt[0, 0,1,0,1]:= tt11;
     tt[0, 0,1,1,0]:= tt12;
     tt[0, 0,1,1,1]:= tt13;

     tt[0, 1,0,0,0]:= tt20;
     tt[0, 1,0,0,1]:= tt21;
     tt[0, 1,0,1,0]:= tt22;
     tt[0, 1,0,1,1]:= tt23;

     tt[0, 1,1,0,0]:= tt30;
     tt[0, 1,1,0,1]:= tt31;
     tt[0, 1,1,1,0]:= tt32;
     tt[0, 1,1,1,1]:= tt33;


     tt[1, 0,0,0,0]:= ctt00;
     tt[1, 0,0,0,1]:= ctt01;
     tt[1, 0,0,1,0]:= ctt02;
     tt[1, 0,0,1,1]:= ctt03;

     tt[1, 0,1,0,0]:= ctt10;
     tt[1, 0,1,0,1]:= ctt11;
     tt[1, 0,1,1,0]:= ctt12;
     tt[1, 0,1,1,1]:= ctt13;

     tt[1, 1,0,0,0]:= ctt20;
     tt[1, 1,0,0,1]:= ctt21;
     tt[1, 1,0,1,0]:= ctt22;
     tt[1, 1,0,1,1]:= ctt23;

     tt[1, 1,1,0,0]:= ctt30;
     tt[1, 1,1,0,1]:= ctt31;
     tt[1, 1,1,1,0]:= ctt32;
     tt[1, 1,1,1,1]:= ctt33;

     { Initialize the default equation for the equation editor.		}

     LastEqn := 'F=0';

     { Make the CREATE page show up on the form when we start.		}

     Screens.ActivePage := 'Create';

end;



{ The following procedure stores "Value" into the variable specified by	}
{ "vName".  It also updates the variable display and any necessary LEDs	}
{ on the EXECUTE page.							}

procedure SetVar(vName:char; Value:integer);
begin

  with LogicEval do begin

     { Convert "#" to "@" so we can use a compact array ("@" appears	}
     { just before "A" in the ASCII character set, "#" is some distance	}
     { away from the alphabetic characters).				}

     if (vName = '#') then vName := '@';

     { Update the value in the Values matrix and the label on the init-	}
     { ialization page.							}

     Values [vName] := Value;
     Values2[vName].Caption := chr(Value+ord('0'));

     { Update the value on the EXECUTE page.				}

     ExecVariables.Cells[ord(vName)-ord('@'),1] :=
           chr(ord('0') + Value);

     { If this variable is E..K, then update the corresponding segment	}
     { on the seven-segment display.					}

     if (vName = 'E') then
        if (Value = 1) then E.Brush.Color := clRed
        else E.Brush.Color := clSilver;

     if (vName = 'F') then
        if (Value = 1) then F.Brush.Color := clRed
        else F.Brush.Color := clSilver;

     if (vName = 'G') then
        if (Value = 1) then G.Brush.Color := clRed
        else G.Brush.Color := clSilver;

     if (vName = 'H') then
        if (Value = 1) then H.Brush.Color := clRed
        else H.Brush.Color := clSilver;

     if (vName = 'I') then
        if (Value = 1) then I.Brush.Color := clRed
        else I.Brush.Color := clSilver;

     if (vName = 'J') then
        if (Value = 1) then J.Brush.Color := clRed
        else J.Brush.Color := clSilver;

     if (vName = 'K') then
        if (Value = 1) then K.Brush.Color := clRed
        else K.Brush.Color := clSilver;


     { If this variable is W..Z, then update the corresponding LED.	}

     if (vName = 'W') then
        if (Value = 1) then W.Brush.Color := clRed
        else W.Brush.Color := clWhite;

     if (vName = 'X') then
        if (Value = 1) then X.Brush.Color := clRed
        else X.Brush.Color := clWhite;

     if (vName = 'Y') then
        if (Value = 1) then Y.Brush.Color := clRed
        else Y.Brush.Color := clWhite;

     if (vName = 'Z') then
        if (Value = 1) then Z.Brush.Color := clRed
        else Z.Brush.Color := clWhite;

  end;
end;




{ The following function evaluates the system of logic equations.	}

procedure Eval;
var
    i		:integer;
    funcCount	:integer;
    CurVar	:char;
    prevVals	:variables;



 { CmpVars-	Compares two arrays of type "variables" and returns	}
 {		true if they are equal.					}

 function CmpVars(var v1, v2:Variables):boolean;
 assembler;
 asm
        	push	ds
		les	di, v2
                lds	si, v1
                mov	cx, 27
                repe cmpsw
                mov	ax, 1
                cmp	cx, 0
                je	@@0
                mov	ax, 0
        @@0:
                pop	ds
 end;


 { EvalOnce-	Evaluates all the active logic equations one time each.	}
 {		This function returns the number of active logic equa-	}
 {		tions in the system.  Note that for a complete logic 	}
 {		system evaluation, that is, to allow values to propogate}
 {		throughout the system of equations, you must evaluate	}
 {		the set of equations at least n times where "n" is the	}
 {		number of logic equations in the system.		}

 function EvalOnce:integer;
 var
     funcName:	char;
     val:	integer;

 begin

  Result := 0;

  { The following loop, in conjunction with the IF stmt, executes once	}
  { for each active equation in the system.				}

  for funcName := 'A' to 'Z' do
    if funcName in EqnSet then
    begin

      { The following case statement handles the case where the current	}
      { equation has zero, one, two, three, or four variables.  It com-	}
      { putes the new value by using a lookup based on the current vari-}
      { able values.							}

      case TruthTbls[funcName].NumVars of
      0: val := TruthTbls[funcName].tt[Values['@'],0,0,0,0];
      1: val := TruthTbls[funcName].tt[Values['@'],0,0,0,
                			Values[TruthTbls[funcName].theVars[0]]];
      2: val := TruthTbls[funcName].tt[Values['@'],0,0,
                			Values[TruthTbls[funcName].theVars[1]],
                			Values[TruthTbls[funcName].theVars[0]]];
      3: val := TruthTbls[funcName].tt[Values['@'],0,
                			Values[TruthTbls[funcName].theVars[2]],
                			Values[TruthTbls[funcName].theVars[1]],
                			Values[TruthTbls[funcName].theVars[0]]];
      4: val := TruthTbls[funcName].tt[Values['@'],
                			Values[TruthTbls[funcName].theVars[3]],
                			Values[TruthTbls[funcName].theVars[2]],
                			Values[TruthTbls[funcName].theVars[1]],
                			Values[TruthTbls[funcName].theVars[0]]];
      end;

      { Update the current function's variable with the value obtained above. }

      Values[funcName] := val;

      { Count the number of functions we've processed down here. }

      inc(Result);

    end;
 end;




begin {Eval}

    { Call EvalOnce to obtain the number of functions in the system.	}
    { Bump this value by one since we've got the clock variable to worry}
    { about, as well.							}

    funcCount := EvalOnce + 1;


    { Evaluate the system of equations "funcCount" times.  This gives	}
    { us a total of "n+2" evaluations where "n" is the number of funcs.	}
    { The first extra execution is for the clock variable, the second	}
    { extra execution provides a safety margin.				}

    for i := 1 to funcCount do EvalOnce;

    { Now let's check for instability.  Save the current set of values	}
    { and execute the set of equations one more time.  If the system is	}
    { stable, we should obtain the exact same set of values.  If the	}
    { system is unstable, they will differ.				}

    prevVals := Values;
    EvalOnce;

    { If the system is unstable, turn on the Instability annunciator.	}
    { If the system is stable, turn the annunciator off.		}

    if CmpVars(prevVals,Values) then
    	 LogicEval.InstabilityAnnunc.Color := clGray
    else LogicEval.InstabilityAnnunc.Color := clRed;

    { Throughout the operations above, EvalOnce stored results directly	}
    { into the Values array rather than (correctly) calling SetVar. The	}
    { reason is because EvalOnce would call SetVar a tremendous number	}
    { of times and SetVar is rather slow.  Therefore, we need to call	}
    { SetVar once for each variable to ensure that all LEDs, display	}
    { values, etc., are properly updated.				}

    for CurVar := '@' to 'Z' do
    	SetVar(CurVar,Values[CurVar]);

end;






{ The following procedures handle button toggle events.  Whenever the	}
{ user toggles one of the four input values (A..D) the following pro-	}
{ cedures adjust the values of the corresponding variables and then	}
{ they evaluate the system of logic equations.				}

procedure TLogicEval.AOff(Sender: TObject);
begin
     SetVar('A',0);
     Eval;
end;

procedure TLogicEval.AOn(Sender: TObject);
begin
     SetVar('A',1);
     Eval;
end;

procedure TLogicEval.BOff(Sender: TObject);
begin
     SetVar('B',0);
     Eval;
end;

procedure TLogicEval.BOn(Sender: TObject);
begin
     SetVar('B',1);
     Eval;
end;

procedure TLogicEval.COn(Sender: TObject);
begin
     SetVar('C',1);
     Eval;
end;

procedure TLogicEval.COff(Sender: TObject);
begin
     SetVar('C',0);
     Eval;
end;

procedure TLogicEval.DOff(Sender: TObject);
begin
     SetVar('D',0);
     Eval;
end;

procedure TLogicEval.DOn(Sender: TObject);
begin
     SetVar('D',1);
     Eval;
end;


{ If the user hits the "Pulse" button, set the clock to zero and eval-	}
{ uate the system, set the clock to one and evaluate the system, and 	}
{ then set the clock back to zero and reevaluate the equations.		}

procedure TLogicEval.PulseBtnClick(Sender: TObject);
begin

    Values['@'] := 0;
    Eval;
    Values['@'] := 1;
    Eval;
    Values['@'] := 0;
    Eval;

end;


{ The system calls the following functions whenever the user clicks on	}
{ one of the buttons on the initialization page.  This code figures	}
{ out which button was pressed and toggles its value.  The InitClick	}
{ procedure runs whenever the user clicks on the panel (button), the	}
{ ValueClick procedure runs if the users clicks on the actual value	}
{ within the panel.							}

procedure TLogicEval.InitClick(Sender: TObject);
var name:char;
begin

   {The first character of the Box's Caption is the variable's name.	}

   name := (Sender as TGroupBox).Caption[1];

   { Fetch that variable's value, invert it, and write it back.		}

   SetVar(Name, Values[name] xor 1);

end;

procedure TLogicEval.ValueClick(Sender: TObject);
var name:char;
begin

   name := ((Sender as TLabel).Parent as TGroupBox).Caption[1];
   SetVar(Name, Values[name] xor 1);

end;




{ If the user presses the "ADD" button, bring up the equation dialog	}
{ box and let them add a new equation to the system.			}

procedure TLogicEval.AddEqnBtnClick(Sender: TObject);
begin

     EqnDlg.InputEqn.SelectAll;	{Select equation inside dialog box.	}
     EqnDlg.Show;		{Open the equation dialog box.		}

end;


{ If the user clicks on an equation in the equation list box, update	}
{ the truth table on the create page to display the truth table for	}
{ the selected equation.						}

procedure TLogicEval.EqnListClick(Sender: TObject);
var ch:char;
begin

    if (EqnList.ItemIndex <> -1) then {Make sure there is a selection.	}
    begin

        ch := EqnList.Items[EqnList.ItemIndex][1]; {Get function name.	}
	DrawTruths(TruthTbls[ch]); {Draw that function's truth table.	}

    end;

end;


{ If the user double-clicks on an equation in the equation list box,	}
{ then bring up the equation editor dialog box and let them edit this	}
{ equation.								}

procedure TLogicEval.EqnListDblClick(Sender: TObject);
begin

	if (EqnList.ItemIndex <> -1) then {Is there a selection?	}
        begin

            { Grab the equation the user just selected and make it the	}
            { default equation in the equation dialog box.		}

            EqnDlg.InputEqn.Text := EqnList.Items[EqnList.ItemIndex];

            { Select the equation.					}

            EqnDlg.InputEqn.SelectAll;

            { Bring up the equation editor dialog box.			}

            EqnDlg.Show;

        end;
end;


{ If the user presses the edit button and there is a selected equation	}
{ in the equation list box, open up the equation editor dialog box and	}
{ let the user edit that equation.					}

procedure TLogicEval.EditBtnClick(Sender: TObject);
begin

	{ If there is a selected equation, copy it to the default	}
        { equation in the equation editor dialog box.  If there is no	}
        { such equation available, just use the current default equa-	}
        { tion when it opens the equation editor dialog box.		}

	if (EqnList.Items.Count <> 0) then   {Are there any equations?	}
           if (EqnList.ItemIndex <> -1) then {Is an equation selected?	}
               EqnDlg.InputEqn.Text := EqnList.Items[EqnList.ItemIndex];

        { Select the equation and open up the dialog box.		}

        EqnDlg.InputEqn.SelectAll;
        EqnDlg.Show;

end;


{ If the user has selected and equation and presses the delete button,	}
{ the following procedure deletes that equation from the list and re-	}
{ moves that function definition from the EqnSet.			}

procedure TLogicEval.DeleteBtnClick(Sender: TObject);
var 	ch:	char;
	dummy:	TruthType;
begin

	if (EqnList.ItemIndex <> -1) then {Is there an equation selected? }
        begin

            { Make sure the user really wants to do this. }

            if MessageDlg('Okay to delete ' +
            		EqnList.Items[EqnList.ItemIndex] + '?',
                      mtWarning, [mbYes, mbNo], 0) = mrYes then
            begin

            	{ Remove the equation from our equation set.		}

        	EqnSet := EqnSet - [EqnList.Items[EqnList.ItemIndex][1]];

                { Remove the equation from the list of equations.	}

                EqnList.Items.Delete(EqnList.ItemIndex);

                { Since there is no longer a selected equation in the	}
                { equation list, clear the truth tables.		}

                dummy.NumVars := 0;
                DrawTruths(dummy);

            end;

        end;
end;


{ Miscellaneous procedures to handle the PRINT, ABOUT, and EXIT buttons	}
{ found on each page of the form.					}

procedure TLogicEval.PrintBtnClick(Sender: TObject);
begin

	if (PrintDialog.Execute) then
        begin

        	LogicEval.Print;

        end;

end;

procedure TLogicEval.ExitBtnClick(Sender: TObject);
begin
     Halt;
end;

procedure TLogicEval.AboutBtn2Click(Sender: TObject);
begin
     AboutBox.Show;
end;


procedure TLogicEval.ScreensChange(	Sender: TObject;
					NewTab: Integer;
  					var AllowChange: Boolean);
var
    i:	integer;
begin

	AllowChange := true;
        if NewTab = 2 then
        begin

            ExecEqns.Clear;
            for i := 0 to EqnList.Items.Count - 1 do
            	ExecEqns.Lines.Add(EqnList.Items[i]);

            Eval;

        end;
end;

end.
