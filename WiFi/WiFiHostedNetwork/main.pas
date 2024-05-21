unit main;

{$MODE Delphi}

interface

uses
  Forms, Classes, wclWiFi, Controls, StdCtrls, ComCtrls, ExtCtrls;

type
  TfmMain = class(TForm)
    btHnOpen: TButton;
    btHnClose: TButton;
    btHnGetConnectionSettings: TButton;
    lvHnData: TListView;
    btHnClear: TButton;
    btHnGetKey: TButton;
    btHnGetProfile: TButton;
    btHnGetSecuritySettings: TButton;
    btHnGetStatus: TButton;
    btHnRefreshSecuritySettings: TButton;
    laHnSSID: TLabel;
    edHnSSID: TEdit;
    laHnNumberOfPeers: TLabel;
    edHnNumberOfPeers: TEdit;
    btHnSetSettings: TButton;
    laHnKey: TLabel;
    edHnKey: TEdit;
    btHnSetKey: TButton;
    cbHnPersistent: TCheckBox;
    btHnEnable: TButton;
    btHnDisable: TButton;
    btHnGetState: TButton;
    btHnRestart: TButton;
    procedure btHnOpenClick(Sender: TObject);
    procedure btHnCloseClick(Sender: TObject);
    procedure btHnGetConnectionSettingsClick(Sender: TObject);
    procedure btHnClearClick(Sender: TObject);
    procedure btHnGetKeyClick(Sender: TObject);
    procedure btHnGetProfileClick(Sender: TObject);
    procedure btHnGetSecuritySettingsClick(Sender: TObject);
    procedure btHnGetStatusClick(Sender: TObject);
    procedure btHnRefreshSecuritySettingsClick(Sender: TObject);
    procedure btHnSetSettingsClick(Sender: TObject);
    procedure btHnSetKeyClick(Sender: TObject);
    procedure btEnableDisableClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btHnGetStateClick(Sender: TObject);
    procedure btHnRestartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    WiFiHostedNetwork: TwclWiFiHostedNetwork;

    procedure HnClear;
    procedure HnAddData(const ParamName: string; const ParamValue: string);

    procedure WiFiHostedNetworkAfterOpen(Sender: TObject);
    procedure WiFiHostedNetworkBeforeClose(Sender: TObject);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

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

function GetEnumName(const Enum: TwclWiFiHostedNetworkState): string;  overload;
begin
  case Enum of
    hnUnavailable: Result := 'hnUnavailable';
    hnIdle: Result := 'hnIdle';
    hnActive: Result := 'hnActive';
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

function ShowResult(const Res: Integer): Boolean;
begin
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    Result := False;

  end else
    Result := True;
end;

procedure ShowInfo(const Info: string);
begin
  MessageDlg(Info, mtInformation, [mbOK], 0);
end;

{ TfmMain }

procedure TfmMain.btHnOpenClick(Sender: TObject);
begin
  ShowResult(WiFiHostedNetwork.Open);
end;

procedure TfmMain.btHnCloseClick(Sender: TObject);
begin
  ShowResult(WiFiHostedNetwork.Close);
end;

procedure TfmMain.WiFiHostedNetworkAfterOpen(Sender: TObject);
begin
  ShowInfo('WiFi Hosted Network opened');
end;

procedure TfmMain.WiFiHostedNetworkBeforeClose(Sender: TObject);
begin
  ShowInfo('WiFi Hosted Network closing');
end;

procedure TfmMain.btHnGetConnectionSettingsClick(Sender: TObject);
var
  Settings: TwclWiFiHostedNetworkConnectionSettings;
begin
  HnClear;

  if ShowResult(WiFiHostedNetwork.GetConnectionSettings(Settings)) then begin
    HnAddData('SSID', Settings.Ssid);
    HnAddData('Max. number of peers', IntToStr(Settings.MaxNumberOfPeers));
  end;
end;

procedure TfmMain.HnClear;
begin
  lvHnData.Items.Clear;
end;

procedure TfmMain.btHnClearClick(Sender: TObject);
begin
  HnClear;
end;

procedure TfmMain.HnAddData(const ParamName: string; const ParamValue: string);
var
  Item: TListItem;
begin
  Item := lvHnData.Items.Add;
  Item.Caption := ParamName;
  Item.SubItems.Add(ParamValue);
end;

procedure TfmMain.btHnGetKeyClick(Sender: TObject);
var
  KeyLength: Cardinal;
  KeyData: Pointer;
  IsPassPhrase: Boolean;
  Persistent: Boolean;
  Str: string;
  i: Integer;
  Res: Integer;
