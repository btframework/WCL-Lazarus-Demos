unit main;

{$MODE Delphi}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclWiFi, ComCtrls, Dialogs;

type
  TfmMain = class(TForm)
    btClientOpen: TButton;
    btClientClose: TButton;
    btClientEnumInterfaces: TButton;
    lvClientInterfaces: TListView;
    btClientEnumNetworks: TButton;
    lvClientNetworks: TListView;
    cbClientAdHocProfiles: TCheckBox;
    cbClientHiddenProfiles: TCheckBox;
    lvClientBss: TListView;
    btClientScan: TButton;
    laClientScanSSID: TLabel;
    edClientScanSSID: TEdit;
    btClientEnumBSS: TButton;
    cbClientUseSSID: TCheckBox;
    laClientBssType: TLabel;
    cbClientBssType: TComboBox;
    cbClientSecurityEnabled: TCheckBox;
    btclientDisconnect: TButton;
    btClientGetShowDeniedNetworks: TButton;
    btClientSetShowDeniedNetworks: TButton;
    btClientGetPowerSettings: TButton;
    laClientAcmSettings: TLabel;
    btClientGetOnlyUseGpProfiles: TButton;
    btClientGetAllowExplicitCreds: TButton;
    btClientSetAllowExplicitCreds: TButton;
    btClientGetBlockPeriod: TButton;
    btClientSetBlockPeriod: TButton;
    btClientGetVirtualStationExtensibility: TButton;
    btClientSetVirtualStationExtensibility: TButton;
    btClientGetInterfaceState: TButton;
    btClientEnumProfiles: TButton;
    lvClientProfiles: TListView;
    btClientDeleteProfile: TButton;
    btClientRenameProfile: TButton;
    btClientGetProfileXml: TButton;
    SaveDialog: TSaveDialog;
    btClientSetProfileXml: TButton;
    OpenDialog: TOpenDialog;
    btClientConnect: TButton;
    cbClientConnect: TComboBox;
    laClientPasskey: TLabel;
    edClientPasskey: TEdit;
    cbClientDiscoverSecure: TCheckBox;
    btTunrOn: TButton;
    btTurnOff: TButton;
    cbUseBssMac: TCheckBox;
    cbPlainText: TCheckBox;
    btCurrentIp: TButton;
    btGetIpSettings: TButton;
    btEnableDhcp: TButton;
    btEnableStaticIp: TButton;
    btEditUi: TButton;
    btSetProfileXmlUserData: TButton;
    btGetDualStaState: TButton;
    btEnableDualSta: TButton;
    btDisableDualSta: TButton;
    btEnumSecondaryInterfaces: TButton;
    procedure btClientOpenClick(Sender: TObject);
    procedure btClientCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btClientEnumInterfacesClick(Sender: TObject);
    procedure btClientEnumNetworksClick(Sender: TObject);
    procedure btClientScanClick(Sender: TObject);
    procedure btClientEnumBSSClick(Sender: TObject);
    procedure btclientDisconnectClick(Sender: TObject);
    procedure btClientGetShowDeniedNetworksClick(Sender: TObject);
    procedure btClientSetShowDeniedNetworksClick(Sender: TObject);
    procedure btClientGetPowerSettingsClick(Sender: TObject);
    procedure btClientGetOnlyUseGpProfilesClick(Sender: TObject);
    procedure btClientGetAllowExplicitCredsClick(Sender: TObject);
    procedure btClientSetAllowExplicitCredsClick(Sender: TObject);
    procedure btClientGetBlockPeriodClick(Sender: TObject);
    procedure btClientSetBlockPeriodClick(Sender: TObject);
    procedure btClientGetVirtualStationExtensibilityClick(Sender: TObject);
    procedure btClientSetVirtualStationExtensibilityClick(Sender: TObject);
    procedure btClientGetInterfaceStateClick(Sender: TObject);
    procedure btClientEnumProfilesClick(Sender: TObject);
    procedure btClientDeleteProfileClick(Sender: TObject);
    procedure btClientRenameProfileClick(Sender: TObject);
    procedure btClientGetProfileXmlClick(Sender: TObject);
    procedure btClientSetProfileXmlClick(Sender: TObject);
    procedure btClientConnectClick(Sender: TObject);
    procedure btTunrOnClick(Sender: TObject);
    procedure btTurnOffClick(Sender: TObject);
    procedure btCurrentIpClick(Sender: TObject);
    procedure btGetIpSettingsClick(Sender: TObject);
    procedure btEnableDhcpClick(Sender: TObject);
    procedure btEnableStaticIpClick(Sender: TObject);
    procedure btEditUiClick(Sender: TObject);
    procedure btSetProfileXmlUserDataClick(Sender: TObject);
    procedure btGetDualStaStateClick(Sender: TObject);
    procedure btEnableDualStaClick(Sender: TObject);
    procedure btDisableDualStaClick(Sender: TObject);
    procedure btEnumSecondaryInterfacesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    WiFiClient: TwclWiFiClient;
    WiFiProfilesManager: TwclWiFiProfilesManager;

    function ClientGetInterfaceId(out Id: TGUID): Boolean;
    function ClientGetProfile(out Name: string): Boolean;

    procedure ClientClearInterfaces;
    procedure ClientClearNetworks;
    procedure ClientClearBss;
    procedure ClientClearProfiles;

    procedure ClientEnumProfiles;

    procedure ClientConnectUsingNetworkProfile;
    procedure ClientConnectUsingSelectedProfile;
    procedure ClientConnectUsingSelectedNetwork;
    procedure ClientConenctUsingTemporaryProfile;

    procedure ClientSwitchState(const Id: TGUID; const Off: Boolean);
    procedure ClientSetDualState(const Enable: Boolean);

    function ClientGetNetworkBss: TwclWiFiBssType;

    procedure WiFiClientAfterOpen(Sender: TObject);
    procedure WiFiClientBeforeClose(Sender: TObject);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils;

