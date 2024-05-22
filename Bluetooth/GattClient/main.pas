unit main;

{$MODE Delphi}

interface

uses
  Forms, wclBluetooth, Classes, StdCtrls, Controls, ComCtrls;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    lvDevices: TListView;
    lvEvents: TListView;
    btClearEvents: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    lvServices: TListView;
    btGetServices: TButton;
    btGetIncludedServices: TButton;
    btGetCharacteristics: TButton;
    lvCharacteristics: TListView;
    btGetCharValue: TButton;
    btGetDescriptors: TButton;
    lvDescriptors: TListView;
    btGetDescValue: TButton;
    lvDescriptorValue: TListView;
    btSetValue: TButton;
    laCharVal: TLabel;
    edCharVal: TEdit;
    btSubscribe: TButton;
    btUnsubscribe: TButton;
    laOperationFlag: TLabel;
    cbOperationFlag: TComboBox;
    btCCCDSubscribe: TButton;
    btCCCDUnsubscribe: TButton;
    btTerminate: TButton;
    laProtection: TLabel;
    cbProtection: TComboBox;
    cbConnectOnRead: TCheckBox;
    btPair: TButton;
    cbFastSubscribe: TCheckBox;
    cbForceIndications: TCheckBox;
    btGetParams: TButton;
    btSetParams: TButton;
    cbParams: TComboBox;
    btGetMaxPduSize: TButton;
    btPhy: TButton;
    laWriteKind: TLabel;
    cbWriteKind: TComboBox;
    laSubscribeKind: TLabel;
    cbSubscribeKind: TComboBox;
    laIoCap: TLabel;
    cbIoCap: TComboBox;
    cbMitmProtection: TComboBox;
    laMitmProtection: TLabel;
    btEnumPaired: TButton;
    btUnpair: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btDiscoverClick(Sender: TObject);
    procedure btClearEventsClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btGetServicesClick(Sender: TObject);
    procedure btGetIncludedServicesClick(Sender: TObject);
    procedure btGetCharacteristicsClick(Sender: TObject);
    procedure btGetCharValueClick(Sender: TObject);
    procedure btGetDescriptorsClick(Sender: TObject);
    procedure btGetDescValueClick(Sender: TObject);
    procedure btSetValueClick(Sender: TObject);
    procedure btSubscribeClick(Sender: TObject);
    procedure btUnsubscribeClick(Sender: TObject);
    procedure btCCCDSubscribeClick(Sender: TObject);
    procedure btCCCDUnsubscribeClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure btPairClick(Sender: TObject);
    procedure cbFastSubscribeClick(Sender: TObject);
    procedure btGetParamsClick(Sender: TObject);
    procedure btSetParamsClick(Sender: TObject);
    procedure btGetMaxPduSizeClick(Sender: TObject);
    procedure btPhyClick(Sender: TObject);
    procedure btUnpairClick(Sender: TObject);
    procedure btEnumPairedClick(Sender: TObject);

  private
    BluetoothManager: TwclBluetoothManager;
    GattClient: TwclGattClient;

    FCharacteristics: TwclGattCharacteristics;
    FDescriptors: TwclGattDescriptors;
    FServices: TwclGattServices;

    function GetRadio: TwclBluetoothRadio;
    function OpFlag: TwclGattOperationFlag;

    procedure Cleanup;

    procedure TraceEvent(const Address: Int64; const Event: string;
      const Param: string; const Value: string);

    procedure ListProp(const Name: string; const Value: string);

    function Protection: TwclGattProtectionLevel;

    procedure GetMaxPduSize;
    procedure GetConnectionParams;
    procedure GetConnectionPhy;

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
    procedure BluetoothManagerProtectionLevelRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Protection: TwclBluetoothLeProtectionLevel);
    procedure BluetoothManagerIoCapabilityRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Mitm: TwclBluetoothMitmProtection;
      out IoCapability: TwclBluetoothIoCapability;
      out OobPresent: Boolean);

    procedure GattClientCharacteristicChanged(Sender: TObject;
      const Handle: Word; const Value: TwclGattCharacteristicValue);
    procedure GattClientConnect(Sender: TObject; const Error: Integer);
    procedure GattClientDisconnect(Sender: TObject;
      const Reason: Integer);
    procedure GattClientConnectionParamsChanged(Sender: TObject);
    procedure GattClientMaxPduSizeChanged(Sender: TObject);
    procedure GattClientConnectionPhyChanged(Sender: TObject);
  end;

var
  fmMain: TfmMain;

implementation

