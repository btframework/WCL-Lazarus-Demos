unit main;

{$MODE Delphi}

interface

uses
  Forms, wclNlm, Classes, Controls, StdCtrls, ComCtrls;

type
  TfmMain = class(TForm)
    btOpen: TButton;
    btClose: TButton;
    lbEvents: TListBox;
    btClear: TButton;
    btIsConnected: TButton;
    btIsInternet: TButton;
    btGetConnectivity: TButton;
    btEnumNetworks: TButton;
    lvNetworks: TListView;
    laNetworkType: TLabel;
    cbNetworkType: TComboBox;
    btRefresh: TButton;
    laNewNameOrDescription: TLabel;
    edNewNameOrDescription: TEdit;
    btSetName: TButton;
    btSetDescription: TButton;
    laCategory: TLabel;
    cbCategory: TComboBox;
    btSetCategory: TButton;
    btGetMachineConnections: TButton;
    btGetNetworkConnections: TButton;
    lvConnections: TListView;
    btDelete: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btIsConnectedClick(Sender: TObject);
    procedure btIsInternetClick(Sender: TObject);
    procedure btGetConnectivityClick(Sender: TObject);
    procedure btEnumNetworksClick(Sender: TObject);
    procedure btRefreshClick(Sender: TObject);
    procedure btSetNameClick(Sender: TObject);
    procedure btSetDescriptionClick(Sender: TObject);
    procedure btSetCategoryClick(Sender: TObject);
    procedure btGetMachineConnectionsClick(Sender: TObject);
    procedure btGetNetworkConnectionsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);

  private
    NetworkListManager: TwclNetworkListManager;

    procedure ShowConnections(var Connections: TwclNlmConnections);

    procedure NetworkListManagerAfterOpen(Sender: TObject);
    procedure NetworkListManagerBeforeClose(Sender: TObject);
    procedure NetworkListManagerConnectivityChanged(Sender: TObject;
      const Connectivity: TwclNlmConnectivityFlags);
    procedure NetworkListManagerNetworkAdded(Sender: TObject;
      const NetworkId: TGUID);
    procedure NetworkListManagerNetworkConnectivityChanged(
      Sender: TObject; const NetworkId: TGUID;
      const Connectivity: TwclNlmConnectivityFlags);
    procedure NetworkListManagerNetworkDeleted(Sender: TObject;
      const NetworkId: TGUID);
    procedure NetworkListManagerNetworkPropertyChanged(Sender: TObject;
      const NetworkId: TGUID;
      const Change: TwclNlmNetworkPropertyChangeFlags);
    procedure NetworkListManagerConnectionConnectivityChanged(
      Sender: TObject; const ConnectionId: TGUID;
      const Connectivity: TwclNlmConnectivityFlags);
    procedure NetworkListManagerConnectionPropertyChanged(
      Sender: TObject; const ConnectionId: TGUID;
      const Prop: TwclNlmConnectionProperty);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils;

{$R *.lfm}

function GetEnumName(const Enum: TwclNlmConnectionProperty): string; overload;
begin
  case Enum of
    nlmAuthentication: Result := 'nlmAuthentication';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclNlmConnectivity): string; overload;
begin
  case Enum of
    nlmDisconnected: Result := 'nlmDisconnected';
    nlmIPv4NoTraffic: Result := 'nlmIPv4NoTraffic';
    nlmIPv6NoTraffic: Result := 'nlmIPv6NoTraffic';
    nlmIPv4Subnet: Result := 'nlmIPv4Subnet';
    nlmIPv4LocalNetwork: Result := 'nlmIPv4LocalNetwork';
    nlmIPv4Internet: Result := 'nlmIPv4Internet';
    nlmIPv6Subnet: Result := 'nlmIPv6Subnet';
    nlmIPv6LocalNetwork: Result := 'nlmIPv6LocalNetwork';
    nlmIPv6Internet: Result := 'nlmIPv6Internet';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(
  const Enum: TwclNlmNetworkPropertyChange): string; overload;
