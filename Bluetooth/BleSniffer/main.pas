unit main;

{$MODE Delphi}

interface

uses
  Forms, StdCtrls, Controls, wclBluetooth, Classes;

type
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
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    BleSniffer: TwclBleSniffer;

    procedure DumpHeader(const Header: TwclBluetoothLePacketHeader);
    procedure DumpPduHeader(
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader);
    procedure DumpPayload(const Payload: Pointer; const Size: Word);

    procedure BleSnifferStarted(Sender: TObject);
    procedure BleSnifferStopped(Sender: TObject);
    procedure BleSnifferAdvDirectIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
      const TargetA: Int64);
    procedure BleSnifferAdvIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
    procedure BleSnifferAdvScanIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
    procedure BleSnifferRawPacketReceived(Sender: TObject;
      const Header: TwclBluetoothLePacketHeader; const Payload: Pointer;
      const Size: Word);
    procedure BleSnifferScanReqReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const ScanA: Int64;
      const AdvA: Int64);
    procedure BleSnifferScanRspReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const ScanRspData: Pointer;
      const ScanRspDataLen: Byte);
    procedure BleSnifferAdvNonConnIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader;
      const AdvA: Int64; const AdvData: Pointer; const AdvDataLen: Byte);
    procedure BleSnifferConnectIndReceived(Sender: TObject;
      const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const InitA: Int64;
      const AdvA: Int64; const LlData: TwclBleSnifferLlData);
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
  Res := BleSniffer.Start(cbChannel.ItemIndex + 37);
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Start failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := BleSniffer.Stop;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Stop failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.BleSnifferStarted(Sender: TObject);
begin
  lbPackets.Items.Add('Started');
end;

procedure TfmMain.BleSnifferStopped(Sender: TObject);
begin
  lbPackets.Items.Add('Stopped');
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  BleSniffer.Stop;
  BleSniffer.Free;
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
        lbPackets.Items.Add('    ' + Str);
        Str := '';
        Ndx := 1;
      end;
    end;
    if Str <> '' then
      lbPackets.Items.Add('    ' + Str);
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

procedure TfmMain.BleSnifferAdvDirectIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const TargetA: Int64);
begin
  lbPackets.Items.Add('ADV_DIRECT_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  lbPackets.Items.Add('  TargeA: ' + IntToHex(TargetA, 12));
  DumpPduHeader(PduHeader);
end;

procedure TfmMain.BleSnifferAdvIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const AdvData: Pointer; const AdvDataLen: Byte);
begin
  lbPackets.Items.Add('ADV_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(AdvData, AdvDataLen);
end;

procedure TfmMain.BleSnifferAdvScanIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const AdvData: Pointer; const AdvDataLen: Byte);
begin
  lbPackets.Items.Add('ADV_SCAN_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(AdvData, AdvDataLen);
end;

procedure TfmMain.BleSnifferRawPacketReceived(Sender: TObject;
  const Header: TwclBluetoothLePacketHeader; const Payload: Pointer;
  const Size: Word);
begin
  lbPackets.Items.Add('RAW PACKET RECEIVED');
  DumpHeader(Header);
  DumpPayload(Payload, Size);
end;

procedure TfmMain.BleSnifferScanReqReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const ScanA: Int64;
  const AdvA: Int64);
begin
  lbPackets.Items.Add('SCAN_REQ RECEIVED');
  lbPackets.Items.Add('  ScanA: ' + IntToHex(ScanA, 12));
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
end;

procedure TfmMain.BleSnifferScanRspReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const ScanRspData: Pointer; const ScanRspDataLen: Byte);
begin
  lbPackets.Items.Add('SCAN_RSP RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(ScanRspData, ScanRspDataLen);
end;

procedure TfmMain.BleSnifferAdvNonConnIndReceived(Sender: TObject;
  const PduHeader: TwclBluetoothLeAdvertisingPduHeader; const AdvA: Int64;
  const AdvData: Pointer; const AdvDataLen: Byte);
begin
  lbPackets.Items.Add('ADV_NONCONN_IND RECEIVED');
  lbPackets.Items.Add('  AdvA: ' + IntToHex(AdvA, 12));
  DumpPduHeader(PduHeader);
  DumpPayload(AdvData, AdvDataLen);
end;

procedure TfmMain.BleSnifferConnectIndReceived(Sender: TObject;
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
  lbPackets.Items.Add('    ChM: ' + IntToHex(LlData.ChM, 16));
  lbPackets.Items.Add('    Hop: ' + IntToStr(LlData.Hop));
  lbPackets.Items.Add('    Sca: ' + IntToStr(LlData.Sca));
  DumpPduHeader(PduHeader);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  BleSniffer := TwclBleSniffer.Create(nil);
  BleSniffer.OnStarted := BleSnifferStarted;
  BleSniffer.OnStopped := BleSnifferStopped;
  BleSniffer.OnAdvDirectIndReceived := BleSnifferAdvDirectIndReceived;
  BleSniffer.OnAdvIndReceived := BleSnifferAdvIndReceived;
  BleSniffer.OnAdvScanIndReceived := BleSnifferAdvScanIndReceived;
  BleSniffer.OnRawPacketReceived := BleSnifferRawPacketReceived;
  BleSniffer.OnScanReqReceived := BleSnifferScanReqReceived;
  BleSniffer.OnScanRspReceived := BleSnifferScanRspReceived;
  BleSniffer.OnAdvNonConnIndReceived := BleSnifferAdvNonConnIndReceived;
  BleSniffer.OnConnectIndReceived := BleSnifferConnectIndReceived;
end;

end.
