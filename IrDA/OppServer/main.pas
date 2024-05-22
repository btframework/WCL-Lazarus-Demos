unit main;

{$MODE Delphi}

interface

uses
  Forms, Controls, StdCtrls, Classes, wclIrDAServers, wclConnections,
  Dialogs;

type
  TfmMain = class(TForm)
    btListen: TButton;
    btClose: TButton;
    btClear: TButton;
    lbLog: TListBox;
    SaveDialog: TSaveDialog;
    procedure btClearClick(Sender: TObject);
    procedure btListenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    IrDAServer: TwclIrDAServer;
    FFileName: string;

    procedure Trace(const Msg: string);

    procedure IrDAServerListen(Sender: TObject);
    procedure IrDAServerClosed(Sender: TObject; const Reason: Integer);
    procedure IrDAServerDisconnect(Sender: TObject;
      const Client: TwclIrDAServerClientConnection; const Reason: Integer);
    procedure IrDAServerDestroyProcessor(Sender: TObject;
      const Connection: TwclServerClientDataConnection);
    procedure IrDAServerConnect(Sender: TObject;
      const Client: TwclIrDAServerClientConnection; const Error: Integer);
    procedure IrDAServerCreateProcessor(Sender: TObject;
      const Connection: TwclServerClientDataConnection);

    procedure OppClientConnect(Sender: TObject; const Description: string);
    procedure OppClientDisconnected(Sender: TObject; const Reason: Integer;
      const Description: string);
    procedure OppClientPutBegin(Sender: TObject; const Name, Description,
      Mime: string; const Length: Cardinal; out Accept: Boolean);
    procedure OppClientPutCompleted(Sender: TObject; const Error: Integer;
      const Stream: TStream; out Accept: Boolean);
    procedure OppClientPutProgress(Sender: TObject; const Position,
      Length: Cardinal; out Continue: Boolean);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclIrDADevices, wclErrors, wclObex, SysUtils;

{$R *.lfm}

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.Trace(const Msg: string);
begin
  lbLog.Items.Add(Msg);
end;

procedure TfmMain.btListenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAServer.Listen;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Error: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAServer.Close;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Error: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  // Simple try to close the server.
  IrDAServer.Close;
  IrDAServer.Free;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  IrDAServer := TwclIrDAServer.Create(nil);
  IrDAServer.OnListen := IrDAServerListen;
  IrDAServer.OnClosed := IrDAServerClosed;
  IrDAServer.OnDisconnect := IrDAServerDisconnect;
  IrDAServer.OnDestroyProcessor := IrDAServerDestroyProcessor;
  IrDAServer.OnConnect := IrDAServerConnect;
  IrDAServer.OnCreateProcessor := IrDAServerCreateProcessor;
  
  IrDAServer.Service := 'OBEX';
  IrDAServer.Mode := cmIrComm3Wire; // Required for OBEX connection!
end;

procedure TfmMain.IrDAServerListen(Sender: TObject);
begin
  Trace('Server listening');
end;

procedure TfmMain.IrDAServerClosed(Sender: TObject;
  const Reason: Integer);
begin
  Trace('Server closed. Reason:: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.IrDAServerDisconnect(Sender: TObject;
  const Client: TwclIrDAServerClientConnection; const Reason: Integer);
begin
  Trace('Client ' + IntToHex(Client.Address, 8) + ' disconnected. Reason: 0x' +
    IntToHex(Reason, 8));
end;

procedure TfmMain.IrDAServerDestroyProcessor(Sender: TObject;
  const Connection: TwclServerClientDataConnection);
begin
  Trace('Data processor for client ' +
    IntToHex(TwclIrDAServerClientConnection(Connection).Address, 8) +
    ' is destroing');
  Connection.Processor.Free;
end;

procedure TfmMain.IrDAServerConnect(Sender: TObject;
  const Client: TwclIrDAServerClientConnection; const Error: Integer);
begin
  if Error = WCL_E_SUCCESS then
    Trace('Client ' + IntToHex(Client.Address, 8) + ' connected')

  else begin
    Trace('Client ' + IntToHex(Client.Address, 8) +
      ' connect failed: 0x' + IntToHex(Error, 8));
  end;
end;

procedure TfmMain.IrDAServerCreateProcessor(Sender: TObject;
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
end;

procedure TfmMain.OppClientConnect(Sender: TObject;
  const Description: string);
var
  Address: Cardinal;
  Proc: TwclObexOppServer;
  Accept: Boolean;
  Res: Integer;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclIrDAServerClientConnection(Proc.Connection).Address;
  Accept := MessageDlg('Client ' + IntToHex(Address, 8) +
    ' requsts for connection: ' + Description + '. Accept?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes;

  if Accept then
    Res := Proc.Accept('Accepted by user')
  else
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
  Address: Cardinal;
  Proc: TwclObexOppServer;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclIrDAServerClientConnection(Proc.Connection).Address;

  Trace('Client ' + IntToHex(Address, 8) +
    ' closed OBEX session with reason: 0x' + IntToHex(Reason, 8) +
    '. Description: ' + Description);
end;

procedure TfmMain.OppClientPutBegin(Sender: TObject; const Name,
  Description, Mime: string; const Length: Cardinal; out Accept: Boolean);
var
  Address: Cardinal;
  Proc: TwclObexOppServer;
  Str: string;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclIrDAServerClientConnection(Proc.Connection).Address;
  Str := 'Client ' + IntToHex(Address, 8) + ' send file ' + Name +
    '. Accept?';
  Accept := MessageDlg(Str, mtConfirmation, [mbYes, mbNo], 0) = mrYes;

  if Accept then
    FFileName := Name;
end;

procedure TfmMain.OppClientPutCompleted(Sender: TObject;
  const Error: Integer; const Stream: TStream; out Accept: Boolean);
var
  Address: Cardinal;
  Proc: TwclObexOppServer;
  Str: string;
begin
  Proc := TwclObexOppServer(Sender);
  Address := TwclIrDAServerClientConnection(Proc.Connection).Address;
  if Error = WCL_E_SUCCESS then begin
    Str := 'Client ' + IntToHex(Address, 8) + ' completed sent file. Accept?';
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

end.
