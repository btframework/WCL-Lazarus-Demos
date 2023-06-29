unit main;

{$I wcl.inc}

interface

uses
  Forms, wclBluetooth, StdCtrls, Classes, Controls, ComCtrls, wclPowerEvents;

type

  { TfmMain }

  TfmMain = class(TForm)
    btEnumConnected: TButton;
    Button1: TButton;
    lvEvents: TListView;
    btClearEvents: TButton;
    btOpen: TButton;
    btClose: TButton;
    lvRadios: TListView;
    btRefreshRadio: TButton;
    btSetConnectable: TButton;
    btSetDiscoverable: TButton;
    btSetName: TButton;
    edName: TEdit;
    btEnumPaired: TButton;
    lvDevices: TListView;
    btRefreshDevice: TButton;
    btEnumServices: TButton;
    lvServices: TListView;
    btDiscover: TButton;
    laTimeout: TLabel;
    edTimeout: TEdit;
    btTerminate: TButton;
    btUnpair: TButton;
    btPair: TButton;
    edPin: TEdit;
    laPin: TLabel;
    btRSSI: TButton;
    btTurnOn: TButton;
    btTurnOff: TButton;
    btCreateVCOM: TButton;
    btDestroyVCOM: TButton;
    btEnumVCOMs: TButton;
    lvVComs: TListView;
    cbEnumPreinstalled: TCheckBox;
    btInstallDevice: TButton;
    btUninstallDevice: TButton;
    btIsInRange: TButton;
    laDiscoveringMode: TLabel;
    cbDiscoveringMode: TComboBox;
    laMitmProtection: TLabel;
    cbMitmProtection: TComboBox;
    laIoCap: TLabel;
    cbIoCap: TComboBox;
    laBleProtection: TLabel;
    cbBleProtection: TComboBox;
    laPairingMethod: TLabel;
    cbPairingMethod: TComboBox;
    btDisconnect: TButton;
    procedure btClearEventsClick(Sender: TObject);
    procedure btEnumConnectedClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btRefreshRadioClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btSetConnectableClick(Sender: TObject);
    procedure btSetDiscoverableClick(Sender: TObject);
    procedure btSetNameClick(Sender: TObject);
    procedure btEnumPairedClick(Sender: TObject);
    procedure btRefreshDeviceClick(Sender: TObject);
    procedure btEnumServicesClick(Sender: TObject);
    procedure btDiscoverClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure btUnpairClick(Sender: TObject);
    procedure btPairClick(Sender: TObject);
    procedure btRSSIClick(Sender: TObject);
    procedure btTurnOnClick(Sender: TObject);
    procedure btTurnOffClick(Sender: TObject);
    procedure btEnumVCOMsClick(Sender: TObject);
    procedure btCreateVCOMClick(Sender: TObject);
    procedure btDestroyVCOMClick(Sender: TObject);
    procedure btInstallDeviceClick(Sender: TObject);
    procedure btUninstallDeviceClick(Sender: TObject);
    procedure btIsInRangeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    FPowerMonitor: TwclPowerEventsMonitor;

    procedure wclBluetoothManagerAfterOpen(Sender: TObject);
    procedure wclBluetoothManagerBeforeClose(Sender: TObject);
    procedure wclBluetoothManagerAuthenticationCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Error: Integer);
    procedure wclBluetoothManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);
    procedure wclBluetoothManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);
    procedure wclBluetoothManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);
    procedure wclBluetoothManagerNumericComparison(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Number: Cardinal; out Confirm: Boolean);
    procedure wclBluetoothManagerPasskeyNotification(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Passkey: Cardinal);
    procedure wclBluetoothManagerPasskeyRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Passkey: Cardinal);
    procedure wclBluetoothManagerPinRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Pin: String);
    procedure wclBluetoothManagerStatusChanged(Sender: TObject;
      const Radio: TwclBluetoothRadio);
    procedure wclBluetoothManagerConfirm(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Confirm: Boolean);
    procedure wclBluetoothManagerIoCapabilityRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Mitm: TwclBluetoothMitmProtection;
      out IoCapability: TwclBluetoothIoCapability;
      out OobPresent: Boolean);
    procedure wclBluetoothManagerOobDataRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out OobData: TwclBluetoothOobData);
    procedure wclBluetoothManagerProtectionLevelRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Protection: TwclBluetoothLeProtectionLevel);
    procedure wclBluetoothManagerClosed(Sender: TObject);

    procedure TraceEvent(const Radio: TwclBluetoothRadio; const Event: string;
      const Parameter: string; const Value: string);

    procedure ShowError(const Error: Integer);

    procedure RefreshRadio(const Item: TListItem);
    procedure AddDevice(const Radio: TwclBluetoothRadio; const Address: Int64);
    procedure RefreshDevices;
    procedure RefreshDevice(const Item: TListItem);
    procedure RefreshVComs;

    procedure ClearRadios;
    procedure ClearDevices;
    procedure ClearServices;
    procedure ClearComPorts;

    procedure PowerStateChanged(Sender: TObject; const State: TwclPowerState);
  end;

