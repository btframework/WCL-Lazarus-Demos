unit main;

{$I wcl.inc}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclBluetooth, ComCtrls;

type

  { TfmMain }

  TfmMain = class(TForm)
    btOpen: TButton;
    btClose: TButton;
    btStart: TButton;
    btStop: TButton;
    btClear: TButton;
    btDefault: TButton;
    cbScanMode: TCheckBox;
    laScanMode: TLabel;
    ListBox: TListBox;
    btClearLogs: TButton;
    lbFrames: TListBox;
    btStartAdvertising: TButton;
    btStopAdvertising: TButton;
    laScanInterval: TLabel;
    edScanInterval: TEdit;
    laScanWindow: TLabel;
    edScanWindow: TEdit;
    laAdvInterval: TLabel;
    edAdvInterval: TEdit;
    cbIBeacon: TCheckBox;
    cbProximityBeacon: TCheckBox;
    cbAltBeacon: TCheckBox;
    cbEddystoneUid: TCheckBox;
    cbEddystoneUrl: TCheckBox;
    cb128SolUuid: TCheckBox;
    cbManufacturer: TCheckBox;
    cb16UuidService: TCheckBox;
    cb32UuidService: TCheckBox;
    cb128UuidService: TCheckBox;
    cb16UuidData: TCheckBox;
    cb32UuidData: TCheckBox;
    cb128UuidData: TCheckBox;
    cbCustomRaw: TCheckBox;
    cbUseExtended: TCheckBox;
    cbAnonymous: TCheckBox;
    cbIncludeTxRssi: TCheckBox;
    procedure btDefaultClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btClearLogsClick(Sender: TObject);
    procedure btStartAdvertisingClick(Sender: TObject);
    procedure btStopAdvertisingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclBluetoothLeBeaconWatcher: TwclBluetoothLeBeaconWatcher;
    wclBluetoothLeAdvertiser: TwclBluetoothLeAdvertiser;

    procedure wclBluetoothManagerAfterOpen(Sender: TObject);
    procedure wclBluetoothManagerBeforeClose(Sender: TObject);
    procedure wclBluetoothManagerStatusChanged(Sender: TObject;
      const Radio: TwclBluetoothRadio);

    procedure wclBluetoothLeBeaconWatcherStarted(Sender: TObject);
    procedure wclBluetoothLeBeaconWatcherStopped(Sender: TObject);
    procedure wclBluetoothLeBeaconWatcherAdvertisementRawFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const DataType: Byte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherManufacturerRawFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const CompanyId: Word;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherProximityBeaconFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const CompanyId: Word; const Major: Word;
      const Minor: Word; const Uuid: TGUID; const TxRssi: Shortint;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherEddystoneUidFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: ShortInt;
      const TxRssi: Shortint; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherEddystoneUrlFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: ShortInt;
      const TxRssi: Shortint; const Url: String);
    procedure wclBluetoothLeBeaconWatcherEddystoneTlmFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: Shortint;
      const AdvCnt: Cardinal; const Batt: Word; const SecCnt: Cardinal;
      const Temp: Double; const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherAltBeaconFrame(Sender: TObject;
      const Address: Int64; const  Timestamp: Int64; const Rssi: Shortint;
      const CompanyId: Word; const Major: Word; const Minor: Word;
      const Uuid: TGUID; const TxRssi: Shortint; const Reserved: Byte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherAdvertisementFrameInformation(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Name: String;
      const PacketType: TwclBluetoothLeAdvertisementType;
      const Flags: TwclBluetoothLeAdvertisementFlags);
    procedure wclBluetoothLeBeaconWatcherAdvertisementUuidFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: TGUID);
    procedure wclBluetoothLeBeaconWatcherAdvertisementExtFrameInformation(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const AddressType: TwclBluetoothAddressType;
      const TxPower: Shortint; const Flags: TwclBluetoothLeExtendedFrameFlags);
    procedure wclBluetoothLeBeaconWatcherAdvertisementService128DataFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherAdvertisementService16DataFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: Word;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherAdvertisementService32DataFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: Cardinal;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure wclBluetoothLeBeaconWatcherAdvertisementServiceSol128Frame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: TGUID);
    procedure wclBluetoothLeBeaconWatcherAdvertisementServiceSol16Frame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: Word);
    procedure wclBluetoothLeBeaconWatcherAdvertisementServiceSol32Frame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: Shortint; const Uuid: Cardinal);
    procedure wclBluetoothLeBeaconWatcherAdvertisementReceived(
      Sender: TObject; const Address, Timestamp: Int64;
      const Rssi: Shortint;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);

    procedure wclBluetoothLeAdvertiserStarted(Sender: TObject);
    procedure wclBluetoothLeAdvertiserStopped(Sender: TObject);
    procedure wclBluetoothLeAdvertiserAdvertisingBegin(Sender: TObject;
      const Index: Integer);
    procedure wclBluetoothLeAdvertiserAdvertisingEnd(Sender: TObject;
      const Index: Integer);
    procedure wclBluetoothLeAdvertiserAdvertisingError(Sender: TObject;
      const Index: Integer; const Error: Integer);

    function GetRadio: TwclBluetoothRadio;

    function ConvertTime(const Timestamp: Int64): TDateTime;

    procedure DumpData(const Data: TwclBluetoothLeAdvertisementFrameRawData);

    procedure AddAdvertisement(Adv: TwclBluetoothLeAdvertisement);
    procedure EnableAdvertisements(const Enable: Boolean);

    procedure DefaultScanParams;
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils, Math, Dialogs, Windows, wclUUIDs;

