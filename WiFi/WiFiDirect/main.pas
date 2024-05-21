unit main;

{$MODE Delphi}

interface

uses
  Forms, wclWiFi, Classes, Controls, StdCtrls, ComCtrls;

type
  TfmMain = class(TForm)
    cbAutonomousGroupOwner: TCheckBox;
    cbDisplayPin: TCheckBox;
    cbProvidePin: TCheckBox;
    cbPushButton: TCheckBox;
    laDiscoverability: TLabel;
    cbDiscoverability: TComboBox;
    btStart: TButton;
    btStop: TButton;
    lbLog: TListBox;
    laPairingProcedure: TLabel;
    cbPairingProcedure: TComboBox;
    laGroupOwnerIntent: TLabel;
    edGroupOwnerIntent: TEdit;
    laConfigurationMethods: TLabel;
    lvDevices: TListView;
    btClear: TButton;
    btDisconnect: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    WiFiDirectAdvertiser: TwclWiFiDirectAdvertiser;

    function GetItem(const Id: string): TListItem;

    procedure WiFiDirectAdvertiserStarted(Sender: TObject);
    procedure WiFiDirectAdvertiserStopped(Sender: TObject);
    procedure WiFiDirectAdvertiserAcceptDevice(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Accept: Boolean);
    procedure WiFiDirectAdvertiserDeviceConnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Error: Integer);
    procedure WiFiDirectAdvertiserDeviceDisconnected(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Reason: Integer);
    procedure WiFiDirectAdvertiserPairCompleted(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Result: Integer);
    procedure WiFiDirectAdvertiserPairConfirm(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Confirm: Boolean);
    procedure WiFiDirectAdvertiserPairDisplayPin(Sender: TObject;
      const Device: TwclWiFiDirectDevice; const Pin: String);
    procedure WiFiDirectAdvertiserPairGetParams(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out GroupOwnerIntent: Smallint;
      out ConfigurationMethods: TwclWiFiDirectConfigurationMethods;
      out PairingProcedure: TwclWiFiDirectPairingProcedure);
    procedure WiFiDirectAdvertiserPairProvidePin(Sender: TObject;
      const Device: TwclWiFiDirectDevice; out Pin: String);
  end;

var
  fmMain: TfmMain;

implementation

uses
  Dialogs, SysUtils, wclErrors;

{$R *.lfm}

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  WiFiDirectAdvertiser.Stop;
  WiFiDirectAdvertiser.Free;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  i: Integer;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    for i := 0 to WiFiDirectAdvertiser.Count - 1 do begin
      if WiFiDirectAdvertiser[i].Id = lvDevices.Selected.SubItems[0] then
      begin
        Res := WiFiDirectAdvertiser[i].Disconnect;
        if Res <> WCL_E_SUCCESS then begin
          MessageDlg('Disconnect error: 0x' + IntToHex(Res, 8), mtError,
            [mbOK], 0);
        end;

        Break;
      end;
    end;
  end;
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := WiFiDirectAdvertiser.Stop;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Stop error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  if WiFiDirectAdvertiser.Active then
    MessageDlg('Already running', mtWarning, [mbOK], 0)

  else begin
    case cbDiscoverability.ItemIndex of
      0: WiFiDirectAdvertiser.Discoverability := adIntensive;
      1: WiFiDirectAdvertiser.Discoverability := adNone;
      2: WiFiDirectAdvertiser.Discoverability := adNormal;
    end;
    WiFiDirectAdvertiser.AutonomousGroupOwnerEnabled :=
      cbAutonomousGroupOwner.Checked;

    Res := WiFiDirectAdvertiser.Start;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Start error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

function TfmMain.GetItem(const Id: string): TListItem;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to lvDevices.Items.Count - 1 do begin
    if lvDevices.Items[i].SubItems[0] = Id then begin
      Result := lvDevices.Items[i];
      Break;
    end;
  end;
end;

procedure TfmMain.WiFiDirectAdvertiserStarted(Sender: TObject);
begin
  lbLog.Items.Add('Advertiser has been started');
end;

procedure TfmMain.WiFiDirectAdvertiserStopped(Sender: TObject);
begin
  lvDevices.Items.Clear;

  lbLog.Items.Add('Advertiser has been stopped');
end;

procedure TfmMain.WiFiDirectAdvertiserAcceptDevice(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Accept: Boolean);
var
  Item: TListItem;
