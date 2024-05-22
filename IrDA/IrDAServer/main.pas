unit main;

{$MODE Delphi}

interface

uses
  Forms, StdCtrls, ComCtrls, Controls, Classes, wclIrDAServers;

type
  TfmMain = class(TForm)
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
    laReadBuffer: TLabel;
    edReadBuffer: TEdit;
    laWriteBuffer: TLabel;
    edWriteBuffer: TEdit;
    laIasValueType: TLabel;
    cbIasValueType: TComboBox;
    btAddIasRecord: TButton;
    procedure btListenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure IrDAServerListen(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btGetBuffersClick(Sender: TObject);
    procedure btSetBuffersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btAddIasRecordClick(Sender: TObject);

  private
    IrDAServer: TwclIrDAServer;

    procedure IrDAServerConnect(Sender: TObject;
      const Client: TwclIrDAServerClientConnection; const Error: Integer);
    procedure IrDAServerDisconnect(Sender: TObject;
      const Client: TwclIrDAServerClientConnection; const Reason: Integer);
    procedure IrDAServerData(Sender: TObject;
      const Client: TwclIrDAServerClientConnection; const Data: Pointer;
      const Size: Cardinal);
    procedure IrDAServerClosed(Sender: TObject; const Reason: Integer);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils, Windows, wclIrDADevices;

{$R *.lfm}

procedure TfmMain.btListenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAServer.Listen;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAServer.Close;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Clear;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Res := TwclIrDAServerClientConnection(lvClients.Selected.Data).Disconnect;
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
    Res := TwclIrDAServerClientConnection(lvClients.Selected.Data).Write(
      PByte(Ansi), Length(Ansi), Sent);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
    else
      MessageDlg('Sent: ' + IntToStr(Sent) + ' from ' + IntToStr(Length(Ansi)),
        mtInformation, [mbOK], 0);
  end;
end;

procedure TfmMain.IrDAServerListen(Sender: TObject);
begin
  lbEvents.Items.Add('Server listening');
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  IrDAServer.Close;
  IrDAServer.Free;
end;

procedure TfmMain.btGetBuffersClick(Sender: TObject);
var
  Client: TwclIrDAServerClientConnection;
  Res: Integer;
  Size: Cardinal;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Client := TwclIrDAServerClientConnection(lvClients.Selected.Data);

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
  Client: TwclIrDAServerClientConnection;
  Res: Integer;
  Size: Cardinal;
begin
  if lvClients.Selected = nil then
    MessageDlg('Select client', mtWarning, [mbOK], 0)

  else begin
    Client := TwclIrDAServerClientConnection(lvClients.Selected.Data);

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

procedure TfmMain.FormCreate(Sender: TObject);
begin
  IrDAServer := TwclIrDAServer.Create(nil);
  IrDAServer.OnConnect := IrDAServerConnect;
  IrDAServer.OnDisconnect := IrDAServerDisconnect;
  IrDAServer.OnData := IrDAServerData;
  IrDAServer.OnClosed := IrDAServerClosed;

  cbIasValueType.ItemIndex := 0;
end;

procedure TfmMain.btAddIasRecordClick(Sender: TObject);
var
  Res: Integer;
begin
  case cbIasValueType.ItemIndex of
    0: begin
         Res := IrDAServer.AddIasRecord('IrDAFramework', 'Integer value',
           1234567);
         if Res <> WCL_E_SUCCESS then
           lbEvents.Items.Add('Add IAS record error: 0x' + IntToHex(Res, 8));
       end;

    1: begin
         Res := IrDAServer.AddIasRecord('IrDAFramework', 'Octet Sequence',
           [$01, $02, $03, $04, $05, $06, $07, $08]);
         if Res <> WCL_E_SUCCESS then
           lbEvents.Items.Add('Add IAS record error: 0x' + IntToHex(Res, 8));
       end;

    2: begin
         Res := IrDAServer.AddIasRecord('IrDAFramework', 'User string',
           csAscii, [85, 115, 101, 114, 32, 115, 116, 114, 105, 110, 103]);
         if Res <> WCL_E_SUCCESS then
           lbEvents.Items.Add('Add IAS record error: 0x' + IntToHex(Res, 8));
       end;
  end;
end;

procedure TfmMain.IrDAServerConnect(Sender: TObject;
  const Client: TwclIrDAServerClientConnection; const Error: Integer);
var
  Item: TListItem;
begin
  lbEvents.Items.Add('Client connected: ' + IntToHex(Client.Address, 8) +
    ' error: 0x' + IntToHex(Error, 8));

  if Error = WCL_E_SUCCESS then begin
    Item := lvClients.Items.Add;
    Item.Caption := IntToHex(Client.Address, 8);
    Item.SubItems.Add(Client.Name);
    Item.Data := Client;
  end;
end;

procedure TfmMain.IrDAServerDisconnect(Sender: TObject;
  const Client: TwclIrDAServerClientConnection; const Reason: Integer);
var
  i: Integer;
begin
  lbEvents.Items.Add('Client disconnected: ' + IntToHex(Client.Address, 8) +
    ' reason: 0x' + IntToHex(Reason, 8));

  for i := 0 to lvClients.Items.Count - 1 do
    if lvClients.Items[i].Data = Client then begin
      lvClients.Items.Delete(i);
      Break;
    end;
end;

procedure TfmMain.IrDAServerData(Sender: TObject;
  const Client: TwclIrDAServerClientConnection; const Data: Pointer;
  const Size: Cardinal);
var
  Str: AnsiString;
begin
  if Size > 0 then begin
    Str := '';
    SetLength(Str, Size);
    CopyMemory(Pointer(Str), Data, Size);

    lbEvents.Items.Add('Received: ' + string(Str) + ' from ' +
      IntToHex(Client.Address, 8));
  end;
end;

procedure TfmMain.IrDAServerClosed(Sender: TObject;
  const Reason: Integer);
begin
  lbEvents.Items.Add('Server closed: 0x' + IntToHex(Reason, 8));

  lvClients.Clear;

  edReadBuffer.Text := '';
  edWriteBuffer.Text := '';
end;

end.