uses
  Dialogs, SysUtils, wclErrors, wclHelpers;

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
  BluetoothManager.OnProtectionLevelRequest := BluetoothManagerProtectionLevelRequest;
  BluetoothManager.OnIoCapabilityRequest := BluetoothManagerIoCapabilityRequest;

  GattClient := TwclGattClient.Create(nil);
  GattClient.OnCharacteristicChanged := GattClientCharacteristicChanged;
  GattClient.OnConnect := GattClientConnect;
  GattClient.OnDisconnect := GattClientDisconnect;
  GattClient.OnConnectionParamsChanged := GattClientConnectionParamsChanged;
  GattClient.OnMaxPduSizeChanged := GattClientMaxPduSizeChanged;
  GattClient.OnConnectionPhyChanged := GattClientConnectionPhyChanged;

  BluetoothManager.Open;
  Cleanup;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  GattClient.Disconnect;
  GattClient.Free;

  BluetoothManager.Close;
  BluetoothManager.Free;

  Cleanup;
end;

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := BluetoothManager.GetLeRadio(Radio);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Get working radio failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
    Result := nil;
  end else
    Result := Radio;
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    Res := Radio.Discover(10, dkBle);
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Error starting discovering: 0x' + IntToHex(Res, 8),
        mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btClearEventsClick(Sender: TObject);
begin
  lvEvents.Items.Clear;
end;

procedure TfmMain.TraceEvent(const Address: Int64; const Event: string;
  const Param: string; const Value: string);
var
  Item: TListItem;
begin
  Item := lvEvents.Items.Add;
  if Address = 0 then
    Item.Caption := ''
  else
    Item.Caption := IntToHex(Address, 12);
  Item.SubItems.Add(Event);
  Item.SubItems.Add(Param);
  Item.SubItems.Add(Value);
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Res: Integer;
  Item: TListItem;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    try
      GattClient.Address := StrToInt64('$' + Item.Caption);
      GattClient.ConnectOnRead := cbConnectOnRead.Checked;
      GattClient.ForceNotifications := cbForceIndications.Checked;

      Res := GattClient.Connect(TwclBluetoothRadio(Item.Data));
      if Res <> WCL_E_SUCCESS then
        MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := GattClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btGetServicesClick(Sender: TObject);
var
  Res: Integer;
  Item: TListItem;
  i: Integer;
  Service: TwclGattService;
begin
  lvServices.Items.Clear;
  FServices := nil;

  Res := GattClient.ReadServices(OpFlag, FServices);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Exit;
  end;

  if FServices = nil then
    Exit;

  for i := 0 to Length(FServices) - 1 do begin
    Service := FServices[i];

    Item := lvServices.Items.Add;
    if Service.Uuid.IsShortUuid then
      Item.Caption := IntToHex(Service.Uuid.ShortUuid, 4)
    else
      Item.Caption := GUIDToString(Service.Uuid.LongUuid);
    Item.SubItems.Add(BoolToStr(Service.Uuid.IsShortUuid, True));
    Item.SubItems.Add(IntToHex(Service.Handle, 4));
  end;
end;

procedure TfmMain.btGetIncludedServicesClick(Sender: TObject);
var
  Res: Integer;
  Item: TListItem;
  i: Integer;
  Service: TwclGattService;
begin
  if lvServices.Selected = nil then begin
    MessageDlg('Select service', mtWarning, [mbOK], 0);
    Exit;
  end;

  Service := FServices[lvServices.Selected.Index];

  lvServices.Items.Clear;
  FServices := nil;

  Res := GattClient.ReadIncludedServices(Service, OpFlag, FServices);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Exit;
  end;

  if FServices = nil then
    Exit;

  for i := 0 to Length(FServices) - 1 do begin
    Service := FServices[i];

    Item := lvServices.Items.Add;
    if Service.Uuid.IsShortUuid then
      Item.Caption := IntToHex(Service.Uuid.ShortUuid, 4)
    else
      Item.Caption := GUIDToString(Service.Uuid.LongUuid);
    Item.SubItems.Add(BoolToStr(Service.Uuid.IsShortUuid, True));
    Item.SubItems.Add(IntToHex(Service.Handle, 4));
  end;
end;

procedure TfmMain.btGetCharacteristicsClick(Sender: TObject);
var
  Service: TwclGattService;
  Res: Integer;
  Item: TListItem;
  i: Integer;
  Character: TwclGattCharacteristic;
