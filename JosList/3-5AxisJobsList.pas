Program JobsList;
Uses CRT,CRT.Helper,Classes,Sysutils,windows,commdlg,Math,Process;

Type
   XY_Record = Record
      X,Y : Extended;
   End;

Const
   RadianConvert=Pi/180;
   Radian45=pi/4;
   Radian90=pi/2;
   Radian180=pi;
   Radian270=(pi*3)/2;
   Radian360=pi*2;
   ConsoleTitle :Pchar    =  'Production Automation Console';
   Number_Of_Profiles = 27;
   Profile : Array [ 65..65+Number_Of_Profiles-1] of Ansistring = (
              '4mm  H80 Divinymat'  ,
              '1/4" G1SP'           ,
              '3/8" SC Core'        ,
              '3/8" DC Core'        ,
              '3/8" CK KC Core'     ,
              '1/2" SC Small Core'  ,
              '1/2" SC Large Core'  ,
              '1/2" RGD GP Core'    ,
              '1/2" DC High Density',
              '1/2" CK Core'        ,
              '1/2" StarBoard'      ,
              '5/8" CK KC NGL Core' ,
              '3/4" DC Core'        ,
              '3/4" CK Core'        ,
              '3/4" GPS Core'       ,
              '3/4" RGD GP Core'    ,
              '  1" GPS Core'       ,
              '  1" GPS Core - Lighter',
              '  1" Coosa'          ,
              '  1" RGD GP Core'    ,
              '  2" Coraform'       ,
              '  3" Coraform'       ,
              '3/4" Fiberglass'     ,
              '3/4" Fiberglass XL'  ,
              '3/4" Plywood'        ,
              '1-1/4" RGD P Core'   ,
              'Instruction'         );
   Pro_Load : Array [ 65..65+Number_Of_Profiles-1] of Ansistring = (
              '4mm H80 Divinymat'  ,
              '250 G1SP'           ,
              '375 SC Core'        ,
              '375 DC Core'        ,
              '375 CK KC Core'     ,
              '500 SC Small Core'  ,
              '500 SC Large Core'  ,
              '500 RGD GP Core'    ,
              '500 DC High Density',
              '500 CK Core'        ,
              '500 StarBoard'      ,
              '625 CK KC NGL Core' ,
              '750 DC Core'        ,
              '750 CK Core'        ,
              '750 GPS Core'       ,
              '750 RGD GP Core'    ,
              '1 GPS Core'         ,
              '1 GPS Core - Lighter',
              '1 Coosa'            ,
              '1 RGD GP CORE'      ,
              '2 Coraform'         ,
              '3 Coraform'         ,
              '750 Fiberglass'     ,
              '750 Fiberglass XL'  ,
              '750 Plywood'        ,
              '1250 RGD P Core'    ,
              'Instruction'        );
//   Pro_Thickness : Array [ 65..65+Number_Of_Profiles-1] of Ansistring = (
//              '4mm'   ,
//              '0.25"',
//              '0.375"',
//              '0.375"',
//              '0.375"',
//              '0.500"',
//              '0.500"',
//              '0.500"',
//              '0.500"',
//              '0.625"',
//              '0.750"',
//              '0.750"',
//              '0.750"',
//              '0.750"',
//              '1"'    ,
//              '2"'    ,
//              '3"'    ,
//              '0.750"',
//              '0.750"',
//              '0.750"');
//              '1.250"');

Var
   Console_HWND        : HWND;
   Console_HMENU       : hmenu;
   ProgProcess         : TProcess;
   TapFileIn           : tstrings;
   TapFilelist         : tstrings;
   TapFileJobsList     : tstrings;
   TapFileToolList     : tstrings;
   ToolDescriptions    : tstrings;
   SaveAsFileName      : TOpenFileNameA;
   SaveAsFileNameBuffer: array[0..Max_Path+1] of char;
   TapFile             : Text;

   Toollistused        : Boolean = False ;
   TapFileHeaderActive : Boolean = False ;
   Errorfound          : Boolean = False ;
   Subroutines         : Boolean = False ;
   Tools               : Boolean = False ;
   SaveAsResult        : Boolean = False ;
   FileOKtoSave        : Boolean = False ;
   Autosave            : Boolean = False ;
   AutoReplace         : Boolean = False ;
   IJRelative          : Boolean = False ;
   RunProMill          : Boolean = False ;
   JobLine             : Boolean = False ;
   NoJObs              : Boolean = False ;
   JObSectionFound     : Boolean = False ;
   ToolSectionFound    : Boolean = False ;
   EndFound            : Boolean = False ;
   CCDFound            : Boolean = False ;
   ScriptFound         : QWord = 0;
   Custom_Variables_Not_Found : QWord = 0;
   SHE_Error           : Boolean = False ;
   J_Error             : Boolean = False ;
   x_dec               : Boolean = False ;
   y_dec               : Boolean = False ;
   i_dec               : Boolean = False ;
   j_dec               : Boolean = False ;
   z_dec               : Boolean = False ;
   a_dec               : Boolean = False ;
   c_dec               : Boolean = False ;
   s_dec               : Boolean = False ;
   Use_S               : Boolean = False ;
   NoCheck             : Boolean = False ;
   SkipNextC           : Boolean = False ;
   FixG0C              : Boolean = False ;
   C2B                 : Boolean = False ;
   C2BAll              : Boolean = False ;
   FixG0InLine         : Boolean = False ;
   FixG1InLine         : Boolean = False ;
   FixG0ZInLine        : Boolean = False ;
   FixG1ZInLine        : Boolean = False ;
   DeleteRemovedLines  : Boolean = False ;
   StringCount         : LongInt ;
   I,J,Toolnum         : LongInt ;
   OutCount            : LongInt = 0     ;
   ToolNumber          : LongInt = 0     ;
   Subroutine_Position : LongInt = 0     ;
   ScoutFoam_Position  : LongInt = 0     ;
   ToolList_Position   : LongInt = 0     ;
   Outount             : LongInt = 0     ;
   ToolCount           : LongInt = 0     ;
   originallinenum     : LongInt = 0     ;
   ErrorCount          : LongInt = 0     ;
   JobErrorCount       : LongInt = 0     ;
   Derrorcount         : LongInt = 0     ;
   JobCount            : LongInt = 0     ;
   JobErrorLineNumber  : LongInt = 0     ;
   Derrorlinenum       : LongInt = 0     ;
   NullG1              : LongInt = 0     ;
   XNum                : Extended  = 0     ;
   YNum                : Extended  = 0     ;
   ZNum                : Extended  = 0     ;
   ANum                : Extended  = 0     ;
   CNum                : Extended  = 0     ;
   SNum                : Extended  = 0     ;
   Line_Segment_Error  : Extended  = 0.0005;
   Replace_G0_Previous_By_Angle       : Boolean = False ;
   Replace_G1_Previous_By_Angle       : Boolean = False ;
   Replace_G0_Previous_By_Distance    : Boolean = False ;
   Replace_G1_Previous_By_Distance    : Boolean = False ;
   Replace_G0_Z_Previous_By_Direction : Boolean = False ;
   Replace_G1_Z_Previous_By_Direction : Boolean = False ;
   ForceG1XY                          : Boolean = False ;
   G0_XY_Angle         : Extended  = NaN   ;
   G1_XY_Angle         : Extended  = NaN   ;
   G0_Z_Direction      : Extended  = NaN   ;
   G1_Z_Direction      : Extended  = NaN   ;
   Prev_G1_XY_Angle    : Extended  = NaN   ;
   Prev_G0_XY_Angle    : Extended  = NaN   ;
   Prev_G0_Z_Direction : Extended  = NaN   ;
   Prev_G1_Z_Direction : Extended  = NaN   ;
   XMin                : Extended  = NaN   ;
   YMin                : Extended  = NaN   ;
   ZMin                : Extended  = NaN   ;
   AMin                : Extended  = NaN   ;
   CMin                : Extended  = NaN   ;
   SMin                : Extended  = NaN   ;
   XMax                : Extended  = NaN   ;
   YMax                : Extended  = NaN   ;
   ZMax                : Extended  = NaN   ;
   AMax                : Extended  = NaN   ;
   CMax                : Extended  = NaN   ;
   SMax                : Extended  = NaN   ;
   X_Limit_Neg         : Extended  = -10     ;
   Y_Limit_Neg         : Extended  = -10     ;
   Z_Limit_Neg         : Extended  = -1    ;
   A_Limit_Neg         : Extended  = NaN   ;
   C_Limit_Neg         : Extended  = NaN   ;
   S_Limit_Neg         : Extended  = 0     ;
   X_Limit_Pos         : Extended  = 62    ;
   Y_Limit_Pos         : Extended  = 120   ;
   Z_Limit_Pos         : Extended  = 6     ;
   A_Limit_Pos         : Extended  = NaN   ;
   C_Limit_Pos         : Extended  = NaN   ;
   S_Limit_POS         : Extended  = 255   ;
   X_Part_Offset       : Extended  = 0     ;
   Y_Part_Offset       : Extended  = 0     ;
   Z_Part_Offset       : Extended  = 0     ;
   error               : Word    = 0     ;
   MessageBoxResult    : Word    = 0     ;
   Loopcount           : Word;
   Gc                  : integer = 0     ;
   Qx                  : Extended  = NaN   ;
   FromX               : Extended  = NaN   ;
   Px                  : Extended  = NaN   ;
   Rx                  : Extended  = NaN   ;
   Gx                  : Extended  = NaN   ;
   Qy                  : Extended  = NaN   ;
   FromY               : Extended  = NaN   ;
   Py                  : Extended  = NaN   ;
   Ry                  : Extended  = NaN   ;
   Gy                  : Extended  = NaN   ;
   Oz                  : Extended  = NaN   ;
   Pz                  : Extended  = NaN   ;
   Rz                  : Extended  = NaN   ;
   Gi                  : Extended  = NaN   ;
   Gj                  : Extended  = NaN   ;
   Rs                  : Extended  = NaN   ;
   Gs                  : Extended  = NaN   ;
   Sa                  : Extended  = NaN   ;
   Ea                  : Extended  = NaN   ;
   R                   : Extended  = NaN   ;
   Arc_X_Min           : Extended  = NaN   ;
   Arc_X_Max           : Extended  = NaN   ;
   Arc_Y_Min           : Extended  = NaN   ;
   Arc_Y_Max           : Extended  = NaN   ;
   ToolPrefix          : AnsiString = '' ;
   ToolDescription     : AnsiString = '' ;
   Machine             : AnsiString = '' ;
   TapFileName         : AnsiString = '' ;
   TapFileData         : AnsiString = '' ;
   TapFileDataNext     : AnsiString = '' ;
   NewTapFileData      : AnsiString = '' ;
   OutputTapFileName   : AnsiString = '' ;
   Xstring             : AnsiString = '' ;
   Ystring             : AnsiString = '' ;
   Zstring             : AnsiString = '' ;
   Astring             : AnsiString = '' ;
   Cstring             : AnsiString = '' ;
   Sstring             : AnsiString = '' ;
   IString             : AnsiString = '' ;
   JString             : AnsiString = '' ;
   TempString          : AnsiString = '' ;
   JobErrorLine        : AnsiString = '' ;
   Derrorline          : AnsiString = '' ;
   Error_String        : AnsiString = '' ;
   Previous_X          : AnsiString = '' ;
   Previous_Y          : AnsiString = '' ;
   Previous_Z          : AnsiString = '' ;
   Current_X           : AnsiString = '' ;
   Current_Y           : AnsiString = '' ;
   Current_Z           : AnsiString = '' ;
   Old_Previous_X      : AnsiString = '' ;
   Old_Previous_Y      : AnsiString = '' ;
   Old_Previous_Z      : AnsiString = '' ;
   Previous_S          : AnsiString = '' ;
   NewToolLine         : AnsiString = '' ;
   Menu_Selection      : Char = #255;
   N                   : Byte;
   TapFileLineNumber   : DWord;
   Replace_G1_Previous_By_Angle_Count       : Qword = 0;
   Replace_G0_Previous_By_Angle_Count       : Qword = 0;
   Replace_G1_Previous_By_Distance_Count    : Qword = 0;
   Replace_G0_Previous_By_Distance_Count    : Qword = 0;
   Replace_G0_Z_Previous_By_Direction_Count : Qword = 0;
   Replace_G1_Z_Previous_By_Direction_Count : Qword = 0;
   LengthPerp          : Extended = NaN;
   LargestLengthPerp   : Extended = NaN;
   SmallestLengthPerp  : Extended = NaN;
   PerpenX             : Extended = NaN;
   PerpenY             : Extended = NaN;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function OutString(OS:Double):AnsiString;
Var
   Stringtemp      :AnsiString;
   Strngposition   : Integer;
Begin
   STR(OS:0:6,Stringtemp);
   For Strngposition := Length(Stringtemp) DownTo 1 Do
      Begin
         If Stringtemp[Strngposition]='0' Then
            Stringtemp:=copy(Stringtemp,1,Strngposition-1)
         Else
            break;
      End;
   If Stringtemp[Strngposition]='.' Then
      Stringtemp:=copy(Stringtemp,1,Strngposition-1);
   OutString:= Stringtemp;
