unit main;

{$MODE Delphi}

interface

uses
  Forms, StdCtrls, Controls, ComCtrls, Dialogs, wclBluetooth, Classes,
  wclConnections, wclObex;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    OpenDialog: TOpenDialog;
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
    laNewDirName: TLabel;
    edNewDirName: TEdit;
    btDir: TButton;
    lvFiles: TListView;
    laDesc: TLabel;
    btRoot: TButton;
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
    BluetoothManager: TwclBluetoothManager;
    RfCommClient: TwclRfCommClient;
    Ftp: TwclObexFtpClient;

    function GetRadio: TwclBluetoothRadio;

    procedure FtpConnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure FtpDisconnect(Sender: TObject; const Error: Integer;
      const Description: string);
    procedure FtpPutComplete(Sender: TObject; const Error: Integer;
      const Description: string; const Stream: TStream);
    procedure FtpProgress(Sender: TObject; const Length: Cardinal;
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

    procedure BluetoothManagerAfterOpen(Sender: TObject);
    procedure BluetoothManagerAuthenticationCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Error: Integer);
    procedure BluetoothManagerDiscoveringCompleted(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Error: Integer);
    procedure BluetoothManagerDiscoveringStarted(Sender: TObject;
      const Radio: TwclBluetoothRadio);
    procedure BluetoothManagerNumericComparison(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Number: Cardinal; out Confirm: Boolean);
    procedure BluetoothManagerPasskeyNotification(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      const Passkey: Cardinal);
    procedure BluetoothManagerPasskeyRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Passkey: Cardinal);
    procedure BluetoothManagerPinRequest(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64;
      out Pin: String);
    procedure BluetoothManagerDeviceFound(Sender: TObject;
      const Radio: TwclBluetoothRadio; const Address: Int64);

    procedure RfCommClientDisconnect(Sender: TObject;
      const Reason: Integer);
    procedure RfCommClientConnect(Sender: TObject;
      const Error: Integer);
    procedure RfCommClientDestroyProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);
    procedure RfCommClientCreateProcessor(Sender: TObject;
      const Connection: TwclClientDataConnection);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclUUIDs, wclErrors, SysUtils;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
var
  Res: Integer;