begin
  FCharacteristics := nil;
  lvCharacteristics.Items.Clear;

  if lvServices.Selected = nil then begin
    MessageDlg('Select service', mtWarning, [mbOK], 0);
    Exit;
  end;

  Service := FServices[lvServices.Selected.Index];
  Res := GattClient.ReadCharacteristics(Service, OpFlag, FCharacteristics);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Exit;
  end;

  if FCharacteristics = nil then
    Exit;

  for i := 0 to Length(FCharacteristics) - 1 do begin
    Character := FCharacteristics[i];

    Item := lvCharacteristics.Items.Add;
    if Character.Uuid.IsShortUuid then
      Item.Caption := IntToHex(Character.Uuid.ShortUuid, 4)
    else
      Item.Caption := GUIDToString(Character.Uuid.LongUuid);
    Item.SubItems.Add(BoolToStr(Character.Uuid.IsShortUuid, True));
    Item.SubItems.Add(IntToHex(Character.ServiceHandle, 4));
    Item.SubItems.Add(IntToHex(Character.Handle, 4));
    Item.SubItems.Add(IntToHex(Character.ValueHandle, 4));
    Item.SubItems.Add(BoolToStr(Character.IsBroadcastable, True));
    Item.SubItems.Add(BoolToStr(Character.IsReadable, True));
    Item.SubItems.Add(BoolToStr(Character.IsWritable, True));
    Item.SubItems.Add(BoolToStr(Character.IsWritableWithoutResponse, True));
    Item.SubItems.Add(BoolToStr(Character.IsSignedWritable, True));
    Item.SubItems.Add(BoolToStr(Character.IsNotifiable, True));
    Item.SubItems.Add(BoolToStr(Character.IsIndicatable, True));
    Item.SubItems.Add(BoolToStr(Character.HasExtendedProperties, True));
  end;
end;

procedure TfmMain.btGetCharValueClick(Sender: TObject);
var
  Characteristic: TwclGattCharacteristic;
  Res: Integer;
  Value: TwclGattCharacteristicValue;
  Str: string;
  i: Integer;
begin
  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];
  Res := GattClient.ReadCharacteristicValue(Characteristic, OpFlag, Value,
    Protection);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Exit;
  end;

  if Value = nil then
    Exit;

  if Length(Value) = 0 then
    MessageDlg('Value is empty', mtInformation, [mbOK], 0)

  else begin
    Str := '';

    for i := Low(Value) to High(Value) do
      Str := Str + IntToHex(Value[i], 2);

    MessageDlg('Value: ' + Str, mtInformation, [mbOK], 0);
  end;
end;

procedure TfmMain.btGetDescriptorsClick(Sender: TObject);
var
  Characteristic: TwclGattCharacteristic;
  Res: Integer;
  i: Integer;
  Item: TListItem;
  Descriptor: TwclGattDescriptor;
begin
  FDescriptors := nil;
  lvDescriptors.Items.Clear;

  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];
  Res := GattClient.ReadDescriptors(Characteristic, OpFlag, FDescriptors);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Exit;
  end;

  if FDescriptors = nil then
    Exit;

  for i := 0 to Length(FDescriptors) - 1 do begin
    Descriptor := FDescriptors[i];

    Item := lvDescriptors.Items.Add;
    if Descriptor.Uuid.IsShortUuid then
      Item.Caption := IntToHex(Descriptor.Uuid.ShortUuid, 4)
    else
      Item.Caption := GUIDToString(Descriptor.Uuid.LongUuid);
    Item.SubItems.Add(BoolToStr(Descriptor.Uuid.IsShortUuid, True));
    Item.SubItems.Add(IntToHex(Descriptor.ServiceHandle, 4));
    Item.SubItems.Add(IntToHex(Descriptor.CharacteristicHandle, 4));
    Item.SubItems.Add(IntToHex(Descriptor.Handle, 4));
    case Descriptor.DescriptorType of
      dtCharacteristicExtendedProperties:
        Item.SubItems.Add('dtCharacteristicExtendedProperties');
      dtCharacteristicUserDescription:
        Item.SubItems.Add('dtCharacteristicUserDescription');
      dtClientCharacteristicConfiguration:
        Item.SubItems.Add('dtClientCharacteristicConfiguration');
      dtServerCharacteristicConfiguration:
        Item.SubItems.Add('dtServerCharacteristicConfiguration');
      dtCharacteristicFormat:
        Item.SubItems.Add('dtCharacteristicFormat');
      dtCharacteristicAggregateFormat:
        Item.SubItems.Add('dtCharacteristicAggregateFormat');
      else
        Item.SubItems.Add('dtCustomDescriptor');
    end;
  end;
end;

procedure TfmMain.Cleanup;
begin
  FCharacteristics := nil;
  FDescriptors := nil;
  FServices := nil;

  lvServices.Items.Clear;
  lvCharacteristics.Items.Clear;
  lvDescriptors.Items.Clear;
  lvDescriptorValue.Items.Clear;
