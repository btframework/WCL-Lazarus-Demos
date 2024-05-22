unit main;

{$MODE Delphi}

interface

uses
  Forms, wclAudio, Classes, StdCtrls, Controls, ComCtrls, ExtCtrls;

type
  TfmMain = class(TForm)
    laEndPoints: TLabel;
    cbEndpoints: TComboBox;
    btOpen: TButton;
    btClose: TButton;
    lbLog: TListBox;
    btClear: TButton;
    Timer: TTimer;
    pbMaster: TProgressBar;
    tbMaster: TTrackBar;
    cbMute: TCheckBox;
    procedure btClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure tbMasterChange(Sender: TObject);
    procedure cbMuteClick(Sender: TObject);

  private
    AudioSwitcher: TwclAudioSwitcher;
    AudioMeter: TwclAudioMeter;
    AudioVolume: TwclAudioVolume;

    FBars: array of TProgressBar;

    procedure Trace(const Msg: string); overload;
    procedure Trace(const Msg: string; const Error: Integer); overload;

    procedure AddDevice(const Device: TwclAudioDevice);
    procedure DeleteDevice(const Id: string);
    procedure SelectActiveDevice;
    procedure UpdateChannelsValue;

    procedure AudioSwitcherClosed(Sender: TObject);
    procedure AudioSwitcherOpened(Sender: TObject);
    procedure AudioSwitcherDeviceRemoved(Sender: TObject;
      const Id: String);
    procedure AudioSwitcherDeviceAdded(Sender: TObject; const Id: String);
    procedure AudioSwitcherStateChanged(Sender: TObject; const Id: String;
      const State: TwclAudioDeviceState);
    procedure AudioSwitcherDefaultDeviceChanged(Sender: TObject;
      const Id: String; const Flow: TwclAudioDeviceDataFlow;
      const Role: TwclAudioDeviceRole);

    procedure AudioMeterOpened(Sender: TObject);
    procedure AudioMeterClosed(Sender: TObject);
    procedure AudioMeterDisconnected(Sender: TObject);

    procedure AudioVolumeOpened(Sender: TObject);
    procedure AudioVolumeClosed(Sender: TObject);
    procedure AudioVolumeDisconnected(Sender: TObject);
    procedure AudioVolumeChanged(Sender: TObject; const Muted: Boolean;
      const Volume: Single; const Volumes: TwclAudioPeakValues);
  end;

var
  fmMain: TfmMain;

implementation

uses
  SysUtils, wclErrors;

type
  TAudioDeviceStorage = class
    Device: TwclAudioDevice;
  end;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.Trace(const Msg: string);
begin
  lbLog.Items.Add(Msg);
end;

