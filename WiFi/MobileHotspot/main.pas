unit main;

{$I wcl.inc}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclWiFi, ComCtrls;

type

  { TfmMain }

  TfmMain = class(TForm)
    btOpen: TButton;
    btClose: TButton;
    btStart: TButton;
    btStop: TButton;
    btGetState: TButton;
    laSsid: TLabel;
    edSsid: TEdit;
    btGetSsid: TButton;
    btSetSsid: TButton;
    laPassword: TLabel;
    edPassword: TEdit;
    btGetPwd: TButton;
    btSetPwd: TButton;
    btGetMaxClients: TButton;
    btGetConnected: TButton;
    Label1: TLabel;
    cbBand: TComboBox;
    btIsSupported: TButton;
    btSetBand: TButton;
    btGetBand: TButton;
    btConnectedClients: TButton;
    lvConnectedClients: TListView;
    btCheckTimeout: TButton;
    btEnableTimeout: TButton;
    btDisableTimeout: TButton;
    procedure btOpenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btGetStateClick(Sender: TObject);
    procedure btGetSsidClick(Sender: TObject);
    procedure btSetSsidClick(Sender: TObject);
    procedure btGetPwdClick(Sender: TObject);
    procedure btSetPwdClick(Sender: TObject);
    procedure btGetMaxClientsClick(Sender: TObject);
    procedure btGetConnectedClick(Sender: TObject);
    procedure btIsSupportedClick(Sender: TObject);
    procedure btGetBandClick(Sender: TObject);
    procedure btSetBandClick(Sender: TObject);
    procedure btConnectedClientsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btCheckTimeoutClick(Sender: TObject);
    procedure btEnableTimeoutClick(Sender: TObject);
    procedure btDisableTimeoutClick(Sender: TObject);

  private
    wclMobileHotspot: TwclMobileHotspot;

    procedure wclMobileHotspotClosed(Sender: TObject);
    procedure wclMobileHotspotOpened(Sender: TObject);

    procedure Trace(const Msg: string); overload;
    procedure Trace(const Msg: string; const Error: Integer); overload;
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.Open;
  if Res <> WCL_E_SUCCESS then
    Trace('Open failed', Res);
end;

procedure TfmMain.Trace(const Msg: string);
begin
  ShowMessage(Msg);
end;

