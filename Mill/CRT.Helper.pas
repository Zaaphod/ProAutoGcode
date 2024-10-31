Unit CRT.Helper;
{$Mode FPC}

Interface
Uses CRT,Windows;
Function GetScreenHeight : DWord;
Function GetScreenWidth : DWord;
function GetScreenWindowHeight : DWord;
function GetScreenWindowWidth : DWord;
Procedure CrtCodePage (CCP:integer);

Implementation

Function GetScreenHeight : DWord;
var
  ConsoleInfo: TConsoleScreenBufferinfo;
Begin
  If (not GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo)) then Begin
{$ifdef SYSTEMDEBUG}
    Writeln(stderr,'GetScreenHeight failed GetLastError returns ',GetLastError);
    Halt(1);
{$endif SYSTEMDEBUG}
    // ts: this is really silly assumption; imho better: issue a halt
    GetScreenHeight:=25;
  End Else
    GetScreenHeight := ConsoleInfo.dwSize.Y;
End; { func. GetScreenHeight }

Function GetScreenWidth : DWord;
var
  ConsoleInfo: TConsoleScreenBufferInfo;
Begin
  If (not GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo)) then Begin
{$ifdef SYSTEMDEBUG}
    Writeln(stderr,'GetScreenWidth failed GetLastError returns ',GetLastError);
    Halt(1);
{$endif SYSTEMDEBUG}
    // ts: this is really silly assumption; imho better: issue a halt
    GetScreenWidth:=80;
  End Else
    GetScreenWidth := ConsoleInfo.dwSize.X;
End; { func. GetScreenWidth }

Function GetScreenWindowHeight : DWord;
var
  ConsoleInfo: TConsoleScreenBufferinfo;
Begin
  If (not GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo)) then Begin
{$ifdef SYSTEMDEBUG}
    Writeln(stderr,'GetScreenWindowHeight failed GetLastError returns ',GetLastError);
    Halt(1);
{$endif SYSTEMDEBUG}
    // ts: this is really silly assumption; imho better: issue a halt
    GetScreenWindowHeight:=25;
  End Else
    GetScreenWindowHeight := ConsoleInfo.srWindow.Bottom-ConsoleInfo.srWindow.Top+1;
End; { func. GetScreenWindowHeight }

Function GetScreenWindowWidth : DWord;
var
  ConsoleInfo: TConsoleScreenBufferInfo;
Begin
  If (not GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo)) then Begin
{$ifdef SYSTEMDEBUG}
    Writeln(stderr,'GetScreenWindowWidth failed GetLastError returns ',GetLastError);
    Halt(1);
{$endif SYSTEMDEBUG}
    // ts: this is really silly assumption; imho better: issue a halt
    GetScreenWindowWidth:=80;
  End Else
    GetScreenWindowWidth := ConsoleInfo.srWindow.Right-ConsoleInfo.srWindow.Left+1;
End; { func. GetScreenWindowWidth }

Procedure CrtCodePage (CCP:integer);
Begin
  If CCP = 0 then
      Begin
         SetUseACP(False);
         SetConsoleOutputCP(GetACP);
      End
  ELSE
    If CCP = -1 Then
      SetUseACP(False)
    ELSE
      Begin
         SetUseACP(False);
         SetConsoleOutputCP(CCP);
      End;
End;

Begin
   CrtCodePage(-1);
   SetSafeCPSwitching(False);
End.
