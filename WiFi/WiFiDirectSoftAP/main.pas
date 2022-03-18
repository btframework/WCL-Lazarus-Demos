unit main;

{$I wcl.inc}

interface

uses
  Forms, Classes, wclWiFi, Controls, StdCtrls;

type

  { TfmMain }

  TfmMain = class(TForm)
    btStart: TButton;
    btStop: TButton;
    laSSID: TLabel;
    edSSID: TEdit;
    laPassphrase: TLabel;
    edPassphrase: TEdit;
    lbEvents: TListBox;
    btGetIpSettings: TButton;
    btChangeIpSettings: TButton;
    btResetIpSettings: TButton;
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btGetIpSettingsClick(Sender: TObject);
    procedure btChangeIpSettingsClick(Sender: TObject);
    procedure btResetIpSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    wclWiFiSoftAP: TwclWiFiSoftAP;

    procedure wclWiFiSoftAPStopped(Sender: TObject);
    procedure wclWiFiSoftAPStarted(Sender: TObject);
    procedure wclWiFiSoftAPDeviceConnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice);
    procedure wclWiFiSoftAPDeviceDisconnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice);
    procedure wclWiFiSoftAPDeviceConnectError(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Error: Integer);
    procedure wclWiFiSoftAPDeviceAccept(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Accept: Boolean);
  end;

var
  fmMain: TfmMain;

implementation

uses
  SysUtils, wclErrors, Dialogs;

{$R *.lfm}

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiSoftAP.Start(edSSID.Text, edPassphrase.Text);
  lbEvents.Items.Add('Start: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiSoftAP.Stop;
  lbEvents.Items.Add('Stop: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclWiFiSoftAPStopped(Sender: TObject);
begin
  lbEvents.Items.Add('Stopped');
end;

procedure TfmMain.wclWiFiSoftAPStarted(Sender: TObject);
var
  Res: Integer;
  Str: string;
begin
  lbEvents.Items.Add('Started');

  Res := wclWiFiSoftAP.GetSsid(Str);
  if Res <> WCL_E_SUCCESS then
    Str := 'Read error 0x' + IntToHex(Res, 8);
  lbEvents.Items.Add('SSID: ' + Str);

  Res := wclWiFiSoftAP.GetPassphrase(Str);
  if Res <> WCL_E_SUCCESS then
    Str := 'Read error 0x' + IntToHex(Res, 8);
  lbEvents.Items.Add('Passphrase: ' + Str);
end;

procedure TfmMain.wclWiFiSoftAPDeviceConnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice);
begin
  lbEvents.Items.Add('Device connected: ' + Device.Name);
  lbEvents.Items.Add('  Local IP: ' + Device.LocalAddress);
  lbEvents.Items.Add('  Remote IP: ' + Device.RemoteAddress);
end;

procedure TfmMain.wclWiFiSoftAPDeviceDisconnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice);
begin
  lbEvents.Items.Add('Device disconnected: ' + Device.Name);
  lbEvents.Items.Add('  Local IP: ' + Device.LocalAddress);
  lbEvents.Items.Add('  Remote IP: ' + Device.RemoteAddress);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclWiFiSoftAP.Stop;
  wclWiFiSoftAP.Free;
end;

procedure TfmMain.wclWiFiSoftAPDeviceConnectError(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Error: Integer);
begin
  lbEvents.Items.Add('Device ' + Device.Name + ' connect error: ' +
    IntToHex(Error, 8));
end;

procedure TfmMain.wclWiFiSoftAPDeviceAccept(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Accept: Boolean);
begin
  Accept := (MessageDlg('Accept device: ' + Device.Id, mtConfirmation,
    [mbYes, mbNo], 0) = mrYes);
end;

procedure TfmMain.btGetIpSettingsClick(Sender: TObject);
var
  Res: Integer;
  Address: string;
  Mask: string;
  Gateway: string;
  Dns1: string;
  Dns2: string;
begin
  Res := wclWiFiSoftAP.GetIpSettings(Address, Mask, Gateway, Dns1, Dns2);
  if Res <> WCL_E_SUCCESS then
    lbEvents.Items.Add('Read IP settings failed: 0x' + IntToHex(Res, 8))
  else begin
    lbEvents.Items.Add('IP settings:');
    lbEvents.Items.Add('  Address: ' + Address);
    lbEvents.Items.Add('  Mask: ' + Mask);
    lbEvents.Items.Add('  Gateway: ' + Gateway);
    lbEvents.Items.Add('  Dns1: ' + Dns1);
    lbEvents.Items.Add('  Dns2: ' + Dns2);
  end;
end;

procedure TfmMain.btChangeIpSettingsClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiSoftAP.SetIpSettings('192.168.2.10', '255.255.255.0',
    '192.168.2.1', '', '');
  if Res <> WCL_E_SUCCESS then
    lbEvents.Items.Add('Write IP settings failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btResetIpSettingsClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiSoftAP.ResetIpSettings;
  if Res <> WCL_E_SUCCESS then
    lbEvents.Items.Add('Reset IP settings failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclWiFiSoftAP := TwclWiFiSoftAP.Create(nil);
  wclWiFiSoftAP.OnDeviceAccept := wclWiFiSoftAPDeviceAccept;
  wclWiFiSoftAP.OnDeviceConnected := wclWiFiSoftAPDeviceConnected;
  wclWiFiSoftAP.OnDeviceConnectError := wclWiFiSoftAPDeviceConnectError;
  wclWiFiSoftAP.OnDeviceDisconnected := wclWiFiSoftAPDeviceDisconnected;
  wclWiFiSoftAP.OnStarted := wclWiFiSoftAPStarted;
  wclWiFiSoftAP.OnStopped := wclWiFiSoftAPStopped;
end;

end.
