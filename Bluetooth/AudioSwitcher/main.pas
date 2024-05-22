unit main;

{$MODE Delphi}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclAudio, ComCtrls;

type
  TfmMain = class(TForm)
    lvDevices: TListView;
    btEnum: TButton;
    cbActive: TCheckBox;
    cbDisabled: TCheckBox;
    cbNotPresent: TCheckBox;
    cbUnplugged: TCheckBox;
    laRole: TLabel;
    cbRole: TComboBox;
    btDefault: TButton;
    btClear: TButton;
    lbLog: TListBox;
    btRefresh: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    cbUseMac: TCheckBox;
    btGetDefault: TButton;
    laFlow: TLabel;
    cbFlow: TComboBox;
    procedure FormDestroy(Sender: TObject);
    procedure btEnumClick(Sender: TObject);
    procedure btDefaultClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btGetDefaultClick(Sender: TObject);

  private
    AudioSwitcher: TwclAudioSwitcher;

    procedure EnumDevices;
    procedure UpdateDevice(const Item: TListItem;
      const Device: TwclAudioDevice);

    procedure AudioSwitcherOpened(Sender: TObject);
    procedure AudioSwitcherClosed(Sender: TObject);
    procedure AudioSwitcherDefaultDeviceChanged(Sender: TObject;
      const Id: String; const Flow: TwclAudioDeviceDataFlow;
      const Role: TwclAudioDeviceRole);
    procedure AudioSwitcherDeviceAdded(Sender: TObject;
      const Id: String);
    procedure AudioSwitcherDeviceRemoved(Sender: TObject;
      const Id: String);
    procedure AudioSwitcherStateChanged(Sender: TObject;
      const Id: String; const State: TwclAudioDeviceState);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  AudioSwitcher.Close;
  AudioSwitcher.Free;
end;

procedure TfmMain.btEnumClick(Sender: TObject);
begin
  EnumDevices;
end;

procedure TfmMain.btDefaultClick(Sender: TObject);
var
  Role: TwclAudioDeviceRole;
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    case cbRole.ItemIndex of
      0: Role := drConsole;
      1: Role := drMultimedia;
      else Role := drCommunications;
    end;

    Res := AudioSwitcher.SetDefault(Role, lvDevices.Selected.Caption);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Unable to set default device: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.AudioSwitcherOpened(Sender: TObject);
begin
  lbLog.Items.Add('Audio switcher opened');
  EnumDevices;
end;

procedure TfmMain.EnumDevices;
var
  States: TwclAudioDeviceStates;
  Res: Integer;
  Devices: TwclAudioDevices;
  i: Integer;
  Item: TListItem;
begin
  States := [];
  if cbActive.Checked then
    States := States + [asActive];
  if cbDisabled.Checked then
    States := States + [asDisabled];
  if cbNotPresent.Checked then
    States := States + [asNotPresent];
  if cbUnplugged.Checked then
    States := States + [asUnplugged];
  if States = [] then
    ShowMessage('Select device state.')

  else begin
    lvDevices.Clear;

    Res := AudioSwitcher.Enum(States, Devices);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Enum failed: 0x' + IntToHex(Res, 8))

    else begin
      if Length(Devices) > 0 then begin
        for i := 0 to Length(Devices) - 1 do begin
          Item := lvDevices.Items.Add;
          Item.Caption := Devices[i].Id;
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          Item.SubItems.Add('');
          UpdateDevice(Item, Devices[i]);
        end;
      end;
    end;
  end;
end;

procedure TfmMain.AudioSwitcherClosed(Sender: TObject);
begin
  lvDevices.Clear;
  lbLog.Items.Add('Audio switcher closed');
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.AudioSwitcherDefaultDeviceChanged(Sender: TObject;
  const Id: String; const Flow: TwclAudioDeviceDataFlow;
  const Role: TwclAudioDeviceRole);
var
  Str: string;
begin
  Str := 'Default device changed: ' + Id + '; Flow: ';
  if Flow = dfRender then
    Str := Str + 'Render'
  else
    Str := Str + 'Capture';
  Str := Str + '; Role: ';
  case Role of
    drConsole:
      Str := Str + 'Console';
    drMultimedia:
      Str := Str + 'Multimedia';
    drCommunications:
      Str := Str + 'Communications';
  end;
  lbLog.Items.Add(Str);
end;

procedure TfmMain.AudioSwitcherDeviceAdded(Sender: TObject;
  const Id: String);
begin
  lbLog.Items.Add('Device added: ' + Id);
end;

procedure TfmMain.AudioSwitcherDeviceRemoved(Sender: TObject;
  const Id: String);
begin
  lbLog.Items.Add('Device removed: ' + Id);
end;

