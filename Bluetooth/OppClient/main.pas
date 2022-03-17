unit main;

{$I wcl.inc}

interface

uses
  Forms, wclBluetooth, Classes, Controls, ComCtrls, StdCtrls, wclConnections,
  wclObex, Dialogs;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    lvDevices: TListView;
    lbLog: TListBox;
    btClear: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    btOpenSession: TButton;
    btCloseSession: TButton;
    btSelectFile: TButton;
    OpenDialog: TOpenDialog;
    edFileName: TEdit;
    btSendFile: TButton;
    btAbort: TButton;
    ProgressBar: TProgressBar;
    btGetvCard: TButton;
    btGetCaps: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btDiscoverClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btCloseSessionClick(Sender: TObject);
    procedure btOpenSessionClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btSelectFileClick(Sender: TObject);
    procedure btAbortClick(Sender: TObject);
    procedure btSendFileClick(Sender: TObject);
    procedure btGetvCardClick(Sender: TObject);
    procedure btGetCapsClick(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclRfCommClient: TwclRfCommClient;
    FOpp: TwclObexOppClient;

    procedure wclBluetoothManagerAfterOpen(Sender: TObject);
    procedure wclBluetoothManagerAuthenticationCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Error: Integer);
    procedure wclBluetoothManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);
    procedure wclBluetoothManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);
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
    procedure wclBluetoothManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);

    procedure wclRfCommClientDisconnect(Sender: TObject;
      const Reason: Integer);
    procedure wclRfCommClientConnect(Sender: TObject;
      const Error: Integer);
    procedure wclRfCommClientDestroyProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);
    procedure wclRfCommClientCreateProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);

    function GetRadio: TwclBluetoothRadio;

    procedure OppConnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure OppDisconnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure OppPutComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
    procedure OppProgress(Sender: TObject; const Length: Cardinal;
      const Position: Cardinal);
    procedure OppGetComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

uses
  wclUUIDs, wclErrors, SysUtils, Windows;

procedure TfmMain.FormCreate(Sender: TObject);
var
  Res: Integer;
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);
  wclBluetoothManager.AfterOpen := wclBluetoothManagerAfterOpen;
  wclBluetoothManager.OnAuthenticationCompleted := wclBluetoothManagerAuthenticationCompleted;
  wclBluetoothManager.OnDeviceFound := wclBluetoothManagerDeviceFound;
  wclBluetoothManager.OnDiscoveringCompleted := wclBluetoothManagerDiscoveringCompleted;
  wclBluetoothManager.OnDiscoveringStarted := wclBluetoothManagerDiscoveringStarted;
  wclBluetoothManager.OnNumericComparison := wclBluetoothManagerNumericComparison;
  wclBluetoothManager.OnPasskeyNotification := wclBluetoothManagerPasskeyNotification;
  wclBluetoothManager.OnPasskeyRequest := wclBluetoothManagerPasskeyRequest;
  wclBluetoothManager.OnPinRequest := wclBluetoothManagerPinRequest;

  wclRfCommClient := TwclRfCommClient.Create(nil);
  wclRfCommClient.OnConnect := wclRfCommClientConnect;
  wclRfCommClient.OnCreateProcessor := wclRfCommClientCreateProcessor;
  wclRfCommClient.OnDestroyProcessor := wclRfCommClientDestroyProcessor;
  wclRfCommClient.OnDisconnect := wclRfCommClientDisconnect;
  // We use ObjectPush Profile so must set the profile's UUID.
  wclRfCommClient.Service := OBEXObjectPushServiceClass_UUID;

  FOpp := nil;

  // Try to open Bluetooth Manager.
  Res := wclBluetoothManager.Open;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Bluetooth Manager Open failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclRfCommClient.Disconnect;
  wclRfCommClient.Free;

  wclBluetoothManager.Close;
  wclBluetoothManager.Free;
end;

procedure TfmMain.wclBluetoothManagerAfterOpen(Sender: TObject);
begin
  lbLog.Items.Add('Bluetooth Manager has been opened');
end;

procedure TfmMain.wclBluetoothManagerAuthenticationCompleted(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  const Error: Integer);
begin
  lbLog.Items.Add('Authentication completed with result: 0x' +
    IntToHex(Error, 8));
end;

procedure TfmMain.wclBluetoothManagerDiscoveringCompleted(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Error: Integer);
var
  i: Integer;
  Item: TListItem;
  Addr: Int64;
  Name: string;
  Res: Integer;
begin
  lbLog.Items.Add('Discovering completed with result: 0x' +
    IntToHex(Error, 8));

  for i := 0 to lvDevices.Items.Count - 1 do begin
    Item := lvDevices.Items[i];
    Addr := StrToInt64('$' + Item.Caption);
    Res := Radio.GetRemoteName(Addr, Name);
    if Res <> WCL_E_SUCCESS then
      Name := 'Error: 0x' + IntToHex(Res, 8);
    Item.SubItems[0] := Name;
  end;
end;

procedure TfmMain.wclBluetoothManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  lbLog.Items.Add('Discovering started');

  lvDevices.Items.Clear;
end;

procedure TfmMain.wclBluetoothManagerNumericComparison(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Number: Cardinal; out Confirm: Boolean);
begin
  lbLog.Items.Add('Numeric comparison. Accept');
  Confirm := True;
end;

procedure TfmMain.wclBluetoothManagerPasskeyNotification(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Passkey: Cardinal);
begin
  lbLog.Items.Add('Passkey notification. Passkey: ' + IntToStr(Passkey));