End;

{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function Value(VS:AnsiString):Extended;
Var
   Errv       : Integer;
   VOUT       : Extended;
   VIN,VS_In  :AnsiString;
Begin
   Value:=0;
   If VS<>'' Then
      Begin
         If (VS[Length(VS)]<'0') or (VS[Length(VS)]>'9') Then
            VS_in:=Copy(VS,1,Length(VS)-1)
         Else
            VS_in:=Vs;
         Val(VS_In,VOUT,errv);
         //Writeln('Value ',VS,'   ',VS_In,'  ',VOUT:0:3,'  ',errv);
         If errv=0 then
            Begin
               If VOUT = -0 then VOUT :=0;
               Value:=VOUT;
            End
         Else
            Begin
               If errv>1 Then
                  Begin
                     VIN:=Copy(VS_In,1,errv-1);
                     Val(VIN,VOUT,errv);
                     //Writeln('Value 2 ',VIN,'  ',VOUT:0:3,'  ',errv);
                     If errv=0 then
                        Begin
                           If VOUT = -0 then VOUT :=0;
                           Value:=VOUT;
                        End
                  End;
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function FindHighestONumber(Pathtosearch:AnsiString):AnsiString;
Var
   Filedirinfo      : Tsearchrec;
   HighestONumber   : AnsiString;
   ONum,HighestONum : Integer;
Begin
HighestONumber:='0000';
ONum := -1;
HIghestONum:=0;
//Writeln(Pathtosearch+'O*.*');
If Sysutils.FindFirst(Pathtosearch+'O*.*', FAAnyfile, FileDirInfo)=0 Then
   Begin
      Repeat
         If (FileDirinfo.Attr AND FADirectory <> FADirectory) AND (Filedirinfo.name<>'') Then
            Begin
               //WriteLn(filedirinfo.name);
               val(Copy(filedirinfo.name,2,length(filedirinfo.name)-1),Onum,error);
               If ONum>HighestONum then
                  HighestONum:=Onum;
               //Writeln (ONum,'  ',HighestONum);
            End;
      Until Sysutils.FindNext(FileDirInfo)<>0;
      {DEC(GF);}
   End;
   Sysutils.FindClose(filedirinfo);
   HighestOnumber:='O';
   For i:=1 to 4-length(inttostr(HighestOnum+1)) do
      Begin
         HighestONumber:=HighestONumber+'0';
      End;
   HighestONumber:=HighestOnumber+inttostr(HighestOnum+1);
   //Writeln(HighestONumber);
   FindHighestONumber:=highestONumber;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
// S:AnsiString to center, Outerlength: Maximum number of chars per line
function CenteredText(const S:AnsiString;Outerlength:integer):AnsiString;
var
  t,u: DWord;
  R:AnsiString;
begin
  If Length(s)<=Outerlength then
     Begin
         t := (Outerlength - Length(s)) div 2;
         u := Outerlength - (T+Length(S));
         R := Format('%*s%s%*s', [t, ' ', s, u, ' ']) ;
         If Length(R) > Outerlength then // sanity check
         begin
               R := S;
               SetLength(R,Outerlength); //truncates
         end;
      End
   Else
      R:= S;
   CenteredText:=R;
end;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure ReportErrors;
Begin
   TextColor(LightRed);
   If JobErrorCount=1 then
      Writeln('1 Errors Found')
   Else
      Writeln(JobErrorCount,' Errors Found');
   TextColor(White);
   Write('First Error Line#: ');
   TextColor(Yellow);
   Write(JobErrorlinenumber,': ');
   TextColor(LightCyan);
   Writeln(JobErrorLine);
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Function RadianAngle(CADX,CADY:Double):Double;
Var
  Ca:Double;
Begin
   CA := Arctan2(cady,cadx);
   If CA < 0 Then
      CA := CA + Radian360;
   RadianAngle:=CA;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Procedure Arc_Min_Max;
Begin
   Gx:=Xnum;
   Gy:=Ynum;
   Sa:=RadianAngle(px-gi,py-gj);
   Ea:=RadianAngle(gx-gi,gy-gj);
   R:=Hypot((gx-gi),(gy-gj));
   //Writeln('Gc',Gc,' Px',Px:0:4,' Py',Py:0:4,'Gx',Gx:0:4,' Gy',Gy:0:4,'Gi',Gi:0:4,' Gj',Gj:0:4,'Sa',Sa:0:4,' Ea',Ea:0:4,' R',R:0:4);
   if Px<Gx then
      Begin
       Arc_X_Min:=px;
       Arc_X_Max:=gx;
      end
   Else
      Begin
       Arc_X_Min:=gx;
       Arc_X_Max:=px;
      end;
   if Py<Gy then
      Begin
       Arc_Y_Min:=py;
       Arc_Y_Max:=gy;
      end
   Else
      Begin
       Arc_Y_Min:=gy;
       Arc_Y_Max:=py;
      end;

   If sa=ea then
      Begin
         Arc_X_Max:=gi+r;
         Arc_Y_Max:=gj+r;
         Arc_X_Min:=gi-r;
         Arc_Y_Min:=gj-r;
      End;
   If (Sa>=0) and (Sa<=Radian90) Then // start quadrant 1
      Begin
         If (Ea>=0) and (Ea<=Radian90) Then // end quadrant 1
            Begin
               If ((Gc=3) and (Sa>Ea)) or ((Gc=2) and (Sa<Ea))  Then
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End;
             End
         Else
         If (Ea>Radian90) and (Ea<=Radian180) Then // end quadrant 2
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_Y_Max:=Gj+R;
                  End
               Else
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End;
            End
         Else
         If (Ea>Radian180) and (Ea<=Radian270) Then // end quadrant 3
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                  End
               Else
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Min:=Gj-R;
                  End;
            End
         Else
         If (Ea>Radian270) and (Ea<=Radian360) Then // end quadrant 4
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End
               Else
                  Begin
                     Arc_X_Max:=Gi+R;
                  End;
            End;
      End
   Else
   If (Sa>Radian90) and (Sa<=Radian180) Then // quadrant 2
      Begin
         If (Ea>Radian90) and (Ea<=Radian180) Then // end quadrant 2
            Begin
               If ((Gc=3) and (Sa>Ea)) or ((Gc=2) and (Sa<Ea))  Then
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End;
             End
         Else
         If (Ea>Radian180) and (Ea<=Radian270) Then // end quadrant 3
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_X_Min:=Gi-R;
                  End
               Else
                  Begin
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Min:=Gj-R;
                  End;
            End
         Else
         If (Ea>Radian270) and (Ea<=Radian360) Then // end quadrant 4
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End
               Else
                  Begin
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Max:=Gi+R;
                  End;
            End
         Else
         If (Ea>=0) and (Ea<=Radian90) Then // end quadrant 1
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                     Arc_X_Max:=Gi+R;
                  End
               Else
                  Begin
                     Arc_Y_Max:=Gj+R;
                  End;
            End;
      End
   Else
   If (Sa>Radian180) and (Sa<=Radian270) Then // quadrant 3
      Begin
         If (Ea>Radian180) and (Ea<=Radian270) Then // end quadrant 3
            Begin
               If ((Gc=3) and (Sa>Ea)) or ((Gc=2) and (Sa<Ea))  Then
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End;
             End
         Else
         If (Ea>Radian270) and (Ea<=Radian360) Then // end quadrant 4
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_Y_Min:=Gj-R;
                  End
               Else
                  Begin
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Max:=Gi+R;
                  End;
            End
         Else
         If (Ea>=0) and (Ea<=Radian90) Then // end quadrant 1
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_Y_Min:=Gj-R;
                     Arc_X_Max:=Gi+R;
                  End
               Else
                  Begin
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Max:=Gj+R;
                  End;
            End
         Else
         If (Ea>Radian90) and (Ea<=Radian180) Then // end quadrant 2
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_Y_Min:=Gj-R;
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                  End
               Else
                  Begin
                     Arc_X_Min:=Gi-R;
                  End;
            End;
      End
   Else
   If (Sa>Radian270) and (Sa<=Radian360) Then // quadrant 4
      Begin
         If (Ea>Radian270) and (Ea<=Radian360) Then // end quadrant 4
            Begin
               If ((Gc=3) and (Sa>Ea)) or ((Gc=2) and (Sa<Ea))  Then
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Min:=Gj-R;
                  End;
             End
         Else
         If (Ea>=0) and (Ea<=Radian90) Then // end quadrant 1
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_X_Max:=Gi+R;
                  End
               Else
                  Begin
                     Arc_Y_Min:=Gj-R;
                     Arc_X_Min:=Gi-R;
                     Arc_Y_Max:=Gj+R;
                  End;
            End
         Else
         If (Ea>Radian90) and (Ea<=Radian180) Then // end quadrant 2
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                  End
               Else
                  Begin
                     Arc_Y_Min:=Gj-R;
                     Arc_X_Min:=Gi-R;
                  End;
            End
         Else
         If (Ea>Radian180) and (Ea<=Radian270) Then // end quadrant 3
            Begin
               If (Gc=3) Then
                  Begin
                     Arc_X_Max:=Gi+R;
                     Arc_Y_Max:=Gj+R;
                     Arc_X_Min:=Gi-R;
                  End
               Else
                  Begin
                     Arc_Y_Min:=Gj-R;
                  End;
            End;
      End;
End;
{=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=+=-=}
Begin
   SetConsoleTitle(ConsoleTitle);
   Console_HWND :=FindWindow(nil,ConsoleTitle);
   Console_hmenu := GetSystemMenu(Console_HWND, FALSE);
   EnableMenuItem(Console_hmenu, SC_CLOSE, MF_ENABLED);
   SetExceptionMask(GetExceptionMask + [exInvalidOp]);

   If ParamStr(1)<>'' Then
      Begin
         For LoopCount:=1 to Paramcount Do
            Begin
               If (Pos('?',Paramstr(LoopCount))>=1) or (Pos('HELP',Paramstr(LoopCount))>=1)  Then
                  Begin
                     TextColor(LightGreen);
                     Writeln ('Help:');
                     TextColor(LightCyan);
                     Writeln ('3-5AxisJobslist Inputfilename.tap');
                     TextColor(Yellow);
                     Writeln ('      Always asks for output file name, using defined tap file as suggested filename');
                     TextColor(LightGreen);
                     Writeln ('Parameters:');
                     TextColor(LightCyan);
                     Writeln ('   AutoSave');
                     TextColor(Yellow);
                     Writeln ('      Only asks for output file name if it is not defined');
                     TextColor(LightCyan);
                     Writeln ('   AutoReplace');
                     TextColor(Yellow);
                     Writeln ('      Never asks for output file name and always replaces input file');
                     TextColor(LightCyan);
                     Writeln ('   NoJobs');
                     TextColor(Yellow);
                     Writeln ('      Will not produce an error is no Jobs are found');
                     TextColor(LightCyan);
                     Writeln ('   NoCheck');
                     TextColor(Yellow);
                     Writeln ('      Will not check boundaries, Promill will check them');
                     TextColor(LightCyan);
                     Writeln ('   RunProMill');
                     TextColor(Yellow);
                     Writeln ('      Runs ProMill Draw Only with new TAP File');
                     Halt(70);
                     Readkey;
                     Halt(70);
                  End;
               If (Pos('.',Upcase(Paramstr(LoopCount)))=0) then
                  Begin
                     If (Pos('AUTOSAVE',Upcase(Paramstr(LoopCount)))>=1) Then
                        Autosave:=True;
                     If (Pos('AUTOREPLACE',Upcase(Paramstr(LoopCount)))>=1) Then
                        AutoReplace:=True;
                     If (Pos('NOJOBS',Upcase(Paramstr(LoopCount)))>=1) Then
                        NoJobs:=True;
                     If (Pos('NOCHECK',Upcase(Paramstr(LoopCount)))>=1) Then
                        NoCheck:=True;
                     If (Pos('RUNPROMILL',Upcase(Paramstr(LoopCount)))>=1) Then
                        RunProMill:=True;
                  End
               Else
                  TapFileName:=ParamStr(LoopCount);
            End;
         Loopcount:=0;
         If TapFileName<='' then
            Begin
               windows.messagebox(0,pchar('No File Name Specified'),pchar('Error'),MB_OK);
               Halt(70);
            End
         Else
         If FileExists(TapFileName) Then
            Begin
               If NoJobs Then
                  Writeln('NoJobs');
               If NoCheck Then
                  Writeln('NoCheck');
               If Autosave Then
                  Writeln('AutoSave');
               If AutoReplace then
                  Begin
                     Writeln('AutoReplace');
                     Autosave:=True;
                     OutputTapFileName:=TapFileName;
                     Writeln('Saving to and replacing:'+OutputTapFileName);
                  End;
               TapFileHeaderActive:=True;
               Tapfilein       :=TStringlist.Create;
               Tapfilelist     :=TStringlist.Create;
               TapfileToolList :=TStringlist.Create;
               TapfileJobsList :=TStringlist.Create;
               ToolDescriptions:=TStringlist.Create;
               Tapfilein.loadfromfile(TapFileName);
               If Tapfilein.Count > 0 then
                  Begin
                     For TapFileLineNumber := 0 to Tapfilein.Count-1 Do
                        Begin
                           If SkipnextC Then
                              Begin
                                 SkipnextC:=False;
                              End
                           Else
                              Begin
                                 TapFileData:=Tapfilein[TapFileLineNumber];
                                 If FixG0C Then
                                    Begin
                                       If TapFileLineNumber < Tapfilein.Count-1 Then
                                          TapFileDataNext:=Tapfilein[TapFileLineNumber+1]
                                       Else
                                          TapFileDataNext:='';
                                       Writeln('|'+TapFileData+'|'+TapFileDataNext+'|');
                                       If Pos('G1 C',TapFileDataNext) > 0 Then
                                          Begin
                                             Writeln('Next Line is G1 C');
                                             TapFileData:=TapFileData+Copy(TapFileDataNext,Pos('G1 C',TapFileDataNext)+3,100);
                                             SkipnextC:=True;
                                          End;
                                       If Pos('G0 C',TapFileData) > 0 Then
                                          Begin
                                             Writeln('Line G0 C');
                                             If Pos('G0',TapFileDataNext) > 0 Then
                                                Begin
                                                   TapFileData:=TapFileDataNext+Copy(TapFileData,Pos('G0 C',TapFileData)+3,100);
                                                   SkipnextC:=True;
                                                End;
                                          End;
                                    End;
                                 NewTapFileData:='';
                                 Inc(Originallinenum);
                                 //Writeln(Originallinenum,' ',Tapfiledata);
                                 If TapFileData='HEAD UP' Then
                                    Begin
                                       TapFileData:='G0 Z12345';
                                    End;
                                 If TapFileData='G1 ' Then
                                    Begin
                                       Inc (NullG1);
                                       TapFileData:=';Skipit';
                                    End
                                 Else
                                    Begin
                                       Gc:=-1;
                                       If (Copy(TapFileData,1,3)='G00') or ((Copy(TapFileData,1,2)='G0') and (Copy(TapFileData,1,3)<>'G01') and (Copy(TapFileData,1,3)<>'G02') and (Copy(TapFileData,1,3)<>'G03')) then
                                          Begin
                                             Gc:=0;
                                             G1_XY_Angle:=NaN;
                                             G1_Z_Direction:=NaN;
                                          End
                                       Else
                                          Begin
                                             G0_XY_Angle:=NaN;
                                             G0_Z_Direction:=NaN;
                                             if (Copy(TapFileData,1,2)='G1') Or (Copy(TapFileData,1,3)='G01') then
                                                Gc:=1
                                             Else
                                                Begin
                                                   G1_XY_Angle:=NaN;
                                                   G1_Z_Direction:=NaN;
                                                   if (Copy(TapFileData,1,2)='G2') Or (Copy(TapFileData,1,3)='G02') then
                                                      Gc:=2
                                                   Else
                                                      if (Copy(TapFileData,1,2)='G3') Or (Copy(TapFileData,1,3)='G03') then
                                                         Gc:=3;
                                                End;
                                          End;

                                       If (Copy(TapFileData,1,2)='G0') or (Copy(TapFileData,1,2)='G1') Or (Copy(TapFileData,1,2)='G2') or (Copy(TapFileData,1,2)='G3') Then
                                          Begin
                                             XString:='';
                                             YString:='';
                                             ZString:='';
                                             AString:='';
                                             CString:='';
                                             SString:='';
                                             IString:='';
                                             JString:='';
                                             Arc_X_Min:=Nan;
                                             Arc_X_Max:=Nan;
                                             Arc_Y_Min:=Nan;
                                             Arc_Y_Max:=Nan;
                                             X_Dec := True;
                                             Y_Dec := True;
                                             I_Dec := True;
                                             J_Dec := True;
                                             Z_Dec := True;
                                             A_Dec := True;
                                             C_Dec := True;
                                             S_Dec := True;
                                             If (Copy(TapFileData,1,3)='G00') or (Copy(TapFileData,1,3)='G01') Or (Copy(TapFileData,1,3)='G02') or (Copy(TapFileData,1,3)='G03') Then
                                                I := 3
                                             Else
                                                I := 2;

                                             Previous_X:=Current_X;
                                             Previous_Y:=Current_Y;
                                             Previous_Z:=Current_Z;
                                             Px:=Value(Previous_X);
                                             Py:=Value(Previous_Y);
                                             Pz:=Value(Previous_Z);
                                             While I<=Length(TapFileData) Do
                                                Begin
                                                   //Writeln(I,' ',TapFileData[I]);
                                                   If TapFileData[I]='X' then
                                                      Begin
                                                         Repeat
                                                            Inc(I);
                                                            IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                               Xstring:=Xstring+TapFileData[I];
                                                         Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                         Dec(I);
                                                         If Pos('.',Xstring)=0 then
                                                               x_dec:=False;
                                                         XNum:=Value(Xstring);
                                                         Current_X:=XString;
                                                         //Writeln(Previous_X);
                                                         //Writeln(XMin,'  ',XMax,'  X',XString,' ',Xnum:0:12);
                                                         If (Xnum>XMax) or IsNan(XMax) Then
                                                            XMax:=Xnum;
                                                         If (Xnum<XMin) or IsNan(XMin) Then
                                                            XMin:=Xnum;
                                                         If Not(NoCheck) and ((Xnum>X_Limit_Pos) Or (Xnum<X_Limit_Neg)) then
                                                            Begin
                                                               If JobErrorLineNumber=0 then
                                                                  Begin
                                                                     JobErrorLineNumber:=Originallinenum;
                                                                     JobErrorLine:=TapFileData;
                                                                  End;
                                                               Inc(JobErrorCount);
                                                               Inc(ErrorCount);
                                                               Errorfound:=True;
                                                            End;
                                                         //Writeln(Xstring,'Px',Px:0:4,I,' ',TapFileData[I]);
                                                      End;
                                                   If TapFileData[I]='Y' then
                                                      Begin
                                                         Repeat
                                                            Inc(I);
                                                            IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                               Ystring:=Ystring+TapFileData[I];
                                                         Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                         Dec(I);
                                                         If Pos('.',Ystring)=0 then
                                                               y_dec:=False;
                                                         YNum:=Value(Ystring);
                                                         Current_Y:=YString;
                                                         //Writeln('Y',YString,' ',Ynum:0:12);
                                                         If (Ynum>YMax) or IsNan(YMax) Then
                                                            YMax:=Ynum;
                                                         If (Ynum<YMin) or IsNan(YMin) Then
                                                            YMin:=Ynum;
                                                         If Not(NoCheck) and ((Ynum>Y_Limit_Pos) Or (Ynum<Y_Limit_Neg)) then
                                                            Begin
                                                               If JobErrorLineNumber=0 then
                                                                  Begin
                                                                     JobErrorLineNumber:=Originallinenum;
                                                                     JobErrorLine:=TapFileData;
                                                                  End;
                                                               Inc(JobErrorCount);
                                                               Inc(ErrorCount);
                                                               Errorfound:=True;
                                                            End;
                                                         //Writeln(Ystring,'Py',Py:0:4,I,' ',TapFileData[I]);
                                                      End;
                                                   If TapFileData[I]='S' then
                                                      Begin
                                                         Use_S:=True;
                                                         Repeat
                                                            Inc(I);
                                                            IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                               Sstring:=Sstring+TapFileData[I];
                                                         Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                         Dec(I);
                                                         If Pos('.',Ystring)=0 then
                                                               s_dec:=False;
                                                         SNum:=Value(Sstring);
                                                         Rs:=Value(Previous_S);
                                                         Previous_S:=Sstring;
                                                         //Writeln('Y',YString,' ',Ynum:0:12);
                                                         If (Snum>SMax) or IsNan(SMax) Then
                                                            SMax:=Snum;
                                                         If (Snum<SMin) or IsNan(SMin) Then
                                                            SMin:=Snum;
                                                         If (Snum>S_Limit_Pos) Or (Snum<S_Limit_Neg) then
                                                            Begin
                                                               If JobErrorLineNumber=0 then
                                                                  Begin
                                                                     JobErrorLineNumber:=Originallinenum;
                                                                     JobErrorLine:=TapFileData;
                                                                  End;
                                                               Inc(JobErrorCount);
                                                               Inc(ErrorCount);
                                                               Errorfound:=True;
                                                            End;
                                                         //Writeln(Sstring,'Ps',Ps:0:4,I,' ',TapFileData[I]);
                                                      End;
                                                   If TapFileData[I]='I' then
                                                      Begin
                                                         Repeat
                                                            Inc(I);
                                                            IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                               Istring:=Istring+TapFileData[I];
                                                         Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                         Dec(I);
                                                         If Pos('.',Istring)=0 then
                                                               i_dec:=False;
                                                         Gi:=Value(Istring);
                                                         If IJRelative then
                                                            Gi:=Gi+XNum;
                                                         //Writeln(ijrelative,istring,'Gi',Gi:0:4,I,' ',TapFileData[I]);
                                                      End;
                                                   If TapFileData[I]='J' then
                                                      Begin
                                                         Repeat
                                                            Inc(I);
                                                            IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                               Jstring:=Jstring+TapFileData[I];
                                                         Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                         Dec(I);
                                                         If Pos('.',Jstring)=0 then
                                                               j_dec:=False;
                                                         Gj:=Value(Jstring);
                                                         If IJRelative then
                                                            Gj:=Gj+YNum;
                                                         //Writeln('Gj',Gj:0:4,I,' ',TapFileData[I]);
                                                      End;
                                                   If TapFileData[I]='Z' then
                                                      Begin
                                                         G1_XY_Angle:=NaN;
                                                         G0_XY_Angle:=NaN;
                                                         Repeat
                                                            Inc(I);
                                                            IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                               Zstring:=Zstring+TapFileData[I];
                                                         Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                         Dec(I);
                                                         If Pos('.',Zstring)=0 then
                                                               z_dec:=False;
                                                         Znum:=Value(Zstring);
                                                         Current_Z:=ZString;
                                                         //Writeln('Z',ZString,' ',Znum:0:12);
                                                         If (Znum>ZMax) or IsNan(ZMax) Then
                                                            ZMax:=Znum;
                                                         If (Znum<ZMin) or IsNan(ZMin) Then
                                                            ZMin:=Znum;
                                                         If Not(NoCheck) and ((Znum>Z_Limit_Pos) Or (Znum<Z_Limit_Neg)) then
                                                            Begin
                                                               If JobErrorLineNumber=0 then
                                                                  Begin
                                                                     JobErrorLineNumber:=Originallinenum;
                                                                     JobErrorLine:=TapFileData;
                                                                  End;
                                                               Inc(JobErrorCount);
                                                               Inc(ErrorCount);
                                                               Errorfound:=True;
                                                            End;
                                                         //Writeln(Zstring,'Znum',Znum:0:4,I,' ',TapFileData[I]);
                                                      End;
                                                   If Machine = 'Scout 5 Axis' Then
                                                      Begin
                                                         If (TapFileData[I]='A') then
                                                            Begin
                                                               Repeat
                                                                  Inc(I);
                                                                  IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                                     Astring:=Astring+TapFileData[I];
                                                               Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                               Dec(I);
                                                               If Pos('.',Astring)=0 then
                                                                  a_dec:=False;
                                                               Anum:=Value(Astring);
                                                               //Writeln('A',AString,' ',Anum:0:12);
                                                               If (Anum>AMax) or IsNan(AMax) Then
                                                                  AMax:=Anum;
                                                               If (Anum<AMin) or IsNan(AMin) Then
                                                                  AMin:=Anum;
                                                               If Not(NoCheck) and ((Anum>A_Limit_Pos) Or (Anum<A_Limit_Neg)) then
                                                                  Begin
                                                                     If JobErrorLineNumber=0 then
                                                                        Begin
                                                                           JobErrorLineNumber:=Originallinenum;
                                                                           JobErrorLine:=TapFileData;
                                                                        End;
                                                                     Inc(JobErrorCount);
                                                                     Inc(ErrorCount);
                                                                     Errorfound:=True;
                                                                  End;
                                                            End;
                                                         If (TapFileData[I]='C') then
                                                            Begin
                                                               Repeat
                                                                  Inc(I);
                                                                  IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                                     Cstring:=Cstring+TapFileData[I];
                                                               Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                               Dec(I);
                                                               If Pos('.',Cstring)=0 then
                                                                  c_dec:=False;
                                                               Cnum:=Value(Cstring);
                                                               //Writeln('C',CString,' ',Cnum:0:12);
                                                               If (Cnum>CMax) or IsNan(CMax) Then
                                                                  CMax:=Cnum;
                                                               If (Cnum<CMin) or IsNan(CMin) Then
                                                                  CMin:=Cnum;
                                                               If Not(NoCheck) and ((Cnum>C_Limit_Pos) Or (Cnum<C_Limit_Neg)) then
                                                                  Begin
                                                                     If JobErrorLineNumber=0 then
                                                                        Begin
                                                                           JobErrorLineNumber:=Originallinenum;
                                                                           JobErrorLine:=TapFileData;
                                                                        End;
                                                                     Inc(JobErrorCount);
                                                                     Inc(ErrorCount);
                                                                     Errorfound:=True;
                                                                  End;
                                                            End;
                                                      End;
                                                   If Machine = 'Scout 5 Axis' Then
                                                      Begin
                                                         If   Not(X_DEC AND Y_DEC AND I_DEC AND J_DEC AND Z_DEC AND A_DEC AND C_DEC) then
                                                            Begin
                                                               inc(Derrorcount);
                                                               if Derrorlinenum =0 then
                                                                  Begin
                                                                     DErrorLine:=TapFileData;
                                                                     DErrorlinenum:=(Originallinenum);
                                                                  end;
                                                            End;
                                                      End;
                                                   Inc(I);
                                                End;
                                             FromX:=Rx;
                                             FromY:=Ry;
                                             Oz:=Rz;
                                             Old_Previous_X:=Previous_X;
                                             Old_Previous_Y:=Previous_Y;
                                             Old_Previous_Z:=Previous_Z;
                       //                      If XString='' then
                                                Begin
                                                   If Previous_X = '' Then
                                                      Rz:=NaN
                                                   Else
                                                      Rx:=Value(Previous_X);
                                                end;
                         //                    If YString='' then
                                                Begin
                                                   If Previous_Y = '' Then
                                                      Ry:=NaN
                                                   Else
                                                      Ry:=Value(Previous_Y);
                                                end;

                                                Begin
                                                   If Previous_Z = '' Then
                                                      Rz:=NaN
                                                   Else
                                                      Rz:=Value(Previous_Z);
                                                end;
                           //                  If (SString='') then
                                                Begin
                                                   Rs:=Value(Previous_S);
                                                end;
                                             If (ZString<>'') Then
                                                Begin
                                                   FromX:=NaN;
                                                   FromY:=NaN;
                                                   Old_Previous_X:='';
                                                   Old_Previous_Y:='';
                                                   Rx:=NaN;
                                                   Ry:=NaN;
                                                   Rs:=NaN;
                                                End;
                                             If (XString<>'') Or (YString<>'') Then
                                                Begin
                                                   Oz:=0;
                                                   Old_Previous_Z:='';
                                                   Rz:=NaN;
                                                End;
                                             //Writeln('Rx',Outstring(Rx),' Ry',Outstring(Ry));
                                             ForceG1XY:=False;
                                             If GC=0 then
                                                Begin
                                                   Replace_G0_Previous_By_Angle       := False;
                                                   Replace_G0_Previous_By_Distance    := False;
                                                   Replace_G0_Z_Previous_By_Direction := False;
                                                   If FixG0InLine Then
                                                      Begin
                                                         If ((XString<>'') or (YString<>'')) and (ZString='') And ((Use_S And (Rs=SNum)) or Not(Use_S)) then
                                                            Begin
                                                               Prev_G0_XY_Angle:=G0_XY_Angle;
                                                               G0_XY_Angle:=ArcTan2(YNum-Ry,XNum-Rx)/(PI/180);
                                                               //Writeln('G0A',G1_XY_Angle:0:20,' dX',XNum-Rx:0:20,' dY',YNum-Ry:0:20);
                                                               If Not(IsNan(Prev_G0_XY_Angle)) And (Prev_G0_XY_Angle = G0_XY_Angle) then
                                                                  Replace_G0_Previous_By_Angle:= True
                                                               Else
                                                                  Begin
                                                                     Replace_G0_Previous_By_Angle:= False;
                                                                     If (G0_XY_Angle <> 0)   And
                                                                        (ABS(G0_XY_Angle) <> 180) And
                                                                        (ABS(G0_XY_Angle) <> 360) And
                                                                        (ABS(G0_XY_Angle) <> 270) And
                                                                        (ABS(G0_XY_Angle) <> 90) Then
                                                                           Begin
                                                                              //  FromX   A  := 0.84375;          //Begin X
                                                                              //  FromY   B  := 3.5625;           //Begin Y
                                                                              //  XNum  C  := 0.845836141667;   //End X
                                                                              //  YNum  D  := 3.56448393879;    //End Y
                                                                              //  Px    E  := 0.845245692895;  //Test Point X
                                                                              //  Py    F  := 3.56406041753;   //Test Point Y
                                                                                       // If either length > line then point is outside of line segment
                                                                              If (Hypot(FromX-Rx,FromY-Ry)>Hypot(FromX-XNum,FromY-YNum)) or (Hypot(XNum-Rx,YNum-Ry)>Hypot(FromX-XNum,FromY-YNum)) then
                                                                                 Replace_G0_Previous_By_Distance:=False
                                                                              Else
                                                                                 Begin
                                                                                    Qx    := ( 1/(((YNum-FromY)/(XNum-FromX)))+Rx);    //X after perpendicular slope
                                                                                    Qy    := (-1/(((YNum-FromY)/(XNum-FromX)))+Ry);    //Y after perpendicular slope
                                                                                    PerpenX    :=(((FromX*YNum-FromY*XNum)*(Rx-Qx)-(FromX-XNum)*(Rx*Qy-Ry*Qx)))/(((FromX-XNum)*(Ry-Qy)-(FromY-YNum)*(Rx-Qx)));  //X Intersection Point
                                                                                    PerpenY    :=(((FromX*YNum-FromY*XNum)*(Ry-Qy)-(FromY-YNum)*(Rx*Qy-Ry*Qx)))/(((FromX-XNum)*(Ry-Qy)-(FromY-YNum)*(Rx-Qx)));  //Y Intersection Point
                                                                                    LengthPerp := Hypot(PerpenX-Rx,PerpenY-Ry);  //Distance from Point to Line
                                                                                    If LengthPerp <= Line_Segment_Error Then
                                                                                       Begin
                                                                                          If Isnan(LargestLengthPerp) OR (LengthPerp > LargestLengthPerp) then
                                                                                             LargestLengthPerp := LengthPerp;
                                                                                          If Isnan(SmallestLengthPerp) OR (LengthPerp < SmallestLengthPerp) then
                                                                                             SmallestLengthPerp := LengthPerp;
                                                                                          Replace_G1_Previous_By_Distance := True;
                                                                                       End
                                                                                    Else
                                                                                       Replace_G0_Previous_By_Distance := False;
                                                                                 End;
                                                                           End;
                                                                  End;
                                                            End;
                                                      End;
                                                   If FixG0ZInLine Then
                                                      Begin
                                                         If (ZString<>'') And (XString='') And (YString='') And ((Use_S And (Rs=SNum)) or Not(Use_S)) then
                                                            Begin
                                                               Prev_G0_Z_Direction:=G0_Z_Direction;
                                                               If ZNum > Rz Then
                                                                  G0_Z_Direction:= 1
                                                               Else
                                                               If ZNum < Rz Then
                                                                  G0_Z_Direction:= -1
                                                               Else
                                                                  G0_Z_Direction:= 0;
                                                               //Writeln('G0_Z_Direction ',G0_Z_Direction:0:4,' ZNum ',ZNum:0:4 ,' RZ ',RZ:0:4, '  G0_Z_Direction',G0_Z_Direction:0:4 );
                                                               If Not(IsNan(Prev_G0_Z_Direction)) And ((Prev_G0_Z_Direction = G0_Z_Direction) or (Prev_G0_Z_Direction = 0)) then
                                                                  Begin
                                                                     Replace_G0_Z_Previous_By_Direction:= True;
                                                                  End
                                                               Else
                                                                  Begin
                                                                     Replace_G0_Z_Previous_By_Direction:= False;
                                                                  End;
                                                            End
                                                         Else
                                                            Begin
                                                               G0_Z_Direction:=NaN;
                                                            End;
                                                      End;
                                                   //Writeln((G0_XY_Angle*180/pi):0:8,' ',Replace_G0_Previous_By_Angle,'  ',PX:0:8,'   ',XNum:0:8,'  ',PY:0:8,'   ',YNum:0:8,'  ',PS:0:8,'   ',SNum:0:8);
                                                   If (Replace_G0_Previous_By_Angle Or Replace_G0_Previous_By_Distance) and (Pos('F',Tapfilelist[Tapfilelist.Count-1]) = 0) Then
                                                      Begin
                                                         If Replace_G0_Previous_By_Angle then
                                                            Inc(Replace_G0_Previous_By_Angle_Count);
                                                         If Replace_G0_Previous_By_Distance then
                                                         Inc(Replace_G0_Previous_By_Distance_Count);
                                                         If DeleteRemovedLines Then
                                                            Tapfilelist.Delete(Tapfilelist.Count-1)
                                                         Else
                                                            Tapfilelist[Tapfilelist.Count-1]:='//'+Tapfilelist[Tapfilelist.Count-1];
                                                         //Writeln('Removed Line:',TapFileData);
                                                         Rx:=FromX;
                                                         Ry:=FromY;
                                                         Previous_X:=Old_Previous_X;
                                                         Previous_Y:=Old_Previous_Y;
                                                      End;
                                                   If (Replace_G0_Z_Previous_By_Direction) and (Pos('F',Tapfilelist[Tapfilelist.Count-1]) = 0) Then
                                                      Begin
                                                         Inc(Replace_G0_Z_Previous_By_Direction_Count);
                                                         If DeleteRemovedLines Then
                                                            Tapfilelist.Delete(Tapfilelist.Count-1)
                                                         Else
                                                            Tapfilelist[Tapfilelist.Count-1]:='//'+Tapfilelist[Tapfilelist.Count-1];
                                                         //Writeln('Removed Line:',TapFileData);
                                                         Rz:=Oz;
                                                         Previous_Z:=Old_Previous_Z;
                                                      End;
                                                End
                                             Else
                                                Begin
                                                   G0_XY_Angle:=NaN;
                                                   G0_Z_Direction:=NaN;
                                                End;
                                             If GC=1 then
                                                Begin
                                                   Replace_G1_Previous_By_Angle       := False;
                                                   Replace_G1_Previous_By_Distance    := False;
                                                   Replace_G1_Z_Previous_By_Direction := False;
                                                   If FixG1InLine Then
                                                      Begin
                                                        // Writeln('   Line From: X'+Outstring(FromX)+' Y'+Outstring(FromY)+
                                                        //  '  To: X'+Outstring(XNum)+' Y'+Outstring(YNum)+
                                                        //  '  Point: X'+Outstring(Rx)+' Y'+Outstring(Ry));
                                                         If ((XString<>'') or (YString<>'')) and (ZString='') And ((Use_S And (Rs=SNum)) or Not(Use_S)) then
                                                            Begin
                                                               Prev_G1_XY_Angle:=G1_XY_Angle;
                                                               G1_XY_Angle:=ArcTan2(YNum-Ry,XNum-Rx)/(PI/180);
                                                               //Writeln('G1A',Outstring(G1_XY_Angle),' dX',Outstring(XNum-Rx),' dY',Outstring(YNum-Ry));
                                                               If Not(IsNan(Prev_G1_XY_Angle)) And (Prev_G1_XY_Angle = G1_XY_Angle) then
                                                                  Replace_G1_Previous_By_Angle:= True
                                                               Else
                                                                  Begin
                                                                     If (G1_XY_Angle <> 0)   And
                                                                        (ABS(G1_XY_Angle) <> 180) And
                                                                        (ABS(G1_XY_Angle) <> 360) And
                                                                        (ABS(G1_XY_Angle) <> 270) And
                                                                        (ABS(G1_XY_Angle) <> 90) Then
                                                                           Begin
                                                                                    // If either length > line then point is outside of line segment
      //                                                                        If (Hypot(FromX-Rx,FromY-Ry)>Hypot(FromX-XNum,FromY-YNum)) or (Hypot(XNum-Rx,YNum-Ry)>Hypot(FromX-XNum,FromY-YNum)) then
      //                                                                           Replace_G1_Previous_By_Distance:=False
      //                                                                        Else
                                                                                 Begin
                                                                                    //Writeln(TapfileData,' A',Outstring(G1_XY_Angle),' FromX',Outstring(FromX),' Rx',Outstring(Rx),' XNum',Outstring(XNum),
                                                                                    //'    FromY',Outstring(FromY),' Ry',Outstring(Ry),' YNum',Outstring(YNum),' ',Outstring(G1_XY_Angle));
                                                                                    If (YNum<>FromY) And (XNum<>FromX) And (YNum<>Rx) And (XNum<>Ry) And (FromX<>Rx) And (FromY<>Ry) Then
                                                                                       Begin
                                                                                          Qx    := Rx+(YNum-FromY);    //X after perpendicular slope
                                                                                          Qy    := Ry+(FromX-XNum);    //Y after perpendicular slope
                                                                                           //Writeln('    Qx',Outstring(Qx),' Qy',Outstring(Qy));
      //                                                                                    If (((FromX-XNum)*(Ry-Qy)-(FromY-YNum)*(Rx-Qx))) = 0 Then
      //                                                                                       Begin
      //                                                                                       End
      //                                                                                    Else
                                                                                             Begin
                                                                                                PerpenX    :=(((FromX*YNum-FromY*XNum)*(Rx-Qx)-(FromX-XNum)*(Rx*Qy-Ry*Qx)))/(((FromX-XNum)*(Ry-Qy)-(FromY-YNum)*(Rx-Qx)));  //X Intersection Point
                                                                                                PerpenY    :=(((FromX*YNum-FromY*XNum)*(Ry-Qy)-(FromY-YNum)*(Rx*Qy-Ry*Qx)))/(((FromX-XNum)*(Ry-Qy)-(FromY-YNum)*(Rx-Qx)));  //Y Intersection Point
                                                                                             End;
                                                                                          LengthPerp := Hypot(PerpenX-Rx,PerpenY-Ry);  //Distance from Point to Line
                                                                                          //Writeln('LengthPerp ',Outstring(LengthPerp));
                                                                                             //   If (Abs((((YNum-FromY)/(XNum-FromX))))= 1) {or (Xnum=5.50171)} Then
                                                                                             //   readln;
                                                                                          //Readln;
                                                                                          If LengthPerp <= Line_Segment_Error Then
                                                                                             Begin
                                                                                                //Writeln(true);
                                                                                                If Isnan(LargestLengthPerp) OR (LengthPerp > LargestLengthPerp) then
                                                                                                   LargestLengthPerp := LengthPerp;
                                                                                                If Isnan(SmallestLengthPerp) OR (LengthPerp < SmallestLengthPerp) then
                                                                                                   SmallestLengthPerp := LengthPerp;
                                                                                                Replace_G1_Previous_By_Distance := True;
                                                                                             End
                                                                                          Else
                                                                                             Replace_G1_Previous_By_Distance := False;
                                                                                       End
                                                                                 // Else
                                                                                 //    Replace_G1_Previous_By_Distance := False;
                                                                                 End;
                                                                           End;
                                                                  End;
                                                            End;
                                                      End;

                                                   If FixG1ZInLine Then
                                                      Begin
                                                         If (ZString<>'') And (XString='') And (YString='') And ((Use_S And (Rs=SNum)) or Not(Use_S)) then
                                                            Begin
                                                               Prev_G1_Z_Direction:=G1_Z_Direction;
                                                               If ZNum > Rz Then
                                                                  G1_Z_Direction:= 1
                                                               Else
                                                               If ZNum < Rz Then
                                                                  G1_Z_Direction:= -1
                                                               Else
                                                                  G1_Z_Direction:= 0;
                                                               //Writeln('G1_Z_Direction ',G1_Z_Direction:0:4,' ZNum ',ZNum:0:4 ,' RZ ',RZ:0:4, '  G0_Z_Direction',G1_Z_Direction:0:4 );
                                                               If Not(IsNan(Prev_G1_Z_Direction)) And ((Prev_G1_Z_Direction = G1_Z_Direction) or (Prev_G1_Z_Direction = 0)) then
                                                                  Begin
                                                                     Replace_G1_Z_Previous_By_Direction:= True;
                                                                  End
                                                               Else
                                                                  Begin
                                                                     Replace_G1_Z_Previous_By_Direction:= False;
                                                                  End;
                                                            End
                                                         Else
                                                            Begin
                                                               G1_Z_Direction:=NaN;
                                                            End;
                                                      End;
                                                   //Writeln((G1_XY_Angle*180/pi):0:8,' ',Replace_G1_Previous_By_Angle,'  ',PX:0:8,'   ',XNum:0:8,'  ',PY:0:8,'   ',YNum:0:8,'  ',PS:0:8,'   ',SNum:0:8);
                                                   If (Replace_G1_Previous_By_Angle Or Replace_G1_Previous_By_Distance) and (Pos('F',Tapfilelist[Tapfilelist.Count-1]) = 0) Then
                                                      Begin
                                                         If Replace_G1_Previous_By_Angle then
                                                            Inc(Replace_G1_Previous_By_Angle_Count);
                                                         If Replace_G1_Previous_By_Distance then
                                                         Inc(Replace_G1_Previous_By_Distance_Count);
                                                         If DeleteRemovedLines Then
                                                            Tapfilelist.Delete(Tapfilelist.Count-1)
                                                         Else
                                                            Begin
                                                               If Replace_G1_Previous_By_Angle then
                                                                  Tapfilelist[Tapfilelist.Count-1]:='//'+Tapfilelist[Tapfilelist.Count-1]+' // Removed By Angle -   Previous Angle:'+Outstring(Prev_G1_XY_Angle)
                                                                                                        +' = Current Angle: '+Outstring(G1_XY_Angle);
                                                               If Replace_G1_Previous_By_Distance then
                                                                  Tapfilelist[Tapfilelist.Count-1]:='//'+Tapfilelist[Tapfilelist.Count-1]+' // Removed By Distance -   Pependicular Length: '+Outstring(LengthPerp)+
                                                                                                   ' < '+Outstring(Line_Segment_Error)+' Line Segment Error'+
                                                                                                  '   Line From: X'+Outstring(FromX)+' Y'+Outstring(FromY)+
                                                                                                    '  To: X'+Outstring(XNum)+' Y'+Outstring(YNum)+
                                                                                                    '  Point: X'+Outstring(Rx)+' Y'+Outstring(Ry);
                                                            End;
                                                         //Writeln('Removed Line:',TapFileData);
                                                         Rx:=FromX;
                                                         Ry:=FromY;
                                                         Previous_X:=Old_Previous_X;
                                                         Previous_Y:=Old_Previous_Y;
                                                         ForceG1XY:=True
                                                      End;
                                                   If (Replace_G1_Z_Previous_By_Direction) and (Pos('F',Tapfilelist[Tapfilelist.Count-1]) = 0) Then
                                                      Begin
                                                         Inc(Replace_G1_Z_Previous_By_Direction_Count);
                                                         If DeleteRemovedLines Then
                                                            Tapfilelist.Delete(Tapfilelist.Count-1)
                                                         Else
                                                            Tapfilelist[Tapfilelist.Count-1]:='//'+Tapfilelist[Tapfilelist.Count-1];
                                                         //Writeln('Removed Line:',TapFileData);
                                                         Rz:=Oz;
                                                         Previous_Z:=Old_Previous_Z;
                                                      End;
                                                End
                                             Else
                                                Begin
                                                   G1_XY_Angle:=NaN;
                                                   G1_Z_Direction:=NaN;
                                                End;
                                             If (Gc=2) or (Gc=3) Then
                                                Begin
                                                   Arc_Min_Max;
                                                   If not(isNan(Arc_X_Min)) and (Arc_X_Min<Xmin) then
                                                      XMin:=Arc_X_Min;
                                                   If not(isNan(Arc_Y_Min)) and (Arc_Y_Min<Ymin) then
                                                      YMin:=Arc_Y_Min;
                                                   If not(isNan(Arc_X_Max)) and (Arc_X_Max>Xmax) then
                                                      XMax:=Arc_X_Max;
                                                   If not(isNan(Arc_Y_Max)) and (Arc_Y_Max>Ymax) then
                                                      YMax:=Arc_Y_Max;
                                                End;
                                             //Writeln(TapfileData,' -X',XMin:0:4,' +X',XMax:0:4,' -Y',YMin:0:4,' +Y',YMax:0:4,' PrevX',Previous_X,' PrevY',Previous_Y   );
                                             If ((Copy(TapFileData,1,2)='G0') And ForceG1XY) Or ((Copy(TapFileData,1,3)<>'G01') and (Copy(TapFileData,1,3)<>'G02') and (Copy(TapFileData,1,3)<>'G03')) and (XString='') and (YString<>'') then
                                                Begin
                                                   If (Copy(TapFileData,1,2)='G00') then
                                                      I := 3
                                                   Else
                                                      I := 2;
                                                   While I<=Length(TapFileData) Do
                                                      Begin
                                                         If TapFileData[I]='Y' then
                                                            Begin
                                                               NewTapFileData:=Copy(TapFileData,1,I-1)+'X'+Current_X+' '+Copy(TapFileData,I,Length(TapFileData)-(I-1));
                                                            End;
                                                         Inc(I);
                                                      End;
                                                   If NewTapFileData<>'' then
                                                      TapFileData := NewTapFileData;
                                                End;
                                             If ((Copy(TapFileData,1,2)='G0') And ForceG1XY) Or ((Copy(TapFileData,1,3)<>'G01') and (Copy(TapFileData,1,3)<>'G02') and (Copy(TapFileData,1,3)<>'G03')) and (YString='') and (XString<>'') then
                                                Begin
                                                   I :=3;
                                                   While I<=Length(TapFileData) Do
                                                      Begin
                                                         If TapFileData[I]='X' then
                                                            Begin
                                                               Xstring:=Copy(TapFileData,1,I);
                                                               Repeat
                                                                  Inc(I);
                                                                  IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                                     Xstring:=Xstring+TapFileData[I];
                                                               Until (I>=Length(TapfileData)) Or Not({(TapFileData[I]=' ') or }(TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                               NewTapFileData:=Xstring+' Y'+Current_Y+Copy(TapFileData,I,Length(TapFileData)-(I-1));
                                                            End;
                                                         Inc(I);
                                                      End;
                                                   If NewTapFileData<>'' then
                                                      TapFileData := NewTapFileData;
                                                End;
                                             If (GC=1) and Use_S and (SString='') Then
                                                Begin
                                                   TapFileData := TapFileData + ' S'+Previous_S;
                                                End;
                                          End;
                                       JobLine:=False;
                                             If (Pos('MACHINE:',Upcase(TapFileData))>0) or (Pos('~MACHINE~ =',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='ProAuto';
                                                   //Writeln(TapFileData,'  ',Upcase(TapFileData));
                                                   //Writeln(POS('MACHINE: PROAUTO ROUTER 5X18',Upcase(TapFileData)));
                                                   //MACHINE: PROAUTO ROUTER 5X18
                                                   //; Machine: ProAuto Router 5x18
                                                End;
                                             If Pos('.CCD',Upcase(TapFileData))>0 Then
                                                CCDFound:=True;
                                             If Pos('|SCRIPT(',Upcase(TapFileData))>0 Then
                                                Inc(ScriptFound);
                                             If Pos('Custom_',TapFileData)>0 Then
                                                Begin
                                                   Inc(Custom_Variables_Not_Found);
                                                      If Pos('Custom_Job_Path',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Job_Path Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Job_Start',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Job_Start Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Job_End',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Job_End Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Start',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Start Variable Not Found');
                                                         End;
                                                      If Pos('Custom_End',Upcase(TapFileData))>0 Then
                                                         Begin
                                                            Writeln('@Custom_End Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Program_Start',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Program_Start Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Program_End',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Program_End Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Top',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Top Variable Not Found');
                                                         End;
                                                      If Pos('Custom_Bottom',TapFileData)>0 Then
                                                         Begin
                                                            Writeln('@Custom_Bottom Variable Not Found');
                                                         End;

                                                End;
                                             If (Pos('MACHINE: PROAUTO ALL',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `PROAUTO ALL`',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='ProAuto Mill';
                                                   X_Limit_Pos:=10000;
                                                   X_Limit_Neg:=-10000;
                                                   Y_Limit_Pos:=10000;
                                                   Y_Limit_Neg:=-10000;
                                                   Z_Limit_Pos:=10000;
                                                   Z_Limit_Neg:=-10000;
                                                End;
                                             If (Pos('MACHINE: PROAUTO MILL',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `PROAUTO MILL`',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='ProAuto';
                                                   X_Limit_Pos:=18;
                                                   X_Limit_Neg:=-18;
                                                   Y_Limit_Pos:=12;
                                                   Y_Limit_Neg:=-12;
                                                   Z_Limit_Pos:=6;
                                                   Z_Limit_Neg:=-6;
                                                End;
                                             If (Pos('MACHINE: PROAUTO ROUTER 5X4',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `PROAUTO ROUTER 5X4`',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='ProAuto Router 5x4';
                                                   X_Limit_Pos:=62;
                                                   X_Limit_Neg:=0;
                                                   Y_Limit_Pos:=48;
                                                   Y_Limit_Neg:=0;
                                                   Z_Limit_Pos:=6;
                                                   Z_Limit_Neg:=-1;
                                                End;
                                             If (Pos('MACHINE: PROAUTO ROUTER 5X8',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `PROAUTO ROUTER 5X8`',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='ProAuto Router 5x8';
                                                   X_Limit_Pos:=62;
                                                   X_Limit_Neg:=0;
                                                   Y_Limit_Pos:=96;
                                                   Y_Limit_Neg:=0;
                                                   Z_Limit_Pos:=6;
                                                   Z_Limit_Neg:=-1;
                                                End;
                                             If (Pos('MACHINE: PROAUTO ROUTER 5X10',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `PROAUTO ROUTER 5X10`',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='ProAuto Router 5x10';
                                                   X_Limit_Pos:=62;
                                                   X_Limit_Neg:=0;
                                                   Y_Limit_Pos:=120;
                                                   Y_Limit_Neg:=0;
                                                   Z_Limit_Pos:=6;
                                                   Z_Limit_Neg:=-1;
                                                End;
                                             If (Pos('MACHINE: PROAUTO ROUTER 5X18',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `PROAUTO ROUTER 5X18`',Upcase(TapFileData))>0) Then
                                             Begin
                                                   Machine:='ProAuto Router 5x18';
                                                   X_Limit_Pos:=75;
                                                   X_Limit_Neg:=-20;
                                                   Y_Limit_Pos:=222;
                                                   Y_Limit_Neg:=-10;
                                                   Z_Limit_Pos:=10;
                                                   Z_Limit_Neg:=-1;
                                                End;
                                             If Pos('MACHINE: ONSRUD',Upcase(TapFileData))>0 Then
                                                Begin
                                                   Machine:='Onsrud';
                                                   X_Limit_Pos:=120;
                                                   X_Limit_Neg:=0;
                                                   Y_Limit_Pos:=60;
                                                   Y_Limit_Neg:=0;
                                                   Z_Limit_Pos:=6;
                                                   Z_Limit_Neg:=-1;
                                                   IJRelative:=True;
                                                End;
                                             If (Pos('MACHINE: 5 AXIS',Upcase(TapFileData))>0) Or
                                                (Pos('~MACHINE~ = `5 AXIS`',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Machine:='Scout 5 Axis';
                                                   X_Limit_Pos:=128;
                                                   X_Limit_Neg:=0;
                                                   Y_Limit_Pos:=254;
                                                   Y_Limit_Neg:=-2;
                                                   Z_Limit_Pos:=93;
                                                   Z_Limit_Neg:=-1;
                                                   A_Limit_Pos:=135;
                                                   A_Limit_Neg:=-135;
                                                   C_Limit_Pos:=1080;
                                                   C_Limit_Neg:=-1080;
                                                   IJRelative:=True;
                                                End;
                                             If Pos('C2B',Upcase(TapFileData))>0 then
                                                Begin
                                                   If Subroutines then
                                                      C2B := True
                                                   Else
                                                     C2BAll := True;
                                                   Writeln('Converting C Axis to B');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If C2B And (Pos('RETURN',Upcase(TapFileData))>0) then
                                                Begin
                                                   C2B := False;
                                                   Writeln('Done Converting C Axis to B');
                                                End;
                                             If (C2B or C2BAll) And 
                                                ((Pos('G00',Upcase(TapFileData))>0) Or
                                                (Pos('G01',Upcase(TapFileData))>0) Or
                                                (Pos('G02',Upcase(TapFileData))>0) Or
                                                (Pos('G03',Upcase(TapFileData))>0) Or
                                                (Pos('G0',Upcase(TapFileData))>0) Or
                                                (Pos('G1',Upcase(TapFileData))>0) Or
                                                (Pos('G2',Upcase(TapFileData))>0) Or
                                                (Pos('G3',Upcase(TapFileData))>0))
                                                And (Pos('C',Upcase(TapFileData))>0) Then
                                                Begin
                                                   //Writeln(Length(TapFileData),' ',TapFileData);
                                                   For J:= 1 to Length(TapFileData) do
                                                      Begin
                                                         //Writeln(J);
                                                         If (TapFileData[J] = 'C') Then
                                                             TapFileData[J]:= 'B';
                                                         If (TapFileData[J] = 'c') Then
                                                             TapFileData[J]:= 'b';
                                                      End;
                                                   //Writeln(TapFileData);
                                                End;
                                             If Pos('FIX G0 C',Upcase(TapFileData))>0 then
                                                Begin
                                                   FixG0C := True;
                                                   Writeln('Fixing G0 C');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('FIX G0 INLINE',Upcase(TapFileData))>0 then
                                                Begin
                                                   FixG0InLine := True;
                                                   Writeln('Fixing G0 InLine');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('FIX G1 INLINE',Upcase(TapFileData))>0 then
                                                Begin
                                                   FixG1InLine := True;
                                                   Writeln('Fixing G1 InLine');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('FIX G0 Z INLINE',Upcase(TapFileData))>0 then
                                                Begin
                                                   FixG0ZInLine := True;
                                                   Writeln('Fixing G0 Z InLine');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('FIX G1 Z INLINE',Upcase(TapFileData))>0 then
                                                Begin
                                                   FixG1ZInLine := True;
                                                   Writeln('Fixing G1 Z InLine');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('DELETE REMOVED LINES',Upcase(TapFileData))>0 then
                                                Begin
                                                   DeleteRemovedLines := True;
                                                   Writeln('Deleting Removed Lines');
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('DISABLE BOUNDARY CHECK',Upcase(TapFileData))>0 then
                                                Begin
                                                   NoCheck := True;
                                                   Writeln('Boundary Check Disabled');
                                                End;
                                             If Pos('LINE SEGMENT ERROR = ',Upcase(TapFileData))>0 then
                                                Begin
                                                   //Writeln('Line Segment Error');
                                                   Tempstring:='';
                                                   I:=Pos('Line Segment Error = ',Upcase(TapFileData))+21;
                                                   Repeat
                                                      Inc(I);
                                                      IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                         Tempstring:=Tempstring+TapFileData[I];
                                                      //Writeln(Tempstring);
                                                   Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                   Line_Segment_Error:=Value(Tempstring);
                                                   Writeln('Line Segment Error = ',Tempstring);
                                                   TapFileData:='SKIPIT';
                                                End;
                                             If Pos('PART X OFFSET = ',Upcase(TapFileData))>0 then
                                                Begin
                                                   //Writeln('PartX');
                                                   Tempstring:='';
                                                   I:=Pos('PART X OFFSET = ',Upcase(TapFileData))+15;
                                                   Repeat
                                                      Inc(I);
                                                      IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                         Tempstring:=Tempstring+TapFileData[I];
                                                   Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                   X_Part_Offset:=Value(Tempstring);
                                                   X_Limit_Neg:=X_Limit_Neg-X_Part_Offset;
                                                   X_Limit_Pos:=X_Limit_Pos-X_Part_Offset;
                                                End;
                                             If Pos('PART Y OFFSET = ',Upcase(TapFileData))>0 then
                                                Begin
                                                   Tempstring:='';
                                                   I:=Pos('PART Y OFFSET = ',Upcase(TapFileData))+15;
                                                   Repeat
                                                      Inc(I);
                                                      IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                         Tempstring:=Tempstring+TapFileData[I];
                                                   Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                   Y_Part_Offset:=Value(Tempstring);
                                                   Y_Limit_Neg:=Y_Limit_Neg-Y_Part_Offset;
                                                   Y_Limit_Pos:=Y_Limit_Pos-Y_Part_Offset;
                                                End;
                                             If Pos('PART Z OFFSET = ',Upcase(TapFileData))>0 then
                                                Begin
                                                   Tempstring:='';
                                                   I:=Pos('PART Z OFFSET = ',Upcase(TapFileData))+15;
                                                   Repeat
                                                      Inc(I);
                                                      IF (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')) Then
                                                         Tempstring:=Tempstring+TapFileData[I];
                                                   Until (I>=Length(TapfileData)) Or Not((TapFileData[I]=' ') or (TapFileData[I]='-') or (TapFileData[I]='.') or ((TapFileData[I]>='0') and (TapFileData[I]<='9')));
                                                   Z_Part_Offset:=Value(Tempstring);
                                                   Z_Limit_Neg:=Z_Limit_Neg-Z_Part_Offset;
                                                   Z_Limit_Pos:=Z_Limit_Pos-Z_Part_Offset;
                                                End;

                                             If Pos('SCOUTFOAM',Upcase(TapFileData))>0 Then
                                                Begin
                                                   ScoutFoam_Position:=OriginalLinenum;
                                                   TapFileData:=';--------------- Material ----------------'
                                                End;
                                             If Pos('CALL [SUBROUTINES]',Upcase(TapFileData))>0 Then
                                                Begin
                                                   TextColor(Cyan);
                                                   Writeln('Subroutine List');
                                                   TapFileHeaderActive:=False;
                                                   Subroutines:=True;
                                                   Subroutine_Position:=OriginalLinenum;
                                                   //TapFileJobsList.Add(';--------------- Subroutine List ----------------');
                                                End;
                                             If Pos('TOOL LIST',Upcase(TapFileData))>0 Then
                                                Begin
                                                   TextColor(Cyan);
                                                   Writeln('Tool List');
                                                   TapFileHeaderActive:=False;
                                                   ToolListused:=True;
                                                   ToolList_Position:=OriginalLinenum;
                                                   //TapFileJobsList.Add(';------------------ Tool List -------------------');
                                                End;
                                             If (Pos('JOBLIST',Upcase(TapFileData))>0) or(Pos('JOB LIST',Upcase(TapFileData))>0) or (Pos('CALL [SUBROUTINES]',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Jobline:=True;
                                                   Subroutine_Position:=OriginalLinenum;
                                                   If Machine<>'' then
                                                      Begin
                                                         TextColor(LightMagenta);
                                                         Writeln('Machine: ',Machine);

                                                         TextColor(LightCyan);
                                                         Writeln(#201,#205,#205,#205,#203,#205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,#203,#205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,#205,#205,#205,#205,#205,#187);
                                                         If Machine = 'Scout 5 Axis' Then
                                                            Write(#186,' 5 ',#186)
                                                         Else
                                                            Write(#186,' 3 ',#186);
                                                         TextColor(LightGreen);
                                                         Write(' Minimum Value ');
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(LightGreen);
                                                         Write(' Maximum Value ');
                                                         TextColor(LightCyan);
                                                         Writeln(#186);
                                                         Writeln(#204,#205,#205,#205,#206,#205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,#206,#205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,#205,#205,#205,#205,#205,#185);
                                                         Write(#186);
                                                         TextColor(LightMagenta);
                                                         Write(' X ');
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(Yellow);
                                                         Write(CenteredText(FloatToStrF(X_Limit_Neg, ffFixed,10, 3),15));
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(Yellow);
                                                         Write(CenteredText(FloatToStrF(X_Limit_Pos, ffFixed,10, 3),15));
                                                         TextColor(LightCyan);
                                                         Writeln(#186);
                                                         Write(#186);
                                                         TextColor(LightMagenta);
                                                         Write(' Y ');
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(Yellow);
                                                         Write(CenteredText(FloatToStrF(Y_Limit_Neg, ffFixed,10, 3),15));
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(Yellow);;
                                                         Write(CenteredText(FloatToStrF(Y_Limit_Pos, ffFixed,10, 3),15));
                                                         TextColor(LightCyan);
                                                         Writeln(#186);
                                                         Write(#186);
                                                         TextColor(LightMagenta);
                                                         Write(' Z ');
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(Yellow);
                                                         Write(CenteredText(FloatToStrF(Z_Limit_Neg, ffFixed,10, 3),15));
                                                         TextColor(LightCyan);
                                                         Write(#186);
                                                         TextColor(Yellow);;
                                                         Write(CenteredText(FloatToStrF(Z_Limit_Pos, ffFixed,10, 3),15));
                                                         TextColor(LightCyan);
                                                         Writeln(#186);
                                                         If Not(Isnan(A_Limit_Neg)) and Not(Isnan(A_Limit_Pos)) Then
                                                            Begin
                                                               Write(#186);
                                                               TextColor(LightMagenta);
                                                               Write(' A ');
                                                               TextColor(LightCyan);
                                                               Write(#186);
                                                               TextColor(Yellow);
                                                               Write(CenteredText(FloatToStrF(A_Limit_Neg, ffFixed,10, 3),15));
                                                               TextColor(LightCyan);
                                                               Write(#186);
                                                               TextColor(Yellow);;
                                                               Write(CenteredText(FloatToStrF(A_Limit_Pos, ffFixed,10, 3),15));
                                                               TextColor(LightCyan);
                                                               Writeln(#186);
                                                            End;
                                                         If Not(Isnan(C_Limit_Neg)) and Not(Isnan(C_Limit_Pos)) Then
                                                            Begin
                                                               Write(#186);
                                                               TextColor(LightMagenta);
                                                               Write(' C ');
                                                               TextColor(LightCyan);
                                                               Write(#186);
                                                               TextColor(Yellow);
                                                               Write(CenteredText(FloatToStrF(C_Limit_Neg, ffFixed,10, 3),15));
                                                               TextColor(LightCyan);
                                                               Write(#186);
                                                               TextColor(Yellow);;
                                                               Write(CenteredText(FloatToStrF(C_Limit_Pos, ffFixed,10, 3),15));
                                                               TextColor(LightCyan);
                                                               Writeln(#186);
                                                            End;
                                                         Writeln(#200,#205,#205,#205,#202,#205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,#202,#205,#205,#205,#205,#205,
                                                                           #205,#205,#205,#205,#205,#205,#205,#205,#205,#205,#188);
                                                         TextColor(Cyan);
                                                         Writeln('Job List');
                                                         TapFileHeaderActive:=False;
                                                         If (Pos('JOBLIST',Upcase(TapFileData))>0) Then
                                                               Begin
                                                                  If Pos('PROAUTO',Upcase(Machine))>0 Then
                                                                     TapFileJobsList.Add(';--------------- Job List ----------------');
                                                                  If (Machine='Scout 5 Axis') or (Machine='Onsrud') Then
                                                                     TapFileJobsList.Add('(---------- Job List -----------)');
                                                               End;
                                                         Jobsectionfound:=True;
                                                      End;
                                                End;

                                             If (Pos('[END]',Upcase(TapFileData))>0) or (Pos('(END)',Upcase(TapFileData))>0) or (Pos('M30',Upcase(TapFileData))>0) or (Pos('%',Upcase(TapFileData))>0) Then
                                                Begin
                                                   Writeln('end');
                                                   EndFound:=True;
                                                End;
                                             If Pos('JOB #',Upcase(TapFileData))>0 Then
                                                Begin
                                                   If JobErrorCount>0 then
                                                      Begin
                                                         ReportErrors;
                                                      End
                                                   else
                                                      If Jobcount>0 then
                                                         Writeln;
                                                   Inc(JobCount);
                                                   TextColor(Magenta);
                                                   Write(TapFileData,' ');  //write?
                                                   JobErrorCount:=0;
                                                   JobErrorLinenumber:=0;
                                                   JobErrorLine:='';
                                                   If Subroutines then
                                                      TapFileJobsList.Add('  Call '+TapFileData)
                                                   Else
                                                      Begin
                                                         If Pos('PROAUTO',Upcase(Machine))>0 Then
                                                            TapFileJobsList.Add('; '+TapFileData);
                                                         If (Machine='Scout 5 Axis') or (Machine='Onsrud') Then
                                                            TapFileJobsList.Add(TapFileData);
                                                      End;
                                                End;
                                             If Pos('&TOOL&',Upcase(TapFileData))>0 Then
                                                Begin
                                                   ToolPrefix:=Copy(TapFileData,1,Pos('&TOOL&',Upcase(TapFileData))-1);
                                                   ToolDescription:=Copy(TapFileData,Pos('&TOOL&',Upcase(TapFileData))+6,Length(TapFileData)-(Pos('&TOOL&',Upcase(TapFileData))+5));
                                                   //Writeln;
                                                   //Writeln('ToolPrefix: ',ToolPrefix,'  ',Pos('&TOOL&',Upcase(TapFileData)));
                                                   //Writeln('ToolDescription: ',ToolDescription);
                                                   Toolnumber:=0;
                                                   If ToolDescriptions.count >0 Then
                                                      Begin
                                                         For Toolnum:=1 to ToolDescriptions.count do
                                                            Begin
                                                               If ToolDescriptions[toolnum-1]=ToolDescription Then
                                                                  Begin
                                                                     Toolnumber:=toolnum;
                                                                     Break;
                                                                  End;
                                                            End;
                                                      End;
                                                   If Toolnumber = 0 Then
                                                      Begin
                                                         ToolDescriptions.Add(ToolDescription);
                                                         Toolnumber:=ToolDescriptions.count;
                                                         NewToolLine:=ToolPrefix+Inttostr(ToolNumber)+ToolDescription;
                                                         TapFileToolList.Add(NewToolLine);
                                                         TextColor(Magenta);
                                                         //Writeln(Newtoolline);
                                                      End;
                                                   TapFileData:=ToolPrefix+Inttostr(ToolNumber)+ToolDescription;
                                                End;
                                             If Pos('^',TapFileData)>0 Then
                                                Begin
                                                   Writeln('Tnum');
                                                   NewToolLine:='';
                                                   For toolnum:=1 to length(TapFileData) do
                                                      Begin
                                                         if TapFileData[Toolnum] = '^' then
                                                         Newtoolline+=Inttostr(Toolnumber)
                                                         Else
                                                         Newtoolline+=TapFileData[Toolnum];
                                                      End;
                                                   //Writeln(Newtoolline);
                                                   TapFileData:=NewToolLine;
                                                End;
                                             If not(Autoreplace) and (Pos('TAP FILE = ',Upcase(TapFileData))>0) Then
                                                Begin
                                                   //Writeln(Pos('TAP FILE = ',Upcase(TapFileData)));
                                                   OutputTapFileName:=Copy(TapFileData,Pos('TAP FILE = ',Upcase(TapFileData))+11,Length(TapFileData)-(Pos('TAP FILE = ',Upcase(TapFileData))+10));
                                                   Writeln('Saving to: '+OutputTapFileName);
                                                End
                                             Else
                                                Begin
                                                   If Not(Pos('CALL [SUBROUTINES]',Upcase(TapFileData))>0) and (TapFileData<>'SKIPIT') Then
                                                      Begin
                                                         If TapFileData = 'G0 Z12345' Then
                                                            Begin
                                                               TapFileData:='HEAD UP';
                                                            End;
                                                         Tapfilelist.Add(TapFileData);
                                                      End
                                                   Else
                                                      Dec(Originallinenum);
                                                End;
                                          End;
                                    End;
                              End;
                        End;
               If Not(NoJobs) and Not(CCDFound) then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                     Error_String:=Error_String+'CCD File not detected.'+#10+'     Check that Drawing is saved in .CCD Format.'+#10+'     Check that the START Job is activated.';
                     SHE_Error:=True;
                  End;
               If Not(NoJobs) and (ScriptFound>0) then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                        If ScriptFound = 1 Then
                           Error_String:=Error_String+' '+inttostr(ScriptFound) + ' Script Error detected.'+#10+'     Check that Drawing is saved in .CCD Format.'+#10+'     Check that SYMBOL TABLE is correct.'
                        else
                           Error_String:=Error_String+' '+inttostr(ScriptFound) + ' Script Errors detected.'+#10+'     Check that Drawing is saved in .CCD Format.'+#10+'     Check that SYMBOL TABLE is correct.';
                     SHE_Error:=True;
                  End;
               If Not(NoJobs) and (Custom_Variables_Not_Found>0) then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                        If Custom_Variables_Not_Found = 1 Then
                           Error_String:=Error_String+' '+inttostr(Custom_Variables_Not_Found) + ' Custom Variable Not detected.'+#10+'     Check that SYMBOL TABLE is correct.'
                        else
                           Error_String:=Error_String+' '+inttostr(Custom_Variables_Not_Found) + ' Custom Variables Not detected.'+#10+'     Check that SYMBOL TABLE is correct.';
                     SHE_Error:=True;
                  End;
               If Not(NoJobs) and (Machine='') then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                     Error_String:=Error_String+'Machine Type Not Defined.'+#10+'     Check that SYMBOL TABLE is correct.'+#10+'     Check that the START Job is activated.';
                     SHE_Error:=True;
                  End;
               If Not(NoJobs) and Not(Jobsectionfound)then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                     Error_String:=Error_String+'Job List not found.'+#10+'     Check that HEADER Job is activated.';
                     SHE_Error:=True;
                  End;
               If Not(NoJobs) and Not(EndFound) and not(subroutines) then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                     Error_String:=Error_String+'Program End not found.'+#10+'     Check that END Job is activated.';
                     SHE_Error:=True;
                  End;
               //Writeln(joberrorcount);
               If JobErrorCount>0 then
                  ReportErrors;
               If JobCount>1 then
                  Begin
                     TextColor(Yellow);
                     If Errorcount=0 then
                        Writeln;
                     Writeln(Jobcount,' Jobs Processed');
                     If Errorcount>0 then
                        Begin
                           TextColor(LightRed);
                           Writeln(ErrorCount,' Total Errors Found');
                        End
                     Else
                        Begin
                           TextColor(LightGreen);
                           Writeln('No Errors Found');
                        End
                  end;
               If Not(NoJObs) and (JobCount=0) then
                   Begin
                      If Error_String<>'' then
                         Error_String:=Error_String+#10;
                      Error_String:=Error_String+'No Jobs found'+#10+'     Check that at least one Job is activated before generating program';
                      J_Error:=True;
                   End;
               If NullG1 > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(NullG1,' Null G1 Lines Removed');
                  End;
               If Replace_G0_Previous_By_Angle_Count > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(Replace_G0_Previous_By_Angle_Count,' XY Angle Aligned Consecutive G0 Lines Removed - Angle Method');
                  End;
               If Replace_G0_Previous_By_Distance_Count > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(Replace_G0_Previous_By_Distance_Count,' XY Angle Aligned Consecutive G0 Lines Removed - Distance Method: ',SmallestLengthPerp:0:20,' ',LargestLengthPerp:0:20 );
                  End;
               If Replace_G1_Previous_By_Angle_Count > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(Replace_G1_Previous_By_Angle_Count,' XY Angle Aligned Consecutive G1 Lines Removed - Angle Method');
                  End;
               If Replace_G1_Previous_By_Distance_Count > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(Replace_G1_Previous_By_Distance_Count,' XY Angle Aligned Consecutive G1 Lines Removed - Distance Method: ',SmallestLengthPerp:0:20,' ',LargestLengthPerp:0:20 );
                  End;
               If Replace_G0_Z_Previous_By_Direction_Count > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(Replace_G0_Z_Previous_By_Direction_Count,' Z Direction Aligned Consecutive G0 Lines Removed');
                  End;
               If Replace_G1_Z_Previous_By_Direction_Count > 0 then
                  Begin
                     TextColor(LightRed);
                     Writeln(Replace_G1_Z_Previous_By_Direction_Count,' Z Direction Aligned Consecutive G1 Lines Removed');
                  End;
               TextColor(Yellow);
               Writeln(Originallinenum,' Lines Processed');
               //Writeln(errorfound);
               TextColor(LightCyan);
               Writeln(#201,#205,#205,#205,#203,#205,#205,#205,#205,#205,
                                   #205,#205,#205,#205,
                                   #205,#205,#205,#205,#205,#203,#205,#205,#205,#205,
                                   #205,#205,#205,#205,#205,#205,#205,#205,#205,#205,#187);
               If Machine = 'Scout 5 Axis' Then
                  Write(#186,' 5 ',#186)
               Else
                  Write(#186,' 3 ',#186);
               TextColor(Yellow);
               Write('   Minimum    ');
               TextColor(LightCyan);
               Write(#186);
               TextColor(Yellow);
               Write('   Maximum    ');
               TextColor(LightCyan);
               Writeln(#186);
               Writeln(#204,#205,#205,#205,#206,#205,#205,#205,#205,#205,
                                   #205,#205,#205,#205,
                                   #205,#205,#205,#205,#205,#206,#205,#205,#205,#205,
                                   #205,#205,#205,#205,#205,#205,#205,#205,#205,#205,#185);
               Write(#186);
               TextColor(LightMagenta);
               Write(' X ');
               TextColor(LightCyan);
               Write(#186);
               If Not(NoCheck) and (Xmin<X_Limit_Neg) Then
                  TextColor(LightRed)
               Else
                  TextColor(LightGreen);
               Write(CenteredText(FloatToStrF(XMin, ffFixed,10, 3),14));
               TextColor(LightCyan);
               Write(#186);
               If Not(NoCheck) and (Xmax>X_Limit_Pos) Then
                  TextColor(LightRed)
               Else
                  TextColor(LightGreen);
               Write(CenteredText(FloatToStrF(XMax, ffFixed,10, 3),14));
               TextColor(LightCyan);
               Writeln(#186);
               Write(#186);
               TextColor(LightMagenta);
               Write(' Y ');
               TextColor(LightCyan);
               Write(#186);
               If Not(NoCheck) and (Ymin<Y_Limit_Neg) Then
                  TextColor(LightRed)
               Else
                  TextColor(LightGreen);
               Write(CenteredText(FloatToStrF(YMin, ffFixed,10, 3),14));
               TextColor(LightCyan);
               Write(#186);
               If Not(NoCheck) and (Ymax>Y_Limit_Pos) Then
                  TextColor(LightRed)
               Else
                  TextColor(LightGreen);;
               Write(CenteredText(FloatToStrF(YMax, ffFixed,10, 3),14));
               TextColor(LightCyan);
               Writeln(#186);
               Write(#186);
               TextColor(LightMagenta);
               Write(' Z ');
               TextColor(LightCyan);
               Write(#186);
               If Not(NoCheck) and (Zmin<Z_Limit_Neg) Then
                  TextColor(LightRed)
               Else
                  TextColor(LightGreen);
               Write(CenteredText(FloatToStrF(ZMin, ffFixed,10, 3),14));
               TextColor(LightCyan);
               Write(#186);
               If Not(NoCheck) and (Zmax>Z_Limit_Pos) Then
                  TextColor(LightRed)
               Else
                  TextColor(LightGreen);;
               Write(CenteredText(FloatToStrF(ZMax, ffFixed,10, 3),14));
               TextColor(LightCyan);
               Writeln(#186);

               If Not(isNan(SMin)) Then
                  Begin
                     Write(#186);
                     TextColor(LightMagenta);
                     Write(' S ');
                     TextColor(LightCyan);
                     Write(#186);
                     If Smin<S_Limit_Neg Then
                        TextColor(LightRed)
                     Else
                        TextColor(LightGreen);
                     Write(CenteredText(FloatToStrF(SMin, ffFixed,10, 3),14));
                     TextColor(LightCyan);
                     Write(#186);
                     If Smax>S_Limit_Pos Then
                        TextColor(LightRed)
                     Else
                        TextColor(LightGreen);;
                     Write(CenteredText(FloatToStrF(SMax, ffFixed,10, 3),14));
                     TextColor(LightCyan);
                     Writeln(#186);
                  End;


               If Not(Isnan(A_Limit_Neg)) and Not(Isnan(A_Limit_Pos)) Then
                  Begin
                     Write(#186);
                     TextColor(LightMagenta);
                     Write(' A ');
                     TextColor(LightCyan);
                     Write(#186);
                     If Not(NoCheck) and (Amin<A_Limit_Neg) Then
                        TextColor(LightRed)
                     Else
                        TextColor(LightGreen);
                     Write(CenteredText(FloatToStrF(AMin, ffFixed,10, 3),14));
                     TextColor(LightCyan);
                     Write(#186);
                     If Not(NoCheck) and (Amax>A_Limit_Pos) Then
                        TextColor(LightRed)
                     Else
                        TextColor(LightGreen);;
                     Write(CenteredText(FloatToStrF(AMax, ffFixed,10, 3),14));
                     TextColor(LightCyan);
                     Writeln(#186);
                  End;
               If Not(Isnan(C_Limit_Neg)) and Not(Isnan(C_Limit_Pos)) Then
                  Begin
                     Write(#186);
                     TextColor(LightMagenta);
                     Write(' C ');
                     TextColor(LightCyan);
                     Write(#186);
                     If Not(NoCheck) and (Cmin<C_Limit_Neg) Then
                        TextColor(LightRed)
                     Else
                        TextColor(LightGreen);
                     Write(CenteredText(FloatToStrF(CMin, ffFixed,10, 3),14));
                     TextColor(LightCyan);
                     Write(#186);
                     If Not(NoCheck) and (Cmax>C_Limit_Pos) Then
                        TextColor(LightRed)
                     Else
                        TextColor(LightGreen);;
                     Write(CenteredText(FloatToStrF(CMax, ffFixed,10, 3),14));
                     TextColor(LightCyan);
                     Writeln(#186);
                  End;
               Writeln(#200,#205,#205,#205,#202,#205,#205,#205,#205,#205,
                       #205,#205,#205,#205,
                       #205,#205,#205,#205,#205,#202,#205,#205,#205,#205,
                       #205,#205,#205,#205,#205,#205,#205,#205,#205,#205,#188);
               //windows.messagebox(0,pchar('X Axis:  '+FloatToStrF(XMin, ffFixed,7, 3)+'   To '+FloatToStrF(XMax, ffFixed,7, 3)+#10+
               //                           'Y Axis:  '+FloatToStrF(YMin, ffFixed,7, 3)+'   To '+FloatToStrF(YMax, ffFixed,7, 3)+#10+
               //                           'Z Axis:  '+FloatToStrF(ZMin, ffFixed,7, 3)+'   To '+FloatToStrF(ZMax, ffFixed,7, 3)+#10),pchar('Boundaries'),MB_OK);
               //writeln(derrorcount);
               If DErrorcount >0 Then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                     If DErrorcount=1 then
                        Error_String:=Error_String+'1 Missing Decimal Point Error'
                     Else
                        Error_String:=Error_String+Inttostr(DErrorCount)+' Missing Decimal Point Errors';
                     Error_String:=Error_String+' Found.'+#10+'     Check for missing decimal points in coordinates.'+#10+'     First Line with missing decimal point: '+Inttostr(DErrorlinenum)+#10+'     '+Derrorline;
                  End;
               If Errorfound Then
                  Begin
                     If Error_String<>'' then
                        Error_String:=Error_String+#10;
                     If Errorcount=1 then
                        Error_String:=Error_String+'1 Coordinate Error'
                     Else
                        Error_String:=Error_String+Inttostr(ErrorCount)+' Coordinate Errors';
                     Error_String:=Error_String+' Found.'+#10+'     Check Minimum and Maximum values in chart.'+#10+'     Check boundaries of all tool paths are in range for the machine.'+#10+
                                                '     Check Location of Axis in Drawing.'+#10+'     Check Part Origin Variables are Correct.';
                  End;
               If SHE_Error Or J_Error or ErrorFound or (Derrorcount>0) then
                  Begin
                     If SHE_Error then
                        Error_String:=Error_String+#10+#10+'Note:'+#10+'     Non-Vectorcam Files will be missing the'+#10+'     Symbol Table and several Macros and'+#10+'     will not generate correctly.'+#10+
                                                           '     copy and paste the drawing to a New Vectorcam drawing'+#10+'     and save it as a .CCD File.';
                     windows.messagebox(0,pchar(Error_String),pchar('Error'),MB_OK);
                     Halt(70);
                  End
               Else
                  Begin
             //        If (TapFileJobsList.count>0) and Not(Subroutines) then
             //           Begin
             //              If Pos('PROAUTO',Upcase(Machine))>0 Then
             //                 TapFileJobsList.Add(';----------------------------------------- ');
             //              If (Machine='Scout 5 Axis') or (Machine='Onsrud') then
             //                 TapFileJobsList.Add('(-------------------------------)');
             //           End;
             //        If (TapFileToolList.Count>0) then
             //           Begin
             //              If Pos('PROAUTO',Upcase(Machine))>0 Then
             //                 TapFileToolList.Add(';----------------------------------------- ');
             //              If (Machine='Scout 5 Axis') or (Machine='Onsrud') then
             //                 TapFileToolList.Add('(-------------------------------)');
             //           End;

                              If (ScoutFoam_Position>0) Then
                                 Begin
                                    TextColor(LightRed);
                                    Writeln('Select Material');
                                    For N := 65 to 65+Number_Of_Profiles-1 do
                                       Begin
                                          TextColor(LightGreen);
                                          Write(Chr(N)+': ');
                                          TextColor(Yellow);
                                          Writeln(Profile[N]);
                                       End;
                                    TextColor(LightMagenta); Write('Selection? ');
                                    Repeat
                                       If Keypressed then
                                          Menu_Selection:=Upcase(readkey)
                                       Else
                                          Sleep(100);
                                    Until (Menu_Selection>= CHR(65)) and (Menu_Selection<=CHR(65+Number_Of_Profiles-1));
                                    TextColor(LightCyan);
                                    Write (Menu_Selection+' ');
                                    TextColor(White);
                                    //Writeln(ORD(Menu_Selection));
                                    Writeln(Profile[ORD(Menu_Selection)]);
                                 End;
                     If Not(Autosave) Or Not(AutoReplace) Or (OutputTapFileName='') Then
                        Begin
                           fillchar(SaveAsFileName, sizeof(SaveAsFileName), 0);
                           SaveAsFileName.lStructSize:=sizeof(SaveAsFileName);
                           SaveAsFileName.hwndOwner:=0;
                           SaveAsFileName.nMaxFile:=Max_Path+1;
                           SaveAsFileName.Flags := OFN_EXPLORER ;
                           SaveAsFileName.lpstrDefExt:='';
                           If Pos('PROAUTO',Upcase(Machine))>0 Then
                              Begin
                                 SaveAsFileName.lpstrTitle:='Production Automation Jobs - Save File As:';
                                 SaveAsFileName.lpstrFilter:='TAP Files (*.Tap)'+#0+'*.Tap'+#0+'All Files (*.*)'+#0+'*.*'+#0;
//                                 Writeln(OutputTapFileName,' ',Length(OutputTapFileName));
                                 If OutputTapFileName<>'' then
                                    Begin
                                       SaveAsFileNameBuffer:=Pchar(OutputTapFileName);
                                       SaveAsFileName.lpstrFile:=SaveAsFileNameBuffer;
                                    End;
//                                 Writeln(SaveAsFileName.lpstrFile);
//                                 Writeln(SaveAsFileName.nMaxFile);
                              End;
                           If Machine = 'Scout 5 Axis' Then
                              Begin
                                 SaveAsFileName.lpstrTitle:='5 Axis Jobs - Save File As:';
                                 SaveAsFileName.lpstrFilter:='No Extention TAP Files (O*.)'+#0+'O*.*'+#0+'All Files (*.*)'+#0+'*.*'+#0;
                                 SaveAsFileNameBuffer:=Pchar(ExtractFilePath(OutputTapFileName)+FindhighestONumber(ExtractFilePath(OutputTapFileName))+#0);
                                 SaveAsFileName.lpstrFile:=SaveAsFileNameBuffer;
                              End;
                           If Machine = 'Onsrud' Then
                              Begin
                                 SaveAsFileName.lpstrTitle:='Onsrud Jobs - Save File As:';
                                 SaveAsFileName.lpstrFilter:='ANC Files (*.anc)'+#0+'*.anc'+#0+'All Files (*.*)'+#0+'*.*'+#0;
                                 If OutputTapFileName<>'' then
                                    Begin
                                       SaveAsFileNameBuffer:=Pchar(OutputTapFileName);
                                       SaveAsFileName.lpstrFile:=SaveAsFileNameBuffer;
                                    End;
                              End;
                           Repeat
                              FileOKtoSave:=False;
                              SaveAsResult:=GetSaveFileNameA(@SaveAsFileName);
                              If SaveasResult and FileExists(strpas(SaveAsFileName.lpstrFile)) Then
                                 Begin
                                    MessageBoxResult:=windows.messagebox(0,pchar(strpas(SaveAsFileName.lpstrFile)+#10+'Already Exists, Overwrite?'),pchar('Warning'),MB_YesNoCancel);
                                    //Writeln(MessageBoxResult);
                                    If MessageBoxResult=6 then
                                       FileOKtoSave:=True;
                                    If MessageBoxResult=2 then
                                       SaveAsResult:=False;
                                 End
                              Else
                                 FileOKtoSave:=True;
                           Until Not(SaveAsResult) Or FileOKtoSave;
                           If SaveAsResult and FileOktoSave then
                              Begin
                                 OutputTapFileName:= StrPas(SaveAsFileName.lpstrFile);
                              End
                           Else
                              Begin
                                 OutputTapFileName:='';
                                 Halt(100);
                              End;
                        End;
                     If OutputTapFileName<>'' Then
                        Begin
                           TextColor(LightRed);
                           Writeln('DO NOT EXIT WHILE THE FILE IS BEING SAVED!!');
                           EnableMenuItem(Console_hmenu, SC_CLOSE, MF_GRAYED);
                           TextColor(LightCyan);
                           Writeln('Writing ',TapFileList.count+TapFileJobsList.count+TapFileToolList.count,' Lines to: '+OutputTapFileName);
                           Assign(TapFile,OutputTapFileName);
                           ReWrite(TapFile);
//                           If TapFileHeader.count >= 1 then
//                           For StringCount:=0 to TapFileHeader.count-1 do
//                              Writeln(TapFile,TapFileHeader[StringCount]);
//                           If TapFileJobsList.count >= 1 then
//                           For StringCount:=0 to TapFileJobsList.count-1 do
//                              Writeln(TapFile,TapFileJobsList[StringCount]);
//                           If TapFileRemainder.count >= 1 then
//                           For StringCount:=0 to TapFileRemainder.count-1 do
//                              Writeln(TapFile,TapFileRemainder[StringCount]);
                           Outcount:=0;
                           Repeat

                              If (ScoutFoam_Position>0) And (Outcount = ScoutFoam_Position-1) Then
                                 Begin
                                    If (Menu_Selection>= CHR(65)) and (Menu_Selection<=CHR(65+Number_Of_Profiles-1)) Then
                                       Begin
                                          Writeln(TapFile,'  Call [Define Material]');
                                          Writeln(TapFile,'  Material Type = '+Profile[ORD(Menu_Selection)]);
                                       End;
                                 End
                              Else
                              If (ToolList_Position>0) And (Outcount = ToolList_Position-1) Then
                                 For StringCount:=0 to TapFileToolList.count-1 do
                                    Writeln(TapFile,TapFileToolList[StringCount])
                              Else
                              If (Subroutine_Position>0) And (Outcount = Subroutine_Position-2) Then
                                 For StringCount:=0 to TapFileJobsList.count-1 do
                                    Writeln(TapFile,TapFileJobsList[StringCount]);
                              Writeln(TapFile,TapFilelist[OutCount]);
                              Inc(OutCount);
                           Until Outcount>=TapFilelist.count;
                           If (Menu_Selection>= CHR(65)) and (Menu_Selection<=CHR(65+Number_Of_Profiles-1)) Then
                              Writeln(TapFile,'Load ['+Pro_Load[ORD(Menu_Selection)]+']');
                           Close(TapFile);
                           If RunProMill Then
                              Begin
                                 ProgProcess := TProcess.Create(nil);
                                 ProgProcess.Executable := 'R:\Proauto\Draw.Bat';
                                 ProgProcess.Parameters.Add(OutputTapFileName);
                                 ProgProcess.Options := ProgProcess.Options + [poWaitOnExit];
                                 ProgProcess.Execute;
                                 ProgProcess.Free;
                              End;
                        End
                     Else
                        Begin
                           windows.messagebox(0,pchar('No Output Tap File Specified in Program'),pchar('Error'),MB_OK);
                        End;
                  End;
               Tapfilelist.Free;
               TapfileToolList.Free;
               TapfileJobsList.Free;
               ToolDescriptions.Free;
            End
         Else
            Begin
               windows.messagebox(0,pchar(TapFileName+' Not Found'),pchar('Error'),MB_OK);
            End;
      End
   Else
      Begin
         windows.messagebox(0,pchar('No Parameters found'+#10+'No File Name Specified'),pchar('Error'),MB_OK);
      End;
End.
