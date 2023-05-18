unit main;

{$I wcl.inc}

interface

uses
  Forms, Classes, wclWiFi, Controls, StdCtrls, ComCtrls, wclPowerEvents;

type
  TfmMain = class(TForm)
    btEventsOpen: TButton;
    btEventsClose: TButton;
    lvEvents: TListView;
    btEventsClear: TButton;
    procedure btEventsOpenClick(Sender: TObject);
    procedure btEventsCloseClick(Sender: TObject);
    procedure btEventsClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    wclWiFiEvents: TwclWiFiEvents;
    FPowerMonitor: TwclPowerEventsMonitor;

    procedure wclWiFiEventsAfterOpen(Sender: TObject);
    procedure wclWiFiEventsBeforeClose(Sender: TObject);
    procedure wclWiFiEventsAcmAdHocNetworkStateChange(Sender: TObject;
      const IfaceId: TGUID; const State: TwclWiFiAdHocNetworkState);
    procedure wclWiFiEventsAcmAutoconfDisabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmAutoconfEnabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmBackgroundScanDisabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmBackgroundScanEnabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmBssTypeChange(Sender: TObject;
      const IfaceId: TGUID; const BssType: TwclWiFiBssType);
    procedure wclWiFiEventsAcmConnectionAttemptFail(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure wclWiFiEventsAcmConnectionComplete(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure wclWiFiEventsAcmConnectionStart(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure wclWiFiEventsAcmDisconnected(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure wclWiFiEventsAcmDisconnecting(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure wclWiFiEventsAcmFilterListChange(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmInterfaceArrival(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmInterfaceRemoval(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmNetworkAvailable(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmNetworkNotAvailable(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmOperationalStateChange(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmPowerSettingChange(Sender: TObject;
      const IfaceId: TGUID; const Setting: TwclWiFiPowerSetting);
    procedure wclWiFiEventsAcmProfileBlocked(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmProfileChange(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmProfileNameChange(Sender: TObject;
      const IfaceId: TGUID; const OldName, NewName: String);
    procedure wclWiFiEventsAcmProfilesExhausted(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmProfileUnblocked(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmScanComplete(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmScanFail(Sender: TObject;
      const IfaceId: TGUID; const Reason: Integer);
    procedure wclWiFiEventsAcmScanListRefresh(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsAcmScreenPowerChange(Sender: TObject;
      const IfaceId: TGUID; const SwitchedOn: Boolean);
    procedure wclWiFiEventsHostedNetworkPeerStateChange(Sender: TObject;
      const IfaceId: TGUID; const OldState,
      NewState: TwclWiFiHostedNetworkPeerState; const Reason: Integer);
    procedure wclWiFiEventsHostedNetworkRadioStateChange(Sender: TObject;
      const IfaceId: TGUID; const SoftwareState,
      HardwareState: TwclWiFiRadioState);
    procedure wclWiFiEventsHostedNetworkStateChange(Sender: TObject;
      const IfaceId: TGUID; const OldState,
      NewState: TwclWiFiHostedNetworkState; const Reason: Integer);
    procedure wclWiFiEventsMsmAdapterOperationModeChange(Sender: TObject;
      const IfaceId: TGUID; const Mode: TwclWiFiOperationMode);
    procedure wclWiFiEventsMsmAdapterRemoval(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmAssociated(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmAssociating(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmAuthenticating(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmConnected(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmDisassociating(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmDisconnected(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmPeerJoin(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmPeerLeave(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmRadioStateChange(Sender: TObject;
      const IfaceId: TGUID; const State: TwclWiFiPhyRadioState);
    procedure wclWiFiEventsMsmRoamingEnd(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmRoamingStart(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure wclWiFiEventsMsmSignalQualityChange(Sender: TObject;
      const IfaceId: TGUID; const Quality: Cardinal);
    procedure wclWiFiEventsMsmLinkDegraded(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsMsmLinkImproved(Sender: TObject;
      const IfaceId: TGUID);
    procedure wclWiFiEventsOneXAuthRestarted(Sender: TObject;
      const IfaceId: TGUID; const Reason: Integer);

    procedure wclWiFiEventsIpChanged(Sender: TObject; const IfaceId: TGUID;
      const Old, New: TwclWiFiIpSettings);
    procedure wclWiFiEventsOneXAuthUpdate(Sender: TObject;
      const IfaceId: TGUID; const State: TwclWiFiOneXStatusUpdate);

    procedure TraceEvent(const Iface: PGUID; const EventName: string;
      const ParamName: string; const ParamValue: string);
    procedure TraceAcmConnectionEvent(const IfaceId: TGUID;
      const EventName: string; const Data: TwclWiFiAcmConnectionEventData);
    procedure TraceMsmConnectionEvent(const IfaceId: TGUID;
      const EventName: string; const Data: TwclWiFiMsmConnectionEventData);

    procedure PowerStateChanged(Sender: TObject; const State: TwclPowerState);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

function GetEnumName(const Enum: TwclWiFiAdHocNetworkState): string; overload;
begin
  case Enum of
    asFormed: Result := 'asFormed';
    asConnected: Result := 'asConnected';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiBssType): string; overload;
begin
  case Enum of
    bssInfrastructure: Result := 'bssInfrastructure';
    bssIndependent: Result := 'bssIndependent';
    bssAny: Result := 'bssAny';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiConnectionMode): string; overload;
begin
  case Enum of
    cmProfile: Result := 'cmProfile';
    cmTemporaryProfile: Result := 'cmTemporaryProfile';
    cmDiscoverySecure: Result := 'cmDiscoverySecure';
    cmDiscoveryUnsecure: Result := 'cmDiscoveryUnsecure';
    cmAuto: Result := 'cmAuto';
    cmInvalid: Result := 'cmInvalid';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiConnectionFlag): string; overload;
begin
  case Enum of
    cfAdHocNetworkFormed: Result := 'cfAdHocNetworkFormed';
    cfConsoleUserProfile: Result := 'cfConsoleUserProfile';
  else
    Result := 'UNKNONW';
  end;
end;

function GetEnumName(const Enum: TwclWiFiPowerSetting): string; overload;
begin
  case Enum of
    psNo: Result := 'psNo';
    psLow: Result := 'psLow';
    psMedium: Result := 'psMedium';
    psMaximum: Result := 'psMaximum';
    psInvalid: Result := 'psInvalid';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(
  const Enum: TwclWiFiHostedNetworkPeerAuthState): string; overload;
begin
  case Enum of
    asInvalid: Result := 'asInvalid';
    asAuthenticated: Result := 'asAuthenticated';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiRadioState): string; overload;
begin
  case Enum of
    rsUnknown: Result := 'rsUnknown';
    rsOn: Result := 'rsOn';
    rsOff: Result := 'rsOff';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiHostedNetworkState): string; overload;
begin
  case Enum of
    hnUnavailable: Result := 'hnUnavailable';
    hnIdle: Result := 'hnIdle';
    hnActive: Result := 'hnActive';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiOperationMode): string; overload;
begin
  case Enum of
    omUnknown: Result := 'omUnknown';
    omStation: Result := 'omStation';
    omAccessPoint: Result := 'omAccessPoint';
    omExtensibleStation: Result := 'omExtensibleStation';
    omExtensibleAccessPoint: Result := 'omExtensibleAccessPoint';
    omWiFiDirectDevice: Result := 'omWiFiDirectDevice';
    omWiFiDirectGroupOwner: Result := 'omWiFiDirectGroupOwner';
    omWiFiDirectClient: Result := 'omWiFiDirectClient';
    omManufacturing: Result := 'omManufacturing';
    omNetworkMonitor: Result := 'omNetworkMonitor';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiPhy): string; overload;
begin
  case Enum of
    phyAny: Result := 'phyAny';
    phyFhss: Result := 'phyFhss';
    phyDsss: Result := 'phyDsss';
    phyIr: Result := 'phyIr';
    phyOfdm: Result := 'phyOfdm';
    phyHrDsss: Result := 'phyHrDsss';
    phyErp: Result := 'phyErp';
    phyHt: Result := 'phyHt';
    phyVht: Result := 'phyVht';
    phyUnknown: Result := 'phyUnknown';
  else
    Result := 'UNKNOWN';
  end;
end;

procedure ShowResult(const Res: Integer);
begin
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

{ TfmMain }

procedure TfmMain.btEventsOpenClick(Sender: TObject);
begin
  ShowResult(wclWiFiEvents.Open);
end;

procedure TfmMain.btEventsCloseClick(Sender: TObject);
begin
  ShowResult(wclWiFiEvents.Close);
end;

procedure TfmMain.btEventsClearClick(Sender: TObject);
begin
  lvEvents.Items.Clear;
end;

procedure TfmMain.wclWiFiEventsAfterOpen(Sender: TObject);
begin
  TraceEvent(nil, 'AfterOpen', '', '');
end;

procedure TfmMain.TraceEvent(const Iface: PGUID; const EventName: string;
  const ParamName: string; const ParamValue: string);
var
  Item: TListItem;
  Id: string;
begin
  if Iface = nil then
    Id := ''
  else
    Id := GUIDToString(Iface^);

  Item := lvEvents.Items.Add;
  Item.Caption := Id;
  Item.SubItems.Add(EventName);
  Item.SubItems.Add(ParamName);
  Item.SubItems.Add(ParamValue);
end;

procedure TfmMain.wclWiFiEventsBeforeClose(Sender: TObject);
begin
  TraceEvent(nil, 'BeforeClose', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmAdHocNetworkStateChange(Sender: TObject;
  const IfaceId: TGUID; const State: TwclWiFiAdHocNetworkState);
begin
  TraceEvent(@IfaceId, 'AcmAdHocNetworkStateChange', 'State',
    GetEnumName(State));
end;

procedure TfmMain.wclWiFiEventsAcmAutoconfDisabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmAutoconfDisabled', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmAutoconfEnabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmAutoconfEnabled', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmBackgroundScanDisabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmBackgroundScanDisabled', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmBackgroundScanEnabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmBackgroundScanEnabled', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmBssTypeChange(Sender: TObject;
  const IfaceId: TGUID; const BssType: TwclWiFiBssType);
begin
  TraceEvent(@IfaceId, 'AcmBssTypeChange', 'BSS type', GetEnumName(BssType));
end;

procedure TfmMain.wclWiFiEventsAcmConnectionAttemptFail(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmConnectionAttemptFail', Data);
end;

procedure TfmMain.TraceAcmConnectionEvent(const IfaceId: TGUID;
  const EventName: string; const Data: TwclWiFiAcmConnectionEventData);
var
  Str: string;
  i: TwclWiFiConnectionFlag;
begin
  TraceEvent(@IfaceId, EventName, 'ConnectionMode',
    GetEnumName(Data.ConnectionMode));
  TraceEvent(nil, '', 'Profile name', Data.ProfileName);
  TraceEvent(nil, '', 'SSID', Data.Ssid);
  TraceEvent(nil, '', 'BSS type', GetEnumName(Data.BssType));
  TraceEvent(nil, '', 'Security enabled',
    BoolToStr(Data.SecurityEnabled, True));
  TraceEvent(nil, '', 'Reason', '0x' + IntToHex(Data.Reason, 8));

  Str := '';
  for i := Low(TwclWiFiConnectionFlag) to High(TwclWiFiConnectionFlag) do
    if i in Data.Flags then
      Str := Str + GetEnumName(i) + ' ';
  TraceEvent(nil, '', 'Flags', Str);

  TraceEvent(nil, '', 'Profile XML', Data.ProfileXml);
end;

procedure TfmMain.wclWiFiEventsAcmConnectionComplete(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmConnectionComplete', Data);
end;

procedure TfmMain.wclWiFiEventsAcmConnectionStart(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmConnectionStart', Data);
end;

procedure TfmMain.wclWiFiEventsAcmDisconnected(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmDisconnected', Data);
end;

procedure TfmMain.wclWiFiEventsAcmDisconnecting(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmDisconnecting', Data);
end;

procedure TfmMain.wclWiFiEventsAcmFilterListChange(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmFilterListChange', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmInterfaceArrival(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmInterfaceArrival', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmInterfaceRemoval(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmInterfaceRemoval', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmNetworkAvailable(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmNetworkAvailable', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmNetworkNotAvailable(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmNetworkNotAvailable', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmOperationalStateChange(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmOperationalStateChange', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmPowerSettingChange(Sender: TObject;
  const IfaceId: TGUID; const Setting: TwclWiFiPowerSetting);
begin
  TraceEvent(@IfaceId, 'AcmOperationalStateChange', 'Setting',
    GetEnumName(Setting));
end;

procedure TfmMain.wclWiFiEventsAcmProfileBlocked(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfileBlocked', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmProfileChange(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfileChange', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmProfileNameChange(Sender: TObject;
  const IfaceId: TGUID; const OldName, NewName: String);
begin
  TraceEvent(@IfaceId, 'AcmProfileNameChange', 'OldName', OldName);
  TraceEvent(nil, '', 'NewName', NewName);
end;

procedure TfmMain.wclWiFiEventsAcmProfilesExhausted(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfilesExhausted', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmProfileUnblocked(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfileUnblocked', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmScanComplete(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmScanComplete', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmScanFail(Sender: TObject;
  const IfaceId: TGUID; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'AcmScanFail', 'Reason', '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclWiFiEventsAcmScanListRefresh(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmScanListRefresh', '', '');
end;

procedure TfmMain.wclWiFiEventsAcmScreenPowerChange(Sender: TObject;
  const IfaceId: TGUID; const SwitchedOn: Boolean);
begin
  TraceEvent(@IfaceId, 'AcmScreenPowerChange', 'SwitchedOn',
    BoolToStr(SwitchedOn, True));
end;

procedure TfmMain.wclWiFiEventsHostedNetworkPeerStateChange(
  Sender: TObject; const IfaceId: TGUID; const OldState,
  NewState: TwclWiFiHostedNetworkPeerState; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'HostedNetworkPeerStateChange', 'Old MAC',
    OldState.Mac);
  TraceEvent(nil, '', 'Old authentication state',
    GetEnumName(OldState.AuthState));
  TraceEvent(nil, '', 'New MAC', NewState.Mac);
  TraceEvent(nil, '', 'New authentication state',
    GetEnumName(NewState.AuthState));
  TraceEvent(nil, '', 'Reason', '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclWiFiEventsHostedNetworkRadioStateChange(
  Sender: TObject; const IfaceId: TGUID; const SoftwareState,
  HardwareState: TwclWiFiRadioState);
begin
  TraceEvent(@IfaceId, 'HostedNetworkRadioStateChange', 'Software state',
    GetEnumName(SoftwareState));
  TraceEvent(nil, '', 'Hardware state', GetEnumName(HardwareState));
end;

procedure TfmMain.wclWiFiEventsHostedNetworkStateChange(Sender: TObject;
  const IfaceId: TGUID; const OldState,
  NewState: TwclWiFiHostedNetworkState; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'HostedNetworkStateChange', 'Old state',
    GetEnumName(OldState));
  TraceEvent(nil, '', 'New state', GetEnumName(NewState));
  TraceEvent(nil, '', 'Reason', '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclWiFiEventsMsmAdapterOperationModeChange(
  Sender: TObject; const IfaceId: TGUID;
  const Mode: TwclWiFiOperationMode);
begin
  TraceEvent(@IfaceId, 'MsmAdapterOperationModeChange', 'Mode',
    GetEnumName(Mode));
end;

procedure TfmMain.wclWiFiEventsMsmAdapterRemoval(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAdapterRemoval', Data);
end;

procedure TfmMain.wclWiFiEventsMsmAssociated(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAssociated', Data);
end;

procedure TfmMain.wclWiFiEventsMsmAssociating(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAssociating', Data);
end;

procedure TfmMain.wclWiFiEventsMsmAuthenticating(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAuthenticating', Data);
end;

procedure TfmMain.wclWiFiEventsMsmConnected(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmConnected', Data);
end;

procedure TfmMain.wclWiFiEventsMsmDisassociating(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmDisassociating', Data);
end;

procedure TfmMain.wclWiFiEventsMsmDisconnected(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmDisconnected', Data);
end;

procedure TfmMain.wclWiFiEventsMsmPeerJoin(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmPeerJoin', Data);
end;

procedure TfmMain.wclWiFiEventsMsmPeerLeave(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmPeerLeave', Data);
end;

procedure TfmMain.wclWiFiEventsMsmRadioStateChange(Sender: TObject;
  const IfaceId: TGUID; const State: TwclWiFiPhyRadioState);
begin
  TraceEvent(@IfaceId, 'MsmRadioStateChange', 'PHY', GetEnumName(State.Phy));
  TraceEvent(nil, '', 'Software state', GetEnumName(State.SoftwareState));
  TraceEvent(nil, '', 'Hardware state', GetEnumName(State.HardwareState));
end;

procedure TfmMain.wclWiFiEventsMsmRoamingEnd(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmRoamingEnd', Data);
end;

procedure TfmMain.wclWiFiEventsMsmRoamingStart(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmRoamingStart', Data);
end;

procedure TfmMain.wclWiFiEventsMsmSignalQualityChange(Sender: TObject;
  const IfaceId: TGUID; const Quality: Cardinal);
begin
  TraceEvent(@IfaceId, 'MsmSignalQualityChange', 'Quality', IntToStr(Quality));
end;

procedure TfmMain.TraceMsmConnectionEvent(const IfaceId: TGUID;
  const EventName: string; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceEvent(@IfaceId, EventName, 'ConnectionMode',
    GetEnumName(Data.ConnectionMode));
  TraceEvent(nil, '', 'Profile name', Data.ProfileName);
  TraceEvent(nil, '', 'SSID', Data.Ssid);
  TraceEvent(nil, '', 'BSS type', GetEnumName(Data.BssType));
  TraceEvent(nil, '', 'MAC', Data.Mac);
  TraceEvent(nil, '', 'Security enabled',
    BoolToStr(Data.SecurityEnabled, True));
  TraceEvent(nil, '', 'First peer', BoolToStr(Data.FirstPeer, True));
  TraceEvent(nil, '', 'Last peer', BoolToStr(Data.LastPeer, True));
  TraceEvent(nil, '', 'Reason', '0x' + IntToHex(Data.Reason, 8));
end;

procedure TfmMain.wclWiFiEventsOneXAuthRestarted(Sender: TObject;
  const IfaceId: TGUID; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'OneXAuthRestarted', 'Reason',
    '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclWiFiEvents.Close;
  wclWiFiEvents.Free;
  
  FPowerMonitor.Close;
  FPowerMonitor.Free;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclWiFiEvents := TwclWiFiEvents.Create(nil);
  wclWiFiEvents.AfterOpen := wclWiFiEventsAfterOpen;
  wclWiFiEvents.BeforeClose := wclWiFiEventsBeforeClose;
  wclWiFiEvents.OnAcmAdHocNetworkStateChange := wclWiFiEventsAcmAdHocNetworkStateChange;
  wclWiFiEvents.OnAcmAutoconfDisabled := wclWiFiEventsAcmAutoconfDisabled;
  wclWiFiEvents.OnAcmAutoconfEnabled := wclWiFiEventsAcmAutoconfEnabled;
  wclWiFiEvents.OnAcmBackgroundScanDisabled := wclWiFiEventsAcmBackgroundScanDisabled;
  wclWiFiEvents.OnAcmBackgroundScanEnabled := wclWiFiEventsAcmBackgroundScanEnabled;
  wclWiFiEvents.OnAcmBssTypeChange := wclWiFiEventsAcmBssTypeChange;
  wclWiFiEvents.OnAcmConnectionAttemptFail := wclWiFiEventsAcmConnectionAttemptFail;
  wclWiFiEvents.OnAcmConnectionComplete := wclWiFiEventsAcmConnectionComplete;
  wclWiFiEvents.OnAcmConnectionStart := wclWiFiEventsAcmConnectionStart;
  wclWiFiEvents.OnAcmDisconnected := wclWiFiEventsAcmDisconnected;
  wclWiFiEvents.OnAcmDisconnecting := wclWiFiEventsAcmDisconnecting;
  wclWiFiEvents.OnAcmFilterListChange := wclWiFiEventsAcmFilterListChange;
  wclWiFiEvents.OnAcmInterfaceArrival := wclWiFiEventsAcmInterfaceArrival;
  wclWiFiEvents.OnAcmInterfaceRemoval := wclWiFiEventsAcmInterfaceRemoval;
  wclWiFiEvents.OnAcmNetworkAvailable := wclWiFiEventsAcmNetworkAvailable;
  wclWiFiEvents.OnAcmNetworkNotAvailable := wclWiFiEventsAcmNetworkNotAvailable;
  wclWiFiEvents.OnAcmOperationalStateChange := wclWiFiEventsAcmOperationalStateChange;
  wclWiFiEvents.OnAcmPowerSettingChange := wclWiFiEventsAcmPowerSettingChange;
  wclWiFiEvents.OnAcmProfileBlocked := wclWiFiEventsAcmProfileBlocked;
  wclWiFiEvents.OnAcmProfileChange := wclWiFiEventsAcmProfileChange;
  wclWiFiEvents.OnAcmProfileNameChange := wclWiFiEventsAcmProfileNameChange;
  wclWiFiEvents.OnAcmProfilesExhausted := wclWiFiEventsAcmProfilesExhausted;
  wclWiFiEvents.OnAcmProfileUnblocked := wclWiFiEventsAcmProfileUnblocked;
  wclWiFiEvents.OnAcmScanComplete := wclWiFiEventsAcmScanComplete;
  wclWiFiEvents.OnAcmScanFail := wclWiFiEventsAcmScanFail;
  wclWiFiEvents.OnAcmScanListRefresh := wclWiFiEventsAcmScanListRefresh;
  wclWiFiEvents.OnAcmScreenPowerChange := wclWiFiEventsAcmScreenPowerChange;
  wclWiFiEvents.OnHostedNetworkPeerStateChange := wclWiFiEventsHostedNetworkPeerStateChange;
  wclWiFiEvents.OnHostedNetworkRadioStateChange := wclWiFiEventsHostedNetworkRadioStateChange;
  wclWiFiEvents.OnHostedNetworkStateChange := wclWiFiEventsHostedNetworkStateChange;
  wclWiFiEvents.OnMsmAdapterOperationModeChange := wclWiFiEventsMsmAdapterOperationModeChange;
  wclWiFiEvents.OnMsmAdapterRemoval := wclWiFiEventsMsmAdapterRemoval;
  wclWiFiEvents.OnMsmAssociated := wclWiFiEventsMsmAssociated;
  wclWiFiEvents.OnMsmAssociating := wclWiFiEventsMsmAssociating;
  wclWiFiEvents.OnMsmAuthenticating := wclWiFiEventsMsmAuthenticating;
  wclWiFiEvents.OnMsmConnected := wclWiFiEventsMsmConnected;
  wclWiFiEvents.OnMsmDisassociating := wclWiFiEventsMsmDisassociating;
  wclWiFiEvents.OnMsmDisconnected := wclWiFiEventsMsmDisconnected;
  wclWiFiEvents.OnMsmPeerJoin := wclWiFiEventsMsmPeerJoin;
  wclWiFiEvents.OnMsmPeerLeave := wclWiFiEventsMsmPeerLeave;
  wclWiFiEvents.OnMsmRadioStateChange := wclWiFiEventsMsmRadioStateChange;
  wclWiFiEvents.OnMsmRoamingEnd := wclWiFiEventsMsmRoamingEnd;
  wclWiFiEvents.OnMsmRoamingStart := wclWiFiEventsMsmRoamingStart;
  wclWiFiEvents.OnMsmSignalQualityChange := wclWiFiEventsMsmSignalQualityChange;
  wclWiFiEvents.OnMsmLinkDegraded := wclWiFiEventsMsmLinkDegraded;
  wclWiFiEvents.OnMsmLinkImproved := wclWiFiEventsMsmLinkImproved;
  wclWiFiEvents.OnOneXAuthRestarted := wclWiFiEventsOneXAuthRestarted;
  wclWiFiEvents.OnOneXAuthUpdate := wclWiFiEventsOneXAuthUpdate;
  wclWiFiEvents.OnIpChanged := wclWiFiEventsIpChanged;

  FPowerMonitor := TwclPowerEventsMonitor.Create;
  FPowerMonitor.OnPowerStateChanged := PowerStateChanged;
  FPowerMonitor.Open;
end;

procedure TfmMain.PowerStateChanged(Sender: TObject;
  const State: TwclPowerState);
begin
  case State of
    psResumeAutomatic:
      TraceEvent(nil, 'Power', 'State', 'psResumeAutomatic');
    psResume:
      TraceEvent(nil, 'Power', 'State', 'psResume');
    psSuspend:
      TraceEvent(nil, 'Power', 'State', 'psSuspend');
    psUnknown:
      TraceEvent(nil, 'Power', 'State', 'psUnknown');
  end;
end;

procedure TfmMain.wclWiFiEventsIpChanged(Sender: TObject;
  const IfaceId: TGUID; const Old, New: TwclWiFiIpSettings);
begin
  TraceEvent(@IfaceId, 'IP changed', 'Old address', Old.Address);
  TraceEvent(nil, '', 'New address', New.Address);
end;

procedure TfmMain.wclWiFiEventsOneXAuthUpdate(Sender: TObject;
  const IfaceId: TGUID; const State: TwclWiFiOneXStatusUpdate);
var
  Str: string;
begin
  case State.Status.Status of
    oxAuthNotStarted:
      Str := 'oxAuthNotStarted';
    oxAuthInProgress:
      Str := 'oxAuthInProgress';
    oxAuthNoAuthenticatorFound:
      Str := 'oxAuthNoAuthenticatorFound';
    oxAuthSuccess:
      Str := 'oxAuthSuccess';
    oxAuthFailure:
      Str := 'oxAuthFailure';
    oxAuthInvalid:
      Str := 'oxAuthInvalid';
    else
      Str := '';
  end;
  TraceEvent(@IfaceId, 'OneXAuthUpdate', 'Status', Str);
  TraceEvent(nil, '', 'Status.Reason', '0x' + IntToHex(State.Status.Reason, 8));
  TraceEvent(nil, '', 'Status.Error', '0x' + IntToHex(State.Status.Error, 8));

  case State.BackendSupport of
    oxEapMethodBackendSupportUnknown:
      Str := 'oxEapMethodBackendSupportUnknown';
    oxEapMethodBackendSupported:
      Str := 'oxEapMethodBackendSupported';
    oxEapMethodBackendUnsupported:
      Str := 'oxEapMethodBackendUnsupported';
    else
      Str := '';
  end;
  TraceEvent(nil, '', 'BackendSupport', Str);

  if State.BackendEngaged then
    TraceEvent(nil, '', 'BackendEngaged', 'True')
  else
    TraceEvent(nil, '', 'BackendEngaged', 'False');

  if State.AuthParams.UpdatePending then
    TraceEvent(nil, '', 'AuthParams.UpdatePending', 'True')
  else
    TraceEvent(nil, '', 'AuthParams.UpdatePending', 'False');

  case State.AuthParams.Profile.SupplicantMode of
    oxSupplicantModeInhibitTransmission:
      Str := 'oxSupplicantModeInhibitTransmission';
    oxSupplicantModeLearn:
      Str := 'oxSupplicantModeLearn';
    oxSupplicantModeCompliant:
      Str := 'oxSupplicantModeCompliant';
    oxSupplicantModeInvalid:
      Str := 'oxSupplicantModeInvalid';
    else
      Str := '';
  end;
  TraceEvent(nil, '', 'AuthParams.Profile.SupplicantMode', Str);

  case State.AuthParams.Profile.AuthMode of
    oxAuthModeMachineOrUser:
      Str := 'oxAuthModeMachineOrUser';
    oxAuthModeMachineOnly:
      Str := 'oxAuthModeMachineOnly';
    oxAuthModeUserOnly:
      Str := 'oxAuthModeUserOnly';
    oxAuthModeGuest:
      Str := 'oxAuthModeGuest';
    oxAuthModeUnspecified:
      Str := 'oxAuthModeUnspecified';
    oxAuthModeInvalid:
      Str := 'oxAuthModeInvalid';
    else
      Str := '';
  end;
  TraceEvent(nil, '', 'AuthParams.Profile.AuthMode', Str);

  TraceEvent(nil, '', 'AuthParams.Profile.HeldPeriod',
    IntToStr(State.AuthParams.Profile.HeldPeriod));
  TraceEvent(nil, '', 'AuthParams.Profile.AuthPeriod',
    IntToStr(State.AuthParams.Profile.AuthPeriod));
  TraceEvent(nil, '', 'AuthParams.Profile.StartPeriod',
    IntToStr(State.AuthParams.Profile.StartPeriod));
  TraceEvent(nil, '', 'AuthParams.Profile.MaxStart',
    IntToStr(State.AuthParams.Profile.MaxStart));
  TraceEvent(nil, '', 'AuthParams.Profile.MaxAuthFailures',
    IntToStr(State.AuthParams.Profile.MaxAuthFailures));
  TraceEvent(nil, '', 'AuthParams.Profile.NetworkAuthTimeout',
    IntToStr(State.AuthParams.Profile.NetworkAuthTimeout));
  TraceEvent(nil, '', 'AuthParams.Profile.NetworkAuthWithUITimeout',
    IntToStr(State.AuthParams.Profile.NetworkAuthWithUITimeout));

  if State.AuthParams.Profile.AllowLogonDialogs then
    TraceEvent(nil, '', 'AuthParams.Profile.AllowLogonDialogs', 'True')
  else
    TraceEvent(nil, '', 'AuthParams.Profile.AllowLogonDialogs', 'False');

  if State.AuthParams.Profile.UserBasedVLan then
    TraceEvent(nil, '', 'AuthParams.Profile.UserBasedVLan', 'True')
  else
    TraceEvent(nil, '', 'AuthParams.Profile.UserBasedVLan', 'False');

  case State.AuthParams.AuthIdentity of
    oxAuthIdentityNone:
      Str := '';
    oxAuthIdentityMachine:
      Str := '';
    oxAuthIdentityUser:
      Str := '';
    oxAuthIdentityExplicitUser:
      Str := '';
    oxAuthIdentityGuest:
      Str := '';
    oxAuthIdentityInvalid:
      Str := '';
    oxAuthIdentityUnknown:
      Str := '';
    else
      Str := '';
  end;
  TraceEvent(nil, '', 'AuthParams.AuthIdentity', Str);

  case State.AuthParams.QuarantineState of
    isUnknonw:
      Str := 'isUnknonw';
    isNotRestricted:
      Str := 'isNotRestricted';
    isInProbation:
      Str := 'isInProbation';
    isRestrictedAccess:
      Str := 'isRestrictedAccess';
    isInvalid:
      Str := 'isInvalid';
    else
      Str := '';
  end;
  TraceEvent(nil, '', 'AuthParams.QuarantineState', Str);

  TraceEvent(nil, '', 'AuthParams.SessiondId',
    IntToStr(State.AuthParams.SessiondId));
  TraceEvent(nil, '', 'AuthParams.Identity', State.AuthParams.Identity);
  TraceEvent(nil, '', 'AuthParams.UserName', State.AuthParams.UserName);
  TraceEvent(nil, '', 'AuthParams.Domain', State.AuthParams.Domain);

  TraceEvent(nil, '', 'EapError.Error', '0x' + IntToHex(State.EapError.Error, 8));

  TraceEvent(nil, '', 'EapError.MethodType.EapType.EapType',
    IntToStr(State.EapError.MethodType.EapType.EapType));
  TraceEvent(nil, '', 'EapError.MethodType.EapType.VendorId',
    IntToStr(State.EapError.MethodType.EapType.VendorId));
  TraceEvent(nil, '', 'EapError.MethodType.EapType.VendorType',
    IntToStr(State.EapError.MethodType.EapType.VendorType));

  TraceEvent(nil, '', 'EapError.MethodType.AuthorId',
    IntToStr(State.EapError.MethodType.AuthorId));

  TraceEvent(nil, '', 'EapError.Reason', '0x' + IntToHex(State.EapError.Reason, 8));
  TraceEvent(nil, '', 'EapError.RootCauseGuid',
    GUIDToString(State.EapError.RootCauseGuid));
  TraceEvent(nil, '', 'EapError.RepairGuid',
    GUIDToString(State.EapError.RepairGuid));
  TraceEvent(nil, '', 'EapError.HelpLinkGuid',
    GUIDToString(State.EapError.HelpLinkGuid));
  TraceEvent(nil, '', 'EapError.RootCauseString', State.EapError.RootCauseString);
  TraceEvent(nil, '', 'EapError.RepairString', State.EapError.RepairString);
end;

procedure TfmMain.wclWiFiEventsMsmLinkDegraded(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'MsmLinkDegraded', '', '');
end;

procedure TfmMain.wclWiFiEventsMsmLinkImproved(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'MsmLinkImproved', '', '');
end;

end.
