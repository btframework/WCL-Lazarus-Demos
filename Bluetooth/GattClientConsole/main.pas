unit main;

{$MODE Delphi}
{$WARN 5024 off : Parameter "$1" not used}
interface

uses
  wclBluetooth;

type
  TGattClientApplication = class
  private
    FClient: TwclGattClient;
    FManager: TwclBluetoothManager;
    FRadio: TwclBluetoothRadio;

    FDisconnectEvent: THandle;
    FOperationEvent: THandle;

    FIndex: Cardinal;
    FDevices: TwclBluetoothAddresses;

    procedure Pause;

    (* Bluetooth Manager event handlers. *)

    procedure BluetoothManagerAfterOpen(Sender: TObject);
    procedure BluetoothManagerBeforeClose(Sender: TObject);
    procedure BluetoothManagerClosed(Sender: TObject);
    procedure BluetoothManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);
    procedure BluetoothManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);
    procedure BluetoothManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);

    (* Device helper methods. *)

    procedure DumpValue(const Value: TwclGattCharacteristicValue);
    procedure GetMaxPduSize;
    procedure GetConnectionParams;
    procedure GetConnectionPhy;
    function UuidToString(const Uuid: TwclGattUuid): string;

    (* GATT client event handlers. *)

    procedure ClientCharacteristicChanged(Sender: TObject; const Handle: Word;
      const Value: TwclGattCharacteristicValue);
    procedure ClientDisconnect(Sender: TObject; const Reason: Integer);
    procedure ClientConnect(Sender: TObject; const Error: Integer);
    procedure ClientMaxPduSizeChanged(Sender: TObject);
    procedure ClientConnectionParamsChanged(Sender: TObject);
    procedure ClientConnectionPhyChanged(Sender: TObject);

    (* Bluetooth Framework initialization & finalization. *)

    function InitializeBluetoothFramework: Boolean;
    procedure FinalizeBluetoothFramework;

    (* Communication functions. *)

    procedure DumpCharacteristicProperties(
      const Characteristic: TwclGattCharacteristic);
    procedure DumpCharacteristicValue(
      const Characteristic: TwclGattCharacteristic);
    procedure SubscribeToCharacteristic(Characteristic: TwclGattCharacteristic);
    procedure ReadCharacteristics(const Service: TwclGattService);
    procedure ReadServices;

    (* Application functions. *)

    procedure ShowFoundDevices;
    function ConnectToDevice(const Address: Int64): Boolean;
    procedure SearchDevices;

    procedure RunApplicationLoop;

  public
    (* Constructor & destructor. *)

    constructor Create;
    destructor Destroy; override;

    (* Control methods. *)

    procedure Run;
  end;

implementation

uses
  SysUtils, Windows, wclErrors, wclConnections, wclMessaging;

{ TGattClientApplication }

procedure TGattClientApplication.BluetoothManagerAfterOpen(Sender: TObject);
begin
  Writeln('Bluetooth Manager opened');
end;

procedure TGattClientApplication.BluetoothManagerBeforeClose(Sender: TObject);
begin
  Writeln('Bluetooth Manager is closing');
end;

procedure TGattClientApplication.BluetoothManagerClosed(Sender: TObject);
begin
  Writeln('Bluetooth Manager closed');
end;

procedure TGattClientApplication.BluetoothManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
var
  Name: string;
  Res: Integer;
  Len: Integer;
begin
  Res := Radio.GetRemoteName(Address, Name);
  if Res <> WCL_E_SUCCESS then
    Name := '<UNKNOWN>';

  Inc(FIndex);
  Write('[' + IntToStr(FIndex) + ']: ' + IntToHex(Address, 12));
  Writeln(' (' + Name + ')');

  Len := Length(FDevices);
  SetLength(FDevices, Len + 1);
  FDevices[Len] := Address;
end;

procedure TGattClientApplication.BluetoothManagerDiscoveringCompleted(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Error: Integer);
begin
  Writeln('Discovering completed with result: 0x' + IntToHex(Error, 8));
  SetEvent(FOperationEvent);
end;

procedure TGattClientApplication.BluetoothManagerDiscoveringStarted(
  Sender: TObject; const Radio: TwclBluetoothRadio);
begin
  FIndex := 0;
  ResetEvent(FOperationEvent);

  Writeln('Discovering started');
  FDevices := nil;
end;

procedure TGattClientApplication.ClientCharacteristicChanged(Sender: TObject;
  const Handle: Word; const Value: TwclGattCharacteristicValue);
begin
  Writeln('Characteristic [' + IntToHex(Handle, 4) + '] value changed');
  DumpValue(Value);
end;

procedure TGattClientApplication.ClientConnect(Sender: TObject;
  const Error: Integer);