begin
  BluetoothManager := TwclBluetoothManager.Create(nil);
  BluetoothManager.AfterOpen := BluetoothManagerAfterOpen;
  BluetoothManager.OnDiscoveringCompleted := BluetoothManagerDiscoveringCompleted;
  BluetoothManager.OnDiscoveringStarted := BluetoothManagerDiscoveringStarted;
  BluetoothManager.OnNumericComparison := BluetoothManagerNumericComparison;
  BluetoothManager.OnPasskeyNotification := BluetoothManagerPasskeyNotification;
  BluetoothManager.OnPasskeyRequest := BluetoothManagerPasskeyRequest;
  BluetoothManager.OnPinRequest := BluetoothManagerPinRequest;
  BluetoothManager.OnDeviceFound := BluetoothManagerDeviceFound;
  BluetoothManager.OnAuthenticationCompleted := BluetoothManagerAuthenticationCompleted;

  RfCommClient := TwclRfCommClient.Create(nil);
  RfCommClient.OnDisconnect := RfCommClientDisconnect;
  RfCommClient.OnConnect := RfCommClientConnect;
  RfCommClient.OnDestroyProcessor := RfCommClientDestroyProcessor;
  RfCommClient.OnCreateProcessor := RfCommClientCreateProcessor;

  // We use ObjectPush Profile so must set the profile's UUID.
  RfCommClient.Service := OBEXFileTransferServiceClass_UUID;

  Ftp := nil;

  // Try to open Bluetooth Manager.
  Res := BluetoothManager.Open;
  if Res <> WCL_E_SUCCESS then
    lbLog.Items.Add('Bluetooth Manager Open failed: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbLog.Clear;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  RfCommClient.Disconnect;
  RfCommClient.Free;

  BluetoothManager.Close;
  BluetoothManager.Free;
end;

procedure TfmMain.BluetoothManagerAfterOpen(Sender: TObject);
begin
  lbLog.Items.Add('Bluetooth Manager has been opened');
end;

procedure TfmMain.BluetoothManagerAuthenticationCompleted(
  Sender: TObject; const Radio: TwclBluetoothRadio; const Address: Int64;
  const Error: Integer);
begin
  lbLog.Items.Add('Authentication completed with result: 0x' +
    IntToHex(Error, 8));
end;

procedure TfmMain.BluetoothManagerDiscoveringCompleted(Sender: TObject;
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

procedure TfmMain.BluetoothManagerDiscoveringStarted(Sender: TObject;
  const Radio: TwclBluetoothRadio);
begin
  lbLog.Items.Add('Discovering started');

  lvDevices.Items.Clear;
end;

procedure TfmMain.BluetoothManagerNumericComparison(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Number: Cardinal; out Confirm: Boolean);
begin
  lbLog.Items.Add('Numeric comparison. Accept');
  Confirm := True;
end;

procedure TfmMain.BluetoothManagerPasskeyNotification(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  const Passkey: Cardinal);
begin
  lbLog.Items.Add('Passkey notification. Passkey: ' + IntToStr(Passkey));
end;

procedure TfmMain.BluetoothManagerPasskeyRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64;
  out Passkey: Cardinal);
begin
  lbLog.Items.Add('Passkey request. Passkey: 12345678');
  Passkey := 12345678;
end;

procedure TfmMain.BluetoothManagerPinRequest(Sender: TObject;
  const Radio: TwclBluetoothRadio; const Address: Int64; out Pin: String);
begin
  lbLog.Items.Add('PIN code request. PIN: 0000');
  Pin := '0000';
end;

procedure TfmMain.BluetoothManagerDeviceFound(Sender: TObject;
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
  Res := BluetoothManager.GetClassicRadio(Radio);
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
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Failed to start discovering: 0x' + IntToHex(Res, 8),
        mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := RfCommClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Disconnect failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.RfCommClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  lbLog.Items.Add('Disconnected with reason: 0x' + IntToHex(Reason, 8));
end;

procedure TfmMain.RfCommClientConnect(Sender: TObject;
  const Error: Integer);
begin
  lbLog.Items.Add('Connect. Operation result: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.RfCommClientDestroyProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // Do we have any data processor created?
  if Ftp <> nil then begin
    // Make sure it is our connection is goind to destroy.
    if Connection.Processor = Ftp then begin
      // Ok, destroy the data processor here.
      Ftp.Free;
      Ftp := nil;
    end;
  end;
end;

procedure TfmMain.RfCommClientCreateProcessor(Sender: TObject;
  const Connection: TwclClientDataConnection);
begin
  // here we must create the data processor for the connection. In this demo
  // we use OPPClient.
  Ftp := TwclObexFtpClient.Create(Connection);
  Ftp.OnConnect := FtpConnect;
  Ftp.OnDisconnect := FtpDisconnect;
  Ftp.OnGetComplete := FtpGetComplete;
  Ftp.OnPutComplete := FtpPutComplete;
  Ftp.OnProgress := FtpProgress;
  Ftp.OnDirComplete := FtpDirComplete;
  Ftp.OnChangeDirComplete := FtpChangeDirComplete;
  Ftp.OnDeleteComplete := FtpDeleteComplete;
  Ftp.OnMakeDirComplete := FtpMkDirComplete;
end;

procedure TfmMain.btCloseSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := Ftp.Disconnect('');
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Close session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btOpenSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)
  else begin
    Res := Ftp.Connect;
    if Res <> WCL_E_SUCCESS then begin
      MessageDlg('Open session failed: 0x' + IntToHex(Res, 8), mtError,
        [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.FtpConnect(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('OBEX session opened with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);
end;

procedure TfmMain.FtpDisconnect(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('OBEX session closed with result: 0x' + IntToHex(Error, 8) +
    '. Description: ' + Description);
  lvFiles.Items.Clear;
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Radio: TwclBluetoothRadio;
  Addr: Int64;
  Res: Integer;
begin
  if RfCommClient.State <> csDisconnected then
    MessageDlg('Client is connected', mtWarning, [mbOK], 0)

  else begin
    if lvDevices.Selected = nil then
      MessageDlg('Select device', mtWarning, [mbOK], 0)

    else begin
      Radio := GetRadio;
      if Radio <> nil then begin
        Addr := StrToInt64('$' + lvDevices.Selected.Caption);
        RfCommClient.Address := Addr;
        Res := RfCommClient.Connect(Radio);
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

procedure TfmMain.FtpProgress(Sender: TObject; const Length: Cardinal;
  const Position: Cardinal);
begin
  ProgressBar.Max := Length;
  ProgressBar.Position := Position;
end;

procedure TfmMain.btAbortClick(Sender: TObject);
var
  Res: Integer;
begin
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)

  else begin
    Res := Ftp.Abort('');
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
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)

  else begin
    if edFileName.Text = '' then
      MessageDlg('Select file', mtWarning, [mbOK], 0)

    else begin
      Stream := TFileStream.Create(edFileName.Text, fmOpenRead);
      Res := Ftp.Put(ExtractFileName(edFileName.Text), '', Stream);
      if Res <> WCL_E_SUCCESS then begin
        MessageDlg('Send file failed: 0x' + IntToHex(Res, 8), mtError,
          [mbOK], 0);
        Stream.Free;
      end;
    end;
  end;
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

procedure TfmMain.btDirClick(Sender: TObject);
var
  Res: Integer;
begin
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)

  else begin
    Res := Ftp.Dir;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Dir failed: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
    else
      lvFiles.Items.Clear;
  end;
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

procedure TfmMain.lvFilesDblClick(Sender: TObject);
var
  Res: Integer;
  Stream: TFileStream;
begin
  if lvFiles.Selected <> nil then begin
    if Ftp = nil then
      MessageDlg('Not connected', mtWarning, [mbOK], 0)

    else begin
      if lvFiles.Selected.SubItems[0] = 'Folder' then begin
        Res := Ftp.ChangeDir(lvFiles.Selected.Caption);
        if Res <> WCL_E_SUCCESS then begin
          MessageDlg('Change path failed 0x' + IntToHex(Res, 8),
            mtError, [mbOK], 0);
        end;

      end else begin
        Stream := TFileStream.Create('.\' + lvFiles.Selected.Caption,
           fmCreate);
        Res := Ftp.Get(lvFiles.Selected.Caption, Stream);
        if Res <> WCL_E_SUCCESS then begin
          MessageDlg('Get failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
          Stream.Free;
        end;
      end;
    end;
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
  Ftp.Dir;
end;

procedure TfmMain.btRootClick(Sender: TObject);
var
  Res: Integer;
begin
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)

  else begin
    Res := Ftp.ChangeDir('');
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Root failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.FtpDeleteComplete(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('Delete completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  lvFiles.Items.Clear;
  Ftp.Dir;
end;

procedure TfmMain.btDeleteClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvFiles.Selected <> nil then begin
    if Ftp = nil then
      MessageDlg('Not connected', mtWarning, [mbOK], 0)

    else begin
      Res := Ftp.Delete(lvFiles.Selected.Caption);
      if Res <> WCL_E_SUCCESS then
        MessageDlg('Delete failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfmMain.btMkDirClick(Sender: TObject);
var
  Res: Integer;
begin
  if Ftp = nil then
    MessageDlg('Not connected', mtWarning, [mbOK], 0)

  else begin
    Res := Ftp.MkDir(edNewDirName.Text);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Make sire failed 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
  end;
end;

procedure TfmMain.FtpMkDirComplete(Sender: TObject; const Error: Integer;
  const Description: string);
begin
  lbLog.Items.Add('Make dir completed with result: 0x' +
    IntToHex(Error, 8) + '. Description: ' + Description);

  ProgressBar.Position := 0;
  ProgressBar.Max := 0;

  lvFiles.Items.Clear;
  Ftp.Dir;
end;

end.