var
  fmMain: TfmMain;

implementation

uses
  SysUtils, Dialogs, wclErrors, wclBluetoothErrors, Windows;

{$R *.lfm}

procedure TfmMain.btClearEventsClick(Sender: TObject);
begin
  lvEvents.Items.Clear;
end;

procedure TfmMain.btEnumConnectedClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Devices: TwclBluetoothAddresses;
  Res: Integer;
  i: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    ClearDevices;

    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    Res := Radio.EnumConnectedDevices(Devices);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)

    else begin
      if Devices <> nil then begin
        for i := 0 to Length(Devices) - 1 do
          AddDevice(Radio, Devices[i]);

        RefreshDevices;
      end;
    end;
  end;
end;

procedure TfmMain.Button1Click(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  Services: TwclBluetoothInstalledServices;
  i: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    ClearServices;

    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);

    Res := Radio.EnumInstalledServices(Address, Services);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)

    else begin
      if Services <> nil then begin
        for i := 0 to Length(Services) - 1 do begin
          Item := lvServices.Items.Add;

          Item.Caption := Radio.ApiName;
          Item.SubItems.Add(IntToHex(Address, 12));
          Item.SubItems.Add('');
          Item.SubItems.Add(GUIDToString(Services[i]));
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          Item.SubItems.Add('');
        end;
      end;
    end;
  end;
end;

procedure TfmMain.TraceEvent(const Radio: TwclBluetoothRadio;
  const Event: string; const Parameter: string; const Value: string);
var
  Item: TListItem;
begin
  Item := lvEvents.Items.Add;

  if Radio <> nil then
    Item.Caption := Radio.ApiName
  else
    Item.Caption := '';

  Item.SubItems.Add(Event);
  Item.SubItems.Add(Parameter);
  Item.SubItems.Add(Value);

  lvEvents.Selected := Item;
  Item.MakeVisible(False);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclBluetoothManager.Close;
  FPowerMonitor.Close;

  wclBluetoothManager.Free;
  FPowerMonitor.Free;
end;

procedure TfmMain.ClearRadios;
begin
  lvRadios.Items.Clear;
  ClearDevices;
end;

procedure TfmMain.RefreshRadio(const Item: TListItem);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
  Address: Int64;
  BoolVal: Boolean;
  ByteVal: Byte;
  WordVal: Word;
  StrVal: string;
  Cod: Cardinal;
begin
  Radio := TwclBluetoothRadio(Item.Data);

  Item.Caption := Radio.ApiName;
  Item.SubItems[0] := BoolToStr(Radio.Available, True);

  Res := Radio.GetAddress(Address);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[1] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[1] := IntToHex(Address, 12);

  Res := Radio.GetConnectable(BoolVal);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[2] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[2] := BoolToStr(BoolVal, True);

  Res := Radio.GetDiscoverable(BoolVal);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[3] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[3] := BoolToStr(BoolVal, True);

  Res := Radio.GetHciVersion(ByteVal, WordVal);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[4] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[4] := IntToStr(ByteVal) + '.' + IntToStr(WordVal);

  Res := Radio.GetLmpVersion(ByteVal, WordVal);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[5] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[5] := IntToStr(ByteVal) + '.' + IntToStr(WordVal);

  Res := Radio.GetManufacturer(WordVal);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[6] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[6] := IntToStr(WordVal);

  Res := Radio.GetName(StrVal);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[7] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[7] := StrVal;

  Res := Radio.GetCod(Cod);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[8] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[8] := '0x' + IntToHex(Cod, 8);
