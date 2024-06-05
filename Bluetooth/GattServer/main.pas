unit main;

{$MODE Delphi}

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, wclBluetooth, ComCtrls;

type
  TfmMain = class(TForm)
    btStart: TButton;
    btStop: TButton;
    btClear: TButton;
    lvDevices: TListView;
    laData: TLabel;
    edData: TEdit;
    btNotify: TButton;
    btNotifyAll: TButton;
    laRepeats: TLabel;
    edRepeats: TEdit;
    btDisconnect: TButton;
    btSetParameters: TButton;
    lbLog: TListBox;
    cbParams: TComboBox;
    procedure btClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure lvDevicesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btDisconnectClick(Sender: TObject);
    procedure edDataKeyPress(Sender: TObject; var Key: Char);
    procedure btNotifyAllClick(Sender: TObject);
    procedure btNotifyClick(Sender: TObject);
    procedure edRepeatsKeyPress(Sender: TObject; var Key: Char);
    procedure btSetParametersClick(Sender: TObject);

  private
    BluetoothManager: TwclBluetoothManager;
    GattServer: TwclGattServer;

    procedure BluetoothManagerAfterOpen(Sender: TObject);
    procedure BluetoothManagerBeforeClose(Sender: TObject);
    procedure BluetoothManagerClosed(Sender: TObject);

    procedure GattServerStarted(Sender: TObject);
    procedure GattServerStopped(Sender: TObject);
    procedure GattServerClientConnected(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure GattServerMaxPduSizeChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure GattServerConnectionParamsChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure GattServerConnectionPhyChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure GattServerNotificationSizeChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure GattServerClientDisconnected(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure GattServerWrite(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic;
      const Request: TwclGattLocalCharacteristicWriteRequest);
    procedure GattServerSubscribed(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic);
    procedure GattServerUnsubscribed(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic);
    procedure GattServerRead(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic;
      const Request: TwclGattLocalCharacteristicReadRequest);

    procedure Trace(const Msg: string); overload;
    procedure Trace(const Spaces: Byte; const Msg: string); overload;
    procedure Trace(const Msg: string; const Error: Integer); overload;
    procedure Trace(const Spaces: Byte; const Msg: string;
      const Error: Integer); overload;

    function InitializeBluetooth(out Radio: TwclBluetoothRadio): Boolean;
    procedure UninitializeBluetooth;

    function InitializeServer(const Radio: TwclBluetoothRadio): Boolean;
    procedure UninitializeServer;

    function AddCharacteristics(const Service: TwclGattLocalService): Boolean;
    function AddService: TwclGattLocalService;

    procedure Start;
    procedure Stop;

    function FindItem(const Client: TwclGattServerClient): TListItem;

    procedure UpdateMaxPduSize(const Client: TwclGattServerClient);
    procedure UpdateConnectionParams(const Client: TwclGattServerClient);
    procedure UpdatePhy(const Client: TwclGattServerClient);
    procedure UpdateNotificationSize(const Client: TwclGattServerClient);

    procedure UpdateNotifyAllStatus;

    procedure Notify(const Address: Int64);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclBluetoothErrors, wclErrors;

const
  SHORT_DATA_LEN = 5;
  LONG_DATA_LEN = 1024;

var
  LongData: array [0..LONG_DATA_LEN - 1] of Byte;
  ShortData: array [0..SHORT_DATA_LEN - 1] of Byte;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.Trace(const Msg: string);
begin
  lbLog.Items.Add(Msg);
  lbLog.TopIndex := lbLog.Items.Count - 1;
end;

procedure TfmMain.Trace(const Spaces: Byte; const Msg: string);
var
  Str: string;
begin
  Str := '';
  if Spaces > 0 then
    Str := StringOfChar(' ', Spaces);
  Str := Str + Msg;
  Trace(Str);
end;

procedure TfmMain.Trace(const Msg: string; const Error: Integer);
begin
  Trace(Msg + ' failed: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.Trace(const Spaces: Byte; const Msg: string;
  const Error: Integer);
begin
  Trace(Spaces, Msg + ' failed: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  BluetoothManager := TwclBluetoothManager.Create(nil);
  BluetoothManager.AfterOpen := BluetoothManagerAfterOpen;
  BluetoothManager.BeforeClose := BluetoothManagerBeforeClose;
  BluetoothManager.OnClosed := BluetoothManagerClosed;

  GattServer := TwclGattServer.Create(nil);
  GattServer.OnStarted := GattServerStarted;
  GattServer.OnStopped := GattServerStopped;
  GattServer.OnClientConnected := GattServerClientConnected;
  GattServer.OnMaxPduSizeChanged := GattServerMaxPduSizeChanged;
  GattServer.OnConnectionParamsChanged := GattServerConnectionParamsChanged;
  GattServer.OnConnectionPhyChanged := GattServerConnectionPhyChanged;
  GattServer.OnNotificationSizeChanged := GattServerNotificationSizeChanged;
  GattServer.OnClientDisconnected := GattServerClientDisconnected;
  GattServer.OnWrite := GattServerWrite;
  GattServer.OnSubscribed := GattServerSubscribed;
  GattServer.OnUnsubscribed := GattServerUnsubscribed;
  GattServer.OnRead := GattServerRead;

  btStop.Enabled := False;
  btDisconnect.Enabled := False;
  btNotify.Enabled := False;
  btNotifyAll.Enabled := False;
  btSetParameters.Enabled := False;

  for i := 0 to SHORT_DATA_LEN - 1 do
    ShortData[i] := i + 1;
  for i := 0 to LONG_DATA_LEN - 1 do
    LongData[i] := LOBYTE(i);
end;

procedure TfmMain.BluetoothManagerAfterOpen(Sender: TObject);
begin
  Trace('Bluetooth Manager opened');
end;

procedure TfmMain.BluetoothManagerBeforeClose(Sender: TObject);
begin
  Trace('Bluetooth Manager is closing');
end;

procedure TfmMain.BluetoothManagerClosed(Sender: TObject);
begin
  Trace('Bluetooth Manager closed');
end;

procedure TfmMain.GattServerStarted(Sender: TObject);
begin
  btStop.Enabled := True;
  btStart.Enabled := False;

  Trace('Server started');
end;

procedure TfmMain.GattServerStopped(Sender: TObject);
begin
  btStop.Enabled := False;
  btStart.Enabled := True;

  Trace('Server stopped');
end;

function TfmMain.InitializeBluetooth(out Radio: TwclBluetoothRadio): Boolean;
var
  Res: Integer;
begin
  Radio := nil;

  Result := False;

  Trace('Opening Bluetooth Manager');
  Res := BluetoothManager.Open();
  if Res <> WCL_E_SUCCESS then
    Trace('Open Bluetooth Manager', Res)

  else begin
    Trace('Get working LE Radio');
    Res := BluetoothManager.GetLeRadio(Radio);
    if Res <> WCL_E_SUCCESS then
      Trace('Get working LE Radio', Res)

    else begin
      Trace('Working radio found. Use ' + Radio.ApiName + ' radio');
      Result := True;
    end;

    if not Result then begin
      Trace('Closing Bluetooth Manager');
      BluetoothManager.Close;
    end;
  end;
end;

procedure TfmMain.UninitializeBluetooth;
begin
  if BluetoothManager.Active then begin
    Trace('Closing Bluetooth Manager');
    BluetoothManager.Close;
  end;
end;

function TfmMain.InitializeServer(const Radio: TwclBluetoothRadio): Boolean;
var
  Res: Integer;
begin
  Trace('Initializing GATT server');
  Res := GattServer.Initialize(Radio);
  if Res <> WCL_E_SUCCESS then begin
    Trace('GATT server initialization', Res);
    Result := False;

  end else begin
    Trace('GATT server initialized');
    Result := True;
  end;
end;

procedure TfmMain.UninitializeServer;
var
  Res: Integer;
begin
  if GattServer.Initialized then begin
    Trace('Uninitializing GATT server');
    Res := GattServer.Uninitialize;
    if Res <> WCL_E_SUCCESS then
      Trace('GATT server uninitialization', Res);
  end;
end;

function TfmMain.AddCharacteristics(
  const Service: TwclGattLocalService): Boolean;
var
  Uuid: TwclGattUuid;
  Params: TwclGattLocalCharacteristicParameters;
  Char: TwclGattLocalCharacteristic;
  Res: Integer;
begin
  Result := False;

  Trace(4, 'Adding GATT characteristics');

  Uuid.IsShortUuid := True;
  Params.Descriptors := nil;
  Params.PresentationFormats := nil;

  Trace(8, 'Add empty characteristic');
  Uuid.ShortUuid := $FFF1;
  Params.Props := [];
  Params.UserDescription := 'Empty characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then
    Trace(12, 'Add empty characteristic', Res)

  else begin
    Trace(12, 'Empty characteristic added');

    Trace(8, 'Add short readable characteristic');
    Uuid.ShortUuid := $FFF2;
    Params.Props := [cpReadable];
    Params.UserDescription := 'Short readable characteristic';
    Res := Service.AddCharacteristic(Uuid, Params, Char);
    if Res <> WCL_E_SUCCESS then
      Trace(12, 'Add short readable characteristic', Res)

    else begin
      Trace(12, 'Short readable characteristic added');

      Trace(8, 'Add long readable characteristic');
      Uuid.ShortUuid := $FFF3;
      Params.Props := [cpReadable];
      Params.UserDescription := 'Long readable characteristic';
      Res := Service.AddCharacteristic(Uuid, Params, Char);
      if Res <> WCL_E_SUCCESS then
        Trace(12, 'Add long readable characteristic: 0x', Res)

      else begin
        Trace(12, 'Long readable characteristic added');

        Trace(8, 'Add writable characteristic');
        Uuid.ShortUuid := $FFF4;
        Params.Props := [cpWritable, cpWritableWithoutResponse];
        Params.UserDescription := 'Writable characteristic';
        Res := Service.AddCharacteristic(Uuid, Params, Char);
        if Res <> WCL_E_SUCCESS then
          Trace(12, 'Add writable characteristic', Res)

        else begin
          Trace(12, 'Writable characteristic added');

          Trace(8, 'Add notifiable characteristic');
          Uuid.ShortUuid := $FFF5;
          Params.Props := [cpNotifiable];
          Params.UserDescription := 'Notifiable characteristic';
          Res := Service.AddCharacteristic(Uuid, Params, Char);
          if Res <> WCL_E_SUCCESS then
            Trace(12, 'Add notifiable characteristic', Res)

          else begin
            Trace(12, 'Notifiable characteristic added');

            Trace(8, 'Add indicatable characteristic');
            Uuid.ShortUuid := $FFF6;
            Params.Props := [cpIndicatable];
            Params.UserDescription := 'Indicatable characteristic';
            Res := Service.AddCharacteristic(Uuid, Params, Char);
            if Res <> WCL_E_SUCCESS then
              Trace(12, 'Add indicatable characteristic', Res)

            else begin
              Trace(12, 'Indicatable characteristic added');

              Trace(4, 'All GATT charactertistics added');
              Result := True;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TfmMain.AddService: TwclGattLocalService;
var
  Uuid: TwclGattUuid;
  Res: Integer;
begin
  Trace('Adding GATT service');

  Uuid.IsShortUuid := True;
  Uuid.ShortUuid := $FFF0;
  Res := GattServer.AddService(Uuid, Result);
  if Res <> WCL_E_SUCCESS then
    Trace(4, 'Add GATT service', Res)
  else
    Trace('GATT service added');
end;

procedure TfmMain.Start;
var
  Radio: TwclBluetoothRadio;
  BoolRes: Boolean;
  Service: TwclGattLocalService;
  Res: Integer;
begin
  Radio := nil;
  if InitializeBluetooth(Radio) then begin
    BoolRes := InitializeServer(Radio);
    if BoolRes then begin
      Service := AddService;
      if Service = nil then
        BoolRes := False

      else begin
        BoolRes := AddCharacteristics(Service);
        if BoolRes then begin
          Trace('Starting GATT server');
          Res := GattServer.Start;
          if Res <> WCL_E_SUCCESS then begin
            Trace('GATT server start', Res);
            BoolRes := False;
          end;
        end;
      end;

      if not BoolRes then
        UninitializeServer;
    end;

    if not BoolRes then
      UninitializeBluetooth;
  end;
end;

procedure TfmMain.Stop;
var
  Res: Integer;
begin
  Trace('Stopping GATT server');

  Res := GattServer.Stop;
  if Res <> WCL_E_SUCCESS then
    Trace('Stop GATT server', Res);

  UninitializeServer;
  UninitializeBluetooth;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  Stop;

  GattServer.Free;
  BluetoothManager.Free;
end;

procedure TfmMain.btStartClick(Sender: TObject);
begin
  Start;
end;

procedure TfmMain.btStopClick(Sender: TObject);
begin
  Stop;
end;

function TfmMain.FindItem(const Client: TwclGattServerClient): TListItem;
var
  i: Integer;
begin
  Result := nil;

  if Client <> nil then begin
    if lvDevices.Items.Count > 0 then begin
      for i := 0 to lvDevices.Items.Count - 1 do begin
        if lvDevices.Items[i].Data = Client then begin
          Result := lvDevices.Items[i];
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfmMain.UpdateMaxPduSize(const Client: TwclGattServerClient);
var
  Item: TListItem;
  Size: Word;
begin
  Item := FindItem(Client);
  if Item <> nil then begin
    if Client.GetMaxPduSize(Size) = WCL_E_SUCCESS then
      Item.SubItems[1] := IntToStr(Size)
    else
      Item.SubItems[1] := '-----';
  end;
end;

procedure TfmMain.UpdateConnectionParams(const Client: TwclGattServerClient);
var
  Item: TListItem;
  Params: TwclBluetoothLeConnectionParameters;
begin
  Item := FindItem(Client);
  if Item <> nil then begin
    if Client.GetConnectionParams(Params) = WCL_E_SUCCESS then begin
      Item.SubItems[2] := IntToStr(Params.Interval);
      Item.SubItems[3] := IntToStr(Params.Latency);
      Item.SubItems[4] := IntToStr(Params.LinkTimeout);

    end else begin
      Item.SubItems[2] := '-----';
      Item.SubItems[3] := '-----';
      Item.SubItems[4] := '-----';
    end;
  end;
end;

procedure TfmMain.UpdatePhy(const Client: TwclGattServerClient);
var
  Item: TListItem;
  Phy: TwclBluetoothLeConnectionPhy;
begin
  Item := FindItem(Client);
  if Item <> nil then begin
    if Client.GetConnectionPhyInfo(Phy) = WCL_E_SUCCESS then begin
      Item.SubItems[5] := BoolToStr(Phy.Receive.IsCoded);
      Item.SubItems[6] := BoolToStr(Phy.Receive.IsUncoded1MPhy);
      Item.SubItems[7] := BoolToStr(Phy.Receive.IsUncoded2MPhy);

      Item.SubItems[8] := BoolToStr(Phy.Transmit.IsCoded);
      Item.SubItems[9] := BoolToStr(Phy.Transmit.IsUncoded1MPhy);
      Item.SubItems[10] := BoolToStr(Phy.Transmit.IsUncoded2MPhy);

    end else begin
      Item.SubItems[5] := '-----';
      Item.SubItems[6] := '-----';
      Item.SubItems[7] := '-----';
      Item.SubItems[8] := '-----';
      Item.SubItems[9] := '-----';
      Item.SubItems[10] := '-----';
    end;
  end;
end;

procedure TfmMain.UpdateNotificationSize(const Client: TwclGattServerClient);
var
  Item: TListItem;
  Size: Word;
begin
  Item := FindItem(Client);
  if Item <> nil then begin
    if Client.GetMaxNotificationSize(Size) = WCL_E_SUCCESS then
      Item.SubItems[11] := IntToStr(Size)
    else
      Item.SubItems[11] := '-----';
  end;
end;

procedure TfmMain.GattServerClientConnected(Sender: TObject;
  const Client: TwclGattServerClient);
var
  Item: TListItem;
begin
  Trace('Client connected: ' + IntToHex(Client.Address, 12));

  Item := lvDevices.Items.Add;
  Item.Caption := IntToHex(Client.Address, 12);
  Item.Data := Client;
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');
  Item.SubItems.Add('');

  UpdateMaxPduSize(Client);
  UpdateConnectionParams(Client);
  UpdatePhy(Client);
  UpdateNotificationSize(Client);
end;

procedure TfmMain.GattServerMaxPduSizeChanged(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  UpdateMaxPduSize(Client);

  Trace('Max PDU size changed: ' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.GattServerConnectionParamsChanged(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  UpdateConnectionParams(Client);

  Trace('Connection parameters changed: ' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.GattServerConnectionPhyChanged(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  UpdatePhy(Client);

  Trace('PHY changed: ' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.GattServerNotificationSizeChanged(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  UpdateNotificationSize(Client);

  Trace('Notification size changed: ' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.GattServerClientDisconnected(Sender: TObject;
  const Client: TwclGattServerClient);
var
  Item: TListItem;
begin
  Trace('Client disconnected: ' + IntToHex(Client.Address, 12));

  Item := FindItem(Client);
  if Item <> nil then begin
    // Characteristics should already be removed because unsubscribe always
    // called before disconnect.
    lvDevices.Items.Delete(Item.Index);

    UpdateNotifyAllStatus;
  end;
end;

procedure TfmMain.lvDevicesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if lvDevices.Selected <> nil then begin
    btDisconnect.Enabled := (lvDevices.Selected.Caption <> '');
    btNotify.Enabled := (lvDevices.Selected.Caption = '');
    btSetParameters.Enabled := (lvDevices.Selected.Caption <> '');

  end else begin
    btDisconnect.Enabled := False;
    btNotify.Enabled := False;
    btSetParameters.Enabled := False;
  end;

  UpdateNotifyAllStatus;
end;

procedure TfmMain.UpdateNotifyAllStatus;
var
  Found: Boolean;
  i: Integer;
begin
  Found := False;

  if lvDevices.Items.Count > 0 then begin
    for i := 0 to lvDevices.Items.Count - 1 do begin
      if lvDevices.Items[i].Caption = '' then begin
        Found := True;
        Break;
      end;
    end;
  end;

  btNotifyAll.Enabled := (Found and (lvDevices.Selected <> nil) and
    (lvDevices.Selected.Caption = ''));
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  // Button is disabled if nothing or incorrect line selected.
  Res := TwclGattServerClient(lvDevices.Selected.Data).Disconnect;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Disconnect error: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.GattServerWrite(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic;
  const Request: TwclGattLocalCharacteristicWriteRequest);
var
  s: String;
  i: Cardinal;
  Res: Integer;
begin
  Trace('Write request received from: ' + IntToHex(Client.Address, 12));
  Trace(4, 'Characteristic: ' + IntToHex(Characteristic.Uuid.ShortUuid, 4));
  Trace(4, 'Size: ' + IntToStr(Request.Size));
  Trace(4, 'Offset: ' + IntToStr(Request.Offset));

  s := '';
  for i := 0 to Request.Size - 1 do
    s := s + IntToHex(Byte(PAnsiChar(Request.Data)[i]), 2);
  Trace(8, s);

  if Request.WithResponse then begin
    Trace(4, 'Sending response');
    Res := Request.Respond;
    // If data is incorrect you can answer with error using:
    //         Res := Request.RespondWithError(Error);
    // For possible error code refer to RespondWithError() method description.
    if Res <> WCL_E_SUCCESS then
      Trace(8, 'Send response', Res)
    else
      Trace(8, 'Response sent');
  end;
end;

procedure TfmMain.edDataKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['0'..'9', #8, 'a'..'f', 'A'..'F'] then
    inherited
  else
    Key := #0;
end;

procedure TfmMain.GattServerSubscribed(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic);
var
  Item: TListItem;
begin
  Trace('Client ' + IntToHex(Client.Address, 12) + ' subscribed to');
  Trace(4, 'Characteristic: ' + IntToHex(Characteristic.Uuid.ShortUuid, 4));

  // Client already connected on this stage.
  Item := FindItem(Client);
  if Item <> nil then begin
    Item := lvDevices.Items.Insert(Item.Index + 1);
    Item.Caption := '';
    Item.Data := Characteristic;
    Item.SubItems.Add(IntToHex(Characteristic.Uuid.ShortUuid, 4));
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');
    Item.SubItems.Add('');

    UpdateNotificationSize(Client);
    UpdateNotifyAllStatus;
  end;
end;

procedure TfmMain.GattServerUnsubscribed(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic);
var
  Item: TListItem;
  i: Integer;
begin
  Trace('Client ' + IntToHex(Client.Address, 12) + ' unsubscribed from');
  Trace(4, 'Characteristic: ' + IntToHex(Characteristic.Uuid.ShortUuid, 4));

  Item := FindItem(Client);
  if Item <> nil then begin
    if Item.Index < lvDevices.Items.Count - 1 then begin
      for i := Item.Index + 1 to lvDevices.Items.Count - 1 do begin
        Item := lvDevices.Items[i];
        if Item.Caption <> '' then
          Break;

        if Item.Data = Characteristic then begin
          lvDevices.Items.Delete(Item.Index);

          UpdateNotificationSize(Client);
          UpdateNotifyAllStatus;

          Break;
        end;
      end;
    end;
  end;
end;

procedure TfmMain.GattServerRead(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic;
  const Request: TwclGattLocalCharacteristicReadRequest);
var
  Res: Integer;
begin
  Trace('Read request received from: ' + IntToHex(Client.Address, 12));
  Trace(4, 'Characteristic: ' + IntToHex(Characteristic.Uuid.ShortUuid, 4));
  Trace(4, 'Offset: ' + IntToStr(Request.Offset));
  Trace(4, 'Buffer size: ' + IntToStr(Request.Size));

  if Characteristic.Uuid.ShortUuid = $FFF2 then
    Res := Request.Respond(@ShortData, SHORT_DATA_LEN)
  else begin
    Res := Request.Respond(@LongData[Request.Offset],
      LONG_DATA_LEN - Request.Offset);
  end;

  if Res <> WCL_E_SUCCESS then begin
    Trace(8, 'Set data', Res);
    Trace(8, 'Respond with error');
    // For possible error code refer to RespondWithError() method description.
    Res := Request.RespondWithError(WCL_E_BLUETOOTH_LE_UNLIKELY);
    if Res <> WCL_E_SUCCESS then
      Trace(12, 'Respond', Res);

  end else
    Trace(8, 'Data sent');
end;

procedure TfmMain.Notify(const Address: Int64);
var
  Characteristic: TwclGattLocalCharacteristic;
  Res: Integer;
  Len: Integer;
  Str: string;
  DataLen: Integer;
  Data: array of Byte;
  i: Integer;
  Repeats: Integer;
  Start: UInt64;
  _End: UInt64;
begin
  Len := Length(edData.Text);
  if Len = 0 then
    ShowMessage('Data is empty')

  else begin
    if edRepeats.Text = '' then
      Repeats := 1
    else
      Repeats := StrToInt(edRepeats.Text);

    if Repeats > 20 then
      ShowMessage('Too many notification repeats')

    else begin
      Characteristic := TwclGattLocalCharacteristic(lvDevices.Selected.Data);

      if Address = 0 then
        Trace('Sending notification to all subscribed clients')
      else
        Trace('Sending notification to ' + IntToHex(Address, 12));
      Trace(4, 'Characteristic: ' + IntToHex(Characteristic.Uuid.ShortUuid, 4));

      Str := edData.Text;
      if Odd(Len) then begin
        Str := '0' + Str;
        Inc(Len);
      end;

      DataLen := Len div 2;
      Data := nil;
      SetLength(Data, DataLen);
      for i := 0 to DataLen - 1 do
        Data[i] := StrToInt('$' + Copy(Str, i * 2 + 1, 2));

      for i := 0 to Repeats - 1 do begin
        if Address = 0 then begin
          Start := GetTickCount64;
          Res := Characteristic.Notify(@Data[0], DataLen);
          _End := GetTickCount64;
        end else begin
          Start := GetTickCount64;
          Res := Characteristic.Notify(Address, @Data[0], DataLen);
          _End := GetTickCount64;
        end;

        if Res <> WCL_E_SUCCESS then
          Trace(8, 'Attempt [' + IntToStr(i + 1) + ']', Res)

        else begin
          Trace(8, 'Attempt [' + IntToStr(i + 1) + '] took ' +
            IntToStr(_End - Start) + ' ms');
        end;
      end;
      
      Trace('Notification procedure completed');
    end;
  end;
end;

procedure TfmMain.btNotifyAllClick(Sender: TObject);
begin
  Notify(0);
end;

procedure TfmMain.btNotifyClick(Sender: TObject);
var
  i: Integer;
begin
  for i := lvDevices.Selected.Index downto 0 do begin
    if lvDevices.Items[i].Caption <> '' then begin
      Notify(TwclGattServerClient(lvDevices.Items[i].Data).Address);
      Break;
    end;
  end;
end;

procedure TfmMain.edRepeatsKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key in ['0'..'9']) or (Key = #8) then
    inherited
  else
    Key := #0;
end;

procedure TfmMain.btSetParametersClick(Sender: TObject);
var
  Client: TwclGattServerClient;
  ParamsValue: TwclBluetoothLeConnectionParametersValue;
  Params: TwclBluetoothLeConnectionParametersType;
  Res: Integer;
begin
  Client := TwclGattServerClient(lvDevices.Selected.Data);

  Trace('Set connection parameters for ' + IntToHex(Client.Address, 12));
  if cbParams.ItemIndex = 3 then begin
    ParamsValue.MinInterval := 84;
    ParamsValue.MaxInterval := 84;
    ParamsValue.Latency := 0;
    ParamsValue.LinkTimeout := 800;
    Res := Client.SetConnectionParams(ParamsValue);

  end else begin
    case cbParams.ItemIndex of
      0: Params := ppBalanced;
      1: Params := ppPowerOptimized;
      2: Params := ppThroughputOptimized;
      else raise wclEInvalidArgument.Create('Invalid connection parameters.');
    end;
    Res := Client.SetConnectionParams(Params);
  end;

  if Res <> WCL_E_SUCCESS then
    Trace(4, 'Set connection parameters', Res)
  else
    Trace(4, 'Connection parameters set');
end;

end.
