unit main;

{$MODE Delphi}

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
    WiFiEvents: TwclWiFiEvents;
    PowerMonitor: TwclPowerEventsMonitor;

    procedure TraceEvent(const Iface: PGUID; const EventName: string;
      const ParamName: string; const ParamValue: string);
    procedure TraceAcmConnectionEvent(const IfaceId: TGUID;
      const EventName: string; const Data: TwclWiFiAcmConnectionEventData);
    procedure TraceMsmConnectionEvent(const IfaceId: TGUID;
      const EventName: string; const Data: TwclWiFiMsmConnectionEventData);

    procedure PowerStateChanged(Sender: TObject; const State: TwclPowerState);

    procedure WiFiEventsAfterOpen(Sender: TObject);
    procedure WiFiEventsBeforeClose(Sender: TObject);
    procedure WiFiEventsAcmAdHocNetworkStateChange(Sender: TObject;
      const IfaceId: TGUID; const State: TwclWiFiAdHocNetworkState);
    procedure WiFiEventsAcmAutoconfDisabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmAutoconfEnabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmBackgroundScanDisabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmBackgroundScanEnabled(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmBssTypeChange(Sender: TObject;
      const IfaceId: TGUID; const BssType: TwclWiFiBssType);
    procedure WiFiEventsAcmConnectionAttemptFail(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure WiFiEventsAcmConnectionComplete(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure WiFiEventsAcmConnectionStart(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure WiFiEventsAcmDisconnected(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure WiFiEventsAcmDisconnecting(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
    procedure WiFiEventsAcmFilterListChange(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmInterfaceArrival(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmInterfaceRemoval(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmNetworkAvailable(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmNetworkNotAvailable(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmOperationalStateChange(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmPowerSettingChange(Sender: TObject;
      const IfaceId: TGUID; const Setting: TwclWiFiPowerSetting);
    procedure WiFiEventsAcmProfileBlocked(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmProfileChange(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmProfileNameChange(Sender: TObject;
      const IfaceId: TGUID; const OldName, NewName: String);
    procedure WiFiEventsAcmProfilesExhausted(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmProfileUnblocked(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmScanComplete(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmScanFail(Sender: TObject;
      const IfaceId: TGUID; const Reason: Integer);
    procedure WiFiEventsAcmScanListRefresh(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsAcmScreenPowerChange(Sender: TObject;
      const IfaceId: TGUID; const SwitchedOn: Boolean);
    procedure WiFiEventsHostedNetworkPeerStateChange(Sender: TObject;
      const IfaceId: TGUID; const OldState,
      NewState: TwclWiFiHostedNetworkPeerState; const Reason: Integer);
    procedure WiFiEventsHostedNetworkRadioStateChange(Sender: TObject;
      const IfaceId: TGUID; const SoftwareState,
      HardwareState: TwclWiFiRadioState);
    procedure WiFiEventsHostedNetworkStateChange(Sender: TObject;
      const IfaceId: TGUID; const OldState,
      NewState: TwclWiFiHostedNetworkState; const Reason: Integer);
    procedure WiFiEventsMsmAdapterOperationModeChange(Sender: TObject;
      const IfaceId: TGUID; const Mode: TwclWiFiOperationMode);
    procedure WiFiEventsMsmAdapterRemoval(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmAssociated(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmAssociating(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmAuthenticating(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmConnected(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmDisassociating(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmDisconnected(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmPeerJoin(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmPeerLeave(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmRadioStateChange(Sender: TObject;
      const IfaceId: TGUID; const State: TwclWiFiPhyRadioState);
    procedure WiFiEventsMsmRoamingEnd(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmRoamingStart(Sender: TObject;
      const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
    procedure WiFiEventsMsmSignalQualityChange(Sender: TObject;
      const IfaceId: TGUID; const Quality: Cardinal);
    procedure WiFiEventsOneXAuthRestarted(Sender: TObject;
      const IfaceId: TGUID; const Reason: Integer);
    procedure WiFiEventsIpChanged(Sender: TObject; const IfaceId: TGUID;
      const Old, New: TwclWiFiIpSettings);
    procedure WiFiEventsOneXAuthUpdate(Sender: TObject;
      const IfaceId: TGUID; const State: TwclWiFiOneXStatusUpdate);
    procedure WiFiEventsMsmLinkDegraded(Sender: TObject;
      const IfaceId: TGUID);
    procedure WiFiEventsMsmLinkImproved(Sender: TObject;
      const IfaceId: TGUID);
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
  ShowResult(WiFiEvents.Open);
end;

procedure TfmMain.btEventsCloseClick(Sender: TObject);
begin
  ShowResult(WiFiEvents.Close);
end;

procedure TfmMain.btEventsClearClick(Sender: TObject);
begin
  lvEvents.Items.Clear;
end;

procedure TfmMain.WiFiEventsAfterOpen(Sender: TObject);
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

procedure TfmMain.WiFiEventsBeforeClose(Sender: TObject);
begin
  TraceEvent(nil, 'BeforeClose', '', '');
end;

procedure TfmMain.WiFiEventsAcmAdHocNetworkStateChange(Sender: TObject;
  const IfaceId: TGUID; const State: TwclWiFiAdHocNetworkState);
begin
  TraceEvent(@IfaceId, 'AcmAdHocNetworkStateChange', 'State',
    GetEnumName(State));
end;

procedure TfmMain.WiFiEventsAcmAutoconfDisabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmAutoconfDisabled', '', '');
end;

procedure TfmMain.WiFiEventsAcmAutoconfEnabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmAutoconfEnabled', '', '');
end;

procedure TfmMain.WiFiEventsAcmBackgroundScanDisabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmBackgroundScanDisabled', '', '');
end;

procedure TfmMain.WiFiEventsAcmBackgroundScanEnabled(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmBackgroundScanEnabled', '', '');
end;

procedure TfmMain.WiFiEventsAcmBssTypeChange(Sender: TObject;
  const IfaceId: TGUID; const BssType: TwclWiFiBssType);
begin
  TraceEvent(@IfaceId, 'AcmBssTypeChange', 'BSS type', GetEnumName(BssType));
end;

procedure TfmMain.WiFiEventsAcmConnectionAttemptFail(Sender: TObject;
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
  for i := Low(TwclWiFiConnectionFlag) to High(TwclWiFiConnectionFlag) do begin
    if i in Data.Flags then
      Str := Str + GetEnumName(i) + ' ';
  end;
  TraceEvent(nil, '', 'Flags', Str);

  TraceEvent(nil, '', 'Profile XML', Data.ProfileXml);
end;

procedure TfmMain.WiFiEventsAcmConnectionComplete(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmConnectionComplete', Data);
end;

procedure TfmMain.WiFiEventsAcmConnectionStart(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmConnectionStart', Data);
end;

procedure TfmMain.WiFiEventsAcmDisconnected(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmDisconnected', Data);
end;

procedure TfmMain.WiFiEventsAcmDisconnecting(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiAcmConnectionEventData);
begin
  TraceAcmConnectionEvent(IfaceId, 'AcmDisconnecting', Data);
end;

procedure TfmMain.WiFiEventsAcmFilterListChange(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmFilterListChange', '', '');
end;

procedure TfmMain.WiFiEventsAcmInterfaceArrival(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmInterfaceArrival', '', '');
end;

procedure TfmMain.WiFiEventsAcmInterfaceRemoval(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmInterfaceRemoval', '', '');
end;

procedure TfmMain.WiFiEventsAcmNetworkAvailable(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmNetworkAvailable', '', '');
end;

procedure TfmMain.WiFiEventsAcmNetworkNotAvailable(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmNetworkNotAvailable', '', '');
end;

procedure TfmMain.WiFiEventsAcmOperationalStateChange(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmOperationalStateChange', '', '');
end;

procedure TfmMain.WiFiEventsAcmPowerSettingChange(Sender: TObject;
  const IfaceId: TGUID; const Setting: TwclWiFiPowerSetting);
begin
  TraceEvent(@IfaceId, 'AcmOperationalStateChange', 'Setting',
    GetEnumName(Setting));
end;

procedure TfmMain.WiFiEventsAcmProfileBlocked(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfileBlocked', '', '');
end;

procedure TfmMain.WiFiEventsAcmProfileChange(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfileChange', '', '');
end;

procedure TfmMain.WiFiEventsAcmProfileNameChange(Sender: TObject;
  const IfaceId: TGUID; const OldName, NewName: String);
begin
  TraceEvent(@IfaceId, 'AcmProfileNameChange', 'OldName', OldName);
  TraceEvent(nil, '', 'NewName', NewName);
end;

procedure TfmMain.WiFiEventsAcmProfilesExhausted(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfilesExhausted', '', '');
end;

procedure TfmMain.WiFiEventsAcmProfileUnblocked(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmProfileUnblocked', '', '');
end;

procedure TfmMain.WiFiEventsAcmScanComplete(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmScanComplete', '', '');
end;

procedure TfmMain.WiFiEventsAcmScanFail(Sender: TObject;
  const IfaceId: TGUID; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'AcmScanFail', 'Reason', '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.WiFiEventsAcmScanListRefresh(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'AcmScanListRefresh', '', '');
end;

procedure TfmMain.WiFiEventsAcmScreenPowerChange(Sender: TObject;
  const IfaceId: TGUID; const SwitchedOn: Boolean);
begin
  TraceEvent(@IfaceId, 'AcmScreenPowerChange', 'SwitchedOn',
    BoolToStr(SwitchedOn, True));
end;

procedure TfmMain.WiFiEventsHostedNetworkPeerStateChange(
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

procedure TfmMain.WiFiEventsHostedNetworkRadioStateChange(
  Sender: TObject; const IfaceId: TGUID; const SoftwareState,
  HardwareState: TwclWiFiRadioState);
begin
  TraceEvent(@IfaceId, 'HostedNetworkRadioStateChange', 'Software state',
    GetEnumName(SoftwareState));
  TraceEvent(nil, '', 'Hardware state', GetEnumName(HardwareState));
end;

procedure TfmMain.WiFiEventsHostedNetworkStateChange(Sender: TObject;
  const IfaceId: TGUID; const OldState,
  NewState: TwclWiFiHostedNetworkState; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'HostedNetworkStateChange', 'Old state',
    GetEnumName(OldState));
  TraceEvent(nil, '', 'New state', GetEnumName(NewState));
  TraceEvent(nil, '', 'Reason', '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.WiFiEventsMsmAdapterOperationModeChange(
  Sender: TObject; const IfaceId: TGUID;
  const Mode: TwclWiFiOperationMode);
begin
  TraceEvent(@IfaceId, 'MsmAdapterOperationModeChange', 'Mode',
    GetEnumName(Mode));
end;

procedure TfmMain.WiFiEventsMsmAdapterRemoval(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAdapterRemoval', Data);
end;

procedure TfmMain.WiFiEventsMsmAssociated(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAssociated', Data);
end;

procedure TfmMain.WiFiEventsMsmAssociating(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAssociating', Data);
end;

procedure TfmMain.WiFiEventsMsmAuthenticating(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmAuthenticating', Data);
end;

procedure TfmMain.WiFiEventsMsmConnected(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmConnected', Data);
end;

procedure TfmMain.WiFiEventsMsmDisassociating(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmDisassociating', Data);
end;

procedure TfmMain.WiFiEventsMsmDisconnected(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmDisconnected', Data);
end;

procedure TfmMain.WiFiEventsMsmPeerJoin(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmPeerJoin', Data);
end;

procedure TfmMain.WiFiEventsMsmPeerLeave(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmPeerLeave', Data);
end;

procedure TfmMain.WiFiEventsMsmRadioStateChange(Sender: TObject;
  const IfaceId: TGUID; const State: TwclWiFiPhyRadioState);
begin
  TraceEvent(@IfaceId, 'MsmRadioStateChange', 'PHY', GetEnumName(State.Phy));
  TraceEvent(nil, '', 'Software state', GetEnumName(State.SoftwareState));
  TraceEvent(nil, '', 'Hardware state', GetEnumName(State.HardwareState));
end;

procedure TfmMain.WiFiEventsMsmRoamingEnd(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmRoamingEnd', Data);
end;

procedure TfmMain.WiFiEventsMsmRoamingStart(Sender: TObject;
  const IfaceId: TGUID; const Data: TwclWiFiMsmConnectionEventData);
begin
  TraceMsmConnectionEvent(IfaceId, 'MsmRoamingStart', Data);
end;

procedure TfmMain.WiFiEventsMsmSignalQualityChange(Sender: TObject;
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

procedure TfmMain.WiFiEventsOneXAuthRestarted(Sender: TObject;
  const IfaceId: TGUID; const Reason: Integer);
begin
  TraceEvent(@IfaceId, 'OneXAuthRestarted', 'Reason',
    '0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  WiFiEvents.Close;
  WiFiEvents.Free;

  PowerMonitor.Close;
  PowerMonitor.Free;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  WiFiEvents := TwclWiFiEvents.Create(nil);
  WiFiEvents.AfterOpen := WiFiEventsAfterOpen;
  WiFiEvents.BeforeClose := WiFiEventsBeforeClose;

  WiFiEvents.OnAcmAdHocNetworkStateChange := WiFiEventsAcmAdHocNetworkStateChange;
  WiFiEvents.OnAcmAutoconfDisabled := WiFiEventsAcmAutoconfDisabled;
  WiFiEvents.OnAcmAutoconfEnabled := WiFiEventsAcmAutoconfEnabled;
  WiFiEvents.OnAcmBackgroundScanDisabled := WiFiEventsAcmBackgroundScanDisabled;
  WiFiEvents.OnAcmBackgroundScanEnabled := WiFiEventsAcmBackgroundScanEnabled;
  WiFiEvents.OnAcmBssTypeChange := WiFiEventsAcmBssTypeChange;
  WiFiEvents.OnAcmConnectionAttemptFail := WiFiEventsAcmConnectionAttemptFail;
  WiFiEvents.OnAcmConnectionComplete := WiFiEventsAcmConnectionComplete;
  WiFiEvents.OnAcmConnectionStart := WiFiEventsAcmConnectionStart;
  WiFiEvents.OnAcmDisconnected := WiFiEventsAcmDisconnected;
  WiFiEvents.OnAcmDisconnecting := WiFiEventsAcmDisconnecting;
  WiFiEvents.OnAcmFilterListChange := WiFiEventsAcmFilterListChange;
  WiFiEvents.OnAcmInterfaceArrival := WiFiEventsAcmInterfaceArrival;
  WiFiEvents.OnAcmInterfaceRemoval := WiFiEventsAcmInterfaceRemoval;
  WiFiEvents.OnAcmNetworkAvailable := WiFiEventsAcmNetworkAvailable;
  WiFiEvents.OnAcmNetworkNotAvailable := WiFiEventsAcmNetworkNotAvailable;
  WiFiEvents.OnAcmOperationalStateChange := WiFiEventsAcmOperationalStateChange;
  WiFiEvents.OnAcmPowerSettingChange := WiFiEventsAcmPowerSettingChange;
  WiFiEvents.OnAcmProfileBlocked := WiFiEventsAcmProfileBlocked;
  WiFiEvents.OnAcmProfileChange := WiFiEventsAcmProfileChange;
  WiFiEvents.OnAcmProfileNameChange := WiFiEventsAcmProfileNameChange;
  WiFiEvents.OnAcmProfilesExhausted := WiFiEventsAcmProfilesExhausted;
  WiFiEvents.OnAcmProfileUnblocked := WiFiEventsAcmProfileUnblocked;
  WiFiEvents.OnAcmScanComplete := WiFiEventsAcmScanComplete;
  WiFiEvents.OnAcmScanFail := WiFiEventsAcmScanFail;
  WiFiEvents.OnAcmScanListRefresh := WiFiEventsAcmScanListRefresh;
  WiFiEvents.OnAcmScreenPowerChange := WiFiEventsAcmScreenPowerChange;

  WiFiEvents.OnHostedNetworkPeerStateChange := WiFiEventsHostedNetworkPeerStateChange;
  WiFiEvents.OnHostedNetworkRadioStateChange := WiFiEventsHostedNetworkRadioStateChange;
  WiFiEvents.OnHostedNetworkStateChange := WiFiEventsHostedNetworkStateChange;

  WiFiEvents.OnIpChanged := WiFiEventsIpChanged;

  WiFiEvents.OnMsmAdapterOperationModeChange := WiFiEventsMsmAdapterOperationModeChange;
  WiFiEvents.OnMsmAdapterRemoval := WiFiEventsMsmAdapterRemoval;
  WiFiEvents.OnMsmAssociated := WiFiEventsMsmAssociated;
  WiFiEvents.OnMsmAssociating := WiFiEventsMsmAssociating;
  WiFiEvents.OnMsmAuthenticating := WiFiEventsMsmAuthenticating;
  WiFiEvents.OnMsmConnected := WiFiEventsMsmConnected;
  WiFiEvents.OnMsmDisassociating := WiFiEventsMsmDisassociating;
  WiFiEvents.OnMsmDisconnected := WiFiEventsMsmDisconnected;
  WiFiEvents.OnMsmPeerJoin := WiFiEventsMsmPeerJoin;
  WiFiEvents.OnMsmPeerLeave := WiFiEventsMsmPeerLeave;
  WiFiEvents.OnMsmRadioStateChange := WiFiEventsMsmRadioStateChange;
  WiFiEvents.OnMsmRoamingEnd := WiFiEventsMsmRoamingEnd;
  WiFiEvents.OnMsmRoamingStart := WiFiEventsMsmRoamingStart;
  WiFiEvents.OnMsmSignalQualityChange := WiFiEventsMsmSignalQualityChange;
  WiFiEvents.OnMsmLinkDegraded := WiFiEventsMsmLinkDegraded;
  WiFiEvents.OnMsmLinkImproved := WiFiEventsMsmLinkImproved;

  WiFiEvents.OnOneXAuthRestarted := WiFiEventsOneXAuthRestarted;
  WiFiEvents.OnOneXAuthUpdate := WiFiEventsOneXAuthUpdate;

  PowerMonitor := TwclPowerEventsMonitor.Create;
  PowerMonitor.OnPowerStateChanged := PowerStateChanged;
  PowerMonitor.Open;
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

    psPowerStatusChanged:
      TraceEvent(nil, 'Power', 'State', 'psPowerStatusChanged');

    psUnknown:
      TraceEvent(nil, 'Power', 'State', 'psUnknown');
  end;
end;

procedure TfmMain.WiFiEventsIpChanged(Sender: TObject;
  const IfaceId: TGUID; const Old, New: TwclWiFiIpSettings);
begin
  TraceEvent(@IfaceId, 'IP changed', 'Old address', Old.Address);
  TraceEvent(nil, '', 'New address', New.Address);
end;

procedure TfmMain.WiFiEventsOneXAuthUpdate(Sender: TObject;
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

procedure TfmMain.WiFiEventsMsmLinkDegraded(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'MsmLinkDegraded', '', '');
end;

procedure TfmMain.WiFiEventsMsmLinkImproved(Sender: TObject;
  const IfaceId: TGUID);
begin
  TraceEvent(@IfaceId, 'MsmLinkImproved', '', '');
end;

end.
