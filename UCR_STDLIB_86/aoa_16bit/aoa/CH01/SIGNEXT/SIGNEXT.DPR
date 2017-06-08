program SignExt;

uses
  Forms,
  Signx in 'SIGNX.PAS' {SignExtend};

{$R *.RES}

begin
  Application.Title := 'Hex Conversion';
  Application.CreateForm(TSignExtend, SignExtend);
  Application.Run;
end.