begin
  lbLog.Items.Add('Accepting device ' + Device.Id);
  Accept := MessageDlg('Accept connection from ' + Device.Name + '?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes;
  if Accept then begin
    Item := lvDevices.Items.Add;
    Item.Caption := Device.Name;
    Item.SubItems.Add(Device.Id);
    Item.SubItems.Add('Connecting');
  end;
end;

procedure TfmMain.WiFiDirectAdvertiserDeviceConnected(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Error: Integer);
var
  Item: TListItem;
begin
  Item := GetItem(Device.Id);
  if Item <> nil then begin
    if Error = WCL_E_SUCCESS then begin
      Item.SubItems[1] := 'Connected';

      lbLog.Items.Add(Device.Name + ' connected');
      lbLog.Items.Add('  Local IP: ' + Device.LocalAddress);
      lbLog.Items.Add('  Remote IP: ' + Device.RemoteAddress);

    end else begin
      lbLog.Items.Add(Device.Name + ' connect error: 0x' + IntToHex(Error, 8));
      Item.Delete;
    end;
  end;
end;

procedure TfmMain.WiFiDirectAdvertiserDeviceDisconnected(
  Sender: TObject; const Device: TwclWiFiDirectDevice;
  const Reason: Integer);
var
  Item: TListItem;
begin
  Item := GetItem(Device.Id);
  if Item <> nil then begin
    lbLog.Items.Add(Device.Name + ' disconnected. Reason: 0x' + IntToHex(Reason, 8));
    Item.Delete;
  end;
end;

procedure TfmMain.WiFiDirectAdvertiserPairCompleted(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Result: Integer);
begin
  lbLog.Items.Add(Device.Name + ' paired. Result: 0x' + IntToHex(Result, 8));
end;

procedure TfmMain.WiFiDirectAdvertiserPairConfirm(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Confirm: Boolean);
begin
  Confirm := MessageDlg('Confirm ' + Device.Name + ' connection',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TfmMain.WiFiDirectAdvertiserPairDisplayPin(Sender: TObject;
  const Device: TwclWiFiDirectDevice; const Pin: String);
begin
  MessageDlg('Use ' + Pin + ' PIN to pair with ' + Device.Name,
    mtInformation, [mbOK], 0);
end;

procedure TfmMain.WiFiDirectAdvertiserPairGetParams(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out GroupOwnerIntent: Smallint;
  out ConfigurationMethods: TwclWiFiDirectConfigurationMethods;
  out PairingProcedure: TwclWiFiDirectPairingProcedure);
begin
  lbLog.Items.Add(Device.Name + ' quering pairing params');

  case cbPairingProcedure.ItemIndex of
    0: PairingProcedure := ppInvitation;
    1: PairingProcedure := ppGroupOwnerNegotiation;
  end;
  GroupOwnerIntent := StrToInt(edGroupOwnerIntent.Text);
  ConfigurationMethods := [];
  if cbDisplayPin.Checked then
    ConfigurationMethods := ConfigurationMethods + [cmDisplayPin];
  if cbProvidePin.Checked then
    ConfigurationMethods := ConfigurationMethods + [cmProvidePin];
  if cbPushButton.Checked then
    ConfigurationMethods := ConfigurationMethods + [cmPushButton];
end;

procedure TfmMain.WiFiDirectAdvertiserPairProvidePin(Sender: TObject;
  const Device: TwclWiFiDirectDevice; out Pin: String);
begin
  Pin := '';
  InputQuery('Pairing', 'Enter PIN for ' + Device.Name, Pin);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  WiFiDirectAdvertiser := TwclWiFiDirectAdvertiser.Create(nil);
  WiFiDirectAdvertiser.OnStarted := WiFiDirectAdvertiserStarted;
  WiFiDirectAdvertiser.OnStopped := WiFiDirectAdvertiserStopped;
  WiFiDirectAdvertiser.OnAcceptDevice := WiFiDirectAdvertiserAcceptDevice;
  WiFiDirectAdvertiser.OnDeviceConnected := WiFiDirectAdvertiserDeviceConnected;
  WiFiDirectAdvertiser.OnDeviceDisconnected := WiFiDirectAdvertiserDeviceDisconnected;
  WiFiDirectAdvertiser.OnPairCompleted := WiFiDirectAdvertiserPairCompleted;
  WiFiDirectAdvertiser.OnPairConfirm := WiFiDirectAdvertiserPairConfirm;
  WiFiDirectAdvertiser.OnPairDisplayPin := WiFiDirectAdvertiserPairDisplayPin;
  WiFiDirectAdvertiser.OnPairGetParams := WiFiDirectAdvertiserPairGetParams;
  WiFiDirectAdvertiser.OnPairProvidePin := WiFiDirectAdvertiserPairProvidePin;
end;

end.
