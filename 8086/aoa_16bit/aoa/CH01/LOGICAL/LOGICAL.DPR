program Logical;

uses
  Forms,
  Logicalu in 'LOGICALU.PAS' {LogicalOps};

{$R *.RES}

begin
  Application.Title := 'Hex Conversion';
  Application.CreateForm(TLogicalOps, LogicalOps);
  Application.Run;
end.
