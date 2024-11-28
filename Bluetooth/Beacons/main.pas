unit main;

{$MODE Delphi}
{$WARN 5057 off : Local variable "$1" does not seem to be initialized}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclBluetooth, ComCtrls, wclDriCommon;

type
  TAdvertisementFrame = (
    afAppearance,
    afExtInformation,
    afInformation,
    afRaw,
    afDetails,
    afService16Data,
    afService32Data,
    afService128Data,
    afSol16,
    afSol32,
    afSol128,
    afTxPower,
    afUuid,
    afAltBeacon,
    afEddystoneTlm,
    afEddystoneUid,
    afEddystoneUrl,
    afManufacturerRaw,
    afMicrosoftCdpBeacon,
    afAppleAirdrop,
    afAppleAirplaySource,
    afAppleAirplayTarget,
    afAppleAirprint,
    afAppleHomeKit,
    afAppleiBeacon,
    afAppleNearbyAction,
    afAppleNearbyInfo,
    afAppleProximityPairing,
    afAppleUnknown,
    afAppleFindMy,
    afAppleHandoff,
    afAppleHeySiri,
    afAppleMagicSwitch,
    afAppleTetheringSource,
    afAppleTetheringTarget,
    afDriAsd,
    afUnknown
  );

  TFrameStorage = class
  private
    FAddress: Int64;
    FFrame: TAdvertisementFrame;
    FTimestamp: Int64;
    FRssi: SByte;

  public
    constructor Create(const Frame: TAdvertisementFrame; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte);

    property Address: Int64 read FAddress;
    property Frame: TAdvertisementFrame read FFrame;
    property Timestamp: Int64 read FTimestamp;
    property Rssi: SByte read FRssi;
  end;

  TGuidFrameStorage = class(TFrameStorage)
  private
    FUuid: TGUID;

  public
    constructor Create(const Frame: TAdvertisementFrame; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte; const Uuid: TGUID);

    property Uuid: TGUID read FUuid;
  end;

  TDataFrameStorage = class(TFrameStorage)
  private
    FData: TwclBluetoothLeAdvertisementFrameRawData;

  public
    constructor Create(const Frame: TAdvertisementFrame; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);

    property Data: TwclBluetoothLeAdvertisementFrameRawData read FData;
  end;

  TGuidDataFrameStorage = class(TDataFrameStorage)
  private
    FUuid: TGUID;

  public
    constructor Create(const Frame: TAdvertisementFrame; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);

    property Uuid: TGUID read FUuid;
  end;

  TAppearanceFrame = class(TFrameStorage)
  private
    FAppearance: Word;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Appearance: Word);

    property Appearance: Word read FAppearance;
  end;

  TExtInformationFrame = class(TFrameStorage)
  private
    FAddressType: TwclBluetoothAddressType;
    FFlags: TwclBluetoothLeExtendedFrameFlags;
    FTxPower: SByte;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const AddressType: TwclBluetoothAddressType;
      const Flags: TwclBluetoothLeExtendedFrameFlags; const TxPower: SByte);

    property AddressType: TwclBluetoothAddressType read FAddressType;
    property Flags: TwclBluetoothLeExtendedFrameFlags read FFlags;
    property TxPower: SByte read FTxPower;
  end;

  TInformationFrame = class(TFrameStorage)
  private
    FFlags: TwclBluetoothLeAdvertisementFlags;
    FName: string;
    FPacketType: TwclBluetoothLeAdvertisementType;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Flags: TwclBluetoothLeAdvertisementFlags;
      const Name: string; const PacketType: TwclBluetoothLeAdvertisementType);

    property Flags: TwclBluetoothLeAdvertisementFlags read FFlags;
    property Name: string read FName;
    property PacketType: TwclBluetoothLeAdvertisementType read FPacketType;
  end;

  TRawFrame = class(TDataFrameStorage)
  private
    FDataType: Byte;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const DataType: Byte);

    property DataType: Byte read FDataType;
  end;

  TDetailsFrame = class(TDataFrameStorage)
  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData);
  end;

  TService16DataFrame = class(TDataFrameStorage)
  private
    FUuid: Word;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const Uuid: Word);

    property Uuid: Word read FUuid;
  end;

  TService32DataFrame = class(TDataFrameStorage)
  private
    FUuid: Cardinal;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const Uuid: Cardinal);

    property Uuid: Cardinal read FUuid;
  end;

  TService128DataFrame = class(TGuidDataFrameStorage)
  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
  end;

  TSol16Frame = class(TFrameStorage)
  private
    FUuid: Word;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: Word);

    property Uuid: Word read FUuid;
  end;

  TSol32Frame = class(TFrameStorage)
  private
    FUuid: Cardinal;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: Cardinal);

    property Uuid: Cardinal read FUuid;
  end;

  TSol128Frame = class(TGuidFrameStorage)
  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: TGUID);
  end;

  TTxPowerFrame = class(TFrameStorage)
  private
    FTxPower: SByte;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const TxPower: SByte);

    property TxPower: SByte read FTxPower;
  end;

  TUuidFrame = class(TGuidFrameStorage)
  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Uuid: TGUID);
  end;

  TBeaconFrame = class(TGuidDataFrameStorage)
  private
    FCompanyId: Word;
    FMajor: Word;
    FMinor: Word;
    FTxRssi: SByte;

  public
    constructor Create(const Frame: TAdvertisementFrame; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const Uuid: TGUID; const CompanyId: Word; const Major: Word;
      const Minor: Word; const TxRssi: SByte);

    property CompanyId: Word read FCompanyId;
    property Major: Word read FMajor;
    property Minor: Word read FMinor;
    property TxRssi: SByte read FTxRssi;
  end;

  TAltBeaconFrame = class(TBeaconFrame)
  private
    FReserved: Byte;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const Uuid: TGUID; const CompanyId: Word; const Major: Word;
      const Minor: Word; const TxRssi: SByte; const Reserved: Byte);

    property Reserved: Byte read FReserved;
  end;

  TMicrosoftCdpBeaconFrame = class(TFrameStorage)
  private
    FAddressAsDeviceId: Boolean;
    FDeviceType: TwclBluetoothLeCdpBeaconDeviceType;
    FExtendedDeviceStatus: TwclBluetoothLeCdpBeaconExtendedDeviceStatuses;
    FHash: TwclBluetoothLeCdpBeaconHash;
    FSalt: TwclBluetoothLeCdpBeaconSalt;
    FScenarioType: TwclBluetoothLeCdpBeaconScenarioType;
    FShareNearBy: Boolean;
    FSubVersion: Byte;
    FVersion: Byte;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const AddressAsDeviceId: Boolean;
      const DeviceType: TwclBluetoothLeCdpBeaconDeviceType;
      const ExtendedDeviceStatus: TwclBluetoothLeCdpBeaconExtendedDeviceStatuses;
      const Hash: TwclBluetoothLeCdpBeaconHash;
      const Salt: TwclBluetoothLeCdpBeaconSalt;
      const ScenarioType: TwclBluetoothLeCdpBeaconScenarioType;
      const ShareNearBy: Boolean; const SubVersion: Byte; const Version: Byte);

    property AddressAsDeviceId: Boolean read FAddressAsDeviceId;
    property DeviceType: TwclBluetoothLeCdpBeaconDeviceType read FDeviceType;
    property ExtendedDeviceStatus: TwclBluetoothLeCdpBeaconExtendedDeviceStatuses
      read FExtendedDeviceStatus;
    property Hash: TwclBluetoothLeCdpBeaconHash read FHash;
    property Salt: TwclBluetoothLeCdpBeaconSalt read FSalt;
    property ScenarioType: TwclBluetoothLeCdpBeaconScenarioType
      read FScenarioType;
    property ShareNearBy: Boolean read FShareNearBy;
    property SubVersion: Byte read FSubVersion;
    property Version: Byte read FVersion;
  end;

  TAppleFrame = class(TFrameStorage)
  public
    constructor Create(const Frame: TAdvertisementFrame;
      const Info: TwclBluetoothLeAdvertisementInfo);
  end;

  TAppleAirdropFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleAirdropFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirdropFrameData);

    property Data: TwclBluetoothLeAppleAirdropFrameData read FData;
  end;

  TAppleAirplaySourceFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleAirplaySourceFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirplaySourceFrameData);

    property Data: TwclBluetoothLeAppleAirplaySourceFrameData read FData;
  end;

  TAppleAirplayTargetFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleAirplayTargetFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirplayTargetFrameData);

    property Data: TwclBluetoothLeAppleAirplayTargetFrameData read FData;
  end;

  TAppleAirprintFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleAirprintFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirprintFrameData);

    property Data: TwclBluetoothLeAppleAirprintFrameData read FData;
  end;

  TAppleHomeKitFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleHomeKitFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleHomeKitFrameData);

    property Data: TwclBluetoothLeAppleHomeKitFrameData read FData;
  end;

  TAppleiBeaconFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleiBeaconFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleiBeaconFrameData);

    property Data: TwclBluetoothLeAppleiBeaconFrameData read FData;
  end;

  TAppleNearbyActionFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleNearbyActionFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleNearbyActionFrameData);

    property Data: TwclBluetoothLeAppleNearbyActionFrameData read FData;
  end;

  TAppleNearbyInfoFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleNearbyInfoFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleNearbyInfoFrameData);

    property Data: TwclBluetoothLeAppleNearbyInfoFrameData read FData;
  end;

  TAppleProximityPairingFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleProximityPairingFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleProximityPairingFrameData);

    property Data: TwclBluetoothLeAppleProximityPairingFrameData read FData;
  end;

  TAppleUnknownFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleUnknownFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleUnknownFrameData);

    property Data: TwclBluetoothLeAppleUnknownFrameData read FData;
  end;

  TAppleFindMyFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleFindMyFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleFindMyFrameData);

    property Data: TwclBluetoothLeAppleFindMyFrameData read FData;
  end;

  TAppleHandoffFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleHandoffFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleHandoffFrameData);

    property Data: TwclBluetoothLeAppleHandoffFrameData read FData;
  end;

  TAppleHeySiriFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleHeySiriFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleHeySiriFrameData);

    property Data: TwclBluetoothLeAppleHeySiriFrameData read FData;
  end;

  TAppleMagicSwitchFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleMagicSwitchFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleMagicSwitchFrameData);

    property Data: TwclBluetoothLeAppleMagicSwitchFrameData read FData;
  end;

  TAppleTetheringSourceFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleTetheringSourceFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleTetheringSourceFrameData);

    property Data: TwclBluetoothLeAppleTetheringSourceFrameData read FData;
  end;

  TAppleTetheringTargetFrame = class(TAppleFrame)
  private
    FData: TwclBluetoothLeAppleTetheringTargetFrameData;

  public
    constructor Create(const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleTetheringTargetFrameData);

    property Data: TwclBluetoothLeAppleTetheringTargetFrameData read FData;
  end;

  TEddystoneTlmFrame = class(TDataFrameStorage)
  private
    FAdvCnt: Cardinal;
    FBatt: Word;
    FSecCnt: Cardinal;
    FTemp: Double;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const AdvCnt: Cardinal; const Batt: Word; const SecCnt: Cardinal;
      const Temp: Double);

    property AdvCnt: Cardinal read FAdvCnt;
    property Batt: Word read FBatt;
    property SecCnt: Cardinal read FSecCnt;
    property Temp: Double read FTemp;
  end;

  TEddystoneUidFrame = class(TGuidDataFrameStorage)
  private
    FTxRssi: SByte;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
      const Uuid: TGUID; const TxRssi: SByte);

    property TxRssi: SByte read FTxRssi;
  end;

  TEddystoneUrlFrame = class(TFrameStorage)
  private
    FTxRssi: SByte;
    FUrl: string;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const TxRssi: SByte; const Url: string);

    property TxRssi: SByte read FTxRssi;
    property Url: string read FUrl;
  end;

  TManufacturerFrame = class(TDataFrameStorage)
  private
    FCompanyId: Word;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const CompanyId: Word;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);

    property CompanyId: Word read FCompanyId;
  end;

  TDriAsdFrame = class(TFrameStorage)
  private
    FRaw: TwclDriRawData;

  public
    constructor Create(const Address: Int64; const Timestamp: Int64;
      const Rssi: SByte; const Raw: TwclDriRawData);

    property Raw: TwclDriRawData read FRaw;
  end;

  TfmMain = class(TForm)
    btWatcherStart: TButton;
    btWatcherStop: TButton;
    lbLog: TListBox;
    btClearLog: TButton;
    btAdvertiserStart: TButton;
    btAdvertiserStop: TButton;
    laWatcherScanInterval: TLabel;
    edWatcherScanInterval: TEdit;
    laWatcherScanWindow: TLabel;
    edWatcherScanWindow: TEdit;
    laAdvertiserInterval: TLabel;
    edAdvertiserInterval: TEdit;
    cbAdvertiserBeacon: TCheckBox;
    cbAdvertiserProximityBeacon: TCheckBox;
    cbAdvertiserAltBeacon: TCheckBox;
    cbAdvertiserEddystoneUid: TCheckBox;
    cbAdvertiserEddystoneUrl: TCheckBox;
    cbAdvertiser128SolUuid: TCheckBox;
    cbAdvertiserManufacturer: TCheckBox;
    cbAdvertiser16Uuid: TCheckBox;
    cbAdvertiser32Uuid: TCheckBox;
    cbAdvertiser128Uuid: TCheckBox;
    cbAdvertiser16UuidData: TCheckBox;
    cbAdvertiser32UuidData: TCheckBox;
    cbAdvertiser128UuidData: TCheckBox;
    cbAdvertiserCustom: TCheckBox;
    cbAdvertiserExtended: TCheckBox;
    cbAdvertiserAnonymous: TCheckBox;
    cbAdvertiserTxRssi: TCheckBox;
    laWatcherScanMode: TLabel;
    btWatcherDefault: TButton;
    btAdvertiserDefault: TButton;
    cbWatcherScanMode: TComboBox;
    laBeaconWatcher: TLabel;
    cbWatcherEnableExtended: TCheckBox;
    lvFrameDetails: TListView;
    laLeAdvertiser: TLabel;
    laLog: TLabel;
    cbAutoScroll: TCheckBox;
    lvDevices: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btClearLogClick(Sender: TObject);
    procedure btWatcherDefaultClick(Sender: TObject);
    procedure btAdvertiserDefaultClick(Sender: TObject);
    procedure cbAdvertiserExtendedClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure btWatcherStartClick(Sender: TObject);
    procedure btWatcherStopClick(Sender: TObject);
    procedure lvDevicesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btAdvertiserStartClick(Sender: TObject);
    procedure btAdvertiserStopClick(Sender: TObject);

  private
    BluetoothManager: TwclBluetoothManager;
    BeaconWatcher: TwclBluetoothLeBeaconWatcher;
    LeAdvertiser: TwclBluetoothLeAdvertiser;

    procedure BluetoothManagerAfterOpen(Sender: TObject);
    procedure BluetoothManagerBeforeClose(Sender: TObject);
    procedure BluetoothManagerClosed(Sender: TObject);

    procedure BeaconWatcherStarted(Sender: TObject);
    procedure BeaconWatcherStopped(Sender: TObject);
    procedure BeaconWatcherAdvertisementAppearanceFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Appearance: Word);
    procedure BeaconWatcherAdvertisementExtFrameInformation(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const AddressType: TwclBluetoothAddressType; const TxPower: SByte;
      const Flags: TwclBluetoothLeExtendedFrameFlags);
    procedure BeaconWatcherAdvertisementFrameInformation(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Name: String; const PacketType: TwclBluetoothLeAdvertisementType;
      const Flags: TwclBluetoothLeAdvertisementFlags);
    procedure BeaconWatcherAdvertisementRawFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const DataType: Byte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherAdvertisementReceived(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherAdvertisementService128DataFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: TGUID; const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherAdvertisementService16DataFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: Word; const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherAdvertisementService32DataFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: Cardinal;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherAdvertisementServiceSol128Frame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: TGUID);
    procedure BeaconWatcherAdvertisementServiceSol16Frame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: Word);
    procedure BeaconWatcherAdvertisementServiceSol32Frame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: Cardinal);
    procedure BeaconWatcherAdvertisementTxPowerLevelFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const TxPower: SByte);
    procedure BeaconWatcherAdvertisementUuidFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const Uuid: TGUID);
    procedure BeaconWatcherAltBeaconFrame(Sender: TObject; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte; const CompanyId: Word;
      const Major: Word; const Minor: Word; const Uuid: TGUID;
      const TxRssi: SByte; const Reserved: Byte;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherEddystoneTlmFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const AdvCnt: Cardinal; const Batt: Word; const SecCnt: Cardinal;
      const Temp: Double; const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherEddystoneUidFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const TxRssi: SByte; const Uuid: TGUID;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherEddystoneUrlFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const TxRssi: SByte; const Url: String);
    procedure BeaconWatcherManufacturerRawFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const CompanyId: Word;
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure BeaconWatcherMicrosoftCdpBeaconFrame(Sender: TObject;
      const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
      const ScenarioType: TwclBluetoothLeCdpBeaconScenarioType;
      const Version: Byte; const DeviceType: TwclBluetoothLeCdpBeaconDeviceType;
      const SubVersion: Byte; const ShareNearBy: Boolean;
      const AddressAsDeviceId: Boolean;
      const ExtendedDeviceStatus: TwclBluetoothLeCdpBeaconExtendedDeviceStatuses;
      const Salt: TwclBluetoothLeCdpBeaconSalt;
      const Hash: TwclBluetoothLeCdpBeaconHash);
    procedure BeaconWatcherDriAsdMessage(Sender: TObject; const Address: Int64;
      const Timestamp: Int64; const Rssi: SByte; const Raw: TwclDriRawData);
    procedure BeaconWatcherAppleiBeaconFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleiBeaconFrameData);
    procedure BeaconWatcherAppleNearbyActionFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleNearbyActionFrameData);
    procedure BeaconWatcherAppleNearbyInfoFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleNearbyInfoFrameData);
    procedure BeaconWatcherAppleHomeKitFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleHomeKitFrameData);
    procedure BeaconWatcherAppleUnknownFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleUnknownFrameData);
    procedure BeaconWatcherAppleAirplaySourceFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirplaySourceFrameData);
    procedure BeaconWatcherAppleAirplayTargetFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirplayTargetFrameData);
    procedure BeaconWatcherAppleAirdropFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirdropFrameData);
    procedure BeaconWatcherAppleAirprintFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleAirprintFrameData);
    procedure BeaconWatcherAppleProximityPairingFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleProximityPairingFrameData);
    procedure BeaconWatcherAppleFindMyFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleFindMyFrameData);
    procedure BeaconWatcherAppleHandoffFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleHandoffFrameData);
    procedure BeaconWatcherAppleHeySiriFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleHeySiriFrameData);
    procedure BeaconWatcherAppleMagicSwitchFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleMagicSwitchFrameData);
    procedure BeaconWatcherAppleTetheringSourceFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleTetheringSourceFrameData);
    procedure BeaconWatcherAppleTetheringTargetFrame(Sender: TObject;
      const Info: TwclBluetoothLeAdvertisementInfo;
      const Data: TwclBluetoothLeAppleTetheringTargetFrameData);

    procedure LeAdvertiserStarted(Sender: TObject);
    procedure LeAdvertiserStopped(Sender: TObject);

    procedure AdvertiserDefaults;
    procedure WatcherDefaults;

    procedure AdvertiserEnableControls(const Stopped: Boolean);
    procedure WatcherEnableControls(const Stopped: Boolean);

    procedure Trace(const Msg: string); overload;
    procedure Trace(const Msg: string; const Res: Integer); overload;

    function GetRadio: TwclBluetoothRadio;

    function AddDevice(const Address: Int64): TListItem;
    procedure AddFrame(const Frame: TFrameStorage);

    function ConvertTime(const Timestamp: Int64): TDateTime;

    procedure ShowData(const Name: string; const Value: string);
    procedure ShowFrameBaseData(const Frame: TFrameStorage);
    procedure ShowFrameRawData(
      const Data: TwclBluetoothLeAdvertisementFrameRawData);
    procedure ShowDriFrameRawData(const Raw: TwclDriRawData);

    procedure ShowAppearanceFrame(const Frame: TAppearanceFrame);
    procedure ShowExtInformationFrame(const Frame: TExtInformationFrame);
    procedure ShowInformationFrame(const Frame: TInformationFrame);
    procedure ShowRawFrame(const Frame: TRawFrame);
    procedure ShowDetailsFrame(const Frame: TDetailsFrame);
    procedure ShowService16DataFrame(const Frame: TService16DataFrame);
    procedure ShowService32DataFrame(const Frame: TService32DataFrame);
    procedure ShowService128DataFrame(const Frame: TService128DataFrame);
    procedure ShowSol16Frame(const Frame: TSol16Frame);
    procedure ShowSol32Frame(const Frame: TSol32Frame);
    procedure ShowSol128Frame(const Frame: TSol128Frame);
    procedure ShowTxPowerFrame(const Frame: TTxPowerFrame);
    procedure ShowUuidFrame(const Frame: TUuidFrame);
    procedure ShowAltBeaconFrame(const Frame: TAltBeaconFrame);
    procedure ShowEddystoneTlmFrame(const Frame: TEddystoneTlmFrame);
    procedure ShowEddystoneUidFrame(const Frame: TEddystoneUidFrame);
    procedure ShowEddystoneUrlFrame(const Frame: TEddystoneUrlFrame);
    procedure ShowManufacturerFrame(const Frame: TManufacturerFrame);
    procedure ShowMicrosoftCdpBeaconFrame(const Frame: TMicrosoftCdpBeaconFrame);
    procedure ShowAppleAirdropFrame(const Frame: TAppleAirdropFrame);
    procedure ShowAppleAirplaySourceFrame(const Frame: TAppleAirplaySourceFrame);
    procedure ShowAppleAirplayTargetFrame(const Frame: TAppleAirplayTargetFrame);
    procedure ShowAppleAirprintFrame(const Frame: TAppleAirprintFrame);
    procedure ShowAppleHomeKitFrame(const Frame: TAppleHomeKitFrame);
    procedure ShowAppleiBeaconFrame(const Frame: TAppleiBeaconFrame);
    procedure ShowAppleNearbyActionFrame(const Frame: TAppleNearbyActionFrame);
    procedure ShowAppleNearbyInfoFrame(const Frame: TAppleNearbyInfoFrame);
    procedure ShowAppleProximityPairingFrame(const Frame: TAppleProximityPairingFrame);
    procedure ShowAppleUnknownFrame(const Frame: TAppleUnknownFrame);
    procedure ShowAppleFindMyFrame(const Frame: TAppleFindMyFrame);
    procedure ShowAppleHandoffFrame(const Frame: TAppleHandoffFrame);
    procedure ShowAppleHeySiriFrame(const Frame: TAppleHeySiriFrame);
    procedure ShowAppleMagicSwitchFrame(const Frame: TAppleMagicSwitchFrame);
    procedure ShowAppleTetheringSourceFrame(const Frame: TAppleTetheringSourceFrame);
    procedure ShowAppleTetheringTargetFrame(const Frame: TAppleTetheringTargetFrame);
    procedure ShowFrameData(const Frame: TFrameStorage);
    procedure ShowDriAsdFrame(const Frame: TDriAsdFrame);

    procedure AddAdvertisement(const Adv: TwclBluetoothLeAdvertisement);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils, Dialogs, Windows, wclUUIDs;