{$R *.lfm}

{ TfmMain }

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclBluetoothManager.Close;

  wclBluetoothLeAdvertiser.Free;
  wclBluetoothLeBeaconWatcher.Free;
  wclBluetoothManager.Free;
end;

procedure TfmMain.btDefaultClick(Sender: TObject);
begin
  DefaultScanParams;
end;

procedure TfmMain.DefaultScanParams;
begin
  cbScanMode.Checked := True;
  edScanInterval.Text := IntToStr(WCL_BLE_DEFAULT_SCAN_INTERVAL);
  edScanWindow.Text := IntToStr(WCL_BLE_DEFAULT_SCAN_WINDOW);
end;

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothManager.Open;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothManager.Close;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btStartClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
  Mode: TwclBluetoothLeScanningMode;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    if cbScanMode.Checked then
      Mode := smActive
    else
      Mode := smPassive;
    Res := wclBluetoothLeBeaconWatcher.Start(Radio, Mode,
      StrToInt(edScanInterval.Text), StrToInt(edScanWindow.Text));
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothLeBeaconWatcher.Stop;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.wclBluetoothManagerAfterOpen(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth Manager Opened');
end;

procedure TfmMain.wclBluetoothManagerBeforeClose(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth Manager Closed');
end;

procedure TfmMain.wclBluetoothManagerStatusChanged(Sender: TObject;
  const Radio: TwclBluetoothRadio);
var
  Str: string;
begin
  if Radio.Available then
   Str := 'AVAILABLE'
  else
    Str := 'UNAVAILABLE';
  ListBox.Items.Add('Radio ' + Radio.ApiName + ' status changed: ' + Str);
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbFrames.Clear;
end;

procedure TfmMain.btClearLogsClick(Sender: TObject);
begin
  ListBox.Clear;
end;

function TfmMain.ConvertTime(const Timestamp: Int64): TDateTime;
var
  li: ULARGE_INTEGER;
  ft: FILETIME;
  st: SYSTEMTIME;
begin
  // Conver timestamp.
  li.QuadPart := Timestamp;
  ft.dwLowDateTime := li.LowPart;
  ft.dwHighDateTime := li.HighPart;
  FileTimeToLocalFileTime(ft, ft);
  FileTimeToSystemTime(ft, st);
  Result := SystemTimeToDateTime(st);
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherStarted(Sender: TObject);
begin
  ListBox.Items.Add('Beacons Monitoring Started');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherStopped(Sender: TObject);
begin
  ListBox.Items.Add('Beacons Monitoring Stopped');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementRawFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const DataType: Byte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('UNKNOWN RAW FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  Data type: ' + IntToHex(DataType, 2));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherManufacturerRawFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const CompanyId: Word;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('UNKNOWN MANUFACTURER RAW FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Company ID: ' + IntToHex(CompanyId, 4));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherProximityBeaconFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const CompanyId: Word; const Major: Word;
  const Minor: Word; const Uuid: TGUID; const TxRssi: Shortint;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Dist: Double;
begin
  // Calculate distance.
  Dist := Power(10.0, (TxRssi - Rssi) / 20.0);

  lbFrames.Items.Add('PROXIMITY BEACON FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Company ID: ' + IntToHex(CompanyId, 4));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));
  lbFrames.Items.Add('  Major: ' + IntToHex(Major, 4));
  lbFrames.Items.Add('  Minor: ' + IntToHex(Minor, 4));
  lbFrames.Items.Add('  TX RSSI: ' + IntToStr(TxRssi));
  lbFrames.Items.Add('  Distance: ' + FloatToStr(Dist));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherEddystoneUidFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: ShortInt; const TxRssi: Shortint; const Uuid: TGUID;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Dist: Double;
