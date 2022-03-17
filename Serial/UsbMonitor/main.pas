unit main;

{$I wcl.inc}

interface

uses
  Forms, Controls, ComCtrls, StdCtrls, Classes, wclSerialDevices;


  { TfmMain }

  type
  TfmMain = class(TForm)
    btEnum: TButton;
    lvDevices: TListView;
    btStart: TButton;
    btStop: TButton;
    lbEvents: TListBox;
    btClear: TButton;
    btEnable: TButton;
    btDisable: TButton;
    procedure btEnumClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btEnableClick(Sender: TObject);
    procedure btDisableClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    wclUsbMonitor: TwclUsbMonitor;

    procedure wclUsbMonitorInserted(Sender: TObject;
      const Device: TwclUsbDevice);
    procedure wclUsbMonitorRemoved(Sender: TObject;
      const Device: TwclUsbDevice);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

procedure TfmMain.btEnumClick(Sender: TObject);
var
  Devices: TwclUsbDevices;
  Res: Integer;
  i: Integer;
  Item: TListItem;
begin
  lvDevices.Items.Clear;

  Res := wclUsbMonitor.EnumDevices(Devices);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Enumeration USB devices failed. Error: 0x' + IntToHex(Res, 8),
      mtError, [mbOK], 0)

  end else
    for i := 0 to Length(Devices) - 1 do begin
      Item := lvDevices.Items.Add;
      
      Item.Caption := Devices[i].FriendlyName;
      Item.SubItems.Add(Devices[i].HardwareId);
      Item.SubItems.Add(Devices[i].Manufacturer);
      Item.SubItems.Add(Devices[i].Instance);
      Item.SubItems.Add(GUIDToString(Devices[i].ClassGuid));
      Item.SubItems.Add(BoolToStr(Devices[i].Enabled, True));
    end;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Clear;
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclUsbMonitor.Start;
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Start monitoring failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
  end else
    lbEvents.Items.Add('Monitoring started');
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclUsbMonitor.Stop;
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Stop monitoring failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
  end else
    lbEvents.Items.Add('Monitoring stopped');
end;

procedure TfmMain.wclUsbMonitorInserted(Sender: TObject;
  const Device: TwclUsbDevice);
begin
  lbEvents.Items.Add('Device inserted: ' + Device.Instance);
end;

procedure TfmMain.wclUsbMonitorRemoved(Sender: TObject;
  const Device: TwclUsbDevice);
begin
  lbEvents.Items.Add('Device removed: ' + Device.Instance);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclUsbMonitor := TwclUsbMonitor.Create(nil);
  wclUsbMonitor.OnInserted := wclUsbMonitorInserted;
  wclUsbMonitor.OnRemoved := wclUsbMonitorRemoved;
end;

procedure TfmMain.btEnableClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    Res := wclUsbMonitor.Enable(lvDevices.Selected.SubItems[2]);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Failed to enable device: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.btDisableClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    Res := wclUsbMonitor.Disable(lvDevices.Selected.SubItems[2]);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Failed to disable device: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclUsbMonitor.Stop;
  wclUsbMonitor.Free;
end;

end.