begin
  case Enum of
    nlmNetworkChangeConnection: Result := 'nlmNetworkChangeConnection';
    nlmNetworkChangeDescription: Result := 'nlmNetworkChangeDescription';
    nlmNetworkChangeName: Result := 'nlmNetworkChangeName';
    nlmNetworkChangeIcon: Result := 'nlmNetworkChangeIcon';
    nlmNetworkChangeCategoryValue: Result := 'nlmNetworkChangeCategoryValue';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclNlmNetworkCategory): string; overload;
begin
  case Enum of
    nlmCategoryPublic: Result := 'nlmCategoryPublic';
    nlmCategoryPrivate: Result := 'nlmCategoryPrivate';
    nlmCategoryDomainAuthenticated: Result := 'nlmCategoryDomainAuthenticated';
  else
    Result := 'UNKNOWN';
  end;
end;

function GetEnumName(const Enum: TwclNlmDomainType): string; overload;
begin
  case Enum of
    nlmNonDomainNetwork: Result := 'nlmNonDomainNetwork';
    nlmDomainNetwork: Result := 'nlmDomainNetwork';
    nlmDomainAuthenticated: Result := 'nlmDomainAuthenticated';
  else
    Result := 'UNKNOWN';
  end;
end;

function DecodeFlags(const Flags: TwclNlmConnectivityFlags): string; overload;
var
  i: TwclNlmConnectivity;
begin
  Result := '';
  for i := Low(TwclNlmConnectivity) to High(TwclNlmConnectivity) do begin
    if i in Flags then
      Result := Result + GetEnumName(i) + ' ';
  end;
end;

function DecodeFlags(
  const Flags: TwclNlmNetworkPropertyChangeFlags): string; overload;
var
  i: TwclNlmNetworkPropertyChange;
begin
  Result := '';
  for i := Low(TwclNlmNetworkPropertyChange) to High(TwclNlmNetworkPropertyChange) do
  begin
    if i in Flags then
      Result := Result + GetEnumName(i);
  end;
end;

procedure ShowInfo(const Info: string);
begin
  MessageDlg(Info, mtInformation, [mbOK], 0);
end;

procedure ShowWarning(const Warn: string);
begin
  MessageDlg(Warn, mtWarning, [mbOK], 0);
end;

function ShowError(const Error: Integer): Boolean;
begin
  Result := Error <> WCL_E_SUCCESS;
  if Result then
    MessageDlg('Error: 0x' + IntToHex(Error, 8), mtError, [mbOK], 0);
end;

{ TfmMain }

procedure TfmMain.FormCreate(Sender: TObject);
begin
  cbNetworkType.ItemIndex := 2;
  cbCategory.ItemIndex := 0;

  NetworkListManager := TwclNetworkListManager.Create(nil);
  NetworkListManager.AfterOpen := NetworkListManagerAfterOpen;
  NetworkListManager.BeforeClose := NetworkListManagerBeforeClose;
  NetworkListManager.OnConnectivityChanged := NetworkListManagerConnectivityChanged;
  NetworkListManager.OnNetworkAdded := NetworkListManagerNetworkAdded;
  NetworkListManager.OnNetworkConnectivityChanged := NetworkListManagerNetworkConnectivityChanged;
  NetworkListManager.OnNetworkDeleted := NetworkListManagerNetworkDeleted;
  NetworkListManager.OnNetworkPropertyChanged := NetworkListManagerNetworkPropertyChanged;
  NetworkListManager.OnConnectionConnectivityChanged := NetworkListManagerConnectionConnectivityChanged;
  NetworkListManager.OnConnectionPropertyChanged := NetworkListManagerConnectionPropertyChanged;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Clear;
end;

procedure TfmMain.btOpenClick(Sender: TObject);
begin
  ShowError(NetworkListManager.Open);
end;

procedure TfmMain.btCloseClick(Sender: TObject);
begin
  ShowError(NetworkListManager.Close);
end;

procedure TfmMain.btIsConnectedClick(Sender: TObject);
var
  Connected: Boolean;
begin
  if not ShowError(NetworkListManager.GetConnected(Connected)) then begin
    if Connected then
      ShowInfo('Connected')
    else
      ShowInfo('NOT Connected');
  end;
end;

procedure TfmMain.btIsInternetClick(Sender: TObject);
var
  Connected: Boolean;
