program Logic;

uses
  Forms,
  Logicev in 'LOGICEV.PAS' {LogicEval},
  About in 'ABOUT.PAS' {AboutBox},
  Eqnentry in 'EQNENTRY.PAS' {EqnDlg},
  Help1 in 'HELP1.PAS' {HelpBox};

{$R *.RES}

begin
  Application.Title := 'LOGICEV';
  Application.CreateForm(TLogicEval, LogicEval);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TEqnDlg, EqnDlg);
  Application.CreateForm(THelpBox, HelpBox);
  Application.Run;
end.