begin
  if Error <> WCL_E_SUCCESS then
    Writeln('Connection failed: 0x' + IntToHex(Error, 8))

  else begin
    Writeln('Client connected');
    GetMaxPduSize;
    GetConnectionParams;
    GetConnectionPhy;
  end;

  SetEvent(FOperationEvent);
end;

procedure TGattClientApplication.ClientConnectionParamsChanged(Sender: TObject);
begin
  Writeln('Connection parameters changed');
  GetConnectionParams;
end;

procedure TGattClientApplication.ClientConnectionPhyChanged(Sender: TObject);
begin
  Writeln('Connection PHY changed');
  GetConnectionPhy;
end;

procedure TGattClientApplication.ClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  Writeln('Client disconnected with reason: 0x' + IntToHex(Reason, 8));
  SetEvent(FDisconnectEvent);
end;

procedure TGattClientApplication.ClientMaxPduSizeChanged(Sender: TObject);
begin
  Writeln('Max PDU size changed');
  GetMaxPduSize;
end;

function TGattClientApplication.ConnectToDevice(const Address: Int64): Boolean;
var
  Res: Integer;
begin
  Writeln('Try to connect to device: ' + IntToHex(Address, 12));

  ResetEvent(FDisconnectEvent);
  ResetEvent(FOperationEvent);

  FClient.Address := Address;
  Res := FClient.Connect(FRadio);
  if Res <> WCL_E_SUCCESS then begin
    Writeln('Start connection failed: 0x' + IntToHex(Res, 8));
    Pause;
    Result := False;

  end else begin
    Writeln('Connection started');
    WaitForSingleObject(FOperationEvent, INFINITE);
    if FClient.State = csConnected then begin
      ReadServices;

      Pause;

      FClient.Disconnect;
      WaitForSingleObject(FDisconnectEvent, INFINITE);
      Writeln('Client disconnected');

      Result := True;

    end else begin
      Pause;
      Result := False;
    end;
  end;
end;

constructor TGattClientApplication.Create;
begin
  TwclMessageBroadcaster.SetMessageProcessingMethod(mpAsync);

  FClient := TwclGattClient.Create(nil);
  FClient.OnCharacteristicChanged := ClientCharacteristicChanged;
  FClient.OnConnect := ClientConnect;
  FClient.OnConnectionParamsChanged := ClientConnectionParamsChanged;
  FClient.OnConnectionPhyChanged := ClientConnectionPhyChanged;
  FClient.OnDisconnect := ClientDisconnect;
  FClient.OnMaxPduSizeChanged := ClientMaxPduSizeChanged;

  FManager := TwclBluetoothManager.Create(nil);
  FManager.AfterOpen := BluetoothManagerAfterOpen;
  FManager.BeforeClose := BluetoothManagerBeforeClose;
  FManager.OnClosed := BluetoothManagerClosed;
  FManager.OnDiscoveringCompleted := BluetoothManagerDiscoveringCompleted;
  FManager.OnDeviceFound := BluetoothManagerDeviceFound;
  FManager.OnDiscoveringStarted := BluetoothManagerDiscoveringStarted;

  FRadio := nil;

  FDevices := nil;

  FDisconnectEvent := 0;
  FOperationEvent := 0;
end;

destructor TGattClientApplication.Destroy;
begin
  FClient.Free;
  FManager.Free;

  inherited;
end;

procedure TGattClientApplication.DumpCharacteristicProperties(
  const Characteristic: TwclGattCharacteristic);
begin
  Write('    Properties: ');
  if Characteristic.IsBroadcastable then
    Write('Broadcastable ');
  if Characteristic.IsReadable then
    Write('Readable ');
  if Characteristic.IsWritable then
    Write('Writable ');
  if Characteristic.IsWritableWithoutResponse then
    Write('WritableWithoutResponse ');
  if Characteristic.IsSignedWritable then
    Write('SignedWritable ');
  if Characteristic.IsNotifiable then
    Write('Notifiable ');
  if Characteristic.IsIndicatable then
    Write('Indicatable ');
  Writeln;
end;

procedure TGattClientApplication.DumpCharacteristicValue(
  const Characteristic: TwclGattCharacteristic);
var
  Value: TwclGattCharacteristicValue;
  Res: Integer;
begin
  if Characteristic.IsReadable then begin
    Writeln('    Read characteristic value');
    Res := FClient.ReadCharacteristicValue(Characteristic, goNone, Value);
    if Res <> WCL_E_SUCCESS then
      Writeln('    Read value failed: 0x' + IntToHex(Res, 8))
    else
      DumpValue(Value);
  end;
end;

procedure TGattClientApplication.DumpValue(
  const Value: TwclGattCharacteristicValue);
