program Packdata;

uses
  Forms,
  Packedu in 'PACKEDU.PAS' {PackedData};

{$R *.RES}

begin
  Application.Title := 'Hex Conversion';
  Application.CreateForm(TPackedData, PackedData);
  Application.Run;
end.
