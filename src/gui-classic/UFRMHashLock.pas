unit UFRMHashLock;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UWallet, Buttons, {$IFDEF FPC}LMessages,{$ENDIF}
  clipbrd, UConst, UGUIUtils, UBaseTypes;

type
  TFRMHashLock = class(TForm)
    btnCancel: TBitBtn;
    btnSet: TBitBtn;
    GroupBox1: TGroupBox;
    rbHashLock: TRadioButton;
    rbHashLockKey: TRadioButton;
    GroupBox2: TGroupBox;
    meHashLockData: TMemo;
    Label2: TLabel;
    lblError: TLabel;
    procedure btnSetClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FHashLock : T32Bytes;
    function GetError : String;
    procedure SetError(const AMsg : String);
  public
    { Public declarations }
    property Error : String read GetError write SetError;
    property HashLock : T32Bytes read FHashLock;
  end;


implementation

uses UCrypto, UAccounts;

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}


procedure TFRMHashLock.btnCancelClick(Sender: TObject);
begin
  Error := '';
end;

procedure TFRMHashLock.btnSetClick(Sender: TObject);
var
  LData : TRawBytes;
  LErr : string;
begin
  Try
  Error := '';
  if (NOT rbHashLock.Checked) AND (NOT rbHashLockKey.Checked) then begin
    Error := 'Select the hash-lock mode';
    Exit;
  end;

  if NOT TCrypto.IsHexString(meHashLockData.Text) then begin
    Error := 'Data is not hexadecimal format';
    Exit;
  end;

  LData := TCrypto.HexaToRaw(meHashLockData.Text);

  if (rbHashLock.Checked) then begin
    if Length(LData) <> 32 then begin
      Error := 'Hash-lock must be 32bytes';
      Exit;
    end;
    FHashLock := TBaseType.To32Bytes(LData);
  end else if (rbHashLockKey.Checked) then begin
    if NOT TAccountComp.IsValidHashLockKey(LData, LErr) then begin
      Error := LErr;
      Exit;
    end;
    FHashLock := TAccountComp.CalculateHashLock(LData);
  end else Error := 'INTERNAL ERROR: 8356DE573BA748618EDD6603B22D9EAD';
  Finally
    if Error='' then ModalResult := MrOk;
  end;
end;

procedure TFRMHashLock.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //
end;

procedure TFRMHashLock.FormCreate(Sender: TObject);
begin
  Error := '';
end;

function TFRMHashLock.GetError : String;
begin
  Result := lblError.Caption;
end;

procedure TFRMHashLock.SetError(const AMsg : String);
begin
  lblError.Caption := AMsg;
end;

end.