begin
  // Calculate distance.
  Dist := Power(10.0, (TxRssi - 41 - Rssi) / 20.0);

  lbFrames.Items.Add('EDDYSTONE UID FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));

  lbFrames.Items.Add('  TX RSSI: ' + IntToStr(TxRssi));
  lbFrames.Items.Add('  Distance: ' + FloatToStr(Dist));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherEddystoneUrlFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: ShortInt; const TxRssi: Shortint; const Url: String);
var
  Dist: Double;
begin
  // Calculate distance.
  Dist := Power(10.0, (TxRssi - 41 - Rssi) / 20.0);

  lbFrames.Items.Add('EDDYSTONE URL FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  URL: ' + Url);

  lbFrames.Items.Add('  TX RSSI: ' + IntToStr(TxRssi));
  lbFrames.Items.Add('  Distance: ' + FloatToStr(Dist));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherEddystoneTlmFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const AdvCnt: Cardinal; const Batt: Word;
  const SecCnt: Cardinal; const Temp: Double;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('EDDYSTONE TLM FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  Advertisements counter: ' + IntToStr(AdvCnt));
  lbFrames.Items.Add('  Battery (mv): ' + IntToStr(Batt));
  lbFrames.Items.Add('  Seconds running: ' + FloatToStr(SecCnt / 10));
  lbFrames.Items.Add('  Temperature: ' + FloatToStr(Temp));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.btStartAdvertisingClick(Sender: TObject);
const
  BEACON_UUID: TGUID = '{09039835-4A80-443B-87AA-DC565D09EA61}';

var
  Radio: TwclBluetoothRadio;
  Res: Integer;
  Data: TwclBluetoothLeAdvertisementFrameRawData;
  Adv: TwclBluetoothLeAdvertisement;
