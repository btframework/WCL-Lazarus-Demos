unit main;

{$I wcl.inc}

interface

uses
  Forms, Controls, StdCtrls, wclBluetooth, Classes;

type
  { TfmMain }

  TfmMain = class(TForm)
    btStart: TButton;
    btStop: TButton;
    lbPackets: TListBox;
    btClear: TButton;
    laChannel: TLabel;
    cbChannel: TComboBox;
    procedure btClearClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure wclBleSnifferStarted(Sender: TObject);
    procedure wclBleSnifferStopped(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure wclBleSnifferRawPacketReceived(Sender: TObject;
      const Header: TwclBluetoothLePacketHeader; const Payload: Pointer;
      const Size: Word);

  private
    wclBleSniffer: TwclBleSniffer;
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils, Dialogs;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbPackets.Items.Clear;
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBleSniffer.Start(cbChannel.ItemIndex + 37);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Start failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBleSniffer.Stop;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Stop failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBleSniffer := TwclBleSniffer.Create(nil);
  wclBleSniffer.OnRawPacketReceived := wclBleSnifferRawPacketReceived;
  wclBleSniffer.OnStarted := wclBleSnifferStarted;
  wclBleSniffer.OnStopped := wclBleSnifferStopped;
end;

procedure TfmMain.wclBleSnifferStarted(Sender: TObject);
begin
  lbPackets.Items.Add('Started');
end;

procedure TfmMain.wclBleSnifferStopped(Sender: TObject);
begin
  lbPackets.Items.Add('Stopped');
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclBleSniffer.Stop;
  wclBleSniffer.Free;
end;

procedure TfmMain.wclBleSnifferRawPacketReceived(Sender: TObject;
  const Header: TwclBluetoothLePacketHeader; const Payload: Pointer;
  const Size: Word);
var
  Str: string;
  Ndx: Byte;
  i: Integer;
begin
  lbPackets.Items.Add('Timestamp: ' + IntToHex(Header.Timestamp, 8));
  lbPackets.Items.Add('  Address: ' + IntToHex(Header.AccessAddress, 8));
  lbPackets.Items.Add('  Channel: ' + IntToHex(Header.Channel, 2));
  lbPackets.Items.Add('  Crc: ' + IntToHex(Header.Crc, 8));
  lbPackets.Items.Add('  Rssi: ' + IntToStr(Header.Rssi));
  if Header.Valid then
    lbPackets.Items.Add('  PACKET: OK')
  else
    lbPackets.Items.Add('  PACKET: ERROR');

  Str := '';
  Ndx := 1;
  for i := 0 to Size - 1 do begin
    Str := Str + IntToHex(Byte(PAnsiChar(Payload)[i]), 2) + ' ';
    Inc(Ndx);
    if Ndx = 16 then begin
      lbPackets.Items.Add('  ' + Str);
      Str := '';
      Ndx := 1;
    end;
  end;
  if Str <> '' then
    lbPackets.Items.Add('  ' + Str);
  lbPackets.Items.Add('');
end;

end.
