unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons,
  Plotpanel, lNetComponents, RS232Port, lNet, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    PORT: TRS232Port;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Client: TRadioButton;
    Server: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    SaveDialog1: TSaveDialog;
    Shape1: TShape;
    Timer1: TTimer;
    UDP: TLUDPComponent;
    TCP: TLTCPComponent;
    PlotPanel1: TPlotPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure PORTReadingProcess(Sender: TObject; Status, NBytes: integer;
      Data: ShortString);
    procedure RadioButton1Change(Sender: TObject);
    procedure RadioButton2Change(Sender: TObject);
    procedure RadioButton3Change(Sender: TObject);
    procedure RadioButton4Change(Sender: TObject);
    procedure RadioButton5Change(Sender: TObject);
    procedure RadioButton6Change(Sender: TObject);
    procedure RadioButton7Change(Sender: TObject);
    procedure TCPAccept(aSocket: TLSocket);
    procedure TCPConnect(aSocket: TLSocket);
    procedure TCPDisconnect(aSocket: TLSocket);
    procedure TCPError(const msg: string; aSocket: TLSocket);
    procedure TCPReceive(aSocket: TLSocket);
    procedure UDPError(const msg: string; aSocket: TLSocket);
    procedure UDPReceive(aSocket: TLSocket);

  private
         FNet: TLConnection;
         FIsServer:Boolean;
         procedure SendToAll(const aMsg: string);
  public
     { public declarations }
  end;

var
  Form1: TForm1;
  Host_IP:string;
  Port_IP:integer;

implementation

uses
  lCommon;

{$R *.lfm}

{ TForm1 }


//button "Connect"
procedure TForm1.Button1Click(Sender: TObject);
begin
     Host_IP := Edit1.Text;
     Port_IP := StrToInt(Edit2.Text);
     FNet.Connect(Host_IP,Port_IP);
     if FNet.Connect(Host_IP,Port_IP) then FIsServer := false;
     if FNet.Connect(Host_IP,Port_IP) then Shape1.Brush.Color := clGreen else Shape1.Brush.Color := clRed;

end;
//button "Disconnect"
procedure TForm1.Button2Click(Sender: TObject);
begin
      FNet.Disconnect;
      Memo1.Append('Disconnected');
      Shape1.Brush.Color := clRed;
end;
// button "Save plot"
procedure TForm1.Button3Click(Sender: TObject);
var
  i:integer;

begin
     PlotPanel1.ClearData;
     Memo1.Clear;
	   for i:= 0 to 10 do
     begin
	   PlotPanel1.AddXY(i,i,clRed,1);
     PlotPanel1.AddXY(i,i*i,clBlue,2);
     Memo1.Lines.Add('x1='+inttostr(i)+' '+'y1='+inttostr(i)+' '+'x2='+inttostr(i)+' '+'y2='+inttostr(i*i));
     end;
end;
// button "Save memo"
procedure TForm1.Button4Click(Sender: TObject);
var
f:file;
begin
     AssignFile(f, Edit6.Text+datetostr(date)+'.txt');
     rewrite(f);
     Memo1.Lines.SaveToFile(Edit6.Text+datetostr(date)+timetostr(time)+'.txt');
end;
// button "Send"
procedure TForm1.Button5Click(Sender: TObject);
begin
      if Length(Edit5.Text) > 0 then
      begin
           if FIsServer then
                            begin
                                 SendToAll(Edit5.Text);
                                 Memo1.Append(Edit5.Text);
                            end else  FNet.SendMessage(Edit5.Text);

         Edit5.Text := '';
      end;
end;
// button "Serial port"
procedure TForm1.Button6Click(Sender: TObject);

begin
     PORT.Device := Edit6.Text;
     PORT.Open;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin

end;

procedure TForm1.PORTReadingProcess(Sender: TObject; Status, NBytes: integer;
  Data: ShortString);
var
   mess, data_x, data_y:string;