end;

procedure TfmMain.wclBluetoothManagerPasskeyRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Passkey: Cardinal);
begin
  lbLog.Items.Add('Passkey request. Passkey: 12345678');
  Passkey := 12345678;
end;

procedure TfmMain.wclBluetoothManagerPinRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64; out Pin: String);
begin
  lbLog.Items.Add('PIN code request. PIN: 0000');
  Pin := '0000';
end;

procedure TfmMain.wclBluetoothManagerDeviceFound(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64);
var
  Item: TListItem;
begin
  Item := lvDevices.Items.Add;
  Item.Caption := IntToHex(Address, 12);
  Item.SubItems.Add('');
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

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Res: Integer;
begin
  Radio := GetRadio;
  if Radio <> nil then begin
    // Discover classic devices only.
    Res := Radio.Discover(10, dkClassic);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Failed to start discovering: 0x' + IntToHex(Res, 8),
        mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclRfCommClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Disconnect failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.wclRfCommClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  lbLog.Items.Add('Disconnected with reason: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclRfCommClientConnect(Sender: TObject;
  const Error: Integer);
begin
  lbLog.Items.Add('Connect. Operation result: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.wclRfCommClientDestroyProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // Do we have any data processor created?
  if FOpp <> nil then begin
    // Make sure it is our connection is goind to destroy.
    if Connection.Processor = FOpp then begin
      // Ok, destroy the data processor here.
      FOpp.Free;
      FOpp := nil;
    end;
  end;
end;

procedure TfmMain.wclRfCommClientCreateProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // here we must create the data processor for the connection. In this demo
  // we use OPPClient.
  FOpp := TwclObexOppClient.Create(Connection);
  FOpp.OnConnect := OppConnect;
  FOpp.OnDisconnect := OppDisconnect;
  FOpp.OnGetComplete := OppGetComplete;
  FOpp.OnPutComplete := OppPutComplete;
  FOpp.OnProgress := OppProgress;
end;

procedure TfmMain.btCloseSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FOpp.Disconnect('');
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Close session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
  end;
end;

procedure TfmMain.btOpenSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FOpp.Connect;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Open session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
  end;
end;

procedure TfmMain.OppConnect(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('OBEX session opened with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);
end;

procedure TfmMain.OppDisconnect(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('OBEX session closed with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Addr: Int64;
  Res: Integer;
begin
  if wclRfCommClient.State <> csDisconnected then
    MessageDlg('Client is connected', mtWarning, [mbOK], 0)
  else begin
    if lvDevices.Selected = nil then
      MessageDlg('Select device', mtWarning, [mbOK], 0)

    else begin
      Radio := GetRadio;
      if Radio <> nil then begin
        Addr := StrToInt64('$' + lvDevices.Selected.Caption);
        wclRfCommClient.Address := Addr;
        Res := wclRfCommClient.Connect(Radio);
        if Res <> WCL_E_SUCCESS then begin
          MessageDlg('Failed to connect: 0x' + IntToHex(Res, 8),
            mtError, [mbOK], 0);
        end;
      end;
    end;
  end;
end;

procedure TfmMain.btSelectFileClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    edFileName.Text := OpenDialog.FileName;
end;

procedure TfmMain.OppPutComplete(Sender: TObject; const Error: Integer;
  const Description: string; const Stream: TStream);
begin
  lbLog.Items.Add('File sending completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  // We must destroy the stream object here.
  Stream.Free;
end;

procedure TfmMain.OppProgress(Sender: TObject; const Length: Cardinal;
  const Position: Cardinal);
begin
  ProgressBar.Max := Length;
  ProgressBar.Position := Position;
end;

procedure TfmMain.btAbortClick(Sender: TObject);
var
  Res: Integer;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FOpp.Abort('');
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Abort failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btSendFileClick(Sender: TObject);
var
  Res: Integer;
  Stream: TStream;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    if edFileName.Text = '' then
      MessageDlg('Select file', mtWarning, [mbOK], 0)
    else begin
      Stream := TFileStream.Create(edFileName.Text, fmOpenRead);
      Res := FOpp.Put(ExtractFileName(edFileName.Text), '', Stream);
      if Res <> WCL_E_SUCCESS then begin
        MessageDlg('Send file failed: 0x' + IntToHex(Res, 8), mtError,
          [mbOK], 0);
        Stream.Free;
      end;
    end;
  end;
end;

procedure TfmMain.btGetvCardClick(Sender: TObject);
var
  Res: Integer;
  Stream: TStream;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Stream := TFileStream.Create('vcard.vcf', fmCreate);
    // Request default vCard object.
    Res := FOpp.Get('text/x-vCard', Stream);
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('GetvCard failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
      Stream.Free;
    end;
  end;
end;

procedure TfmMain.btGetCapsClick(Sender: TObject);
var
  Res: Integer;
  Stream: TStream;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Stream := TFileStream.Create('caps.xml', fmCreate);
    // Request Device Capability object.
    Res := FOpp.Get('x-obex/capability', Stream);
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('GetCaps failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
      Stream.Free;
    end;
  end;
end;

procedure TfmMain.OppGetComplete(Sender: TObject; const Error: Integer;
  const Description: string; const Stream: TStream);
begin
  lbLog.Items.Add('File receiving completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  // We must destroy the stream object here.
  Stream.Free;
end;

end.
