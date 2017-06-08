program Optimzp;

uses
  Forms,
  Optimize in 'OPTIMIZE.PAS' {EqnOptimize},
  Aboutu in 'ABOUTU.PAS' {AboutBox};

{$R *.RES}

begin
  Application.CreateForm(TEqnOptimize, EqnOptimize);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