{$R *.lfm}

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

function GetEnumName(const Enum: TwclWiFiAuthAlgorithm): string; overload;
begin
  case Enum of
    auOpen: Result := 'auOpen';
    auSharedKey: Result := 'auSharedKey';
    auWpa: Result := 'auWpa';
    auWpaPsk: Result := 'auWpaPsk';
    auWpaNone: Result := 'auWpaNone';
    auRsna: Result := 'auRsna';
    auRsnaPsk: Result := 'auRsnaPsk';
    auWpa3: Result := 'auWpa3';
    auWpa3Sae: Result := 'auWpa3Sae';
    auOwe: Result := 'auOwe';
    auWpa3Ent: Result := 'auWpa3Ent';
    auUnknown: Result := 'auUnknown';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiCipherAlgorithm): string; overload;
begin
  case Enum of
    caNone: Result := 'caNone';
    caWep40: Result := 'caWep40';
    caTkip: Result := 'caTkip';
    caCcmp: Result := 'caCcmp';
    caWep104: Result := 'caWep104';
    caBip: Result := 'caBip';
    caGcmp128: Result := 'caGcmp128';
    caGcmp256: Result := 'caGcmp256';
    caCcmp256: Result := 'caCcmp256';
    caBipGmac128: Result := 'caBipGmac128';
    caBipGmac256: Result := 'caBipGmac256';
    caBipCmac256: Result := 'caBipCmac256';
    caUseGroup: Result := 'caUseGroup';
    caWep: Result := 'caWep';
    caUnknown: Result := 'caUnknown';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(
  const Enum: TwclWiFiAvailableNetworkFlag): string; overload;
begin
  case Enum of
    nfConnected: Result := 'nfConnected';
    nfHasProfile: Result := 'nfHasProfile';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiBssCap): string; overload;
begin
  case Enum of
    bcEss: Result := 'bcEss';
    bcIbss: Result := 'bcIbss';
    bcCfPollable: Result := 'bcCfPollable';
    bcCfPollRequest: Result := 'bcCfPollRequest';
    bcPrivacy: Result := 'bcPrivacy';
  else
    Result := 'UNKNOWN';
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

function GetEnumName(const Enum: TwclWiFiInterfaceState): string; overload;
begin
  case Enum of
    isNotReady: Result := 'isNotReady';
    isConnected: Result := 'isConnected';
    isAdHocFormed: Result := 'isAdHocFormed';
    isDisconnecting: Result := 'isDisconnecting';
    isDisconnected: Result := 'isDisconnected';
    isAssociating: Result := 'isAssociating';
    isDiscovering: Result := 'isDiscovering';
    isAuthenticating: Result := 'isAuthenticating';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclWiFiProfileFlag): string; overload;
begin
  case Enum of
    pfGroupPolicy: Result := 'pfGroupPolicy';
    pfUser: Result := 'pfUser';
    pfGetPlaintextKey: Result := 'pfGetPlaintextKey';
  else
    Result := 'UNKNOWN';
  end;
end;

function ShowResult(const Res: Integer): Boolean;
begin
  if Res = WCL_E_SUCCESS then
    Result := True

  else begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Result := False;
  end;
end;

function ShowConfirm(const Conf: string): TModalResult;
begin
  Result := MessageDlg(Conf, mtConfirmation, mbYesNoCancel, 0);
end;

procedure ShowInfo(const Info: string);
begin
  MessageDlg(Info, mtInformation, [mbOK], 0);
end;

procedure ShowWarning(const Warn: string);
begin
  MessageDlg(Warn, mtWarning, [mbOK], 0);
end;

{ TfmMain }

procedure TfmMain.btClientOpenClick(Sender: TObject);
begin
  ShowResult(WiFiClient.Open);
end;

procedure TfmMain.btClientCloseClick(Sender: TObject);
begin
  ShowResult(WiFiClient.Close);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  WiFiClient.Close;

  WiFiClient.Free;
  WiFiProfilesManager.Free;