end;

procedure TfmMain.btRefreshRadioClick(Sender: TObject);
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)
  else
    RefreshRadio(lvRadios.Selected);
end;

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothManager.Open();
  if Res <> WCL_E_SUCCESS then
    ShowError(Res);
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothManager.Close;
  if Res <> WCL_E_SUCCESS then
    ShowError(Res);
end;

procedure TfmMain.ShowError(const Error: Integer);
begin
  MessageDlg('Error: 0x' + IntToHex(Error, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btSetConnectableClick(Sender: TObject);
var
  Mr: TModalResult;
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Mr := MessageDlg('[YES] - turn connectable ON, [NO] - turn connectable OFF',
      mtConfirmation, mbYesNoCancel, 0);
    if Mr <> mrCancel then begin
      Item := lvRadios.Selected;
      Radio := TwclBluetoothRadio(Item.Data);

      Res := Radio.SetConnectable(Mr = mrYes);
      if Res <> WCL_E_SUCCESS then
        ShowError(Res);

      RefreshRadio(Item);
    end;
  end;
end;

procedure TfmMain.btSetDiscoverableClick(Sender: TObject);
var
  Mr: TModalResult;
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Mr := MessageDlg('[YES] - turn discoverable ON, [NO] - turn discoverable OFF',
      mtConfirmation, mbYesNoCancel, 0);
    if Mr <> mrCancel then begin
      Item := lvRadios.Selected;
      Radio := TwclBluetoothRadio(Item.Data);

      Res := Radio.SetDiscoverable(Mr = mrYes);
      if Res <> WCL_E_SUCCESS then
        ShowError(Res);

      RefreshRadio(Item);
    end;
  end;
end;

procedure TfmMain.btSetNameClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    Res := Radio.SetName(edName.Text);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);

    RefreshRadio(Item);
  end;
end;

procedure TfmMain.btEnumPairedClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Devices: TwclBluetoothAddresses;
  Res: Integer;
  i: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    ClearDevices;

    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    Res := Radio.EnumPairedDevices(Devices);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)

    else begin
      if Devices <> nil then begin
        for i := 0 to Length(Devices) - 1 do
          AddDevice(Radio, Devices[i]);

        RefreshDevices;
      end;
    end;
  end;
end;

procedure TfmMain.ClearDevices;
begin
  lvDevices.Items.Clear;
  ClearServices;
end;

procedure TfmMain.RefreshDevice(const Item: TListItem);
var
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  Cod: Cardinal;
  DevType: TwclBluetoothDeviceType;
  DevName: string;
  Paired: Boolean;
  Connected: Boolean;
  AddrType: TwclBluetoothAddressType;
begin
  Radio := TwclBluetoothRadio(Item.Data);
  Address := StrToInt64('$' + Item.SubItems[0]);

  Res := Radio.GetRemoteCod(Address, Cod);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[1] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[1] := IntToHex(Cod, 8);

  Res := Radio.GetRemoteDeviceType(Address, DevType);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[2] := 'Error: 0x' + IntToHex(Res, 8)
  else begin
    case DevType of
      dtClassic: Item.SubItems[2] := 'Classic';
      dtBle: Item.SubItems[2] := 'BLE';
      dtMixed: Item.SubItems[2] := 'Mixed';
      else Item.SubItems[2] := 'Unknown';
    end;
  end;

  Res := Radio.GetRemoteName(Address, DevName);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[3] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[3] := DevName;

  Res := Radio.GetRemotePaired(Address, Paired);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[4] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[4] := BoolToStr(Paired, True);

  Res := Radio.GetRemoteConnectedStatus(Address, Connected);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[5] := 'Error: 0x' + IntToHex(Res, 8)
  else
    Item.SubItems[5] := BoolToStr(Connected, True);

  Res := Radio.GetRemoteAddressType(Address, AddrType);
  if Res <> WCL_E_SUCCESS then
    Item.SubItems[6] := 'Error: 0x' + IntToHex(Res, 8)
  else begin
    case AddrType of
      atClassic:
        Item.SubItems[6] := 'Classic';
      atPublic:
        Item.SubItems[6] := 'LE Public';
      atRandom:
        Item.SubItems[6] := 'LE Random';
      atUnspecified:
        Item.SubItems[6] := 'Unspecified';
      else
        Item.SubItems[6] := 'Unknown';
    end;
  end;
