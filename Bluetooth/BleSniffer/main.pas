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
    procedure FormDestroy(Sender: TObject);

  private
    wclBleSniffer: TwclBleSniffer;

    procedure wclBleSnifferStarted(Sender: TObject);
    procedure wclBleSnifferStopped(Sender: TObject);
    procedure wclBleSnifferRawPacketReceived(Sender: TObject;
      const Header: TwclBluetoothLePacketHeader; const Payload: Pointer;
      const Size: Word);
    procedure wclBleSnifferAdvIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
    procedure wclBleSnifferAdvDirectIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const TargetA: Int64);
    procedure wclBleSnifferAdvNonConnIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
    procedure wclBleSnifferAdvScanIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
    procedure wclBleSnifferScanReqReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const ScanA: Int64; const AdvA: Int64);
    procedure wclBleSnifferScanRspReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const ScanRspData: Pointer;
      const ScanRspDataLen: Byte);
    procedure wclBleSnifferConnectIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const InitA: Int64;
      const AdvA: Int64; const LlData: TwclBleSnifferLlData);

    procedure DumpHeader(const Header: TwclBluetoothLePacketHeader);
    procedure DumpPduHeader(
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader);
    procedure DumpPayload(const Payload: Pointer; const Size: Word);
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
  wclBleSniffer.OnStarted := wclBleSnifferStarted;
  wclBleSniffer.OnStopped := wclBleSnifferStopped;
  wclBleSniffer.OnRawPacketReceived := wclBleSnifferRawPacketReceived;
  wclBleSniffer.OnAdvIndReceived := wclBleSnifferAdvIndReceived;
  wclBleSniffer.OnAdvDirectIndReceived := wclBleSnifferAdvDirectIndReceived;
  wclBleSniffer.OnAdvNonConnIndReceived := wclBleSnifferAdvNonConnIndReceived;
  wclBleSniffer.OnAdvScanIndReceived := wclBleSnifferAdvScanIndReceived;
  wclBleSniffer.OnScanReqReceived := wclBleSnifferScanReqReceived;
  wclBleSniffer.OnScanRspReceived := wclBleSnifferScanRspReceived;
  wclBleSniffer.OnConnectIndReceived := wclBleSnifferConnectIndReceived;
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
begin
  lbPackets.Items.Add('RAW PACKET RECEIVED');
  DumpHeader(Header);
  DumpPayload(Payload, Size);
end;

procedure TfmMain.wclBleSnifferAdvIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
  const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
begin
  lbPackets.Items.Add('ADV_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(AdvData, AdvDataLen);
end;

procedure TfmMain.DumpHeader(const Header: TwclBluetoothLePacketHeader);
begin
  lbPackets.Items.Add('   HEADER');
  lbPackets.Items.Add('  ========');
  lbPackets.Items.Add('    Timestamp: ' + IntToHex(Header.Timestamp, 8));
  lbPackets.Items.Add('    Access Address: ' +
    IntToHex(Header.AccessAddress, 8));
  lbPackets.Items.Add('    Channel: ' + IntToHex(Header.Channel, 2));
  lbPackets.Items.Add('    Crc: ' + IntToHex(Header.Crc, 8));
  lbPackets.Items.Add('    Rssi: ' + IntToStr(Header.Rssi));
  if Header.Valid then
    lbPackets.Items.Add('    PACKET: OK')
  else
    lbPackets.Items.Add('    PACKET: ERROR');
end;

procedure TfmMain.DumpPayload(const Payload: Pointer; const Size: Word);
var
  Str: string;
  Ndx: Byte;
  i: Integer;
begin
  if (Payload <> nil) and (Size > 0) then begin
    lbPackets.Items.Add('   PAYLOAD');
    lbPackets.Items.Add('  =========');
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
  end;
  lbPackets.Items.Add('');
end;

procedure TfmMain.DumpPduHeader(
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader);
begin
  DumpHeader(PduHeader.Header);
  lbPackets.Items.Add('   PDU HEADER');
  lbPackets.Items.Add('  ============');
  lbPackets.Items.Add('    ChSel: ' + BoolToStr(PduHeader.ChSel, True));
  lbPackets.Items.Add('    TxAdd: ' + BoolToStr(PduHeader.TxAdd, True));
  lbPackets.Items.Add('    RxAdd: ' + BoolToStr(PduHeader.RxAdd, True));
end;

procedure TfmMain.wclBleSnifferAdvDirectIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const TargetA: Int64);
begin
  lbPackets.Items.Add('ADV_DIRECT_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  lbPackets.Items.Add('  TargetA: ' + IntToHex(TargetA, 12));
  DumpPduHeader(PduHeader);
end;

procedure TfmMain.wclBleSnifferAdvNonConnIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
  const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
begin
  lbPackets.Items.Add('ADV_NONCONN_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(AdvData, AdvDataLen);
end;

procedure TfmMain.wclBleSnifferAdvScanIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
  const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
begin
  lbPackets.Items.Add('ADV_SCAN_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(AdvData, AdvDataLen);
end;

procedure TfmMain.wclBleSnifferScanReqReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const ScanA: Int64;
  const AdvA: Int64);
begin
  lbPackets.Items.Add('SCAN_REQ RECEIVED');
  lbPackets.Items.Add('  ScanA: ' + IntToHex(ScanA, 12));
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
end;

procedure TfmMain.wclBleSnifferScanRspReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const ScanRspData: Pointer; const ScanRspDataLen: Byte);
begin
  lbPackets.Items.Add('SCAN_RSP RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(ScanRspData, ScanRspDataLen);
end;

procedure TfmMain.wclBleSnifferConnectIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const InitA: Int64;
  const AdvA: Int64; const LlData: TwclBleSnifferLlData);
begin
  lbPackets.Items.Add('CONNECT_IND RECEIVED');
  lbPackets.Items.Add('  InitA: ' + IntToHex(InitA, 12));
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  lbPackets.Items.Add('  LLDATA');
  lbPackets.Items.Add('    Aa: ' + IntToHex(LlData.Aa, 8));
  lbPackets.Items.Add('    CrcInit: ' + IntToHex(LlData.CrcInit, 8));
  lbPackets.Items.Add('    WinSize: ' + IntToStr(LlData.WinSize));
  lbPackets.Items.Add('    WinOffset: ' + IntToStr(LlData.WinOffset));
  lbPackets.Items.Add('    Interval: ' + IntToStr(LlData.Interval));
  lbPackets.Items.Add('    Latency: ' + IntToStr(LlData.Latency));
  lbPackets.Items.Add('    Timeout: ' + IntToStr(LlData.Timeout));
  lbPackets.Items.Add('    ChMap: ' + IntToHex(LlData.ChMap, 16));
  lbPackets.Items.Add('    Hop: ' + IntToStr(LlData.Hop));
  lbPackets.Items.Add('    Sca: ' + IntToStr(LlData.Sca));
  DumpPduHeader(PduHeader);
end;

end.
