Program TestCRT;

{$Mode FPC}
Uses
  CRT.Helper,
  Windows,
  SysUtils;

Procedure TestScreenFunctions;
Begin
  Writeln('Screen Height: ', GetScreenHeight);
  Writeln('Screen Width: ', GetScreenWidth);
  Writeln('Screen Window Height: ', GetScreenWindowHeight);
  Writeln('Screen Window Width: ', GetScreenWindowWidth);
End;

Procedure ForceInvalidHandle;
Var
  OriginalHandle: THandle;
Begin
  Writeln('Forcing error with invalid handle:');
  OriginalHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  SetStdHandle(STD_OUTPUT_HANDLE, INVALID_HANDLE_VALUE);

  TestScreenFunctions;

  SetStdHandle(STD_OUTPUT_HANDLE, OriginalHandle);
End;

Procedure ForceFileHandle;
Var
  OriginalHandle, FileHandle: THandle;
Begin
  Writeln('Forcing error with file handle:');
  FileHandle := CreateFile('test.txt', GENERIC_WRITE, 0, Nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  OriginalHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  SetStdHandle(STD_OUTPUT_HANDLE, FileHandle);

  TestScreenFunctions;

  SetStdHandle(STD_OUTPUT_HANDLE, OriginalHandle);
  CloseHandle(FileHandle);
End;

Procedure DetachConsole;
Begin
  Writeln('Testing with detached console:');
  //FreeConsole;
  TestScreenFunctions;
End;

Begin
  Writeln('Testing Screen Functions under normal conditions:');
  TestScreenFunctions;
  Writeln('');
  DetachConsole;
  Writeln('');
  ForceFileHandle;
  Writeln('');
  ForceInvalidHandle;
End.
