unit main;

{$I wcl.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, wclBluetooth;

const
  SHORT_DATA_LEN = 5;
  LONG_DATA_LEN = 1024;

type

  { TfmMain }

  TfmMain = class(TForm)
    btStart: TButton;
    btStop: TButton;
    btClear: TButton;
    lbLog: TListBox;
    procedure btClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclGattServer: TwclGattServer;

    FCounter: Cardinal;
    FStarted: Boolean;

    FLongData: array [0..LONG_DATA_LEN - 1] of Byte;
    FShortData: array [0..SHORT_DATA_LEN - 1] of Byte;

    procedure wclBluetoothManagerAfterOpen(Sender: TObject);
    procedure wclBluetoothManagerBeforeClose(Sender: TObject);

    procedure wclGattServerStarted(Sender: TObject);
    procedure wclGattServerStopped(Sender: TObject);
    procedure wclGattServerRead(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic;
      const Request: TwclGattLocalCharacteristicReadRequest);
    procedure wclGattServerWrite(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic;
      const Request: TwclGattLocalCharacteristicWriteRequest);
    procedure wclGattServerUnsubscribed(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic);
    procedure wclGattServerSubscribed(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic);
    procedure wclGattServerClientConnected(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure wclGattServerClientDisconnected(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure wclGattServerNotificationSizeChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure wclGattServerMaxPduSizeChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure wclGattServerConnectionParamsChanged(Sender: TObject;
      const Client: TwclGattServerClient);
    procedure wclGattServerConnectionPhyChanged(Sender: TObject;
      const Client: TwclGattServerClient);

    function InitBluetooth(out Radio: TwclBluetoothRadio): Boolean;
    procedure UninitBluetooth;
    function InitServer(Radio: TwclBluetoothRadio): Boolean;
    procedure UninitServer;
    function AddCharacteristics(Service: TwclGattLocalService): Boolean;
    function AddServices: Boolean;
    procedure Start;
    procedure Stop;

    procedure GetConParams(const Client: TwclGattServerClient);
    procedure GetConPhy(const Client: TwclGattServerClient);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, wclBluetoothErrors;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
var
  i: Word;
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);
  wclBluetoothManager.AfterOpen := wclBluetoothManagerAfterOpen;
  wclBluetoothManager.BeforeClose := wclBluetoothManagerBeforeClose;

  wclGattServer := TwclGattServer.Create(nil);
  wclGattServer.OnRead := wclGattServerRead;
  wclGattServer.OnStarted := wclGattServerStarted;
  wclGattServer.OnStopped := wclGattServerStopped;
  wclGattServer.OnSubscribed := wclGattServerSubscribed;
  wclGattServer.OnUnsubscribed := wclGattServerUnsubscribed;
  wclGattServer.OnWrite := wclGattServerWrite;
  wclGattServer.OnClientConnected := wclGattServerClientConnected;
  wclGattServer.OnClientDisconnected := wclGattServerClientDisconnected;
  wclGattServer.OnNotificationSizeChanged := wclGattServerNotificationSizeChanged;
  wclGattServer.OnMaxPduSizeChanged := wclGattServerMaxPduSizeChanged;
  wclGattServer.OnConnectionParamsChanged := wclGattServerConnectionParamsChanged;
  wclGattServer.OnConnectionPhyChanged := wclGattServerConnectionPhyChanged;

  FStarted := False;

  for i := 0 to SHORT_DATA_LEN - 1 do
    FShortData[i] := i + 1;
  for i := 0 to LONG_DATA_LEN - 1 do
    FLongData[i] := LOBYTE(i);
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.wclBluetoothManagerAfterOpen(Sender: TObject);
begin
  lbLog.Items.Add('Bluetooth Manager has been opened');
end;

procedure TfmMain.wclBluetoothManagerBeforeClose(Sender: TObject);
begin
  lbLog.Items.Add('Bluetooth Manager is closing');
end;

procedure TfmMain.wclGattServerStarted(Sender: TObject);
begin
  lbLog.Items.Add('Server has been started');
  FStarted := True;
  FCounter := 0;
end;

procedure TfmMain.wclGattServerStopped(Sender: TObject);
begin
  lbLog.Items.Add('Server has been stopped');
  FStarted := False;
end;

procedure TfmMain.wclGattServerRead(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic;
  const Request: TwclGattLocalCharacteristicReadRequest);
var
  Res: Integer;
  IsShort: Boolean;
begin
  lbLog.Items.Add('Read request from ' + IntToHex(Client.Address, 12));
  lbLog.Items.Add('  Offset: ' + IntToStr(Request.Offset));
  lbLog.Items.Add('  Read Buffer Size: ' + IntToStr(Request.Size));

  IsShort := (Characteristic.Uuid.IsShortUuid and
    (Characteristic.Uuid.ShortUuid = $FFF2));
  if IsShort then
    Res := Request.Respond(@FShortData, SHORT_DATA_LEN)

  else begin
    Res := Request.Respond(@FLongData[Request.Offset],
      LONG_DATA_LEN - Request.Offset);
  end;
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('  Set data failed: 0x' + IntToHex(Res, 8));
    lbLog.Items.Add('  respond with error');
    Res := Request.RespondWithError(WCL_E_BLUETOOTH_LE_UNLIKELY);
    if Res <> WCL_E_SUCCESS then
      lbLog.Items.Add('  Respond failed: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.wclGattServerWrite(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic;
  const Request: TwclGattLocalCharacteristicWriteRequest);
var
  s: String;
  i: Cardinal;
  Res: Integer;
begin
  lbLog.Items.Add('Data received from ' + IntToHex(Client.Address, 12));
  lbLog.Items.Add('  Size: ' + IntToStr(Request.Size));
  lbLog.Items.Add('  Offset: ' + IntToStr(Request.Offset));

  s := '';
  for i := 0 to Request.Size - 1 do
    s := s + IntToHex(Byte(PAnsiChar(Request.Data)[i]), 2);
  lbLog.Items.Add(s);

  if Request.WithResponse then begin
    lbLog.Items.Add('  Write With Response. Sending response');
    Res := Request.Respond;
    if Res <> WCL_E_SUCCESS then
      lbLog.Items.Add('  Respond failed: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.wclGattServerUnsubscribed(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic);
begin
  lbLog.Items.Add('Client unsubscribed :' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.wclGattServerClientConnected(Sender: TObject;
  const Client: TwclGattServerClient);
var
  Res: Integer;
  Size: Word;
begin
  lbLog.Items.Add('Client connected :' + IntToHex(Client.Address, 12));

  Res := Client.GetMaxPduSize(Size);
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Get max PDU size failed: 0x' + IntToHex(Res, 8))
  else
    lbLog.Items.Add('Max PDU size: ' + IntToStr(Size));

  GetConParams(Client);
  GetConPhy(Client);
end;

procedure TfmMain.wclGattServerConnectionParamsChanged(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  GetConParams(Client);
end;

procedure TfmMain.wclGattServerClientDisconnected(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  lbLog.Items.Add('Client disconnected :' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.wclGattServerSubscribed(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic);
var
  Str: string;
  Res: Integer;
  Size: Word;
begin
  Str := 'Client subscribed: ' + IntToHex(Client.Address, 12);

  Res := Client.GetMaxNotificationSize(Size);
  if Res <> WCL_E_SUCCESS then
    Str := Str + ' Get max notification size failed: 0x' + IntToHex(Res, 8)
  else
    Str := Str + ' Max notification size: ' + IntToStr(Size);
  lbLog.Items.Add(Str);

  Res := Characteristic.Notify(Client.Address, @FCounter, 4);
  Inc(FCounter);
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Notification failed: ' + IntToHex(Res, 8));
end;

function TfmMain.InitBluetooth(out Radio: TwclBluetoothRadio): Boolean;
var
  Res: Integer;
begin
  Radio := nil;

  Result := False;
  
  Res := wclBluetoothManager.Open();
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Bluetooth Manager open failed: 0x' + IntToHex(Res, 8))

  else begin
    lbLog.Items.Add('Checking for working Radio');
    Res := wclBluetoothManager.GetLeRadio(Radio);
    if Res <> WCL_E_SUCCESS then
      lbLog.Items.Add('Get workign radio failed: 0x' + IntToHex(Res, 8))

    else begin
      lbLog.Items.Add('Use ' + Radio.ApiName + ' radio');
      Result := True;
    end;

    if not Result then
      wclBluetoothManager.Close;
  end;
end;

procedure TfmMain.UninitBluetooth;
begin
  lbLog.Items.Add('Close Bluetooth manager');
  if wclBluetoothManager.Active then
    wclBluetoothManager.Close;
end;

function TfmMain.InitServer(Radio: TwclBluetoothRadio): Boolean;
var
  Res: Integer;
begin
  lbLog.Items.Add('Initialize server');
  Res := wclGattServer.Initialize(Radio);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Initialize server failed: 0x' + IntToHex(Res, 8));
    Result := False;
  end else begin
    lbLog.Items.Add('Server initialized');
    Result := True;
  end;
end;

procedure TfmMain.UninitServer;
var
  Res: Integer;
begin
  lbLog.Items.Add('Uninitializing server');
  Res := wclGattServer.Uninitialize;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Uninitialize server failed: 0x' + IntToHex(Res, 8));
end;

function TfmMain.AddCharacteristics(
  Service: TwclGattLocalService): Boolean;
var
  Uuid: TwclGattUuid;
  Params: TwclGattLocalCharacteristicParameters;
  Char: TwclGattLocalCharacteristic;
  Res: Integer;
begin
  lbLog.Items.Add('Adding characteristics services');

  Uuid.IsShortUuid := True;
  Params.Descriptors := nil;
  Params.PresentationFormats := nil;

  lbLog.Items.Add('Add empty characteristic');
  Uuid.ShortUuid := $FFF1;
  Params.Props := [];
  Params.UserDescription := 'Empty characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add empty characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
    Exit;
  end;

  lbLog.Items.Add('Add short readable characteristic');
  Uuid.ShortUuid := $FFF2;
  Params.Props := [cpReadable];
  Params.UserDescription := 'Short readable characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add short readable characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
    Exit;
  end;

  lbLog.Items.Add('Add long readable characteristic');
  Uuid.ShortUuid := $FFF3;
  Params.Props := [cpReadable];
  Params.UserDescription := 'Long readable characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add long readable characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
    Exit;
  end;

  lbLog.Items.Add('Add writable characteristic');
  Uuid.ShortUuid := $FFF4;
  Params.Props := [cpWritable, cpWritableWithoutResponse];
  Params.UserDescription := 'Writable characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add writable characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
    Exit;
  end;

  lbLog.Items.Add('Add notifiable characteristic');
  Uuid.ShortUuid := $FFF5;
  Params.Props := [cpNotifiable];
  Params.UserDescription := 'Notifiable characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add notifiable characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
    Exit;
  end;

  lbLog.Items.Add('Add indicatable characteristic');
  Uuid.ShortUuid := $FFF6;
  Params.Props := [cpIndicatable];
  Params.UserDescription := 'Indicatable characteristic';
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add indicatable characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
    Exit;
  end;

  lbLog.Items.Add('All charactertistics were added');
  Result := True;
end;

function TfmMain.AddServices: Boolean;
var
  Uuid: TwclGattUuid;
  Service: TwclGattLocalService;
  Res: Integer;
begin
  lbLog.Items.Add('Preparing services');

  Uuid.IsShortUuid := True;
  Uuid.ShortUuid := $FFF0;

  lbLog.Items.Add('Add service');
  Res := wclGattServer.AddService(Uuid, Service);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add service: 0x' + IntToHex(Res, 8));
    Result := False;
  end else begin
    lbLog.Items.Add('Service has been added');
    Result := AddCharacteristics(Service);
  end;
end;

procedure TfmMain.Start;
var
  Radio: TwclBluetoothRadio;
  Result: Boolean;
  Res: Integer;
begin
  if FStarted then
    lbLog.Items.Add('Already started')
  else begin
    Radio := nil;
    if InitBluetooth(Radio) then begin
      Result := InitServer(Radio);
      if Result then begin
        Result := AddServices;
        if Result then begin
          lbLog.Items.Add('Starting server');
          Res := wclGattServer.Start;
          if Res <> WCL_E_SUCCESS then begin
            lbLog.Items.Add('Start server failed: 0x' + IntToHex(Res, 8));
            Result := False;
          end;
        end;
        if not Result then
          UninitServer;
      end;
      if not Result then
        UninitBluetooth;
    end;
  end;
end;

procedure TfmMain.Stop;
var
  Res: Integer;
begin
  if not FStarted then
    lbLog.Items.Add('Not started')
  else begin
    lbLog.Items.Add('Stopping server');
    Res := wclGattServer.Stop;
    if Res <> WCL_E_SUCCESS then
      lbLog.Items.Add('Stop server failed: 0x' + IntToHex(Res, 8));

    UninitServer;
    UninitBluetooth;
  end;
end;

procedure TfmMain.btStartClick(Sender: TObject);
begin
  Start;
end;

procedure TfmMain.btStopClick(Sender: TObject);
begin
  Stop;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  Stop;

  wclGattServer.Free;
  wclBluetoothManager.Free;
end;

procedure TfmMain.wclGattServerNotificationSizeChanged(Sender: TObject;
  const Client: TwclGattServerClient);
var
  Res: Integer;
  Size: Word;
begin
  Res := Client.GetMaxNotificationSize(Size);
  if Res = WCL_E_SUCCESS then begin
    lbLog.Items.Add(IntToHex(Client.Address, 12) +
      ' notification size changed: ' + IntToStr(Size));
  end else begin
    lbLog.Items.Add(IntToHex(Client.Address, 12) +
      ' get max notification size failed: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.wclGattServerMaxPduSizeChanged(Sender: TObject;
  const Client: TwclGattServerClient);
var
  Res: Integer;
  Size: Word;
begin
  Res := Client.GetMaxPduSize(Size);
  if Res = WCL_E_SUCCESS then begin
    lbLog.Items.Add(IntToHex(Client.Address, 12) +
      ' PDU size changed: ' + IntToStr(Size));
  end else begin
    lbLog.Items.Add(IntToHex(Client.Address, 12) +
      ' get max PDU size failed: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.GetConParams(const Client: TwclGattServerClient);
var
  Res: Integer;
  Params: TwclBluetoothLeConnectionParameters;
begin
  Res := Client.GetConnectionParams(Params);
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Get connection params failed: 0x' + IntToHex(Res, 8))

  else begin
    lbLog.Items.Add('Connection params [' + IntToHex(Client.Address, 12) + ']');
    lbLog.Items.Add('  Interval     : ' + IntToStr(Params.Interval));
    lbLog.Items.Add('  Latency      : ' + IntToStr(Params.Latency));
    lbLog.Items.Add('  Link Timeout : ' + IntToStr(Params.LinkTimeout));
  end;
end;

procedure TfmMain.GetConPhy(const Client: TwclGattServerClient);
var
  Res: Integer;
  Phy: TwclBluetoothLeConnectionPhy;
begin
  Res := Client.GetConnectionPhyInfo(Phy);
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Get connection PHY failed: 0x' + IntToHex(Res, 8))

  else begin
    lbLog.Items.Add('Connection PHY [' + IntToHex(Client.Address, 12) + ']');
    lbLog.Items.Add('  Receive');
    lbLog.Items.Add('    IsCoded        : ' + BoolToStr(Phy.Receive.IsCoded));
    lbLog.Items.Add('    IsUncoded1MPhy : ' + BoolToStr(Phy.Receive.IsUncoded1MPhy));
    lbLog.Items.Add('    IsUncoded2MPhy : ' + BoolToStr(Phy.Receive.IsUncoded2MPhy));
    lbLog.Items.Add('  Transmit');
    lbLog.Items.Add('    IsCoded        : ' + BoolToStr(Phy.Transmit.IsCoded));
    lbLog.Items.Add('    IsUncoded1MPhy : ' + BoolToStr(Phy.Transmit.IsUncoded1MPhy));
    lbLog.Items.Add('    IsUncoded2MPhy : ' + BoolToStr(Phy.Transmit.IsUncoded2MPhy));
  end;
end;

procedure TfmMain.wclGattServerConnectionPhyChanged(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  GetConPhy(Client);
end;

end.