end;

procedure TfmMain.btGetDescValueClick(Sender: TObject);
var
  Descriptor: TwclGattDescriptor;
  Value: TwclGattDescriptorValue;
  Res: Integer;
  Str: string;
  i: Integer;
begin
  lvDescriptorValue.Items.Clear;

  if lvDescriptors.Selected = nil then begin
    MessageDlg('Select descriptor', mtWarning, [mbOK], 0);
    Exit;
  end;

  Descriptor := FDescriptors[lvDescriptors.Selected.Index];
  Res := GattClient.ReadDescriptorValue(Descriptor, OpFlag, Value,
    Protection);
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)

  else begin
    case Value.AType of
      dtCharacteristicExtendedProperties:
        begin
          ListProp('Type', 'dtCharacteristicExtendedProperties');
          ListProp('IsReliableWriteEnabled', BoolToStr(
            Value.CharacteristicExtendedProperties.IsReliableWriteEnabled,
            True));
          ListProp('IsAuxiliariesWritable', BoolToStr(
            Value.CharacteristicExtendedProperties.IsAuxiliariesWritable,
            True));
        end;

      dtCharacteristicUserDescription:
        begin
          ListProp('Type', 'dtCharacteristicUserDescription');
          ListProp('Descriptipon', Value.UserDescription.Description);
        end;

      dtClientCharacteristicConfiguration:
        begin
          ListProp('Type', 'dtClientCharacteristicConfiguration');
          ListProp('IsSubscribeToNotification ', BoolToStr(
            Value.ClientCharacteristicConfiguration.IsSubscribeToNotification,
            True));
          ListProp('IsSubscribeToIndication', BoolToStr(
            Value.ClientCharacteristicConfiguration.IsSubscribeToIndication,
            True));
        end;

      dtServerCharacteristicConfiguration:
        begin
          ListProp('Type', 'dtServerCharacteristicConfiguration');
          ListProp('IsBroadcast', BoolToStr(
            Value.ServerCharacteristicConfiguration.IsBroadcast,
            True));
        end;

      dtCharacteristicFormat:
        begin
          ListProp('Type', 'dtCharacteristicFormat');
          ListProp('Format', IntToHex(Byte(Value.CharacteristicFormat.Format), 2));
          ListProp('Exponent', IntToHex(
            Value.CharacteristicFormat.Exponent, 2));
          ListProp('Unit', IntToHex(
            Value.CharacteristicFormat.AUnit, 4));
          ListProp('NameSpace', IntToHex(
            Value.CharacteristicFormat.NameSpace, 2));
          ListProp('Description', IntToHex(
            Value.CharacteristicFormat.Description, 4));
        end;

      dtCharacteristicAggregateFormat:
        begin
          ListProp('Type', 'dtCharacteristicAggregateFormat');
          if Length(Value.CharacteristicAggregateFormat.Handles) > 0 then begin
            for i := 0 to Length(Value.CharacteristicAggregateFormat.Handles) - 1 do begin
              ListProp('Handle [' + IntToStr(i) + ']',
                IntToHex(Value.CharacteristicAggregateFormat.Handles[i], 4));
            end;
          end;
        end;

      else
        ListProp('Type', 'UNKNOWN');
    end;

    if Value.Data <> nil then begin
      Str := '';
      for i := 0 to Length(Value.Data) - 1 do
        Str := Str + IntToHex(Value.Data[i], 2);
      ListProp('Data', Str);
    end;
  end;
end;

procedure TfmMain.ListProp(const Name: string; const Value: string);
var
  Item: TListItem;
begin
  Item := lvDescriptorValue.Items.Add;
  Item.Caption := Name;
  Item.SubItems.Add(Value);
end;

procedure TfmMain.btSetValueClick(Sender: TObject);
var
  Str: string;
  Characteristic: TwclGattCharacteristic;
  Val: TwclGattCharacteristicValue;
  i: Integer;
  j: Integer;
  Res: Integer;
  WriteKind: TwclGattWriteKind;
begin
  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];

  Str := edCharVal.Text;
  if Length(Str) mod 2 <> 0 then
    Str := '0' + Str;
  Val := nil;
  SetLength(Val, Length(Str) div 2);
  i := 1;
  j := 0;
  while i < Length(Str) do begin
    Val[j] := StrToInt('$' + Copy(Str, i, 2));
    Inc(j);
    Inc(i, 2);
  end;

  case cbWriteKind.ItemIndex of
    0: WriteKind := wkWithResponse;
    1: WriteKind := wkWithoutResponse;
    else WriteKind := wkAuto;
  end;

  Res := GattClient.WriteCharacteristicValue(Characteristic, Val, Protection,
    WriteKind);
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btSubscribeClick(Sender: TObject);
var
  Characteristic: TwclGattCharacteristic;
  Res: Integer;
  SubscribeKind: TwclGattSubscribeKind;