begin
  if not ShowError(NetworkListManager.GetConnectedToInternet(Connected)) then
  begin
    if Connected then
      ShowInfo('Connected')
    else
      ShowInfo('NOT Connected');
  end;
end;

procedure TfmMain.btGetConnectivityClick(Sender: TObject);
var
  Connectivity: TwclNlmConnectivityFlags;
begin
  if not ShowError(NetworkListManager.GetConnectivity(Connectivity)) then
    ShowInfo('Connectivity: ' + DecodeFlags(Connectivity));
end;

procedure TfmMain.btEnumNetworksClick(Sender: TObject);
var
  Res: Integer;
  Flag: TwclNlmEnumNetwork;
  Networks: TwclNlmNetworks;
  i: Integer;
  Item: TListItem;
  Network: TwclNlmNetwork;
  Id: TGUID;
  Category: TwclNlmNetworkCategory;
  Connectivity: TwclNlmConnectivityFlags;
  Description: string;
  Domain: TwclNlmDomainType;
  AName: string;
  CreationDateTime: TDateTime;
  ConnectedDateTime: TDateTime;
  Connected: Boolean;
begin
  lvNetworks.Items.Clear;

  Flag := TwclNlmEnumNetwork(cbNetworkType.ItemIndex);
  Res := NetworkListManager.GetNetworks(Flag, Networks);
  try
    if not ShowError(Res) then begin
      for i := 0 to Length(Networks) - 1 do begin
        Item := lvNetworks.Items.Add;
        Network := Networks[i];

        Res := Network.GetNetworkId(Id);
        if Res = WCL_E_SUCCESS then
          Item.Caption := GUIDToString(Id)
        else
          Item.Caption := 'Error: 0x' + IntToHex(Res, 8);

        Res := Network.GetCategory(Category);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(GetEnumName(Category))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Network.GetConnectivity(Connectivity);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(DecodeFlags(Connectivity))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Network.GetDescription(Description);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(Description)
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Network.GetDomainType(Domain);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(GetEnumName(Domain))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Network.GetName(AName);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(AName)
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Network.GetTimeCreatedAndConnected(CreationDateTime,
          ConnectedDateTime);
        if Res = WCL_E_SUCCESS then begin
          Item.SubItems.Add(DateToStr(CreationDateTime));
          Item.SubItems.Add(DateToStr(ConnectedDateTime));
        end else begin
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));
        end;

        Res := Network.GetConnected(Connected);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(BoolToStr(Connected, True))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Network.GetConnectedToInternet(Connected);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(BoolToStr(Connected, True))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));
      end;
    end;

  finally
    // Cleanup
    for i := 0 to Length(Networks) - 1 do
      Networks[i].Free;
    Networks := nil;
  end;
end;

procedure TfmMain.btRefreshClick(Sender: TObject);
var
  Id: TGUID;
  Network: TwclNlmNetwork;
  Item: TListItem;
  Category: TwclNlmNetworkCategory;
  Connectivity: TwclNlmConnectivityFlags;
  Description: string;
  Domain: TwclNlmDomainType;
  AName: string;
  Res: Integer;
  CreationDateTime: TDateTime;
  ConnectedDateTime: TDateTime;
  Connected: Boolean;
