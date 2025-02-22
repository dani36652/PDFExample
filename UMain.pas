unit UMain;

interface

uses
  {$IFDEF ANDROID}
  Androidapi.JNI.Webkit, FMX.VirtualKeyboard,
  Androidapi.JNI.Print, Androidapi.JNI.Util,
  fmx.Platform.Android,
  Androidapi.jni,fmx.helpers.android, Androidapi.Jni.app,
  Androidapi.Jni.GraphicsContentViewText, Androidapi.JniBridge,
  Androidapi.JNI.Os, Androidapi.Jni.Telephony,
  Androidapi.JNI.JavaTypes,Androidapi.Helpers,
  Androidapi.JNI.Widget,System.Permissions,
  FMX.DialogService,Androidapi.Jni.Provider,Androidapi.Jni.Net,
  fmx.TextLayout,AndroidAPI.JNI.Support,
 {$ENDIF}
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Layouts, FMX.Objects,
  FMX.WebBrowser, FMX.TabControl, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TfrmMain = class(TForm)
    CmbBxPDFs: TComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    rectToolBar: TRectangle;
    lblTituloToolBar: TLabel;
    NavegacionPDF: TGridPanelLayout;
    btnAnterior: TButton;
    btnSiguiente: TButton;
    imgPDF: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnSiguienteClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure CmbBxPDFsChange(Sender: TObject);
  private
    { Private declarations }
    FRenderer: JPdfRenderer;
    FFileDescriptor: JParcelFileDescriptor;
    FCurrentPage: JPdfRenderer_Page;
    FPageIndex: Integer;
    procedure LoadPDF(const FileName: string);
    procedure ShowPage(Index: Integer);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation
uses
  System.IOUtils;

{$R *.fmx}

{ TfrmMain }

procedure TfrmMain.btnAnteriorClick(Sender: TObject);
begin
  Dec(FPageIndex);
  ShowPage(FPageIndex);
end;

procedure TfrmMain.btnSiguienteClick(Sender: TObject);
begin
  Inc(FPageIndex);
  ShowPage(FPageIndex);
end;

procedure TfrmMain.CmbBxPDFsChange(Sender: TObject);
begin
  case TComboBox(Sender).ItemIndex of
    0:
    begin
      FPageIndex := 0;
      LoadPDF('Asesinato.pdf'); // Aseg�rate de que el archivo est� en la carpeta Assets.
      ShowPage(FPageIndex);
    end;

    1:
    begin
      FPageIndex := 0;
      LoadPDF('Caballeria.pdf'); // Aseg�rate de que el archivo est� en la carpeta Assets.
      ShowPage(FPageIndex);
    end;

    2:
    begin
      FPageIndex := 0;
      LoadPDF('Corazon.pdf'); // Aseg�rate de que el archivo est� en la carpeta Assets.
      ShowPage(FPageIndex);
    end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  Window: JWindow;
begin
  Window:= TAndroidHelper.Activity.getWindow;
  Window.setStatusBarColor(TAndroidHelper.AlphaColorToJColor(rectToolBar.Fill.Color));

  FPageIndex := 0;
  LoadPDF('Asesinato.pdf');
  ShowPage(FPageIndex);
end;

procedure TfrmMain.LoadPDF(const FileName: string);
var
  FilePath: string;
  JavaFile: JFile;
begin
  FilePath := TPath.Combine(TPath.GetDocumentsPath, FileName);

  JavaFile := TJFile.JavaClass.init(StringToJString(FilePath));

  FFileDescriptor := TJParcelFileDescriptor.JavaClass.open(JavaFile,
    TJParcelFileDescriptor.JavaClass.MODE_READ_ONLY);

  FRenderer := TJPdfRenderer.JavaClass.init(FFileDescriptor);
end;

procedure TfrmMain.ShowPage(Index: Integer);
var
  Bitmap: JBitmap;
  DelphiBitmap: TBitmap;
  ScaleFactor: Integer;
begin
  // Cerrar la p�gina actual si est� abierta
  if FCurrentPage <> nil then
    FCurrentPage.close;

  // Abrir la nueva p�gina
  FCurrentPage := FRenderer.openPage(Index);

  ScaleFactor:= 3; //Un factor de escala para aumentar la resoluci�n de la imagen

  // Crear un bitmap para renderizar la p�gina
  Bitmap := TJBitmap.JavaClass.createBitmap(FCurrentPage.getWidth * ScaleFactor,
    FCurrentPage.getHeight * ScaleFactor, TJBitmap_Config.JavaClass.ARGB_8888);

  FCurrentPage.render(Bitmap, nil, nil, TJPdfRenderer_Page.JavaClass.RENDER_MODE_FOR_DISPLAY);

  // Convertir el bitmap de Android a un bitmap de Delphi
  DelphiBitmap := TBitmap.Create;
  try
    if not JBitmapToBitmap(Bitmap, DelphiBitmap) then
      Exit;
    imgPDF.Bitmap.Assign(DelphiBitmap);
  finally
    DelphiBitmap.Free;
    Bitmap.recycle;
  end;

  // Habilitar/deshabilitar botones
  btnAnterior.Enabled := Index > 0;
  btnSiguiente.Enabled := Index < FRenderer.getPageCount - 1;
end;

end.