begin
  wclBluetoothLeAdvertiser.Stop;

  Radio := GetRadio;
  if Radio <> nil then begin
    // Create and add iBeacon advdertisement.
    if cbIBeacon.Checked then begin
      Adv := TwclBluetoothLeiBeaconAdvertisement.Create(-5, $0101, $0202,
        BEACON_UUID);
      AddAdvertisement(Adv);
    end;

    // Create and add Proximity Beacon advertisement.
    if cbProximityBeacon.Checked then begin
      Adv := TwclBluetoothLeProximityBeaconAdvertisement.Create(-5, $0101,
        $0202, BEACON_UUID, $FFFE);
      AddAdvertisement(Adv);
    end;

    // Create and add Alt Beacon advertisement.
    if cbAltBeacon.Checked then begin
      Adv := TwclBluetoothLeAltBeaconAdvertisement.Create(-5, $0101, $0202,
        BEACON_UUID, $FFFE, $11);
      AddAdvertisement(Adv);
    end;

    // Create and add Eddystone UID advertisement.
    if cbEddystoneUid.Checked then begin
      Adv := TwclBluetoothLeEddystoneUidBeaconAdvertisement.Create(-5,
        BEACON_UUID);
      AddAdvertisement(Adv);
    end;

    // Create and add Eddystone URL.
    if cbEddystoneUrl.Checked then begin
      Adv := TwclBluetoothLeEddystoneUrlBeaconAdvertisement.Create(-5,
        'https://www.btframework.com');
      AddAdvertisement(Adv);
    end;

    if cb128SolUuid.Checked then begin
      // Create and add custom advertisement.
      SetLength(Data, 16);
      Data[0] := $D0;
      Data[1] := $00;
      Data[2] := $2D;
      Data[3] := $12;
      Data[4] := $1E;
      Data[5] := $4B;
      Data[6] := $0F;
      Data[7] := $A4;
      Data[8] := $99;
      Data[9] := $4E;
      Data[10] := $CE;
      Data[11] := $B5;
      Data[12] := $31;
      Data[13] := $F4;
      Data[14] := $05;
      Data[15] := $79;
      Adv := TwclBluetoothLeCustomAdvertisement.Create(
        LE_GAP_AD_TYPE_SERVICE_SOL_UUIDS_128, Data);
      AddAdvertisement(Adv);
    end;

    // Create and add manufacturer specific advertisement.
    if cbManufacturer.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLeManufacturerAdvertisement.Create($010E, Data);
      AddAdvertisement(Adv);
    end;

    if cb16UuidService.Checked then begin
      Adv := TwclBluetoothLe16ServiceAdvertisement.Create($9835);
      AddAdvertisement(Adv);
    end;

    if cb32UuidService.Checked then begin
      Adv := TwclBluetoothLe32ServiceAdvertisement.Create($09039835);
      AddAdvertisement(Adv);
    end;

    if cb128UuidService.Checked then begin
      Adv := TwclBluetoothLe128ServiceAdvertisement.Create(BEACON_UUID);
      AddAdvertisement(Adv);
    end;

    if cb16UuidData.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLe16ServiceDataAdvertisement.Create($9835, Data);
      AddAdvertisement(Adv);
    end;

    if cb32UuidData.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLe32ServiceDataAdvertisement.Create($09039835, Data);
      AddAdvertisement(Adv);
    end;

    if cb128UuidData.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLe128ServiceDataAdvertisement.Create(BEACON_UUID,
        Data);
      AddAdvertisement(Adv);
    end;

    if cbCustomRaw.Checked then begin
      Data := nil;
      SetLength(Data, 20);

      // 16 bit Service Data
      Data[0] := $09; // Length.
      Data[1] := LE_GAP_AD_TYPE_SERVICE_DATA_16; // Data type.
      Data[2] := $12; // 16 UUID LO BYTE
      Data[3] := $34; // 16 UUID HI BYTE
      Data[4] := $FF; // Data 1st byte
      Data[5] := $FE; // Data 2st byte
      Data[6] := $FD; // Data 3st byte
      Data[7] := $FC; // Data 4st byte
      Data[8] := $FB; // Data 5st byte
      Data[9] := $FA; // Data 6st byte
      // Manufacturer specific data.
      Data[10] := $09; // Length.
      Data[11] := LE_GAP_AD_TYPE_MANUFACTURER; // Data type.
      Data[12] := $10; // Company ID.
      Data[13] := $12; // Company ID.
      Data[14] := $01; // Data 1st byte
      Data[15] := $02; // Data 2st byte
      Data[16] := $03; // Data 3st byte
      Data[17] := $04; // Data 4st byte
      Data[18] := $05; // Data 5st byte
      Data[19] := $06; // Data 6st byte

      Adv := TwclBluetoothLeRawAdvertisement.Create(Data);
      AddAdvertisement(Adv);
    end;

    if wclBluetoothLeAdvertiser.Count = 0 then
      ShowMessage('Select at least one advertisement type.')

    else begin
      wclBluetoothLeAdvertiser.UseExtendedAdvertisement := cbUseExtended.Checked;
      wclBluetoothLeAdvertiser.Anonymous := cbAnonymous.Checked;
      wclBluetoothLeAdvertiser.IncludeTxRssi := cbIncludeTxRssi.Checked;
      wclBluetoothLeAdvertiser.PreferredTxRssi := 10;

      Res := wclBluetoothLeAdvertiser.Start(Radio,
        StrToInt(edAdvInterval.Text));
      if Res <> WCL_E_SUCCESS then begin
        ListBox.Items.Add('Start advertiser failed: 0x' + IntToHex(Res, 8));
        wclBluetoothLeAdvertiser.Clear;
      end;
    end;
  end;