end;

procedure TfmMain.WiFiClientAfterOpen(Sender: TObject);
begin
  ShowInfo('WiFi client opened');

  WiFiProfilesManager.Open;
end;

procedure TfmMain.WiFiClientBeforeClose(Sender: TObject);
begin
  WiFiProfilesManager.Close;

  ClientClearInterfaces;
  ClientClearNetworks;
  ClientClearBss;
  ClientClearProfiles;

  ShowInfo('WiFi client is closing');
end;

procedure TfmMain.ClientClearInterfaces;
begin
  lvClientInterfaces.Items.Clear;
end;

procedure TfmMain.btClientEnumInterfacesClick(Sender: TObject);
var
  Interfaces: TwclWiFiInterfaces;
  i: Integer;
  Item: TListItem;
begin
  ClientClearInterfaces;
  if ShowResult(WiFiClient.EnumInterfaces(Interfaces)) then begin
    try
      for i := 0 to Length(Interfaces) - 1 do begin
        Item := lvClientInterfaces.Items.Add;
        Item.Caption := GUIDToString(Interfaces[i].Id);
        Item.SubItems.Add(Interfaces[i].Description);
        Item.SubItems.Add(BoolToStr(Interfaces[i].Primary, True));
      end;

    finally
      Interfaces := nil;
    end;
  end;
end;

function TfmMain.ClientGetInterfaceId(out Id: TGUID): Boolean;
begin
  if lvClientInterfaces.Selected = nil then begin
    ShowWarning('Select interface');
    Result := False;

  end else begin
    Id := StringToGUID(lvClientInterfaces.Selected.Caption);
    Result := True;
  end;
end;

procedure TfmMain.ClientClearNetworks;
begin
  lvClientNetworks.Items.Clear;
end;

procedure TfmMain.btClientEnumNetworksClick(Sender: TObject);
var
  Filters: TwclWiFiAvailableNetworkFilters;
  Networks: TwclWiFiAvailableNetworks;
  Id: TGUID;
  i: Integer;
  Item: TListItem;
  Str: string;
  j: TwclWiFiPhy;
  f: TwclWiFiAvailableNetworkFlag;
begin
  ClientClearNetworks;

  if ClientGetInterfaceId(Id) then begin
    Filters := [];
    if cbClientAdHocProfiles.Checked then
      Include(Filters, ffIncludeAllAdhocProfiles);
    if cbClientHiddenProfiles.Checked then
      Include(Filters, ffIncludeAllManualHiddenProfiles);

    if ShowResult(WiFiClient.EnumAvailableNetworks(Id, Filters, Networks)) then
    begin
      try
        for i := 0 to Length(Networks) - 1 do begin
          Item := lvClientNetworks.Items.Add;
          Item.Caption := Networks[i].ProfileName;
          Item.SubItems.Add(Networks[i].Ssid);
          Item.SubItems.Add(GetEnumName(Networks[i].BssType));
          Item.SubItems.Add(IntToStr(Networks[i].NumberOfBssids));
          Item.SubItems.Add(BoolToStr(Networks[i].NetworkConnectable, True));
          Item.SubItems.Add('0x' + IntToHex(Networks[i].NotConnectableReason, 8));

          Str := '';
          for j := Low(TwclWiFiPhy) to High(TwclWiFiPhy) do begin
            if j in Networks[I].PhyTypes then
              Str := Str + GetEnumName(j) + ' ';
          end;
          Item.SubItems.Add(Str);

          Item.SubItems.Add(BoolToStr(Networks[i].MorePhyTypes, True));
          Item.SubItems.Add(IntToStr(Networks[i].SignalQuality));
          Item.SubItems.Add(BoolToStr(Networks[i].SecurityEnabled, True));
          Item.SubItems.Add(GetEnumName(Networks[i].DefaultAuthAlgorithm));
          Item.SubItems.Add(GetEnumName(Networks[i].DefaultCipherAlgorithm));

          Str := '';
          for f := Low(TwclWiFiAvailableNetworkFlag) to High(TwclWiFiAvailableNetworkFlag) do
          begin
            if f in Networks[i].Flags then
              Str := Str + GetEnumName(f) + ' ';
          end;
          Item.SubItems.Add(Str);
        end;

      finally
        Networks := nil;
      end;
    end;
  end;
end;

procedure TfmMain.btClientScanClick(Sender: TObject);
var
  Id: TGUID;
begin
  if ClientGetInterfaceId(Id) then begin
    if ShowResult(WiFiClient.Scan(Id, edClientScanSSID.Text)) then
      ShowInfo('Scan started. Use EventsDemo to see scan events.');
  end;
end;

procedure TfmMain.btClientEnumBSSClick(Sender: TObject);
var
  Id: TGUID;
  Ssid: string;
  BssType: TwclWiFiBssType;
  BssList: TwclWiFiBssArray;
  i: Integer;
  Item: TListItem;
  Str: string;
  j: TwclWiFiBssCap;
  x: Integer;
  Res: Integer;