begin
     Memo1.Lines.Add(Data);
     mess := Data;
     data_x := copy(mess,pos('|x|',mess),7);
     data_x := copy(data_x,length(data_x)-3,4);
     data_y := copy(mess,pos('|y|',mess),7);
     data_y := copy(data_y,length(data_y)-3,4);
     PlotPanel1.AddXY(strtofloat(data_x),strtofloat(data_y),clRed,1);
     PlotPanel1.XMax := strtofloat(data_x) + 0.01;
     PlotPanel1.XMin := strtofloat(data_x) - 10;
end;

// tcp radio
procedure TForm1.RadioButton1Change(Sender: TObject);
begin
     FNet := TCP;
   //  TCP.SocketNet := LAF_INET;
end;
// udp radio
procedure TForm1.RadioButton2Change(Sender: TObject);
begin
     FNet := UDP;
end;
// serial port radio
procedure TForm1.RadioButton3Change(Sender: TObject);
begin

end;
// server radio
procedure TForm1.RadioButton4Change(Sender: TObject);
begin
     Memo1.Lines.Add('Server');
     Port_IP := StrToInt(Edit2.Text);
     if FNet.Listen(Port_IP) then
                          begin
                                Memo1.Append('Accepting connections');
                                FIsServer := True;
                          end;
end;
// client radio
procedure TForm1.RadioButton5Change(Sender: TObject);
begin
     Memo1.Lines.Add('Client');
     Host_IP := Edit1.Text;
     Port_IP := StrToInt(Edit2.Text);
end;
 // Speed serial port 9600
procedure TForm1.RadioButton6Change(Sender: TObject);
begin
     PORT.Close;
     PORT.BaudRate := br009600;
end;
  // Speed serial port 115200
procedure TForm1.RadioButton7Change(Sender: TObject);
begin
     PORT.Close;
     PORT.BaudRate := br115200;
end;

procedure TForm1.TCPAccept(aSocket: TLSocket);
begin
     Memo1.Append('Connection accepted');
     Memo1.SelStart := Length(Memo1.Lines.Text);
end;

procedure TForm1.TCPConnect(aSocket: TLSocket);
begin
     Memo1.Append('Connected to remote host');
end;

procedure TForm1.TCPDisconnect(aSocket: TLSocket);
begin
     Memo1.Append('Connection lost');
     Memo1.SelStart := Length(Memo1.Lines.Text);
end;

procedure TForm1.TCPError(const msg: string; aSocket: TLSocket);
begin
      Memo1.Append(msg);
      Memo1.SelStart := Length(Memo1.Lines.Text);
end;

procedure TForm1.TCPReceive(aSocket: TLSocket);
var
    s: string;
begin
      if aSocket.GetMessage(s) > 0 then
                                        begin
                                              Memo1.Append(s);
                                              Memo1.SelStart := Length(Memo1.Lines.Text);
                                              if FNet is TLUdp then
                                                                   begin // echo to sender if UDP
                                                                        if FIsServer then FNet.SendMessage(s);
                                                                   end else if FIsServer then SendToAll(s);// echo to all if TCP

                                        end;

end;

procedure TForm1.UDPError(const msg: string; aSocket: TLSocket);
begin
      Memo1.Append(msg);
      Memo1.SelStart := Length(Memo1.Lines.Text);
end;

procedure TForm1.UDPReceive(aSocket: TLSocket);
var
    s: string;
begin
   if aSocket.GetMessage(s) > 0 then
                                    begin
                                         Memo1.Append(s);
                                         Memo1.SelStart := Length(Memo1.Lines.Text);
                                    end;
end;

procedure TForm1.SendToAll(const aMsg: string);
var
  n: Integer;
begin
     if FNet is TLUdp then
                          begin // UDP, use broadcast
                                n := TLUdp(FNet).SendMessage(aMsg, LADDR_BR);
                                if n < Length(aMsg) then
                                 Memo1.Append('Error on send [' + IntToStr(n) + ']');
                          end else
                                  begin // TCP
                                       FNet.IterReset; // start at server socket
                                       while FNet.IterNext do
                                                             begin // skip server socket, go to clients only
                                                                   n := FNet.SendMessage(aMsg, FNet.Iterator);
                                                                   if n < Length(aMsg) then
                                                                                            Memo1.Append('Error on send [' + IntToStr(n) + ']');
                                                             end;
                                   end;
end;

 initialization
 ///{$I main.lrs}

end.

