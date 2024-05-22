unit main;

{$MODE Delphi}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclBluetooth, ComCtrls;

type
  TfmMain = class(TForm)
    btOpen: TButton;
    btClose: TButton;
    btStart: TButton;
    btStop: TButton;
    btClear: TButton;
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
    cbMode: TCheckBox;
    laScanMode: TLabel;
    btDefaultScanParams: TButton;
    btDefInterval: TButton;
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
    procedure btDefaultScanParamsClick(Sender: TObject);
    procedure btDefIntervalClick(Sender: TObject);

  private
    BluetoothManager: TwclBluetoothManager;
    BluetoothLeAdvertiser: TwclBluetoothLeAdvertiser;
    BluetoothLeBeaconWatcher: TwclBluetoothLeBeaconWatcher;

    function GetRadio: TwclBluetoothRadio;

    function ConvertTime(const Timestamp: Int64): TDateTime;

    procedure DumpData(const Data: TwclBluetoothLeAdvertisementFrameRawData);

    procedure AddAdvertisement(Adv: TwclBluetoothLeAdvertisement);
    procedure EnableAdvertisements(const Enable: Boolean);

    procedure DefaultScanParams;

    procedure BluetoothManagerAfterOpen(Sender: TObject);
    procedure BluetoothManagerBeforeClose(Sender: TObject);
    procedure BluetoothManagerStatusChanged(Sender: TObject;
      const Radio: TwclBluetoothRadio);

    procedure BluetoothLeAdvertiserStarted(Sender: TObject);
    procedure BluetoothLeAdvertiserStopped(Sender: TObject);

    procedure BluetoothLeBeaconWatcherStarted(Sender: TObject);
    procedure BluetoothLeBeaconWatcherStopped(Sender: TObject);
    procedure BluetoothLeBeaconWatcherAdvertisementExtFrameInformation(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const AddressType: TwclBluetoothAddressType;
      const TxPower: SByte; const Flags: TwclBluetoothLeExtendedFrameFlags);
    procedure BluetoothLeBeaconWatcherAdvertisementFrameInformation(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Name: String;
      const PacketType: TwclBluetoothLeAdvertisementType;
      const Flags: TwclBluetoothLeAdvertisementFlags);
    procedure BluetoothLeBeaconWatcherAdvertisementRawFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const DataType: Byte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherAdvertisementReceived(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherAdvertisementService128DataFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherAdvertisementService16DataFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: Word;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherAdvertisementService32DataFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: Cardinal;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherAdvertisementServiceSol128Frame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: TGUID);
    procedure BluetoothLeBeaconWatcherAdvertisementServiceSol16Frame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: Word);
    procedure BluetoothLeBeaconWatcherAdvertisementServiceSol32Frame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: Cardinal);
    procedure BluetoothLeBeaconWatcherAdvertisementUuidFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: TGUID);
    procedure BluetoothLeBeaconWatcherAltBeaconFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const CompanyId: Word; const Major: Word; const Minor: Word;
      const Uuid: TGUID; const TxRssi: SByte; const Reserved: Byte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherEddystoneTlmFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const AdvCnt: Cardinal; const Batt: Word; const SecCnt: Cardinal;
      const Temp: Double; const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherEddystoneUidFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: Sbyte;
      const TxRssi: SByte; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherEddystoneUrlFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const TxRssi: SByte; const Url: String);
    procedure BluetoothLeBeaconWatcherManufacturerRawFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const CompanyId: Word;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherProximityBeaconFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const CompanyId: Word; const Major: Word; const Minor: Word;
      const Uuid: TGUID; const TxRssi: SByte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BluetoothLeBeaconWatcherAdvertisementTxPowerLevelFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const TxPower: SByte);
    procedure BluetoothLeBeaconWatcherAdvertisementAppearanceFrame(
      Sender: TObject; const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Appearance: Word);
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
  BluetoothLeAdvertiser.Stop;
  BluetoothLeAdvertiser.Free;

  BluetoothLeBeaconWatcher.Stop;
  BluetoothLeBeaconWatcher.Free;

  BluetoothManager.Close;
  BluetoothManager.Free;