begin
  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];

  case cbSubscribeKind.ItemIndex of
    0: SubscribeKind := skNotification;
    1: SubscribeKind := skIndication;
    else SubscribeKind := skManual;
  end;

  if SubscribeKind = skManual then begin
    // In case if characteristic has both Indication and Notification properties
    // set to True we have to select one of them. Here we use Notifications but
    // you can use other one.
    if Characteristic.IsNotifiable and Characteristic.IsIndicatable then begin
      // Change the code line below to
      // Characteristic.IsNotifiable = false;
      // if you want to receive Indications instead of notifications.
      Characteristic.IsIndicatable := False;
    end;
  end;

  if cbFastSubscribe.Checked then begin
    if SubscribeKind = skManual then
      Res := GattClient.SubscribeForNotifications(Characteristic)
    else begin
      Res := GattClient.SubscribeForNotifications(Characteristic, OpFlag,
        Protection, SubscribeKind);
    end;
  end else begin
    if SubscribeKind = skManual then
      Res := GattClient.Subscribe(Characteristic)
    else
      Res := GattClient.Subscribe(Characteristic, SubscribeKind);
  end;

  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btUnsubscribeClick(Sender: TObject);
var
  Characteristic: TwclGattCharacteristic;
  Res: Integer;
  SubscribeKind: TwclGattSubscribeKind;
begin
  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];

  case cbSubscribeKind.ItemIndex of
    0: SubscribeKind := skNotification;
    1: SubscribeKind := skIndication;
    else SubscribeKind := skManual;
  end;
  
  if SubscribeKind = skManual then begin
    // In case if characteristic has both Indication and Notification properties
    // set to True we have to select one of them. Here we use Notifications but
    // you can use other one.
    // YOU MUST USE THE SAME PROPERTY THAT IS USED IN SUBSCRIBE
    if Characteristic.IsNotifiable and Characteristic.IsIndicatable then begin
      // Change the code line below to
      // Characteristic.IsNotifiable = false;
      // if you want to receive Indications instead of notifications.
      Characteristic.IsIndicatable := False;
    end;
  end;

  if cbFastSubscribe.Checked then begin
    if SubscribeKind = skManual then
      Res := GattClient.UnsubscribeFromNotifications(Characteristic)
    else begin
      Res := GattClient.UnsubscribeFromNotifications(Characteristic, OpFlag,
        Protection, SubscribeKind);
    end;
  end else begin
    if SubscribeKind = skManual then
      Res := GattClient.Unsubscribe(Characteristic)
    else
      Res := GattClient.Unsubscribe(Characteristic, SubscribeKind);
  end;

  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

function TfmMain.OpFlag: TwclGattOperationFlag;
begin
  case cbOperationFlag.ItemIndex of
    1: Result := goReadFromDevice;
    2: Result := goReadFromCache;
    else Result := goNone;
  end;
end;

procedure TfmMain.btCCCDSubscribeClick(Sender: TObject);
var
  Characteristic: TwclGattCharacteristic;
  Res: Integer;
  SubscribeKind: TwclGattSubscribeKind;
begin
  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];

  case cbSubscribeKind.ItemIndex of
    0: SubscribeKind := skNotification;
    1: SubscribeKind := skIndication;
    else SubscribeKind := skManual;
  end;
  
  if SubscribeKind = skManual then begin
    // In case if characteristic has both Indication and Notification properties
    // set to True we have to select one of them. Here we use Notifications but
    // you can use other one.
    if Characteristic.IsNotifiable and Characteristic.IsIndicatable then begin
      // Change the code line below to
      // Characteristic.IsNotifiable = false;
      // if you want to receive Indications instead of notifications.
      Characteristic.IsIndicatable := False;
    end;
    Res := GattClient.WriteClientConfiguration(Characteristic, True, OpFlag,
      Protection);

  end else begin
    Res := GattClient.WriteClientConfiguration(Characteristic, True, OpFlag,
      Protection, SubscribeKind);
  end;

  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btCCCDUnsubscribeClick(Sender: TObject);
var
  Characteristic: TwclGattCharacteristic;
  Res: Integer;
  SubscribeKind: TwclGattSubscribeKind;
