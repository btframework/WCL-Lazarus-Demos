unit main;

{$MODE Delphi}

interface

uses
  Forms, StdCtrls, Controls, ComCtrls, Classes, wclIrDADevices, wclPowerEvents;

type
  TfmMain = class(TForm)
    btDiscover: TButton;
    lvDevices: TListView;
    ntSubscribe: TButton;
    btUnsubscribe: TButton;
    lbEvents: TListBox;
    btClear: TButton;
    btQuery: TButton;
    laClassName: TLabel;
    cbClassName: TComboBox;
    laAttributeName: TLabel;
    cbAttributeName: TComboBox;
    btStartLazyDiscovering: TButton;
    btStopLazyDiscovering: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btDiscoverClick(Sender: TObject);
    procedure ntSubscribeClick(Sender: TObject);
    procedure btUnsubscribeClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
    procedure cbClassNameChange(Sender: TObject);
    procedure btQueryClick(Sender: TObject);
    procedure btStartLazyDiscoveringClick(Sender: TObject);
    procedure btStopLazyDiscoveringClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    IrDAReceiver: TwclIrDAReceiver;
    PowerMonitor: TwclPowerEventsMonitor;

    procedure IrDAReceiverChange(Sender: TObject);
    procedure IrDAReceiverDevicesFound(Sender: TObject;
      const Device: TwclIrDADevice);

    procedure PowerStateChanged(Sender: TObject; const State: TwclPowerState);
  end;

var
  fmMain: TfmMain;

implementation

uses
  Dialogs, SysUtils, wclErrors;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  IrDAReceiver := TwclIrDAReceiver.Create(nil);
  IrDAReceiver.OnChange := IrDAReceiverChange;
  IrDAReceiver.OnDevicesFound := IrDAReceiverDevicesFound;

  cbClassName.ItemIndex := 0;
  cbClassNameChange(cbClassName);

  PowerMonitor := TwclPowerEventsMonitor.Create;
  PowerMonitor.OnPowerStateChanged := PowerStateChanged;
  PowerMonitor.Open;
end;

procedure TfmMain.btDiscoverClick(Sender: TObject);
var
  Res: Integer;
  Devices: TwclIrDADevices;
  i: Integer;
  Device: TwclIrDADevice;
  Item: TListItem;
  Str: string;
  j: TwclIrDAHint;
begin
  lvDevices.Items.Clear;

  Res := IrDAReceiver.Discover(Devices);
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)

  else
    if Length(Devices) = 0 then
      MessageDlg('Nothing found', mtWarning, [mbOK], 0)

    else
      for i := 0 to Length(Devices) - 1 do begin
        Device := Devices[i];

        Item := lvDevices.Items.Add;
        Item.Caption := IntToHex(Device.Address, 8);
        Item.SubItems.Add(Device.Name);

        Str := '';
        for j := Low(TwclIrDAHint) to High(TwclIrDAHint) do
          if j in Device.Hints then
            case j of
              ihPnp: Str := Str + 'ihPnp ';
              ihPda: Str := Str + 'ihPda ';
              ihComputer: Str := Str + 'ihComputer ';
              ihPrinter: Str := Str + 'ihPrinter ';
              ihModem: Str := Str + 'ihModem ';
              ihFax: Str := Str + 'ihFax ';
              ihLan: Str := Str + 'ihLan ';
              ihTelephony: Str := Str + 'ihTelephony ';
              ihFileServer: Str := Str + 'ihFileServer ';
              ihComm: Str := Str + 'ihComm ';
              ihMessage: Str := Str + 'ihMessage ';
              ihHttp: Str := Str + 'ihHttp ';
              ihObex: Str := Str + 'ihObex ';
            else
              Str := Str + 'UNKNOWN ';
            end;
        Item.SubItems.Add(Str);

        case Device.CharSet of
          csAscii: Item.SubItems.Add('csAscii');
          csIso8859_1: Item.SubItems.Add('csIso8859_1');
          csIso8859_2: Item.SubItems.Add('csIso8859_2');
          csIso8859_3: Item.SubItems.Add('csIso8859_3');
          csIso8859_4: Item.SubItems.Add('csIso8859_4');
          csIso8859_5: Item.SubItems.Add('csIso8859_5');
          csIso8859_6: Item.SubItems.Add('csIso8859_6');
          csIso8859_7: Item.SubItems.Add('csIso8859_7');
          csIso8859_8: Item.SubItems.Add('csIso8859_8');
          csIso8859_9: Item.SubItems.Add('csIso8859_9');
          csUnicode: Item.SubItems.Add('csUnicode');
        else
          Item.SubItems.Add('UNKNOWN');
        end;
      end;
