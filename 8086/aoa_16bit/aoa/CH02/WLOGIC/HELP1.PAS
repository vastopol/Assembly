unit Help1;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  THelpBox = class(TForm)
    Panel1: TPanel;
    OKButton: TBitBtn;
    HelpLbl1: TLabel;
    HelpLbl2: TLabel;
    HelpLbl3: TLabel;
    HelpLbl4: TLabel;
    HelpLbl5: TLabel;
    HelpLbl6: TLabel;
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HelpBox: THelpBox;

implementation

{$R *.DFM}

procedure THelpBox.OKButtonClick(Sender: TObject);
begin
	Close;
end;

end.
 
