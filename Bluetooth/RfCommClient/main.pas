unit main;

{$MODE Delphi}

interface

uses
  Forms, Controls, ComCtrls, Classes, StdCtrls, wclBluetooth;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    lvDevices: TListView;
    btClearEvents: TButton;
    laTimeout: TLabel;
    edTimeout: TEdit;
    laMilliseconds: TLabel;
    edText: TEdit;
    btSend: TButton;
    laReadBuffer: TLabel;
    edReadBuffer: TEdit;
    laWriteBuffer: TLabel;
    edWriteBuffer: TEdit;
    btSetBuffers: TButton;
    lbEvents: TListBox;
    cbAuthentication: TCheckBox;
    cbEncryption: TCheckBox;
    btGetBuffers: TButton;
    cbServiceName: TCheckBox;
    edServiceName: TEdit;
    btPair: TButton;
    cbEnumPaired: TCheckBox;
    btUnpair: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btDiscoverClick(Sender: TObject);
    procedure btClearEventsClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure btSetBuffersClick(Sender: TObject);
    procedure btGetBuffersClick(Sender: TObject);
    procedure btPairClick(Sender: TObject);
    procedure btUnpairClick(Sender: TObject);

  private
    BluetoothManager: TwclBluetoothManager;
    RfCommClient: TwclRfCommClient;

    function GetRadio: TwclBluetoothRadio;

    procedure GetBuffers;

    procedure BluetoothManagerNumericComparison(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Number: Cardinal; out Confirm: Boolean);
    procedure BluetoothManagerPasskeyNotification(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Passkey: Cardinal);
    procedure BluetoothManagerPasskeyRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Passkey: Cardinal);
    procedure BluetoothManagerPinRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Pin: String);
    procedure BluetoothManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);
    procedure BluetoothManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);
    procedure BluetoothManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);
    procedure BluetoothManagerConfirm(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Confirm: Boolean);
    procedure BluetoothManagerAuthenticationCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Error: Integer);

    procedure RfCommClientConnect(Sender: TObject;
      const Error: Integer);
    procedure RfCommClientData(Sender: TObject; const Data: Pointer;
      const Size: Cardinal);
    procedure RfCommClientDisconnect(Sender: TObject;
      const Reason: Integer);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils, Dialogs, Windows, wclUUIDs;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  BluetoothManager := TwclBluetoothManager.Create(nil);
  BluetoothManager.OnNumericComparison := BluetoothManagerNumericComparison;
  BluetoothManager.OnPasskeyNotification := BluetoothManagerPasskeyNotification;
  BluetoothManager.OnPasskeyRequest := BluetoothManagerPasskeyRequest;
  BluetoothManager.OnPinRequest := BluetoothManagerPinRequest;
  BluetoothManager.OnDeviceFound := BluetoothManagerDeviceFound;
  BluetoothManager.OnDiscoveringCompleted := BluetoothManagerDiscoveringCompleted;
  BluetoothManager.OnDiscoveringStarted := BluetoothManagerDiscoveringStarted;
  BluetoothManager.OnConfirm := BluetoothManagerConfirm;
  BluetoothManager.OnAuthenticationCompleted := BluetoothManagerAuthenticationCompleted;

  RfCommClient := TwclRfCommClient.Create(nil);
  RfCommClient.OnConnect := RfCommClientConnect;
  RfCommClient.OnData := RfCommClientData;
  RfCommClient.OnDisconnect := RfCommClientDisconnect;

  // In real application you should always analize the result code.
  // In this demo we assume that all is always OK.
  BluetoothManager.Open;

  cbAuthentication.Checked := RfCommClient.Authentication;
  cbEncryption.Checked := RfCommClient.Encryption;
end;

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := BluetoothManager.GetClassicRadio(Radio);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Get working radio failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
    Result := nil;
  end else
    Result := Radio;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  RfCommClient.Disconnect;
  RfCommClient.Free;

  BluetoothManager.Close;
  BluetoothManager.Free;
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
  Devices: TwclBluetoothAddresses;
  i: Integer;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    if cbEnumPaired.Checked then begin
      Res := Radio.EnumPairedDevices(Devices);
      if Res <> WCL_E_SUCCESS then begin
        MessageDlg('Enum paired devices failed: 0x' + IntToHex(Res, 8),
          mtError, [mbOK], 0);

      end else begin
        lvDevices.Items.Clear;
        if Length(Devices) > 0 then begin
          for i := 0 to Length(Devices) - 1 do
            BluetoothManagerDeviceFound(BluetoothManager, Radio, Devices[i]);
          BluetoothManagerDiscoveringCompleted(BluetoothManager, Radio,
            WCL_E_SUCCESS);
        end;
      end;

    end else begin
      Res := Radio.Discover(10, dkClassic);
      if Res <> WCL_E_SUCCESS then begin
        MessageDlg('Error starting discovering: 0x' + IntToHex(Res, 8),
          mtError, [mbOK], 0);
      end;
    end;
  end;