{$R *.lfm}

{ TFrameStorage }

constructor TFrameStorage.Create(const Frame: TAdvertisementFrame;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte);
begin
  FAddress := Address;
  FFrame := Frame;
  FTimestamp := Timestamp;
  FRssi := Rssi;
end;

{ TGuidFrameStorage }

constructor TGuidFrameStorage.Create(const Frame: TAdvertisementFrame;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: TGUID);
begin
  inherited Create(Frame, Address, Timestamp, Rssi);

  FUuid := Uuid;
end;

{ TDataFrameStorage }

constructor TDataFrameStorage.Create(const Frame: TAdvertisementFrame;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  inherited Create(Frame, Address, Timestamp, Rssi);

  FData := Data;
end;

{ TGuidDataFrameStorage }

constructor TGuidDataFrameStorage.Create(const Frame: TAdvertisementFrame;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: TGUID; const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  inherited Create(Frame, Address, Timestamp, Rssi, Data);

  FUuid := Uuid;
end;

{ TAppearanceFrame }

constructor TAppearanceFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte; const Appearance: Word);
begin
  inherited Create(afAppearance, Address, Timestamp, Rssi);

  FAppearance := Appearance;
end;

{ TExtInformationFrame }

constructor TExtInformationFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte;
  const AddressType: TwclBluetoothAddressType;
  const Flags: TwclBluetoothLeExtendedFrameFlags; const TxPower: SByte);