procedure TfmMain.Trace(const Msg: string; const Error: Integer);
begin
  Trace(Msg + ': 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  Res: Integer;
begin
  AudioSwitcher := TwclAudioSwitcher.Create(nil);
  AudioSwitcher.OnClosed := AudioSwitcherClosed;
  AudioSwitcher.OnOpened := AudioSwitcherOpened;
  AudioSwitcher.OnDeviceRemoved := AudioSwitcherDeviceRemoved;
  AudioSwitcher.OnDeviceAdded := AudioSwitcherDeviceAdded;
  AudioSwitcher.OnDefaultDeviceChanged := AudioSwitcherDefaultDeviceChanged;
  AudioSwitcher.OnStateChanged := AudioSwitcherStateChanged;
  
  AudioMeter := TwclAudioMeter.Create(nil);
  AudioMeter.OnOpened := AudioMeterOpened;
  AudioMeter.OnClosed := AudioMeterClosed;
  AudioMeter.OnDisconnected := AudioMeterDisconnected;

  AudioVolume := TwclAudioVolume.Create(nil);
  AudioVolume.OnOpened := AudioVolumeOpened;
  AudioVolume.OnClosed := AudioVolumeClosed;
  AudioVolume.OnDisconnected := AudioVolumeDisconnected;
  AudioVolume.OnChanged := AudioVolumeChanged;

  FBars := nil;

  Res := AudioSwitcher.Open;
  if Res <> WCL_E_SUCCESS then
    Trace('Audio switcher open failed', Res);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  AudioVolume.Close;
  AudioVolume.Free;

  AudioMeter.Close;
  AudioMeter.Free;

  AudioSwitcher.Close;
  AudioSwitcher.Free;
end;

procedure TfmMain.AudioSwitcherClosed(Sender: TObject);
var
  i: Integer;
begin
  Trace('Audio switcher closed');

  if cbEndpoints.Items.Count > 0 then begin
    for i := 0 to cbEndpoints.Items.Count - 1 do
      cbEndpoints.Items.Objects[i].Free;
    cbEndpoints.Items.Clear;
  end;
end;

procedure TfmMain.AudioSwitcherOpened(Sender: TObject);
var
  Res: Integer;
  Devices: TwclAudioDevices;
  i: Integer;
begin
  Trace('Audio switcher opened');

  Res := AudioSwitcher.Enum([asActive], Devices);
  if Res <> WCL_E_SUCCESS then
    Trace('Enum audio endpoints failed', Res)

  else begin
    if Length(Devices) = 0 then
      Trace('No active audio endpoints found')

    else begin
      for i := 0 to Length(Devices) - 1 do
        AddDevice(Devices[i]);

      if cbEndpoints.Items.Count = 0 then
        Trace('No output audio endpoints found')
      else
        SelectActiveDevice;
    end;
  end;
end;

procedure TfmMain.AudioSwitcherDeviceRemoved(Sender: TObject;
  const Id: String);
begin
  DeleteDevice(Id);
end;

procedure TfmMain.DeleteDevice(const Id: string);
var
  i: Integer;
  Storage: TAudioDeviceStorage;
begin
  if cbEndpoints.Items.Count > 0 then begin
    for i := 0 to cbEndpoints.Items.Count - 1 do begin
      Storage := TAudioDeviceStorage(cbEndpoints.Items.Objects[i]);
      if Storage.Device.Id = Id then begin
        Storage.Free;
        cbEndpoints.Items.Delete(i);
        if cbEndpoints.Items.Count > 0 then
          SelectActiveDevice;
        Break;
      end;
    end;
  end;
end;

procedure TfmMain.SelectActiveDevice;
var
  i: Integer;
  Storage: TAudioDeviceStorage;
  Res: Integer;
  Device: TwclAudioDevice;
begin
  if cbEndpoints.Items.Count > 0 then begin
    for i := 0 to cbEndpoints.Items.Count - 1 do begin
      Storage := TAudioDeviceStorage(cbEndpoints.Items.Objects[i]);
      Res := AudioSwitcher.GetDeviceDetails(Storage.Device.Id, Device);
      if Res = WCL_E_SUCCESS then
        Storage.Device := Device;
      if drMultimedia in Storage.Device.Roles then begin
        cbEndpoints.ItemIndex := i;
        Exit;
      end;
    end;
  end;

  cbEndpoints.ItemIndex := -1;
end;

procedure TfmMain.AudioSwitcherDeviceAdded(Sender: TObject;
  const Id: String);
var
  Device: TwclAudioDevice;
begin
  if AudioSwitcher.GetDeviceDetails(Id, Device) = WCL_E_SUCCESS then
    AddDevice(Device);
end;

procedure TfmMain.AddDevice(const Device: TwclAudioDevice);
var
  Storage: TAudioDeviceStorage;
begin
  if (Device.State = asActive) and (Device.Flow = dfRender) then begin
    Storage := TAudioDeviceStorage.Create;
    Storage.Device := Device;
    cbEndpoints.Items.AddObject(Device.FriendlyName, Storage);

    SelectActiveDevice;
  end;
end;

procedure TfmMain.AudioMeterOpened(Sender: TObject);
var
  Res: Integer;
  Features: TwclAudioHardwareFeatures;
  Channels: Cardinal;
  i: Integer;
  Bar: TProgressBar;
  Pos: Integer;
begin
  Trace('Audio meter opened');
  cbEndpoints.Enabled := False;
  pbMaster.Visible := True;

  Res := AudioMeter.GetHardwareFeatures(Features);
  if Res <> WCL_E_SUCCESS then
    Trace('Get hardware features failed', Res)

  else begin
    Trace('Hardware features');
    if hfVolume in Features then
      Trace('  Volume');
    if hfMute in Features then
      Trace('  Mute');
    if hfMeter in Features then
      Trace('  Meter');
  end;

  Res := AudioMeter.GetChannels(Channels);
  if Res <> WCL_E_SUCCESS then
    Trace('Get channels count failed', Res)

  else begin
    if Channels = 0 then begin
      Trace('No mettering channels available');
      AudioMeter.Close;

    end else begin
      Trace('Channels: ' + IntToStr(Channels));

      Pos := pbMaster.Left + pbMaster.Width + 5;
      SetLength(FBars, Channels);
      for i := 0 to Channels - 1 do begin
        Bar := TProgressBar.Create(Self);
        Bar.Parent := Self;
        Bar.Orientation := pbVertical;
        Bar.Width := pbMaster.Width;
        Bar.Height := pbMaster.Height;
        Bar.Top := pbMaster.Top;
        Bar.Left := Pos;
        Bar.Smooth := pbMaster.Smooth;

        Pos := Bar.Left + Bar.Width + 5;

        FBars[i] := Bar;
      end;

      UpdateChannelsValue;

      Timer.Enabled := True;
    end;
  end;
end;

procedure TfmMain.AudioMeterClosed(Sender: TObject);
var
  i: Integer;
begin
  Trace('Audio meter closed');
  Timer.Enabled := False;
  cbEndpoints.Enabled := True;

  if Length(FBars) > 0 then begin
    for i := 0 to Length(FBars) - 1 do
      FBars[i].Free;
    FBars := nil;
  end;

  pbMaster.Position := 0;
  pbMaster.Visible := False;
end;

procedure TfmMain.AudioMeterDisconnected(Sender: TObject);
begin
  Trace('Audio meter device ' + AudioMeter.Id + ' disconnected');
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := AudioVolume.Close;
  if Res <> WCL_E_SUCCESS then
    Trace('Audio volume close failed', Res);

  Res := AudioMeter.Close;
  if Res <> WCL_E_SUCCESS then
    Trace('Audio meter close failed', Res);
end;

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
  Id: string;
begin
  if cbEndpoints.ItemIndex = -1 then
    Trace('No audio endpoints found')

  else begin
    Id := TAudioDeviceStorage(
      cbEndpoints.Items.Objects[cbEndpoints.ItemIndex]).Device.Id;

    Res := AudioMeter.Open(Id);
    if Res <> WCL_E_SUCCESS then
      Trace('Audio meter open failed', Res);

    Res := AudioVolume.Open(Id);
    if Res <> WCL_E_SUCCESS then
      Trace('Audio volume open failed', Res);
  end;
end;

procedure TfmMain.UpdateChannelsValue;
var
  i: Integer;
  Res: Integer;
  Value: Single;
  Values: TwclAudioPeakValues;
begin
  Res := AudioMeter.GetPeak(Value);
  if Res = WCL_E_SUCCESS then begin
    if tbMaster.Visible then begin
      Value := Value * 100.00 * ((100 - tbMaster.Position) / 100.00);
      pbMaster.Position := Round(Value);
    end else
      pbMaster.Position := Round(Value * 100);
  end;

  if Length(FBars) > 0 then begin
    Res := AudioMeter.GetChannelsPeak(Values);
    if (Res = WCL_E_SUCCESS) and (Length(Values) > 0) then begin
      for i := 0 to Length(Values) - 1 do
        FBars[i].Position := Round(Values[i] * 100);
    end;
  end;
end;

procedure TfmMain.TimerTimer(Sender: TObject);
begin
  UpdateChannelsValue;
end;

procedure TfmMain.AudioSwitcherStateChanged(Sender: TObject;
  const Id: String; const State: TwclAudioDeviceState);
begin
  if State = asActive then
    AudioSwitcherDeviceAdded(AudioSwitcher, Id)
  else
    DeleteDevice(Id);
end;

procedure TfmMain.AudioSwitcherDefaultDeviceChanged(Sender: TObject;
  const Id: String; const Flow: TwclAudioDeviceDataFlow;
  const Role: TwclAudioDeviceRole);
begin
  Trace('Active device changed');

  if not AudioMeter.Active then
    SelectActiveDevice;
end;

procedure TfmMain.AudioVolumeOpened(Sender: TObject);
var
  Res: Integer;
  Features: TwclAudioHardwareFeatures;
  Volume: Single;
  Mute: Boolean;
begin
  Trace('Audio volume opened');
  cbEndpoints.Enabled := False;

  Res := AudioVolume.GetHardwareFeatures(Features);
  if Res <> WCL_E_SUCCESS then
    Trace('Get hardware features failed', Res)

  else begin
    Trace('Hardware features');
    if hfVolume in Features then
      Trace('  Volume');
    if hfMute in Features then
      Trace('  Mute');
    if hfMeter in Features then
      Trace('  Meter');
  end;

  Res := AudioVolume.GetVolume(Volume);
  if Res <> WCL_E_SUCCESS then
    Trace('Get volume failed', Res)
  else begin
    tbMaster.Visible := True;
    tbMaster.Position := 100 - Round(Volume * 100);
  end;

  Res := AudioVolume.GetMute(Mute);
  if Res <> WCL_E_SUCCESS then
    Trace('Get mute failed', Res)
  else begin
    cbMute.Visible := True;
    cbMute.Checked := Mute;
  end;
end;

procedure TfmMain.AudioVolumeClosed(Sender: TObject);
begin
  Trace('Audio volume closed');
  cbEndpoints.Enabled := True;
  tbMaster.Visible := False;
  tbMaster.Position := 100;
  cbMute.Visible := False;
end;

procedure TfmMain.AudioVolumeDisconnected(Sender: TObject);
begin
  Trace('Audio volume device ' + AudioVolume.Id + ' disconnected');
end;

procedure TfmMain.tbMasterChange(Sender: TObject);
var
  Res: Integer;
begin
  if AudioVolume.Active then begin
    Res := AudioVolume.SetVolume((100 - tbMaster.Position) / 100.00);
    if Res <> WCL_E_SUCCESS then
      Trace('Set volume failed', Res);
  end;
end;

procedure TfmMain.cbMuteClick(Sender: TObject);
var
  Res: Integer;
begin
  if AudioVolume.Active then begin
    Res := AudioVolume.SetMute(cbMute.Checked);
    if Res <> WCL_E_SUCCESS then
      Trace('Set mute failed', Res);
  end;
end;

procedure TfmMain.AudioVolumeChanged(Sender: TObject; const Muted: Boolean;
  const Volume: Single; const Volumes: TwclAudioPeakValues);
begin
  if AudioVolume.Active then begin
    Trace('Volume changed');

    cbMute.Checked := Muted;
    tbMaster.Position := 100 - Round(Volume * 100);
  end;
end;

end.
