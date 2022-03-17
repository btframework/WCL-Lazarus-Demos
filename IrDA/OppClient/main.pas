unit main;

{$I wcl.inc}

interface

uses
  Forms, Classes, Controls, ComCtrls, StdCtrls, wclConnections,
  wclObex, Dialogs, wclIrDAClients, wclIrDADevices;

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
    wclIrDAReceiver: TwclIrDAReceiver;
    wclIrDAClient: TwclIrDAClient;

    FOpp: TwclObexOppClient;

    procedure wclIrDAClientDisconnect(Sender: TObject;
      const Reason: Integer);
    procedure wclIrDAClientConnect(Sender: TObject; const Error: Integer);
    procedure wclIrDAClientDestroyProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);
    procedure wclIrDAClientCreateProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);

    procedure OppConnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure OppDisconnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure OppPutComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
    procedure OppProgress(Sender: TObject; const Size: Cardinal;
      const Position: Cardinal);
    procedure OppGetComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
  end;

var
  fmMain: TfmMain;

implementation

{$R *.lfm}

uses
  wclErrors, SysUtils, Windows;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclIrDAReceiver := TwclIrDAReceiver.Create(nil);

  wclIrDAClient := TwclIrDAClient.Create(nil);
  // We use ObjectPush Profile so must set the profile's UUID.
  wclIrDAClient.Service := 'OBEX';
  wclIrDAClient.Mode := cmIrComm3Wire; // Required for OBEX connection!
  wclIrDAClient.Service := 'IrDA:IrCOMM';
  wclIrDAClient.OnConnect := wclIrDAClientConnect;
  wclIrDAClient.OnCreateProcessor := wclIrDAClientCreateProcessor;
  wclIrDAClient.OnDestroyProcessor := wclIrDAClientDestroyProcessor;
  wclIrDAClient.OnDisconnect := wclIrDAClientDisconnect;

  FOpp := nil;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclIrDAReceiver.Free;

  wclIrDAClient.Disconnect;
  wclIrDAClient.Free;
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Res: Integer;
  Devices: TwclIrDADevices;
  i: Integer;
  Item: TListItem;
begin
  lvDevices.Clear;

  Res := wclIrDAReceiver.Discover(Devices);
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Failed to start discovering: 0x' + IntToHex(Res, 8),
      mtError, [mbOK], 0)
  else begin
    for i := 0 to Length(Devices) - 1 do begin
      Item := lvDevices.Items.Add;
      Item.Caption := IntToHex(Devices[i].Address, 8);
      Item.SubItems.Add(Devices[i].Name);
    end;
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclIrDAClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Disconnect failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
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
  Addr: Int64;
  Res: Integer;
begin
  if wclIrDAClient.State <> csDisconnected then
    MessageDlg('Client is connected', mtWarning, [mbOK], 0)

  else begin
    if lvDevices.Selected = nil then
      MessageDlg('Select device', mtWarning, [mbOK], 0)

    else begin
      Addr := StrToInt('$' + lvDevices.Selected.Caption);
      wclIrDAClient.Address := Addr;
      Res := wclIrDAClient.Connect;
      if Res <> WCL_E_SUCCESS then
        MessageDlg('Failed to connect: 0x' + IntToHex(Res, 8),
          mtError, [mbOK], 0);
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

procedure TfmMain.OppProgress(Sender: TObject; const Size: Cardinal;
  const Position: Cardinal);
begin
  ProgressBar.Max := Size;
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
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Open session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
  end;
end;

procedure TfmMain.btSendFileClick(Sender: TObject);
var
  Res: Integer;
  Stream: TStream;
begin
  if FOpp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else
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

procedure TfmMain.wclIrDAClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  lbLog.Items.Add('Disconnected with reason: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclIrDAClientConnect(Sender: TObject;
  const Error: Integer);
begin
  lbLog.Items.Add('Connect. Operation result: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.wclIrDAClientDestroyProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // Do we have any data processor created?
  if FOpp <> nil then
    // Make sure it is our connection is goind to destroy.
    if Connection.Processor = FOpp then begin
      // Ok, destroy the data processor here.
      FOpp.Free;
      FOpp := nil;
    end;
end;

procedure TfmMain.wclIrDAClientCreateProcessor(Sender: TObject;
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

end.
