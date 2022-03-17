unit main;

{$I wcl.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, wclBluetooth;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    lvDevices: TListView;
    btConnect: TButton;
    btDisconnect: TButton;
    lbLog: TListBox;
    btClear: TButton;
    laBattLevelCaption: TLabel;
    laBattLevel: TLabel;
    btGetStatus: TButton;
    cbLed1: TCheckBox;
    cbLed2: TCheckBox;
    cbLed3: TCheckBox;
    cbLed4: TCheckBox;
    btGetLeds: TButton;
    btSetLeds: TButton;
    cbA: TCheckBox;
    laButtons: TLabel;
    cbB: TCheckBox;
    cbPlus: TCheckBox;
    cbHome: TCheckBox;
    cbMinus: TCheckBox;
    cbOne: TCheckBox;
    cbTwo: TCheckBox;
    cbUp: TCheckBox;
    cbDown: TCheckBox;
    cbLeft: TCheckBox;
    cbRight: TCheckBox;
    laAccel: TLabel;
    laXCaption: TLabel;
    laX: TLabel;
    laYCaption: TLabel;
    laY: TLabel;
    laZCaption: TLabel;
    laZ: TLabel;
    btEnableAccel: TButton;
    btDisableAccel: TButton;
    laIrCaption: TLabel;
    laIrModeCpation: TLabel;
    laIrMode: TLabel;
    laIrSensitivityCaption: TLabel;
    laIrSensitivity: TLabel;
    laSensor0Caption: TLabel;
    laSensor0PositionCaption: TLabel;
    laSensor0Position: TLabel;
    laSensor0SizeCaption: TLabel;
    laSensor0Size: TLabel;
    laSensor0FoundCaption: TLabel;
    laSensor0Found: TLabel;
    laSensor1Caption: TLabel;
    laSensor1PositionCaption: TLabel;
    laSensor1Position: TLabel;
    laSensor1SizeCaption: TLabel;
    laSensor1Size: TLabel;
    laSensor1FoundCaption: TLabel;
    laSensor1Found: TLabel;
    laSensor2Caption: TLabel;
    laSensor2PositionCaption: TLabel;
    laSensor2Position: TLabel;
    laSensor2SizeCaption: TLabel;
    laSensor2Size: TLabel;
    laSensor2FoundCaption: TLabel;
    laSensor2Found: TLabel;
    laSensor3Caption: TLabel;
    laSensor3PositionCaption: TLabel;
    laSensor3Position: TLabel;
    laSensor3SizeCpation: TLabel;
    laSensor3Size: TLabel;
    laSensor3FoundCaption: TLabel;
    laSensor3Found: TLabel;
    btEnableIr: TButton;
    btDisableIr: TButton;
    btRumbleOn: TButton;
    btRumbleOff: TButton;
    laNunchukCaption: TLabel;
    laNunchukState: TLabel;
    laNunchukXCaption: TLabel;
    laNunchukX: TLabel;
    laNunchukYCaption: TLabel;
    laNunchukY: TLabel;
    laNunchukZCaption: TLabel;
    laNunchukZ: TLabel;
    laNunchukJoyXCaption: TLabel;
    laNunchukJoyYCaption: TLabel;
    laNunchukJoyX: TLabel;
    laNunchukJoyY: TLabel;
    cbNunchukC: TCheckBox;
    cbNunchukZ: TCheckBox;
    laBalanceBoardCaption: TLabel;
    laBalanceBoardState: TLabel;
    laBbTopRightCaption: TLabel;
    laBbTopLeftCaption: TLabel;
    laBbBottomRightCaption: TLabel;
    laBbBottomLeftCaption: TLabel;
    laBbTopRight: TLabel;
    laBbTopLeft: TLabel;
    laBbBottomRight: TLabel;
    laBbBottomLeft: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btDiscoverClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btGetStatusClick(Sender: TObject);
    procedure btGetLedsClick(Sender: TObject);
    procedure btSetLedsClick(Sender: TObject);
    procedure btEnableAccelClick(Sender: TObject);
    procedure btDisableAccelClick(Sender: TObject);
    procedure btEnableIrClick(Sender: TObject);
    procedure btDisableIrClick(Sender: TObject);
    procedure btRumbleOnClick(Sender: TObject);
    procedure btRumbleOffClick(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclWiiRemoteClient: TwclWiiRemoteClient;

    procedure wclBluetoothManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);
    procedure wclBluetoothManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);
    procedure wclBluetoothManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);

    procedure wclWiiRemoteClientConnect(Sender: TObject;
      const Error: Integer);
    procedure wclWiiRemoteClientDisconnect(Sender: TObject;
      const Reason: Integer);
    procedure wclWiiRemoteClientStatusChanged(Sender: TObject;
      const Batt: Double; const Leds: TwclWiiRemoteLeds);
    procedure wclWiiRemoteClientButtonsChanged(Sender: TObject;
      const Buttons: TwclWiiRemoteButtons);
    procedure wclWiiRemoteClientAccelChanged(Sender: TObject;
      const Accel: TwclWiiRemoteAccel);
    procedure wclWiiRemoteClientIrChanged(Sender: TObject;
      const Ir: TwclWiiRemoteIrSensors);
    procedure wclWiiRemoteClientExtensionAttached(Sender: TObject);
    procedure wclWiiRemoteClientExtensionDetached(Sender: TObject);
    procedure wclWiiRemoteClientNunchukChanged(Sender: TObject;
      const Nunchuk: TwclWiiRemoteNunchuk);
    procedure wclWiiRemoteClientBalanceBoardChanged(Sender: TObject;
      const Board: TwclWiiRemoteBalanceBoard);

    function GetRadio: TwclBluetoothRadio;

    procedure Trace(const Msg: string); overload;
    procedure Trace(const Msg: string; const Res: Integer); overload;

    procedure SetLeds;

    procedure ClearAccel;
    procedure ClearIr;
    procedure ClearNunchuk;
    procedure ClearExtensions;
    procedure ClearBalanceBoard;
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, wclConnections;