var
  s: string;
  i: Integer;
begin
  if Length(Value) > 0 then begin
    s := '';
    for i := 0 to Length(Value) - 1 do
      s := s + IntToHex(Value[i], 2);
    Writeln('Value: ' + s);
  end;
end;

procedure TGattClientApplication.FinalizeBluetoothFramework;
var
  Res: Integer;
begin
  Writeln('Closing Bluetooth Manager');
  Res := FManager.Close;
  if Res <> WCL_E_SUCCESS then
    Writeln('Close Bluetooth Manager failed: 0x' + IntToHex(Res, 8));

  FRadio := nil;
end;

procedure TGattClientApplication.GetConnectionParams;
var
  Params: TwclBluetoothLeConnectionParameters;
  Res: Integer;
begin
  Res := FClient.GetConnectionParams(Params);
  if Res <> WCL_E_SUCCESS then
    Writeln('Get connection params error: 0x' + IntToHex(Res, 8))

  else begin
    Writeln('Connection params: ');
    Writeln('  Interval     : ' + IntToStr(Params.Interval));
    Writeln('  Latency      : ' + IntToStr(Params.Latency));
    Writeln('  Link Timeout : ' + IntToStr(Params.LinkTimeout));
  end;
end;

procedure TGattClientApplication.GetConnectionPhy;
var
  Phy: TwclBluetoothLeConnectionPhy;
  Res: Integer;
begin
  Res := FClient.GetConnectionPhyInfo(Phy);
  if Res <> WCL_E_SUCCESS then
    Writeln('Get connection PHY error: 0x' + IntToHex(Res, 8))

  else begin
    Writeln('Connection PHY: ');
    Writeln('  Receive');
    Writeln('    IsCoded        : ' + BoolToStr(Phy.Receive.IsCoded, True));
    Writeln('    IsUncoded1MPhy : ' + BoolToStr(Phy.Receive.IsUncoded1MPhy));
    Writeln('    IsUncoded2MPhy : ' + BoolToStr(Phy.Receive.IsUncoded2MPhy));
    Writeln('  Transmit');
    Writeln('    IsCoded        : ' + BoolToStr(Phy.Transmit.IsCoded));
    Writeln('    IsUncoded1MPhy : ' + BoolToStr(Phy.Transmit.IsUncoded1MPhy));
    Writeln('    IsUncoded2MPhy : ' + BoolToStr(Phy.Transmit.IsUncoded2MPhy));
  end;
end;

procedure TGattClientApplication.GetMaxPduSize;
var
  Size: Word;
  Res: Integer;
begin
  Res := FClient.GetMaxPduSize(Size);
  if Res <> WCL_E_SUCCESS then
    Writeln('Get max PDU size error: 0x' + IntToHex(Res, 8))
  else
    Writeln('Max PDU size: ' + IntToStr(Size));
end;

function TGattClientApplication.InitializeBluetoothFramework: Boolean;
var
  Res: Integer;
begin
  Writeln('Opening Bluetooth Manager');
  Res := FManager.Open;
  if Res <> WCL_E_SUCCESS then begin
    Writeln('Initialize Bluetooth Manager failed: 0x' + IntToHex(Res, 8));
    Result := False;

  end else begin
    Writeln('Try to get working Bluetooth LE radio');
    Res := FManager.GetLeRadio(FRadio);
    if Res <> WCL_E_SUCCESS then begin
      Writeln('Get working Bluetooth LE radio failed: 0x' + IntToHex(Res, 8));
      FManager.Close;
      Result := False;

    end else begin
      Writeln('Use ' + FRadio.ApiName + ' Bluetooth radio');
      Result := True;
    end;
  end;
end;

procedure TGattClientApplication.Pause;
begin
  Writeln('Press ENTER to continue');
  Readln;
end;

procedure TGattClientApplication.ReadCharacteristics(
  const Service: TwclGattService);
var
  Characteristics: TwclGattCharacteristics;
  Res: Integer;
  i: Integer;
begin
  Writeln('  Read characteristics');

  Res := FClient.ReadCharacteristics(Service, goNone, Characteristics);
  if Res <> WCL_E_SUCCESS then
    Writeln('  Read characteristics failed: 0x' + IntToHex(Res, 8))

  else begin
    if Length(Characteristics) = 0 then
      Writeln('  No characteristics found')

    else begin
      for i := 0 to Length(Characteristics) - 1 do begin
        Write('  Characteristic [' + IntToStr(i) + '] ');
        Write(IntToHex(Characteristics[i].Handle, 4));
        WriteLn(' ' + UuidToString(Characteristics[i].Uuid));
        DumpCharacteristicProperties(Characteristics[i]);
        DumpCharacteristicValue(Characteristics[i]);
        SubscribeToCharacteristic(Characteristics[i]);
      end;
    end;
  end;