end;

procedure TfmMain.btRefreshDeviceClick(Sender: TObject);
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)
  else
    RefreshDevice(lvDevices.Selected);
end;

procedure TfmMain.ClearServices;
begin
  lvServices.Items.Clear;
  ClearComPorts;
end;

procedure TfmMain.btEnumServicesClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  Services: TwclBluetoothServices;
  i: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    ClearServices;

    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);

    Res := Radio.EnumRemoteServices(Address, nil, Services);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)

    else begin
      if Services <> nil then begin
        for i := 0 to Length(Services) - 1 do begin
          Item := lvServices.Items.Add;

          Item.Caption := Radio.ApiName;
          Item.SubItems.Add(IntToHex(Address, 12));
          Item.SubItems.Add(IntToHex(Services[i].Handle, 8));
          Item.SubItems.Add(GUIDToString(Services[i].Uuid));
          Item.SubItems.Add(IntToStr(Services[i].Channel));
          Item.SubItems.Add(Services[i].Name);
          Item.SubItems.Add(Services[i].Comment);
        end;
      end;
    end;
  end;
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
  Kind: TwclBluetoothDiscoverKind;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    if cbDiscoveringMode.ItemIndex = 0 then
      Kind := dkClassic
    else
      Kind := dkBle;
      
    Res := Radio.Discover(StrToInt(edTimeout.Text), Kind);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);
  end;
end;

procedure TfmMain.btTerminateClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    Res := Radio.Terminate;
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);
  end;
end;

procedure TfmMain.AddDevice(const Radio: TwclBluetoothRadio;
  const Address: Int64);
var
  Item: TListItem;
begin
  Item := lvDevices.Items.Add;
  Item.Data := Radio;

  Item.Caption := Radio.ApiName;
  Item.SubItems.Add(IntToHex(Address, 12));
  Item.SubItems.Add(''); // Class Of Device
  Item.SubItems.Add(''); // Device type
  Item.SubItems.Add(''); // Name
  Item.SubItems.Add(''); // Paired
  Item.SubItems.Add(''); // Connected
  Item.SubItems.Add(''); // Address type
end;

procedure TfmMain.RefreshDevices;
var
  i: Integer;
begin
  for i := 0 to lvDevices.Items.Count - 1 do
    RefreshDevice(lvDevices.Items[i]);
end;

procedure TfmMain.btUnpairClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);

    Res := Radio.RemoteUnpair(Address);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);

    RefreshDevice(Item);
  end;
end;

procedure TfmMain.btPairClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  Method: TwclBluetoothPairingMethod;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);

    case cbPairingMethod.ItemIndex of
      1: Method := pmClassic;
      2: Method := pmLe;
      else Method := pmAuto;
    end;

    Res := Radio.RemotePair(Address, Method);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);
  end;
end;

procedure TfmMain.btRSSIClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  Rssi: ShortInt;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);

    Res := Radio.GetRemoteRssi(Address, Rssi);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)
    else
      MessageDlg('RSSI: ' + IntToStr(Rssi) + 'dB', mtInformation, [mbOK], 0);
  end;
end;

procedure TfmMain.btTurnOnClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    Res := Radio.TurnOn;
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);

    RefreshRadio(Item);
  end;
end;

procedure TfmMain.btTurnOffClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)

  else begin
    Item := lvRadios.Selected;
    Radio := TwclBluetoothRadio(Item.Data);

    Res := Radio.TurnOff;
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);

    RefreshRadio(Item);
  end;
end;

procedure TfmMain.wclBluetoothManagerAfterOpen(Sender: TObject);
begin
  TraceEvent(nil, 'AfterOpen', '', '');
end;

