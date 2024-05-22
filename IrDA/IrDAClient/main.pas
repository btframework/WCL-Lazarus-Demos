unit main;

{$MODE Delphi}

interface

uses
  Forms, StdCtrls, Controls, ComCtrls, Classes, wclIrDADevices,
  wclIrDAClients;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    lvDevices: TListView;
    btConnect: TButton;
    btDisconnect: TButton;
    lbEvents: TListBox;
    btClear: TButton;
    btSend: TButton;
    edText: TEdit;
    laTimeout: TLabel;
    edTimeout: TEdit;
    laMilliseconds: TLabel;
    laReadBuffer: TLabel;
    edReadBuffer: TEdit;
    laWriteBuffer: TLabel;
    edWriteBuffer: TEdit;
    btSetBuffers: TButton;
    procedure btDiscoverClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btSetBuffersClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    IrDAClient: TwclIrDAClient;
    IrDAReceiver: TwclIrDAReceiver;

    procedure IrDAClientConnect(Sender: TObject; const Error: Integer);
    procedure IrDAClientData(Sender: TObject; const Data: Pointer;
      const Size: Cardinal);
    procedure IrDAClientDisconnect(Sender: TObject;
      const Reason: Integer);
  end;

var
  fmMain: TfmMain;

implementation

uses
  wclErrors, Dialogs, SysUtils, Windows;

{$R *.lfm}

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Res: Integer;
  Devices: TwclIrDADevices;
  i: Integer;
  Item: TListItem;
begin
  lvDevices.Items.Clear;

  Res := IrDAReceiver.Discover(Devices);
  try
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)

    else
      if Length(Devices) = 0 then
        MessageDlg('No devices were found.', mtInformation, [mbOK], 0)

      else
        for i := 0 to Length(Devices) - 1 do begin
          Item := lvDevices.Items.Add;
          Item.Caption := IntToHex(Devices[i].Address, 8);
          Item.SubItems.Add(Devices[i].Name);
        end;

  finally
    Devices := nil;
  end;
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Clear;
end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAClient.Disconnect;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btConnectClick(Sender: TObject);
var
  Res: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    IrDAClient.Address := StrToInt('$' + lvDevices.Selected.Caption);
    IrDAClient.Timeout := StrToInt(edTimeout.Text);

    Res := IrDAClient.Connect;
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
  end;
end;

procedure TfmMain.btSendClick(Sender: TObject);
var
  Ansi: AnsiString;
  Res: Integer;
  Sent: Cardinal;
begin
  Ansi := AnsiString(edText.Text);
  Res := IrDAClient.Write(PByte(Ansi), Length(Ansi), Sent);
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)
  else
    MessageDlg('Sent: ' + IntToStr(Sent) + ' from ' + IntToStr(Length(Ansi)),
      mtInformation, [mbOK], 0);
end;

procedure TfmMain.IrDAClientConnect(Sender: TObject;
  const Error: Integer);
var
  Res: Integer;
  Size: Cardinal;
begin
  if Error = WCL_E_SUCCESS then begin
    lbEvents.Items.Add('Connected');

    // Try to get read and write buffers size.
    Size := 0;

    Res := IrDAClient.GetReadBufferSize(Size);
    if Res <> WCL_E_SUCCESS then
      lbEvents.Items.Add('Get read buffer error: 0x' + IntToHex(Res, 8))
    else
      edReadBuffer.Text := IntToStr(Size);

    Size := 0;
    Res := IrDAClient.GetWriteBufferSize(Size);
    if Res <> WCL_E_SUCCESS then
      lbEvents.Items.Add('Get write buffer error: 0x' + IntToHex(Res, 8))
    else
      edWriteBuffer.Text := IntToStr(Size);

  end else
    lbEvents.Items.Add('Connect error: 0x' + IntToHex(Error, 8));
end;

procedure TfmMain.IrDAClientData(Sender: TObject; const Data: Pointer;
  const Size: Cardinal);
var
  Str: AnsiString;
begin
  if Size > 0 then begin
    Str := '';
    SetLength(Str, Size);
    CopyMemory(Pointer(Str), Data, Size);

    lbEvents.Items.Add('Received: ' + string(Str));
  end;
end;

procedure TfmMain.IrDAClientDisconnect(Sender: TObject;
  const Reason: Integer);
begin
  lbEvents.Items.Add('Disconnected: 0x' + IntToHex(Reason, 8));

  edReadBuffer.Text := '0';
  edWriteBuffer.Text := '0';
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  IrDAClient.Disconnect;
  IrDAClient.Free;
  IrDAReceiver.Free;
end;

procedure TfmMain.btSetBuffersClick(Sender: TObject);
var
  Res: Integer;
  Size: Cardinal;
begin
  // Try to set read buffer size first.
  Size := StrToInt(edReadBuffer.Text);
  Res := IrDAClient.SetReadBufferSize(Size);
  if Res = WCL_E_SUCCESS then
    lbEvents.Items.Add('Read buffer size changed.')
  else
    lbEvents.Items.Add('Set read buffer size error: 0x' + IntToHex(Res, 8));

  // Now write buffer.
  Size := StrToInt(edWriteBuffer.Text);
  Res := IrDAClient.SetWriteBufferSize(Size);
  if Res = WCL_E_SUCCESS then
    lbEvents.Items.Add('Write buffer size changed.')
  else
    lbEvents.Items.Add('Set write buffer size error: 0x' + IntToHex(Res, 8));
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  IrDAReceiver := TwclIrDAReceiver.Create(nil);

  IrDAClient := TwclIrDAClient.Create(nil);
  IrDAClient.OnConnect := IrDAClientConnect;
  IrDAClient.OnData := IrDAClientData;
  IrDAClient.OnDisconnect := IrDAClientDisconnect;
end;

end.