begin
  ClientClearBss;

  if ClientGetInterfaceId(Id) then begin
    Ssid := '';

    if cbClientUseSSID.Checked then begin
      if lvClientNetworks.Selected = nil then begin
        ShowWarning('Select network');
        Exit;
      end;

      Ssid := lvClientNetworks.Selected.SubItems[0];
    end;

    BssType := TwclWiFiBssType(cbClientBssType.ItemIndex);

    Res := WiFiClient.EnumBss(Id, Ssid, BssType,
      cbClientSecurityEnabled.Checked, BssList);
    if ShowResult(Res) then begin
      try
        for i := 0 to Length(BssList) - 1 do begin
          Item := lvClientBss.Items.Add;
          Item.Caption := BssList[i].Ssid;
          Item.SubItems.Add(IntToStr(BssList[i].PhyId));
          Item.SubItems.Add(BssList[i].Mac);
          Item.SubItems.Add(GetEnumName(BssList[i].BssType));
          Item.SubItems.Add(GetEnumName(BssList[i].PhyType));
          Item.SubItems.Add(IntToStr(BssList[i].Rssi));
          Item.SubItems.Add(IntToStr(BssList[i].LinkQuality));
          Item.SubItems.Add(BoolToStr(BssList[i].InRegDomain, True));
          Item.SubItems.Add(IntToStr(BssList[i].BeaconPeriod));
          Item.SubItems.Add(IntToStr(BssList[i].Timestamp));
          Item.SubItems.Add(IntToStr(BssList[i].HostTimestamp));

          Str := '';
          for j := Low(TwclWiFiBssCap) to High(TwclWiFiBssCap) do begin
            if j in BssList[i].Capability then
              Str := Str + GetEnumName(j) + ' ';
          end;
          Item.SubItems.Add(Str);

          Item.SubItems.Add(IntToStr(BssList[i].ChCenterFrequency));

          Str := '';
          if Length(BssList[i].IeRaw) > 0 then begin
            for x := 0 to Length(BssList[i].IeRaw) - 1 do
              Str := Str + IntToHex(BssList[i].IeRaw[x], 2);
          end;
          Item.SubItems.Add(Str);
        end;

      finally
        for i := 0 to Length(BssList) - 1 do begin
          BssList[i].Rates := nil;
          BssList[i].IeRaw := nil;
        end;

        BssList := nil;
      end;
    end;
  end;
end;

procedure TfmMain.ClientClearBss;
begin
  lvClientBss.Items.Clear;
end;

procedure TfmMain.btclientDisconnectClick(Sender: TObject);
var
  Id: TGUID;
begin
  if ClientGetInterfaceId(Id) then
    ShowResult(WiFiClient.Disconnect(Id));
end;

procedure TfmMain.btClientGetShowDeniedNetworksClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  if ShowResult(WiFiClient.AcmGetShowDeniedNetworks(Enabled)) then begin
    if Enabled then
      ShowInfo('Show denied networks')
    else
      ShowInfo('Do not show denied networks');
  end;
end;

procedure TfmMain.btClientSetShowDeniedNetworksClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := ShowConfirm('Show denied networks?');
  if Res = mrCancel then
    Exit;

  ShowResult(WiFiClient.AcmSetShowDeniedNetworks(Res = mrYes));
end;

procedure TfmMain.btClientGetPowerSettingsClick(Sender: TObject);
var
  Setting: TwclWiFiPowerSetting;
begin
  if ShowResult(WiFiClient.AcmGetPowerSetting(Setting)) then
    ShowInfo(GetEnumName(Setting));
end;

procedure TfmMain.btClientGetOnlyUseGpProfilesClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  if ShowResult(WiFiClient.AcmGetOnlyUseGpProfiles(Enabled)) then begin
    if Enabled then
      ShowInfo('Only use GP profiles ENABLED')
    else
      ShowInfo('Only use GP profiles DISABLED');
  end;
end;

procedure TfmMain.btClientGetAllowExplicitCredsClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  if ShowResult(WiFiClient.AcmGetAllowExplicitCreds(Enabled)) then begin
    if Enabled then
      ShowInfo('Explicit creds ALLOWED')
    else
      ShowInfo('Explicit creds NOT ALLOWED');
  end;
end;

procedure TfmMain.btClientSetAllowExplicitCredsClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := ShowConfirm('Allow explicit creds?');
  if Res = mrCancel then
    Exit;

  ShowResult(WiFiClient.AcmSetAllowExplicitCreds(Res = mrYes));
end;

procedure TfmMain.btClientGetBlockPeriodClick(Sender: TObject);
var
  Period: Cardinal;
begin
  if ShowResult(WiFiClient.AcmGetBlockPeriod(Period)) then
    ShowInfo('Block period: ' + IntToStr(Period));