procedure TfmMain.wclBluetoothManagerBeforeClose(Sender: TObject);
begin
  TraceEvent(nil, 'BeforeClose', '', '');
end;

procedure TfmMain.wclBluetoothManagerAuthenticationCompleted(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  const Error: Integer);
begin
  TraceEvent(Radio, 'AuthenticationCompleted', 'Address',
    IntToHex(Address, 12));
  TraceEvent(nil, '', 'Error', '0x' + IntToHex(Error, 8));
end;

procedure TfmMain.wclBluetoothManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
begin
  TraceEvent(Radio, 'DeviceFound', 'Address', IntToHex(Address, 12));

  AddDevice(Radio, Address);
end;

procedure TfmMain.wclBluetoothManagerDiscoveringCompleted(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Error: Integer);
begin
  TraceEvent(Radio, 'DiscoveringCompleted', 'Error', '0x' + IntToHex(Error, 8));

  RefreshDevices;
end;

procedure TfmMain.wclBluetoothManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  ClearDevices;

  TraceEvent(Radio, 'DiscoveringStarted', '', '');
end;

procedure TfmMain.wclBluetoothManagerNumericComparison(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Number: Cardinal; out Confirm: Boolean);
begin
  Confirm := True;

  TraceEvent(Radio, 'NumericComparison', 'Address', IntToHex(Address, 12));
  TraceEvent(nil, '', 'Number', IntToStr(Number));
  TraceEvent(nil, '', 'Confirm', BoolToStr(Confirm, True));
end;

procedure TfmMain.wclBluetoothManagerPasskeyNotification(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Passkey: Cardinal);
begin
  TraceEvent(Radio, 'PasskeyNotification', 'Address', IntToHex(Address, 12));
  TraceEvent(nil, '', 'Passkey', IntToStr(Passkey));
end;

procedure TfmMain.wclBluetoothManagerPasskeyRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Passkey: Cardinal);
begin
  Passkey := 123456;

  TraceEvent(Radio, 'PasskeyRequest', 'Address', IntToHex(Address, 12));
  TraceEvent(nil, '', 'Passkey', IntToStr(Passkey));
end;

procedure TfmMain.wclBluetoothManagerPinRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64; out Pin: String);
begin
  Pin := edPin.Text;

  TraceEvent(Radio, 'PinRequest', 'Address', IntToHex(Address, 12));
  TraceEvent(nil, '', 'PIN', Pin);
end;

procedure TfmMain.wclBluetoothManagerStatusChanged(Sender: TObject;
  const Radio: TwclBluetoothRadio);
var
  i: Integer;
  Status: string;
  Found: Boolean;
  Item: TListItem;
begin
  if Radio.Available then
    Status := 'Available'
  else begin
    if Radio.Plugged then
      Status := 'Not available, Plugged'
    else
      Status := 'Unplugged';
  end;
  TraceEvent(Radio, 'StatusChanged', 'New status', Status);

  Found := False;
  for i := 0 to lvRadios.Items.Count - 1 do begin
    if lvRadios.Items[i].Data = Radio then begin
      Found := True;
      RefreshRadio(lvRadios.Items[i]);
      Break;
    end;
  end;

  if not Found then begin
    Item := lvRadios.Items.Add;
    Item.Data := Radio;

    Item.Caption := '';    // Api
    Item.SubItems.Add(''); // Available
    Item.SubItems.Add(''); // Address
    Item.SubItems.Add(''); // Connectable
    Item.SubItems.Add(''); // Discoverable
    Item.SubItems.Add(''); // HCI version
    Item.SubItems.Add(''); // LMP version
    Item.SubItems.Add(''); // Manufacturer
    Item.SubItems.Add(''); // Name
    Item.SubItems.Add(''); // COD

    RefreshRadio(Item);
  end;
end;

procedure TfmMain.ClearComPorts;
begin
  lvVComs.Items.Clear;
end;

procedure TfmMain.btEnumVCOMsClick(Sender: TObject);
begin
  if lvRadios.Selected = nil then
    MessageDlg('Select radio', mtWarning, [mbOK], 0)
  else
    RefreshVComs;
end;

procedure TfmMain.RefreshVComs;
var
  i: Integer;
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Ports: TwclVirtualComPorts;
  Port: TwclVirtualComPort;
  Res: Integer;