begin
  inherited Create(afExtInformation, Address, Timestamp, Rssi);

  FAddressType := AddressType;
  FFlags := Flags;
  FTxPower := TxPower;
end;

{ TInformationFrame }

constructor TInformationFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte;
  const Flags: TwclBluetoothLeAdvertisementFlags; const Name: string;
  const PacketType: TwclBluetoothLeAdvertisementType);
begin
  inherited Create(afInformation, Address, Timestamp, Rssi);

  FFlags := Flags;
  FName := Name;
  FPacketType := PacketType;
end;

{ TRawFrame }

constructor TRawFrame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
  const DataType: Byte);
begin
  inherited Create(afRaw, Address, Timestamp, Rssi, Data);

  FDataType := DataType;
end;

{ TDetailsFrame }

constructor TDetailsFrame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  inherited Create(afDetails, Address, Timestamp, Rssi, Data);
end;

{ TService16DataFrame }

constructor TService16DataFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData; const Uuid: Word);
begin
  inherited Create(afService16Data, Address, Timestamp, Rssi, Data);

  FUuid := Uuid;
end;

{ TService32DataFrame }

constructor TService32DataFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData; const Uuid: Cardinal);
begin
  inherited Create(afService32Data, Address, Timestamp, Rssi, Data);

  FUuid := Uuid;
end;

{ TService128DataFrame }

constructor TService128DataFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte; const Uuid: TGUID;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  inherited Create(afService128Data, Address, Timestamp, Rssi, Uuid, Data);
end;

{ TSol16Frame }

constructor TSol16Frame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: Word);
begin
  inherited Create(afSol16, Address, Timestamp, Rssi);

  FUuid := Uuid;
end;

{ TSol32Frame }

constructor TSol32Frame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: Cardinal);
begin
  inherited Create(afSol32, Address, Timestamp, Rssi);

  FUuid := Uuid;
end;

{ TSol128Frame }

constructor TSol128Frame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: TGUID);
begin
  inherited Create(afSol128, Address, Timestamp, Rssi, Uuid);
end;

{ TTxPowerFrame }

constructor TTxPowerFrame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const TxPower: SByte);
begin
  inherited Create(afTxPower, Address, Timestamp, Rssi);

  FTxPower := TxPower;
end;

{ TUuidFrame }

constructor TUuidFrame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Uuid: TGUID);
begin
  inherited Create(afUuid, Address, Timestamp, Rssi, Uuid);
end;

{ TBeaconFrame }

constructor TBeaconFrame.Create(const Frame: TAdvertisementFrame;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData; const Uuid: TGUID;
  const CompanyId: Word; const Major: Word; const Minor: Word;
  const TxRssi: SByte);
begin
  inherited Create(Frame, Address, Timestamp, Rssi, Uuid, Data);

  FCompanyId := CompanyId;
  FMajor := Major;
  FMinor := Minor;
  FTxRssi := TxRssi;
end;

{ TAltBeaconFrame }

constructor TAltBeaconFrame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Data: TwclBluetoothLeAdvertisementFrameRawData;
  const Uuid: TGUID; const CompanyId: Word; const Major: Word;
  const Minor: Word; const TxRssi: SByte; const Reserved: Byte);
begin
  inherited Create(afAltBeacon, Address, Timestamp, Rssi, Data, Uuid, CompanyId,
    Major, Minor, TxRssi);

  FReserved := Reserved;
end;

{ TMicrosoftCdpBeaconFrame }

constructor TMicrosoftCdpBeaconFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte; const AddressAsDeviceId: Boolean;
  const DeviceType: TwclBluetoothLeCdpBeaconDeviceType;
  const ExtendedDeviceStatus: TwclBluetoothLeCdpBeaconExtendedDeviceStatuses;
  const Hash: TwclBluetoothLeCdpBeaconHash;
  const Salt: TwclBluetoothLeCdpBeaconSalt;
  const ScenarioType: TwclBluetoothLeCdpBeaconScenarioType;
  const ShareNearBy: Boolean; const SubVersion: Byte; const Version: Byte);
begin
  inherited Create(afMicrosoftCdpBeacon, Address, Timestamp, Rssi);

  FAddressAsDeviceId := AddressAsDeviceId;
  FDeviceType := DeviceType;
  FExtendedDeviceStatus := ExtendedDeviceStatus;
  FHash := Hash;
  FSalt := Salt;
  FScenarioType := ScenarioType;
  FShareNearBy := ShareNearBy;
  FSubVersion  := SubVersion;
  FVersion := Version;
end;

{ TAppleFrame }

constructor TAppleFrame.Create(const Frame: TAdvertisementFrame;
  const Info: TwclBluetoothLeAdvertisementInfo);
begin
  inherited Create(Frame, Info.Address, Info.Timestamp, Info.Rssi);
end;

{ TAppleAirdropFrame }

constructor TAppleAirdropFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirdropFrameData);
begin
  inherited Create(afAppleAirdrop, Info);

  FData := Data;
end;

{ TAppleAirplaySourceFrame }

constructor TAppleAirplaySourceFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirplaySourceFrameData);
begin
  inherited Create(afAppleAirplaySource, Info);

  FData := Data;
end;

{ TAppleAirplayTargetFrame }

constructor TAppleAirplayTargetFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirplayTargetFrameData);
begin
  inherited Create(afAppleAirplayTarget, Info);

  FData := Data;
end;

{ TAppleAirprintFrame }

constructor TAppleAirprintFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirprintFrameData);
begin
  inherited Create(afAppleAirprint, Info);

  FData := Data;
end;

{ TAppleHomeKitFrame }

constructor TAppleHomeKitFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleHomeKitFrameData);
begin
  inherited Create(afAppleHomeKit, Info);

  FData := Data;
end;

{ TAppleiBeaconFrame }

constructor TAppleiBeaconFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleiBeaconFrameData);
begin
  inherited Create(afAppleiBeacon, Info);

  FData := Data;
end;

{ TAppleNearbyActionFrame }

constructor TAppleNearbyActionFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleNearbyActionFrameData);
begin
  inherited Create(afAppleNearbyAction, Info);

  FData := Data;
end;

{ TAppleNearbyInfoFrame }

constructor TAppleNearbyInfoFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleNearbyInfoFrameData);
begin
  inherited Create(afAppleNearbyInfo, Info);

  FData := Data;
end;

{ TAppleProximityPairingFrame }

constructor TAppleProximityPairingFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleProximityPairingFrameData);
begin
  inherited Create(afAppleProximityPairing, Info);

  FData := Data;
end;

{ TAppleUnknownFrame }

constructor TAppleUnknownFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleUnknownFrameData);
begin
  inherited Create(afAppleUnknown, Info);

  FData := Data;
end;

{ TAppleFindMyFrame }

constructor TAppleFindMyFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleFindMyFrameData);
begin
  inherited Create(afAppleFindMy, Info);

  FData := Data;
end;

{ TAppleHandoffFrame }

constructor TAppleHandoffFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleHandoffFrameData);
begin
  inherited Create(afAppleHandoff, Info);

  FData := Data;
end;

{ TAppleHeySiriFrame }

constructor TAppleHeySiriFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleHeySiriFrameData);
begin
  inherited Create(afAppleHeySiri, Info);

  FData := Data;
end;

{ TAppleMagicSwitchFrame }

constructor TAppleMagicSwitchFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleMagicSwitchFrameData);
begin
  inherited Create(afAppleMagicSwitch, Info);

  FData := Data;
end;

{ TAppleTetheringSourceFrame }

constructor TAppleTetheringSourceFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleTetheringSourceFrameData);
begin
  inherited Create(afAppleTetheringSource, Info);

  FData := Data;
end;

{ TAppleTetheringTargetFrame }

constructor TAppleTetheringTargetFrame.Create(
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleTetheringTargetFrameData);
begin
  inherited Create(afAppleTetheringTarget, Info);

  FData := Data;
end;

{ TEddystoneTlmFrame }

constructor TEddystoneTlmFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData; const AdvCnt: Cardinal;
  const Batt: Word; const SecCnt: Cardinal; const Temp: Double);
begin
  inherited Create(afEddystoneTlm, Address, Timestamp, Rssi, Data);

  FAdvCnt := AdvCnt;
  FBatt := Batt;
  FSecCnt := SecCnt;
  FTemp := Temp;
end;

{ TEddystoneUidFrame }

constructor TEddystoneUidFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData; const Uuid: TGUID;
  const TxRssi: SByte);
begin
  inherited Create(afEddystoneUid, Address, Timestamp, Rssi, Uuid, Data);

  FTxRssi := TxRssi;
end;

{ TEddystoneUrlFrame }

constructor TEddystoneUrlFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte; const TxRssi: SByte;
  const Url: string);
begin
  inherited Create(afEddystoneUrl, Address, Timestamp, Rssi);

  FTxRssi := TxRssi;
  FUrl := Url;
end;

{ TManufacturerFrame }