{$R *.lfm}

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := wclBluetoothManager.GetClassicRadio(Radio);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Get working radio failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
    Result := nil;
  end else
    Result := Radio;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);
  wclBluetoothManager.OnDeviceFound := wclBluetoothManagerDeviceFound;
  wclBluetoothManager.OnDiscoveringCompleted := wclBluetoothManagerDiscoveringCompleted;
  wclBluetoothManager.OnDiscoveringStarted := wclBluetoothManagerDiscoveringStarted;

  wclWiiRemoteClient := TwclWiiRemoteClient.Create(nil);
  wclWiiRemoteClient.OnAccelChanged := wclWiiRemoteClientAccelChanged;
  wclWiiRemoteClient.OnBalanceBoardChanged := wclWiiRemoteClientBalanceBoardChanged;
  wclWiiRemoteClient.OnButtonsChanged := wclWiiRemoteClientButtonsChanged;
  wclWiiRemoteClient.OnConnect := wclWiiRemoteClientConnect;
  wclWiiRemoteClient.OnDisconnect := wclWiiRemoteClientDisconnect;
  wclWiiRemoteClient.OnExtensionAttached := wclWiiRemoteClientExtensionAttached;
  wclWiiRemoteClient.OnExtensionDetached := wclWiiRemoteClientExtensionDetached;
  wclWiiRemoteClient.OnIrChanged := wclWiiRemoteClientIrChanged;
  wclWiiRemoteClient.OnNunchukChanged := wclWiiRemoteClientNunchukChanged;
  wclWiiRemoteClient.OnStatusChanged := wclWiiRemoteClientStatusChanged;

  wclBluetoothManager.Open;
  ClearAccel;
  ClearIr;
  ClearExtensions;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclWiiRemoteClient.Disconnect;
  wclWiiRemoteClient.Free;

  wclBluetoothManager.Close;
  wclBluetoothManager.Free;
end;

procedure TfmMain.wclBluetoothManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  lvDevices.Items.Clear;
  Trace('Discovering started');
end;

procedure TfmMain.wclBluetoothManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
var
  Item: TListItem;
begin
  Item := lvDevices.Items.Add;
  Item.Caption := IntToHex(Address, 12);
  Item.SubItems.Add('');
end;

procedure TfmMain.wclBluetoothManagerDiscoveringCompleted(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Error: Integer);
var
  i: Integer;
  Item: TListItem;
  Addr: Int64;
  Res: Integer;
  Name: string;