end;

procedure TfmMain.ntSubscribeClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAReceiver.Subscribe;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btUnsubscribeClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAReceiver.Unsubscribe;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btClearClick(Sender: TObject);
begin
  lbEvents.Items.Clear;
end;

procedure TfmMain.cbClassNameChange(Sender: TObject);
begin
  cbAttributeName.Items.Clear;

  case cbClassName.ItemIndex of
    0: begin
         cbAttributeName.Items.Add('DeviceName');
         cbAttributeName.Items.Add('IrLMPSupport');
       end;
    1: begin
         cbAttributeName.Items.Add('Parameters');
         cbAttributeName.Items.Add('IrDA:IrLMP:LsapSel');
         cbAttributeName.Items.Add('IrDA:TinyTP:LsapSel');
         cbAttributeName.Items.Add('IrDA:InstanceName');
       end;
    2: cbAttributeName.Items.Add('IrDA:TinyTP:LsapSel');
    3: cbAttributeName.Items.Add('IrDA:IrLMP:LsapSel');
    4: begin
         cbAttributeName.Items.Add('Integer value');
         cbAttributeName.Items.Add('Octet Sequence');
         cbAttributeName.Items.Add('User string');
       end;
  end;

  cbAttributeName.ItemIndex := 0;
end;

procedure TfmMain.btQueryClick(Sender: TObject);
var
  Res: Integer;
  Attrib: TwclIrDAAttribute;
  Str: string;
  i: Integer;
begin
  if lvDevices.Selected = nil then
    MessageDlg('Select device', mtWarning, [mbOK], 0)

  else begin
    Res := IrDAReceiver.QueryAttribute(
      StrToInt('$' + lvDevices.Selected.Caption),
      cbClassName.Items[cbClassName.ItemIndex],
      cbAttributeName.Items[cbAttributeName.ItemIndex], Attrib);
    if Res <> WCL_E_SUCCESS then
      MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0)

    else
      case Attrib.ValueType of
        atInteger:
          MessageDlg('Integer: ' + IntToStr(Attrib.IntegerValue),
            mtInformation, [mbOK], 0);

        atSequence:
          begin
            Str := '';
            if Attrib.SequenceValue <> nil then begin
              if Length(Attrib.SequenceValue) > 0 then
                for i := 0 to Length(Attrib.SequenceValue) - 1 do
                  Str := Str + IntToHex(Attrib.SequenceValue[i], 2);

              Attrib.SequenceValue := nil;
            end;

            MessageDlg('Sequence: ' + Str, mtInformation, [mbOK], 0);
          end;

        atString:
          MessageDlg('String: ' + Attrib.StringValue, mtInformation, [mbOK], 0);
      end;
  end;
end;

procedure TfmMain.btStartLazyDiscoveringClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAReceiver.StartLazyDiscovering;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.btStopLazyDiscoveringClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := IrDAReceiver.StopLazyDiscovering;
  if Res <> WCL_E_SUCCESS then
    MessageDlg('Error: 0x' + IntToHex(Res, 8), mtError, [mbOK], 0);
end;

procedure TfmMain.IrDAReceiverChange(Sender: TObject);
begin
  if IrDAReceiver.Available then
    lbEvents.Items.Add('Hardware changed. IrDA available.')
  else
    lbEvents.Items.Add('Hardware changed. IrDA NOT available.');
end;

procedure TfmMain.IrDAReceiverDevicesFound(Sender: TObject;
  const Device: TwclIrDADevice);
begin
  lbEvents.Items.Add('Device found: ' +
    IntToHex(Device.Address, 8) + '; ' + Device.Name);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  PowerMonitor.Close;
  PowerMonitor.Free;

  IrDAReceiver.StopLazyDiscovering;
  IrDAReceiver.Unsubscribe;
  IrDAReceiver.Free;
end;

procedure TfmMain.PowerStateChanged(Sender: TObject;
  const State: TwclPowerState);
begin
  case State of
    psResumeAutomatic:
      lbEvents.Items.Add('Power state: psResumeAutomatic');

    psResume:
      lbEvents.Items.Add('Power state: psResume');

    psSuspend:
      begin
        IrDAReceiver.StopLazyDiscovering;
        IrDAReceiver.Unsubscribe;

        lbEvents.Items.Add('Power state: psSuspend');
      end;

    psUnknown:
      lbEvents.Items.Add('Power state: psUnknown');
  end;
end;

end.