procedure TfmMain.Trace(const Msg: string; const Error: Integer);
begin
  Trace(Msg + '. Error: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.Close;
  if Res <> WCL_E_SUCCESS then
    Trace('Close failed', Res);
end;

procedure TfmMain.wclMobileHotspotClosed(Sender: TObject);
begin
  Trace('Mobile hotspot closed.');

  edSsid.Text := '';
  edPassword.Text := '';

  lvConnectedClients.Items.Clear;
end;

procedure TfmMain.wclMobileHotspotOpened(Sender: TObject);
var
  Ssid: string;
  Passphrase: string;
begin
  Trace('Mobile hotspot opened.');
  if wclMobileHotspot.GetSsid(Ssid) = WCL_E_SUCCESS then
    edSsid.Text := Ssid;
  if wclMobileHotspot.GetPassphrase(Passphrase) = WCL_E_SUCCESS then
    edPassword.Text := Passphrase;
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.Start;
  if Res <> WCL_E_SUCCESS then
    Trace('Start failed', Res);
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.Stop;
  if Res <> WCL_E_SUCCESS then
    Trace('Stop failed', Res);
end;

procedure TfmMain.btGetStateClick(Sender: TObject);
var
  Res: Integer;
  State: TwclMobileHotspotState;
begin
  Res := wclMobileHotspot.GetState(State);
  if Res <> WCL_E_SUCCESS then
    Trace('Get state failed', Res)
  else begin
    case State of
      mhsUnknown:
        Trace('State: unknown');
      mhsOn:
        Trace('State: on');
      mhsOff:
        Trace('State: off');
      mhsInTransition:
        Trace('State: switching');
    end;
  end;
end;

procedure TfmMain.btGetSsidClick(Sender: TObject);
var
  Res: Integer;
  Ssid: string;
begin
  Res := wclMobileHotspot.GetSsid(Ssid);
  if Res <> WCL_E_SUCCESS then
    Trace('Get SSID failed', Res)
  else
    edSsid.Text := Ssid;
end;

procedure TfmMain.btSetSsidClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.SetSsid(edSsid.Text);
  if Res <> WCL_E_SUCCESS then
    Trace('Set SSID failed', Res);
end;

procedure TfmMain.btGetPwdClick(Sender: TObject);
var
  Res: Integer;
  Pwd: string;
begin
  Res := wclMobileHotspot.GetPassphrase(Pwd);
  if Res <> WCL_E_SUCCESS then
    Trace('Get passphrase failed', Res)
  else
    edPassword.Text := Pwd;
end;

procedure TfmMain.btSetPwdClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.SetPassphrase(edPassword.Text);
  if Res <> WCL_E_SUCCESS then
    Trace('Set passphrase failed', Res);
end;

procedure TfmMain.btGetMaxClientsClick(Sender: TObject);
var
  Res: Integer;
  Count: Cardinal;
begin
  Res := wclMobileHotspot.GetMaxClientCount(Count);
  if Res <> WCL_E_SUCCESS then
    Trace('Get max client connections failed', Res)
  else
    Trace('Maximum allowed connections: ' + IntToStr(Count));
end;

procedure TfmMain.btGetConnectedClick(Sender: TObject);
var
  Res: Integer;
  Count: Cardinal;
begin
  Res := wclMobileHotspot.GetClientCount(Count);
  if Res <> WCL_E_SUCCESS then
    Trace('Get connectioned clients count failed', Res)
  else
    Trace('Connected clients: ' + IntToStr(Count));
end;

procedure TfmMain.btIsSupportedClick(Sender: TObject);
var
  Band: TwclMobileHotspotBand;
  Res: Integer;
  Supp: Boolean;
begin
  case cbBand.ItemIndex of
    0: Band := mhbAuto;
    1: Band := mhbTwoPointFourGigahertz;
    else Band := mhbFiveGigahertz;
  end;

  Res := wclMobileHotspot.IsBandSupported(Band, Supp);
  if Res <> WCL_E_SUCCESS then
    Trace('Check band failed', Res)
  else begin
    if Supp then
      ShowMessage('Band is supported')
    else
      ShowMessage('Band is NOT supported');
  end;
end;

procedure TfmMain.btGetBandClick(Sender: TObject);
var
  Band: TwclMobileHotspotBand;
  Res: Integer;
begin
  Res := wclMobileHotspot.GetBand(Band);
  if Res <> WCL_E_SUCCESS then
    Trace('Get band failed', Res)
  else begin
    case Band of
      mhbAuto: ShowMessage('Band: Auto');
      mhbTwoPointFourGigahertz: ShowMessage('Band: 2.4');
      else ShowMessage('Band: 5.8');
    end;
  end;
end;

procedure TfmMain.btSetBandClick(Sender: TObject);
var
  Band: TwclMobileHotspotBand;
  Res: Integer;
begin
  case cbBand.ItemIndex of
    0: Band := mhbAuto;
    1: Band := mhbTwoPointFourGigahertz;
    else Band := mhbFiveGigahertz;
  end;

  Res := wclMobileHotspot.SetBand(Band);
  if Res <> WCL_E_SUCCESS then
    Trace('Set band failed', Res);
end;

procedure TfmMain.btConnectedClientsClick(Sender: TObject);
var
  Clients: TwclMobileHotspotClients;
  Res: Integer;
  i: Integer;
  Item: TListItem;
begin
  lvConnectedClients.Items.Clear;
  Res := wclMobileHotspot.GetClients(Clients);
  if Res <> WCL_E_SUCCESS then
    Trace('Get connected clients failed', Res)
  else begin
    if Length(Clients) > 0 then begin
      for i := 0 to Length(Clients) - 1 do begin
        Item := lvConnectedClients.Items.Add;
        Item.Caption := Clients[i].Mac;
        Item.SubItems.Add(Clients[i].Name);
      end;
    end;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclMobileHotspot := TwclMobileHotspot.Create(nil);
  wclMobileHotspot.OnClosed := wclMobileHotspotClosed;
  wclMobileHotspot.OnOpened := wclMobileHotspotOpened;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclMobileHotspot.Close;
  wclMobileHotspot.Free;
end;

procedure TfmMain.btCheckTimeoutClick(Sender: TObject);
var
  Res: Integer;
  Enabled: Boolean;
begin
  Res := wclMobileHotspot.IsNoConnectionsTimeoutEnabled(Enabled);
  if Res <> WCL_E_SUCCESS then
    Trace('Get no connection timeout status failed', Res)
  else begin
    if Enabled then
      ShowMessage('No connection timeout enabled')
    else
      ShowMessage('No connection timeout disabled');
  end;
end;

procedure TfmMain.btEnableTimeoutClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.EnableNoConnectionsTimeout;
  if Res <> WCL_E_SUCCESS then
    Trace('Enable No Connection Timeout failed', Res);
end;

procedure TfmMain.btDisableTimeoutClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclMobileHotspot.DisableNoConnectionsTimeout;
  if Res <> WCL_E_SUCCESS then
    Trace('Disable No Connection Timeout failed', Res);
end;

end.