begin
  for i := 0 to lvDevices.Items.Count - 1 do begin
    Item := lvDevices.Items[i];
    Addr := StrToInt64('$' + Item.Caption);

    Res := Radio.GetRemoteName(Addr, Name);
    if Res <> WCL_E_SUCCESS then
      Name := 'Error: 0x' + IntToHex(Res, 8);
    Item.SubItems[0] := Name;
  end;

  Trace('Discovering completed with result', Error);
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    Res := Radio.Discover(10, dkClassic);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Discover failed; 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  if wclWiiRemoteClient.State <> csDisconnected then
    ShowMessage('Wii Remote is connected')

  else begin
    Radio := GetRadio;
    if Radio <> nil then begin
      if lvDevices.Selected = nil then
        ShowMessage('Select device')

      else begin
        wclWiiRemoteClient.Address := StrToInt64('$' + lvDevices.Selected.Caption);
        Res := wclWiiRemoteClient.Connect(Radio);
        if Res <> WCL_E_SUCCESS then
          ShowMessage('Unable connect: 0x' + IntToHex(Res, 8));
      end;
    end;
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Unable disconnect: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclWiiRemoteClientConnect(Sender: TObject;
  const Error: Integer);
begin
  if Error <> WCL_E_SUCCESS then
    Trace('Connection failed', Error)
  else begin
    Trace('Connected');
    SetLeds;
  end;
end;

procedure TfmMain.wclWiiRemoteClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  Trace('Disconnected. Reason', Reason);

  laBattLevel.Caption := '0.00';
  cbLed1.Checked := False;
  cbLed2.Checked := False;
  cbLed3.Checked := False;
  cbLed4.Checked := False;

  cbA.Checked := False;
  cbB.Checked := False;
  cbPlus.Checked := False;
  cbHome.Checked := False;
  cbMinus.Checked := False;
  cbOne.Checked := False;
  cbTwo.Checked := False;
  cbUp.Checked := False;
  cbDown.Checked := False;
  cbLeft.Checked := False;
  cbRight.Checked := False;

  ClearAccel;
  ClearIr;
  ClearExtensions;
end;

procedure TfmMain.wclWiiRemoteClientStatusChanged(Sender: TObject;
  const Batt: Double; const Leds: TwclWiiRemoteLeds);
begin
  Trace('Status changed');

  laBattLevel.Caption := FormatFloat('0.00', Batt);

  cbLed1.Checked := Leds.Led1;
  cbLed2.Checked := Leds.Led2;
  cbLed3.Checked := Leds.Led3;
  cbLed4.Checked := Leds.Led4;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.Trace(const Msg: string);
begin
  lbLog.Items.Add(Msg);
end;