begin
  if lvCharacteristics.Selected = nil then begin
    MessageDlg('Select characteristic', mtWarning, [mbOK], 0);
    Exit;
  end;

  Characteristic := FCharacteristics[lvCharacteristics.Selected.Index];

  case cbSubscribeKind.ItemIndex of
    0: SubscribeKind := skNotification;
    1: SubscribeKind := skIndication;
    else SubscribeKind := skManual;
  end;
  
  if SubscribeKind = skManual then begin
    // In case if characteristic has both Indication and Notification properties
    // set to True we have to select one of them. Here we use Notifications but
    // you can use other one.
    // YOU MUST USE THE SAME PROPERTY THAT IS USED IN SUBSCRIBE
    if Characteristic.IsNotifiable and Characteristic.IsIndicatable then begin
      // Change the code line below to
      // Characteristic.IsNotifiable = false;
      // if you want to receive Indications instead of notifications.
      Characteristic.IsIndicatable := False;
    end;
    Res := GattClient.WriteClientConfiguration(Characteristic, False, OpFlag,
      Protection);
  end else begin
    Res := GattClient.WriteClientConfiguration(Characteristic, False, OpFlag,
      Protection, SubscribeKind);
  end;

  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.BluetoothManagerNumericComparison(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Number: Cardinal; out Confirm: Boolean);
begin
  // Accept any pairing.
  Confirm := True;
  TraceEvent(Address, 'Numeric comparison', 'Number', IntToStr(Number));
end;

procedure TfmMain.BluetoothManagerPasskeyNotification(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Passkey: Cardinal);
begin
  TraceEvent(Address, 'Passkey notification', 'Passkey', IntToStr(Passkey));
end;

procedure TfmMain.BluetoothManagerPasskeyRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Passkey: Cardinal);
begin
  // Use 123456 as passkey.
  Passkey := 123456;
  TraceEvent(Address, 'Passkey request', 'Passkey', IntToStr(Passkey));
end;

procedure TfmMain.BluetoothManagerPinRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64; out Pin: String);
begin
  // Use '0000' as PIN.
  Pin := '0000';
  TraceEvent(Address, 'Pin request', 'PIN', Pin);
end;

procedure TfmMain.BluetoothManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
var
  Item: TListItem;
  DevType: TwclBluetoothDeviceType;
  Paired: Boolean;
  Res: Integer;
begin
  Item := lvDevices.Items.Add;
  Item.Caption := IntToHex(Address, 12);
  Item.SubItems.Add(''); // We can not read a device's name here.
  Item.Data := Radio; // To use it later.

  Res := Radio.GetRemoteDeviceType(Address, DevType);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8))

  else begin
    case DevType of
      dtClassic: Item.SubItems.Add('Classic');
      dtBle: Item.SubItems.Add('BLE');
      dtMixed: Item.SubItems.Add('Mixed');
      else Item.SubItems.Add('Unknown');
    end;
  end;

  Res := Radio.GetRemotePaired(Address, Paired);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8))
  else begin
    if Paired then
      Item.SubItems.Add('True')
    else
      Item.SubItems.Add('False');
  end;

  TraceEvent(Address, 'Device found', '', '');
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
    MessageDlg('No BLE devices were found.', mtInformation, [mbOK], 0)

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

  TraceEvent(0, 'Discovering completed', '', '');
end;

procedure TfmMain.BluetoothManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  lvDevices.Items.Clear;
  TraceEvent(0, 'Discovering started', '', '');
end;

procedure TfmMain.GattClientCharacteristicChanged(Sender: TObject;
  const Handle: Word; const Value: TwclGattCharacteristicValue);
var
  Str: string;
  i: Integer;
begin
  TraceEvent(TwclGattClient(Sender).Address, 'ValueChanged', 'Handle',
    IntToHex(Handle, 4));
  if Value = nil then
    TraceEvent(0, '', 'Value', '')

  else begin
    if Length(Value) = 0 then
      TraceEvent(0, '', 'Value', '')

    else begin
      Str := '';
      for i := Low(Value) to High(Value) do
        Str := Str + IntToHex(Value[i], 2);
      TraceEvent(0, '', 'Value', Str);
    end;
  end;
end;

procedure TfmMain.GattClientConnect(Sender: TObject;
  const Error: Integer);
begin
  // Connection property is valid here.
  TraceEvent(TwclGattClient(Sender).Address, 'Connected', 'Error',
    '0x' + IntToHex(Error, 8));

  if Error = WCL_E_SUCCESS then begin
    TraceEvent(GattClient.Address, 'Max PDU', '', '');
    GetMaxPduSize;

    TraceEvent(GattClient.Address, 'Connection params', '', '');
    GetConnectionParams;

    TraceEvent(GattClient.Address, 'Connection PHY', '', '');
    GetConnectionPhy;
  end;