constructor TManufacturerFrame.Create(const Address: Int64;
  const Timestamp: Int64; const Rssi: SByte; const CompanyId: Word;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
begin
  inherited Create(afManufacturerRaw, Address, Timestamp, Rssi, Data);

  FCompanyId := CompanyId;
end;

{ TDriAsdFrame }

constructor TDriAsdFrame.Create(const Address: Int64; const Timestamp: Int64;
  const Rssi: SByte; const Raw: TwclDriRawData);
begin
  inherited Create(afDriAsd, Address, Timestamp, Rssi);

  FRaw := Raw;
end;

{ TfmMain }

procedure TfmMain.AdvertiserDefaults;
begin
  LeAdvertiser.RestoreDefaults;
  edAdvertiserInterval.Text := IntToStr(LeAdvertiser.Interval);

  cbAdvertiserBeacon.Checked := True;
  cbAdvertiserProximityBeacon.Checked := False;
  cbAdvertiserAltBeacon.Checked := False;
  cbAdvertiserEddystoneUid.Checked := False;
  cbAdvertiserEddystoneUrl.Checked := False;
  cbAdvertiser128SolUuid.Checked := False;
  cbAdvertiserManufacturer.Checked := False;
  cbAdvertiser16Uuid.Checked := False;
  cbAdvertiser32Uuid.Checked := False;
  cbAdvertiser128Uuid.Checked := False;
  cbAdvertiser16UuidData.Checked := False;
  cbAdvertiser32UuidData.Checked := False;
  cbAdvertiser128UuidData.Checked := False;
  cbAdvertiserCustom.Checked := False;

  cbAdvertiserExtended.Checked := False;
  cbAdvertiserAnonymous.Checked := False;
  cbAdvertiserTxRssi.Checked := False;

  cbAdvertiserAnonymous.Enabled := False;
  cbAdvertiserTxRssi.Enabled := False;
end;

procedure TfmMain.WatcherDefaults;
begin
  BeaconWatcher.RestoreDefaults;
  if BeaconWatcher.ScanningMode = smActive then
    cbWatcherScanMode.ItemIndex := 0
  else
    cbWatcherScanMode.ItemIndex := 1;
  edWatcherScanInterval.Text := IntToStr(BeaconWatcher.ScanInterval);
  edWatcherScanWindow.Text := IntToStr(BeaconWatcher.ScanWindow);
  cbWatcherEnableExtended.Checked := BeaconWatcher.AllowExtendedAdvertisements;
end;

procedure TfmMain.AdvertiserEnableControls(const Stopped: Boolean);
begin
  btAdvertiserStart.Enabled := Stopped;
  btAdvertiserStop.Enabled := (not Stopped);
  btAdvertiserDefault.Enabled := Stopped;

  edAdvertiserInterval.Enabled := Stopped;

  cbAdvertiserBeacon.Enabled := Stopped;
  cbAdvertiserProximityBeacon.Enabled := Stopped;
  cbAdvertiserAltBeacon.Enabled := Stopped;
  cbAdvertiserEddystoneUid.Enabled := Stopped;
  cbAdvertiserEddystoneUrl.Enabled := Stopped;
  cbAdvertiser128SolUuid.Enabled := Stopped;
  cbAdvertiserManufacturer.Enabled := Stopped;
  cbAdvertiser16Uuid.Enabled := Stopped;
  cbAdvertiser32Uuid.Enabled := Stopped;
  cbAdvertiser128Uuid.Enabled := Stopped;
  cbAdvertiser16UuidData.Enabled := Stopped;
  cbAdvertiser32UuidData.Enabled := Stopped;
  cbAdvertiser128UuidData.Enabled := Stopped;
  cbAdvertiserCustom.Enabled := Stopped;

  cbAdvertiserExtended.Enabled := Stopped;
  cbAdvertiserAnonymous.Enabled := Stopped and cbAdvertiserExtended.Checked;
  cbAdvertiserTxRssi.Enabled := Stopped and cbAdvertiserExtended.Checked;
end;

procedure TfmMain.WatcherEnableControls(const Stopped: Boolean);
begin
  cbWatcherScanMode.Enabled := Stopped;
  edWatcherScanInterval.Enabled := Stopped;
  edWatcherScanWindow.Enabled := Stopped;
  cbWatcherEnableExtended.Enabled := Stopped;

  btWatcherDefault.Enabled := Stopped;

  btWatcherStart.Enabled := Stopped;
  btWatcherStop.Enabled := (not Stopped);
end;

procedure TfmMain.Trace(const Msg: string);
begin
  lbLog.Items.Add(Msg);
  if cbAutoScroll.Checked then
    lbLog.TopIndex := lbLog.Items.Count - 1;
end;

procedure TfmMain.Trace(const Msg: string; const Res: Integer);
begin
  Trace(Msg + ' failed: 0x' + IntToHex(Res, 8));
end;

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
begin
  Result := nil;

  if not BluetoothManager.Active then
    Res := BluetoothManager.Open
  else
    Res := WCL_E_SUCCESS;

  if Res <> WCL_E_SUCCESS then
    Trace('Bluetooth Manager open', Res)

  else begin
    Res := BluetoothManager.GetLeRadio(Result);
    if Res <> WCL_E_SUCCESS then
      Trace('Get working radio', Res)
    else
      Trace('Use ' + Result.ApiName + ' radio');
  end;
end;

function TfmMain.AddDevice(const Address: Int64): TListItem;
var
  i: Integer;
  AddrStr: string;
begin
  Result := nil;

  AddrStr := IntToHex(Address, 12);

  if lvDevices.Items.Count > 0 then begin
    for i := 0 to lvDevices.Items.Count - 1 do begin
      if AddrStr = lvDevices.Items[i].Caption then begin
        Result := lvDevices.Items[i];
        Break;
      end;
    end;
  end;

  if Result = nil then begin
    Result := lvDevices.Items.Add;
    Result.Caption := AddrStr;
    Result.Data := nil;
    Result.SubItems.Add('');
  end;
end;

procedure TfmMain.AddFrame(const Frame: TFrameStorage);
var
  FrameItem: TListItem;
  Device: TListItem;
  i: Integer;
begin
  FrameItem := nil;

  Device := AddDevice(Frame.Address);
  if Device.Index < lvDevices.Items.Count - 1 then begin
    for i := Device.Index + 1 to lvDevices.Items.Count - 1 do begin
      if lvDevices.Items[i].Data = nil then
        Break;

      if TFrameStorage(lvDevices.Items[i].Data).Frame = Frame.Frame then begin
        FrameItem := lvDevices.Items[i];
        Break;
      end;
    end;
  end;

  if FrameItem = nil then begin
    FrameItem := lvDevices.Items.Insert(Device.Index + 1);
    FrameItem.Caption := '';
    FrameItem.Data := nil;

    case Frame.Frame of
      afAppearance: FrameItem.SubItems.Add('Appearance');
      afExtInformation: FrameItem.SubItems.Add('Ext Information');
      afInformation: FrameItem.SubItems.Add('Information');
      afRaw: FrameItem.SubItems.Add('Raw');
      afDetails: FrameItem.SubItems.Add('Details');
      afService16Data: FrameItem.SubItems.Add('Service 16');
      afService32Data: FrameItem.SubItems.Add('Service 32');
      afService128Data: FrameItem.SubItems.Add('Service 128');
      afSol16: FrameItem.SubItems.Add('16 SOL');
      afSol32: FrameItem.SubItems.Add('32 SOL');
      afSol128: FrameItem.SubItems.Add('128 SOL');
      afTxPower: FrameItem.SubItems.Add('Tx Power');
      afUuid: FrameItem.SubItems.Add('UUID');
      afAltBeacon: FrameItem.SubItems.Add('Alt Beacon');
      afEddystoneTlm: FrameItem.SubItems.Add('Eddystone TLM');
      afEddystoneUid: FrameItem.SubItems.Add('Eddystone UID');
      afEddystoneUrl: FrameItem.SubItems.Add('Eddystone URL');
      afManufacturerRaw: FrameItem.SubItems.Add('Manufacturer');
      afMicrosoftCdpBeacon: FrameItem.SubItems.Add('Microsoft CDP');
      afAppleAirdrop: FrameItem.SubItems.Add('Apple AirDrop');
      afAppleAirplaySource: FrameItem.SubItems.Add('Apple Airplay Source');
      afAppleAirplayTarget: FrameItem.SubItems.Add('Apple Airplay Target');
      afAppleAirprint: FrameItem.SubItems.Add('Apple AirPrint');
      afAppleHomeKit: FrameItem.SubItems.Add('Apple Home Kit');
      afAppleiBeacon: FrameItem.SubItems.Add('Apple iBeacon');
      afAppleNearbyAction: FrameItem.SubItems.Add('Apple Nearby Action');
      afAppleNearbyInfo: FrameItem.SubItems.Add('Apple Nearby Info');
      afAppleProximityPairing: FrameItem.SubItems.Add('Apple Proximity Pairing');
      afAppleUnknown: FrameItem.SubItems.Add('Apple Unknown');
      afAppleFindMy: FrameItem.SubItems.Add('Apple Find My');
      afAppleHandoff: FrameItem.SubItems.Add('Apple Handoff');
      afAppleHeySiri: FrameItem.SubItems.Add('Apple Hey Siri');
      afAppleMagicSwitch: FrameItem.SubItems.Add('Apple Magic Switch');
      afAppleTetheringSource: FrameItem.SubItems.Add('Apple Tethering Source');
      afAppleTetheringTarget: FrameItem.SubItems.Add('Apple Tethering Target');
      afDriAsd: FrameItem.SubItems.Add('DRI ASD');
      else FrameItem.SubItems.Add('Unknown');
    end;
  end;

  if FrameItem.Data <> nil then
    TFrameStorage(FrameItem.Data).Free;
  FrameItem.Data := Frame;

  if Frame.Frame = afInformation then begin
    if TInformationFrame(Frame).Name <> '' then
      Device.SubItems[0] := TInformationFrame(Frame).Name;
  end;

  if FrameItem.Selected then
    ShowFrameData(Frame);
end;

function TfmMain.ConvertTime(const Timestamp: Int64): TDateTime;
var
  li: ULARGE_INTEGER;
  ft: FILETIME;
  st: SYSTEMTIME;
begin
  li.QuadPart := Timestamp;
  ft.dwLowDateTime := li.LowPart;
  ft.dwHighDateTime := li.HighPart;
  FileTimeToLocalFileTime(ft, ft);
  FileTimeToSystemTime(ft, st);
  Result := SystemTimeToDateTime(st);
end;

procedure TfmMain.ShowData(const Name: string; const Value: string);
var
  Item: TListItem;
begin
  Item := lvFrameDetails.Items.Add;
  Item.Caption := Name;
  Item.SubItems.Add(Value);
end;

procedure TfmMain.ShowFrameBaseData(const Frame: TFrameStorage);
begin
  ShowData('Address', IntToHex(Frame.Address, 12));
  ShowData('Timestamp', DateTimeToStr(ConvertTime(Frame.Timestamp)));
  ShowData('RSSI', IntToStr(Frame.Rssi));
end;

procedure TfmMain.ShowFrameRawData(
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Str: string;
  c: Byte;
  i: Integer;
  First: string;
begin
  First := 'Data';

  if Length(Data) > 0 then begin
    Str := '';
    c := 0;
    for i := 0 to Length(Data) - 1 do begin
      Str := Str + IntToHex(Data[i], 2) + ' ';
      if c = 15 then begin
        ShowData(First, Str);

        First := '';
        Str := '';
        c := 0;
      end else
        Inc(c);
    end;

    if Str <> '' then
      ShowData(First, Str);
  end;
end;

procedure TfmMain.ShowDriFrameRawData(const Raw: TwclDriRawData);
var
  Len: Integer;
  Data: TwclBluetoothLeAdvertisementFrameRawData;
begin
  Len := Length(Raw);
  if Len > 0 then begin
    Data := nil;
    SetLength(Data, Len);
    CopyMemory(Pointer(Data), Pointer(Raw), Len);
    ShowFrameRawData(Data);
  end;
end;

procedure TfmMain.ShowAppearanceFrame(const Frame: TAppearanceFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Appearance', IntToHex(Frame.Appearance, 4));
end;

procedure TfmMain.ShowExtInformationFrame(const Frame: TExtInformationFrame);
var
  Str: string;
begin
  ShowFrameBaseData(Frame);

  case Frame.AddressType of
    atClassic: Str := 'Classic';
    atPublic: Str := 'Public';
    atRandom: Str := 'Random';
    atUnspecified: Str := 'Unpecified';
    else Str := 'Unknonw';
  end;
  ShowData('Address type', Str);

  Str := '';
  if efAnonymous in Frame.Flags then
    Str := Str + ' [Anonymous]';
  if efConnectable in Frame.Flags then
    Str := Str + ' [Connectable]';
  if efDirected in Frame.Flags then
    Str := Str + ' [Directed]';
  if efScannable in Frame.Flags then
    Str := Str + ' [Scannable]';
  if efScanResponse in Frame.Flags then
    Str := Str + ' [Scan Response]';
  Str := Str + ' ';
  ShowData('Flags', Str);

  ShowData('TX Power', IntToStr(Frame.TxPower));
end;

procedure TfmMain.ShowInformationFrame(const Frame: TInformationFrame);
var
  Str: string;
begin
  ShowFrameBaseData(Frame);

  Str := '';
  if afLimitedDiscoverableMode in Frame.Flags then
    Str := Str + ' [General Discoverable Mode]';
  if afClassicNotSupported in Frame.Flags then
    Str := Str + ' [Classic Not Supported]';
  if afDualModeControllerCapable in Frame.Flags then
    Str := Str + ' [Dual Mode Controller Capable]';
  if afDualModeHostCapable in Frame.Flags then
    Str := Str + ' [Dual Mode Host Capable]';
  Str := Str + ' ';
  ShowData('Flags', Str);

  ShowData('Name', Frame.Name);

  case Frame.PacketType of
    atConnectableUndirected: Str := 'Connectable Undirected';
    atConnectableDirected: Str := 'Connectable Directed';
    atScannableUndirected: Str := 'Scannable Undirected';
    atNonConnectableUndirected: Str := 'Non Connectable Undirected';
    atScanResponse: Str := 'Scan Response';
    atExtended: Str := 'Extended';
    else Str := 'Unknown';
  end;
  ShowData('Packet Type', Str);
end;

procedure TfmMain.ShowRawFrame(const Frame: TRawFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Data Type', IntToHex(Frame.DataType, 2));
  
  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowDetailsFrame(const Frame: TDetailsFrame);
begin
  ShowFrameBaseData(Frame);

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowService16DataFrame(const Frame: TService16DataFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', IntToHex(Frame.Uuid, 4));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowService32DataFrame(const Frame: TService32DataFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', IntToHex(Frame.Uuid, 8));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowService128DataFrame(const Frame: TService128DataFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', GUIDToString(Frame.Uuid));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowSol16Frame(const Frame: TSol16Frame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', IntToHex(Frame.Uuid, 4));
end;

procedure TfmMain.ShowSol32Frame(const Frame: TSol32Frame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', IntToHex(Frame.Uuid, 8));
end;

procedure TfmMain.ShowSol128Frame(const Frame: TSol128Frame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', GUIDToString(Frame.Uuid));
end;

procedure TfmMain.ShowTxPowerFrame(const Frame: TTxPowerFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('TX Power', IntToStr(Frame.TxPower));
end;

procedure TfmMain.ShowUuidFrame(const Frame: TUuidFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', GUIDToString(Frame.Uuid));
end;

procedure TfmMain.ShowAltBeaconFrame(const Frame: TAltBeaconFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', GUIDToString(Frame.Uuid));
  ShowData('CompanyId', IntToHex(Frame.CompanyId, 4));
  ShowData('Major', IntToHex(Frame.Major, 4));
  ShowData('Minor', IntToHex(Frame.Minor, 4));
  ShowData('TX RSSI', IntToStr(Frame.TxRssi));
  ShowData('Reserved', IntToHex(Frame.Reserved, 2));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowEddystoneTlmFrame(const Frame: TEddystoneTlmFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Advertisements Counter', IntToStr(Frame.AdvCnt));
  ShowData('Battery status', IntToStr(Frame.Batt));
  ShowData('Seconds', IntToStr(Frame.SecCnt));
  ShowData('Temperature', FloatToStr(Frame.Temp));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowEddystoneUidFrame(const Frame: TEddystoneUidFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', GUIDToString(Frame.Uuid));
  ShowData('TX RSSI', IntToStr(Frame.TxRssi));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowEddystoneUrlFrame(const Frame: TEddystoneUrlFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('TX RSSI', IntToStr(Frame.TxRssi));
  ShowData('URL', Frame.Url);
end;

procedure TfmMain.ShowManufacturerFrame(const Frame: TManufacturerFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Company ID', IntToHex(Frame.CompanyId, 4));

  ShowFrameRawData(Frame.Data);
end;

procedure TfmMain.ShowMicrosoftCdpBeaconFrame(
  const Frame: TMicrosoftCdpBeaconFrame);
var
  Str: string;
  i: Integer;
begin
  ShowFrameBaseData(Frame);

  ShowData('Address As Device ID', BoolToStr(Frame.AddressAsDeviceId, True));
  case Frame.DeviceType of
    dtXboxOne: ShowData('Device Type', 'Xbox one');
    dtiPhone: ShowData('Device Type', 'iPhone');
    dtiPad: ShowData('Device Type', 'iPad');
    dtAndroid: ShowData('Device Type', 'Android');
    dtWindowsDesktop: ShowData('Device Type', 'Windows Desktop');
    dtWindowsPhone: ShowData('Device Type', 'Windows Phone');
    dtLinux: ShowData('Device Type', 'Linux');
    dtWindowsIoT: ShowData('Device Type', 'Windows IoT');
    dtSurfaceHub: ShowData('Device Type', 'Surface Hub');
    dtWindowsLaptop: ShowData('Device Type', 'Windows Laptop');
    dtWindowsTablet: ShowData('Device Type', 'Windows Tablet');
    else ShowData('Device Type', IntToHex(Byte(Frame.DeviceType), 2));
  end;

  Str := '';
  if edsRemoteSessionsHosted in Frame.ExtendedDeviceStatus then
    Str := Str + ' [Remote Sessions Hosted]';
  if edsRemoteSessionsNotHosted in Frame.ExtendedDeviceStatus then
    Str := Str + ' [Remote Sessions Not Hosted]';
  if edsNearShareAuthPolicySameUser in Frame.ExtendedDeviceStatus then
    Str := Str + ' [Near Share Auth Policy Same User]';
  if edsNearShareAuthPolicyPermissive in Frame.ExtendedDeviceStatus then
    Str := Str + ' [Near Share Auth Policy Permissive]';
  Str := Str + ' ';
  ShowData('Extended Device Status', Str);

  Str := '';
  if Length(Frame.Hash) > 0 then begin
    for i := 0 to Length(Frame.Hash) - 1 do
      Str := Str + IntToHex(Frame.Hash[i], 2) + ' ';
  end;
  ShowData('Hash', Str);

  Str := '';
  if Length(Frame.Salt) > 0 then begin
    for i := 0 to Length(Frame.Salt) - 1 do
      Str := Str + IntToHex(Frame.Salt[i], 2) + ' ';
  end;
  ShowData('Salt', Str);

  case Frame.ScenarioType of
    stBluetooth: ShowData('Scenario Type', 'Bluetooth');
    else ShowData('Scenario Type', IntToHex(Byte(Frame.ScenarioType), 2));
  end;

  ShowData('Share Near By', BoolToStr(Frame.ShareNearBy, True));
  ShowData('Subversion', IntToHex(Frame.SubVersion, 2));
  ShowData('Version', IntToHex(Frame.Version, 2));
end;

procedure TfmMain.ShowAppleiBeaconFrame(const Frame: TAppleiBeaconFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('UUID', GUIDToString(Frame.Data.Uuid));
  ShowData('Major', IntToHex(Frame.Data.Major, 4));
  ShowData('Minor', IntToHex(Frame.Data.Minor, 4));
  ShowData('TX RSSI', IntToStr(Frame.Data.TxRssi));
end;

procedure TfmMain.ShowAppleNearbyActionFrame(
  const Frame: TAppleNearbyActionFrame);
var
  Str: string;
  i: Integer;
begin
  ShowFrameBaseData(Frame);

  ShowData('Flags', IntToHex(Frame.Data.Flags, 2));

  case Frame.Data.Action of
    $01: ShowData('Action', 'Apple TV Setup');
    $04: ShowData('Action', 'Mobile Backup');
    $05: ShowData('Action', 'Watch Setup');
    $06: ShowData('Action', 'Apple TV Pair');
    $07: ShowData('Action', 'Internet Relay');
    $08: ShowData('Action', 'WiFi Password');
    $09: ShowData('Action', 'iOS Setup');
    $0A: ShowData('Action', 'Repair');
    $0B: ShowData('Action', 'Speaker Setupd');
    $0C: ShowData('Action', 'Apple Pay');
    $0D: ShowData('Action', 'Whole Home Audio Setup');
    $0E: ShowData('Action', 'Developer Tools Pairing Request');
    $0F: ShowData('Action', 'Answered Call');
    $10: ShowData('Action', 'Ended Call');
    $11: ShowData('Action', 'DD Ping');
    $12: ShowData('Action', 'DD Pong');
    $13: ShowData('Action', 'Remote Auto Fill');
    $14: ShowData('Action', 'Companion Link Proximity');
    $15: ShowData('Action', 'Remote Management');
    $16: ShowData('Action', 'Remote Auto Fill Pong');
    $17: ShowData('Action', 'Remote Display');
    else ShowData('Action', 'Unknown: 0x' + IntToHex(Frame.Data.Action, 2));
  end;

  ShowData('Tag', IntToHex(Frame.Data.Tag, 6));

  case Frame.Data.Device of
    $02: ShowData('Device', 'iPhone');
    $04: ShowData('Device', 'iPod');
    $06: ShowData('Device', 'iPad');
    $08: ShowData('Device', 'Audio accessory (HomePod)');
    $0A: ShowData('Device', 'Mac');
    $0C: ShowData('Device', 'AppleTV');
    $0E: ShowData('Device', 'Watch');
    else ShowData('Device', 'Unknown: 0x' + IntToHex(Frame.Data.Device, 2));
  end;

  if Length(Frame.Data.Params) > 0 then begin
    Str := '';
    for i := 0 to Length(Frame.Data.Params) - 1 do
      Str := Str + IntToHex(Frame.Data.Params[i], 2);
    ShowData('Params', Str);
  end;
end;

procedure TfmMain.ShowAppleNearbyInfoFrame(const Frame: TAppleNearbyInfoFrame);
begin
  ShowFrameBaseData(Frame);

  if (Frame.Data.Status and $01) <> 0 then
    ShowData('Primary device', 'YES')
  else
    ShowData('Primary device', 'NO');
  if (Frame.Data.Status and $04) <> 0 then
    ShowData('AirDrop', 'RECEIVING')
  else
    ShowData('AirDrop', 'NOT ACTIVE');

  case Frame.Data.Action of
    $00: ShowData('Action', 'None');
    $01: ShowData('Action', 'Activity reporting disabled');
    $03: ShowData('Action', 'Idle user');
    $05: ShowData('Action', 'Audio playing while screen locked');
    $07: ShowData('Action', 'Active user (screen on)');
    $09: ShowData('Action', 'Screen on with video playing');
    $0A: ShowData('Action', 'Watch on wrist and unlocked');
    $0B: ShowData('Action', 'Recent user interaction');
    $0D: ShowData('Action', 'User is driving a vehicle');
    $0E: ShowData('Action', 'Phone or Facetime Call');
    else ShowData('Action', 'Unknown: 0x' + IntToHex(Frame.Data.Action, 2));
  end;

  if (Frame.Data.Flags and $01) <> 0 then
    ShowData('AirDrop state', 'Connected and Screen ON')
  else
    ShowData('AirDrop state', 'Disconnected');

  if (Frame.Data.Flags and $02) <> 0 then
    ShowData('Auth tag length', '4 bytes')
  else
    ShowData('Auth tag length', '3 bytes');

  if (Frame.Data.Flags and $04) <> 0 then
    ShowData('WiFi', 'ON')
  else
    ShowData('WiFi', 'OFF');

  if (Frame.Data.Flags and $10) <> 0 then
    ShowData('Auth Tag Present', 'YES')
  else
    ShowData('Auth Tag Present', 'NO');

  if (Frame.Data.Flags and $20) <> 0 then
    ShowData('Apple Watch', 'LOCKED')
  else
    ShowData('Apple Watch', 'UNLOCKED');

  if (Frame.Data.Flags and $40) <> 0 then
    ShowData('Apple Watch AutoLock', 'ENABLED')
  else
    ShowData('Apple Watch AutoLock', 'DISABLED');

  if (Frame.Data.Flags and $80) <> 0 then
    ShowData('AutoLock', 'ENABLED')
  else
    ShowData('AutoLock', 'DISABLED');

  if (Frame.Data.Flags and $10) <> 0 then begin
    if (Frame.Data.Flags and $02) <> 0 then
      ShowData('Auth Tag', IntToHex(Frame.Data.Tag, 8))
    else
      ShowData('Auth Tag', IntToHex(Frame.Data.Tag, 6));
  end;
end;

procedure TfmMain.ShowAppleProximityPairingFrame(
  const Frame: TAppleProximityPairingFrame);
var
  Str: string;
  i: Byte;
begin
  ShowFrameBaseData(Frame);

  ShowData('Prefix', IntToHex(Frame.Data.Prefix, 2));

  case Frame.Data.DeviceModel of
    $2002: ShowData('Device mode', 'AirPods');
    $2003: ShowData('Device mode', 'Powerbeats 3');
    $2005: ShowData('Device mode', 'BeatsX');
    $2006: ShowData('Device mode', 'Beats Solo 3');
    $2007: ShowData('Device mode', 'Beats Studio 3');
    $2009: ShowData('Device mode', 'Beats Studio 3');
    $200A: ShowData('Device mode', 'AirPods Max');
    $200B: ShowData('Device mode', 'Powerbeats Pro');
    $200C: ShowData('Device mode', 'Beats Solo Pro');
    $200D: ShowData('Device mode', 'Powerbeats 4');
    $200E: ShowData('Device mode', 'AirPods Pro');
    $200F: ShowData('Device mode', 'AirPods 2');
    $2010: ShowData('Device mode', 'Beats Flex');
    $2011: ShowData('Device mode', 'Beats Studio Buds');
    $2012: ShowData('Device mode', 'Beats Fit Pro');
    $2013: ShowData('Device mode', 'AirPods 3');
    $2014: ShowData('Device mode', 'AirPods Pro 2');
    else ShowData('Device mode', 'Unknown: 0x' + IntToHex(Frame.Data.DeviceModel, 4));
  end;

  case Frame.Data.Status of
    $01: ShowData('Status', 'AirPods: Both out of case, not in ear');
    $02: ShowData('Status', 'Right in ear, Left in case');
    $03: ShowData('Status', 'AirPods: Right in ear, Left out of case');
    $0B: ShowData('Status', 'Both AirPods in ear');
    $11: ShowData('Status', 'AirPods: Right out of case, Left in case');
    $13: ShowData('Status', 'AirPods: Right in ear, Left in case');
    $21: ShowData('Status', 'Both taken out of ears, Pause Audio');
    $22: ShowData('Status', 'Left in ear, Right in case');
    $23: ShowData('Status', 'AirPods: Left in ear, Right out of case');
    $2B: ShowData('Status', 'Both AirPods in ear');
    $31: ShowData('Status', 'AirPods: Left out of case, Right in case');
    $33: ShowData('Status', 'AirPods: Left in ear, Right in case');
    $51: ShowData('Status', 'Case: Left out of case, Right in case');
    $53: ShowData('Status', 'Case: Left in ear, Right in case');
    $55: ShowData('Status', 'Case: Both AirPods in case');
    $71: ShowData('Status', 'Case: Right out of case, Left in case');
    $73: ShowData('Status', 'Case: Right in ear, Left in case');
    $75: ShowData('Status', 'Case: Both AirPods in case');
    else ShowData('Status', 'Unknown: 0x' + IntToHex(Frame.Data.Status, 2));
  end;

  ShowData('Left Battery', IntToStr(Frame.Data.LeftBattery));
  ShowData('Right Battery', IntToStr(Frame.Data.RightBattery));

  if Frame.Data.CaseCharging then
    ShowData('Case charging', 'Yes')
  else
    ShowData('Case charging', 'No');
  if Frame.Data.RightCharging then
    ShowData('Right charging', 'Yes')
  else
    ShowData('Right charging', 'No');
  if Frame.Data.LeftCharging then
    ShowData('Left charging', 'Yes')
  else
    ShowData('Left charging', 'No');

  ShowData('Case Battery', IntToStr(Frame.Data.CaseBattery));
  ShowData('Lid open counter', IntToStr(Frame.Data.Counter));

  case Frame.Data.Color of
    $00: ShowData('Color', 'White');
    $01: ShowData('Color', 'Black');
    $02: ShowData('Color', 'Red');
    $03: ShowData('Color', 'Blue');
    $04: ShowData('Color', 'Pink');
    $05: ShowData('Color', 'Gray');
    $06: ShowData('Color', 'Silver');
    $07: ShowData('Color', 'Gold');
    $08: ShowData('Color', 'Rose Gold');
    $09: ShowData('Color', 'Space Gray');
    $0A: ShowData('Color', 'Dark Blue');
    $0B: ShowData('Color', 'Light Blue');
    $0C: ShowData('Color', 'Yellow');
    else ShowData('Color', 'Unknown: 0x' + IntToHex(Frame.Data.Color, 2))
  end;

  ShowData('Suffix', IntToHex(Frame.Data.Suffix, 2));

  Str := '';
  for i := 0 to 15 do
    Str := Str + IntToHex(Frame.Data.Data[i], 2);
  ShowData('Encrypted', Str);
end;

procedure TfmMain.ShowDriAsdFrame(const Frame: TDriAsdFrame);
begin
  ShowFrameBaseData(Frame);

  ShowDriFrameRawData(Frame.Raw);
end;

procedure TfmMain.ShowFrameData(const Frame: TFrameStorage);
begin
  lvFrameDetails.Items.Clear;

  case Frame.Frame of
    afAppearance: ShowAppearanceFrame(TAppearanceFrame(Frame));
    afExtInformation: ShowExtInformationFrame(TExtInformationFrame(Frame));
    afInformation: ShowInformationFrame(TInformationFrame(Frame));
    afRaw: ShowRawFrame(TRawFrame(Frame));
    afDetails: ShowDetailsFrame(TDetailsFrame(Frame));
    afService16Data: ShowService16DataFrame(TService16DataFrame(Frame));
    afService32Data: ShowService32DataFrame(TService32DataFrame(Frame));
    afService128Data: ShowService128DataFrame(TService128DataFrame(Frame));
    afSol16: ShowSol16Frame(TSol16Frame(Frame));
    afSol32: ShowSol32Frame(TSol32Frame(Frame));
    afSol128: ShowSol128Frame(TSol128Frame(Frame));
    afTxPower: ShowTxPowerFrame(TTxPowerFrame(Frame));
    afUuid: ShowUuidFrame(TUuidFrame(Frame));
    afAltBeacon: ShowAltBeaconFrame(TAltBeaconFrame(Frame));
    afEddystoneTlm: ShowEddystoneTlmFrame(TEddystoneTlmFrame(Frame));
    afEddystoneUid: ShowEddystoneUidFrame(TEddystoneUidFrame(Frame));
    afEddystoneUrl: ShowEddystoneUrlFrame(TEddystoneUrlFrame(Frame));
    afManufacturerRaw: ShowManufacturerFrame(TManufacturerFrame(Frame));
    afMicrosoftCdpBeacon: ShowMicrosoftCdpBeaconFrame(TMicrosoftCdpBeaconFrame(Frame));
    afAppleAirdrop: ShowAppleAirdropFrame(TAppleAirdropFrame(Frame));
    afAppleAirplaySource: ShowAppleAirplaySourceFrame(TAppleAirplaySourceFrame(Frame));
    afAppleAirplayTarget: ShowAppleAirplayTargetFrame(TAppleAirplayTargetFrame(Frame));
    afAppleAirprint: ShowAppleAirprintFrame(TAppleAirprintFrame(Frame));
    afAppleHomeKit: ShowAppleHomeKitFrame(TAppleHomeKitFrame(Frame));
    afAppleiBeacon: ShowAppleiBeaconFrame(TAppleiBeaconFrame(Frame));
    afAppleNearbyAction: ShowAppleNearbyActionFrame(TAppleNearbyActionFrame(Frame));
    afAppleNearbyInfo: ShowAppleNearbyInfoFrame(TAppleNearbyInfoFrame(Frame));
    afAppleProximityPairing: ShowAppleProximityPairingFrame(TAppleProximityPairingFrame(Frame));
    afAppleUnknown: ShowAppleUnknownFrame(TAppleUnknownFrame(Frame));
    afAppleFindMy: ShowAppleFindMyFrame(TAppleFindMyFrame(Frame));
    afAppleHandoff: ShowAppleHandoffFrame(TAppleHandoffFrame(Frame));
    afAppleHeySiri: ShowAppleHeySiriFrame(TAppleHeySiriFrame(Frame));
    afAppleMagicSwitch: ShowAppleMagicSwitchFrame(TAppleMagicSwitchFrame(Frame));
    afAppleTetheringSource: ShowAppleTetheringSourceFrame(TAppleTetheringSourceFrame(Frame));
    afAppleTetheringTarget: ShowAppleTetheringTargetFrame(TAppleTetheringTargetFrame(Frame));
    afDriAsd: ShowDriAsdFrame(TDriAsdFrame(Frame));
  end;
end;

procedure TfmMain.AddAdvertisement(const Adv: TwclBluetoothLeAdvertisement);
var
  Res: Integer;
begin
  Res := LeAdvertiser.Add(Adv);
  if Res <> WCL_E_SUCCESS then begin
    Trace('Add advertisement', Res);
    Adv.Free;
  end;
end;

procedure TfmMain.lvDevicesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if (lvDevices.Selected <> nil) and (lvDevices.Selected.Data <> nil) then
    ShowFrameData(TFrameStorage(lvDevices.Selected.Data))
  else
    lvFrameDetails.Items.Clear;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  BluetoothManager := TwclBluetoothManager.Create(nil);
  BluetoothManager.AfterOpen := BluetoothManagerAfterOpen;
  BluetoothManager.BeforeClose := BluetoothManagerBeforeClose;
  BluetoothManager.OnClosed := BluetoothManagerClosed;

  BeaconWatcher := TwclBluetoothLeBeaconWatcher.Create(nil);
  BeaconWatcher.OnStarted := BeaconWatcherStarted;
  BeaconWatcher.OnStopped := BeaconWatcherStopped;
  BeaconWatcher.OnAdvertisementAppearanceFrame := BeaconWatcherAdvertisementAppearanceFrame;
  BeaconWatcher.OnAdvertisementExtFrameInformation := BeaconWatcherAdvertisementExtFrameInformation;
  BeaconWatcher.OnAdvertisementFrameInformation := BeaconWatcherAdvertisementFrameInformation;
  BeaconWatcher.OnAdvertisementRawFrame := BeaconWatcherAdvertisementRawFrame;
  BeaconWatcher.OnAdvertisementReceived := BeaconWatcherAdvertisementReceived;
  BeaconWatcher.OnAdvertisementService128DataFrame := BeaconWatcherAdvertisementService128DataFrame;
  BeaconWatcher.OnAdvertisementService16DataFrame := BeaconWatcherAdvertisementService16DataFrame;
  BeaconWatcher.OnAdvertisementService32DataFrame := BeaconWatcherAdvertisementService32DataFrame;
  BeaconWatcher.OnAdvertisementServiceSol128Frame := BeaconWatcherAdvertisementServiceSol128Frame;
  BeaconWatcher.OnAdvertisementServiceSol16Frame := BeaconWatcherAdvertisementServiceSol16Frame;
  BeaconWatcher.OnAdvertisementServiceSol32Frame := BeaconWatcherAdvertisementServiceSol32Frame;
  BeaconWatcher.OnAdvertisementTxPowerLevelFrame := BeaconWatcherAdvertisementTxPowerLevelFrame;
  BeaconWatcher.OnAdvertisementUuidFrame := BeaconWatcherAdvertisementUuidFrame;
  BeaconWatcher.OnAltBeaconFrame := BeaconWatcherAltBeaconFrame;
  BeaconWatcher.OnEddystoneTlmFrame := BeaconWatcherEddystoneTlmFrame;
  BeaconWatcher.OnEddystoneUidFrame := BeaconWatcherEddystoneUidFrame;
  BeaconWatcher.OnEddystoneUrlFrame := BeaconWatcherEddystoneUrlFrame;
  BeaconWatcher.OnManufacturerRawFrame := BeaconWatcherManufacturerRawFrame;
  BeaconWatcher.OnMicrosoftCdpBeaconFrame := BeaconWatcherMicrosoftCdpBeaconFrame;
  BeaconWatcher.OnAppleAirdropFrame := BeaconWatcherAppleAirdropFrame;
  BeaconWatcher.OnAppleAirplaySourceFrame := BeaconWatcherAppleAirplaySourceFrame;
  BeaconWatcher.OnAppleAirplayTargetFrame := BeaconWatcherAppleAirplayTargetFrame;
  BeaconWatcher.OnAppleAirprintFrame := BeaconWatcherAppleAirprintFrame;
  BeaconWatcher.OnAppleiBeaconFrame := BeaconWatcherAppleiBeaconFrame;
  BeaconWatcher.OnAppleNearbyActionFrame := BeaconWatcherAppleNearbyActionFrame;
  BeaconWatcher.OnAppleNearbyInfoFrame := BeaconWatcherAppleNearbyInfoFrame;
  BeaconWatcher.OnAppleHomeKitFrame := BeaconWatcherAppleHomeKitFrame;
  BeaconWatcher.OnAppleProximityPairingFrame := BeaconWatcherAppleProximityPairingFrame;
  BeaconWatcher.OnAppleUnknownFrame := BeaconWatcherAppleUnknownFrame;
  BeaconWatcher.OnAppleFindMyFrame := BeaconWatcherAppleFindMyFrame;
  BeaconWatcher.OnAppleHandoffFrame := BeaconWatcherAppleHandoffFrame;
  BeaconWatcher.OnAppleHeySiriFrame := BeaconWatcherAppleHeySiriFrame;
  BeaconWatcher.OnAppleMagicSwitchFrame := BeaconWatcherAppleMagicSwitchFrame;
  BeaconWatcher.OnAppleTetheringSourceFrame := BeaconWatcherAppleTetheringSourceFrame;
  BeaconWatcher.OnAppleTetheringTargetFrame := BeaconWatcherAppleTetheringTargetFrame;

  LeAdvertiser := TwclBluetoothLeAdvertiser.Create(nil);
  LeAdvertiser.OnStarted := LeAdvertiserStarted;
  LeAdvertiser.OnStopped := LeAdvertiserStopped;

  AdvertiserDefaults;
  WatcherDefaults;

  btAdvertiserStop.Enabled := False;
  btWatcherStop.Enabled := False;

  cbAutoScroll.Checked := True;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  BluetoothManager.Close;

  LeAdvertiser.Free;
  BeaconWatcher.Free;
  BluetoothManager.Free;
end;

procedure TfmMain.btClearLogClick(Sender: TObject);
begin
  lbLog.Items.Clear;
end;

procedure TfmMain.btWatcherDefaultClick(Sender: TObject);
begin
  WatcherDefaults;
end;

procedure TfmMain.btAdvertiserDefaultClick(Sender: TObject);
begin
  AdvertiserDefaults;
end;

procedure TfmMain.cbAdvertiserExtendedClick(Sender: TObject);
begin
  cbAdvertiserAnonymous.Enabled := cbAdvertiserExtended.Checked;
  cbAdvertiserTxRssi.Enabled := cbAdvertiserExtended.Checked;
end;

procedure TfmMain.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key in ['0'..'9']) or (Key = #8) then
    inherited
  else
    Key := #0;
end;

procedure TfmMain.BluetoothManagerAfterOpen(Sender: TObject);
begin
  Trace('Bluetooth Manager opened');
end;

procedure TfmMain.BluetoothManagerBeforeClose(Sender: TObject);
begin
  Trace('Bluetooth Manager is closing');

  LeAdvertiser.Stop;
  BeaconWatcher.Stop;
end;

procedure TfmMain.BluetoothManagerClosed(Sender: TObject);
begin
  Trace('Bluetooth Manager closed');
end;

procedure TfmMain.btWatcherStartClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    BeaconWatcher.AllowExtendedAdvertisements :=
      cbWatcherEnableExtended.Checked;
    if cbWatcherScanMode.ItemIndex = 0 then
      BeaconWatcher.ScanningMode := smActive
    else
      BeaconWatcher.ScanningMode := smPassive;
    BeaconWatcher.ScanInterval := StrToInt(edWatcherScanInterval.Text);
    BeaconWatcher.ScanWindow := StrToInt(edWatcherScanWindow.Text);

    Res := BeaconWatcher.Start(Radio);
    if Res <> WCL_E_SUCCESS then
      Trace('Start Watched', Res);
  end;
end;

procedure TfmMain.btWatcherStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := BeaconWatcher.Stop;
  if Res <> WCL_E_SUCCESS then
    Trace('Beacon Watcher stop', Res);
end;

procedure TfmMain.BeaconWatcherStarted(Sender: TObject);
begin
  Trace('Beacon Watcher started');

  WatcherEnableControls(False);
end;

procedure TfmMain.BeaconWatcherStopped(Sender: TObject);
var
  i: Integer;
begin
  Trace('Beacon Watcher stopped');

  WatcherEnableControls(True);

  lvFrameDetails.Items.Clear;

  if lvDevices.Items.Count > 0 then begin
    for i := 0 to lvDevices.Items.Count - 1 do begin
      if lvDevices.Items[i].Data <> nil then
        TFrameStorage(lvDevices.Items[i].Data).Free;
    end;

    lvDevices.Items.Clear;
  end;
end;

procedure TfmMain.BeaconWatcherAdvertisementAppearanceFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Appearance: Word);
var
  Frame: TFrameStorage;
begin
  Frame := TAppearanceFrame.Create(Address, Timestamp, Rssi, Appearance);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementExtFrameInformation(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const AddressType: TwclBluetoothAddressType; const TxPower: SByte;
  const Flags: TwclBluetoothLeExtendedFrameFlags);
var
  Frame: TFrameStorage;
begin
  Frame := TExtInformationFrame.Create(Address, Timestamp, Rssi, AddressType,
    Flags, TxPower);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementFrameInformation(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Name: String; const PacketType: TwclBluetoothLeAdvertisementType;
  const Flags: TwclBluetoothLeAdvertisementFlags);
var
  Frame: TFrameStorage;
begin
  Frame := TInformationFrame.Create(Address, Timestamp, Rssi, Flags, Name,
    PacketType);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementRawFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const DataType: Byte; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TRawFrame.Create(Address, Timestamp, Rssi, Data, DataType);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementReceived(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TDetailsFrame.Create(Address, Timestamp, Rssi, Data);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementService128DataFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: TGUID; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TService128DataFrame.Create(Address, Timestamp, Rssi, Uuid, Data);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementService16DataFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: Word; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TService16DataFrame.Create(Address, Timestamp, Rssi, Data, Uuid);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementService32DataFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: Cardinal; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TService32DataFrame.Create(Address, Timestamp, Rssi, Data, Uuid);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementServiceSol128Frame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: TGUID);
var
  Frame: TFrameStorage;
begin
  Frame := TSol128Frame.Create(Address, Timestamp, Rssi, Uuid);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementServiceSol16Frame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: Word);
var
  Frame: TFrameStorage;
begin
  Frame := TSol16Frame.Create(Address, Timestamp, Rssi, Uuid);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementServiceSol32Frame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: Cardinal);
var
  Frame: TFrameStorage;
begin
  Frame := TSol32Frame.Create(Address, Timestamp, Rssi, Uuid);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementTxPowerLevelFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const TxPower: SByte);
var
  Frame: TFrameStorage;
begin
  Frame := TTxPowerFrame.Create(Address, Timestamp, Rssi, TxPower);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAdvertisementUuidFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Uuid: TGUID);
var
  Frame: TFrameStorage;
begin
  Frame := TUuidFrame.Create(Address, Timestamp, Rssi, Uuid);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherAltBeaconFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const CompanyId: Word; const Major: Word; const Minor: Word;
  const Uuid: TGUID; const TxRssi: SByte; const Reserved: Byte;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TAltBeaconFrame.Create(Address, Timestamp, Rssi, Data, Uuid,
    CompanyId, Major, Minor, TxRssi, Reserved);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherEddystoneTlmFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const AdvCnt: Cardinal; const Batt: Word; const SecCnt: Cardinal;
  const Temp: Double; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TEddystoneTlmFrame.Create(Address, Timestamp, Rssi, Data, AdvCnt,
    Batt, SecCnt, Temp);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherEddystoneUidFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const TxRssi: SByte; const Uuid: TGUID;
  const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TEddystoneUidFrame.Create(Address, Timestamp, Rssi, Data, Uuid,
    TxRssi);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherEddystoneUrlFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const TxRssi: SByte; const Url: String);
var
  Frame: TFrameStorage;
begin
  Frame := TEddystoneUrlFrame.Create(Address, Timestamp, Rssi, TxRssi, Url);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherManufacturerRawFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const CompanyId: Word; const Data: TwclBluetoothLeAdvertisementFrameRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TManufacturerFrame.Create(Address, Timestamp, Rssi, CompanyId, Data);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherMicrosoftCdpBeaconFrame(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const ScenarioType: TwclBluetoothLeCdpBeaconScenarioType;
  const Version: Byte; const DeviceType: TwclBluetoothLeCdpBeaconDeviceType;
  const SubVersion: Byte; const ShareNearBy: Boolean;
  const AddressAsDeviceId: Boolean;
  const ExtendedDeviceStatus: TwclBluetoothLeCdpBeaconExtendedDeviceStatuses;
  const Salt: TwclBluetoothLeCdpBeaconSalt;
  const Hash: TwclBluetoothLeCdpBeaconHash);
var
  Frame: TFrameStorage;
begin
  Frame := TMicrosoftCdpBeaconFrame.Create(Address, Timestamp, Rssi,
    AddressAsDeviceId, DeviceType, ExtendedDeviceStatus, Hash, Salt,
    ScenarioType, ShareNearBy, SubVersion, Version);
  AddFrame(Frame);
end;

procedure TfmMain.BeaconWatcherDriAsdMessage(Sender: TObject;
  const Address: Int64; const Timestamp: Int64; const Rssi: SByte;
  const Raw: TwclDriRawData);
var
  Frame: TFrameStorage;
begin
  Frame := TDriAsdFrame.Create(Address, Timestamp, Rssi, Raw);
  AddFrame(Frame);
end;

procedure TfmMain.btAdvertiserStartClick(Sender: TObject);
const
  BEACON_UUID: TGUID = '{09039835-4A80-443B-87AA-DC565D09EA61}';

var
  Radio: TwclBluetoothRadio;
  Res: Integer;
  Data: TwclBluetoothLeAdvertisementFrameRawData;
  Adv: TwclBluetoothLeAdvertisement;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    LeAdvertiser.Clear;
    
    if cbAdvertiserBeacon.Checked then begin
      Adv := TwclBluetoothLeiBeaconAdvertisement.Create(-5, $0101, $0202,
        BEACON_UUID);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiserProximityBeacon.Checked then begin
      Adv := TwclBluetoothLeProximityBeaconAdvertisement.Create(-5, $0101,
        $0202, BEACON_UUID, $FFFE);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiserAltBeacon.Checked then begin
      Adv := TwclBluetoothLeAltBeaconAdvertisement.Create(-5, $0101, $0202,
        BEACON_UUID, $FFFE, $11);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiserEddystoneUid.Checked then begin
      Adv := TwclBluetoothLeEddystoneUidBeaconAdvertisement.Create(-5,
        BEACON_UUID);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiserEddystoneUrl.Checked then begin
      Adv := TwclBluetoothLeEddystoneUrlBeaconAdvertisement.Create(-5,
        'https://www.btframework.com');
      AddAdvertisement(Adv);
    end;

    Data := nil;
    if cbAdvertiser128SolUuid.Checked then begin
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

    if cbAdvertiserManufacturer.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLeManufacturerAdvertisement.Create($010E, Data);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiser16Uuid.Checked then begin
      Adv := TwclBluetoothLe16ServiceAdvertisement.Create($9835);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiser32Uuid.Checked then begin
      Adv := TwclBluetoothLe32ServiceAdvertisement.Create($09039835);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiser128Uuid.Checked then begin
      Adv := TwclBluetoothLe128ServiceAdvertisement.Create(BEACON_UUID);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiser16UuidData.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLe16ServiceDataAdvertisement.Create($9835, Data);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiser32UuidData.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLe32ServiceDataAdvertisement.Create($09039835, Data);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiser128UuidData.Checked then begin
      Data := nil;
      SetLength(Data, 2);
      Data[0] := $12;
      Data[1] := $34;
      Adv := TwclBluetoothLe128ServiceDataAdvertisement.Create(BEACON_UUID,
        Data);
      AddAdvertisement(Adv);
    end;

    if cbAdvertiserCustom.Checked then begin
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

    if LeAdvertiser.Count = 0 then
      ShowMessage('Select at least one advertisement type.')

    else begin
      LeAdvertiser.Interval := StrToInt(edAdvertiserInterval.Text);

      LeAdvertiser.UseExtendedAdvertisement := cbAdvertiserExtended.Checked;
      LeAdvertiser.Anonymous := cbAdvertiserAnonymous.Checked;
      LeAdvertiser.IncludeTxRssi := cbAdvertiserTxRssi.Checked;
      LeAdvertiser.PreferredTxRssi := 10;

      Res := LeAdvertiser.Start(Radio);
      if Res <> WCL_E_SUCCESS then
        Trace('Start advertiser', Res);
    end;
  end;
end;

procedure TfmMain.btAdvertiserStopClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := LeAdvertiser.Stop;
  if Res <> WCL_E_SUCCESS then
    Trace('Advertiser stop', Res);
end;

procedure TfmMain.LeAdvertiserStarted(Sender: TObject);
begin
  Trace('LE Advertiser started');

  AdvertiserEnableControls(False);
end;

procedure TfmMain.LeAdvertiserStopped(Sender: TObject);
begin
  Trace('LE Advertiser stopped');

  AdvertiserEnableControls(True);
end;

procedure TfmMain.BeaconWatcherAppleiBeaconFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleiBeaconFrameData);
begin
  AddFrame(TAppleiBeaconFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleNearbyInfoFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleNearbyInfoFrameData);
begin
  AddFrame(TAppleNearbyInfoFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleNearbyActionFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleNearbyActionFrameData);
begin
  AddFrame(TAppleNearbyActionFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleHomeKitFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleHomeKitFrameData);
begin
  AddFrame(TAppleHomeKitFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleAirplaySourceFrame(
  const Frame: TAppleAirplaySourceFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Data byte', IntToHex(Frame.Data.Data, 2));
end;

procedure TfmMain.ShowAppleAirplayTargetFrame(
  const Frame: TAppleAirplayTargetFrame);
var
  Str: string;
begin
  ShowFrameBaseData(Frame);

  ShowData('Flags', IntToHex(Frame.Data.Flags, 2));
  ShowData('Seed', IntToHex(Frame.Data.Seed, 2));

  Str := IntToStr(Frame.Data.Address shr 24) + '.';
  Str := Str + IntToStr((Frame.Data.Address and $00FF0000) shr 16) + '.';
  Str := Str + IntToStr((Frame.Data.Address and $0000FF00) shr 8) + '.';
  Str := Str + IntToStr(Frame.Data.Address and $000000FF);
  ShowData('IPv4 address', Str);
end;

procedure TfmMain.ShowAppleHomeKitFrame(const Frame: TAppleHomeKitFrame);
var
  Str: string;
  i: Byte;
begin
  ShowFrameBaseData(Frame);

  ShowData('Status', IntToHex(Frame.Data.Status, 2));

  Str := '';
  for i := 0 to 5 do
    Str := Str + IntToHex(Frame.Data.DeviceId[i], 2);
  ShowData('Device ID', Str);

  case Frame.Data.Category of
    $0000: ShowData('Category', 'Unknown');
    $0001: ShowData('Category', 'Other');
    $0002: ShowData('Category', 'Bridge');
    $0003: ShowData('Category', 'Fan');
    $0004: ShowData('Category', 'Garage Door Opener');
    $0005: ShowData('Category', 'Lightbulb');
    $0006: ShowData('Category', 'Door Lock');
    $0007: ShowData('Category', 'Outlet');
    $0008: ShowData('Category', 'Switch');
    $0009: ShowData('Category', 'Thermostat');
    $000A: ShowData('Category', 'Sensor');
    $000B: ShowData('Category', 'Security System');
    $000C: ShowData('Category', 'Door');
    $000D: ShowData('Category', 'Window');
    $000E: ShowData('Category', 'Window Covering');
    $000F: ShowData('Category', 'Programmable Switch');
    $0010: ShowData('Category', 'Range Extender');
    $0011: ShowData('Category', 'IP Camera');
    $0012: ShowData('Category', 'Video Doorbell');
    $0013: ShowData('Category', 'Air Purifier');
    $0014: ShowData('Category', 'Heater');
    $0015: ShowData('Category', 'Air Conditioner');
    $0016: ShowData('Category', 'Humidifier');
    $0017: ShowData('Category', 'Dehumidifier');
    $001C: ShowData('Category', 'Sprinklers');
    $001D: ShowData('Category', 'Faucets');
    $001E: ShowData('Category', 'Shower Systems');
    else ShowData('Category', 'Unknown: 0x' + IntToHex(Frame.Data.Category, 4));
  end;

  ShowData('State Number', IntToHex(Frame.Data.StateNumber, 4));
  ShowData('Config Number', IntToHex(Frame.Data.ConfigNumber, 2));
  ShowData('Version', IntToHex(Frame.Data.Version, 2));
end;

procedure TfmMain.ShowAppleUnknownFrame(const Frame: TAppleUnknownFrame);
var
  Str: string;
  i: Integer;
begin
  ShowFrameBaseData(Frame);

  ShowData('Message ID', IntToHex(Frame.Data.Id, 2));

  if Length(Frame.Data.Payload) > 0 then begin
    Str := '';
    for i := 0 to Length(Frame.Data.Payload) - 1 do
      Str := Str + IntToHex(Frame.Data.Payload[i], 2);
    ShowData('Payload', Str);
  end;
end;

procedure TfmMain.BeaconWatcherAppleUnknownFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleUnknownFrameData);
begin
  AddFrame(TAppleUnknownFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleAirplaySourceFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirplaySourceFrameData);
begin
  AddFrame(TAppleAirplaySourceFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleAirplayTargetFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirplayTargetFrameData);
begin
  AddFrame(TAppleAirplayTargetFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleAirdropFrame(const Frame: TAppleAirdropFrame);
var
  Str: string;
  i: Byte;
begin
  ShowFrameBaseData(Frame);

  Str := '';
  for i := 0 to 7 do
    Str := Str + IntToHex(Frame.Data.Prefix[i], 2);
  ShowData('Prefix', Str);

  ShowData('Version', IntToHex(Frame.Data.Version, 2));
  ShowData('Apple ID', IntToHex(Frame.Data.AppleId, 4));
  ShowData('Phone', IntToHex(Frame.Data.PhoneNumber, 4));
  ShowData('E-Mail', IntToHex(Frame.Data.Email, 4));
  ShowData('E-Mail 2', IntToHex(Frame.Data.Email2, 4));
  ShowData('Suffix', IntToHex(Frame.Data.Suffix, 2));
end;

procedure TfmMain.ShowAppleAirprintFrame(const Frame: TAppleAirprintFrame);
var
  Str: string;
  i: Byte;
begin
  ShowFrameBaseData(Frame);

  ShowData('Address type', IntToHex(Frame.Data.AddressType, 2));
  ShowData('Resource type', IntToHex(Frame.Data.ResourceType, 2));
  ShowData('Security type', IntToHex(Frame.Data.SecurityType, 2));
  ShowData('Port', IntToStr(Frame.Data.Port));

  Str := '';
  for i := 0 to 14 do
    Str := Str + IntToStr(Frame.Data.Address[i]) + '.';
  Str := Str + IntToStr(Frame.Data.Address[15]);
  ShowData('Address', Str);

  ShowData('Power', IntToStr(Frame.Data.Power));
end;

procedure TfmMain.BeaconWatcherAppleAirdropFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirdropFrameData);
begin
  AddFrame(TAppleAirdropFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleAirprintFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleAirprintFrameData);
begin
  AddFrame(TAppleAirprintFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleProximityPairingFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleProximityPairingFrameData);
begin
  AddFrame(TAppleProximityPairingFrame.Create(Info, Data));
end;

procedure TfmMain.BeaconWatcherAppleFindMyFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleFindMyFrameData);
begin
  AddFrame(TAppleFindMyFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleFindMyFrame(const Frame: TAppleFindMyFrame);
var
  Str: string;
  i: Byte;
begin
  ShowFrameBaseData(Frame);

  case Frame.Data.Status of
    $00: ShowData('Status', 'Owner did not connect within key rotation period (15 min.)');
    $24: ShowData('Status', 'Owner connected with key roation period, Battery Full');
    $64: ShowData('Status', 'Owner connected with key roation period, Battery Medium');
    $A4: ShowData('Status', 'Owner connected with key roation period, Battery Low');
    $E4: ShowData('Status', 'Owner connected with key roation period, Battery Critically Low');
    else ShowData('Status', IntToHex(Frame.Data.Status, 2));
  end;

  Str := '';
  for i := 0 to 21 do
    Str := Str + IntToHex(Frame.Data.Key[i], 2);
  ShowData('Key', Str);

  case Frame.Data.KeyBits of
    $00: ShowData('Key bits', 'bits 6 and 7 not set in public key');
    $01: ShowData('Key bits', 'bit 6 set in public key');
    $02: ShowData('Key bits', 'bit 7 set in public key');
    $03: ShowData('Key bits', 'bits 6 and 7 set in public key');
    else ShowData('Key bits', IntToHex(Frame.Data.KeyBits, 2));
  end;

  ShowData('Hint', IntToHex(Frame.Data.Hint, 2));
end;

procedure TfmMain.ShowAppleHandoffFrame(const Frame: TAppleHandoffFrame);
var
  Str: string;
  i: Byte;
begin
  ShowFrameBaseData(Frame);

  if Frame.Data.Clipboard then
    ShowData('Clipboard', 'Yes')
  else
    ShowData('Clipboard', 'No');

  ShowData('Sequence', IntToStr(Frame.Data.Sequence));
  ShowData('Auth tag', IntToHex(Frame.Data.AuthTag, 2));

  Str := '';
  for i := 0 to 9 do
    Str := Str + IntToHex(Frame.Data.Data[i], 2);
  ShowData('Data', Str);
end;

procedure TfmMain.BeaconWatcherAppleHandoffFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleHandoffFrameData);
begin
  AddFrame(TAppleHandoffFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleHeySiriFrame(const Frame: TAppleHeySiriFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Hash', IntToHex(Frame.Data.Hash, 4));
  ShowData('Snr', IntToStr(Frame.Data.Snr));

  case Frame.Data.Confidence of
    $03: ShowData('Confidence', 'Not on Wrist');
    $1F: ShowData('Confidence', 'Wrist detection disabled');
    $3F: ShowData('Confidence', 'On Wrist');
    else ShowData('Confidence', IntToHex(Frame.Data.Confidence, 2));
  end;

  case Frame.Data.DeviceClass of
    $0002: ShowData('Device class', 'iPhone');
    $0003: ShowData('Device class', 'iPad');
    $0007: ShowData('Device class', 'HomePod');
    $0009: ShowData('Device class', 'MacBook');
    $000A: ShowData('Device class', 'Watch');
    else ShowData('Device class', IntToHex(Frame.Data.DeviceClass, 4));
  end;

  ShowData('Rand', IntToHex(Frame.Data.Rand, 2));
end;

procedure TfmMain.BeaconWatcherAppleHeySiriFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleHeySiriFrameData);
begin
  AddFrame(TAppleHeySiriFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleMagicSwitchFrame(
  const Frame: TAppleMagicSwitchFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Data', IntToHex(Frame.Data.Data, 4));

  case Frame.Data.Confidence of
    $03: ShowData('Confidence', 'Not on Wrist');
    $1F: ShowData('Confidence', 'Wrist detection disabled');
    $3F: ShowData('Confidence', 'On Wrist');
    else ShowData('Confidence', IntToHex(Frame.Data.Confidence, 2));
  end;
end;

procedure TfmMain.BeaconWatcherAppleMagicSwitchFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleMagicSwitchFrameData);
begin
  AddFrame(TAppleMagicSwitchFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleTetheringSourceFrame(
  const Frame: TAppleTetheringSourceFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Version', IntToHex(Frame.Data.Version, 2));
  ShowData('Flags', IntToHex(Frame.Data.Flags, 2));
  ShowData('Battery', IntToStr(Frame.Data.Battery));

  case Frame.Data.CellType of
    $0000: ShowData('Cell type', '4G (GSM)');
    $0001: ShowData('Cell type', '1xRTT');
    $0002: ShowData('Cell type', 'GPRS');
    $0003: ShowData('Cell type', 'EDGE');
    $0004: ShowData('Cell type', '3G (EV-DO)');
    $0005: ShowData('Cell type', '3G');
    $0006: ShowData('Cell type', '4G');
    $0007: ShowData('Cell type', 'LTE');
    else ShowData('Cell type', IntToHex(Frame.Data.CellType, 4));
  end;

  ShowData('Bars', IntToStr(Frame.Data.Bars));
end;

procedure TfmMain.BeaconWatcherAppleTetheringSourceFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleTetheringSourceFrameData);
begin
  AddFrame(TAppleTetheringSourceFrame.Create(Info, Data));
end;

procedure TfmMain.ShowAppleTetheringTargetFrame(
  const Frame: TAppleTetheringTargetFrame);
begin
  ShowFrameBaseData(Frame);

  ShowData('Id', IntToHex(Frame.Data.Id, 8));
end;

procedure TfmMain.BeaconWatcherAppleTetheringTargetFrame(Sender: TObject;
  const Info: TwclBluetoothLeAdvertisementInfo;
  const Data: TwclBluetoothLeAppleTetheringTargetFrameData);
begin
  AddFrame(TAppleTetheringTargetFrame.Create(Info, Data));
end;

end.
