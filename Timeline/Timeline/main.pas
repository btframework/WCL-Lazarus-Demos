unit main;

{$I wcl.inc}

interface

uses
  Forms, Classes, wclTimeline, Controls, StdCtrls;

type
  TfmMain = class(TForm)
    btRegisterProtocol: TButton;
    btUnregisterProtocol: TButton;
    laActivationProtocol: TLabel;
    edActivationProtocol: TEdit;
    laActivationProtocolDescription: TLabel;
    edActivationProtocolDescription: TEdit;
    btOpen: TButton;
    btClose: TButton;
    btCreateActivity: TButton;
    btDestroyActivity: TButton;
    laActivityId: TLabel;
    edActivityId: TEdit;
    laStateCaption: TLabel;
    laState: TLabel;
    laDisplayText: TLabel;
    edDisplayText: TEdit;
    laDescription: TLabel;
    edDescription: TEdit;
    laProtocolCaption: TLabel;
    laProtocol: TLabel;
    btBeginSession: TButton;
    btEndSession: TButton;
    laTitleCaption: TLabel;
    edTitleCaption: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btRegisterProtocolClick(Sender: TObject);
    procedure btUnregisterProtocolClick(Sender: TObject);
    procedure btOpenClick(Sender: TObject);
    procedure btCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btCreateActivityClick(Sender: TObject);
    procedure btBeginSessionClick(Sender: TObject);
    procedure btDestroyActivityClick(Sender: TObject);
    procedure btEndSessionClick(Sender: TObject);

  private
    wclTimelineChannel: TwclTimelineChannel;

    FActivity: TwclUserActivity;

    procedure DestroyActivity;
    procedure CheckParams;
  end;

var
  fmMain: TfmMain;

implementation

uses
  Dialogs, SysUtils, wclErrors;