procedure TfmMain.AudioSwitcherStateChanged(Sender: TObject;
  const Id: String; const State: TwclAudioDeviceState);
var
  Str: string;
begin
  case State of
    asActive:
      Str := 'Active';
    asDisabled:
      Str := 'Disabled';
    asNotPresent:
      Str := 'NotPresent';
    asUnplugged:
      Str := 'Unplugged';
  end;
  lbLog.Items.Add('Device ' + Id + ' state changed: ' + Str);
end;

procedure TfmMain.btRefreshClick(Sender: TObject);
var
  Res: Integer;
  Device: TwclAudioDevice;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    Res := AudioSwitcher.GetDeviceDetails(lvDevices.Selected.Caption,
      Device);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Refresh device error: 0x' + IntToHex(Res, 8))
    else
      UpdateDevice(lvDevices.Selected, Device);
  end;
end;

procedure TfmMain.UpdateDevice(const Item: TListItem;
  const Device: TwclAudioDevice);
var
  FlowStr: string;
  RolesStr: string;
  StateStr: string;
  MacStr: string;
  ServiceStr: string;
begin
  if Device.Flow = dfRender then
    FlowStr := 'Render'
  else
    FlowStr := 'Capture';

  RolesStr := '[ ';
  if drConsole in Device.Roles then
    RolesStr := RolesStr + 'Console ';
  if drMultimedia in Device.Roles then
    RolesStr := RolesStr + 'Multimedia ';
  if drCommunications in Device.Roles then
    RolesStr := RolesStr + 'Communications ';
  RolesStr := RolesStr + ']';

  case Device.State of
    asActive:
      StateStr := 'Active';
    asDisabled:
      StateStr := 'Disabled';
    asNotPresent:
      StateStr := 'NotPresent';
    asUnplugged:
      StateStr := 'Unplugged';
  end;

  if Device.IsBluetooth then begin
    MacStr := IntToHex(Device.Mac, 12);
    ServiceStr := GUIDToString(Device.Service);
  end else begin
    MacStr := '';
    ServiceStr := '';
  end;

  Item.SubItems[0] := Device.FriendlyName;
  Item.SubItems[1] := Device.Description;
  Item.SubItems[2] := FlowStr;
  Item.SubItems[3] := RolesStr;
  Item.SubItems[4] := StateStr;
  Item.SubItems[5] := MacStr;
  Item.SubItems[6] := ServiceStr;
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    if cbUseMac.Checked then begin
      if lvDevices.Selected.SubItems[5] = '' then begin
        ShowMessage('Selected device is not Bluetooth enabled');
        Exit;
      end;

      Res := AudioSwitcher.Connect(
        StrToInt64('$' + lvDevices.Selected.SubItems[5]));

    end else
      Res := AudioSwitcher.Connect(lvDevices.Selected.Caption);

    if Res <> WCL_E_SUCCESS then
      ShowMessage('Connect error: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    if cbUseMac.Checked then begin
      if lvDevices.Selected.SubItems[5] = '' then begin
        ShowMessage('Selected device is not Bluetooth enabled');
        Exit;
      end;

      Res := AudioSwitcher.Disconnect(
        StrToInt64('$' + lvDevices.Selected.SubItems[5]));

    end else
      Res := AudioSwitcher.Disconnect(lvDevices.Selected.Caption);

    if Res <> WCL_E_SUCCESS then
      ShowMessage('Connect error: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  Res: Integer;
begin
  AudioSwitcher := TwclAudioSwitcher.Create(nil);
  AudioSwitcher.OnOpened := AudioSwitcherOpened;
  AudioSwitcher.OnClosed := AudioSwitcherClosed;
  AudioSwitcher.OnDefaultDeviceChanged := AudioSwitcherDefaultDeviceChanged;
  AudioSwitcher.OnDeviceAdded := AudioSwitcherDeviceAdded;
  AudioSwitcher.OnDeviceRemoved := AudioSwitcherDeviceRemoved;
  AudioSwitcher.OnStateChanged := AudioSwitcherStateChanged;

  Res := AudioSwitcher.Open;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Open failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btGetDefaultClick(Sender: TObject);
var
  Role: TwclAudioDeviceRole;
  Flow: TwclAudioDeviceDataFlow;
  Id: string;
  Res: Integer;
begin
  case cbRole.ItemIndex of
    0: Role := drConsole;
    1: Role := drMultimedia;
    else Role := drCommunications;
  end;

  if cbFlow.ItemIndex = 0 then
    Flow := dfCapture
  else
    Flow := dfRender;

  Res := AudioSwitcher.GetDefault(Role, Flow, Id);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Unable to get default device: 0x' + IntToHex(Res, 8))
  else
    ShowMessage('Default device ID: ' + Id);
end;

end.
