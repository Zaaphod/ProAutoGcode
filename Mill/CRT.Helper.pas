Unit CRT.Helper;

{$Mode OBJFPC}

Interface

Uses
   CRT,
   Windows,
   SysUtils;

Const
   UseSystemCodePage = 0;
   DisableAnsiCodePage = -1;

Var
   ConsoleInfo: TConsoleScreenBufferInfo;

Function GetScreenHeight: DWord;
Function GetScreenWidth: DWord;
Function GetScreenWindowHeight: DWord;
Function GetScreenWindowWidth: DWord;
Procedure CrtCodePage(CCP: Integer);

Implementation

Function GetConsoleInfo(Const ErrorMsg: String): Boolean;
Begin
   If GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), ConsoleInfo) Then
      Begin
         Result := True;
      End
   Else
      Begin
         Writeln(stderr, ErrorMsg, ' failed. GetLastError: ', GetLastError);
         Try
            RaiseLastOSError;
         Except
            On E: Exception Do
               Writeln(stderr, E.Message);
         End;
         Result := False;
      End;
End;

Function GetScreenHeight: DWord;
Begin
   If GetConsoleInfo('GetScreenHeight') Then
      Result := ConsoleInfo.dwSize.Y
   Else
      Result := 0;
End;

Function GetScreenWidth: DWord;
Begin
   If GetConsoleInfo('GetScreenWidth') Then
      Result := ConsoleInfo.dwSize.X
   Else
      Result := 0;
End;

Function GetScreenWindowHeight: DWord;
Begin
   If GetConsoleInfo('GetScreenWindowHeight') Then
      Result := ConsoleInfo.srWindow.Bottom - ConsoleInfo.srWindow.Top + 1
   Else
      Result := 0;
End;

Function GetScreenWindowWidth: DWord;
Begin
   If GetConsoleInfo('GetScreenWindowWidth') Then
      Result := ConsoleInfo.srWindow.Right - ConsoleInfo.srWindow.Left + 1
   Else
      Result := 0;
End;

Procedure CrtCodePage(CCP: Integer);
Begin
   SetUseACP(False);
   Case CCP Of
      UseSystemCodePage: SetConsoleOutputCP(GetACP);
      DisableAnsiCodePage: ;
      Else SetConsoleOutputCP(CCP);
   End;
End;

Begin
   CrtCodePage(DisableAnsiCodePage);
   SetSafeCPSwitching(False);
End.