begin
  ClearComPorts;

  Item := lvRadios.Selected;
  Radio := TwclBluetoothRadio(Item.Data);

  if cbEnumPreinstalled.Checked then
    Res := Radio.EnumComPorts(Ports)
  else begin
    Ports := Radio.ComPorts;
    Res := WCL_E_SUCCESS;
  end;

  if Res <> WCL_E_SUCCESS then
    ShowMessage('Error enumerating vCOMs: 0x' + IntToHex(Res, 8))

  else begin
    for i := 0 to Length(Ports) - 1 do begin
      Port := Ports[i];

      Item := lvVComs.Items.Add;
      Item.Caption := Radio.ApiName;
      Item.SubItems.Add(IntToHex(Port.Address, 12));
      Item.SubItems.Add(GUIDToString(Port.Service));
      Item.SubItems.Add(IntToStr(Port.Number));

      Item.Data := Radio;
    end;
  end;
end;

procedure TfmMain.btCreateVCOMClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  Service: TGUID;
  Number: Word;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    if lvServices.Selected = nil then
      MessageDlg('Select service', mtWarning, [mbOK], 0)

    else begin
      Item := lvDevices.Selected;
      Radio := TwclBluetoothRadio(Item.Data);
      Address := StrToInt64('$' + Item.SubItems[0]);
      Service := StringToGUID(lvServices.Selected.SubItems[2]);

      Res := Radio.CreateComPort(Address, Service, Number);
      if Res <> WCL_E_SUCCESS then
        ShowError(Res)

      else begin
        TraceEvent(Radio, 'Create vCOM', 'Number', IntToStr(Number));

        RefreshVComs;
      end;
    end;
  end;
end;

procedure TfmMain.btDestroyVCOMClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Number: Word;
  Res: Integer;
begin
  if lvVComs.Selected = nil then
    MessageDlg('Select vCOM', mtWarning, [mbOK], 0)

  else begin
    Item := lvVComs.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Number := StrToInt(Item.SubItems[2]);

    Res := Radio.DestroyComPort(Number);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)

    else begin
      TraceEvent(Radio, 'Destroy vCOM', 'Number', IntToStr(Number));

      RefreshVComs;
    end;
  end;
end;

procedure TfmMain.btInstallDeviceClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Service: TGUID;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    if lvServices.Selected = nil then
      MessageDlg('Select service', mtWarning, [mbOK], 0)

    else begin
      Item := lvDevices.Selected;
      Radio := TwclBluetoothRadio(Item.Data);
      Address := StrToInt64('$' + Item.SubItems[0]);
      Service := StringToGUID(lvServices.Selected.SubItems[2]);

      Res := Radio.InstallDevice(Address, Service);
      if Res = WCL_E_BLUETOOTH_DEVICE_ALREADY_INSTALLED then begin
        // Reinstall to reconnect!
        Radio.UninstallDevice(Address, Service);
        Res := Radio.InstallDevice(Address, Service);
      end;

      if Res <> WCL_E_SUCCESS then
        ShowError(Res)
      else
        MessageDlg('Device installed', mtInformation, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btUninstallDeviceClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Service: TGUID;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    if lvServices.Selected = nil then
      MessageDlg('Select service', mtWarning, [mbOK], 0)

    else begin
      Item := lvDevices.Selected;
      Radio := TwclBluetoothRadio(Item.Data);
      Address := StrToInt64('$' + Item.SubItems[0]);
      Service := StringToGUID(lvServices.Selected.SubItems[2]);

      Res := Radio.UninstallDevice(Address, Service);
      if Res <> WCL_E_SUCCESS then
        ShowError(Res)
      else
        MessageDlg('Device uninstalled', mtInformation, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btIsInRangeClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
  InRange: Boolean;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);

    Res := Radio.IsRemoteDeviceInRange(Address, InRange);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res)
    else begin
      if InRange then
        ShowMessage('Device is in range')
      else
        ShowMessage('Device is NOT in range');
    end;
  end;
end;

procedure TfmMain.wclBluetoothManagerConfirm(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Confirm: Boolean);
begin
  Confirm := True;

  TraceEvent(Radio, 'Just Works pairing', 'Address', IntToHex(Address, 12));
