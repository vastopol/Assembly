program Canon;

uses
  Forms,
  Canonu in 'CANONU.PAS' {LogEqns},
  Aboutu in 'ABOUTU.PAS' {AboutBox};

{$R *.RES}

begin
  Application.CreateForm(TLogEqns, LogEqns);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