end;

procedure TfmMain.GattClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  // Connection property is valid here.
  TraceEvent(TwclGattClient(Sender).Address, 'Disconnected', 'Reason',
    '0x' + IntToHex(Reason, 8));

  Cleanup;
end;

procedure TfmMain.btTerminateClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    Res := Radio.Terminate;
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Error terminating discovering: 0x' + IntToHex(Res, 8),
        mtError, [mbOK], 0);
    end;
  end;
end;

function TfmMain.Protection: TwclGattProtectionLevel;
begin
  case cbProtection.ItemIndex of
    0: Result := plNone;
    1: Result := plAuthentication;
    2: Result := plEncryption;
    3: Result := plEncryptionAndAuthentication;
  else
    Result := plNone;
  end;
end;

procedure TfmMain.BluetoothManagerConfirm(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Confirm: Boolean);
begin
  // Accept any pairing.
  Confirm := True;
  TraceEvent(Address, 'Just works pairing', 'Accept', 'True');
end;

procedure TfmMain.BluetoothManagerAuthenticationCompleted(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  const Error: Integer);
begin
  TraceEvent(Address, 'Authentication completed', 'Error', IntToHex(Error, 8));
end;

procedure TfmMain.btPairClick(Sender: TObject);
var
  Res: Integer;
  Item: TListItem;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Res := TwclBluetoothRadio(Item.Data).RemotePair(StrToInt64('$' +
      Item.Caption), pmLe);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.cbFastSubscribeClick(Sender: TObject);
begin
  btCCCDSubscribe.Enabled := not cbFastSubscribe.Checked;
  btCCCDUnsubscribe.Enabled := not cbFastSubscribe.Checked;
end;

procedure TfmMain.btGetParamsClick(Sender: TObject);
begin
  TraceEvent(GattClient.Address, 'Connection params', '', '');
  GetConnectionParams;
end;

procedure TfmMain.GattClientConnectionParamsChanged(Sender: TObject);
begin
  TraceEvent(GattClient.Address, 'Connection params changed', '', '');
  GetConnectionParams;
end;

procedure TfmMain.btSetParamsClick(Sender: TObject);
var
  ParamsValue: TwclBluetoothLeConnectionParametersValue;
  Params: TwclBluetoothLeConnectionParametersType;
  Res: Integer;
begin
  if cbParams.ItemIndex = 3 then begin
    ParamsValue.MinInterval := 84;
    ParamsValue.MaxInterval := 84;
    ParamsValue.Latency := 0;
    ParamsValue.LinkTimeout := 800;
    Res := GattClient.SetConnectionParams(ParamsValue);

  end else begin
    case cbParams.ItemIndex of
      0: Params := ppBalanced;
      1: Params := ppPowerOptimized;
      2: Params := ppThroughputOptimized;
      else raise wclEInvalidArgument.Create('Invalid connection parameters.');
    end;
    Res := GattClient.SetConnectionParams(Params);
  end;

  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
end;

procedure TfmMain.GattClientMaxPduSizeChanged(Sender: TObject);
begin
  TraceEvent(GattClient.Address, 'Max PDU size changed', '', '');
  GetMaxPduSize;
end;

procedure TfmMain.btGetMaxPduSizeClick(Sender: TObject);
begin
  TraceEvent(GattClient.Address, 'Max PDU', '', '');
  GetMaxPduSize;
end;

procedure TfmMain.GetMaxPduSize;
var
  Res: Integer;
  Size: Word;
begin
  Res := GattClient.GetMaxPduSize(Size);
  if Res <> WCL_E_SUCCESS then
    TraceEvent(GattClient.Address, '', 'Error', IntToHex(Res, 8))
  else
    TraceEvent(GattClient.Address, '', 'Size', IntToStr(Size));
end;

procedure TfmMain.GetConnectionParams;
var
  Params: TwclBluetoothLeConnectionParameters;
  Res: Integer;
begin
  Res := GattClient.GetConnectionParams(Params);
  if Res <> WCL_E_SUCCESS then
    TraceEvent(0, '', 'Error', IntToHex(Res, 8))

  else begin
    TraceEvent(0, '', 'Connection interval', IntToStr(Params.Interval));
    TraceEvent(0, '', 'Connection latency', IntToStr(Params.Latency));
    TraceEvent(0, '', 'Link timeout', IntToStr(Params.LinkTimeout));
  end;
end;

procedure TfmMain.BluetoothManagerProtectionLevelRequest(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  out Protection: TwclBluetoothLeProtectionLevel);
begin
  case cbProtection.ItemIndex of
    0: Protection := pplNone;
    1: Protection := pplDefault;
    2: Protection := pplEncryption;
    3: Protection := pplEncryptionAndAuthentication
  end;
