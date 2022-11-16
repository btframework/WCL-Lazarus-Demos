unit main;

{$I wcl.inc}

interface

uses
  Forms, wclBluetooth, StdCtrls, ComCtrls, Controls, Classes;

type
  TfmMain = class(TForm)
    laReadBuffer: TLabel;
    laWriteBuffer: TLabel;
    btListen: TButton;
    btClose: TButton;
    lbEvents: TListBox;
    btClear: TButton;
    lvClients: TListView;
    btDisconnect: TButton;
    edText: TEdit;
    btSend: TButton;
    btGetBuffers: TButton;
    btSetBuffers: TButton;
    edReadBuffer: TEdit;
    edWriteBuffer: TEdit;
    cbAuthentication: TCheckBox;
    cbEcnryption: TCheckBox;
    laServiceName: TLabel;
    edServiceName: TEdit;
    procedure btClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btListenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure btGetBuffersClick(Sender: TObject);
    procedure btSetBuffersClick(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclRfCommServer: TwclRfCommServer;

    procedure wclBluetoothManagerNumericComparison(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Number: Cardinal; out Confirm: Boolean);
    procedure wclBluetoothManagerPasskeyNotification(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Passkey: Cardinal);
    procedure wclBluetoothManagerPasskeyRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Passkey: Cardinal);
    procedure wclBluetoothManagerPinRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Pin: String);

    procedure wclRfCommServerClosed(Sender: TObject;
      const Reason: Integer);
    procedure wclRfCommServerConnect(Sender: TObject;
      const Client: TwclRfCommServerClientConnection;
      const Error: Integer);
    procedure wclRfCommServerData(Sender: TObject;
      const Client: TwclRfCommServerClientConnection; const Data: Pointer;
      const Size: Cardinal);
    procedure wclRfCommServerDisconnect(Sender: TObject;
      const Client: TwclRfCommServerClientConnection;
      const Reason: Integer);
    procedure wclRfCommServerListen(Sender: TObject);

    function GetRadio: TwclBluetoothRadio;
    function GetDeviceName(const Address: Int64): string;
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclUUIDs, wclErrors, Dialogs, SysUtils, wclConnectionErrors,
  wclBluetoothErrors, Windows;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Clear;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);
  wclBluetoothManager.OnNumericComparison := wclBluetoothManagerNumericComparison;
  wclBluetoothManager.OnPasskeyNotification := wclBluetoothManagerPasskeyNotification;
  wclBluetoothManager.OnPasskeyRequest := wclBluetoothManagerPasskeyRequest;
  wclBluetoothManager.OnPinRequest := wclBluetoothManagerPinRequest;

  wclRfCommServer := TwclRfCommServer.Create(nil);
  wclRfCommServer.ServiceName := 'WCL SPP Server';
  wclRfCommServer.OnClosed := wclRfCommServerClosed;
  wclRfCommServer.OnConnect := wclRfCommServerConnect;
  wclRfCommServer.OnData := wclRfCommServerData;
  wclRfCommServer.OnDisconnect := wclRfCommServerDisconnect;
  wclRfCommServer.OnListen := wclRfCommServerListen;

  // In real application you should always analize the result code.
  // In this demo we assume that all is always OK.
  wclBluetoothManager.Open;

  cbAuthentication.Checked := wclRfCommServer.Authentication;
  cbEcnryption.Checked := wclRfCommServer.Encryption;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclRfCommServer.Close;
  wclRfCommServer.Free;

  wclBluetoothManager.Close;
  wclBluetoothManager.Free;
end;

function TfmMain.GetRadio: TwclBluetoothRadio;
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := wclBluetoothManager.GetClassicRadio(Radio);
  if Res <> WCL_E_SUCCESS then begin
    MessageDlg('Get working radio failed: 0x' + IntToHex(Res, 8), mtError,
      [mbOK], 0);
    Result := nil;
  end else
    Result := Radio;
end;

procedure TfmMain.btListenClick(Sender: TObject);
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    wclRfCommServer.Authentication := cbAuthentication.Checked;
    wclRfCommServer.Encryption := cbEcnryption.Checked;
    
    wclRfCommServer.Service := SerialPortServiceClass_UUID;
    wclRfCommServer.ServiceName := edServiceName.Text;

    Res := wclRfCommServer.Listen(Radio);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclRfCommServer.Close;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Res := TwclRfCommServerClientConnection(lvClients.Selected.Data).Disconnect;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btSendClick(Sender: TObject);
var
  Res: Integer;
  Ansi: AnsiString;
  Sent: Cardinal;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Ansi := AnsiString(edText.Text);
    Res := TwclRfCommServerClientConnection(
      lvClients.Selected.Data).Write(PByte(Ansi), Length(Ansi), Sent);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
    else
      MessageDlg('Sent: ' + IntToStr(Sent) + ' from ' + IntToStr(Length(Ansi)),
        mtInformation, [mbOK], 0);
  end;
end;

procedure TfmMain.btGetBuffersClick(Sender: TObject);
var
  Client: TwclRfCommServerClientConnection;
  Res: Integer;
  Size: Cardinal;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Client := TwclRfCommServerClientConnection(lvClients.Selected.Data);

    // Get read buffer.
    Size := 0;
    Res := Client.GetReadBufferSize(Size);
    if Res <> WCL_E_SUCCESS then
      lbEvents.Items.Add('Get read buffer error: 0x' + IntToHex(Res, 8))
    else
      edReadBuffer.Text := IntToStr(Size);

    // Get write buffer.
    Size := 0;
    Res := Client.GetWriteBufferSize(Size);
    if Res <> WCL_E_SUCCESS then
      lbEvents.Items.Add('Get write buffer error: 0x' + IntToHex(Res, 8))
    else
      edWriteBuffer.Text := IntToStr(Size);
  end;
