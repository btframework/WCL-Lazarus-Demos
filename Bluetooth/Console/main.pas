unit main;

{$MODE Delphi}

interface

uses
  SysUtils, Windows, wclMessaging, wclErrors, wclBluetooth;

type
  TwclConsole = class
  private
    FEvent: THandle;

    procedure ManagerAfterOpen(Sender: TObject);
    procedure ManagerClosed(Sender: TObject);
    procedure ManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);
    procedure ManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);
    procedure ManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);

  public
    procedure Run;
  end;

implementation

procedure TwclConsole.ManagerAfterOpen(Sender: TObject);
begin
  SetEvent(FEvent);
end;

procedure TwclConsole.ManagerClosed(Sender: TObject);
begin
  SetEvent(FEvent);
end;

procedure TwclConsole.ManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
begin
  WriteLn('Device ' + IntToHex(Address, 12) + ' found');
end;

procedure TwclConsole.ManagerDiscoveringCompleted(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Error: Integer);
begin
  WriteLn('Discoverign has been compledted');
  SetEvent(FEvent);
end;

procedure TwclConsole.ManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  WriteLn('Discovering has been started');
end;

procedure TwclConsole.Run;
var
  Manager: TwclBluetoothManager;
  Res: Integer;
  Radio: TwclBluetoothRadio;
  i: Integer;
begin
  WriteLn('Bluetooth Framework Console Demo application');
  WriteLn('  The demo is very simple: it just discovers nearby classic and LE');
  WriteLn('  devices.');
  WriteLn('  The demo shows how to use Bluetooth Framework in console');
  WriteLn('  applications with Asynchronous messages processing.');
  WriteLn('Press ENTER to continue');
  ReadLn;

  // Create classes we have to use.
  Manager := TwclBluetoothManager.Create(nil);
  Manager.MessageProcessing := mpAsync;
  Manager.AfterOpen := ManagerAfterOpen;
  Manager.OnClosed := ManagerClosed;
  Manager.OnDeviceFound := ManagerDeviceFound;
  Manager.OnDiscoveringCompleted := ManagerDiscoveringCompleted;
  Manager.OnDiscoveringStarted := ManagerDiscoveringStarted;

  // The event used to notify about event completion.
  FEvent := CreateEvent(nil, False, False, nil);
  if FEvent = 0 then
    WriteLn('Unable to create synchronization event!')

  else begin
  // Open Bluetooth Manager
    Res := Manager.Open;
    if Res <> WCL_E_SUCCESS then
      WriteLn('Open Bluetooth Manager failed: 0x' + IntToHex(Res, 8))

    else begin
      // Wait for Open completion.
      WaitForSingleObject(FEvent, INFINITE);

      // Try to find available Bluetooth Radio. Use first one found.
      if Manager.Count = 0 then
        WriteLn('No Bluetooth Hardware connected.')

      else begin
        Radio := nil;
        for i := 0 to Manager.Count - 1 do begin
          if Manager[i].Available then begin
            Radio := Manager[i];
            Break;
          end;
        end;

        if Radio = nil then
          WriteLn('Available BluetoothRadio not found.')

        else begin
          // Discover classic devices
          WriteLn('Try to start classic discovering');
          Res := Radio.Discover(10, dkClassic);
          if Res <> WCL_E_SUCCESS then
            WriteLn('Start classic discovering failed: 0x' + IntToHex(Res, 8))
          else
            // Wait for discovering completion.
            WaitForSingleObject(FEvent, INFINITE);

          // Discover LE devices
          WriteLn('Try to start LE discovering');
          Res := Radio.Discover(10, dkBle);
          if Res <> WCL_E_SUCCESS then
            WriteLn('Start LE discovering failed: 0x' + IntToHex(Res, 8))
          else
            // Wait for discovering completion.
            WaitForSingleObject(FEvent, INFINITE);
        end;
      end;

      // Close Bluetooth Manager.
      Res := Manager.Close;
      if Res <> WCL_E_SUCCESS then
        WriteLn('Open Bluetooth Manager failed: 0x' + IntToHex(Res, 8))
      else
        // Wait for Close completion.
        WaitForSingleObject(FEvent, INFINITE);
    end;

    // Do not forget about event.
    CloseHandle(FEvent);
  end;

  // Do not forget to destroy Bluetooth Manager.
  Manager.Free;

  WriteLn('Demo finished. Press ENTER');
  ReadLn;
end;

end.
