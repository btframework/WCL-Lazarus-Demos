unit main;

{$I wcl.inc}

interface

uses
  Forms, Classes, wclWiFi, StdCtrls, Controls, ComCtrls;

type

  { TfmMain }

  TfmMain = class(TForm)
    lvDevices: TListView;
    btDiscover: TButton;
    btTerminate: TButton;
    lbLog: TListBox;
    btClear: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    cbDisplayPin: TCheckBox;
    cbProvidePin: TCheckBox;
    cbPushButton: TCheckBox;
    edGroupOwnerIntent: TEdit;
    laGroupOwnerIntent: TLabel;
    laPairingProcedure: TLabel;
    cbPairingProcedure: TComboBox;
    procedure btDiscoverClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);

  private
    wclWiFiDirectDeviceWatcher: TwclWiFiDirectDeviceWatcher;
    wclWiFiDirectClient: TwclWiFiDirectClient;

    procedure wclWiFiDirectDeviceWatcherDiscoveringCompleted(
      Sender: TObject; const Error: Integer);
    procedure wclWiFiDirectDeviceWatcherDiscoveringStarted(
      Sender: TObject);
    procedure wclWiFiDirectDeviceWatcherDeviceFound(Sender: TObject;
      const Id: string; const Name: string);

    procedure wclWiFiDirectClientPairCompleted(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Result: Integer);
    procedure wclWiFiDirectClientPairConfirm(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Confirm: Boolean);
    procedure wclWiFiDirectClientPairDisplayPin(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Pin: String);
    procedure wclWiFiDirectClientPairGetParams(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out GroupOwnerIntent: Smallint;
      out ConfigurationMethods: TwclWiFiDirectConfigurationMethods;
      out PairingProcedure: TwclWiFiDirectPairingProcedure);
    procedure wclWiFiDirectClientPairProvidePin(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Pin: String);
    procedure wclWiFiDirectClientDeviceConnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Error: Integer);
    procedure wclWiFiDirectClientDeviceDisconnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Reason: Integer);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

procedure TfmMain.wclWiFiDirectDeviceWatcherDeviceFound(Sender: TObject;
  const Id: string; const Name: string);
var
  Item: TListItem;
begin
  Item := lvDevices.Items.Add;
  Item.Caption := Name;
  Item.SubItems.Add(Id);

  lbLog.Items.Add('Device found');
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiDirectDeviceWatcher.Discover;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Discover error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btTerminateClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiDirectDeviceWatcher.Terminate;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Terminate error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclWiFiDirectDeviceWatcher := TwclWiFiDirectDeviceWatcher.Create(nil);
  wclWiFiDirectDeviceWatcher.OnDeviceFound := wclWiFiDirectDeviceWatcherDeviceFound;
  wclWiFiDirectDeviceWatcher.OnDiscoveringCompleted := wclWiFiDirectDeviceWatcherDiscoveringCompleted;
  wclWiFiDirectDeviceWatcher.OnDiscoveringStarted := wclWiFiDirectDeviceWatcherDiscoveringStarted;

  wclWiFiDirectClient := TwclWiFiDirectClient.Create(nil);
  wclWiFiDirectClient.OnDeviceConnected := wclWiFiDirectClientDeviceConnected;
  wclWiFiDirectClient.OnDeviceDisconnected := wclWiFiDirectClientDeviceDisconnected;
  wclWiFiDirectClient.OnPairCompleted := wclWiFiDirectClientPairCompleted;
  wclWiFiDirectClient.OnPairConfirm := wclWiFiDirectClientPairConfirm;
  wclWiFiDirectClient.OnPairDisplayPin := wclWiFiDirectClientPairDisplayPin;
  wclWiFiDirectClient.OnPairGetParams := wclWiFiDirectClientPairGetParams;
  wclWiFiDirectClient.OnPairProvidePin := wclWiFiDirectClientPairProvidePin;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclWiFiDirectClient.Disconnect;
  wclWiFiDirectClient.Free;

  wclWiFiDirectDeviceWatcher.Terminate;
  wclWiFiDirectDeviceWatcher.Free;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.wclWiFiDirectDeviceWatcherDiscoveringCompleted(
  Sender: TObject; const Error: Integer);
begin
  lbLog.Items.Add('Discovering completed with result: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.wclWiFiDirectDeviceWatcherDiscoveringStarted(
  Sender: TObject);
begin
  lvDevices.Items.Clear;
  lbLog.Items.Add('Discovering started');
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiFiDirectClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Disconnect error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Res := wclWiFiDirectClient.Connect(lvDevices.Selected.SubItems[0]);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Connect Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.wclWiFiDirectClientPairCompleted(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Result: Integer);
begin
  lbLog.Items.Add('Pairing completed with result: 0x' + IntToHex(Result, 8));
end;

procedure TfmMain.wclWiFiDirectClientPairConfirm(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Confirm: Boolean);
begin
  Confirm := MessageDlg('Confirm pairing', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes;
end;

procedure TfmMain.wclWiFiDirectClientPairDisplayPin(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Pin: String);
begin
  MessageDlg('Use PIN: ' + Pin, mtInformation, [mbOK], 0);
end;

procedure TfmMain.wclWiFiDirectClientPairGetParams(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out GroupOwnerIntent: Smallint;
  out ConfigurationMethods: TwclWiFiDirectConfigurationMethods;
  out PairingProcedure: TwclWiFiDirectPairingProcedure);
begin
  GroupOwnerIntent := StrToInt(edGroupOwnerIntent.Text);

  ConfigurationMethods := [];
  if cbDisplayPin.Checked then
    ConfigurationMethods := ConfigurationMethods + [cmDisplayPin];
  if cbProvidePin.Checked then
    ConfigurationMethods := ConfigurationMethods + [cmProvidePin];
  if cbPushButton.Checked then
    ConfigurationMethods := ConfigurationMethods + [cmPushButton];

  if cbPairingProcedure.ItemIndex = 0 then
    PairingProcedure := ppInvitation
  else
    PairingProcedure := ppGroupOwnerNegotiation;
end;

procedure TfmMain.wclWiFiDirectClientPairProvidePin(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Pin: String);
begin
  Pin := InputBox('Enter PIN', 'PIN', '');
end;

procedure TfmMain.wclWiFiDirectClientDeviceConnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Error: Integer);
begin
  lbLog.Items.Add('Connected with result: 0x' + IntToHex(Error, 8));
  if Error = WCL_E_SUCCESS then begin
    lbLog.Items.Add('  Local IP: ' + wclWiFiDirectClient.LocalAddress);
    lbLog.Items.Add('  Remote IP: ' + wclWiFiDirectClient.RemoteAddress);
  end;
end;

procedure TfmMain.wclWiFiDirectClientDeviceDisconnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Reason: Integer);
begin
  lbLog.Items.Add('Disconnected. Reason: 0x' + IntToHex(Reason, 8));
end;

end.