end;

procedure TfmMain.btStopAdvertisingClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclBluetoothLeAdvertiser.Stop;
  if Res <> WCL_E_SUCCESS then
    ListBox.Items.Add('Stop advertiser failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAltBeaconFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const CompanyId: Word; const Major: Word;
  const Minor: Word; const Uuid: TGUID; const TxRssi: Shortint;
  const Reserved: Byte; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Dist: Double;
begin
  // Calculate distance.
  Dist := Power(10.0, (TxRssi - Rssi) / 20.0);

  lbFrames.Items.Add('ALT BEACON FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Company ID: ' + IntToHex(CompanyId, 4));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));
  lbFrames.Items.Add('  Major: ' + IntToHex(Major, 4));
  lbFrames.Items.Add('  Minor: ' + IntToHex(Minor, 4));
  lbFrames.Items.Add('  Reserved: ' + IntToHex(Reserved, 2));
  lbFrames.Items.Add('  TX RSSI: ' + IntToStr(TxRssi));
  lbFrames.Items.Add('  Distance: ' + FloatToStr(Dist));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementFrameInformation(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Name: String;
  const PacketType: TwclBluetoothLeAdvertisementType;
  const Flags: TwclBluetoothLeAdvertisementFlags);
var
  Str: string;
begin
  lbFrames.Items.Add('FRAME INFORMATION');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  Name: ' + Name);

  case PacketType of
    atConnectableUndirected:
      Str := 'Connectable Undirected';
    atConnectableDirected:
      Str := 'Connectable Directed';
    atScannableUndirected:
      Str := 'Scannable Undirecte';
    atNonConnectableUndirected:
      Str := 'Non Connectable Undirected';
    atScanResponse:
      Str := 'Scan Response';
    else
      Str := 'Unknown';
  end;
  lbFrames.Items.Add('  Frame type: ' + Str);

  Str := '[';
  if afLimitedDiscoverableMode in Flags then
    Str := Str + ' afLimitedDiscoverableMode';
  if afGeneralDiscoverableMode in Flags then
    Str := Str + ' afGeneralDiscoverableMode';
  if afClassicNotSupported in Flags then
    Str := Str + ' afClassicNotSupported';
  if afDualModeControllerCapable in Flags then
    Str := Str + ' afDualModeControllerCapable';
  if afDualModeHostCapable in Flags then
    Str := Str + ' afDualModeHostCapable';
  Str := Str + ' ]';
  lbFrames.Items.Add('  Flags: ' + Str);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementUuidFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: TGUID);
begin
  lbFrames.Items.Add('UUID FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementExtFrameInformation(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const AddressType: TwclBluetoothAddressType;
  const TxPower: Shortint; const Flags: TwclBluetoothLeExtendedFrameFlags);
var
  Str: string;
