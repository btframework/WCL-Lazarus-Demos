unit main;

{$MODE Delphi}

interface

uses
  Forms, wclAudio, Controls, ComCtrls, Classes, StdCtrls;

type

  { TfmMain }

  TfmMain = class(TForm)
    lvDevices: TListView;
    btStart: TButton;
    btStop: TButton;
    lbLog: TListBox;
    btClear: TButton;
    btOpen: TButton;
    btClose: TButton;
    btConnect: TButton;
    procedure btClearClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    wclBluetoothAudioWatcher: TwclBluetoothAudioWatcher;
    wclBluetoothAudioReceiver: TwclBluetoothAudioReceiver;

    procedure wclBluetoothAudioWatcherDeviceAdded(Sender: TObject;
      const Id: string; const Name: String);
    procedure wclBluetoothAudioWatcherDeviceRemoved(Sender: TObject;
      const Id: String);
    procedure wclBluetoothAudioWatcherStarted(Sender: TObject);
    procedure wclBluetoothAudioWatcherStopped(Sender: TObject);

    procedure wclBluetoothAudioReceiverClosed(Sender: TObject);
    procedure wclBluetoothAudioReceiverListen(Sender: TObject);
    procedure wclBluetoothAudioReceiverConnected(Sender: TObject);
    procedure wclBluetoothAudioReceiverDisconnected(Sender: TObject);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils, Dialogs;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothAudioReceiver.Close;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Close failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothAudioReceiver.Connect;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Connect failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    ShowMessage('Select device')

  else begin
    Res := wclBluetoothAudioReceiver.Listen(lvDevices.Selected.Caption);
    if Res <> WCL_E_SUCCESS then
      lbLog.Items.Add('Open failed: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothAudioWatcher.Start;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Watcher start failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothAudioWatcher.Stop;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Watcher stop failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBluetoothAudioWatcher := TwclBluetoothAudioWatcher.Create(nil);
  wclBluetoothAudioWatcher.OnDeviceAdded := wclBluetoothAudioWatcherDeviceAdded;
  wclBluetoothAudioWatcher.OnDeviceRemoved := wclBluetoothAudioWatcherDeviceRemoved;
  wclBluetoothAudioWatcher.OnStarted := wclBluetoothAudioWatcherStarted;
  wclBluetoothAudioWatcher.OnStopped := wclBluetoothAudioWatcherStopped;

  wclBluetoothAudioReceiver := TwclBluetoothAudioReceiver.Create(nil);
  wclBluetoothAudioReceiver.OnClosed := wclBluetoothAudioReceiverClosed;
  wclBluetoothAudioReceiver.OnListen := wclBluetoothAudioReceiverListen;
  wclBluetoothAudioReceiver.OnConnected := wclBluetoothAudioReceiverConnected;
  wclBluetoothAudioReceiver.OnDisconnected := wclBluetoothAudioReceiverDisconnected;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclBluetoothAudioReceiver.Close;
  wclBluetoothAudioReceiver.Free;

  wclBluetoothAudioWatcher.Stop;
  wclBluetoothAudioWatcher.Free;
end;

procedure TfmMain.wclBluetoothAudioWatcherDeviceAdded(Sender: TObject;
  const Id: string; const Name: String);
var
  Item: TListItem;
begin
  Item := lvDevices.Items.Add;
  Item.Caption := Id;
  Item.SubItems.Add(Name);

  lbLog.Items.Add('Device added: ' + Id);
end;

procedure TfmMain.wclBluetoothAudioWatcherDeviceRemoved(Sender: TObject;
  const Id: String);
var
  i: Integer;
begin
  if lvDevices.Items.Count > 0 then begin
    for i := 0 to lvDevices.Items.Count - 1 do begin
      if lvDevices.Items[i].Caption = Id then begin
        lvDevices.Items.Delete(i);
        Break;
      end;
    end;
  end;

  lbLog.Items.Add('Device removed: ' + Id);
end;

procedure TfmMain.wclBluetoothAudioWatcherStarted(Sender: TObject);
begin
  lbLog.Items.Add('Watcher started');
  lvDevices.Items.Clear;
end;

procedure TfmMain.wclBluetoothAudioWatcherStopped(Sender: TObject);
begin
  lbLog.Items.Add('Watcher stopped');
end;

procedure TfmMain.wclBluetoothAudioReceiverClosed(Sender: TObject);
begin
  lbLog.Items.Add('Audio receiver closed');
end;

procedure TfmMain.wclBluetoothAudioReceiverListen(Sender: TObject);
begin
  lbLog.Items.Add('Audio receiver listening');
end;

procedure TfmMain.wclBluetoothAudioReceiverConnected(Sender: TObject);
begin
  lbLog.Items.Add('Remote device connected');
end;

procedure TfmMain.wclBluetoothAudioReceiverDisconnected(Sender: TObject);
begin
  lbLog.Items.Add('Remote device disconnected');
end;

end.
