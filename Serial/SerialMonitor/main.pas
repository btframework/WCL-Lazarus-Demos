unit main;

{$I wcl.inc}

interface

uses
  Forms, StdCtrls, Controls, ComCtrls, Classes, wclSerialDevices,
  wclPowerEvents;

type
  TfmMain = class(TForm)
    btEnum: TButton;
    btStart: TButton;
    btStop: TButton;
    lvDevices: TListView;
    btClear: TButton;
    lbEvents: TListBox;
    procedure btClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btEnumClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    wclSerialMonitor: TwclSerialMonitor;

    FPowerMonitor: TwclPowerEventsMonitor;

    procedure wclSerialMonitorInserted(Sender: TObject;
      const Device: TwclSerialDevice);
    procedure wclSerialMonitorRemoved(Sender: TObject;
      const Device: TwclSerialDevice);

    procedure PowerStateChanged(Sender: TObject; const State: TwclPowerState);
  end;

var
  fmMain: TfmMain;

implementation

uses
  SysUtils, wclErrors;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Items.Clear;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclSerialMonitor.Stop;
  wclSerialMonitor.Free;

  FPowerMonitor.Close;
  FPowerMonitor.Free;
end;

procedure TfmMain.btEnumClick(Sender: TObject);
var
  Res: Integer;
  Devices: TwclSerialDevices;
  Item: TListItem;
  i: Integer;
begin
  lvDevices.Items.Clear;

  Res := wclSerialMonitor.EnumDevices(Devices);
  lbEvents.Items.Add('Enumerate serial devices: 0x' + IntToHex(Res, 8));

  if Res = WCL_E_SUCCESS then
    for i := 0 to Length(Devices) - 1 do begin
      Item := lvDevices.Items.Add;
      Item.Caption := Devices[i].FriendlyName;
      Item.SubItems.Add(BoolToStr(Devices[i].IsModem, True));
      Item.SubItems.Add(Devices[i].DeviceName);
    end;
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclSerialMonitor.Start;
  lbEvents.Items.Add('Monitoring started: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclSerialMonitor.Stop;
  lbEvents.Items.Add('Monitoring stopped: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclSerialMonitorInserted(Sender: TObject;
  const Device: TwclSerialDevice);
begin
  lbEvents.Items.Add('Device inserted:');
  lbEvents.Items.Add('  Friendly name: ' + Device.FriendlyName);
  lbEvents.Items.Add('  Modem: ' + BoolToStr(Device.IsModem, True));
  lbEvents.Items.Add('  DeviceName: ' + Device.DeviceName);
end;

procedure TfmMain.wclSerialMonitorRemoved(Sender: TObject;
  const Device: TwclSerialDevice);
begin
  lbEvents.Items.Add('Device removed:');
  lbEvents.Items.Add('  Friendly name: ' + Device.FriendlyName);
  lbEvents.Items.Add('  Modem: ' + BoolToStr(Device.IsModem, True));
  lbEvents.Items.Add('  DeviceName: ' + Device.DeviceName);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclSerialMonitor := TwclSerialMonitor.Create(nil);
  wclSerialMonitor.OnInserted := wclSerialMonitorInserted;
  wclSerialMonitor.OnRemoved := wclSerialMonitorRemoved;

  FPowerMonitor := TwclPowerEventsMonitor.Create;
  FPowerMonitor.OnPowerStateChanged := PowerStateChanged;
  FPowerMonitor.Open;
end;

procedure TfmMain.PowerStateChanged(Sender: TObject;
  const State: TwclPowerState);
{$J+}
const
  Running: Boolean = False;
{$J-}
begin
  case State of
    psResumeAutomatic:
      begin
        if Running then begin
          Running := False;
          wclSerialMonitor.Start;
        end;
        lbEvents.Items.Add('Power changed: psResumeAutomatic');
      end;

    psResume:
      lbEvents.Items.Add('Power changed: psResume');

    psSuspend:
      begin
        if wclSerialMonitor.Monitoring then begin
          Running := True;
          wclSerialMonitor.Stop;
        end;
        lbEvents.Items.Add('Power changed: psSuspend');
      end;

    psUnknown:
      lbEvents.Items.Add('Power changed: psUnknown');
  end;
end;

end.
