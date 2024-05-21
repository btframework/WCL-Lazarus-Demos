unit main;

{$MODE Delphi}

interface

uses
  Forms, Classes, wclWiFi, StdCtrls, Controls, ComCtrls;

type
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
    btIsPaired: TButton;
    btUnpair: TButton;
    btEnumPaired: TButton;
    procedure btDiscoverClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btIsPairedClick(Sender: TObject);
    procedure btUnpairClick(Sender: TObject);
    procedure btEnumPairedClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    WiFiDirectDeviceWatcher: TwclWiFiDirectDeviceWatcher;
    WiFiDirectClient: TwclWiFiDirectClient;

    procedure WiFiDirectDeviceWatcherDeviceFound(Sender: TObject;
      const Id: string; const Name: string);
    procedure WiFiDirectDeviceWatcherDiscoveringCompleted(
      Sender: TObject; const Error: Integer);
    procedure WiFiDirectDeviceWatcherDiscoveringStarted(
      Sender: TObject);

    procedure WiFiDirectClientPairCompleted(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Result: Integer);
    procedure WiFiDirectClientPairConfirm(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Confirm: Boolean);
    procedure WiFiDirectClientPairDisplayPin(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Pin: String);
    procedure WiFiDirectClientPairGetParams(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out GroupOwnerIntent: Smallint;
      out ConfigurationMethods: TwclWiFiDirectConfigurationMethods;
      out PairingProcedure: TwclWiFiDirectPairingProcedure);
    procedure WiFiDirectClientPairProvidePin(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Pin: String);
    procedure WiFiDirectClientDeviceConnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Error: Integer);
    procedure WiFiDirectClientDeviceDisconnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Reason: Integer);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

procedure TfmMain.WiFiDirectDeviceWatcherDeviceFound(Sender: TObject;
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
  Res := WiFiDirectDeviceWatcher.Discover;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Discover error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btTerminateClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := WiFiDirectDeviceWatcher.Terminate;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Terminate error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  WiFiDirectClient.Disconnect;
  WiFiDirectDeviceWatcher.Terminate;

  WiFiDirectClient.Free;
  WiFiDirectDeviceWatcher.Free;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.WiFiDirectDeviceWatcherDiscoveringCompleted(
  Sender: TObject; const Error: Integer);
begin
  lbLog.Items.Add('Discovering completed with result: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.WiFiDirectDeviceWatcherDiscoveringStarted(
  Sender: TObject);
begin
  lvDevices.Items.Clear;
  lbLog.Items.Add('Discovering started');
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := WiFiDirectClient.Disconnect;
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
    Res := WiFiDirectClient.Connect(lvDevices.Selected.SubItems[0]);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Connect Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.WiFiDirectClientPairCompleted(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Result: Integer);
begin
  lbLog.Items.Add('Pairing completed with result: 0x' + IntToHex(Result, 8));
end;

procedure TfmMain.WiFiDirectClientPairConfirm(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Confirm: Boolean);
begin
  Confirm := MessageDlg('Confirm pairing', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes;
end;

procedure TfmMain.WiFiDirectClientPairDisplayPin(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Pin: String);
begin
  MessageDlg('Use PIN: ' + Pin, mtInformation, [mbOK], 0);
end;

procedure TfmMain.WiFiDirectClientPairGetParams(Sender: TObject;
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

procedure TfmMain.WiFiDirectClientPairProvidePin(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Pin: String);
begin
  Pin := InputBox('Enter PIN', 'PIN', '');
end;

procedure TfmMain.WiFiDirectClientDeviceConnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Error: Integer);
begin
  lbLog.Items.Add('Connected with result: 0x' + IntToHex(Error, 8));
  if Error = WCL_E_SUCCESS then begin
    lbLog.Items.Add('  Local IP: ' + WiFiDirectClient.LocalAddress);
    lbLog.Items.Add('  Remote IP: ' + WiFiDirectClient.RemoteAddress);
  end;
end;

procedure TfmMain.WiFiDirectClientDeviceDisconnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Reason: Integer);
begin
  lbLog.Items.Add('Disconnected. Reason: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.btIsPairedClick(Sender: TObject);
var
  Res: Integer;
  IsPaired: Boolean;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)
  else begin
    Res := WiFiDirectDeviceWatcher.IsPaired(lvDevices.Selected.SubItems[0],
      IsPaired);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Get paired error: 0x' + IntToHex(Res, 8))
    else begin
      if IsPaired then
        ShowMessage('Device is paired')
      else
        ShowMessage('Device is NOT paired');
    end;
  end;
end;

procedure TfmMain.btUnpairClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)
  else begin
    Res := WiFiDirectDeviceWatcher.Unpair(lvDevices.Selected.SubItems[0]);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Unpair error: 0x' + IntToHex(Res, 8))
    else
      ShowMessage('Unpaired');
  end;
end;

procedure TfmMain.btEnumPairedClick(Sender: TObject);
var
  Paired: TStringList;
  Res: Integer;
  i: Integer;
  Item: TListItem;
begin
  Paired := TStringList.Create;
  Res := WiFiDirectDeviceWatcher.EnumPairedDevices(Paired);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Enum paired error: 0x' + IntToHex(Res, 8))

  else begin
    lvDevices.Items.Clear;

    if Paired.Count > 0 then begin
      for i := 0 to Paired.Count - 1 do begin
        Item := lvDevices.Items.Add;
        Item.Caption := '';
        Item.SubItems.Add(Paired[i]);
      end;
    end;
  end;
  Paired.Free;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  WiFiDirectDeviceWatcher := TwclWiFiDirectDeviceWatcher.Create(nil);
  WiFiDirectDeviceWatcher.OnDeviceFound := WiFiDirectDeviceWatcherDeviceFound;
  WiFiDirectDeviceWatcher.OnDiscoveringCompleted := WiFiDirectDeviceWatcherDiscoveringCompleted;
  WiFiDirectDeviceWatcher.OnDiscoveringStarted := WiFiDirectDeviceWatcherDiscoveringStarted;

  WiFiDirectClient := TwclWiFiDirectClient.Create(nil);
  WiFiDirectClient.OnPairCompleted := WiFiDirectClientPairCompleted;
  WiFiDirectClient.OnPairConfirm := WiFiDirectClientPairConfirm;
  WiFiDirectClient.OnPairDisplayPin := WiFiDirectClientPairDisplayPin;
  WiFiDirectClient.OnPairGetParams := WiFiDirectClientPairGetParams;
  WiFiDirectClient.OnPairProvidePin := WiFiDirectClientPairProvidePin;
  WiFiDirectClient.OnDeviceConnected := WiFiDirectClientDeviceConnected;
  WiFiDirectClient.OnDeviceDisconnected := WiFiDirectClientDeviceDisconnected;
end;

end.