end;

procedure TfmMain.btSetBuffersClick(Sender: TObject);
var
  Client: TwclRfCommServerClientConnection;
  Res: Integer;
  Size: Cardinal;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Client := TwclRfCommServerClientConnection(lvClients.Selected.Data);

    // Set read buffer.
    Size := StrToInt(edReadBuffer.Text);
    Res := Client.SetReadBufferSize(Size);
    if Res <> WCL_E_SUCCESS then
      lbEvents.Items.Add('Set read buffer error: 0x' + IntToHex(Res, 8));

    // Set write buffer.
    Size := StrToInt(edWriteBuffer.Text);
    Res := Client.SetWriteBufferSize(Size);
    if Res <> WCL_E_SUCCESS then
      lbEvents.Items.Add('Set write buffer error: 0x' + IntToHex(Res, 8));
  end;
end;

function TfmMain.GetDeviceName(const Address: Int64): string;
var
  Radio: TwclBluetoothRadio;
  DevName: string;
  Res: Integer;
begin
  Result := '';

  Radio := GetRadio;
  if Radio <> nil then begin
    Res := Radio.GetRemoteName(Address, DevName);
    if Res = WCL_E_SUCCESS then
      Result := DevName
    else
      Result := 'Error: 0x' + IntToHex(Res, 8);
  end;
end;

procedure TfmMain.wclBluetoothManagerNumericComparison(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Number: Cardinal; out Confirm: Boolean);
begin
  // Accept any pairing.
  Confirm := True;
  lbEvents.Items.Add('Numeric comparison: ' + IntToStr(Number));
end;

procedure TfmMain.wclBluetoothManagerPasskeyNotification(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Passkey: Cardinal);
begin
  lbEvents.Items.Add('Passkey notification: ' + IntToStr(Passkey));
end;

procedure TfmMain.wclBluetoothManagerPasskeyRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Passkey: Cardinal);
begin
  // Use 123456 as passkey.
  Passkey := 123456;
  lbEvents.Items.Add('Passkey request: ' + IntToStr(Passkey));
end;

procedure TfmMain.wclBluetoothManagerPinRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64; out Pin: String);
begin
  // Use '0000' as PIN.
  Pin := '0000';
  lbEvents.Items.Add('Pin request: ' + Pin);
end;

procedure TfmMain.wclRfCommServerClosed(Sender: TObject;
  const Reason: Integer);
begin
  lbEvents.Items.Add('Server closed on radio ' +
    TwclRfCommServer(Sender).Radio.ApiName + ' with reason: 0x' +
    IntToHex(Reason, 8));

  lvClients.Clear;

  edReadBuffer.Text := '';
  edWriteBuffer.Text := '';
end;

procedure TfmMain.wclRfCommServerConnect(Sender: TObject;
  const Client: TwclRfCommServerClientConnection; const Error: Integer);
var
  Item: TListItem;
  Server: TwclRfCommServerConnection;
begin
  Server := TwclRfCommServerConnection(Client.Server);

  lbEvents.Items.Add('Client connected: ' + IntToHex(Client.Address, 12) +
    ' on Radio ' + Server.Radio.ApiName + ' error: 0x' +
    IntToHex(Error, 8));

  Item := lvClients.Items.Add;
  Item.Caption := IntToHex(Client.Address, 12);
  Item.SubItems.Add(GetDeviceName(Client.Address));
  Item.Data := Client;
end;

procedure TfmMain.wclRfCommServerData(Sender: TObject;
  const Client: TwclRfCommServerClientConnection; const Data: Pointer;
  const Size: Cardinal);
var
  Str: AnsiString;
  Server: TwclRfCommServerConnection;
begin
  if Size > 0 then begin
    SetLength(Str, Size);
    CopyMemory(Pointer(Str), Data, Size);

    Server := TwclRfCommServerConnection(Client.Server);
    lbEvents.Items.Add('Received: ' + string(Str) + ' from ' +
      IntToHex(Client.Address, 12) + ' on radio ' + Server.Radio.ApiName);
  end;
end;

procedure TfmMain.wclRfCommServerDisconnect(Sender: TObject;
  const Client: TwclRfCommServerClientConnection; const Reason: Integer);
var
  Server: TwclRfCommServerConnection;
  i: Integer;
begin
  Server := TwclRfCommServerConnection(Client.Server);

  lbEvents.Items.Add('Client disconnected: ' + IntToHex(Client.Address, 12) +
    ' on radio ' + Server.Radio.ApiName + ' reason: 0x' + IntToHex(Reason, 8));

  for i := 0 to lvClients.Items.Count - 1 do begin
    if lvClients.Items[i].Data = Client then begin
      lvClients.Items.Delete(i);
      Break;
    end;
  end;
end;

procedure TfmMain.wclRfCommServerListen(Sender: TObject);
begin
  lbEvents.Items.Add('Server listening on radio ' +
    TwclRfCommServer(Sender).Radio.ApiName + ' on channel: ' +
    IntToStr(TwclRfCommServer(Sender).AssignedChannel));
end;

end.