end;

procedure TfmMain.btClearEventsClick(Sender: TObject);
begin
  lbEvents.Clear;
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
  Services: TwclBluetoothServices;
  Connect: Boolean;
  i: Integer;
  Service: TGUID;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Radio := GetRadio;
    if Radio <> nil then begin
      RfCommClient.Address := StrToInt64('$' + lvDevices.Selected.Caption);
      RfCommClient.Authentication := cbAuthentication.Checked;
      RfCommClient.Encryption := cbEncryption.Checked;
      RfCommClient.Timeout := StrToInt(edTimeout.Text);

      RfCommClient.Channel := 0;
      RfCommClient.Service := SerialPortServiceClass_UUID;
      
      Connect := False;
      if cbServiceName.Checked then begin
        Service := RfCommClient.Service;
        Res := Radio.EnumRemoteServices(RfCommClient.Address,
          @Service, // Se are looking for specified services only!
          Services);
        if Res <> WCL_E_SUCCESS then
          MessageDlg('Service enumerating error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)

        else begin
          if Length(Services) = 0 then
            ShowMessage('Services not found')

          else begin
            for i := 0 to Length(Services) - 1 do begin
              if Services[i].Name = edServiceName.Text then begin
                RfCommClient.Channel := Services[i].Channel;
                Connect := True;
                Break;
              end;
            end;

            if not Connect then
              ShowMessage('Service not found');
          end;
        end;
      end else
        Connect := True;

      if Connect then begin
        Res := RfCommClient.Connect(Radio);
        if Res <> WCL_E_SUCCESS then
          MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
      end;
    end;
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := RfCommClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btSendClick(Sender: TObject);
var
  Ansi: AnsiString;
  Res: Integer;
  Sent: Cardinal;
begin
  Ansi := AnsiString(edText.Text);
  Res := RfCommClient.Write(PByte(Ansi), Length(Ansi), Sent);
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
  else begin
    MessageDlg('Sent: ' + IntToStr(Sent) + ' from ' + IntToStr(Length(Ansi)),
      mtInformation, [mbOK], 0);
  end;
end;

procedure TfmMain.btSetBuffersClick(Sender: TObject);
var
  Res: Integer;
  Size: Cardinal;
begin
  // Try to set read buffer size first.
  Size := StrToInt(edReadBuffer.Text);
  Res := RfCommClient.SetReadBufferSize(Size);
  if Res = WCL_E_SUCCESS then
    lbEvents.Items.Add('Read buffer size changed.')
  else
    lbEvents.Items.Add('Set read buffer size error: 0x' + IntToHex(Res, 8));

  // Now write buffer.
  Size := StrToInt(edWriteBuffer.Text);
  Res := RfCommClient.SetWriteBufferSize(Size);
  if Res = WCL_E_SUCCESS then
    lbEvents.Items.Add('Write buffer size changed.')
  else
    lbEvents.Items.Add('Set write buffer size error: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btGetBuffersClick(Sender: TObject);
begin
  GetBuffers;
end;

procedure TfmMain.GetBuffers;
var
  Res: Integer;
  Size: Cardinal;
begin
  // Try to get read and write buffers size.
  Size := 0;

  Res := RfCommClient.GetReadBufferSize(Size);
  if Res <> WCL_E_SUCCESS then
    lbEvents.Items.Add('Get read buffer error: 0x' + IntToHex(Res, 8))
  else
    edReadBuffer.Text := IntToStr(Size);

  Size := 0;
  Res := RfCommClient.GetWriteBufferSize(Size);
  if Res <> WCL_E_SUCCESS then
    lbEvents.Items.Add('Get write buffer error: 0x' + IntToHex(Res, 8))
  else
    edWriteBuffer.Text := IntToStr(Size);
end;

procedure TfmMain.BluetoothManagerNumericComparison(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Number: Cardinal; out Confirm: Boolean);
begin
  // Accept any pairing.
  Confirm := True;
  lbEvents.Items.Add('Numeric comparison: ' + IntToStr(Number));
end;

procedure TfmMain.BluetoothManagerPasskeyNotification(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Passkey: Cardinal);
begin
  lbEvents.Items.Add('Passkey notification: ' + IntToStr(Passkey));
end;

procedure TfmMain.BluetoothManagerPasskeyRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Passkey: Cardinal);
begin
  // Use 123456 as passkey.
  Passkey := 123456;
  lbEvents.Items.Add('Passkey request: ' + IntToStr(Passkey));
end;

procedure TfmMain.BluetoothManagerPinRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64; out Pin: String);
begin
  // Use '0000' as PIN.
  Pin := '0000';
  lbEvents.Items.Add('Pin request: ' + Pin);