end;

procedure TfmMain.btClientSetBlockPeriodClick(Sender: TObject);
var
  Period: string;
begin
  Period := '';
  if InputQuery('Change ACM setting', 'Block period', Period) then
    ShowResult(WiFiClient.AcmSetBlockPeriod(StrToInt(Period)));
end;

procedure TfmMain.btClientGetVirtualStationExtensibilityClick(Sender: TObject);
var
  Allowed: Boolean;
begin
  if ShowResult(WiFiClient.AcmGetVirtualStationExtensibility(Allowed)) then
  begin
    if Allowed then
      ShowInfo('Virtual station extensibility ALLOWED')
    else
      ShowInfo('Virtual station extensibility NOT ALLOWED');
  end;
end;

procedure TfmMain.btClientSetVirtualStationExtensibilityClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := ShowConfirm('Allow wirtual station extensibility?');
  if Res = mrCancel then
    Exit;

  ShowResult(WiFiClient.AcmSetVirtualStationExtensibility(Res = mrYes));
end;

procedure TfmMain.btClientGetInterfaceStateClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
  State: TwclWiFiInterfaceState;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    try
      if ShowResult(Iface.Open) then begin
        try
          if ShowResult(Iface.GetState(State)) then
            ShowInfo('Interface state: ' + GetEnumName(State));

        finally
          Iface.Close;
        end;
      end;

    finally
      Iface.Free;
    end;
  end;
end;

procedure TfmMain.ClientClearProfiles;
begin
  lvClientProfiles.Items.Clear;
end;

procedure TfmMain.btClientEnumProfilesClick(Sender: TObject);
begin
  ClientEnumProfiles;
end;

procedure TfmMain.btClientDeleteProfileClick(Sender: TObject);
var
  Id: TGUID;
  Profile: string;
begin
  if ClientGetInterfaceId(Id) then begin
    if ClientGetProfile(Profile) then begin
      if ShowResult(WiFiProfilesManager.DeleteProfile(Id, Profile)) then
        ClientEnumProfiles;
    end;
  end;
end;

procedure TfmMain.ClientEnumProfiles;
var
  Id: TGUID;
  Profiles: TwclWiFiProfiles;
  i: Integer;
  Item: TListItem;
  Str: string;
  j: TwclWiFiProfileFlag;
begin
  ClientClearProfiles;

  if ClientGetInterfaceId(Id) then begin
    if ShowResult(WiFiProfilesManager.GetProfileList(Id, Profiles)) then
    begin
      try
        if Profiles <> nil then begin
          for i := 0 to Length(Profiles) - 1 do begin
            Item := lvClientProfiles.Items.Add;
            Item.Caption := Profiles[i].Name;

            Str := '';
            for j := Low(TwclWiFiProfileFlag) to High(TwclWiFiProfileFlag) do
            begin
              if j in Profiles[i].Flags then
                Str := Str + GetEnumName(j) + ' ';
            end;
            Item.SubItems.Add(Str);
          end;
        end;

      finally
        Profiles := nil;
      end;
    end;
  end;
end;

function TfmMain.ClientGetProfile(out Name: string): Boolean;
begin
  if lvClientProfiles.Selected = nil then begin
    ShowWarning('Select profile');
    Result := False;

  end else begin
    Name := lvClientProfiles.Selected.Caption;
    Result := True;
  end;
end;

procedure TfmMain.btClientRenameProfileClick(Sender: TObject);
var
  Id: TGUID;
  Profile: string;
  NewName: string;
  Res: Integer;
begin
  if ClientGetInterfaceId(Id) then begin
    if ClientGetProfile(Profile) then begin
      NewName := '';
      if InputQuery('Renamr profile', 'New profile name', NewName) then begin
        Res := WiFiProfilesManager.RenameProfile(Id, Profile, NewName);
        if ShowResult(Res) then
          ClientEnumProfiles;
      end;
    end;
  end;
end;

procedure TfmMain.btClientGetProfileXmlClick(Sender: TObject);
var
  Id: TGUID;
  Profile: string;
  Flags: TwclWiFiProfileFlags;
  Xml: string;
  List: TStringList;
  Res: Integer;
begin
  if ClientGetInterfaceId(Id) then begin
    if ClientGetProfile(Profile) then begin
      if cbPlainText.Checked then
        Flags := [pfGetPlaintextKey]
      else
        Flags := [];
      Res := WiFiProfilesManager.GetProfile(Id, Profile, Flags, Xml);
      if ShowResult(Res) then begin
        SaveDialog.FileName := Profile + '.xml';

        if SaveDialog.Execute then begin
          List := TStringList.Create;
          try
            List.Text := Xml;
            List.SaveToFile(SaveDialog.FileName);

          finally
            List.Free;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfmMain.btClientSetProfileXmlClick(Sender: TObject);
var
  Id: TGUID;
  Flags: TwclWiFiProfileFlags;
  List: TStringList;
