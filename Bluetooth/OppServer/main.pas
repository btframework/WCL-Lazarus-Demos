unit main;

{$I wcl.inc}

interface

uses
  Forms, wclBluetooth, Classes, Controls, StdCtrls, wclConnections,
  ComCtrls, Dialogs, wclObex;

type
  TfmMain = class(TForm)
    btListen: TButton;
    btClose: TButton;
    lbLog: TListBox;
    btClear: TButton;
    lvClients: TListView;
    btDisconnect: TButton;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btListenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);

  private
    wclBluetoothManager: TwclBluetoothManager;
    wclRfCommServer: TwclRfCommServer;

    FFileName: string;

    procedure wclRfCommServerListen(Sender: TObject);
    procedure wclRfCommServerClosed(Sender: TObject;
      const Reason: Integer);
    procedure wclRfCommServerDisconnect(Sender: TObject;
      const Client: TwclRfCommServerClientConnection;
      const Reason: Integer);
    procedure wclRfCommServerDestroyProcessor(Sender: TObject;
      const Connection: TwclServerClientDataConnection);
    procedure wclRfCommServerConnect(Sender: TObject;
      const Client: TwclRfCommServerClientConnection;
      const Error: Integer);
    procedure wclRfCommServerCreateProcessor(Sender: TObject;
      const Connection: TwclServerClientDataConnection);

    procedure wclRfCommServerGetSdpAttributes(Sender: TObject;
      out Protocols: TwclBluetoothSdpProtocols;
      out Profiles: TwclBluetoothSdpProfiles;
      out Formats: TwclBluetoothSdpFormats; out Cod: Cardinal);

    procedure Trace(const Msg: string);

    procedure OppClientConnect(Sender: TObject; const Description: string);
    procedure OppClientDisconnected(Sender: TObject; const Reason: Integer;
      const Description: string);
    procedure OppClientPutBegin(Sender: TObject; const Name: string;
      const Description: string; const Mime: string; const Length: Cardinal;
      out Accept: Boolean);
    procedure OppClientPutCompleted(Sender: TObject; const Error: Integer;
      const Stream: TStream; out Accept: Boolean);
    procedure OppClientPutProgress(Sender: TObject; const Position: Cardinal;
      const Length: Cardinal; out Continue: Boolean);
    procedure OppClientGetRequest(Sender: TObject; const aType: string;
      out Result: TwclObexServerOperationResult; out Stream: TStream);
    procedure OppClientGetCompleted(Sender: TObject; const Error: Integer;
      const Stream: TStream);
    procedure OppClientProgress(Sender: TObject; const Length: Cardinal;
      const Position: Cardinal);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclUUIDs, wclErrors, SysUtils, Windows, wclCods;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclBluetoothManager := TwclBluetoothManager.Create(nil);

  wclRfCommServer := TwclRfCommServer.Create(nil);
  wclRfCommServer.Authentication := False;
  wclRfCommServer.Service := OBEXObjectPushServiceClass_UUID;
  wclRfCommServer.ServiceName := 'WCL OPP Server';
  wclRfCommServer.GetSdpAttributes := wclRfCommServerGetSdpAttributes;
  wclRfCommServer.OnClosed := wclRfCommServerClosed;
  wclRfCommServer.OnConnect := wclRfCommServerConnect;
  wclRfCommServer.OnCreateProcessor := wclRfCommServerCreateProcessor;
  wclRfCommServer.OnDestroyProcessor := wclRfCommServerDestroyProcessor;
  wclRfCommServer.OnDisconnect := wclRfCommServerDisconnect;
  wclRfCommServer.OnListen := wclRfCommServerListen;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclRfCommServer.Close;
  wclRfCommServer.Free;

  wclBluetoothManager.Close;
  wclBluetoothManager.Free;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.btListenClick(Sender: TObject);
var
  Res: Integer;
  Radio: TwclBluetoothRadio;