end;

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := BluetoothManager.Open;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := BluetoothManager.Close;
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
    if cbMode.Checked then
      Mode := smActive
    else
      Mode := smPassive;
    Res := BluetoothLeBeaconWatcher.Start(Radio, Mode,
      StrToInt(edScanInterval.Text), StrToInt(edScanWindow.Text));
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := BluetoothLeBeaconWatcher.Stop;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.BluetoothManagerAfterOpen(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth Manager Opened');
end;

procedure TfmMain.BluetoothManagerBeforeClose(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth Manager Closed');
end;

procedure TfmMain.BluetoothManagerStatusChanged(Sender: TObject;
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
  ZeroMemory(@st, SizeOf(SYSTEMTIME));
  // Conver timestamp.
  li.QuadPart := Timestamp;
  ft.dwLowDateTime := li.LowPart;
  ft.dwHighDateTime := li.HighPart;
  FileTimeToLocalFileTime(ft, ft);
  FileTimeToSystemTime(ft, st);
  Result := SystemTimeToDateTime(st);
end;

procedure TfmMain.BluetoothLeBeaconWatcherStarted(Sender: TObject);
begin
  ListBox.Items.Add('Beacons Monitoring Started');
end;

procedure TfmMain.BluetoothLeBeaconWatcherStopped(Sender: TObject);
begin
  ListBox.Items.Add('Beacons Monitoring Stopped');
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
  BluetoothLeAdvertiser.Stop;

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
      Data := nil;
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

    if BluetoothLeAdvertiser.Count = 0 then
      ShowMessage('Select at least one advertisement type.')
    else begin
      BluetoothLeAdvertiser.UseExtendedAdvertisement := cbUseExtended.Checked;
      BluetoothLeAdvertiser.Anonymous := cbAnonymous.Checked;
      BluetoothLeAdvertiser.IncludeTxRssi := cbIncludeTxRssi.Checked;
      BluetoothLeAdvertiser.PreferredTxRssi := 10;

      Res := BluetoothLeAdvertiser.Start(Radio,
        StrToInt(edAdvInterval.Text));
      if Res <> WCL_E_SUCCESS then begin
        ListBox.Items.Add('Start advertiser failed: 0x' + IntToHex(Res, 8));
        BluetoothLeAdvertiser.Clear;
      end;
    end;
  end;
end;

procedure TfmMain.btStopAdvertisingClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := BluetoothLeAdvertiser.Stop;
  if Res <> WCL_E_SUCCESS then
    ListBox.Items.Add('Stop advertiser failed: 0x' + IntToHex(Res, 8));
end;

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := BluetoothManager.GetLeRadio(Radio);
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
  Res := BluetoothLeAdvertiser.Add(Adv);
  if Res <> WCL_E_SUCCESS then begin
    ListBox.Items.Add('Add advertisement failed: 0x' + IntToHex(Res, 8));
    Adv.Free;
  end;
end;

procedure TfmMain.BluetoothLeAdvertiserStarted(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth LE Advertising Started');

  EnableAdvertisements(False);
end;

procedure TfmMain.BluetoothLeAdvertiserStopped(Sender: TObject);
begin
  ListBox.Items.Add('Bluetooth LE Advertising Stopped');
  BluetoothLeAdvertiser.Clear;

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
  BluetoothManager := TwclBluetoothManager.Create(nil);
  BluetoothManager.AfterOpen := BluetoothManagerAfterOpen;
  BluetoothManager.BeforeClose := BluetoothManagerBeforeClose;
  BluetoothManager.OnStatusChanged := BluetoothManagerStatusChanged;

  BluetoothLeAdvertiser := TwclBluetoothLeAdvertiser.Create(nil);
  BluetoothLeAdvertiser.OnStarted := BluetoothLeAdvertiserStarted;
  BluetoothLeAdvertiser.OnStopped := BluetoothLeAdvertiserStopped;

  BluetoothLeBeaconWatcher := TwclBluetoothLeBeaconWatcher.Create(nil);
  BluetoothLeBeaconWatcher.OnStarted := BluetoothLeBeaconWatcherStarted;
  BluetoothLeBeaconWatcher.OnStopped := BluetoothLeBeaconWatcherStopped;
  BluetoothLeBeaconWatcher.OnAdvertisementExtFrameInformation := BluetoothLeBeaconWatcherAdvertisementExtFrameInformation;
  BluetoothLeBeaconWatcher.OnAdvertisementFrameInformation := BluetoothLeBeaconWatcherAdvertisementFrameInformation;
  BluetoothLeBeaconWatcher.OnAdvertisementRawFrame := BluetoothLeBeaconWatcherAdvertisementRawFrame;
  BluetoothLeBeaconWatcher.OnAdvertisementReceived := BluetoothLeBeaconWatcherAdvertisementReceived;
  BluetoothLeBeaconWatcher.OnAdvertisementService128DataFrame := BluetoothLeBeaconWatcherAdvertisementService128DataFrame;
  BluetoothLeBeaconWatcher.OnAdvertisementService16DataFrame := BluetoothLeBeaconWatcherAdvertisementService16DataFrame;
  BluetoothLeBeaconWatcher.OnAdvertisementService32DataFrame := BluetoothLeBeaconWatcherAdvertisementService32DataFrame;
  BluetoothLeBeaconWatcher.OnAdvertisementServiceSol128Frame := BluetoothLeBeaconWatcherAdvertisementServiceSol128Frame;
  BluetoothLeBeaconWatcher.OnAdvertisementServiceSol16Frame := BluetoothLeBeaconWatcherAdvertisementServiceSol16Frame;
  BluetoothLeBeaconWatcher.OnAdvertisementServiceSol32Frame := BluetoothLeBeaconWatcherAdvertisementServiceSol32Frame;
  BluetoothLeBeaconWatcher.OnAdvertisementUuidFrame := BluetoothLeBeaconWatcherAdvertisementUuidFrame;
  BluetoothLeBeaconWatcher.OnAltBeaconFrame := BluetoothLeBeaconWatcherAltBeaconFrame;
  BluetoothLeBeaconWatcher.OnEddystoneTlmFrame := BluetoothLeBeaconWatcherEddystoneTlmFrame;
  BluetoothLeBeaconWatcher.OnEddystoneUidFrame := BluetoothLeBeaconWatcherEddystoneUidFrame;
  BluetoothLeBeaconWatcher.OnEddystoneUrlFrame := BluetoothLeBeaconWatcherEddystoneUrlFrame;
  BluetoothLeBeaconWatcher.OnManufacturerRawFrame := BluetoothLeBeaconWatcherManufacturerRawFrame;
  BluetoothLeBeaconWatcher.OnProximityBeaconFrame := BluetoothLeBeaconWatcherProximityBeaconFrame;
  BluetoothLeBeaconWatcher.OnAdvertisementTxPowerLevelFrame := BluetoothLeBeaconWatcherAdvertisementTxPowerLevelFrame;
  BluetoothLeBeaconWatcher.OnAdvertisementAppearanceFrame := BluetoothLeBeaconWatcherAdvertisementAppearanceFrame;

  edAdvInterval.Text := IntToStr(WCL_BLE_DEFAULT_ADVERTISING_INTERVAL);

  DefaultScanParams;
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

procedure TfmMain.btDefaultScanParamsClick(Sender: TObject);
begin
  DefaultScanParams;
end;

procedure TfmMain.DefaultScanParams;
begin
  cbMode.Checked := True;
  edScanInterval.Text := IntToStr(WCL_BLE_DEFAULT_SCAN_INTERVAL);
  edScanWindow.Text := IntToStr(WCL_BLE_DEFAULT_SCAN_WINDOW);
end;

procedure TfmMain.btDefIntervalClick(Sender: TObject);
begin
  edAdvInterval.Text := IntToStr(WCL_BLE_DEFAULT_ADVERTISING_INTERVAL);
end;

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementExtFrameInformation(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const AddressType: TwclBluetoothAddressType;
  const TxPower: SByte; const Flags: TwclBluetoothLeExtendedFrameFlags);
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementFrameInformation(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Name: String;
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementRawFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const DataType: Byte;
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementReceived(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  lbFrames.Items.Add('RAW ADVERTISEMENT FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  DumpData(Data);

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementService128DataFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: TGUID;
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementService16DataFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: Word;
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementService32DataFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: Cardinal;
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementServiceSol128Frame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: TGUID);
begin
  lbFrames.Items.Add('128 UUID SOL SERVICE');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementServiceSol16Frame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: Word);
begin
  lbFrames.Items.Add('16 UUID SOL SERVICE');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + IntToHex(Uuid, 4));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementServiceSol32Frame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: Cardinal);
begin
  lbFrames.Items.Add('32 UUID SOL SERVICE');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + IntToHex(Uuid, 8));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementUuidFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: TGUID);
begin
  lbFrames.Items.Add('UUID FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));
  lbFrames.Items.Add('  UUID: ' + GUIDToString(Uuid));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.BluetoothLeBeaconWatcherAltBeaconFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const CompanyId: Word; const Major: Word;
  const Minor: Word; const Uuid: TGUID; const TxRssi: SByte;
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

procedure TfmMain.BluetoothLeBeaconWatcherEddystoneTlmFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const AdvCnt: Cardinal; const Batt: Word;
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

procedure TfmMain.BluetoothLeBeaconWatcherEddystoneUidFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const TxRssi: SByte; const Uuid: TGUID;
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

procedure TfmMain.BluetoothLeBeaconWatcherEddystoneUrlFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const TxRssi: SByte; const Url: String);
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

procedure TfmMain.BluetoothLeBeaconWatcherManufacturerRawFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const CompanyId: Word;
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

procedure TfmMain.BluetoothLeBeaconWatcherProximityBeaconFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const CompanyId: Word; const Major: Word;
  const Minor: Word; const Uuid: TGUID; const TxRssi: SByte;
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

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementTxPowerLevelFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const TxPower: SByte);
begin
  lbFrames.Items.Add('TX POWER FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  TX Power: ' + IntToStr(TxPower));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

procedure TfmMain.BluetoothLeBeaconWatcherAdvertisementAppearanceFrame(
  Sender: TObject; const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Appearance: Word);
begin
  lbFrames.Items.Add('APPEARANCE FRAME');

  lbFrames.Items.Add('  Address: ' + IntToHex(Address, 12));
  lbFrames.Items.Add('  Timestamp: ' + DateTimeToStr(ConvertTime(Timestamp)));
  lbFrames.Items.Add('  RSSI: ' + IntToStr(Rssi));

  lbFrames.Items.Add('  Appearance: ' + IntToHex(Appearance, 4));

  lbFrames.Items.Add('-------------------------------------------------------');
end;

end.