end;

procedure TfmMain.btPhyClick(Sender: TObject);
begin
  TraceEvent(GattClient.Address, 'Connection PHY', '', '');
  GetConnectionPhy;
end;

procedure TfmMain.GattClientConnectionPhyChanged(Sender: TObject);
begin
  TraceEvent(GattClient.Address, 'Connection PHY changed', '', '');
  GetConnectionPhy;
end;

procedure TfmMain.GetConnectionPhy;
var
  Res: Integer;
  Phy: TwclBluetoothLeConnectionPhy;
begin
  Res := GattClient.GetConnectionPhyInfo(Phy);
  if Res <> WCL_E_SUCCESS then
    TraceEvent(0, '', 'Error', IntToHex(Res, 8))

  else begin
    TraceEvent(0, 'Transmit PHY', '', '');
    TraceEvent(0, '', 'Coded', BoolToStr(Phy.Transmit.IsCoded, True));
    TraceEvent(0, '', '1M', BoolToStr(Phy.Transmit.IsUncoded1MPhy, True));
    TraceEvent(0, '', '2M', BoolToStr(Phy.Transmit.IsUncoded2MPhy, True));

    TraceEvent(0, 'Receive PHY', '', '');
    TraceEvent(0, '', 'Coded', BoolToStr(Phy.Receive.IsCoded, True));
    TraceEvent(0, '', '1M', BoolToStr(Phy.Receive.IsUncoded1MPhy, True));
    TraceEvent(0, '', '2M', BoolToStr(Phy.Receive.IsUncoded2MPhy, True));
  end;
end;

procedure TfmMain.BluetoothManagerIoCapabilityRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Mitm: TwclBluetoothMitmProtection;
  out IoCapability: TwclBluetoothIoCapability; out OobPresent: Boolean);
begin
  case cbMitmProtection.ItemIndex of
    0: Mitm := mitmProtectionNotRequired;
    1: Mitm := mitmProtectionRequired;
    2: Mitm := mitmProtectionNotRequiredBonding;
    3: Mitm := mitmProtectionRequiredBonding;
    4: Mitm := mitmProtectionNotRequiredGeneralBonding;
    5: Mitm := mitmProtectionRequiredGeneralBonding;
    else Mitm := mitmProtectionNotDefined;
  end;

  case cbIoCap.ItemIndex of
    0: IoCapability := iocapDisplayOnly;
    1: IoCapability := iocapDisplayYesNo;
    2: IoCapability := iocapKeyboardOnly;
    3: IoCapability := iocapNoInputNoOutput;
    4: IoCapability := iocapDisplayKeyboard;
    else IoCapability := iocapNotDefined;
  end;

  OobPresent := False;
end;

procedure TfmMain.btUnpairClick(Sender: TObject);
var
  Res: Integer;
  Item: TListItem;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Res := TwclBluetoothRadio(Item.Data).RemoteUnpair(StrToInt64('$' +
      Item.Caption), pmLe);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btEnumPairedClick(Sender: TObject);
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
  Devices: TwclBluetoothAddresses;
  i: Integer;
  Item: TListItem;
  Name: string;
  DevType: TwclBluetoothDeviceType;
  Paired: Boolean;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    lvDevices.Items.Clear;

    Res := Radio.EnumPairedDevices(dkBle, Devices);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Enum paired failed: 0x' + IntToHex(Res, 8))

    else begin
      if Length(Devices) > 0 then begin
        for i := 0 to Length(Devices) - 1 do begin
          Item := lvDevices.Items.Add;
          Item.Data := Radio;

          Item.Caption := IntToHex(Devices[i], 12);

          Res := Radio.GetRemoteName(Devices[i], Name);
          if Res = WCL_E_SUCCESS then
            Item.SubItems.Add(Name)
          else
            Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

          Res := Radio.GetRemoteDeviceType(Devices[i], DevType);
          if Res <> WCL_E_SUCCESS then
            Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8))
          else begin
            case DevType of
              dtClassic: Item.SubItems.Add('Classic');
              dtBle: Item.SubItems.Add('BLE');
              dtMixed: Item.SubItems.Add('Mixed');
              else Item.SubItems.Add('Unknown');
            end;
          end;

          Res := Radio.GetRemotePaired(Devices[i], Paired);
          if Res <> WCL_E_SUCCESS then
            Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8))
          else begin
            if Paired then
              Item.SubItems.Add('True')
            else
              Item.SubItems.Add('False');
          end;
        end;
      end;
    end;
  end;
end;

end.