begin
  HnClear;

  Res := WiFiHostedNetwork.GetKey(KeyLength, KeyData, IsPassPhrase, Persistent);
  if ShowResult(Res) then begin
    try
      if IsPassPhrase then
        Str := string(AnsiString(PAnsiChar(KeyData)))

      else begin
        Str := '';
        for i := 0 to KeyLength - 1 do
          Str := Str + IntToHex(Byte(PAnsiChar(KeyData)[i]), 2);
      end;

      HnAddData('Key length', IntToStr(KeyLength));
      HnAddData('Key data', Str);
      HnAddData('Is pass phrase', BoolToStr(IsPassPhrase, True));
      HnAddData('Persistent', BoolToStr(Persistent, True));

    finally
      WiFiHostedNetwork.FreeMemory(KeyData);
    end;
  end;
end;

procedure TfmMain.btHnGetProfileClick(Sender: TObject);
var
  XML: string;
begin
  HnClear;

  if ShowResult(WiFiHostedNetwork.GetProfile(XML)) then
    HnAddData('Profile XML', XML);
end;

procedure TfmMain.btHnGetSecuritySettingsClick(Sender: TObject);
var
  Settings: TwclWiFiAuthCipherPair;
begin
  HnClear;

  if ShowResult(WiFiHostedNetwork.GetSecuritySettings(Settings)) then begin
    HnAddData('Auth algorithm', GetEnumName(Settings.AuthAlgorithm));
    HnAddData('Cipher algorithm', GetEnumName(Settings.CipherAlgorithm));
  end;
end;

procedure TfmMain.btHnGetStatusClick(Sender: TObject);
var
  Status: TwclWiFiHostedNetworkStatus;
  i: Integer;
  Res: Integer;
  Address: string;
begin
  HnClear;

  if ShowResult(WiFiHostedNetwork.GetStatus(Status)) then begin
    try
      HnAddData('State', GetEnumName(Status.State));
      HnAddData('Interface ID', GUIDToString(Status.Id));
      HnAddData('BSS ID', Status.BssId);
      HnAddData('Phy', GetEnumName(Status.Phy));
      HnAddData('ChannelFrequency', IntToStr(Status.ChannelFrequency));

      Res := WiFiHostedNetwork.GetLocalIp(Address);
      if Res <> WCL_E_SUCCESS then
        Address := 'Get failed: 0x' + IntToHex(Res, 8);
      HnAddData('Local IP', Address);

      for i := 0 to Length(Status.Peers) - 1 do begin
        HnAddData('Peer[' + IntToStr(i) + '] MAC', Status.Peers[i].Mac);
        Res := WiFiHostedNetwork.GetRemoteIp(Status.Peers[i].Mac, Address);
        if Res = WCL_E_SUCCESS then
          HnAddData('Peer[' + IntToStr(i) + '] IP', Address)
        else begin
          HnAddData('Peer[' + IntToStr(i) + '] IP', 'Get failed: 0x' +
            IntToHex(Res, 8));
        end;
        HnAddData('Peer[' + IntToStr(i) + '] auth state',
          GetEnumName(Status.Peers[i].AuthState));
      end;

    finally
      Status.Peers := nil;
    end;
  end;
end;

procedure TfmMain.btHnRefreshSecuritySettingsClick(Sender: TObject);
begin
  ShowResult(WiFiHostedNetwork.RefreshSecuritySettings);
end;

procedure TfmMain.btHnSetSettingsClick(Sender: TObject);
var
  Settings: TwclWiFiHostedNetworkConnectionSettings;
begin
  Settings.Ssid := edHnSSID.Text;
  Settings.MaxNumberOfPeers := StrToInt(edHnNumberOfPeers.Text);

  ShowResult(WiFiHostedNetwork.SetConnectionSettings(Settings));
end;

procedure TfmMain.btHnSetKeyClick(Sender: TObject);
var
  KeyData: AnsiString;
begin
  KeyData := AnsiString(edHnKey.Text);
  ShowResult(WiFiHostedNetwork.SetKey(Length(KeyData) + 1, Pointer(KeyData),
    True, cbHnPersistent.Checked));
end;

procedure TfmMain.btEnableDisableClick(Sender: TObject);
begin
  ShowResult(WiFiHostedNetwork.SetState(Sender = btHnEnable));
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  WiFiHostedNetwork.Close;
end;

procedure TfmMain.btHnGetStateClick(Sender: TObject);
var
  State: Boolean;
begin
  HnClear;

  if ShowResult(WiFiHostedNetwork.GetState(State)) then
    HnAddData('Enabled', BoolToStr(State, True));
end;

procedure TfmMain.btHnRestartClick(Sender: TObject);
begin
  ShowResult(WiFiHostedNetwork.Restart);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  WiFiHostedNetwork := TwclWiFiHostedNetwork.Create(nil);
  WiFiHostedNetwork.AfterOpen := WiFiHostedNetworkAfterOpen;
  WiFiHostedNetwork.BeforeClose := WiFiHostedNetworkBeforeClose;
end;

end.