end;

procedure TfmMain.wclBluetoothManagerIoCapabilityRequest(Sender: TObject;
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

  // To accept OOB pairing set this parameter to True.
  OobPresent := False;
end;

procedure TfmMain.wclBluetoothManagerOobDataRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out OobData: TwclBluetoothOobData);
begin
  // This event fires when a remote device requests OOB data.
  ZeroMemory(@OobData, SizeOf(TwclBluetoothOobData));
end;

procedure TfmMain.wclBluetoothManagerProtectionLevelRequest(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  out Protection: TwclBluetoothLeProtectionLevel);
begin
  case cbBleProtection.ItemIndex of
    0: Protection := pplDefault;
    1: Protection := pplNone;
    2: Protection := pplEncryption;
    3: Protection := pplEncryptionAndAuthentication;
    else Protection := pplDefault;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);
  wclBluetoothManager.AfterOpen := wclBluetoothManagerAfterOpen;
  wclBluetoothManager.BeforeClose := wclBluetoothManagerBeforeClose;
  wclBluetoothManager.OnAuthenticationCompleted := wclBluetoothManagerAuthenticationCompleted;
  wclBluetoothManager.OnClosed := wclBluetoothManagerClosed;
  wclBluetoothManager.OnConfirm := wclBluetoothManagerConfirm;
  wclBluetoothManager.OnDeviceFound := wclBluetoothManagerDeviceFound;
  wclBluetoothManager.OnDiscoveringCompleted := wclBluetoothManagerDiscoveringCompleted;
  wclBluetoothManager.OnDiscoveringStarted := wclBluetoothManagerDiscoveringStarted;
  wclBluetoothManager.OnIoCapabilityRequest := wclBluetoothManagerIoCapabilityRequest;
  wclBluetoothManager.OnNumericComparison := wclBluetoothManagerNumericComparison;
  wclBluetoothManager.OnOobDataRequest := wclBluetoothManagerOobDataRequest;
  wclBluetoothManager.OnPasskeyNotification := wclBluetoothManagerPasskeyNotification;
  wclBluetoothManager.OnPasskeyRequest := wclBluetoothManagerPasskeyRequest;
  wclBluetoothManager.OnPinRequest := wclBluetoothManagerPinRequest;
  wclBluetoothManager.OnProtectionLevelRequest := wclBluetoothManagerProtectionLevelRequest;
  wclBluetoothManager.OnStatusChanged := wclBluetoothManagerStatusChanged;

  FPowerMonitor := TwclPowerEventsMonitor.Create;
  FPowerMonitor.OnPowerStateChanged := PowerStateChanged;
  FPowerMonitor.Open;
end;

procedure TfmMain.PowerStateChanged(Sender: TObject;
  const State: TwclPowerState);
{$J+}
const
  WasOpened: Boolean = False;
{$J-}
begin
  case State of
    psResumeAutomatic:
      begin
        TraceEvent(nil, 'Power', 'State', 'psResumeAutomatic');
        if WasOpened then begin
          WasOpened := False;
          wclBluetoothManager.Open;
        end;
      end;

    psResume:
      TraceEvent(nil, 'Power', 'State', 'psResume');

    psSuspend:
      begin
        TraceEvent(nil, 'Power', 'State', 'psSuspend');
        if wclBluetoothManager.Active then begin
          WasOpened := True;
          wclBluetoothManager.Close;
        end;
      end;

    psUnknown:
      TraceEvent(nil, 'Power', 'State', 'psUnknown');
  end;
end;

procedure TfmMain.wclBluetoothManagerClosed(Sender: TObject);
begin
  ClearRadios;

  TraceEvent(nil, 'Closed', '', '');
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Item: TListItem;
  Radio: TwclBluetoothRadio;
  Address: Int64;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Item := lvDevices.Selected;
    Radio := TwclBluetoothRadio(Item.Data);
    Address := StrToInt64('$' + Item.SubItems[0]);
    Res := Radio.RemoteDisconnect(Address);
    if Res <> WCL_E_SUCCESS then
      ShowError(Res);
  end;
end;

end.