begin
  if lvNetworks.Selected = nil then
    ShowWarning('Select network')

  else begin
    Item := lvNetworks.Selected;
    Id := StringToGUID(Item.Caption);
    if not ShowError(NetworkListManager.GetNetwork(Id, Network)) then
    begin
      try
        Res := Network.GetCategory(Category);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[0] := GetEnumName(Category)
        else
          Item.SubItems[0] := 'Error: 0x' + IntToHex(Res, 9);

        Res := Network.GetConnectivity(Connectivity);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[1] := DecodeFlags(Connectivity)
        else
          Item.SubItems[1] := 'Error: 0x' + IntToHex(Res, 8);

        Res := Network.GetDescription(Description);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[2] := Description
        else
          Item.SubItems[2] := 'Error: 0x' + IntToHex(Res, 8);

        Res := Network.GetDomainType(Domain);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[3] := GetEnumName(Domain)
        else
          Item.SubItems[3] := 'Error: 0x' + IntToHex(Res, 8);

        Res := Network.GetName(AName);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[4] := AName
        else
          Item.SubItems[4] := 'Error: 0x' + IntToHex(Res, 8);

        Res := Network.GetTimeCreatedAndConnected(CreationDateTime,
          ConnectedDateTime);
        if Res = WCL_E_SUCCESS then begin
          Item.SubItems[5] := DateToStr(CreationDateTime);
          Item.SubItems[6] := DateToStr(ConnectedDateTime);
        end else begin
          Item.SubItems[5] := 'Error: 0x' + IntToHex(Res, 8);
          Item.SubItems[6] := 'Error: 0x' + IntToHex(Res, 8);
        end;

        Res := Network.GetConnected(Connected);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[7] := BoolToStr(Connected, True)
        else
          Item.SubItems[7] := 'Error: 0x' + IntToHex(Res, 8);

        Res := Network.GetConnectedToInternet(Connected);
        if Res = WCL_E_SUCCESS then
          Item.SubItems[8] := BoolToStr(Connected, True)
        else
          Item.SubItems[8] := 'Error: 0x' + IntToHex(Res, 8);

      finally
        Network.Free;
      end;
    end;
  end;
end;

procedure TfmMain.btSetNameClick(Sender: TObject);
var
  Network: TwclNlmNetwork;
  Res: Integer;
begin
  if lvNetworks.Selected = nil then
    ShowWarning('Select network')

  else begin
    Res := NetworkListManager.GetNetwork(
      StringToGUID(lvNetworks.Selected.Caption), Network);
    if not ShowError(Res) then begin
      if ShowError(Network.SetName(edNewNameOrDescription.Text)) then
        ShowWarning('Admin privilegies required');
      Network.Free;
    end;
  end;
end;

procedure TfmMain.btSetDescriptionClick(Sender: TObject);
var
  Network: TwclNlmNetwork;
  Res: Integer;
begin
  if lvNetworks.Selected = nil then
    ShowWarning('Select network')

  else begin
    Res := NetworkListManager.GetNetwork(
      StringToGUID(lvNetworks.Selected.Caption), Network);
    if not ShowError(Res) then begin
      if ShowError(Network.SetDescription(edNewNameOrDescription.Text)) then
        ShowWarning('Admin privilegies required');
      Network.Free;
    end;
  end;
end;

procedure TfmMain.btSetCategoryClick(Sender: TObject);
var
  Network: TwclNlmNetwork;
  Res: Integer;
begin
  if lvNetworks.Selected = nil then
    ShowWarning('Select network')

  else begin
    Res := NetworkListManager.GetNetwork(
      StringToGUID(lvNetworks.Selected.Caption), Network);
    if not ShowError(Res) then begin
      Res := Network.SetCategory(TwclNlmNetworkCategory(cbCategory.ItemIndex));
      if ShowError(Res) then
        ShowWarning('Admin privilegies required');
      Network.Free;
    end;
  end;
end;

procedure TfmMain.ShowConnections(var Connections: TwclNlmConnections);
var
  i: Integer;
  Connection: TwclNlmConnection;
  Item: TListItem;
  Id: TGUID;
  Res: Integer;
  Connected: Boolean;
  Connectivity: TwclNlmConnectivityFlags;
  Domain: TwclNlmDomainType;
begin
  lvConnections.Items.Clear;

  if Connections <> nil then begin
    try
      for i := 0 to Length(Connections) - 1 do begin
        Connection := Connections[i];
        Item := lvConnections.Items.Add;

        Res := Connection.GetAdapterId(Id);
        if Res = WCL_E_SUCCESS then
          Item.Caption := GUIDToString(Id)
        else
          Item.Caption := 'Error: 0x' + IntToHex(Res, 8);

        Res := Connection.GetConnected(Connected);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(BoolToStr(Connected, True))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Connection.GetConnectedToInternet(Connected);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(BoolToStr(Connected, True))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Connection.GetConnectivity(Connectivity);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(DecodeFlags(Connectivity))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Connection.GetDomainType(Domain);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(GetEnumName(Domain))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));

        Res := Connection.GetId(Id);
        if Res = WCL_E_SUCCESS then
          Item.SubItems.Add(GUIDToString(Id))
        else
          Item.SubItems.Add('Error: 0x' + IntToHex(Res, 8));
      end;

    finally
      for i := 0 to Length(Connections) - 1 do
        Connections[i].Free;
      Connections := nil;
    end;
  end;
