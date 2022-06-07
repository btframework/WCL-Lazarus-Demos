unit main;

{$I wcl.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, wclBluetooth, wclErrors;

type

  { TfmMain }

  TfmMain = class(TForm)
    btStart: TButton;
    btStop: TButton;
    lbLog: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclGattServer: TwclGattServer;

    FCounter: Cardinal;
    FStarted: Boolean;

    procedure wclBluetoothManagerAfterOpen(Sender: TObject);
    procedure wclBluetoothManagerBeforeClose(Sender: TObject);

    procedure wclGattServerStarted(Sender: TObject);
    procedure wclGattServerStopped(Sender: TObject);
    procedure wclGattServerRead(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic;
      const Value: TwclGattLocalCharacteristicValue);
    procedure wclGattServerWrite(Sender: TObject;
      const Client: TwclGattServerClient;
      const Characteristic: TwclGattLocalCharacteristic;
      const Data: Pointer; const Size: Cardinal);
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

    function InitBluetooth(out Radio: TwclBluetoothRadio): Boolean;
    procedure UninitBluetooth;
    function InitServer(Radio: TwclBluetoothRadio): Boolean;
    procedure UninitServer;
    function AddCharacteristics(Service: TwclGattLocalService): Boolean;
    function AddServices: Boolean;
    procedure Start;
    procedure Stop;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
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

  FStarted := False;
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
  const Value: TwclGattLocalCharacteristicValue);
var
  b: array [0..4] of Byte;
  Res: Integer;
begin
  lbLog.Items.Add('Read request from ' + IntToHex(Client.Address, 12));
  b[0] := 1;
  b[1] := 2;
  b[2] := 3;
  b[3] := 2;
  b[4] := 1;
  Res := Value.SetData(@b, 5);
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Set data failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclGattServerWrite(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic;
  const Data: Pointer; const Size: Cardinal);
var
  s: String;
  i: Cardinal;
begin
  lbLog.Items.Add('Data received from ' + IntToHex(Client.Address, 12) + ' (' +
    IntToStr(Size) + ' bytes): ');
  s := '';
  for i := 0 to Size - 1 do
    s := s + IntToHex(Byte(PAnsiChar(Data)[i]), 2);
  lbLog.Items.Add(s);
end;

procedure TfmMain.wclGattServerUnsubscribed(Sender: TObject;
  const Client: TwclGattServerClient;
  const Characteristic: TwclGattLocalCharacteristic);
begin
  lbLog.Items.Add('Client unsubscribed :' + IntToHex(Client.Address, 12));
end;

procedure TfmMain.wclGattServerClientConnected(Sender: TObject;
  const Client: TwclGattServerClient);
begin
  lbLog.Items.Add('Client connected :' + IntToHex(Client.Address, 12));
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
  Result := False;

  lbLog.Items.Add('Add empty characteristic');
  Uuid.ShortUuid := $FFF1;
  Params.Props := [];
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add empty characteristic: 0x' + IntToHex(Res, 8));
    Result := False;
   Exit;
  end;

  lbLog.Items.Add('Add readable characteristic');
  Uuid.ShortUuid := $FFF2;
  Params.Props := [cpReadable];
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add readable characteristic: 0x' + IntToHex(Res, 8));
    Exit;
  end;

  lbLog.Items.Add('Add writable characteristic');
  Uuid.ShortUuid := $FFF3;
  Params.Props := [cpWritable];
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add writable characteristic: 0x' + IntToHex(Res, 8));
    Exit;
  end;

  lbLog.Items.Add('Add notifiable characteristic');
  Uuid.ShortUuid := $FFF4;
  Params.Props := [cpNotifiable];
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add notifiable characteristic: 0x' + IntToHex(Res, 8));
    Exit;
  end;

  lbLog.Items.Add('Add indicatable characteristic');
  Uuid.ShortUuid := $FFF5;
  Params.Props := [cpIndicatable];
  Res := Service.AddCharacteristic(Uuid, Params, Char);
  if Res <> WCL_E_SUCCESS then begin
    lbLog.Items.Add('Failed to add indicatable characteristic: 0x' + IntToHex(Res, 8));
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

end.
