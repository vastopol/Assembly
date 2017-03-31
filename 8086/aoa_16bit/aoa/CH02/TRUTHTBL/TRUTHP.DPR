program Truthp;

uses
  Forms,
  Truthu in 'TRUTHU.PAS' {TruthTbl},
  Aboutp in 'ABOUTP.PAS' {AboutBox};

{$R *.RES}

begin
  Application.Title := 'Logic Simulation';
  Application.CreateForm(TTruthTbl, TruthTbl);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
