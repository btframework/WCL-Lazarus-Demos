unit main;

{$MODE Delphi}

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  wclWiFi, StdCtrls, ComCtrls;

type
  TfmMain = class(TForm)
    laMacAddressTitle: TLabel;
    laMacAddress: TLabel;
    laChannelTitle: TLabel;
    laChannel: TLabel;
    laPhyTitle: TLabel;
    laPhy: TLabel;
    laSetChannelTitle: TLabel;
    laSetPhyTitle: TLabel;
    laWarning: TLabel;
    laRawFrames: TLabel;
    btEnumInterfaces: TButton;
    btStartCapture: TButton;
    btStopCapture: TButton;
    lvInterfaces: TListView;
    edChannel: TEdit;
    btSetChannel: TButton;
    cbPhy: TComboBox;
    btSetPhy: TButton;
    lbFrames: TListBox;
    btClear: TButton;
    cbDoNotChangeMode: TCheckBox;
    laIfaceModeCaption: TLabel;
    laIfaceMode: TLabel;
    procedure btEnumInterfacesClick(Sender: TObject);
    procedure btStartCaptureClick(Sender: TObject);
    procedure btStopCaptureClick(Sender: TObject);
    procedure btSetChannelClick(Sender: TObject);
    procedure btSetPhyClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    WiFiClient: TwclWiFiClient;
    WiFiSniffer: TwclWiFiSniffer;

    procedure ShowError(const s: string; const Error: Integer);
    procedure RefreshChannel;
    procedure RefreshPhy;

    procedure WiFiSnifferAfterOpen(Sender: TObject);
    procedure WiFiSnifferBeforeClose(Sender: TObject);
    procedure WiFiSnifferRawFrameReceived(Sender: TObject;
      const Buffer: Pointer; const Size: Cardinal);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors;

{$R *.lfm}

{ TfmMain }

procedure TfmMain.RefreshChannel;
var
  Ch: Cardinal;
  Res: Integer;
begin
  Res := WiFiSniffer.GetChannel(Ch);
  if Res = WCL_E_SUCCESS then
    laChannel.Caption := IntToStr(Ch)
  else
    laChannel.Caption := 'Error: 0x' + IntToHex(Res, 8);
end;

procedure TfmMain.RefreshPhy;
var
  Phy: TwclWiFiSnifferPhy;
  Res: Integer;
begin
  Res := WiFiSniffer.GetPhy(Phy);
  if Res = WCL_E_SUCCESS then begin
    case Phy of
      ph802_11a: laPhy.Caption := '802.11a';
      ph802_11b: laPhy.Caption := '802.11b';
      ph802_11g: laPhy.Caption := '802.11g';
      ph802_11n: laPhy.Caption := '802.11n';
    else
      laPhy.Caption := 'UNKNOWN';
    end
  end else
    laPhy.Caption := 'Error: 0x' + IntToHex(Res, 8);
end;

