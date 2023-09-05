unit main;

{$MODE Delphi}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclBluetooth, ComCtrls;

type

  { TfmMain }

  TfmMain = class(TForm)
    btOpen: TButton;
    btClose: TButton;
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
    procedure btOpenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btEnumClick(Sender: TObject);
    procedure btDefaultClick(Sender: TObject);
    procedure wclAudioSwitcherOpened(Sender: TObject);
    procedure wclAudioSwitcherClosed(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);

  private
    wclAudioSwitcher: TwclAudioSwitcher;

    procedure wclAudioSwitcherDefaultDeviceChanged(Sender: TObject;
      const Id: String; const Flow: TwclAudioDeviceDataFlow;
      const Role: TwclAudioDeviceRole);
    procedure wclAudioSwitcherDeviceAdded(Sender: TObject;
      const Id: String);
    procedure wclAudioSwitcherDeviceRemoved(Sender: TObject;
      const Id: String);
    procedure wclAudioSwitcherStateChanged(Sender: TObject;
      const Id: String; const State: TwclAudioDeviceState);

    procedure EnumDevices;
    procedure UpdateDevice(const Item: TListItem;
      const Device: TwclAudioDevice);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils, ActiveX;

{$R *.lfm}

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclAudioSwitcher.Open;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Open failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclAudioSwitcher.Close;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Close failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclAudioSwitcher := TwclAudioSwitcher.Create(nil);
  wclAudioSwitcher.OnClosed := wclAudioSwitcherClosed;
  wclAudioSwitcher.OnDefaultDeviceChanged := wclAudioSwitcherDefaultDeviceChanged;
  wclAudioSwitcher.OnDeviceAdded := wclAudioSwitcherDeviceAdded;
  wclAudioSwitcher.OnOpened := wclAudioSwitcherOpened;
  wclAudioSwitcher.OnDeviceRemoved := wclAudioSwitcherDeviceRemoved;
  wclAudioSwitcher.OnStateChanged := wclAudioSwitcherStateChanged;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclAudioSwitcher.Close;
  wclAudioSwitcher.Free;
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

    Res := wclAudioSwitcher.SetDefault(Role, lvDevices.Selected.Caption);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Unable to set default device: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.wclAudioSwitcherOpened(Sender: TObject);
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

    Res := wclAudioSwitcher.Enum(States, Devices);
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

procedure TfmMain.wclAudioSwitcherClosed(Sender: TObject);
begin
  lvDevices.Clear;
  lbLog.Items.Add('Audio switcher closed');
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.wclAudioSwitcherDefaultDeviceChanged(Sender: TObject;
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

procedure TfmMain.wclAudioSwitcherDeviceAdded(Sender: TObject;
  const Id: String);
begin
  lbLog.Items.Add('Device added: ' + Id);
end;

procedure TfmMain.wclAudioSwitcherDeviceRemoved(Sender: TObject;
  const Id: String);
begin
  lbLog.Items.Add('Device removed: ' + Id);
end;

procedure TfmMain.wclAudioSwitcherStateChanged(Sender: TObject;
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
    Res := wclAudioSwitcher.GetDeviceDetails(lvDevices.Selected.Caption,
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
    Res := wclAudioSwitcher.Connect(lvDevices.Selected.Caption);
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
    Res := wclAudioSwitcher.Disconnect(lvDevices.Selected.Caption);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Connect error: 0x' + IntToHex(Res, 8));
  end;
end;

end.
