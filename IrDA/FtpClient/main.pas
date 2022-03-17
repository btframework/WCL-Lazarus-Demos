unit main;

{$I wcl.inc}

interface

uses
  Forms, Dialogs, wclIrDAClients, wclIrDADevices, ComCtrls, StdCtrls,
  Controls, Classes, wclConnections, wclObex;

type
  TfmMain = class(TForm)
    laNewDirName: TLabel;
    laDesc: TLabel;
    btDiscover: TButton;
    btConnect: TButton;
    btDisconnect: TButton;
    lvDevices: TListView;
    btOpenSession: TButton;
    btCloseSession: TButton;
    btClear: TButton;
    lbLog: TListBox;
    btSelectFile: TButton;
    edFileName: TEdit;
    btSendFile: TButton;
    btAbort: TButton;
    ProgressBar: TProgressBar;
    btMkDir: TButton;
    btDelete: TButton;
    edNewDirName: TEdit;
    btDir: TButton;
    lvFiles: TListView;
    btRoot: TButton;
    OpenDialog: TOpenDialog;
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
    procedure btDirClick(Sender: TObject);
    procedure lvFilesDblClick(Sender: TObject);
    procedure btRootClick(Sender: TObject);
    procedure btDeleteClick(Sender: TObject);
    procedure btMkDirClick(Sender: TObject);

  private
    wclIrDAReceiver: TwclIrDAReceiver;
    wclIrDAClient: TwclIrDAClient;

    FFtp: TwclObexFtpClient;

    procedure wclIrDAClientConnect(Sender: TObject; const Error: Integer);
    procedure wclIrDAClientDisconnect(Sender: TObject;
      const Reason: Integer);
    procedure wclIrDAClientDestroyProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);
    procedure wclIrDAClientCreateProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);

    procedure FtpConnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure FtpDisconnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure FtpPutComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
    procedure FtpProgress(Sender: TObject; const Size: Cardinal;
      const Position: Cardinal);
    procedure FtpGetComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
    procedure FtpDirComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Dirs: TwclObexFileObjects);
    procedure FtpChangeDirComplete(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure FtpDeleteComplete(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure FtpMkDirComplete(Sender: TObject; const Error: Integer;
      const Description: string);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, SysUtils;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclIrDAReceiver := TwclIrDAReceiver.Create(nil);

  wclIrDAClient := TwclIrDAClient.Create(nil);
  // We use ObjectPush Profile so must set the profile's UUID.
  wclIrDAClient.Service := 'OBEX';
  wclIrDAClient.Mode := cmIrComm3Wire; // Required for OBEX connection!
  wclIrDAClient.OnConnect := wclIrDAClientConnect;
  wclIrDAClient.OnCreateProcessor := wclIrDAClientCreateProcessor;
  wclIrDAClient.OnDestroyProcessor := wclIrDAClientDestroyProcessor;
  wclIrDAClient.OnDisconnect := wclIrDAClientDisconnect;

  FFtp := nil;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  wclIrDAClient.Disconnect;
  wclIrDAClient.Free;

  wclIrDAReceiver.Free;
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

procedure TfmMain.wclIrDAClientConnect(Sender: TObject;
  const Error: Integer);
begin
  lbLog.Items.Add('Connect. Operation result: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.wclIrDAClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  lbLog.Items.Add('Disconnected with reason: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.wclIrDAClientDestroyProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // Do we have any data processor created?
  if FFtp <> nil then begin
    // Make sure it is our connection is goind to destroy.
    if Connection.Processor = FFtp then begin
      // Ok, destroy the data processor here.
      FFtp.Free;
      FFtp := nil;
    end;
  end;
end;

procedure TfmMain.wclIrDAClientCreateProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // here we must create the data processor for the connection. In this demo
  // we use OPPClient.
  FFtp := TwclObexFtpClient.Create(Connection);
  FFtp.OnConnect := FtpConnect;
  FFtp.OnDisconnect := FtpDisconnect;
  FFtp.OnGetComplete := FtpGetComplete;
  FFtp.OnPutComplete := FtpPutComplete;
  FFtp.OnProgress := FtpProgress;
  FFtp.OnDirComplete := FtpDirComplete;
  FFtp.OnChangeDirComplete := FtpChangeDirComplete;
  FFtp.OnDeleteComplete := FtpDeleteComplete;
  FFtp.OnMakeDirComplete := FtpMkDirComplete;
end;

procedure TfmMain.btCloseSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FFtp.Disconnect('');
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Close session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
  end;
end;

procedure TfmMain.btOpenSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FFtp.Connect;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Open session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
  end;
end;

procedure TfmMain.FtpChangeDirComplete(Sender: TObject;
  const Error: Integer; const Description: string);
begin
  lbLog.Items.Add('Change dir completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  lvFiles.Items.Clear;
  FFtp.Dir;
end;

procedure TfmMain.FtpConnect(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('OBEX session opened with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);
end;

procedure TfmMain.FtpDeleteComplete(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('Delete completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  lvFiles.Items.Clear;
  FFtp.Dir;
end;

procedure TfmMain.FtpDirComplete(Sender: TObject; const Error: Integer;
  const Description: string; const Dirs: TwclObexFileObjects);
var
  i: Integer;
  Item: TListItem;
  Perm: string;
begin
  lbLog.Items.Add('Dir completed with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  for i := 0 to Length(Dirs) - 1 do begin
    Item := lvFiles.Items.Add;
    Item.Caption := Dirs[i].Name;
    if Dirs[i].IsDirectory then
      Item.SubItems.Add('Folder')
    else
      Item.SubItems.Add('File');
    Item.SubItems.Add(IntToStr(Dirs[i].Size));

    Perm := '';
    if opRead in Dirs[i].Permissions then
      Perm := Perm + 'R';
    if opWrite in Dirs[i].Permissions then
      Perm := Perm + 'W';
    if opDelete in Dirs[i].Permissions then
      Perm := Perm + 'D';
    Item.SubItems.Add(Perm);
    if Dirs[i].Modified <> 0 then
      Item.SubItems.Add(DateToStr(Dirs[i].Modified))
    else
      Item.SubItems.Add('');
    if Dirs[i].Created <> 0 then
      Item.SubItems.Add(DateToStr(Dirs[i].Created))
    else
      Item.SubItems.Add('');
    if Dirs[i].Accessed <> 0 then
      Item.SubItems.Add(DateToStr(Dirs[i].Accessed))
    else
      Item.SubItems.Add('');

    Item.SubItems.Add(Dirs[i].Description);
  end;
end;

procedure TfmMain.FtpDisconnect(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('OBEX session closed with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);
  lvFiles.Items.Clear;
end;

procedure TfmMain.FtpGetComplete(Sender: TObject; const Error: Integer;
  const Description: string; const Stream: TStream);
begin
  lbLog.Items.Add('File receiving completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  // We must destroy the stream object here.
  Stream.Free;
end;

procedure TfmMain.FtpMkDirComplete(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('Make dir completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  lvFiles.Items.Clear;
  FFtp.Dir;
end;

procedure TfmMain.FtpProgress(Sender: TObject; const Size,
  Position: Cardinal);
begin
  ProgressBar.Max := Size;
  ProgressBar.Position := Position;
end;

procedure TfmMain.FtpPutComplete(Sender: TObject; const Error: Integer;
  const Description: string; const Stream: TStream);
begin
  lbLog.Items.Add('File sending completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  // We must destroy the stream object here.
  Stream.Free;
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

procedure TfmMain.btAbortClick(Sender: TObject);
var
  Res: Integer;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FFtp.Abort('');
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Open session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btSendFileClick(Sender: TObject);
var
  Res: Integer;
  Stream: TStream;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    if edFileName.Text = '' then
      MessageDlg('Select file', mtWarning, [mbOK], 0)
    else begin
      Stream := TFileStream.Create(edFileName.Text, fmOpenRead);
      Res := FFtp.Put(ExtractFileName(edFileName.Text), '', Stream);
      if Res <> WCL_E_SUCCESS then begin
        MessageDlg('Send file failed: 0x' + IntToHex(Res, 8), mtError,
          [mbOK], 0);
        Stream.Free;
      end;
    end;
  end;
end;

procedure TfmMain.btDirClick(Sender: TObject);
var
  Res: Integer;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FFtp.Dir;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Dir failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
    else
      lvFiles.Items.Clear;
  end;
end;

procedure TfmMain.lvFilesDblClick(Sender: TObject);
var
  Res: Integer;
  Stream: TFileStream;
begin
  if lvFiles.Selected <> nil then begin
    if FFtp = nil then
      MessageDlg('Not connected', mtWarning, [mbOK], 0)

    else begin
      if lvFiles.Selected.SubItems[0] = 'Folder' then begin
        Res := FFtp.ChangeDir(lvFiles.Selected.Caption);
        if Res <> WCL_E_SUCCESS then begin
          MessageDlg('Change path failed 0x' + IntToHex(Res, 8),
            mtError, [mbOK], 0);
        end;

      end else begin
        Stream := TFileStream.Create('.\' + lvFiles.Selected.Caption,
           fmCreate);
        Res := FFtp.Get(lvFiles.Selected.Caption, Stream);
        if Res <> WCL_E_SUCCESS then begin
          MessageDlg('Get failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
          Stream.Free;
        end;
      end;
    end;
  end;
end;

procedure TfmMain.btRootClick(Sender: TObject);
var
  Res: Integer;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)

  else begin
    Res := FFtp.ChangeDir('');
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Root failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.btDeleteClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvFiles.Selected <> nil then begin
    if FFtp = nil then
      MessageDlg('Not connected', mtWarning, [mbOK], 0)

    else begin
      Res := FFtp.Delete(lvFiles.Selected.Caption);
      if Res <> WCL_E_SUCCESS then
        MessageDlg('Delete failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btMkDirClick(Sender: TObject);
var
  Res: Integer;
begin
  if FFtp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := FFtp.MkDir(edNewDirName.Text);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Make sire failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

end.