begin
  if ClientGetInterfaceId(Id) then begin
    OpenDialog.FileName := '';

    if OpenDialog.Execute then begin
      List := TStringList.Create;
      try
        List.LoadFromFile(OpenDialog.FileName);

        Flags := [];
        ShowResult(WiFiProfilesManager.SetProfile(Id, Flags,
          List.Text, True));

      finally
        List.Free;
      end;
    end;
  end;
end;

procedure TfmMain.btClientConnectClick(Sender: TObject);
begin
  case cbClientConnect.ItemIndex of
    0: ClientConnectUsingNetworkProfile;
    1: ClientConnectUsingSelectedProfile;
    2: ClientConnectUsingSelectedNetwork;
    3: ClientConenctUsingTemporaryProfile;
  end;
end;

procedure TfmMain.ClientConenctUsingTemporaryProfile;
var
  Id: TGUID;
  Xml: string;
  Ssid: string;
  AuthAlg: string;
  CipherAlg: string;
  Key: string;
  BoolRes: Boolean;
  Mac: string;
  Hex: AnsiString;
begin
  if ClientGetInterfaceId(Id) then begin
    if lvClientNetworks.Selected = nil then
      ShowWarning('Select network')

    else begin
      if cbUseBssMac.Checked and (lvClientBss.Selected = nil) then begin
        ShowWarning('Select Bss');
        Exit;
      end;

      if cbUseBssMac.Checked then
        Mac := lvClientBss.Selected.SubItems[1]
      else
        Mac := '';

      Ssid := lvClientNetworks.Selected.SubItems[0];
      Hex := WiFiProfilesManager.SsidToHex(Ssid);

      Xml := '<?xml version="1.0"?>' +
             '<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">' +
             '<name>%s</name>' + // ProfileName (SSID)
             '<SSIDConfig>' +
             '<SSID>' +
             '<hex>%s</hex>' + // SSID HEX
             '<name>%s</name>' + // Network SSID
             '</SSID>' +
             '</SSIDConfig>' +
             '<connectionType>ESS</connectionType>' +
             '<connectionMode>manual</connectionMode>' +
             '<autoSwitch>false</autoSwitch>' +
             '<MSM>' +
             '<security>' +
             '<authEncryption>' +
             '<authentication>%s</authentication>' + // Authe algorithm
             '<encryption>%s</encryption>' + // Cipher algorithm
             '<useOneX>false</useOneX>' +
             '</authEncryption>' +
             '<sharedKey>' +
             '<keyType>passPhrase</keyType>' +
             '<protected>false</protected>' +
             '<keyMaterial>%s</keyMaterial>' + // Key
             '</sharedKey>' +
             '</security>' +
             '</MSM>' +
             '</WLANProfile>';

      Key := edClientPasskey.Text;

      if lvClientNetworks.Selected.SubItems[10] = 'auOpen' then
        AuthAlg := 'open'
      else begin
        if lvClientNetworks.Selected.SubItems[10] = 'auSharedKey' then
          AuthAlg := 'shared'
        else begin
          if lvClientNetworks.Selected.SubItems[10] = 'auWpa' then
            AuthAlg := 'WPA'
          else begin
            if lvClientNetworks.Selected.SubItems[10] = 'auWpaPsk' then
              AuthAlg := 'WPAPSK'
            else begin
              if lvClientNetworks.Selected.SubItems[10] = 'auRsna' then
                AuthAlg := 'WPA2'
              else begin
                if lvClientNetworks.Selected.SubItems[10] = 'auWpa3' then
                  AuthAlg := 'WPA3ENT192'
                else begin
                  if lvClientNetworks.Selected.SubItems[10] = 'auWpa3Sae' then
                    AuthAlg := 'WPA3SAE'
                  else begin
                    if lvClientNetworks.Selected.SubItems[10] = 'auWpa3Ent' then
                      AuthAlg := 'WPA3ENT'
                    else begin
                      if lvClientNetworks.Selected.SubItems[10] = 'auOwe' then
                        AuthAlg := 'OWE'
                      else
                        AuthAlg := 'WPA2PSK';
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;

      if lvClientNetworks.Selected.SubItems[11] = 'caNone' then
        CipherAlg := 'none'
      else begin
        if lvClientNetworks.Selected.SubItems[11] = 'caTkip' then
          CipherAlg := 'TKIP'
        else begin
          BoolRes := (lvClientNetworks.Selected.SubItems[11] = 'caWep40') or
            (lvClientNetworks.Selected.SubItems[11] = 'caWep104') or
            (lvClientNetworks.Selected.SubItems[11] = 'caWep');
          if BoolRes then
            CipherAlg := 'WEP'
          else begin
            if lvClientNetworks.Selected.SubItems[11] = 'caGcmp256' then
              CipherAlg := 'GCMP256'
            else
              CipherAlg := 'AES';
          end;
        end;
      end;

      Xml := Format(Xml, [Ssid, Hex, Ssid, AuthAlg, CipherAlg, Key]);

      ShowResult(WiFiClient.Connect(Id, cmTemporaryProfile, Xml, Ssid,
        ClientGetNetworkBss, [], Mac));
    end;
  end;