begin
  lbFrames.Items.Add('EXTENDED FRAME INFORMATION');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  case AddressType of
    atPublic:
      Str := 'Public';
    atRandom:
      Str := 'Random';
    atUnspecified:
      Str := 'Unspecified';
    else
      Str := 'Unknown';
  end;
  lbFrames.Items.Add('  Address type: ' + Str);

  lbFrames.Items.Add('  TX Power: ' + IntToStr(TxPower));

  Str := '[';
  if efAnonymous in Flags then
    Str := Str + ' efAnonymous';
  if efConnectable in Flags then
    Str := Str + ' efConnectable';
  if efDirected in Flags then
    Str := Str + ' efDirected';
  if efScannable in Flags then
    Str := Str + ' efScannable';
  if efScanResponse in Flags then
    Str := Str + ' efScanResponse';
  Str := Str + ' ]';
  lbFrames.Items.Add('  Flags: ' + Str);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementService128DataFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: TGUID;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('128 UUID SERVICE DATA');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementService16DataFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: Word;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('16 UUID SERVICE DATA');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + IntToHex(Uuid, 4));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementService32DataFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: Cardinal;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('32 UUID SERVICE DATA');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + IntToHex(Uuid, 8));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementServiceSol128Frame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: TGUID);
begin
  lbFrames.Items.Add('128 UUID SOL SERVICE');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementServiceSol16Frame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: Word);
begin
  lbFrames.Items.Add('16 UUID SOL SERVICE');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + IntToHex(Uuid, 4));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementServiceSol32Frame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: Shortint; const Uuid: Cardinal);
begin
  lbFrames.Items.Add('32 UUID SOL SERVICE');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + IntToHex(Uuid, 8));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := wclBluetoothManager.GetLeRadio(Radio);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Get working radio failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
    Result := nil;
  end else
    Result := Radio;
end;

procedure TfmMain.AddAdvertisement(Adv: TwclBluetoothLeAdvertisement);
var
  Res: Integer;
begin
  Res := wclBluetoothLeAdvertiser.Add(Adv);
  if Res <> WCL_E_SUCCESS then begin
    ListBox.Items.Add('Add advertisement failed: 0x' + IntToHex(Res, 8));
    Adv.Free;
  end;
end;