end;

procedure TGattClientApplication.ReadServices;
var
  Services: TwclGattServices;
  Res: Integer;
  i: Integer;
begin
  Writeln('Read services');

  Res := FClient.ReadServices(goNone, Services);
  if Res <> WCL_E_SUCCESS then
    Writeln('Read services failed: 0x' + IntToHex(Res, 8))

  else begin
    if Length(Services) = 0 then
      Writeln('No services found')

    else begin
      for i := 0 to Length(Services) - 1 do begin
        Write('Service [' + IntToStr(i + 1) + '] ');
        Write(' (' + IntToHex(Services[i].Handle, 4) + ') ');
        Writeln(UuidToString(Services[i].Uuid));

        ReadCharacteristics(Services[i]);
      end;
    end;
  end;
end;

procedure TGattClientApplication.Run;
begin
  Write('This demo shows how to use wclGATTClient in console/service applications with ');
  Writeln('Asyncrhonous message processing.');
  Writeln;

  if InitializeBluetoothFramework then begin
    FOperationEvent := CreateEvent(nil, True, False, nil);
    if FOperationEvent <> 0 then begin
      FDisconnectEvent := CreateEvent(nil, True, False, nil);
      if FDisconnectEvent <> 0 then begin
        RunApplicationLoop;

        CloseHandle(FDisconnectEvent);

      end else
        Writeln('Create disconnect event failed');

      CloseHandle(FOperationEvent);

    end else
      Writeln('Create operation event failed');

    FinalizeBluetoothFramework;
  end;
end;

procedure TGattClientApplication.RunApplicationLoop;
var
  Terminate: Boolean;
  Opt: Integer;
begin
  Terminate := False;
  while not Terminate do begin
    Writeln;
    Writeln;
    Writeln('Select option:');
    Writeln('    1 - Search for GATT enabled devices');
    Writeln('    0 - Exit');

    Readln(Opt);
    case Opt of
      0: Terminate := True;
      1: SearchDevices;
      else Writeln('Invalid option selected. Try again');
    end;
  end;
end;

procedure TGattClientApplication.SearchDevices;
var
  Res: Integer;
  Index: Integer;
begin
  Writeln('Start searching for Bluetooth LE devices');
  Res := FRadio.Discover(10, dkBle);
  if Res <> WCL_E_SUCCESS then begin
    Writeln('Start searching devices failed: 0x' + IntToHex(Res, 8));
    Pause;

  end else begin
    WaitForSingleObject(FOperationEvent, INFINITE);

    if Length(FDevices) = 0 then begin
      Writeln;
      Writeln('No Bluetooth LE devices found');
      Pause;

    end else begin
      while True do begin
        Writeln;
        Writeln('Enter device index or 0 to exit: ');

        Readln(Index);

        if Index = 0 then
          Exit;

        Dec(Index);

        if Index >= Length(FDevices) then begin
          Writeln('Invalid device index');
          Continue;
        end;

        if ConnectToDevice(FDevices[Index]) then
          Exit;

        ShowFoundDevices();
      end;
    end;
  end;
end;

procedure TGattClientApplication.ShowFoundDevices;
var
  i: Integer;
  Name: string;
  Res: Integer;
begin
  if Length(FDevices) > 0 then begin
    for i := 0 to Length(FDevices) - 1 do begin
      Res := FRadio.GetRemoteName(FDevices[i], Name);
      if Res <> WCL_E_SUCCESS then
        Name := '<UNKNOWN>';

      Write('[' + IntToStr(i + 1) + ']: ' + IntToHex(FDevices[i], 12));
      Writeln(' (' + Name + ')');
    end;
  end;
end;

procedure TGattClientApplication.SubscribeToCharacteristic(
  Characteristic: TwclGattCharacteristic);
var
  Res: Integer;
begin
  if Characteristic.IsIndicatable or Characteristic.IsNotifiable then begin
    Writeln('    Try to subscribe to characteristic');
    if Characteristic.IsIndicatable and Characteristic.IsNotifiable then
      Characteristic.IsIndicatable := False;

    Res := FClient.SubscribeForNotifications(Characteristic);
    if Res <> WCL_E_SUCCESS then
      Writeln('    Subscribe failed: 0x' + IntToHex(Res, 8))
    else
      Writeln('    Subscribed');
  end;
end;

function TGattClientApplication.UuidToString(const Uuid: TwclGattUuid): string;
begin
  if Uuid.IsShortUuid then
    Result := IntToHex(Uuid.ShortUuid, 4)
  else
    Result := GuidToString(Uuid.LongUuid);
end;

end.