end;

procedure TfmMain.ClientConnectUsingNetworkProfile;
var
  Id: TGUID;
  Mac: string;
begin
  if ClientGetInterfaceId(Id) then begin
    if lvClientNetworks.Selected = nil then begin
      ShowWarning('Select network');
      Exit;
    end;

    if cbUseBssMac.Checked and (lvClientBss.Selected = nil) then begin
      ShowWarning('Select Bss');
      Exit;
    end;

    if cbUseBssMac.Checked then
      Mac := lvClientBss.Selected.SubItems[1]
    else
      Mac := '';

    ShowResult(WiFiClient.Connect(Id, cmProfile,
      lvClientNetworks.Selected.Caption, '', ClientGetNetworkBss, [], Mac));
  end;
end;

procedure TfmMain.ClientConnectUsingSelectedNetwork;
var
  Mode: TwclWiFiConnectionMode;
  Id: TGUID;
  Mac: string;
begin
  if ClientGetInterfaceId(Id) then begin
    if lvClientNetworks.Selected = nil then
      ShowWarning('Select network')

    else begin
      if cbClientDiscoverSecure.Checked then
        Mode := cmDiscoverySecure

      else
        Mode := cmDiscoveryUnsecure;

      if cbUseBssMac.Checked and (lvClientBss.Selected = nil) then begin
        ShowWarning('Select Bss');
        Exit;
      end;

      if cbUseBssMac.Checked then
        Mac := lvClientBss.Selected.SubItems[1]
      else
        Mac := '';

      ShowResult(WiFiClient.Connect(Id, Mode, '',
        lvClientNetworks.Selected.SubItems[0], ClientGetNetworkBss, [], Mac));
    end;
  end;
end;

procedure TfmMain.ClientConnectUsingSelectedProfile;
var
  Id: TGUID;
  Mac: string;
begin
  if ClientGetInterfaceId(Id) then begin
    if lvClientProfiles.Selected = nil then begin
      ShowWarning('Select profile');
      Exit;
    end;

    if cbUseBssMac.Checked and (lvClientBss.Selected = nil) then begin
      ShowWarning('Select Bss');
      Exit;
    end;

    if cbUseBssMac.Checked then
      Mac := lvClientBss.Selected.SubItems[1]
    else
      Mac := '';

    ShowResult(WiFiClient.Connect(Id, cmProfile,
      lvClientProfiles.Selected.Caption, '', ClientGetNetworkBss, [], Mac));
  end;
end;

function TfmMain.ClientGetNetworkBss: TwclWiFiBssType;
begin
  if lvClientNetworks.Selected = nil then
    Result := TwclWiFiBssType(cbClientBssType.ItemIndex)
  else begin
    if lvClientNetworks.Selected.SubItems[1] = 'bssInfrastructure' then
      Result := bssInfrastructure
    else begin
      if lvClientNetworks.Selected.SubItems[1] = 'bssIndependent' then
        Result := bssIndependent
      else
        raise Exception.Create('Inavlid BSS type');
    end;
  end;
end;

procedure TfmMain.btTunrOnClick(Sender: TObject);
var
  Id: TGUID;
begin
  if ClientGetInterfaceId(Id) then
    ClientSwitchState(Id, False);
end;

procedure TfmMain.btTurnOffClick(Sender: TObject);
var
  Id: TGUID;
begin
  if ClientGetInterfaceId(Id) then
    ClientSwitchState(Id, True);
end;

procedure TfmMain.ClientSwitchState(const Id: TGUID; const Off: Boolean);
var
  Iface: TwclWiFiInterface;
begin
  Iface := TwclWiFiInterface.Create(Id);
  try
    if ShowResult(Iface.Open) then begin
      try
        if Off then
          ShowResult(Iface.TurnOff)
        else
          ShowResult(Iface.TurnOn);
      finally
        Iface.Close;
      end;
    end;
  finally
    Iface.Free;
  end;
end;

procedure TfmMain.btCurrentIpClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
  Res: Integer;
  Static: Boolean;
  Dns1: string;
  Dns2: string;
  Address: string;
  Gateway: string;
  Mask: string;
  Msg: string;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    if ShowResult(Iface.Open) then begin
      Res := Iface.GetCurrentIp(Static, Address, Mask, Gateway, Dns1, Dns2);
      if ShowResult(Res) then begin
        if Static then
          Msg := 'Static IP' + #13#10
        else
          Msg := 'DHCP' + #13#10;
        Msg := Msg + 'Address: ' + Address + #13#10 +
                     'Subnet mask: ' + Mask + #13#10 +
                     'Default gateway: ' + Gateway + #13#10 +
                     'Name server 1: ' + Dns1 + #13#10 +
                     'Name server 2: ' + Dns2;
        ShowMessage(Msg);
      end;
      Iface.Close;
    end;
    Iface.Free;
  end;
