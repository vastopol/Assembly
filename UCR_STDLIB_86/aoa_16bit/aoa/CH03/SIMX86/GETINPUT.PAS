unit Getinput;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TInputForm = class(TForm)
    Label1: TLabel;
    HexInput: TEdit;
    OKButton: TButton;
    procedure HexInputChange(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InputForm: TInputForm;
  InputValue:word;

implementation

uses SIMx86p;

{$R *.DFM}

procedure TInputForm.HexInputChange(Sender: TObject);
var isHex:boolean;
	i:integer;
       ch:char;
begin

	isHex := length(HexInput.Text) >= 1;
        for i := 1 to length(HexInput.Text) do
        	isHex := isHex and
                	 (HexInput.Text[i] in ['0'..'9', 'a'..'f', 'A'..'F']);

        if not isHex then
        begin
        	HexInput.Color := clRed;
                MessageBeep($FFFF);

        end
        else begin

        	InputValue := 0;
        	for i := 1 to length(HexInput.Text) do
                begin

                    ch := upcase(HexInput.Text[i]);
                    if ch in ['0'..'9'] then
                    	InputValue := InputValue shl 4 + (ord(ch) and $f)
                    else InputValue := InputValue shl 4 + (ord(ch) and $f) + 9;
                    HexInput.Color := clWhite;

                end;
        end;

end;

procedure TInputForm.OKButtonClick(Sender: TObject);
begin

	if (HexInput.Color <> clRed) then
        begin

        	SIMx86Form.Input.Items.Add(HexInput.Text);
        	InputForm.Close;

        end;
end;

end.
