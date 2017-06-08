unit Simx86p;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Patterns, Menus, StdCtrls, TabNotBk, ExtCtrls, VBXCtrl,
  Switch, Spin, GetInput, Printers;

type

  TMem = array [0..$ffef] of byte;
  TMemPtr = ^TMem;

  TSIMx86Form = class(TForm)
    Simx86Pages: TTabbedNotebook;
    SourceCode: TMemo;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Edit: TMenuItem;
    New: TMenuItem;
    Open: TMenuItem;
    Save: TMenuItem;
    SaveAs: TMenuItem;
    Cut: TMenuItem;
    Copy: TMenuItem;
    Paste: TMenuItem;
    Delete: TMenuItem;
    EditBreak: TMenuItem;
    BeforeQuit: TMenuItem;
    PrintMenuItem: TMenuItem;
    SelectAll: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    StartAdrs: TEdit;
    StartAdrsLbl: TLabel;
    ASMbtn: TButton;

    Mem01: TEdit;
    Mem02: TEdit;
    Mem03: TEdit;
    Mem04: TEdit;
    Mem05: TEdit;
    Mem00: TEdit;
    Mem06: TEdit;
    Mem07: TEdit;

    AdrsEntry: TEdit;
    Label0: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Lbl8: TLabel;
    Lbl10: TLabel;
    Lbl18: TLabel;
    Lbl20: TLabel;
    Lbl28: TLabel;
    Lbl30: TLabel;
    Lbl38: TLabel;
    Mem10: TEdit;
    Mem11: TEdit;
    Mem12: TEdit;
    Mem13: TEdit;
    Mem14: TEdit;
    Mem15: TEdit;
    Mem16: TEdit;
    Mem17: TEdit;
    Mem27: TEdit;
    Mem26: TEdit;
    Mem25: TEdit;
    Mem24: TEdit;
    Mem23: TEdit;
    Mem22: TEdit;
    Mem21: TEdit;
    Mem20: TEdit;
    Mem30: TEdit;
    Mem31: TEdit;
    Mem32: TEdit;
    Mem33: TEdit;
    Mem34: TEdit;
    Mem35: TEdit;
    Mem36: TEdit;
    Mem37: TEdit;
    Mem47: TEdit;
    Mem46: TEdit;
    Mem45: TEdit;
    Mem44: TEdit;
    Mem43: TEdit;
    Mem42: TEdit;
    Mem41: TEdit;
    Mem40: TEdit;
    Mem50: TEdit;
    Mem51: TEdit;
    Mem52: TEdit;
    Mem53: TEdit;
    Mem54: TEdit;
    Mem55: TEdit;
    Mem56: TEdit;
    Mem57: TEdit;
    Mem67: TEdit;
    Mem66: TEdit;
    Mem65: TEdit;
    Mem64: TEdit;
    Mem63: TEdit;
    Mem62: TEdit;
    Mem61: TEdit;
    Mem60: TEdit;
    Mem70: TEdit;
    Mem71: TEdit;
    Mem72: TEdit;
    Mem73: TEdit;
    Mem74: TEdit;
    Mem75: TEdit;
    Mem76: TEdit;
    Mem77: TEdit;
    IntVect: TEdit;
    IntVectLbl: TLabel;
    ResetVectLbl: TLabel;
    ResetVect: TEdit;
    Label8: TLabel;
    DisAsm: TListBox;
    Output: TListBox;
    InPort0: TBiSwitch;
    InPort2: TBiSwitch;
    InPort4: TBiSwitch;
    InPort6: TBiSwitch;
    OutPort8: TShape;
    OutPortA: TShape;
    OutPortC: TShape;
    OutPortE: TShape;
    FFF8Lbl: TLabel;
    FFFALbl: TLabel;
    FFFCLbl: TLabel;
    FFFELbl: TLabel;
    RunBtn: TButton;
    StepBtn: TButton;
    HaltBtn: TButton;
    InterruptBtn: TButton;
    OutputLbl: TLabel;
    RunningLite: TPanel;
    AXValue: TEdit;
    AXLbl: TLabel;
    BXValue: TEdit;
    DXValue: TEdit;
    CXValue: TEdit;
    IPValue: TEdit;
    BXLbl: TLabel;
    CXLbl: TLabel;
    DXLbl: TLabel;
    IPLbl: TLabel;
    Instruction: TLabel;
    DisAsmAdrs: TEdit;
    EqualFlag: TCheckBox;
    LessThanFlag: TCheckBox;
    ResetBtn: TButton;
    Input: TListBox;
    InputLbl: TLabel;
    SpinButton: TSpinButton;
    ClrMemBtn: TButton;
    PrintDialog: TPrintDialog;
    N1: TMenuItem;
    Quit: TMenuItem;

    procedure QuitClick(Sender: TObject);
    procedure CutClick(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure NewClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure HexChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AdrsEntryChange(Sender: TObject);
    procedure StartAdrsChange(Sender: TObject);
    procedure ASMbtnClick(Sender: TObject);
    procedure Simx86PagesChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure ClrMemBtnClick(Sender: TObject);
    procedure DisAsmAdrsChange(Sender: TObject);
    procedure SpinButtonDownClick(Sender: TObject);
    procedure SpinButtonUpClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RunBtnClick(Sender: TObject);
    procedure HaltBtnClick(Sender: TObject);
    procedure InterruptBtnClick(Sender: TObject);
    procedure IntVectChange(Sender: TObject);
    procedure IPValueChange(Sender: TObject);
    procedure StepBtnClick(Sender: TObject);
    procedure PrintMenuItemClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  SIMx86Form: TSIMx86Form;
  MemEntry: array[0..7,0..7] of TEdit;






implementation

type

    TSymPtr = ^TSym;

    TSym = record
             value:word;
             defined:boolean;
           end;




const
	MaxCodeAdrs = 4095;

var

  HasOpcode:Boolean;
  Opcode:word;
  HasReg:Boolean;
  RegCode:word;
  HasOperand:Boolean;
  OperandCode:word;
  HasValue:Boolean;
  OperandValue:word;
  StoreMem:boolean;

  Halted:boolean;
  Running:boolean;
  PendingInt:boolean;
  InInt:boolean;
  IntAdrs:word;

  Val:byte;

  AX: word;
  BX: word;
  CX: word;
  DX: word;
  IP: word;

  LineNum:integer;
  Adrs:word;
  MemAdrs:word;
  MemWS:integer;
  AbortAsm:Boolean;
  NoError:Boolean;
  Memory: TMemPtr;
  SymTbl: array ['A'..'Z'] of TSym;


  SaveAX:word;
  SaveBX:word;
  SaveCX:word;
  SaveDX:word;
  SaveIP:word;
  SaveEqual:boolean;
  SaveLess:boolean;

  Reg:byte;
  RegMem:byte;
  Operation:byte;
  InstrSize:word;

  Op1:^word;
  Op2v:word;
  offset:word;

  Filename:string;







{$F+}
function ProcessLbl(Pat:TPatPtr):boolean; forward;
function GetLbl(Pat:TPatPtr):boolean; forward;
function ConvertHex(Pat:TPatPtr):boolean; forward;

procedure SetJmp(Pat:TPatPtr); forward;
procedure SetJa(Pat:TPatPtr); forward;
procedure SetJae(Pat:TPatPtr); forward;
procedure SetJb(Pat:TPatPtr); forward;
procedure SetJbe(Pat:TPatPtr); forward;
procedure SetJe(Pat:TPatPtr); forward;
procedure SetJne(Pat:TPatPtr); forward;

procedure SetNot(Pat:TPatPtr); forward;
procedure SetAnd(Pat:TPatPtr); forward;
procedure SetOr(Pat:TPatPtr); forward;
procedure SetCmp(Pat:TPatPtr); forward;
procedure SetSub(Pat:TPatPtr); forward;
procedure SetAdd(Pat:TPatPtr); forward;
procedure SetMovReg(Pat:TPatPtr); forward;
procedure SetMovMem(Pat:TPatPtr); forward;


procedure SetIret(Pat:TPatPtr); forward;
procedure SetHalt(Pat:TPatPtr); forward;
procedure SetBrk(Pat:TPatPtr); forward;
procedure SetPut(Pat:TPatPtr); forward;
procedure SetGet(Pat:TPatPtr); forward;

procedure SetAX(Pat:TPatPtr); forward;
procedure SetBX(Pat:TPatPtr); forward;
procedure SetCX(Pat:TPatPtr); forward;
procedure SetDX(Pat:TPatPtr); forward;

procedure SetAX2(Pat:TPatPtr); forward;
procedure SetBX2(Pat:TPatPtr); forward;
procedure SetCX2(Pat:TPatPtr); forward;
procedure SetDX2(Pat:TPatPtr); forward;

procedure SetBXInd(Pat:TPatPtr); forward;
procedure SetBXIndx(Pat:TPatPtr); forward;
procedure SetABS(Pat:TPatPtr); forward;
procedure SetImm(Pat:TPatPtr); forward;


{$F-}

const

     { WS1- Matches a string containing one or more white-   }
     {      space characters.                                }

     WS1:TPattern = (mf:OneOrMoreCset; m:(cset:[' ',#9]);
                     Next:NIL; Alt:NIL; Success:NIL);

     { WS0- Matches a string containing zero or more white-  }
     {      space characters.                                }

     WS0:TPattern=(mf:SpanCset; m:(cset:[' ',#9]);
                      Next:NIL; Alt:NIL; Success:NIL);


     { A Pattern that matches whitespace at the end of a line }

     SkipToEOS:TPattern=(mf:EOS; m:(ch:' ');
                       Next:NIL; Alt:NIL; Success:NIL);

     WSeoln:TPattern=(mf:SpanCset; m:(cset:[' ',#9]);
                       Next:@SkipToEOS; Alt:NIL; Success:NIL);



     { Match an x86 register mode here.                       }


     TryDX:Tpattern=(mf:Matchistr; m:(str:'DX');
                        Next:NIL; Alt:NIL; Success:SetDX);

     TryCX:Tpattern=(mf:Matchistr; m:(str:'CX');
                        Next:NIL; Alt:@TryDX; Success:SetCX);

     TryBX:Tpattern=(mf:Matchistr; m:(str:'BX');
                        Next:NIL; Alt:@TryCX; Success:SetBX);

     TryReg:Tpattern=(mf:Matchistr; m:(str:'AX');
                        Next:NIL; Alt:@TryBX; Success:SetAX);


     { Match an x86 addressing mode here                     }

     TryImm:TPattern=( mf:ConvertHex; m:(ch:' ');
                      Next:@WSEoln; Alt:NIL; Success:SetImm);

     TryDX2:Tpattern=(mf:Matchistr; m:(str:'DX');
                        Next:@WSeoln; Alt:@TryImm; Success:SetDX2);

     TryCX2:Tpattern=(mf:Matchistr; m:(str:'CX');
                        Next:@WSeoln; Alt:@TryDX2; Success:SetCX2);

     TryBX2:Tpattern=(mf:Matchistr; m:(str:'BX');
                        Next:@WSeoln; Alt:@TryCX2; Success:SetBX2);

     TryReg2:Tpattern=(mf:Matchistr; m:(str:'AX');
                        Next:@WSeoln; Alt:@TryBX2; Success:SetAX2);



     BXBrack:TPattern=( mf:MatchChar; m:(ch:']');
                      Next:NIL; Alt:NIL; Success:NIL);

     BXBrackWS:TPattern=( mf:SpanCset; m:(cset:[' ',#9]);
                      Next:@BXBrack; Alt:NIL; Success:NIL);

     BXEnd:TPattern=( mf:MatchiStr; m:(str:'BX');
                      Next:@BXBrackWS; Alt:NIL; Success:NIL);

     TryABS:TPattern=( mf:Succeed; m:(ch:' ');
                       Next:@BXBrackWS; Alt:NIL; Success:SetABS);

     BXPlus:TPattern=( mf:MatchChar; m:(ch:'+');
                      Next:@BXEnd; Alt:@TryABS; Success:SetBXIndx);

     BXPlusWS:TPattern=( mf:SpanCset; m:(cset:[' ',#9]);
                      Next:@BXPlus; Alt:NIL; Success:NIL);

     BXIndex:TPattern=( mf:ConvertHex; m:(ch:' ');
                        Next:@BXPlusWS; Alt:@BXEnd; Success:NIL);


     BXBracket:TPattern=( mf:MatchiStr; m:(str:'BX');
                          Next:@BXBrackWS; Alt:@BXIndex; Success:SetBXInd);


     BXIndWS:TPattern=(mf:SpanCset; m:(cset:[' ',#9]);
                      Next:@BXBracket; Alt:NIL; Success:NIL);

     DoMem:TPattern=( mf:MatchChar; m:(ch:'[');
                      Next:@BXIndWS; Alt:@TryReg2; Success:NIL);


     { Generic Two-operand instructions }

     TryOr:TPattern=(mf:MatchiStr; m:(str:'OR');
                        Next:NIL; Alt:NIL; Success:SetOr);

     TryAnd:TPattern=(mf:MatchiStr; m:(str:'AND');
                        Next:NIL; Alt:@TryOr; Success:SetAnd);

     TryCmp:TPattern=(mf:MatchiStr; m:(str:'CMP');
                        Next:NIL; Alt:@TryAnd; Success:SetCmp);

     TrySub:TPattern=(mf:MatchiStr; m:(str:'SUB');
                        Next:NIL; Alt:@TryCmp; Success:SetSub);

     TryAdd:TPattern=( mf:MatchiStr; m:(str:'ADD');
                       Next:NIL; Alt:@TrySub; Success:SetAdd);



     { Handle label definitions at the beginning of the line    }

     Lbl:TPattern=(mf:ProcessLbl; m:(ch:' ');
                   Next:NIL; Alt:NIL; Success:NIL);



     { A statement may be one of the following:                 }
     {                                                          }
     {       1: A Blank Line.                                   }
     {       2: An optional label in column 1 followed by an    }
     {          instruction.                                    }
     {       3: Whitespace followed by an instruction.          }
     {       4: An instruction starting in column 1.            }
     {                                                          }
     { The following patterns match one of the above.           }

     { Zero-Operand Instructions here: }


     TryBrk:TPattern=( mf:MatchiStr; m:(str:'BRK');
                      Next:@WSeoln; Alt:NIL; Success:SetBrk);

     TryIRet:TPattern=( mf:MatchiStr; m:(str:'IRET');
                      Next:@WSeoln; Alt:@TryBrk; Success:SetIret);

     TryHalt:TPattern=( mf:MatchiStr; m:(str:'HALT');
                      Next:@WSeoln; Alt:@TryIRet; Success:SetHalt);

     TryPut:TPattern=( mf:MatchiStr; m:(str:'PUT');
                      Next:@WSeoln; Alt:@TryHalt; Success:SetPut);

     TryGet:TPattern=( mf:MatchiStr; m:(str:'GET');
                      Next:@WSeoln; Alt:@TryPut; Success:SetGet);

     { Jump Instructions here: }

     JmpLbl2:TPattern=(mf:GetLbl; m:(ch:' ');
                        Next:NIL; Alt:NIL; Success:NIL);

     JmpLbl:TPattern=(mf:OneOrMoreCset; m:(cset:[' ',#9]);
                        Next:@JmpLbl2; Alt:NIL; Success:NIL);

     TryJne:TPattern=(mf:MatchiStr; m:(str:'JNE');
                        Next:@JmpLbl; Alt:@TryGet; Success:SetJne);

     TryJe:TPattern=(mf:MatchiStr; m:(str:'JE');
                        Next:@JmpLbl; Alt:@TryJne; Success:SetJe);

     TryJb:TPattern=(mf:MatchiStr; m:(str:'JB');
                        Next:@JmpLbl; Alt:@TryJe; Success:SetJb);

     TryJbe:TPattern=(mf:MatchiStr; m:(str:'JBE');
                        Next:@JmpLbl; Alt:@TryJb; Success:SetJbe);

     TryJa:TPattern=(mf:MatchiStr; m:(str:'JA');
                        Next:@JmpLbl; Alt:@TryJbe; Success:SetJa);

     TryJae:TPattern=(mf:MatchiStr; m:(str:'JAE');
                        Next:@JmpLbl; Alt:@TryJa; Success:SetJae);

     TryJmp:TPattern=(mf:MatchiStr; m:(str:'JMP');
                        Next:@JmpLbl; Alt:@TryJae; Success:SetJmp);



     { not reg/mem here: }

     GenMemMode:TPattern=( mf:MatchSub; m:(Pat:@DoMem);
                          Next:@WSeoln; Alt:NIL; Success:NIL);


     NotWS:TPattern=(mf:SpanCset; m:(cset:[' ',#9]);
                     Next:@GenMemMode; Alt:NIL; Success:NIL);

     TryNotInstr:TPattern=( mf:MatchiStr; m:(str:'NOT');
                           Next:@NotWS; Alt:@TryJmp; Success:SetNot);



     { instr reg, mem here: }

     WSComma2:TPattern=( mf:SpanCset; m:(cset:[' ',',',#9]);
                         Next:@GenMemMode; Alt:NIL; Success:NIL);

     GenRegMem:TPattern=(mf:MatchSub; m:(Pat:@TryReg);
                     Next:@WSComma2; Alt:NIL; Success:NIL);

     InstrWS:TPattern=(mf:SpanCset; m:(cset:[' ',#9]);
                     Next:@GenRegMem; Alt:NIL; Success:NIL);

     TryGeneric:TPattern=( mf:MatchSub; m:(Pat:@TryAdd);
                           Next:@InstrWS; Alt:@TryNotInstr; Success:NIL);



     { mov mem, reg here: }

     MovReg:TPattern=(mf:MatchSub; m:(Pat:@TryReg);
                     Next:@WSeoln; Alt:NIL; Success:SetMovMem);

     WSComma3:TPattern=( mf:SpanCset; m:(cset:[' ',',',#9]);
                       Next:@MovReg; Alt:NIL; Success:NIL);

     MemReg:TPattern=( mf:MatchSub; m:(Pat:@DoMem);
                       Next:@WSComma3; Alt:NIL; Success:NIL);


     { mov reg, mem here: }

     MemMode:TPattern=( mf:MatchSub; m:(Pat:@DoMem);
                       Next:@WSeoln; Alt:NIL; Success:SetMovReg);

     WSComma:TPattern=( mf:SpanCset; m:(cset:[' ',',',#9]);
                       Next:@MemMode; Alt:NIL; Success:NIL);

     RgMem:TPattern=(mf:MatchSub; m:(Pat:@TryReg);
                     Next:@WSComma; Alt:@MemReg; Success:NIL);

     { Generic mov here: }

     MovWS:TPattern=(mf:SpanCset; m:(cset:[' ',#9]);
                     Next:@RgMem; Alt:NIL; Success:NIL);

     TryMnemonic:TPattern=(mf:MatchiStr; m:(str:'MOV');
                      Next:@MovWS; Alt:@TryGeneric; Success:NIL);




     TryEOS:TPattern=(mf:EOS; m:(ch:' ');
                      Next:NIL; Alt:@TryMnemonic; Success:NIL);

     TryWS:TPattern =(mf:SpanCset; m:(cset:[' ',#9]);
                      Next:@TryEOS; Alt:NIL; Success:NIL);

     stmt:TPattern = (mf:MatchSub; m:(Pat:@Lbl);
                      Next:@TryMnemonic; Alt:@TryWS; Success:NIL);








{ System initialization }


procedure TSIMx86Form.FormCreate(Sender: TObject);
var 	i:	word;
	ch:	char;
begin


    { Allocate Storage for the x86 memory space }

    system.new(Memory);

    { Zero out the allocated memory }

    for i := 0 to $ffef do
    	Memory^[i] := 0;

    MemAdrs := 0;
    MemWS := 0;
    IntAdrs := $FFFF;
    Adrs := 0;
    AX := 0;
    BX := 0;
    CX := 0;
    DX := 0;
    IP := 0;

    MemEntry[0,0] := Mem00;
    MemEntry[0,1] := Mem01;
    MemEntry[0,2] := Mem02;
    MemEntry[0,3] := Mem03;
    MemEntry[0,4] := Mem04;
    MemEntry[0,5] := Mem05;
    MemEntry[0,6] := Mem06;
    MemEntry[0,7] := Mem07;

    MemEntry[1,0] := Mem10;
    MemEntry[1,1] := Mem11;
    MemEntry[1,2] := Mem12;
    MemEntry[1,3] := Mem13;
    MemEntry[1,4] := Mem14;
    MemEntry[1,5] := Mem15;
    MemEntry[1,6] := Mem16;
    MemEntry[1,7] := Mem17;

    MemEntry[2,0] := Mem20;
    MemEntry[2,1] := Mem21;
    MemEntry[2,2] := Mem22;
    MemEntry[2,3] := Mem23;
    MemEntry[2,4] := Mem24;
    MemEntry[2,5] := Mem25;
    MemEntry[2,6] := Mem26;
    MemEntry[2,7] := Mem27;

    MemEntry[3,0] := Mem30;
    MemEntry[3,1] := Mem31;
    MemEntry[3,2] := Mem32;
    MemEntry[3,3] := Mem33;
    MemEntry[3,4] := Mem34;
    MemEntry[3,5] := Mem35;
    MemEntry[3,6] := Mem36;
    MemEntry[3,7] := Mem37;

    MemEntry[4,0] := Mem40;
    MemEntry[4,1] := Mem41;
    MemEntry[4,2] := Mem42;
    MemEntry[4,3] := Mem43;
    MemEntry[4,4] := Mem44;
    MemEntry[4,5] := Mem45;
    MemEntry[4,6] := Mem46;
    MemEntry[4,7] := Mem47;

    MemEntry[5,0] := Mem50;
    MemEntry[5,1] := Mem51;
    MemEntry[5,2] := Mem52;
    MemEntry[5,3] := Mem53;
    MemEntry[5,4] := Mem54;
    MemEntry[5,5] := Mem55;
    MemEntry[5,6] := Mem56;
    MemEntry[5,7] := Mem57;

    MemEntry[6,0] := Mem60;
    MemEntry[6,1] := Mem61;
    MemEntry[6,2] := Mem62;
    MemEntry[6,3] := Mem63;
    MemEntry[6,4] := Mem64;
    MemEntry[6,5] := Mem65;
    MemEntry[6,6] := Mem66;
    MemEntry[6,7] := Mem67;

    MemEntry[7,0] := Mem70;
    MemEntry[7,1] := Mem71;
    MemEntry[7,2] := Mem72;
    MemEntry[7,3] := Mem73;
    MemEntry[7,4] := Mem74;
    MemEntry[7,5] := Mem75;
    MemEntry[7,6] := Mem76;
    MemEntry[7,7] := Mem77;

    { See if there were any command-line parameters }

    if (ParamCount = 1) then
    begin

        SourceCode.Lines.LoadFromFile(ParamStr(1));
        Filename := ParamStr(1);

    end
    else Filename := '';


end;






(****************************************************************************)


{$R *.DFM}


{ Read a byte from memory.  Also handles memory-mapped I/O (locations	}
{ $FFF0.$FFFF are memory-mapped I/O locations).				}
{									}
{ $FFF0 (bit 0)-	Switch zero.					}
{ $FFF2 (bit 0)-	Switch one.					}
{ $FFF4 (bit 0)-	Switch two.					}
{ $FFF6 (bit 0)-	Switch three.					}
{ 	All other bit positions return zero in the above words.		}
{									}
{	Locations $FFF8..$FFFF are write-only locations and return	}
{	random garbage.							}

function ReadMem(adrs:word):byte;
begin

	if (adrs < $fff0) then Result := Memory^[adrs]
        else begin

            with SIMx86Form do begin

        	if (Adrs = $fff0) then Result := ord(Inport0.pOn)
                else if (Adrs = $fff2) then Result := ord(Inport2.pOn)
                else if (Adrs = $fff4) then Result := ord(Inport4.pOn)
                else if (Adrs = $fff6) then Result := ord(Inport6.pOn)
                else if (Adrs = $fff1) or (Adrs=$FFF3) or
                	(Adrs = $fff5) or (Adrs=$fff7) then Result := 0;

            end;

        end;

end;



{ WriteMem-	Write a byte to memory.  Note that locations	}
{		$FFF0..$FFFF are memory mapped I/O locations	}
{		and must be handled specially.  Only the low-	}
{		order bit of locations $FFF8, $FFFA, $FFFC, and	}
{		$FFFE are active outputs;  these bits cor-	}
{		respond to the four LEDs.  The other memory-	}
{		mapped I/O locations ignore data written to them}

procedure WriteMem(Adrs:word; Value:word);
begin

	if (Adrs < $fff0) then
        	Memory^[Adrs] := Value
        else begin

            with SIMx86Form do begin

        	if (Adrs = $fff8) then
                	if (odd(Value)) then Outport8.Brush.Color := clRed
                        else Outport8.Brush.Color := clWhite
                else if (Adrs = $fffa) then
                	if (odd(Value)) then OutportA.Brush.Color := clRed
                        else OutportA.Brush.Color := clWhite
                else if (Adrs = $fffC) then
                	if (odd(Value)) then OutportC.Brush.Color := clRed
                        else OutportC.Brush.Color := clWhite
                else if (Adrs = $fffe) then
                	if (odd(Value)) then OutportE.Brush.Color := clRed
                        else OutportE.Brush.Color := clWhite;

            end;
        end;

end;



{ Print an error message dialog box for the assembler. }

procedure ErrorMsg(const msg, Stmt:string);
begin

     AbortAsm := MessageDlg(msg+': '+Stmt,
                            mtWarning,[mbOK, mbCancel],0) = mrCancel;
     NoError := false;

end;


{ The following function converts a string of characters representing a	}
{ hexadecimal number into the binary equivalent.			}

function HexToWord(const s:string):word;
var i:integer;
begin

     Result := 0;
     for i := 1 to length(s) do
         if (s[i] in ['0'..'9']) then
            Result := (Result shl 4) + ord(s[i]) - ord('0')
         else
            Result := (Result shl 4) + ord(upcase(s[i])) -
                              ord('A') + 10;
end;




{ CheckHex-	This procedure checks a TEdit object to see if its text	}
{		field contains a valid hexadecimal value.  It turns the	}
{		background red if invalid.				}

procedure CheckHex(var s:TEdit);
var i:integer;
begin

    s.Color := clWindow;
    for i := 1 to length(s.Text) do
    	if not (s.Text[i] in ['0'..'9','A'..'F','a'..'f']) then
        begin

           s.Color := clRed;
           MessageBeep($FFFF);

        end;

end;






{$F+}

{ Whenever the assembler encounters a label at the beginning of a line,	}
{ the following function checks to see if it is a legal label and adds	}
{ it to the symbol table along with its address.  It also backpatches	}
{ any previous references to that symbol if there are any.		}

function ProcessLbl(Pat:TPatPtr):boolean;
var id:	char;
    i,
    tmp:word;
begin

     id :=upcase(Pat^.EndPattern^);

     { See if this is a legal label }

     if (id in ['A'..'Z']) and ((Pat^.EndPattern+1)^ = ':') then
     begin

     	  {See if this symbol is already in the symbol table.	}

          if SymTbl[id].Defined then
          begin

             ErrorMsg('Duplicate Identifier',
                   SIMx86Form.SourceCode.lines[LineNum]);

          end
          else begin

               { See if this symbol was used already.	}
               { If so, we need to backpatch some	}
               { addresses in memory.			}

               if (SymTbl[id].Value <> 0) then
               begin

                  i := SymTbl[id].Value;
                  repeat

                   	tmp := Memory^[i] + (Memory^[i+1] shl 8);
                   	Memory^[i] := Adrs and $ff;
                        Memory^[i+1] := Adrs shr 8;
                        i := tmp;

                   until i = 0;

               end;

               { Put all the necessary information into the symbol table. }

               SymTbl[id].Defined := true;
               SymTbl[id].Value := adrs;
               Result := true;

               { Skip over any white space following this label. }

               Pat^.EndPattern := Pat^.EndPattern + 2;
               While (Pat^.EndPattern^ in [' ',#9]) do
                     inc(Pat^.EndPattern);

          end;


     end
     else Result := false;

end;


{ ConvertHex-	Converts the text field of a PChar object into a binary	}
{		value and return true if the result is successful.	}
{		This routine shoves the binary result into the global	}
{		variable OperandValue.  The assembler uses this func	}
{		to process hexadecimal instruction operands.		}

function ConvertHex(Pat:TPatPtr):Boolean;
var i:integer;
begin

     OperandValue := 0;
     Result := Pat^.EndPattern^ in ['0'..'9', 'a'..'f', 'A'..'F'];
     HasValue := true;
     while (Pat^.EndPattern^ in ['0'..'9', 'a'..'f', 'A'..'F']) do
     begin

         if (Pat^.EndPattern^  in ['0'..'9']) then
            OperandValue := (OperandValue shl 4) +
            		     ord(Pat^.EndPattern^) - ord('0')
         else
            OperandValue := ( OperandValue shl 4) +
            		      ord(upcase(Pat^.EndPattern^ )) -
                              ord('A') + 10;

         inc(Pat^.EndPattern);

     end;
end;



{ GetLbl-	The assembler uses this function to process labels it	}
{		finds in the operand field of a jump instruction.	}

function GetLbl(Pat:TPatPtr):boolean;
var id:char;
begin

     id :=upcase(Pat^.EndPattern^);
     Result := false;

     { If the operand begins with a decimal digit, it's a hexadecimal	}
     { number, not a label.						}

     if (id in ['0'..'9']) then
     begin

        HasValue := ConvertHex(Pat);
        while (Pat^.EndPattern^ in [' ',#9]) do inc(Pat^.EndPattern);
        Result := Pat^.EndPattern^ = #0;

     end

     { If the operand begins with an alphabetic character, then we've	}
     { got a label.							}

     else if (id in ['A'..'Z']) then
     begin

     	  HasValue := true;
     	  if (not SymTbl[id].Defined) then
          begin

          	{ If the symbol is not defined yet, create a linked }
                { list of undefined items for this symbol.	    }

          	OperandValue := SymTbl[id].Value;
                SymTbl[id].Value := adrs+1;

          end
          else OperandValue := SymTbl[id].Value;

          repeat

                inc(Pat^.EndPattern);

          until not (Pat^.EndPattern^ in [' ',#9]);
          Result := Pat^.EndPattern^ = #0;

     end
     else begin

          ErrorMsg('Expected label operand',
                   SIMx86Form.SourceCode.lines[LineNum]);

     end;


end;







{ The assembler calls the following procedure whenever it encounters	}
{ the corresponding procedure or operand.  These procedures set up the	}
{ global opcode and operand values so the assembler can emit the ap-	}
{ propriate object code later.						}

Procedure SetJmp(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $6;

end;

Procedure SetJa(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $4;

end;

Procedure SetJae(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $5;

end;

Procedure SetJb(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $2;

end;

Procedure SetJbe(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $3;

end;

Procedure SetJe(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $0;

end;

Procedure SetJne(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $8;
     HasOperand := true;
     OperandCode := $1;

end;


Procedure SetNot(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $10;

end;

Procedure SetOr(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $20;

end;

Procedure SetAnd(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $40;

end;

Procedure SetCmp(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $60;

end;

Procedure SetSub(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $80;

end;

Procedure SetAdd(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $A0;

end;

Procedure SetMovReg(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $C0;

end;

Procedure SetMovMem(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $E0;

end;

Procedure SetBRK(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $0;
     HasOperand := true;
     OperandCode := $3;

end;

Procedure SetIret(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $0;
     HasOperand := true;
     OperandCode := $4;

end;

Procedure SetHalt(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $0;
     HasOperand := true;
     OperandCode := $5;

end;

Procedure SetPut(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $0;
     HasOperand := true;
     OperandCode := $7;

end;

Procedure SetGet(Pat:TPatPtr);
begin

     HasOpcode := True;
     Opcode := $0;
     HasReg := true;
     RegCode := $0;
     HasOperand := true;
     OperandCode := $6;

end;




Procedure SetAX(Pat:TPatPtr);
begin

     HasReg := True;
     Regcode := $00;

end;

Procedure SetBX(Pat:TPatPtr);
begin

     HasReg := True;
     Regcode := $08;

end;

Procedure SetCX(Pat:TPatPtr);
begin

     HasReg := True;
     Regcode := $10;

end;

Procedure SetDX(Pat:TPatPtr);
begin

     HasReg := True;
     Regcode := $18;

end;




Procedure SetAX2(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $00;

end;

Procedure SetBX2(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $1;

end;

Procedure SetCX2(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $2;

end;

Procedure SetDX2(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $3;

end;

Procedure SetBXInd(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $4;

end;

Procedure SetBXIndx(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $5;

end;

Procedure SetABS(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $6;

end;

Procedure SetImm(Pat:TPatPtr);
begin

     HasOperand := True;
     Operandcode := $7;

end;

{$F-}













{ Whenever the user presses the CLEAR button on the memory page, the	}
{ following method zeros out memory.					}

procedure TSIMx86Form.ClrMemBtnClick(Sender: TObject);
var i:word;
begin

    AdrsEntry.Text := '0000';
    AdrsEntryChange(AdrsEntry);

    { Zero out memory }

    for i := 0 to $ffef do
    	Memory^[i] := 0;

    MemAdrs := 0;
    Adrs := 0;

end;




{ Handle the NEW, OPEN, SAVE, SAVEAS, Print, and QUIT entries in the File Menu }

procedure TSIMx86Form.QuitClick(Sender: TObject);
begin

	Application.Terminate;

end;



procedure TSIMx86Form.PrintMenuItemClick(Sender: TObject);
var
    i: integer;
    f: TextFile;

begin

    if PrintDialog.Execute then begin

      if (SIMx86Pages.PageIndex = 0) then begin

    	AssignPrn(f);
        Rewrite(f);

	for i := 0 to SourceCode.Lines.Count-1 do
        	writeln(f,SourceCode.Lines[i]);

        CloseFile(f);

      end
      else Print;

    end;

end;



procedure TSIMx86Form.NewClick(Sender: TObject);
begin

    SourceCode.Clear;
    Filename := '';

end;

procedure TSIMx86Form.OpenClick(Sender: TObject);
var
    name:string;

begin

    if OpenDialog.Execute then
    begin

        SourceCode.Lines.LoadFromFile(OpenDialog.Filename);
        Filename := OpenDialog.Filename;

    end;

end;

procedure TSIMx86Form.SaveAsClick(Sender: TObject);
begin

    if SaveDialog.Execute then
    begin

    	FileName := SaveDialog.Filename;
    	SourceCode.Lines.SaveToFile(SaveDialog.Filename);

    end;

end;

procedure TSIMx86Form.SaveClick(Sender: TObject);
begin

    if (Filename = '') then
    begin
    	if SaveDialog.Execute then
           Filename := SaveDialog.Filename;

    end;

    if (Filename <> '') then
    begin

    	SourceCode.Lines.SaveToFile(Filename);

    end;



end;




{ Handle Cut, Copy, Paste, Delete, and SelectAll in the Edit Menu }

procedure TSIMx86Form.CutClick(Sender: TObject);
begin

    SourceCode.CutToClipBoard;

end;

procedure TSIMx86Form.CopyClick(Sender: TObject);
begin

	SourceCode.CopyToClipBoard;

end;

procedure TSIMx86Form.PasteClick(Sender: TObject);
begin

    SourceCode.PasteFromClipBoard;

end;

procedure TSIMx86Form.DeleteClick(Sender: TObject);
begin

    SourceCode.ClearSelection;

end;

procedure TSIMx86Form.SelectAllClick(Sender: TObject);
begin

    SourceCode.SelectAll;
    SourceCode.Repaint;

end;




{ Whenver a value changes in one of the memory data entry boxes, this	}
{ method converts the data data to hexadecimal and stores the resulting	}
{ value away into memory.						}

procedure TSIMx86Form.HexChange(Sender: TObject);
var Cell:TEdit;
    HexVal:byte;
    i,
    j,
    index:word;

begin

    Cell := TEdit(Sender);
    CheckHex(Cell);

    { Only store the data if there is no error.  If there is an error,	}
    { the memory cell's background color will be red.			}

    if (Cell.Color <> clRed) then
    begin

        for i := 0 to 7 do
            for j := 0 to 7 do
            	if (Sender = MemEntry[i,j]) then
                    WriteMem(MemAdrs+ i*8+j, HexToWord(Cell.Text));

    end;

end;




{ AdrsEntryChange-	This method executes whenever the user changes	}
{			a value in the address box on the Memory page.	}
{			This method converts the string representation	}
{			of the address to binary, updates all the labels}
{			on the screen, and then updates all the memory	}
{			entry boxes on the page.			}

procedure TSIMx86Form.AdrsEntryChange(Sender: TObject);
var
    HexVal:	word;
    index:	word;
    i,j:	word;

begin

    CheckHex(TEdit(Sender));

    { If the entry is invalid, don't do anything.	}

    if (AdrsEntry.Color <> clRed) then begin

    	HexVal := HexToWord(AdrsEntry.Text);

        { Update the labels on the page.  Make sure the values we use	}
        { are all even multiples of eight.				}

        MemAdrs := HexVal and $FFF8;
        Lbl8.Caption  := IntToHex(MemAdrs+8,4);
        Lbl10.Caption := IntToHex(MemAdrs+16,4);
        Lbl18.Caption := IntToHex(MemAdrs+24,4);
        Lbl20.Caption := IntToHex(MemAdrs+32,4);
        Lbl28.Caption := IntToHex(MemAdrs+40,4);
        Lbl30.Caption := IntToHex(MemAdrs+48,4);
        Lbl38.Caption := IntToHex(MemAdrs+56,4);

        { Update the data in the entry cells on the page.  If	}
        { the location we access is before the starting address	}
        { (because we may have rounded it down to the previous	}
        {  eight-byte boundary), then turn the background color	}
        { gray.							}

        for i := 0 to 7 do
            for j := 0 to 7 do
            begin

            	index := MemAdrs + i*8 + j;
                MemEntry[i,j].Text := IntToHex(ReadMem(index),2);
                if ((index < HexVal) or (Index >=$fff0)) then
                begin

                	MemEntry[i,j].Color := clSilver;
                        MemEntry[i,j].Enabled := false;

                end
                else begin

                	MemEntry[i,j].Color := clWindow;
                        MemEntry[i,j].Enabled := true;

                end;

            end;


    end;

end;



procedure TSIMx86Form.StartAdrsChange(Sender: TObject);
begin

    CheckHex(StartAdrs);

end;



{ Do the assembly here }

procedure TSIMx86Form.ASMbtnClick(Sender: TObject);
var
   i:word;
   ch:char;
   line:array[0..255] of char;
   s:PChar;

begin

     { Initialize the symbol table }

     for ch := 'A' to 'Z' do
     begin

          SymTbl[ch].Value := 0;
          SymTbl[ch].Defined := false;

     end;

     { Compute the address of the first instruction }

     if (StartAdrs.Color <> clRed) then
     	Adrs := HexToWord(StartAdrs.Text)
     else Adrs := 0;

     { Assemble each line of source code }

     for LineNum := 0 to SourceCode.Lines.Count-1 do begin

         s := strPCopy(line, SourceCode.Lines[LineNum]);
         NoError := true;
         HasValue := false;
         HasOpcode := false;
         HasReg := false;
         HasOperand := false;
         if (not Match(stmt, s)) then
         begin

           if (NoError) then
              ErrorMsg('Syntax Error',
                   SourceCode.lines[LineNum]);
           if (AbortAsm) then break;

         end
         else begin


             { Okay, the instruction is syntactically cor-	}
             { rect.  Now emit the opcode and any necessary	}
             { operands to memory.				}

             Val := 0;
             if (HasOpcode) then  {It's not a blank line }
             begin

             	Val := Val or Opcode;
                if (HasReg) then Val := Val or Regcode;
                if (HasOperand) then Val := Val or OperandCode;
                WriteMem(Adrs, Val);
                inc(adrs);

                if (HasValue) then begin {It has an operand }

                	WriteMem(Adrs, OperandValue and $ff);
                        inc(adrs);
                        WriteMem(Adrs, OperandValue shr 8);
                        inc (adrs);

                end;

             end;

         end;

     end;

     { Check to see if there were any undefined symbols }

     for ch := 'A' to 'Z' do
     	if (not SymTbl[ch].Defined)then
           if (SymTbl[ch].Value <> 0) then
              ErrorMsg('Undefined Symbol', ch);

end;



{ Given an opcode, the following function returns the size of	}
{ an instruction (in bytes).  This is either one or three.	}

function InstrSz(opcode:word):integer;
begin

	if (opcode > $1f) or ((opcode and $18) = $10) then
        	if (opcode and $7) >= 5 then Result := 3
                else Result := 1
        else if (opcode and $18) = $8 then Result := 3
        else Result := 1;

end;


{ Given an opcode, the following function returns a string that	}
{ corresponds to the instruction's mnemonic.			}

function Instr(opcode:word):string;
begin

        Result := '????';
	case (opcode shr 5) of

            1: Result := 'or  ';
            2: Result := 'and ';
            3: Result := 'cmp ';
            4: Result := 'sub ';
            5: Result := 'add ';
            6: Result := 'mov ';
            7: Result := 'mov ';
            0: begin

            	if (opcode and $18) = $10 then
                   Result := 'not '
                else if (opcode and $18) = $8 then
                begin

                    case opcode and $7 of

                    0: Result := 'je  ';
                    1: Result := 'jne ';
                    2: Result := 'jb  ';
                    3: Result := 'jbe ';
                    4: Result := 'ja  ';
                    5: Result := 'jae ';
                    6: Result := 'jmp ';
                    7: Result := '****';
                    end;

                end
                else if (opcode and $18) = $18 then Result := '****'
                else begin

                    case (opcode and $7) of
                    0: Result := '****';
                    1: Result := '****';
                    2: Result := '****';
                    3: Result := 'brk ';
                    4: Result := 'iret';
                    5: Result := 'halt';
                    6: Result := 'get ';
                    7: Result := 'put ';
                    end;
                end;
               end;
        end;

end;



{ Given an opcode and an option operand, the following function returns	}
{ a string that represents the reg/memory addressing mode.		}

function AdrsMode(opcode, operand:word):string;

	function MemMode(opcode,operand:word):string;
        begin

        	case opcode and $7 of
                0: Result := 'ax';
                1: Result := 'bx';
                2: Result := 'cx';
                3: Result := 'dx';
                4: Result := '[bx]';
                5: Result := '['+IntToHex(operand,4)+'+bx]';
                6: Result := '['+IntToHex(operand,4)+']';
                7: Result := IntToHex(operand,4);
                end;
        end;

begin

	if (opcode > $1f) or (opcode and $18 = $10) then
        	Result := MemMode(opcode,operand)
        else if (opcode and $18 = $8) then
        	Result := MemMode($27, operand)
        else	Result := '';

end;





{ The following function disassembles a single instruction at the given	}
{ address and returns the string representation of that instruction.	}

function Disassemble2(var CodeAdrs:word):string;
var 	Size,
	Operand:word;
begin

	Result := IntToHex(CodeAdrs,4) + ': ' +
        	  IntToHex(ReadMem(CodeAdrs),2) + ' ';

        Size := InstrSz(ReadMem(CodeAdrs));
        Opcode := ReadMem(CodeAdrs);
        if Size = 1 then
        begin

        	Result := Result + '      ';
                inc(CodeAdrs);

        end
        else begin

        	Result := Result +
        	       IntToHex(ReadMem(CodeAdrs+1),2) + ' ' +
                       IntToHex(ReadMem(CodeAdrs+2),2) + ' ';
                Operand := ReadMem(CodeAdrs+1) + (ReadMem(CodeAdrs+2) shl 8);
                CodeAdrs := CodeAdrs + 3;

        end;
        Result := Result + Instr(opcode) + ' ';
        case (opcode shr 5) of
        1,2,3,4,5,6:begin

        	case ((opcode shr 3) and $3) of
                0: Result := Result + 'ax, ';
                1: Result := Result + 'bx, ';
                2: Result := Result + 'cx, ';
                3: Result := Result + 'dx, ';
                end;
                Result := Result + AdrsMode(Opcode, Operand);
            end;

        7:begin

        	Result := Result + AdrsMode(Opcode, Operand) + ', ';
                case ((opcode shr 3) and $3) of
                0: Result := Result + 'ax';
                1: Result := Result + 'bx';
                2: Result := Result + 'cx';
                3: Result := Result + 'dx';
                end;
           end;

        0: begin

        	case (opcode shr 3) and $3 of
                1: Result := Result + IntToHex(Operand,4);
                2: Result := Result + AdrsMode(Opcode,Operand);
                end;

           end;

        end;

end;



function Disassemble(CodeAdrs:word):string;
begin

	Result := Disassemble2(CodeAdrs);

end;



{ The following event method handles switching between pages on the form. }

procedure TSIMx86Form.Simx86PagesChange(Sender: TObject;
					NewTab: Integer;
  					var AllowChange: Boolean);
var DisAdrs:word;
    i:integer;
begin

	{ Don't allow a change if a program is running. }

	if (Running and (NewTab = 0)) then
        begin

        	AllowChange := false;

        end

        { If the user switches to the memory page, redraw all the cells. }

	else if (NewTab = 1) then
        	AdrsEntryChange(AdrsEntry)

        { If the user switches to the execute page, disassemble some	}
        { code for the disassembly list box.				}

        else if (NewTab = 2) then
        begin

            DisAdrs := HexToWord(DisAsmAdrs.Text);
            DisAsm.Clear;
            for i := 1 to 15 do
            	DisAsm.Items.Add(Disassemble2(DisAdrs));
            Instruction.Caption := Disassemble(IP);

        end;

end;



{ If the user changes the address in the TEdit box at the bottom of the	}
{ disassembly list box, the following procedure converts this to a word	}
{ and disassembles 15 instructions starting at this new address.	}

procedure TSIMx86Form.DisAsmAdrsChange(Sender: TObject);
var i:integer;
    DisAdrs:word;
begin

    DisAdrs := HexToWord(DisAsmAdrs.Text);
    DisAsm.Clear;
    for i := 1 to 15 do
        DisAsm.Items.Add(Disassemble2(DisAdrs));

end;


{ If the user presses on the down portion of the spinner at the bottom	}
{ of the disassembly list box, this method increments the disassembly	}
{ address and updates the disassembly list box.				}

procedure TSIMx86Form.SpinButtonDownClick(Sender: TObject);
var value:word;
begin

    Value := HexToWord(DisAsmAdrs.Text);
    inc(Value);
    DisAsmAdrs.Text := IntToHex(Value,4);

end;

{ If they press on the up arrow portion of the spinner, this code will	}
{ decrement the starting disassembly address and update the list box.	}

procedure TSIMx86Form.SpinButtonUpClick(Sender: TObject);
var value:word;
begin

    Value := HexToWord(DisAsmAdrs.Text);
    dec(Value);
    DisAsmAdrs.Text := IntToHex(Value,4);

end;








procedure OneInstr;


    procedure Store(mode:byte; index:word; value: word);
    begin

	case mode of

        0: AX := value;
        1: BX := value;
        2: CX := value;
        3: DX := value;
        4: begin

        	WriteMem(bx, value and $FF);
                WriteMem(bx+1, value shr 8);

           end;

        5: begin

        	WriteMem(bx+index, value and $FF);
                WriteMem(bx+index+1, value shr 8);

           end;

        6: begin

        	WriteMem(index, value and $FF);
                WriteMem(index+1, value shr 8);

           end;

        end;

    end;


begin

	with  SIMx86Form do begin

                if (PendingInt) and (not InInt) then
                   if (IntAdrs <> $FFFF) then
                   begin

                   	InInt := true;
                        SaveAX := AX;
                        SaveBX := BX;
                        SaveCX := CX;
                        SaveDX := DX;
                        SaveIP := IP;
                        SaveLess := LessThanFlag.Checked;
                        SaveEqual:= EqualFlag.Checked;
                        PendingInt := false;

                        IP := IntAdrs;

                   end;

                { Okay, do the instruction here.	}

                Opcode := ReadMem(IP);
                Operation := Opcode shr 5;
                Reg := (Opcode shr 3) and $3;
                RegMem := Opcode and $7;
                InstrSize := 1;

                case Reg of
                  0: Op1 := @AX;
                  1: Op1 := @BX;
                  2: Op1 := @CX;
                  3: Op1 := @DX;
                end;


                case RegMem of
                  0: Op2v := AX;
                  1: Op2v := BX;
                  2: Op2v := CX;
                  3: Op2v := DX;

                  4: Op2v := ReadMem(BX) + (ReadMem(BX+1) shl 8);

                  5: begin {[1000+bx]}

                  	offset := BX + ReadMem(IP+1) + ReadMem(IP+2) shl 8;
                  	Op2v := ReadMem(offset) + ReadMem(offset+1) shl 8;
                        InstrSize := 3;

                     end;

                  6: begin {[1000]}

                  	offset := ReadMem(IP+1) + ReadMem(IP+2) shl 8;
                  	Op2v := ReadMem(offset) + ReadMem(offset+1) shl 8;
                        InstrSize := 3;

                     end;

                  7: begin {1000}

                  	Op2v := ReadMem(IP+1) + ReadMem(IP+2) shl 8;
                        InstrSize := 3;

                     end;

                end;

                case Operation of

                  1: Op1^ := Op1^ or Op2v;
		  2: Op1^ := Op1^ and Op2v;

                  3: begin

                  	LessThanFlag.Checked := Op1^ < Op2v;
                        EqualFlag.Checked := Op1^ = Op2v;

                     end;

		  4: Op1^ := Op1^ - Op2v;
		  5: Op1^ := Op1^ + Op2v;
                  6: Op1^ := Op2v;
                  7: Store(regmem, ReadMem(IP+1) + ReadMem(IP+2) shl 8, Op1^);

                  0: case Reg of

                  	2: Store(regmem,
                        	 ReadMem(IP+1) + ReadMem(IP+2) shl 8,
                                 not Op2v);

                        1: begin {jumps}

                        	InstrSize := 0;
                        	case RegMem of

                        	0: if EqualFlag.Checked then
                                	IP := ReadMem(IP+1) +
                                        	ReadMem(IP+2) shl 8
                                   else InstrSize := 3;

                        	1: if not EqualFlag.Checked then
                                	IP := ReadMem(IP+1) +
                                        	ReadMem(IP+2) shl 8
                                   else InstrSize := 3;

                        	2: if LessThanFlag.Checked then
                                	IP := ReadMem(IP+1) +
                                        	ReadMem(IP+2) shl 8
                                   else InstrSize := 3;

                        	3: if LessThanFlag.Checked or
                                      EqualFlag.Checked then
                                	IP := ReadMem(IP+1) +
                                        	ReadMem(IP+2) shl 8
                                   else InstrSize := 3;

                        	4: if not (LessThanFlag.Checked or
                                           EqualFlag.Checked) then
                                	IP := ReadMem(IP+1) +
                                        	ReadMem(IP+2) shl 8
                                   else InstrSize := 3;

                        	5: if not LessThanFlag.Checked then
                                	IP := ReadMem(IP+1) +
                                        	ReadMem(IP+2) shl 8
                                   else InstrSize := 3;

                        	6: IP := ReadMem(IP+1) + ReadMem(IP+2) shl 8;

                                7: begin

                                	ErrorMsg('Illegal instruction',
                                        	 IntToHex(IP,4));

                                        Halted := true;

                                   end;

                                end;
                           end;

                        3: begin

                        	ErrorMsg('Illegal instruction',IntToHex(IP,4));
				Halted := true;

                           end;

                        0: case (RegMem) of
                           0,1,2:begin

                        	ErrorMsg('Illegal instruction',IntToHex(IP,4));
				Halted := true;
                                InstrSize := 0;

                              end;

                           3: begin

                        	ErrorMsg('BRK encountered',IntToHex(IP,4));
				Halted := true;
                                InstrSize := 1;

                              end;

                           4: if (not InInt) then
                              begin

                        	ErrorMsg('IRET encountered outside interrupt',
                                	 IntToHex(IP,4));
				Halted := true;
                                InstrSize := 0;

                              end
                              else begin

                              	AX := SaveAX;
                              	BX := SaveBX;
                              	CX := SaveCX;
                              	DX := SaveDX;
                              	IP := SaveIP;
                                LessThanFlag.Checked := SaveLess;
                                EqualFlag.Checked := SaveEqual;
                                InstrSize := 0;
                                InInt := false;

                              end;

                           5: begin

                        	ErrorMsg('Halt encountered',IntToHex(IP,4));
				Halted := true;
                                InstrSize := 0;

                              end;

                           6: begin

                           	InputForm.ShowModal;
                           	AX := InputValue;
                                InstrSize := 1;

                              end;

                           7: begin

                           	Output.Items.Add(IntToHex(AX,4));
                                InstrSize := 1;

                              end;

                        end;
                  end;
                end;
                IP := IP + InstrSize;

        end;

end;


procedure StopPgm;
begin

    with SIMx86Form do begin

	IPValue.Enabled := true;
	DisAsmAdrs.Enabled := true;
	SpinButton.Enabled := true;
	RunBtn.Enabled := true;
	StepBtn.Enabled := true;
	AXValue.Enabled := true;
	BXValue.Enabled := true;
	CXValue.Enabled := true;
	DXValue.Enabled := true;
	LessThanFlag.Enabled := true;
	EqualFlag.Enabled := true;
	HaltBtn.Enabled := false;
        RunningLite.Color := clGray;
        MainMenu.Items[0].Enabled := true;
        MainMenu.Items[1].Enabled := true;
        PendingInt := false;
        Instruction.Caption := Disassemble(IP);

    end;

end;

{ If the users presses the "RUN" button, the following code kicks in	}
{ the emulator.								}

procedure TSIMx86Form.RunBtnClick(Sender: TObject);


begin

	IPValue.Enabled := false;
	DisAsmAdrs.Enabled := false;
	SpinButton.Enabled := false;
	RunBtn.Enabled := false;
	StepBtn.Enabled := false;
	AXValue.Enabled := false;
	BXValue.Enabled := false;
	CXValue.Enabled := false;
	DXValue.Enabled := false;
	LessThanFlag.Enabled := false;
	EqualFlag.Enabled := false;
	HaltBtn.Enabled := true;
        RunningLite.Color := clRed;
        PendingInt := false;

        MainMenu.Items[0].Enabled := false;
        MainMenu.Items[1].Enabled := false;

        Halted := false;
        Running := true;
        InInt := false;



        while not Halted do begin

        	Application.ProcessMessages;
                OneInstr;

        end;
        Running := false;
        RunningLite.Color := clGray;
        StopPgm;

        IPValue.Text := IntToHex(IP,4);
        AXValue.Text := IntToHex(AX,4);
        BXValue.Text := IntToHex(BX,4);
        CXValue.Text := IntToHex(CX,4);
        DXValue.Text := IntToHex(DX,4);

end;

procedure TSIMx86Form.HaltBtnClick(Sender: TObject);
begin

	StopPgm;
        Halted := true;

end;


{ If the user presses the reset button, the following method resets	}
{ the machine.								}

procedure TSIMx86Form.ResetBtnClick(Sender: TObject);
begin

	AX := 0;
        BX := 0;
        CX := 0;
        DX := 0;
        AXValue.Text := '0000';
        BXValue.Text := '0000';
        CXValue.Text := '0000';
        DXValue.Text := '0000';
        if (ResetVect.Color <> clRed) then
        begin

        	IP := HexToWord(ResetVect.Text);
	        IPValue.Text := ResetVect.Text;

        end
        else begin

        	IP := 0;
                IPValue.Text := '0000';

        end;
        LessThanFlag.Checked := false;
        EqualFlag.Checked := false;
        PendingInt := false;
        StopPgm;
        Halted := true;
        Output.Items.Clear;
        Input.Items.Clear;
        Instruction.Caption := Disassemble(IP);


end;




procedure TSIMx86Form.InterruptBtnClick(Sender: TObject);
begin

	PendingInt := true;

end;



procedure TSIMx86Form.IntVectChange(Sender: TObject);
begin

	CheckHex(IntVect);
        if (IntVect.Color <> clRed) then
        begin

        	IntAdrs := HexToWord(IntVect.Text);

        end;
end;

procedure TSIMx86Form.IPValueChange(Sender: TObject);
begin

	CheckHex(IPValue);
        if IPValue.Color <> clRed then
        begin

        	IP := HexToWord(IPValue.Text);

        end;
        Instruction.Caption := Disassemble(IP);

end;

procedure TSIMx86Form.StepBtnClick(Sender: TObject);
begin

	OneInstr;
        IPValue.Text := IntToHex(IP,4);
        AXValue.Text := IntToHex(AX,4);
        BXValue.Text := IntToHex(BX,4);
        CXValue.Text := IntToHex(CX,4);
        DXValue.Text := IntToHex(DX,4);
        Instruction.Caption := Disassemble(IP);

end;


end.