{$R *.lfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  wclTimelineChannel := TwclTimelineChannel.Create(nil);

  edActivationProtocol.Text := 'uatest';
  edActivationProtocolDescription.Text := 'User Activity Test';
  edActivityId.Text := 'TestUserActivity';
  laState.Caption := '<No activity>';
  laProtocol.Caption := '<No activity>';

  edDisplayText.Text := 'Hello activities (Test)';
  edDescription.Text := 'Test User Activity';

  FActivity := nil;

  CheckParams;
end;

procedure TfmMain.btRegisterProtocolClick(Sender: TObject);
var
  Res: Integer;
begin
  if edActivationProtocol.Text = '' then
    ShowMessage('Activation protocol can not be an empty string')

  else begin
    if edActivationProtocolDescription.Text = '' then
      ShowMessage('Protocol description can not be an empty string')

    else begin
      Res := wclTimelineChannel.RegisterProtocol(edActivationProtocol.Text,
        edActivationProtocolDescription.Text);
      if Res <> WCL_E_SUCCESS then
        ShowMessage('Failed to register protocol: ' + IntToHex(Res, 8))
      else
        ShowMessage('Protocol registered');
    end;
  end;
end;

procedure TfmMain.btUnregisterProtocolClick(Sender: TObject);
var
  Res: Integer;
begin
  if edActivationProtocol.Text = '' then
    ShowMessage('Activation protocol can not be an empty string')

  else begin
    Res := wclTimelineChannel.UnregisterProtocol(edActivationProtocol.Text);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Failed to unregister protocol: ' + IntToHex(Res, 8))
    else
      ShowMessage('Protocol unregistered');
  end;
end;

procedure TfmMain.CheckParams;
var
  Str: string;
  p: Integer;
  Res: Integer;
begin
  // Check application params.
  if ParamCount > 0 then begin
    Str := ParamStr(1);
    // Make sure it is correct params.
    p := Pos(':', Str);
    if p > 0 then begin
      // Extract ActivityID.
      Str := Copy(Str, p + 1, Length(Str) - p);
      // Start activity with given ID.
      if Str <> '' then begin
        Res := wclTimelineChannel.Open;
        if Res = WCL_E_SUCCESS then begin
          Res := wclTimelineChannel.CreateActivity(Str, FActivity);
          if Res = WCL_E_SUCCESS then begin
            ShowMessage('Application started from Activity. Activity opened.');
            laState.Caption := 'Published';
            edActivityId.Text := Str;
            edDescription.Text := FActivity.Description;
            edDisplayText.Text := FActivity.DisplayText;
            laProtocol.Caption := FActivity.Protocol;
            edTitleCaption.Text := FActivity.Title;
          end else
            wclTimelineChannel.Close;
        end;
      end;
    end;
  end;
end;

procedure TfmMain.btOpenClick(Sender: TObject);
var
  Res: Integer;
begin
  Res := wclTimelineChannel.Open;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Open channel failed: 0x' + IntToHex(Res, 8))
  else
    ShowMessage('Channel opened.');
end;

procedure TfmMain.btCloseClick(Sender: TObject);
var
  Res: Integer;
begin
  DestroyActivity;

  Res := wclTimelineChannel.Close;
  if Res <> WCL_E_SUCCESS then
    ShowMessage('Close channel failed: 0x' + IntToHex(Res, 8))
  else
    ShowMessage('Channel closed.');
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  DestroyActivity;
  wclTimelineChannel.Close;
  wclTimelineChannel.Free;
end;

procedure TfmMain.btCreateActivityClick(Sender: TObject);
var
  Res: Integer;
begin
  if FActivity <> nil then
    ShowMessage('Activity has already been created')

  else begin
    Res := wclTimelineChannel.CreateActivity(edActivityId.Text, FActivity);
    if Res <> WCL_E_SUCCESS then
      ShowMessage('Create activity failed: 0x' + IntToHex(Res, 8))

    else begin
      ShowMessage('Activity has been created');

      case FActivity.State of
        asNew:
          begin
            laState.Caption := 'New';
            laProtocol.Caption := edActivationProtocol.Text;
          end;

        asPublished:
          begin
            laState.Caption := 'Published';
            edDescription.Text := FActivity.Description;
            edDisplayText.Text := FActivity.DisplayText;
            laProtocol.Caption := FActivity.Protocol;
            edTitleCaption.Text := FActivity.Title;
          end;
      end;
    end;
  end;
end;

procedure TfmMain.btBeginSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if FActivity = nil then
    ShowMessage('Activity has not been created')

  else begin
    if FActivity.Active then
      ShowMessage('Session is active')

    else begin
      FActivity.Protocol := edActivationProtocol.Text;
      // Add Activity ID as first parameter so we can open the
      // activity then. You can add additinal params if needed.
      FActivity.Params := FActivity.Id;
      FActivity.Description := edDescription.Text;
      FActivity.DisplayText := edDisplayText.Text;
      FActivity.Title := edTitleCaption.Text;

      Res := FActivity.BeginSession;
      if Res <> WCL_E_SUCCESS then
        ShowMessage('Begin session failed: 0x' + IntToHex(Res, 8))
      else
        ShowMessage('Session has been started');
    end;
  end;
end;

procedure TfmMain.btDestroyActivityClick(Sender: TObject);
begin
  if FActivity = nil then
    ShowMessage('Activity has not been created')

  else begin
    DestroyActivity;

    ShowMessage('Activity released');
  end;
end;

procedure TfmMain.btEndSessionClick(Sender: TObject);
var
  Res: Integer;
begin
  if FActivity = nil then
    ShowMessage('Activity has not been created')

  else begin
    Res := FActivity.EndSession;
    if Res <> WCL_E_SUCCESS then
      ShowMessage('End session failed: 0x' + IntToHex(Res, 8))
    else
      ShowMessage('Session has been stopped');
  end;
end;

procedure TfmMain.DestroyActivity;
begin
  if FActivity <> nil then begin
    FActivity.Free;
    FActivity := nil;

    laState.Caption := '<No activity>';
    laProtocol.Caption := '<No activity>';
  end;
end;

end.