end;

procedure TfmMain.btGetMachineConnectionsClick(Sender: TObject);
var
  Connections: TwclNlmConnections;
begin
  if not ShowError(NetworkListManager.GetConnections(Connections)) then
    ShowConnections(Connections);
end;

procedure TfmMain.btGetNetworkConnectionsClick(Sender: TObject);
var
  Id: TGUID;
  Network: TwclNlmNetwork;
  Connections: TwclNlmConnections;
  Item: TListItem;
begin
  if lvNetworks.Selected = nil then
    ShowWarning('Select network')

  else begin
    Item := lvNetworks.Selected;
    Id := StringToGUID(Item.Caption);
    if not ShowError(NetworkListManager.GetNetwork(Id, Network)) then
    begin
      try
        if not ShowError(Network.GetConnections(Connections)) then
          ShowConnections(Connections);

      finally
        Network.Free;
      end;
    end;
  end;
end;

procedure TfmMain.NetworkListManagerAfterOpen(Sender: TObject);
begin
  lbEvents.Items.Add('AfterOpen');
end;

procedure TfmMain.NetworkListManagerBeforeClose(Sender: TObject);
begin
  lbEvents.Items.Add('BeforeClose');
end;

procedure TfmMain.NetworkListManagerConnectivityChanged(Sender: TObject;
  const Connectivity: TwclNlmConnectivityFlags);
begin
  lbEvents.Items.Add('Connectivity changed: ' + DecodeFlags(Connectivity));
end;

procedure TfmMain.NetworkListManagerNetworkAdded(Sender: TObject;
  const NetworkId: TGUID);
begin
  lbEvents.Items.Add('Network added: ' + GUIDToString(NetworkId));
end;

procedure TfmMain.NetworkListManagerNetworkConnectivityChanged(
  Sender: TObject; const NetworkId: TGUID;
  const Connectivity: TwclNlmConnectivityFlags);
begin
  lbEvents.Items.Add('Network ' + GUIDToString(NetworkId) +
    ' connectivity changed: ' + DecodeFlags(Connectivity));
end;

procedure TfmMain.NetworkListManagerNetworkDeleted(Sender: TObject;
  const NetworkId: TGUID);
begin
  lbEvents.Items.Add('Network deleted: ' + GUIDToString(NetworkId));
end;

procedure TfmMain.NetworkListManagerNetworkPropertyChanged(
  Sender: TObject; const NetworkId: TGUID;
  const Change: TwclNlmNetworkPropertyChangeFlags);
begin
  lbEvents.Items.Add('Network ' + GUIDToString(NetworkId) +
    ' property changed: ' + DecodeFlags(Change));
end;

procedure TfmMain.NetworkListManagerConnectionConnectivityChanged(
  Sender: TObject; const ConnectionId: TGUID;
  const Connectivity: TwclNlmConnectivityFlags);
begin
  lbEvents.Items.Add('Connection: ' + GUIDToString(ConnectionId) +
    ' connectivity changed: ' + DecodeFlags(Connectivity));
end;

procedure TfmMain.NetworkListManagerConnectionPropertyChanged(
  Sender: TObject; const ConnectionId: TGUID;
  const Prop: TwclNlmConnectionProperty);
begin
  lbEvents.Items.Add('Connection: ' + GUIDToString(ConnectionId) +
    ' property changed: ' + GetEnumName(Prop));
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  NetworkListManager.Close;
  NetworkListManager.Free;
end;

procedure TfmMain.btDeleteClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvNetworks.Selected = nil then
    ShowWarning('Select network')

  else begin
    Res := NetworkListManager.DeleteNetwork(
      StringToGUID(lvNetworks.Selected.Caption));
    if not ShowError(Res) then
      lvNetworks.Selected.Delete;
  end;
end;

end.