procedure TfmMain.wclBluetoothLeAdvertiserStarted(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth LE Advertising Started');

  EnableAdvertisements(False);
end;

procedure TfmMain.wclBluetoothLeAdvertiserStopped(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth LE Advertising Stopped');
  wclBluetoothLeAdvertiser.Clear;

  EnableAdvertisements(True);
end;

procedure TfmMain.EnableAdvertisements(const Enable: Boolean);
begin
  cbIBeacon.Enabled := Enable;
  cbProximityBeacon.Enabled := Enable;
  cbAltBeacon.Enabled := Enable;
  cbEddystoneUid.Enabled := Enable;
  cbEddystoneUrl.Enabled := Enable;
  cb128SolUuid.Enabled := Enable;
  cbManufacturer.Enabled := Enable;
  cb16UuidService.Enabled := Enable;
  cb32UuidService.Enabled := Enable;
  cb128UuidService.Enabled := Enable;
  cb16UuidData.Enabled := Enable;
  cb32UuidData.Enabled := Enable;
  cb128UuidData.Enabled := Enable;
  cbCustomRaw.Enabled := Enable;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);
  wclBluetoothManager.AfterOpen := wclBluetoothManagerAfterOpen;
  wclBluetoothManager.BeforeClose := wclBluetoothManagerBeforeClose;
  wclBluetoothManager.OnStatusChanged := wclBluetoothManagerStatusChanged;

  wclBluetoothLeBeaconWatcher := TwclBluetoothLeBeaconWatcher.Create(nil);
  wclBluetoothLeBeaconWatcher.OnAdvertisementFrameInformation := wclBluetoothLeBeaconWatcherAdvertisementFrameInformation;
  wclBluetoothLeBeaconWatcher.OnAdvertisementExtFrameInformation := wclBluetoothLeBeaconWatcherAdvertisementExtFrameInformation;
  wclBluetoothLeBeaconWatcher.OnAdvertisementRawFrame := wclBluetoothLeBeaconWatcherAdvertisementRawFrame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementReceived := wclBluetoothLeBeaconWatcherAdvertisementReceived;
  wclBluetoothLeBeaconWatcher.OnAdvertisementService16DataFrame := wclBluetoothLeBeaconWatcherAdvertisementService16DataFrame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementService32DataFrame := wclBluetoothLeBeaconWatcherAdvertisementService32DataFrame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementService128DataFrame := wclBluetoothLeBeaconWatcherAdvertisementService128DataFrame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementServiceSol16Frame := wclBluetoothLeBeaconWatcherAdvertisementServiceSol16Frame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementServiceSol32Frame := wclBluetoothLeBeaconWatcherAdvertisementServiceSol32Frame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementServiceSol128Frame := wclBluetoothLeBeaconWatcherAdvertisementServiceSol128Frame;
  wclBluetoothLeBeaconWatcher.OnAdvertisementUuidFrame := wclBluetoothLeBeaconWatcherAdvertisementUuidFrame;
  wclBluetoothLeBeaconWatcher.OnAltBeaconFrame := wclBluetoothLeBeaconWatcherAltBeaconFrame;
  wclBluetoothLeBeaconWatcher.OnEddystoneTlmFrame := wclBluetoothLeBeaconWatcherEddystoneTlmFrame;
  wclBluetoothLeBeaconWatcher.OnEddystoneUidFrame := wclBluetoothLeBeaconWatcherEddystoneUidFrame;
  wclBluetoothLeBeaconWatcher.OnEddystoneUrlFrame := wclBluetoothLeBeaconWatcherEddystoneUrlFrame;
  wclBluetoothLeBeaconWatcher.OnManufacturerRawFrame := wclBluetoothLeBeaconWatcherManufacturerRawFrame;
  wclBluetoothLeBeaconWatcher.OnProximityBeaconFrame := wclBluetoothLeBeaconWatcherProximityBeaconFrame;
  wclBluetoothLeBeaconWatcher.OnStarted := wclBluetoothLeBeaconWatcherStarted;
  wclBluetoothLeBeaconWatcher.OnStopped := wclBluetoothLeBeaconWatcherStopped;

  wclBluetoothLeAdvertiser := TwclBluetoothLeAdvertiser.Create(nil);
  wclBluetoothLeAdvertiser.OnAdvertisingBegin := wclBluetoothLeAdvertiserAdvertisingBegin;
  wclBluetoothLeAdvertiser.OnAdvertisingEnd := wclBluetoothLeAdvertiserAdvertisingEnd;
  wclBluetoothLeAdvertiser.OnAdvertisingError := wclBluetoothLeAdvertiserAdvertisingError;
  wclBluetoothLeAdvertiser.OnStarted := wclBluetoothLeAdvertiserStarted;
  wclBluetoothLeAdvertiser.OnStopped := wclBluetoothLeAdvertiserStopped;

  DefaultScanParams;
end;

procedure TfmMain.wclBluetoothLeAdvertiserAdvertisingBegin(Sender: TObject;
  const Index: Integer);
begin
  ListBox.Items.Add('Advertising ' + IntToStr(Index) + ' begin.');
end;

procedure TfmMain.wclBluetoothLeAdvertiserAdvertisingEnd(Sender: TObject;
  const Index: Integer);
begin
  ListBox.Items.Add('Advertising ' + IntToStr(Index) + ' end');
end;

procedure TfmMain.wclBluetoothLeAdvertiserAdvertisingError(Sender: TObject;
  const Index: Integer; const Error: Integer);
begin
  ListBox.Items.Add('Advertising ' + IntToStr(Index) + ' error 0x' +
    IntToHex(Error, 8));
end;

procedure TfmMain.DumpData(
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Str: string;
  c: Byte;
  i: Integer;
begin
  if Length(Data) > 0 then begin
    Str := '';
    c := 0;
    for i := 0 to Length(Data) - 1 do begin
      Str := Str + IntToHex(Data[i], 2);
      if c = 15 then begin
        lbFrames.Items.Add('    ' + Str);
        Str := '';
        c := 0;
      end else
        Inc(c);
    end;
    if Str <> '' then
      lbFrames.Items.Add('    ' + Str);
  end;
end;

procedure TfmMain.wclBluetoothLeBeaconWatcherAdvertisementReceived(
  Sender: TObject; const Address, Timestamp: Int64; const Rssi: Shortint;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('RAW ADVERTISEMENT FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

end.
