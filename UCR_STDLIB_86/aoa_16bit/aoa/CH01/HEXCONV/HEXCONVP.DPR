program Hexconvp;

uses
  Forms,
  Hexconvu in 'HEXCONVU.PAS' {HexConv};

{$R *.RES}

begin
  Application.Title := 'Hex Conversion';
  Application.CreateForm(THexConv, HexConv);
  Application.Run;
end.