procedure TfmMain.ShowError(const s: string; const Error: Integer);
begin
  MessageDlg(s + ': 0x' + IntToHex(Error, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btEnumInterfacesClick(Sender: TObject);
var
  Res: Integer;
  Ifaces: TwclWiFiInterfaces;
  i: Integer;
  Item: TListItem;
begin
  lvInterfaces.Items.Clear;

  Res := WiFiClient.Open;
  if Res <> WCL_E_SUCCESS then
    ShowError('Unable to open WiFi Client', Res)
  else begin
    try
      Res := WiFiClient.EnumInterfaces(Ifaces);
      if Res <> WCL_E_SUCCESS then
        ShowError('Unable to enumerate WiFi Interfaces', Res)
      else begin
        try
          if Length(Ifaces) = 0 then
            MessageDlg('No WiFi Interfaces were found', mtWarning, [mbOK], 0)
          else begin
            for i := 0 to Length(Ifaces) - 1 do begin
              Item := lvInterfaces.Items.Add;
              Item.Caption := Ifaces[i].Description;
              Item.SubItems.Add(GUIDToString(Ifaces[i].Id));
            end;
          end;
        finally
          Ifaces := nil;
        end;
      end;
    finally
      WiFiClient.Close;
    end;
  end;
end;

procedure TfmMain.btStartCaptureClick(Sender: TObject);
var
  Id: TGUID;
  Res: Integer;
begin
  if lvInterfaces.Selected = nil then
    MessageDlg('Select interface', mtWarning, [mbOK], 0)
  else begin
    Id := StringToGUID(lvInterfaces.Selected.SubItems[0]);
    try
      WiFiSniffer.DoNotChangeMode := cbDoNotChangeMode.Checked;
      Res := WiFiSniffer.Open(Id);
      if Res <> WCL_E_SUCCESS then
        ShowError('Unable start capturing', Res);
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;
end;

procedure TfmMain.btStopCaptureClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := WiFiSniffer.Close;
  if Res <> WCL_E_SUCCESS then
    ShowError('Unable to stop capturing', Res);
end;

procedure TfmMain.btSetChannelClick(Sender: TObject);
var
  Ch: Integer;
  Res: Integer;
begin
  Ch := StrToInt(edChannel.Text);
  Res := WiFiSniffer.SetChannel(Ch);
  if Res <> WCL_E_SUCCESS then
    ShowError('Unable to change channel', Res)
  else
    RefreshChannel;
end;

procedure TfmMain.btSetPhyClick(Sender: TObject);
var
  Phy: TwclWiFiSnifferPhy;
  Res: Integer;
begin
  Phy := TwclWiFiSnifferPhy(cbPhy.ItemIndex);
  Res := WiFiSniffer.SetPhy(Phy);
  if Res <> WCL_E_SUCCESS then
    ShowError('Unable to change PHY', Res)
  else
    RefreshPhy;
end;

procedure TfmMain.WiFiSnifferAfterOpen(Sender: TObject);
var
  Mac: Int64;
  Res: Integer;
begin
  RefreshChannel;
  RefreshPhy;
  Res := WiFiSniffer.GetMacAddr(Mac);
  if Res = WCL_E_SUCCESS then begin
    laMacAddress.Caption := IntToHex(Mac, 12);
    case WiFiSniffer.Mode of
      omUnknown: laIfaceMode.Caption := 'Unknown';
      omStation: laIfaceMode.Caption := 'Station';
      omAccessPoint: laIfaceMode.Caption := 'Access point';
      omExtensibleStation: laIfaceMode.Caption := 'Extensible Station';
      omExtensibleAccessPoint: laIfaceMode.Caption := 'Extensible Access Point';
      omWiFiDirectDevice: laIfaceMode.Caption := 'WiFiDirect Device';
      omWiFiDirectGroupOwner: laIfaceMode.Caption := 'WiFiDirect Group Owner';
      omWiFiDirectClient: laIfaceMode.Caption := 'WiFiDirect Client';
      omManufacturing: laIfaceMode.Caption := 'Manufacturing';
      omNetworkMonitor: laIfaceMode.Caption := 'Network Monitor';
      else laIfaceMode.Caption := 'Unknown';
    end;
  end else
    laMacAddress.Caption := 'Error: 0x' + IntToHex(Res, 8);
end;

procedure TfmMain.WiFiSnifferBeforeClose(Sender: TObject);
begin
  laMacAddress.Caption := '000000000000';
  laPhy.Caption := 'NONE';
  laChannel.Caption := '0';
  laIfaceMode.Caption := 'Unknown';
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbFrames.Clear;
end;

procedure TfmMain.WiFiSnifferRawFrameReceived(Sender: TObject;
  const Buffer: Pointer; const Size: Cardinal);
var
  s: string;
  i: Cardinal;
begin
  s := '';
  for i := 0 to Size - 1 do begin
    s := s + IntToHex(Byte(PAnsiChar(Buffer)[i]), 2) + ' ';
    if Length(s) = 96 then begin
      lbFrames.Items.Add(s);
      s := '';
    end;
  end;
  if Length(s) > 0 then
    lbFrames.Items.Add(s);
  Application.ProcessMessages;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  WiFiSniffer.Close;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  WiFiClient := TwclWiFiClient.Create(nil);

  WiFiSniffer := TwclWiFiSniffer.Create(nil);
  WiFiSniffer.AfterOpen := WiFiSnifferAfterOpen;
  WiFiSniffer.BeforeClose := WiFiSnifferBeforeClose;
  WiFiSniffer.OnRawFrameReceived := WiFiSnifferRawFrameReceived;
end;

end.