procedure TfmMain.Trace(const Msg: string; const Res: Integer);
begin
  Trace(Msg + ': 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btGetStatusClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.GetStatus;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Get status failed; 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btGetLedsClick(Sender: TObject);
begin
  if wclWiiRemoteClient.State <> csConnected then
    ShowMessage('Not connected')
  else begin
    cbLed1.Checked := wclWiiRemoteClient.Leds.Led1;
    cbLed2.Checked := wclWiiRemoteClient.Leds.Led2;
    cbLed3.Checked := wclWiiRemoteClient.Leds.Led3;
    cbLed4.Checked := wclWiiRemoteClient.Leds.Led4;
  end;
end;

procedure TfmMain.btSetLedsClick(Sender: TObject);
begin
  SetLeds;
end;

procedure TfmMain.SetLeds;
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.SetLeds(cbLed1.Checked, cbLed2.Checked,
    cbLed3.Checked, cbLed4.Checked);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Set LEDs failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclWiiRemoteClientButtonsChanged(Sender: TObject;
  const Buttons: TwclWiiRemoteButtons);
begin
  cbA.Checked := Buttons.A;
  cbB.Checked := Buttons.B;
  cbPlus.Checked := Buttons.Plus;
  cbHome.Checked := Buttons.Home;
  cbMinus.Checked := Buttons.Minus;
  cbOne.Checked := Buttons.One;
  cbTwo.Checked := Buttons.Two;
  cbUp.Checked := Buttons.Up;
  cbDown.Checked := Buttons.Down;
  cbLeft.Checked := Buttons.Left;
  cbRight.Checked := Buttons.Right;
end;

procedure TfmMain.wclWiiRemoteClientAccelChanged(Sender: TObject;
  const Accel: TwclWiiRemoteAccel);
begin
  laX.Caption := IntToStr(Accel.Values.X);
  laY.Caption := IntToStr(Accel.Values.Y);
  laZ.Caption := IntToStr(Accel.Values.Z);
end;

procedure TfmMain.btEnableAccelClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.EnableAccel;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Enable accelerometer failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btDisableAccelClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.DisableAccel;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Disable accelerometer failed: 0x' + IntToHex(Res, 8))
  else
    ClearAccel;
end;

procedure TfmMain.wclWiiRemoteClientIrChanged(Sender: TObject;
  const Ir: TwclWiiRemoteIrSensors);
begin
  case Ir.Mode of
    wiiIrOff:
      ClearIr;
    wiiIrBasicMode:
      laIrMode.Caption := 'Basic';
    wiiIrExtendedMode:
      laIrMode.Caption := 'Extended';
    wiiIrFullMode:
      laIrMode.Caption := 'Full';
    else
      laIrMode.Caption := 'Unknown';
  end;

  if Ir.Mode <> wiiIrOff then begin
    case Ir.Sensitivity of
      wiiIrLevelOff:
        laIrSensitivity.Caption := 'Off';
      wiiIrLevel1:
        laIrSensitivity.Caption := 'Level 1';
      wiiIrLevel2:
        laIrSensitivity.Caption := 'Level 2';
      wiiIrLevel3:
        laIrSensitivity.Caption := 'Level 3';
      wiiIrLevel4:
        laIrSensitivity.Caption := 'Level 4';
      wiiIrLevel5:
        laIrSensitivity.Caption := 'Level 5';
      wiiIrLevelMax:
        laIrSensitivity.Caption := 'Maximum';
      else
        laIrSensitivity.Caption := 'Unknown';
    end;

    if Ir.Sensors[0].Found then begin
      laSensor0Position.Caption := IntToStr(Ir.Sensors[0].Position.X) + '; ' +
        IntToStr(Ir.Sensors[0].Position.Y);
      laSensor0Size.Caption := IntToStr(Ir.Sensors[0].Size);
      laSensor0Found.Caption := 'True';
    end else begin
      laSensor0Position.Caption := '0; 0';
      laSensor0Size.Caption := '0';
      laSensor0Found.Caption := 'False';
    end;

    if Ir.Sensors[1].Found then begin
      laSensor1Position.Caption := IntToStr(Ir.Sensors[1].Position.X) + '; ' +
        IntToStr(Ir.Sensors[1].Position.Y);
      laSensor1Size.Caption := IntToStr(Ir.Sensors[1].Size);
      laSensor1Found.Caption := 'True';
    end else begin
      laSensor1Position.Caption := '0; 0';
      laSensor1Size.Caption := '0';
      laSensor1Found.Caption := 'False';
    end;

    if Ir.Sensors[2].Found then begin
      laSensor2Position.Caption := IntToStr(Ir.Sensors[2].Position.X) + '; ' +
        IntToStr(Ir.Sensors[2].Position.Y);
      laSensor2Size.Caption := IntToStr(Ir.Sensors[2].Size);
      laSensor2Found.Caption := 'True';
    end else begin
      laSensor2Position.Caption := '0; 0';
      laSensor2Size.Caption := '0';
      laSensor2Found.Caption := 'False';
    end;

    if Ir.Sensors[3].Found then begin
      laSensor3Position.Caption := IntToStr(Ir.Sensors[3].Position.X) + '; ' +
        IntToStr(Ir.Sensors[3].Position.Y);
      laSensor3Size.Caption := IntToStr(Ir.Sensors[3].Size);
      laSensor3Found.Caption := 'True';
    end else begin
      laSensor3Position.Caption := '0; 0';
      laSensor3Size.Caption := '0';
      laSensor3Found.Caption := 'False';
    end;
  end;
end;

procedure TfmMain.ClearAccel;
begin
  laX.Caption := '0';
  laY.Caption := '0';
  laZ.Caption := '0';
end;

procedure TfmMain.ClearIr;
begin
  laIrMode.Caption := 'Off';
  laIrSensitivity.Caption := 'Off';

  laSensor0Position.Caption := '0; 0';
  laSensor0Size.Caption := '0';
  laSensor0Found.Caption := 'False';

  laSensor1Position.Caption := '0; 0';
  laSensor1Size.Caption := '0';
  laSensor1Found.Caption := 'False';

  laSensor2Position.Caption := '0; 0';
  laSensor2Size.Caption := '0';
  laSensor2Found.Caption := 'False';

  laSensor3Position.Caption := '0; 0';
  laSensor3Size.Caption := '0';
  laSensor3Found.Caption := 'False';
end;

procedure TfmMain.btEnableIrClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.SetIrSensitivity(wiiIrLevelMax);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Enable IR failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btDisableIrClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.SetIrSensitivity(wiiIrLevelOff);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Disable IR failed: 0x' + IntToHex(Res, 8))
  else
    ClearIr;
end;

procedure TfmMain.btRumbleOnClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.SetRumble(True);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Set Rumble ON failed; 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btRumbleOffClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclWiiRemoteClient.SetRumble(False);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Set Rumble OFF failed; 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclWiiRemoteClientExtensionAttached(Sender: TObject);
var
  Ext: string;
begin
  case wclWiiRemoteClient.Extension of
    wiiNoExtension:
      Ext := 'wiiNoExtension';
    wiiNunchuk:
      begin
        Ext := 'wiiNunchuk';
        laNunchukState.Caption := 'Attached';
      end;
    wiiClassicController:
      Ext := 'wiiClassicController';
    wiiGuitar:
      Ext := 'wiiGuitar';
    wiiDrums:
      Ext := 'wiiDrums';
    wiiBalanceBoard:
      begin
        Ext := 'wiiBalanceBoard';
        laBalanceBoardState.Caption := 'Attached';
      end;
    else
      Ext := 'Unknonw';
  end;

  Trace('Extension attached: ' + Ext);
end;

procedure TfmMain.wclWiiRemoteClientExtensionDetached(Sender: TObject);
begin
  Trace('Extension detached');
  ClearExtensions;
end;

procedure TfmMain.wclWiiRemoteClientNunchukChanged(Sender: TObject;
  const Nunchuk: TwclWiiRemoteNunchuk);
begin
  laNunchukX.Caption := IntToStr(Nunchuk.Accel.Values.X);
  laNunchukY.Caption := IntToStr(Nunchuk.Accel.Values.Y);
  laNunchukZ.Caption := IntToStr(Nunchuk.Accel.Values.Z);

  laNunchukJoyX.Caption := IntToStr(Nunchuk.Joystick.X);
  laNunchukJoyY.Caption := IntToStr(Nunchuk.Joystick.Y);

  cbNunchukC.Checked := Nunchuk.C;
  cbNunchukZ.Checked := Nunchuk.Z;
end;

procedure TfmMain.ClearNunchuk;
begin
  laNunchukState.Caption := 'Detached';

  laNunchukX.Caption := '0';
  laNunchukY.Caption := '0';
  laNunchukZ.Caption := '0';

  laNunchukJoyX.Caption := '0';
  laNunchukJoyY.Caption := '0';

  cbNunchukC.Checked := False;
  cbNunchukZ.Checked := False;
end;

procedure TfmMain.ClearExtensions;
begin
  ClearNunchuk;
  ClearBalanceBoard;
end;

procedure TfmMain.ClearBalanceBoard;
begin
  laBalanceBoardState.Caption := 'Detached';

  laBbTopRight.Caption := '0';
  laBbTopLeft.Caption := '0';
  laBbBottomRight.Caption := '0';
  laBbBottomLeft.Caption := '0';
end;

procedure TfmMain.wclWiiRemoteClientBalanceBoardChanged(Sender: TObject;
  const Board: TwclWiiRemoteBalanceBoard);
begin
  laBbTopRight.Caption := FormatFloat('0.00', Board.SensorsKg.TopRight);
  laBbTopLeft.Caption := FormatFloat('0.00', Board.SensorsKg.TopLeft);
  laBbBottomRight.Caption := FormatFloat('0.00', Board.SensorsKg.BottomRight);
  laBbBottomLeft.Caption := FormatFloat('0.00', Board.SensorsKg.BottomLeft);
end;

end.