end;

procedure TfmMain.btGetIpSettingsClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
  Res: Integer;
  Static: Boolean;
  Dns1: string;
  Dns2: string;
  Address: string;
  Gateway: string;
  Mask: string;
  Msg: string;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    if ShowResult(Iface.Open) then begin
      Res := Iface.GetIpSettings(Static, Address, Mask, Gateway, Dns1, Dns2);
      if ShowResult(Res) then begin
        if Static then
          Msg := 'Static IP' + #13#10
        else
          Msg := 'DHCP' + #13#10;
        Msg := Msg + 'Address: ' + Address + #13#10 +
                     'Subnet mask: ' + Mask + #13#10 +
                     'Default gateway: ' + Gateway + #13#10 +
                     'Name server 1: ' + Dns1 + #13#10 +
                     'Name server 2: ' + Dns2;
        ShowMessage(Msg);
      end;
      Iface.Close;
    end;
    Iface.Free;
  end;
end;

procedure TfmMain.btEnableDhcpClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    if ShowResult(Iface.Open) then begin
      ShowResult(Iface.EnableDhcp);
      Iface.Close;
    end;
    Iface.Free;
  end;
end;

procedure TfmMain.btEnableStaticIpClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    if ShowResult(Iface.Open) then begin
      ShowResult(Iface.SetStaticIp('192.168.1.210', '255.255.255.0',
        '192.168.1.1', '192.168.1.1', ''));
      Iface.Close;
    end;
    Iface.Free;
  end;
end;

procedure TfmMain.btEditUiClick(Sender: TObject);
var
  Id: TGUID;
  Profile: string;
begin
  if ClientGetInterfaceId(Id) then begin
    if ClientGetProfile(Profile) then
      ShowResult(WiFiProfilesManager.ShowUIEdit(Id, Profile));
  end;
end;

procedure TfmMain.btSetProfileXmlUserDataClick(Sender: TObject);
var
  Id: TGUID;
  Profile: string;
  List: TStringList;
begin
  if ClientGetInterfaceId(Id) then begin
    if ClientGetProfile(Profile) then begin
      OpenDialog.FileName := '';

      if OpenDialog.Execute then begin
        List := TStringList.Create;
        try
          List.LoadFromFile(OpenDialog.FileName);

          ShowResult(WiFiProfilesManager.SetProfileEapXmlUserData(Id,
            Profile, False, List.Text));

        finally
          List.Free;
        end;
      end;
    end;
  end;
end;

procedure TfmMain.btGetDualStaStateClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
  State: Boolean;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    try
      if ShowResult(Iface.Open) then begin
        try
          if ShowResult(Iface.GetSecondarySta(State)) then
            ShowInfo('Dual-STA state: ' + BoolToStr(State, True));
        finally
          Iface.Close;
        end;
      end;
    finally
      Iface.Free;
    end;
  end;
end;

procedure TfmMain.btEnableDualStaClick(Sender: TObject);
begin
  ClientSetDualState(True);
end;

procedure TfmMain.btDisableDualStaClick(Sender: TObject);
begin
  ClientSetDualState(False);
end;

procedure TfmMain.ClientSetDualState(const Enable: Boolean);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    try
      if ShowResult(Iface.Open) then begin
        try
          ShowResult(Iface.SetSecondarySta(Enable));
        finally
          Iface.Close;
        end;
      end;
    finally
      Iface.Free;
    end;
  end;
end;

procedure TfmMain.btEnumSecondaryInterfacesClick(Sender: TObject);
var
  Id: TGUID;
  Iface: TwclWiFiInterface;
  Ifaces: TwclWiFiInterfaces;
  i: Integer;
  Item: TListItem;
begin
  if ClientGetInterfaceId(Id) then begin
    Iface := TwclWiFiInterface.Create(Id);
    try
      if ShowResult(Iface.Open) then begin
        try
          if ShowResult(Iface.EnumInterfaces(Ifaces)) then begin
            ClientClearInterfaces;
            for i := 0 to Length(Ifaces) - 1 do begin
              Item := lvClientInterfaces.Items.Add;
              Item.Caption := GUIDToString(Ifaces[i].Id);
              Item.SubItems.Add(Ifaces[i].Description);
              Item.SubItems.Add(BoolToStr(Ifaces[i].Primary, True));
            end;
          end;
        finally
          Iface.Close;
        end;
      end;
    finally
      Iface.Free;
    end;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  WiFiClient := TwclWiFiClient.Create(nil);
  WiFiProfilesManager := TwclWiFiProfilesManager.Create(nil);

  WiFiClient.AfterOpen := WiFiClientAfterOpen;
  WiFiClient.BeforeClose := WiFiClientBeforeClose;
end;

end.