end;

procedure TfmMain.BluetoothManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
var
  Item: TListItem;
  DevType: TwclBluetoothDeviceType;
  Res: Integer;
begin
  DevType := dtMixed;
  Res := Radio.GetRemoteDeviceType(Address, DevType);

  Item := lvDevices.Items.Add;
  Item.Caption := IntToHex(Address, 12);
  Item.SubItems.Add(''); // We can not read a device's name here.
  Item.Data := Radio; // To use it later.
  if Res <> WCL_E_SUCCESS then
    Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8))
  else begin
    case DevType of
      dtClassic:
        Item.SubItems.Add('Classic');
      dtBle:
        Item.SubItems.Add('BLE');
      dtMixed:
        Item.SubItems.Add('Mixed');
    else
      Item.SubItems.Add('Unknown');
    end;
  end;

  lbEvents.Items.Add('Device found: ' + IntToHex(Address, 12));
end;

procedure TfmMain.BluetoothManagerDiscoveringCompleted(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Error: Integer);
var
  i: Integer;
  Item: TListItem;
  Address: Int64;
  Res: Integer;
  DevName: string;
begin
  if lvDevices.Items.Count = 0 then
    MessageDlg('No devices were found.', mtInformation, [mbOK], 0)

  else begin
    // Here we can update found devices names.
    for i := 0 to lvDevices.Items.Count - 1 do begin
      Item := lvDevices.Items[i];

      Address := StrToInt64('$' + Item.Caption);
      Res := Radio.GetRemoteName(Address, DevName);
      if Res <> WCL_E_SUCCESS then
        Item.SubItems[0] := 'Error: 0x' + IntToHex(Res, 8)
      else
        Item.SubItems[0] := DevName;
    end;
  end;

  lbEvents.Items.Add('Discovering completed');
end;

procedure TfmMain.BluetoothManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  lvDevices.Items.Clear;
  lbEvents.Items.Add('Discovering started');
end;

procedure TfmMain.RfCommClientConnect(Sender: TObject;
  const Error: Integer);
begin
  if Error = WCL_E_SUCCESS then begin
    lbEvents.Items.Add('Connected');

    GetBuffers;

  end else
    lbEvents.Items.Add('Connect error: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.RfCommClientData(Sender: TObject; const Data: Pointer;
  const Size: Cardinal);
var
  Str: AnsiString;
begin
  if Size > 0 then begin
    Str := '';
    SetLength(Str, Size);
    CopyMemory(Pointer(Str), Data, Size);

    lbEvents.Items.Add('Received: ' + string(Str));
  end;
end;

procedure TfmMain.RfCommClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  lbEvents.Items.Add('Disconnected: 0x' + IntToHex(Reason, 8));

  edReadBuffer.Text := '0';
  edWriteBuffer.Text := '0';
end;

procedure TfmMain.BluetoothManagerConfirm(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Confirm: Boolean);
begin
  Confirm := True;
  lbEvents.Items.Add('Just works pairing');
end;

procedure TfmMain.BluetoothManagerAuthenticationCompleted(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  const Error: Integer);
begin
  lbEvents.Items.Add('Authentication completed: ' + IntToHex(Error, 8));
end;

procedure TfmMain.btPairClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Radio := GetRadio;
    if Radio <> nil then begin
      Res := Radio.RemotePair(StrToInt64('$' + lvDevices.Selected.Caption),
        pmClassic);
      if Res <> WCL_E_SUCCESS then
        ShowMessage('Pair failed: 0x' + IntToHex(Res, 8));
    end;
  end;
end;

procedure TfmMain.btUnpairClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Radio := GetRadio;
    if Radio <> nil then begin
      Res := Radio.RemoteUnpair(StrToInt64('$' + lvDevices.Selected.Caption),
        pmClassic);
      if Res <> WCL_E_SUCCESS then
        ShowMessage('Unpair failed: 0x' + IntToHex(Res, 8));
    end;
  end;
end;

end.
