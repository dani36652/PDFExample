program PDFExample;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  UMain in 'UMain.pas' {frmMain};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