begin
  Res := wclBluetoothManager.Open;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Bluetooth manager open failed: 0x' + IntToHex(Res, 8))

  else begin
    Res := wclBluetoothManager.GetClassicRadio(Radio);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Get working radio failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0)

    else begin
      // As wrote above it is better to start listening in AfterOpen event
      // handler. But again, for demo app its OK to do it here.
      Res := wclRfCommServer.Listen(Radio);
      if Res <> WCL_E_SUCCESS then
        ShowMessage('Failed to start listening: 0x' + IntToHex(Res, 8));
    end;

    if Res <> WCL_E_SUCCESS then
      // We must close Bluetooth Manager here!
      wclBluetoothManager.Close;
  end;
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclRfCommServer.Close;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Close failed; 0x' + IntToHex(Res, 8))
  else
    wclBluetoothManager.Close;
end;

procedure TfmMain.wclRfCommServerListen(Sender: TObject);
begin
  Trace('Server listening');
end;

procedure TfmMain.Trace(const Msg: string);
begin
  lbLog.Items.Add(Msg);
end;

procedure TfmMain.wclRfCommServerClosed(Sender: TObject;
  const Reason: Integer);
begin
  Trace('Server closed. Reason:: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclRfCommServerDisconnect(Sender: TObject;
  const Client: TwclRfCommServerClientConnection; const Reason: Integer);
begin
  Trace('Client ' + IntToHex(Client.Address, 12) + ' disconnected. Reason: 0x' +
    IntToHex(Reason, 8));
end;

procedure TfmMain.wclRfCommServerDestroyProcessor(Sender: TObject;
  const Connection: TwclServerClientDataConnection);
begin
  Trace('Data processor for client ' +
    IntToHex(TwclRfCommServerClientConnection(Connection).Address, 12) +
    ' is destroing');
  Connection.Processor.Free;
end;

procedure TfmMain.wclRfCommServerConnect(Sender: TObject;
  const Client: TwclRfCommServerClientConnection; const Error: Integer);
begin
  if Error = WCL_E_SUCCESS then
    Trace('Client ' + IntToHex(Client.Address, 12) + ' connected')

  else begin
    Trace('Client ' + IntToHex(Client.Address, 12) +
      ' connect failed: 0x' + IntToHex(Error, 8));
  end;
end;

procedure TfmMain.wclRfCommServerCreateProcessor(Sender: TObject;
  const Connection: TwclServerClientDataConnection);
var
  Proc: TwclObexOppServer;
begin
  // Here we must create OBEX OPP server data processor.
  Proc := TwclObexOppServer.Create(Connection);
  Proc.OnConnect := OppClientConnect;
  Proc.OnDisconnected := OppClientDisconnected;
  Proc.OnPutBegin := OppClientPutBegin;
  Proc.OnPutCompleted := OppClientPutCompleted;
  Proc.OnPutProgress := OppClientPutProgress;
  Proc.OnGetRequest := OppClientGetRequest;
  Proc.OnGetCompleted := OppClientGetCompleted;
  Proc.OnProgress := OppClientProgress;
end;

procedure TfmMain.OppClientConnect(Sender: TObject;
  const Description: string);
var
  Address: Int64;
  Proc: TwclObexOppServer;
  Accept: Boolean;
  Res: Integer;
  Item: TListItem;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclRfCommServerClientConnection(Proc.Connection).Address;
  Accept := MessageDlg('Client ' + IntToHex(Address, 12) +
    ' requsts for connection: ' + Description + '. Accept?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes;

  if Accept then begin
    Res := Proc.Accept('Accepted by user');
    if Res = WCL_E_SUCCESS then begin
      Item := lvClients.Items.Add;
      Item.Caption := IntToHex(Address, 12);
      Item.Data := Sender;
      Trace('OBEX session opened for client: ' + IntToHex(Address, 12));
    end;

  end else
    Res := Proc.Reject('Rejected by user');

  if Res <> WCL_E_SUCCESS then begin
    ShowMessage('Operation failed: 0x' + IntToHex(Res, 8));
    // Disconnect client!
    Proc.Connection.Disconnect;
  end;
end;

procedure TfmMain.OppClientDisconnected(Sender: TObject;
  const Reason: Integer; const Description: string);
var
  Address: Int64;
  Proc: TwclObexOppServer;
  i: Integer;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclRfCommServerClientConnection(Proc.Connection).Address;

  Trace('Client ' + IntToHex(Address, 12) +
    ' closed OBEX session with reason: 0x' + IntToHex(Reason, 8) +
    '. Description: ' + Description);

  for i := 0 to lvClients.Items.Count - 1 do begin
    if lvClients.Items[i].Data = Sender then begin
      lvClients.Items.Delete(i);
      Break;
    end;
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Proc: TwclObexOppServer;
  Res: Integer;
begin
  if lvClients.Selected = nil then
    ShowMessage('Select client')

  else begin
    Proc := TwclObexOppServer(lvClients.Selected.Data);
    Res := Proc.Connection.Disconnect;
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Disconnect failed: 0x' + IntToHex(Res, 8));
  end;
end;

procedure TfmMain.wclRfCommServerGetSdpAttributes(Sender: TObject;
  out Protocols: TwclBluetoothSdpProtocols;
  out Profiles: TwclBluetoothSdpProfiles;
  out Formats: TwclBluetoothSdpFormats; out Cod: Cardinal);
begin
  // We have to provide additional information for SDP record.
  SetLength(Protocols, 1);
  Protocols[0] := OBEX_PROTOCOL_UUID16;
  SetLength(Profiles, 1);
  Profiles[0].Uuid := OBEXObjectPushServiceClass_UUID16;
  Profiles[0].Version := $0100;
  SetLength(Formats, 1);
  Formats[0] := $FF; // All formats.
  Cod := COD_SERVICE_OBJECT_XFER;
end;

procedure TfmMain.OppClientPutBegin(Sender: TObject; const Name,
  Description, Mime: string; const Length: Cardinal; out Accept: Boolean);
var
  Address: Int64;
  Proc: TwclObexOppServer;
  Str: string;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclRfCommServerClientConnection(Proc.Connection).Address;
  Str := 'Client ' + IntToHex(Address, 12) + ' send file ' + Name +
    '. Accept?';
  Accept := MessageDlg(Str, mtConfirmation, [mbYes, mbNo], 0) = mrYes;

  if Accept then
    FFileName := Name;
end;

procedure TfmMain.OppClientPutCompleted(Sender: TObject;
  const Error: Integer; const Stream: TStream; out Accept: Boolean);
var
  Address: Int64;
  Proc: TwclObexOppServer;
  Str: string;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclRfCommServerClientConnection(Proc.Connection).Address;
  if Error = WCL_E_SUCCESS then begin
    Str := 'Client ' + IntToHex(Address, 12) + ' completed sent file. Accept?';
    Accept := MessageDlg(Str, mtConfirmation, [mbYes, mbNo], 0) = mrYes;

    if Accept then begin
      SaveDialog.FileName := FFileName;
      if SaveDialog.Execute then
        TMemoryStream(Stream).SaveToFile(SaveDialog.FileName);
    end;

  end else
    Trace('Send file error: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.OppClientPutProgress(Sender: TObject; const Position,
  Length: Cardinal; out Continue: Boolean);
begin
  Trace('Sending file: ' + IntToStr(Position) + ' from ' + IntToStr(Length));
  // Do not foget to set Continue flag!
  Continue := True;
end;

procedure TfmMain.OppClientGetRequest(Sender: TObject; const aType: string;
  out Result: TwclObexServerOperationResult; out Stream: TStream);
begin
  if (aType = 'text/x-vCard') or (aType = 'x-obex/capability') then begin
    Trace('Requested file type: ' + aType);

    if not OpenDialog.Execute then begin
      Result := orForbidden;
      Stream := nil;

    end else begin
      try
        Stream := TFileStream.Create(OpenDialog.FileName, fmOpenRead);
        Result := orSuccess;
      except
        Result := orUnexpected;
      end;
    end;

  end else begin
    Result := orUnsupportedMedia;
    Stream := nil;
  end;
end;

procedure TfmMain.OppClientGetCompleted(Sender: TObject;
  const Error: Integer; const Stream: TStream);
begin
  Trace('Get operation completed with result: 0x' + IntToHex(Error, 8));
  if Stream <> nil then
    Stream.Free;
end;

procedure TfmMain.OppClientProgress(Sender: TObject; const Length: Cardinal;
  const Position: Cardinal);
begin
  Trace('Sending file: ' + IntToStr(Position) + ' from ' + IntToStr(Length));
end;

end.
