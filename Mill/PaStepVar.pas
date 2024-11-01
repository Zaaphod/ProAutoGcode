Unit PaStepVar;
{$Mode OBJFPC}

Interface
Uses
   classes,Process,Sysutils,IniFiles,Pro_Math,mimemess,mimepart,smtpsend;

Const
   Test=True;
   MajorVersion=9;
   MinorVersion=4;
   LetterVersion='C';

type
{  Params = Record
      X_pos:ShortInt;
      Y_Pos:ShortInt;
      EA:ShortInt;
      Parameter:String[20];
      P_Value:String[20];
      P_Range0:Single;
      P_Range1:Single;
     End;}
   TStringListHelper = class helper for TStringList
      function High: NativeInt;
   end;
   TStringsHelper = class helper for TStrings
      function High: NativeInt;
   end;

   DrawCMD = Record  //Duplite DrawCMD from agg_pro.  If AGG_Pro ever needs this then remove it from there
                LN: LongInt;
                GC: Byte;
                PX,PY,PZ,GX,GY,GZ,GI,GJ,R,SA,EA:Double;
             End;


   Fxed = String;      {file data}

   MathCMD      = Record
                     Variable:AnsiString;
                     Formula:AnsiString;
                     cmdnum:QWord;
                  End;

   WhenCMD      = Record
                     XTarget,YTarget,ZTarget,ATarget,BTarget,CTarget:Double;
                     GreaterThan:Boolean;
                     HasRun:Boolean;
                     Variable:AnsiString;
                     Formula:AnsiString;
                  End;

   LabelCMD     = Record
                     GCodeName: AnsiString;
                     Name: AnsiString;
                     cmdnum:Qword;
                     Programnum:QWord;
                  End;
   DISPLAYCMD   = Record
                     Linenum: Qword;
                     Orig: String;
                     GType: Char;
                     Err:Integer;
                  End;
   MotionCMD    = Record
                    {Orig: String[40];}
                     GType: Char;
                     DispNum:QWord;
                     GNUM,MNUM:Word;
                     VERBOSE,PARAMVALUE,
                     XMotion,YMotion,ZMotion,WMotion,RMotion,AMotion,BMotion,CMotion,
                     ICenter,JCenter,KCenter,X_Psn,Y_Psn,
                     DrillEnd,DrillClear,DrillIncrement,DrillThreadsPerInch,
                     FeedValue,OtherValue,PreviousValue,PowerValue:String;
                     Head2Use:String;
                     EOL:Char;
                  End;

   Zone_Record = Record
      X_Offset    : Double;
      Y_Offset    : Double;
      Z_Offset    : Double;
      X_Park      : Double;
      Y_Park      : Double;
      X_Min       : Double;
      Y_Min       : Double;
      X_Max       : Double;
      Y_Max       : Double;
      Color       : Word;
   End;

   Tool_Record = Record
      X_Unload    :Double;
      Y_Unload    :Double;
      Z_Unload    :Double;
      X_Unload_2  :Double;
      Y_Unload_2  :Double;
      Z_Unload_2  :Double;
      X_Load      :Double;
      Y_Load      :Double;
      Z_Load      :Double;
      X_Load_2    :Double;
      Y_Load_2    :Double;
      Z_Load_2    :Double;
   End;
   Tool_String_Record = Record
      X_Unload    :String;
      Y_Unload    :String;
      Z_Unload    :String;
      X_Unload_2  :String;
      Y_Unload_2  :String;
      Z_Unload_2  :String;
      X_Load      :String;
      Y_Load      :String;
      Z_Load      :String;
      X_Load_2    :String;
      Y_Load_2    :String;
      Z_Load_2    :String;
   End;

   Double_3D_Point = Record
      X,Y,Z:Double;
   End;
   
   Double_2D_Point = Record
      X,Y:Double;
   End;


   Axis_Double_Record = Record
      XY,X,Y,Z,W,A,B,C,L,R,V,U,T,Five,Five_Y,S,Dot,Cross:Double;
   End;

   Head_Double_Record = Record
      Z,W,L,R,V,U,T,Five,S,Dot,Cross:Double;
   End;

   Head_String_Record = Record
      Z,W,L,R,V,U,T,Five,S,Dot,Cross:AnsiString;
   End;

   Axis_Pin_Record = Record
      X,Y,Z,W,A,B,C,L,R,V,U,T,Five,Five_Y,S,Dot,Cross:Integer;
   End;

   Axis_String_Record = Record
      X,Y,Z,W,A,B,C,L,R,V,U,T,Five,F,S,Dot,Cross:AnsiString;
   End;

   Axis_Boolean_Record = Record
      X,Y,Z,W,A,B,C,L,R,V,U,T,Five,WL,S,Dot,Cross:Boolean;
   End;

   XYZ_Record = Record
      X,Y,Z : Double
   End;

   MTS_Record = record
      Port             :AnsiString;
      Clock_Positive   :Byte;
      Clock_Negative   :Byte;
      Data             :Byte;
      Scale            :Double;
      Offset           :Double;
   End;

   MNet_Record  = Record
      Machine   :AnsiString;
      Network   :AnsiString;
   End;

   Modbus_Config_Record  = Record
      Connection                 :AnsiString;
      BaudRate                   :DWord;
      Parity_DataBits_Stopbits   :AnsiString;
   End;

   Port_Record = Record
      Variable_Name         : AnsiString;
      Port_Number           : AnsiString;
      Port                  : AnsiString;
      Unit_ID               : Byte;
      Device                : AnsiString;
      Port_Storage_Location : Byte;
      Pin_Number            : Integer;
      Out_Pin               : Boolean;
      State                 : Boolean;
   End;

   Port_Storage_Record = Record
      Port_Number : AnsiString;
      Data0   : Word;
      Data1   : Byte;
      Data2   : Byte;
   End;

   Call_Stack_Record = Record
      Name     : AnsiString;
      Location : QWord;
      Offset   : XYZ_Record;
      Scale    : XYZ_Record;
      Rotation : Double;
   End;
   
   TLimitArray = array [1..2,1..10] Of DWord;

//type {Infix}
   //String = AnsiString;                 {Store Variable IDs this way To conserve}
   VariablePtr = ^VariableType;        {For dynamic allocation Of Records }
   VariableType = Record
      ID    : AnsiString;               {the id Of the Variable, with @s   }
      Value : Double;                   {the current value Of the Variable }
      Next  : VariablePtr;              {hook To next Record in linked list}
   End; {VariableType}
   VariableStringPtr = ^VariableStringType;        {For dynamic allocation Of Records }
   VariableStringType = Record
      ID    : AnsiString;                   {the id Of the Variable, with @s   }
      Value : AnsiString;                   {the current value Of the Variable }
      Next  : VariableStringPtr;            {hook To next Record in linked list}
   End; {VariableStringType}

Const
   SmoothieGcodeDetails = False;
   JRHidden = faHidden;
   M400detail  = False;
   X_Axis        = 1001;
   Y_Axis        = 1002;
   Z_Axis        = 1003;
   W_Axis        = 1004;
   L_Axis        = 1005;
   R_Axis        = 1006;
   A_Axis        = 1007;
   B_Axis        = 1008;
   C_Axis        = 1009;
   Feed          = 1010;
   WL_Axis       = 1011;
   Dot_Head      = 1012;
   Cross_Head    = 1013;
   S_Head        = 1014;
   T_Head        = 1015;
   U_Head        = 1016;
   V_Head        = 1017;
   Five_Head     = 1018;
   Calculat      = 1019;
   Variable      = 1020;
   Manual_Gcode  = 1021;
   Manual_Serial = 1022;
   MultiSpeed    = 1023;
   P_File        = 1024;
   P_Time        = 1025;
   P_Head_Tool   = 1026;
   P_Zone        = 1027;
   SpoilBoard    = 1028;
   ChangeLog     = 1029;
   XORYOffset    = 1030;
   BallGraph     = 1040;

   Axis_X=0;
   Axis_Y=1;
   Axis_Z=2;
   Head_Z=2;
   Axis_A=3;
   Axis_B=4;
   Axis_C=5;
   Head_L=3;
   Head_W=3;
   Head_R=4;
   Head_T=5;
   Head_U=6;
   Head_V=7;
   Head_Five=8;
   Head_S=9;
   Head_Dot=10;
   Head_Cross=11;
   Head_ZW=12;
   Cut=13;
   Draw=14;
   Tot=15;
   Minimum=0;
   Maximum=1;


   CM_Black        = Chr($E0);  //0
   CM_Blue         = Chr($E1);  //1
   CM_Green        = Chr($E2);  //2
   CM_Cyan         = Chr($E3);  //3
   CM_Red          = Chr($E4);  //4
   CM_Magenta      = Chr($E5);  //5
   CM_Brown        = Chr($E6);  //6
   CM_LightGray    = Chr($E7);  //7
   CM_DarkGray     = Chr($E8);  //8
   CM_LightBlue    = Chr($E9);  //9
   CM_LightGreen   = Chr($EA);  //10
   CM_LightCyan    = Chr($EB);  //11
   CM_LightRed     = Chr($EC);  //12
   CM_LightMagenta = Chr($ED);  //13
   CM_Yellow       = Chr($EE);  //14
   CM_White        = Chr($EF);  //15
   C1_Black        = Chr($D0);  //0
   C1_Blue         = Chr($D1);  //1
   C1_Green        = Chr($D2);  //2
   C1_Cyan         = Chr($D3);  //3
   C1_Red          = Chr($D4);  //4
   C1_Magenta      = Chr($D5);  //5
   C1_Brown        = Chr($D6);  //6
   C1_LightGray    = Chr($D7);  //7
   C1_DarkGray     = Chr($D8);  //8
   C1_LightBlue    = Chr($D9);  //9
   C1_LightGreen   = Chr($DA);  //10
   C1_LightCyan    = Chr($DB);  //11
   C1_LightRed     = Chr($DC);  //12
   C1_LightMagenta = Chr($DD);  //13
   C1_Yellow       = Chr($DE);  //14
   C1_White        = Chr($DF);  //15

           A_Day = 1;
         An_Hour = A_Day/24;
        A_Minute = An_Hour/60;
        A_Second = A_Minute/60;
   A_Millisecond = A_Second/1000;
   A_Microsecond = A_Millisecond/1000;
    A_Nanosecond = A_Microsecond/1000;
    A_Picosecond = A_Nanosecond/1000;

   Time2Edit=5*A_Second{(1/24/60/60)};      //5 Seconds
   BisC = True;
   
   bgcolor='<body bgcolor="#000000">';{black}
   ftextcolor='<font color="springgreen">';
   fred='<font color="red">';
   fyellow='<font color="Gold">';
   fGreen='<font color="lime">';
   fpurple='<font color="darkviolet">';
   fmagenta='<font color="magenta">';
   fcyan='<font color="cyan">';
   fcyan2='<font color="deepskyblue">';
   fblue='<font color="steelblue">';
   fwhite='<font color="snow">';
   fbr='</font><br>';
   br='<br>';
   sf='</font>';

Var
   mime,cusmime                                    : Tmimemess;
   P,CP                                            : TMimePart;

   TheHead :Integer;
   End_Of_Display_Parameters : Integer = 1027;
   Preload_StringList                        : TStringList;
   Originalformula                           : AnsiString;
   ProgProcess                               : TProcess;
//Var {Infix}
   HPtr,                               {head Of Variable list       }
   TPtr,                               {tail Of Variable list       }
   SPtr  : VariablePtr;                {used To search Variable list}
   HSPtr,                              {head Of Variable list       }
   TSPtr,                              {tail Of Variable list       }
   SSPtr  : VariableStringPtr;         {used To search Variable list}
   CalcError : Integer;                {the position Of the Error   }
   edittime                                           : Double;

   MathArray                                         : Array of MathCMD;
   WhenArray                                         : Array of WhenCMD;
   LabelArray                                        : Array of LabelCMD;
   displayfile                                       : File Of displayCMD;
   DrawArray                                         : Array Of DrawCMD;
   drawfile                                          : File Of drawCMD;
   motionfile                                        : File Of MotionCMD;
   NetStatusFile                                     : File Of Char;
   serverprogfile                                    : Text;
   DispRec,TempDispRec,TemPorthoD,Empty_Disp         : DisplayCMD;
   GcodeRec,Drillsaverec,Gcodeoriginal,TempGcodeRec,TemPorthoM,Empty_Record,Load_XY     : MotionCMD;
   Math_info                                         : MathCMD;
   CustomIONames                                     : Array Of AnsiString;
   MarkChar                :Char = #0;
   Custom_Port             :AnsiString;
   Custom_Modbus_Unit_ID   :Integer;
   Custom_Modbus_Device    :AnsiString;
   Custom_Pin              :Integer;
   CustomNameFound         :Boolean;
   
   
   
   
   PreviousNumberLoad:Word;

   STLFile                                           : File Of String;
   stl999                                            : String;
   MTSSaveData                                       : Array [1..10] of Double;
   X_pos,Y_Pos,EA                                    : Array [X_Axis..BallGraph] Of ShortInt;
   Parameter,P_Value                                 : Array [X_Axis..BallGraph] Of String;
   P_Range                                           : Array [X_Axis..BallGraph,0..1] Of Single;
   oldbignumaLipse                                   : Array [X_Axis..BallGraph] Of AnsiString;
   LoadOldPos                                        : Array [0..100] Of QWord;
   loaDoldname                                       : Array [0..100] Of AnsiString;
   LoadFileNameStingList                             : TStringList;
   Tooladj                                           : Array [0..101] Of Double;
   FanOffTime                                        :  Head_Double_Record;
   Ini_Probe_Tool_Set_Rapid                          :  Head_Double_Record;
   ARROWARRAY                                        : Array [X_Axis..Feed,0..1] Of Byte;
//   XOffsetcxy,YOffsetcxy,ZOffsetcxy,RotationCXY      : Array [0..255] Of Double;
//   Callstk                                           : Array [1..255] Of LongInt;
   Call_Stack                                        : Array of Call_Stack_Record;
   Call_Stack_History                                : Array of Call_Stack_Record;
   SerialQueue                                       : Array [0..63] Of AnsiString;
   SerialQueueLoctn                                  : Array [0..63] Of QWord;
   SQ_Start,SQ_End,Items_In_Q                        : Byte;
   CommandRecall                                     : Array [Calculat..Manual_Serial,0..63] Of AnsiString;
   CRStart,CommandMax,CommandCount,CommandPosition   : Array [Calculat..Manual_Serial] Of Byte;
   stl                                               : Array [0..200] of String;
   Test_Input_Registers:Word;
   MyFile:AnsiString;
   Material_Bounds: Array[0..2,0..1] of Double;
   Disable_Axis: Axis_Boolean_Record;
   DrawWithwWaits,DNU,SetSpeedsFound,DisableDrawOnlyCancel,SmoothieWasReset,Ready_For_Pendant,AutoResetAlarm,DisableErrorListPrompt :Boolean;
   KneeStart,RADrawText:Double;
   Duplicate_Label_Line:Dword;
   New_Label_Name:AnsiString;
   Process_Errors:Text;
   DNUText:AnsiString;
   PreDrawOnlyPx,PreDrawOnlyPy,PreDrawOnlyPz:Double;
   GCode_Wasnt_DrawOnly,G0OutOfRange,OutofBounds,outofmaterial,CutsOutsideMaterial,DisableDrawCount,IgnoreRange,
   CheckBoundaries,CheckRunBoundaries,CheckArcBoundaries:Boolean;
   FilesLoaded, OldFilesLoaded, Programnumber        : DWord;
   Text_Letter_Style,Last_Label_Index:Word;
   DigiString:FXED;
   Spindle_Cooldown_Time: TDateTime;
   doingisnan,nanok,Remove_temp_Commments,Warmup_Due:Boolean;
   Displayout:displaycmd;
   DigIfile,digifile2: text;
   pausekey:Char;
   Old_Tap_Drive,Old_Tap_SubDirectory,Old_Tap_Path,Old_Filename,temp_string,Preload_Extension:AnsiString;
   Old_Tap_Files_Only,Old_Use_Default_Tap_Drive,Old_Use_Default_Tap_Directory, temp_bool,DISABLESTOPERROR,F_Mode:Boolean;
   showallDone ,Paused,DoNotInterupt,RUNONCE,StoreSystemVariable:Boolean;
   MathFunctionBitMask : QWORD;
   showallXPtr,ShowallMPtr : VariablePtr;
   showallStringXPtr,ShowallStringMPtr : VariableStringPtr;
   WaitN  : byte;
   Idlecheck,IdleFixSav,Runnigcheck,H_Toggle,L_Toggle,Stepovercomments,somethingtowaitfor,Show_hidden,Always_Show_hidden,Labelfound: Boolean;
   H_savold,L_savold: Double;
   Graphflutecolor,Ellipse_Space,Max_Coord_Y,Idletimebeforesendingmail:Word;
   Sillyballs,MaterialSet:Boolean;
   DrawPX,DrawPY,DrawPZ,Draw_Resolution,
   MaterialsizeX,materialsizey,materialthickness,
   materialoffx,materialoffy,
   Vacuum_On_Time,
   Vacuum_Off_Time,
   Dust_Collector_Off_Time,
   Air_Purge_Off_Time,
   Laser_Fan_Off_Time,
   Head_Light_Off_Time,
   NotificationStartTime,PreloadStartTime,StartSwitchStartTime:double;
   Consolog:Text;
   Networkstatus:char;
   debugmode,Ackalarm,CXYSCale,Drawit,simulateit,showpreloadfiledetails,movearrowinit: Boolean;
   PreloadNow,usefulldouble: Boolean;
   loopswithoutposition,Bitnum   :  Byte;
   CheckStatus,Checkstatus2,Promillmd5,stldatmd5,FileChecking,PreLoad_File_Parameter,Preload_Extract_Directory,Preload_Extract_Path,
   Preload_Relative_Path_From_Default,Preload_Relative_Path_From_Last_Used,Preload_Tap_Drive,preloadfilename,Current_Loaded_File,Loaded_File,Preloaded_File,Preload_SubDirectory,Prog_Drive,Prog_Path,Prog_dir,
   Vector_Filename,OldFeed:AnsiString;
   Mathline,mathline2:ANSIString;
   Checkloop,prtoffset,Longest_PR_Line:Word;
   animatedelay,LastLimitchecktime:Double;
   Fileage_Current_Loaded_File:Longint;
   LimitWord,LimitNewWord,LimitTempWord:QWord;
   mailmessage                  : tstringList;
   stderrorwrite :Ansistring;
   emailtest,Already_Stopping:Boolean;
   CountCommands:  Word;
   NewLimitStarttime,Current_ToolAdj,StartSpindletime:Double;
   Last_SMOO,Q_X,Q_Y,Q_Z,Q_W,Q_R,savezone2,keycode,keycode2,keyhex,LastN_Cksm,LoctnStr,GendStr,PvalueP_FileExt,old_FileExt  : AnsiString;
   headef,PrevHeadef,Prev_State,NormalStatLine,idlecount,Keybyte,Comcheckcount                                              : Byte;
   Homeing,Homezing,ForceStatline,reloaditagain,ManualGcode,DefaultsProcessed,Getpositiondone,M400Waiting,manualmove : Boolean;
   Going,SpStarted :Boolean;
   previousstatline:Integer;
   STIM,ETIM,TotTime,stepCount,DoSTIMe,DeBounce:LongInt;
   key2,Feedaxis:Char;
   LoadRunOnly,esTop,CPLD_Moving,Prevshowunexp:Boolean;
   ensave:Word;
   LoopCount:Byte;
   spdle,OldSpindleSpeed:integer;
   PreviousSpindleSpeed:String;
   Preld:Boolean;
   Spindlewait,multi_speed,Jog_Incr,Ynum_X:Byte;
   preloadzone,Save_Variable_Name:AnsiString;
   Current_Tool1,Current_Tool:ShortInt;
   fastswap:ShortInt;
   SwapCurrent,Current_Head:String;
   Loctn,M_Num,PrevContourStart,Lastcompletedloctn,Scrol,Max_Que_Mem:LongInt;
   drilltype:ShortInt;
   QENABLE,cusTommessage:Boolean;
   stopmode:Byte;
   Demo:Integer;
   X_Center,Y_Center,Z_Center,W_Center,JogA,InspectA,Inspeed,
   incjogs:Double;
   JogEnd:Boolean;
   current_XY_Speed,Current_Z_Speed:Double;
   Override_Max_Speeds,Override_Max_Smoothie_Speeds:Boolean;
   C_PEnd,C_NEnd:Double;
   MoToRin,Arrowoffset:Integer;
   Memfile,FIfile,WDFile,MoToR2:Text;
   Prev_I_Center,Prev_J_Center,Prev_I_Centerprobe,Prev_J_Centerprobe,Prev_K_Center:Double;
   QPlungeFeedValue,QFeedValue,ArcFeedValue,LinearFeedValue,PlungeFeedValue,ThreadsPerInch,probefeedvalue:AnsiString;
   PreQArcFeedValue,PreQLinearFeedValue,PreQPlungeFeedValue:AnsiString;
   Originate,AX:String[3];
   JAX:Char;
   MotorError,LimitError,Queit,TempQ:Boolean;
  //Y_Axis,Z_Axis,W_Axis,Feed,R_Axis,A_Axis,B_Axis,C_Axis:Integer;
   Rapid_Plane,Clearance_Plane,Drill_Z_ST,Drill_Z_CL,DrillDwell,DrillAccel,
   Cutting_Plane,Drill_Z_En,Drill_Z_Fd,Drill_I,Drill_J,MototInput:AnsiString;
   Dwell_Setting:Double;
   Cirtype:String[3];
   ErrorChar,ErrorAxis,ErrorKey:Char;
   ErrorString:AnsiString;
   Last_GCode:AnsiString;

   LoopTest:LongInt;
   XSWStrng,YSWStrng,ZSWSTRN,WSWSTRN:AnsiString;
   Tap_Files_Only,Use_Default_Tap_Directory,Use_Default_Tap_Drive:Boolean;
   searchtype:String[1];
   ZoneNum:Integer;
   ProNum:Byte;
   CurrentStatLine:Integer;
   SearchFileName:Ansistring;
   Filenewname2, filenewname:AnsiString;
   max_Files_To_Display:Word;
   loadnewIndex,LoadLine:LongInt;
   STLOOP,LastGNum:Integer;
   LookForloop:Longword;
   DispCnt:QWord;
   PREVCIRC:AnsiString;
   PREVmode:AnsiString;
   prvswp:Boolean;
   prevTool,prevsped:Integer;
   prvxyrt,prvzrt,prVarcrt,prvqrt,prvqzrt,prvclr,prvcut,prvrpd:AnsiString;
   PRVA_Scale,PRVB_Scale,PRVC_Scale,
   prvhead,prvzone,PRVX_Scale,PRV_Scale,PRVY_Scale,PRVZ_Scale,PRVX_Scalec,PRVY_Scalec,PRVZ_Scalec,
   XprvPSN,YprvPSN,ZprvPSN,WprvPSN,RprvPSN,AprvPSN,BprvPSN,CprvPSN,
   XPSN,YPSN,ZPSN,WPSN,APSN,BPSN,CPSN,
   XPrvOffset,YPrvOffset,ZPrvOffset,APrvOffset,BPrvOffset,CPrvOffset,PrvRotation,PrvRotationOverride:AnsiString;
   Savehead,ActiveHead:AnsiString;
   GetTheFile:Text;
   Errorfile:Text;
   editfile:Text;
   Zoneloadfiles:text;
   rapidchk,Clearchk,cutplnchk,Arraystchk,ArrXCHK,ARRYCHK,ARRZCHK,ARRXVCHK,ARRYVCHK,ARRZVCHK:Boolean;
   Gline,TestLine:AnsiString;
   SearchValue:AnsiString;
   filedirInfo                               :TSearchRec  ;
   LoadMore,Loadnew:Byte;
   Repeatgcode,RepeatSMOOthiecmd,RepeatCalculator:Boolean;
   keybuf:Byte;
   proname,oldTap_SubDirectory,oldproname,oldproext,oldpvalueP_File:AnsiString;
   Drillcodez:ShortInt;
   minxy45slope,maxxy45slope:Double;
   manualfeed,PRvxyAccel,PrvZAccel,PrvAAccel,PrvBAccel,PrvCAccel,PrvMaxAccel:AnsiString;
   XY_Accel,Z_Accel,A_Accel,B_Accel,C_Accel,Max_Accel: Double;
   X_Speed,Y_Speed,Z_Speed,A_Speed,B_Speed,C_Speed: Double;
   PRvxyMax,PrvZMax:AnsiString;
   Fullcircle:Boolean;
   ORtho:ShortInt;
   TotDay,TotHour,TotMin,TotSEC:Integer;
   curHead:AnsiString;
   Dimentions{,Keygood}:ShortInt;
   PNum : LongWord;
   Timerunning:ShortInt;
   QMaxnum,WarnCount,ErrorCount:LongInt;
   DefaultTapRPM:Integer;
   fileresult,SilentDisplay,PrevSilentDisplay,Start_Type,LastEAX,LastEAY,LastEAz,LastEAW,LastEAR,LastEAA,LastEAB,LastEAC,LastEAF:ShortInt;
   BXFA,BYFA,BXFDA,BYFDA,NEWFILE:Integer;
   Size,cols,Rows,
   Time_X_Pos,Time_Y_Pos,timeColor,
   Tool_X_Pos,Tool_Y_Pos,ToolColor,
   SyOf:Integer;
   SNPOS,LFPOS,YNPOS,YN2POS,ECPOS:Word;
   sts,svs,svspl5,svs2,sjs,flsvs,bnvs,bfsvs,FLTS,FLTSO,FLO,PRTS,PRTSO,PRO,FLWR:Word;  {PRSVS is in timekeeping}
   svspl,svspl1,bfsvs2:DWord;
   bnvs2:Longint;
   FGMaxSize,SLYPOS,Bargraphcols,SXA,SYA,BXA,BYA,YStatus,Wnum:Integer;
   Rapid_Plane_Def,Clearance_Plane_Def,Cutting_Plane_Def,
   PrevGcodeX,PrevGcodeY,PrevGcodeZ,PrevGcodeW,PrevGcodeR,PrevGcodeA,PrevGcodeB,PrevGcodeC:AnsiString;
   PrevOriginalGcodeX,PrevOriginalGcodeY,PrevOriginalGcodeZ,PrevOriginalGcodeW,PrevOriginalGcodeR,PrevOriginalGcodeA,PrevOriginalGcodeB,PrevOriginalGcodeC:AnsiString;
   Point:pointer;
   Last_HI,Last_GS,Loops,G_End,RunOnceLine : Int64;
   K,Tap_SubDirectory,Tap_Path,Tap_Drive:AnsiString;
   load_filename,Preload_Filename,Preload_Tap_Path,oldvalue2:AnsiString;
   ParamLoad:Byte;
   MainloopStarttime,MainloopStopTime,MainLoopTime,MainLoopTimeLeft:Double;
   EnableStartSwitch:Boolean;
   StartSignal:Boolean;
   LimitLoopCount,LimitLoop:ShortInt;
   MyDouble : Double;
   MyErr  : Byte;
   MyExpr : AnsiString;
   MyBool : Boolean;
   MyAddr : AnsiString;
   ArrayActive:Boolean;
   editnum:Byte;
   eval_Coordinates:Boolean;
   TEST2:LongInt;
  {CSumold:LongInt;}
   bitmask,Keyinbuf,Makefile:Byte;
   powrit,sTopit:Byte;
   skjp:Double;
   lbnum,mtnum:LongInt;
   reldrillEnd:AnsiString;
   Pwrit:Byte;
   Runkey,RunExt:Char;
   Sly1pos,Sly2pos:Integer;
   absolutemode:String[3];
   Saloc,Feedact:ShortInt;
   SALoop:Word;
   Array_start,Array_End,Array_ST_SCR,Array_End_SCR:LongInt;
   Array_XNUM,Array_YNUM,Array_ZNUM:LongInt;
   Array_XOFF,ARRAY_YOFF,ARRAY_ZOFF:Double;
   Temp_X_Offset,Temp_Y_Offset,
   X_Offset,Y_Offset,Z_Offset,A_Offset,B_Offset,C_Offset,Rotation,Rotation_Override,
   Array_X_Offset,Array_Y_Offset,Array_Z_Offset:Double;
   Zone:Integer;
   A_Scale,B_Scale,C_Scale,
   X_Scale,X_Scale_Center,Y_Scale,Y_Scale_Center,Z_Scale,Z_Scale_Center,X_Rotation_Center,Y_Rotation_Center:Double;
   Tjog,moveflg,SnglStep,Snglstepsav,RHFlutes,FLPos,array_it:Word;
   Array_XCnt,Array_YCNT,Array_ZCNT:LongInt;
   Empty_Line:FXED;
   PreloadFile,Batch:Text;
   NextFile:AnsiString;
   RunString,editcommandline :Ansistring;
   SaveZone,X_B4_Remove,Y_B4_Remove,Z_B4_Remove,Prevcustommessage,CurrentSpindleSpeed,probespeed: AnsiString;
   GotMac:String;
   Current_Statline_Data,Previous_Statline_Data:AnsiString;
   Redrawit,Redrawall,Redrewit,IJrelative,Probeit,UseToolLoadPosition,checkhead,Spindle_Disabled,DigiDiag:Boolean;
   ToolLoadPositionX,ToolLoadPositionY,PrevX,PrevY,PrevZ,PrevW,PrevA,Digi_File :AnsiString;
   DigiFilenum:Dword;
   WHB04B_Is_Present:Boolean=False;
   HeadFEQ:Byte;
   MPGButton1,MPGButton2:Byte;
   LCDTime,Idletime:Double;
   DXF_CommentX,DXF_CommentY : Double;
   UseDXFComment: Boolean;
   Blower_Enable,Dust_Collector_Enable,Vacuum_Pump_Enable,Z_Move_Enable,Laser_Enable,Inkjet_Enable : Boolean;
   Maximum_DXF_Comments:Word;
   Update_Position,Keywaspressed:Boolean;
   DisableDXFLabels,CheckG0:Boolean;
   Smoothie_Version:AnsiString;
   New_Smoothie:Boolean;
   Current_Value_At_Home:Axis_Double_Record;
   Value_At_Home:Axis_Double_Record;
   EnableOffset,EnableTemp : Byte;
   EnableOffsetSave,EnableTempSave : Byte;
   DrawTool : Integer;
   DrawValueAthome : Double;
   AskChar:Char;
   ArcX_Min,ArcX_Max,ArcY_Min,ArcY_Max: Double;
   G0Wait:Boolean;
   IoCode : Integer;
   Machinesfile : Text;
   subject,servername,user                    : Ansistring;
   pass:String;
   RBF_Mailtest,RBF_Zip,RBFUpdate,RBFDetails,RBFnowait,SpoilboardDefined : Boolean;
   SMTP: TSMTPSend;
   RBF_run_from_Promill,MAC_Only, RBF_test,resultsofit,BitsaveChanged,BittoolChanged: Boolean;
   Program_End_Time:Double;
   Spindle_Zero_Time:Double;
   Spindle_Start_Retry:Integer;
   Recursive_CLLTE:Integer;


   Ini                                      : TIniFile;
   MachineNames                             : TStringList;
   Loopy,Loopie : Byte;
   Sav                                       : Array[X_Axis..Feed] of AnsiString;

   VerifyFile                                : Text;
   Tool_String                               : Tool_String_Record;
   Ini_Steps_Per_Inch                        : Axis_Double_Record;
   Ini_Steps_Per_Millimeter                  : Axis_Double_Record;
   Ini_Max_Speed                             : Axis_Double_Record;
   Ini_Accel                                 : Axis_Double_Record;
   Ini_AccelMax                              : Double;


   Ini_Max_Travel                            : Axis_Double_Record;
   Ini_Handshake_Pin                         : Axis_Pin_Record;
   Ini_Spindle_Select_Pin                    : Axis_Pin_Record;
   Ini_Spindle_Forward_Pin                   : Axis_Pin_Record;
   Ini_Spindle_Reverse_Pin                   : Axis_Pin_Record;
   Ini_Spindle_Fan_Pin                       : Axis_Pin_Record;
   Ini_Spindle_Fan2_Pin                      : Axis_Pin_Record;

   Ini_Piggyback                             : Axis_Boolean_Record;
   Ini_Home                                  : Axis_Boolean_Record;
   Ini_Force_To_Minimum                      : Axis_Boolean_Record;
   Ini_Minimum_Move_Value                    : Axis_Double_Record;
   Ini_Force_To_Value_At_Home                : Axis_Boolean_Record;

   Ini_Piggyback_Pin                         : Axis_Pin_Record;
   Ini_Piggyback_Power_Pin                   : Axis_Pin_Record;
   Ini_Piggyback_Fan_Pin                     : Axis_Pin_Record;
   Ini_Piggyback_Offset                      : Axis_String_Record;
   Ini_Spindle_Control_Port                  : Axis_String_Record;
   Ini_Smoothie_Accel                        : Axis_String_Record;
   Ini_Smoothie_Speed                        : Axis_String_Record;
   Ini_Smoothie_Steps                        : Axis_String_Record;
   Ini_Smoothie_Accel_Max                    : AnsiString;
   Ini_Spindle_Control_Modbus_Unit_ID        : Axis_Pin_Record;
   
   Ini_Spindle_Control_Modbus_Device         : Axis_String_Record;
   Ini_Dust_Collector_Damper_Pin             : Axis_Pin_Record;
   
   Fix360                                    : Array[A_Axis..C_Axis] of Boolean;
   Ini_Axis_Of_Rotation                      : Array[A_Axis..C_Axis] of AnsiString;
   Use                                       : Array[X_Axis..Five_Head] of Boolean;
   Ini_Home_Move_Off_Switch                  : Array[A_Axis..C_Axis] of AnsiString;
   Ini_Home_Value                            : Array[X_Axis..C_Axis] of AnsiString;
   Ini_Home_Position                         : Array[X_Axis..C_Axis] of AnsiString;
   Ini_Headswap                              : Array[Head_W..Head_Cross,X_Axis..Y_Axis] of AnsiString;
   Ini_MTS                                   : Array[1..10] of MTS_Record;
   Ini_Zone                                  : Array[0..10] of Zone_Record;
   Ini_Tool_Position                         : Array[0..110] of Tool_Record;
   Ini_Tool_Position_String                  : Array[0..110] of Tool_String_Record;
   Ini_Smoothie_Config                       : Array[1..3] of AnsiString;
   Ini_Boundaries                            : Array [Axis_X..Axis_Z,Head_Z..Tot,Minimum..Maximum] of Double;   // [Axis , Head, Minimum/Maximum]
   Ini_Boundaries_Precision                  : Double;
   MNet                                      : Array [0..36] of Mnet_Record;
   Modbus_Config                             : Array [0..36] of Modbus_Config_Record;
   Port_List                                 : Array [0..255] of Port_Record;
   Port_Storage                              : Array [0..255] of Port_Storage_Record;
   Ini_Spindle_Fan_Off_Delay                 : Head_String_Record;
   Ini_Piggyback_Fan_Off_Delay               : Head_String_Record;
   Ini_Marker_ToolHolder                     : Array [0 .. 9] of Integer;
   Ini_Marker_Cap_Prompt                     : Array [0 .. 9] of Boolean;
   Ini_Spindle_Max_RPM                       : Array[X_Axis..Five_Head] of Integer;
   Ini_Seconds_To_Max_RPM                    : Array[X_Axis..Five_Head] of Double;
   Ini_Max_Speed_Feeds                       ,
   Ini_Max_Speed_Arcs                        ,
   Ini_Max_Speed_Home_Retract                ,
   Ini_Clearance_Plane                       ,
   Ini_Rapid_Plane                           ,
   Ini_Cutting_Plane                         ,
   Ini_Piggyback_Dwell_Down_Time             ,
   Ini_Piggyback_Dwell_Up_Time               ,
   Ini_Tap_Gap_Distance              ,
   Ini_Tap_Gap_Feedrate              ,
   Ini_Tool_Changer_RPM_Decelereation_Time   ,
   Ini_Tool_Changer_Pick_Up_Gap              ,
   Ini_Tool_Changer_Pick_Up_Delay            ,
   Ini_Tool_Changer_Sensor_Delay             ,
   Ini_Ortho_XY45_Minimum_Angle              ,
   Ini_Ortho_XY45_Maximum_Angle              ,
   Ini_Spindle_Wait_Stop_Delay               ,
   Ini_Spindle_Wait_Start_Delay              ,
   Ini_Timings_MainLoop                      ,
   Ini_Timings_Limitloop                     ,
   Ini_Timings_Limit_Noise_Filter            ,
   Ini_Auto_Radius_Acceleration              ,
   Ini_Auto_Radius_MInimum_Feedrate          ,
   Ini_Auto_Radius_Reject_Size               ,
   Ini_Auto_Radius_Full_Circle_Tollerance    ,
   Ini_Arc_Radius_Error                      ,
   Ini_Light_Latitude                        ,
   Ini_Light_Longitude                       ,
   Ini_Light_Zenith_Angle                    ,
   Ini_MTS_Clock_Pulse_Delay                 ,
   Ini_Tool_Diameter                         ,
   Ini_Probe_3D_X_Offset                     ,
   Ini_Probe_3D_Y_Offset                     ,
   Ini_Probe_3D_Z_Offset                     ,
   Ini_Probe_3D_Radius                       ,
   Ini_Probe_Tool_Set_X                      ,
   Ini_Probe_Tool_Set_Y                      ,
   Ini_Probe_Tool_Set_Z_Clear                ,
   Ini_Probe_Tool_Set_Z_Rapid                ,
   Ini_Probe_Tool_Set_Z_Feed                 ,
   Ini_Probe_Tool_Set_Z_Offset               ,
   Ini_Probe_Tool_Set_Slow                   ,
   Ini_Probe_Tool_Set_Fast                   ,
   Ini_Probe_Tool_Set_Blower_Delay           ,
   Ini_Auto_DXF_Comment_Size                 ,
   Ini_Auto_DXF_CallXY_Size                  ,
   Ini_Auto_DXF_Label_Size                   ,
   Ini_Auto_DXF_Comment_Spacing              ,
   DXF_Comment_Size                          ,
   DXF_CallXY_Size                           ,
   DXF_Comment_Spacing                       ,
   Ini_Marker_Dwell_Down_Time                ,
   Ini_Marker_Dwell_Up_Time                  ,
   Ini_Home_Dual_Y_Left_Offset               ,
   Ini_Home_Dual_Y_Right_Offset              ,
   Ini_Laser_Default_Power                   ,
   Ini_Laser_Maximum_Power                   ,
   Ini_Laser_Minimum_Power                   ,
   Ini_Laser_Focusing_Power                  ,
   Ini_Notification_Time                     ,
   Ini_Start_Time                            ,
   Ini_Preload_Time                          ,
   Ini_Soft_Volume_Time                      ,
   Ini_Spindle_S3_Start_Time_Retry           :Double;

   Ini_Simulation_Initial_Rotation           :RotationRec;

   Ini_LR                                    ,
   Ini_Knee                                  ,
   Ini_Preload                               ,
   Ini_Reload                                ,
   Reload_Program                            ,
   Ini_Uppercase                             ,
   Ini_Ask_for_Zone                          ,
   Ini_Show_Line_Numbers                     ,
   Ini_Use_Drill_Clear                       ,
   Ini_Spindle_MultiSpeed_S_Starts_Spindle   ,
   Ini_Spindle_Wait_S3                       ,
   Ini_Show_S3_Edge                          ,
   Ini_Spindle_Wait_Dwell                    ,
   Ini_Spindle_Wait_Before_Z                 ,
   Ini_Tool_Changer_Air_Purge_While_Running  ,
   Ini_Tool_Changer_Blower_While_Running     ,
   Ini_Tool_Changer_T_Starts_Spindle         ,
   Ini_Tool_Changer_T101_Power               ,
   Ini_Tool_Changer_Clips                    ,
   Ini_Fast_Swaps                            ,
   Ini_Notification_Program_Time             ,
   Ini_Notification_Tool_Change              ,
   Ini_Notification_Program_Finished         ,
   Ini_Home_W_Fan                            ,
   Ini_Smoothie_G28_After_Home               ,
   Ini_Park_After_Home                       ,
   Ini_Home_Z_Only                           ,
   Ini_Home_On_ToolUp                        ,
   Ini_Run_Both_Spindles_At_Once             ,
   Ini_Serial_Use_ComLog                     ,
   Ini_Serial_Unexpected                     ,
   Ini_Serial_Show_Q                         ,
   Ini_Serial_Diag                           ,
   Ini_Use_Auto_Radius                       ,
   Ini_Auto_Radius_True_Full_Circle_Only     ,
   Ini_Display_Vertical                      ,
   Ini_Auto_DXF_Use_Dashed                   ,
   Ini_Simulation_Ask_First                  ,
   Ini_Simulation_DrawOnly_Use_Tool_Color    ,
   Ini_Show_G0_Moves                         ,
   Ini_Show_Vector_Arrows                    ,
   Ini_Show_All_Vector_Arrows                ,
   Ini_Show_Start_Stop_Arrows                ,
   Ini_Climb_Cut                             ,
   Ini_Material_Check                        ,
   Ini_Load_Not_Found_Returns                ,
   ProMill_Version_Changed                   ,
   Ini_Probe_Tool_Set_Safe_XY_Diagonal       ,
   Ini_Probe_Tool_Set_Safe_X_First           ,
   Ini_Probe_Tool_Set_Home_Head_First        ,
   Ini_Probe_Tool_Set_Blower_During_Probe    ,
   Ini_Probe_Tool_Set_Park_When_Finished     ,
   Probe_Enabled                             ,
   Probe_Tool_Enabled                        ,
   Probe_State                               ,
   Ini_Pendant_Wireless                      ,
   Use_Pendant                               ,
   Ini_MD5_Changed                           ,
   Ini_Home_Dual_Y                           ,
   Ini_Home_Dual_Y_Left_First                ,
   Ini_Simulation_Draw_Helix                 ,
   Draw_Helix                                ,
   Ini_Start_On_Release                      ,
   Ini_Notification_Upgrade_Prompt           ,
   Ini_Notification_J                        ,
   Ini_Laser_Fan_While_Running               ,
   Ini_Show_Load_Options                     ,
   Ini_Boundaries_GCode_Check                ,
   Ini_Boundaries_GCode_Run_Lockout          ,
   Ini_Boundaries_Move_Check                 ,
   Ini_Use_Volume_Control                    ,
   Ini_Auto_Detect_Volume                    ,
   Ini_Auto_Save_Volume                      ,
   Volume_Up                                 ,
   Ini_Auto_Generate_All_DXF                 ,
   Ini_Auto_Generate_All_DPax                ,
   Ini_Auto_Generate_All_PNG                 ,
   Ini_Auto_Generate_All_TIF                 ,
   Ini_Auto_Generate_All_BMP                 ,
   Ini_Auto_Generate_All_JPG                 ,
   Ini_Auto_Generate_Skip_Waits              ,
   Ini_Auto_Generate_Skip_Return_To_Nowhere  ,
   Ini_Picture_Window_On_Top                 ,
   Ini_Picture_Window_Stops_Filename         ,
   Ini_Save_Location_On_C                    ,
   Ini_CheckRuningBoundaries                 ,
   Ini_CheckRuningArcBoundaries              ,
   Ini_Auto_Radius_Reject_Draw_Warning       ,
   Ini_Auto_Radius_Reject_Run_Warning        ,
   Ini_EMail_Log_File                        ,
   Ini_Log_Full_Path                         ,
   Ini_Log_Tap_Path                          ,
   Ini_Spindle_S3_Show_Retry_Message         ,
   Ini_Spindle_Verify_Speed                  ,
   Ini_Enforce_The_Board                     ,
   Ini_null_Eq_zero                          :Boolean;

   Ini_Piggyback_Modbus_Unit_ID              ,
   Ini_Piggyback_Fan_Modbus_Unit_ID          ,
   Ini_Handshake_Modbus_Unit_ID              ,
   Ini_Start_Modbus_Unit_ID                  ,  
   Ini_Start_Pin                             ,
   Ini_Tap_RPM                               ,
   Ini_Tool_Changer_Modbus_Unit_ID           ,
   Ini_Tool_Changer_Input_Modbus_Unit_ID     ,
   Ini_Tool_Changer_S1_Pin                   ,
   Ini_Tool_Changer_S2_Pin                   ,
   Ini_Tool_Changer_S3_Pin                   ,
   Ini_Tool_Changer_Button_Pin               ,
   Ini_Tool_Changer_Button_Bulb_Pin          ,
   Ini_Tool_Changer_Eject_Pin                ,
   Ini_Tool_Changer_Air_Purge_Pin            ,
   Ini_Tool_Changer_Blower_Pin               ,
   Ini_Tool_Changer_Max_Tools                ,
   Ini_Spindle_MultiSpeed_Modbus_Unit_ID     ,
   Ini_Spindle_MultiSpeed_Default            ,
   Ini_Spindle_MultiSpeed_Bit0_Pin           ,
   Ini_Spindle_MultiSpeed_Bit1_Pin           ,
   Ini_Spindle_MultiSpeed_Bit2_Pin           ,
   Ini_Spindle_MultiSpeed_Bit3_Pin           ,
   Ini_Spindle_Overheat_Pin                  ,
   Ini_Spindle_Fan_Modbus_Unit_ID            ,
   Ini_Spindle_Power_Modbus_Unit_ID          ,
   Ini_Spindle_Power_Pin                     ,
   Ini_Spindle_Power_Forward_Pin             ,
   Ini_Spindle_Power_Reverse_Pin             ,
   Ini_Serial_Com1_Port                      ,
   Ini_Serial_Com2_Port                      ,
   Ini_Display_File_Lines                    ,
   Ini_Display_File_Chars                    ,
   Ini_Auto_DXF_Vector_Version               ,
   Ini_Simulation_Slow_Delay                 ,
   Ini_Simulation_Fast_Delay                 ,
   Ini_Light_Modbus_Unit_ID                  ,
   Ini_Head_Light_Modbus_Unit_ID             ,
   Ini_Light_Pin                             ,
   Ini_Head_Light_Pin                        ,
   Ini_Probe_Modbus_Unit_ID                  ,
   Ini_Probe_3D_Pin                          ,
   Ini_Probe_3D_ToolHolder                   ,
   Ini_Probe_Tool_Set_Pin                    ,
   Ini_Probe_Tool_Set_Blower_Pin             ,
   Ini_Opto_Enable_Modbus_Unit_ID            ,
   Ini_Opto_Enable_Negative_Pin              ,
   Ini_Opto_Enable_Positive_Pin              ,
   Ini_Dust_Collector_Modbus_Unit_ID         ,
   Ini_Dust_Collector_Pin                    ,
   Ini_Dust_Collector_Damper_Modbus_Unit_ID  ,
   Ini_Vacuum_Pump_Modbus_Unit_ID            ,
   Ini_Vacuum_Pump_Pin                       ,
   Ini_Marker_Modbus_Unit_ID                 ,
   Ini_Marker_Pin                            ,
   Ini_Laser_Modbus_Unit_ID                  ,
   Ini_Laser_Enable_Pin                      ,
   Ini_InkJet_Modbus_Unit_ID                 ,
   Ini_InkJet_Enable_Pin                     ,
   Ini_Laser_Fan_Pin                         ,
   Critical_Errors, Warnings, Wait_for_input ,
   Ini_Modbus_Retries                        ,
   Ini_Simulation_Helix_Resolution           ,
   Ini_Volume_While_Idle                     ,
   Ini_Volume_While_Running                  ,
   Ini_Auto_Generate_JPG_Quality             ,
   Ini_Auto_Generate_Max_Size                ,
   Ini_BitSave_Backups_To_Keep               ,
   Ini_BitSave_Network_Backups_To_Keep       ,
   Ini_BitSave_Upgrade_Backups_To_Keep       ,
   Ini_MP_Backups_To_Keep                    ,
   Ini_MP_Network_Backups_To_Keep            ,
   Ini_MP_Upgrade_Backups_To_Keep            ,
   Ini_Boundaries_Max_Errors                 ,
   Ini_Log_Version                           ,
   Ini_Spindle_S3_Max_Detection_Speed        ,
   Ini_Spindle_S3_Number_Of_Retries          ,
   Ini_Max_Error_Log                         ,
   Ini_Max_Error_Load                        :Integer;

   Ini_Serial_Com1_Baudrate                  ,
   Ini_Serial_Com2_Baudrate                  :LongInt;

   Ini_Display_Program_Lines                 :Int64;

   Ini_Display_Title_Divider                 ,
   Ini_Display_Gcode_Divider                 ,
   Ini_Display_Info_V_Divider                ,
   Ini_Auto_DXF_G0_Color                     ,
   Ini_Auto_DXF_G1_Color                     ,
   Ini_Auto_DXF_G2_Color                     ,
   Ini_Auto_DXF_G3_Color                     ,
   Ini_Auto_DXF_Drill_Color                  ,
   Ini_Auto_DXF_Comment_Color                ,
   Ini_Auto_DXF_CallXY_Color                 ,
   DXF_Comment_Color                         ,
   DXF_CallXY_Color                          ,
   Ini_Auto_DXF_Label_Color                  ,
   Ini_Auto_DXF_Comment_Maximum_Number       ,
   Ini_Vector_Color                          ,
   Ini_Vector_Color_First                    ,
   Ini_Line_Z0_1_Color                       ,
   Ini_Line_Z0_2_Color                       ,
   Ini_Line_Z_Positive_1_Color               ,
   Ini_Line_Z_Positive_2_Color               ,
   Ini_Line_Z_Negative_1_Color               ,
   Ini_Line_Z_Negative_2_Color               ,
   Ini_Arc_Z0_1_Color                        ,
   Ini_Arc_Z0_2_Color                        ,
   Ini_Arc_Z_Positive_1_Color                ,
   Ini_Arc_Z_Positive_2_Color                ,
   Ini_Arc_Z_Negative_1_Color                ,
   Ini_Arc_Z_Negative_2_Color                ,
   Ini_Circle_Z0_Color                       ,
   Ini_Circle_Z_Positive_Color               ,
   Ini_Circle_Z_Negative_Color               ,
   Ini_Circle_Disabled_Color                 ,
   Ini_Force_Z_To_Min_Color                  ,
   Ini_Slightly_Above_Zero_Color             ,
   Ini_G0_Color                              ,
   Ini_G0_Error_Color                        ,
   Ini_Start_Color                           ,
   Ini_Stop_Color                            ,
   Ini_Tool_Color                            ,
   Ini_Tool_Opacity                          ,
   Ini_Vector_Divider                        ,
   Ini_Material_Color                        ,
   Ini_Bounding_Box_Color                    ,
   Ini_Table_Color                           ,
   Ini_Crosshair_Color                       ,
   Ini_Pendant_USB_VID                       ,
   Ini_Pendant_USB_PID                       ,
   Ini_Notification_Popup_Message_Max_Lines  ,
   Ini_Gcode_Color_Line_Number               ,
   Ini_Gcode_Color_Line_Number_Highlight     ,
   Ini_Gcode_Color_Comment                   ,
   Ini_Gcode_Color_Draw                      ,
   Ini_Gcode_Color_Head                      ,
   Ini_Gcode_Color_Display_Comment           ,
   Ini_Gcode_Color_Tool_Number               ,
   Ini_Gcode_Color_Verbose                   ,
   Ini_Gcode_Color_MCode                     ,
   Ini_Gcode_Color_GCode                     ,
   Ini_Gcode_Color_Text_Document             ,
   Ini_Gcode_Color_Label                     ,
   Ini_Gcode_Color_Error                     ,
   Ini_Gcode_Color_Added                     ,
   Ini_Gcode_Color_Warning                   ,
   Ini_Gcode_Color_Digitize                  ,
   Ini_Gcode_Color_Equation                  ,
   Ini_Picture_Window_X_Position             ,
   Ini_Picture_Window_Y_Position             ,
   Ini_Picture_Window_Width                  ,
   Ini_Picture_Window_Height                 :Word;

   ProMill_Version                           ,
   Ini_ProMill                               ,
   Ini_Machine_ID                            ,
   Ini_Edit_Command                          ,
   Ini_Tap_Drive                             ,
   Ini_Tap_Directory                         ,
   Ini_Vector_Drive                          ,
   Ini_Vector_Directory                      ,
   Ini_Log_File_Prefix                       ,
   Ini_Log_Ini_File                          ,
   Ini_Enable_Dot_File                       ,
   Ini_Head_Up_Tool_Up                       ,
   Ini_Head_Up_Head_Swap                     ,
   Ini_Head_Up_Power                         ,
   Ini_Head_Up_T_Command                     ,
   Ini_Heads_Up_Program_Start                ,
   Ini_Heads_Up_Program_Stop                 ,
   Ini_ZR_or_ZE                              ,
   Ini_Tool_Changer_Type                     ,
   Ini_Ortho_Method                          ,
   Ini_Notification_Runtime_pax_Drive        ,
   Ini_Notification_Runtime_pax_Directory    ,
   Ini_Notification_Runtime_pax_File         ,
   Ini_Notification_Send_EMail               ,
   Ini_Notification_EMail_UserName           ,
   Ini_Notification_EMail_Password           ,
   Ini_Notification_EMail_Host               ,
   Ini_Notification_EMail_From               ,
   Ini_Notification_Idle_Time                ,
   Ini_Notification_RBF_EMail                ,
   Ini_Notification_Update_Bat               ,
   Ini_Notification_Upgrade_Path             ,
   Ini_Notification_Upgrade_File             ,
   Ini_Notification_Upgrade_Date             ,
   Ini_Notification_Preload_Path             ,
   Ini_Notification_Popup_Temp_File          ,
   Ini_Notification_Popup_Message_File       ,
   Ini_Notification_Popup_ToDo_File          ,
   Ini_Notification_Popup_ToDo_Date          ,
   Ini_Notification_Popup_Message_Date       ,
   Ini_Default_XY_Rate                       ,
   Ini_Default_Z_Rate                        ,
   Ini_Default_Arc_Rate                      ,
   Ini_Default_Q_Feed_Rate                   ,
   Ini_Default_Q_Plunge_Rate                 ,
   Ini_Spindle_MultiSpeed_Option             ,
   Ini_Wait_For_Spindle_Stop                 ,
   Ini_Display_Window_Resolution             ,
   Ini_Display_XY                            ,
   Ini_Display_Console_Window_Size           ,
   Ini_Display_Console_XY                    ,
   Ini_Display_Console_Popup_Window_Size     ,
   Ini_Display_Console_Popup_XY              ,
   Ini_Display_Power_On_Time                 ,
   Ini_Display_Power_Off_Time                ,
   Ini_Display_Off_Delay                     ,
   Ini_Display_DayCode                       ,
   Ini_Light_Delay                           ,
   Ini_Auto_DXF_Start_XY                     ,
   Ini_Auto_DXF_Comment_XY                   ,
   DXF_Comment_XY                            ,
   Ini_Simulation_Resolution                 ,
   Ini_Simulation_Draw_Circle_Tolerance      ,
   Ini_Probe_3D_Type                         ,
   Ini_Probe_3D_Slow                         ,
   Ini_Probe_3D_Fast                         ,
   Ini_Probe_Tool_Set_Type                   ,
   Ini_Probe_Tool_Set_X_Safe                 ,
   Ini_Probe_Tool_Set_Y_Safe                 ,
   Ini_Vector_Color_String                   ,
   Ini_Vector_Color_First_String             ,
   Ini_Line_Z0_1_Color_String                ,
   Ini_Line_Z0_2_Color_String                ,
   Ini_Line_Z_Positive_1_Color_String        ,
   Ini_Line_Z_Positive_2_Color_String        ,
   Ini_Line_Z_Negative_1_Color_String        ,
   Ini_Line_Z_Negative_2_Color_String        ,
   Ini_Arc_Z0_1_Color_String                 ,
   Ini_Arc_Z0_2_Color_String                 ,
   Ini_Arc_Z_Positive_1_Color_String         ,
   Ini_Arc_Z_Positive_2_Color_String         ,
   Ini_Arc_Z_Negative_1_Color_String         ,
   Ini_Arc_Z_Negative_2_Color_String         ,
   Ini_Circle_Z0_Color_String                ,
   Ini_Circle_Z_Positive_Color_String        ,
   Ini_Circle_Z_Negative_Color_String        ,
   Ini_Circle_Disabled_Color_String          ,
   Ini_Force_Z_To_Min_Color_String           ,
   Ini_Slightly_Above_Zero_Color_String      ,
   Ini_G0_Color_String                       ,
   Ini_G0_Error_Color_String                 ,
   Ini_Start_Color_String                    ,
   Ini_Stop_Color_String                     ,
   Ini_Tool_Color_String                     ,
   Ini_Material_Color_String                 ,
   Ini_Bounding_Box_Color_String             ,
   Ini_Table_Color_String                    ,
   Ini_Crosshair_Color_String                ,
   Ini_Material_Size                         ,
   Ini_Material_Offset                       ,
   Ini_Table_Size                            ,
   Ini_Table_Offset                          ,
   Ini_Data                                  ,
   Ini_String                                ,
   Ini_MD5                                   ,
   Ini_BitSave_MD5                           ,
   Ini_Bittool_MD5                           ,
   Ini_Location_MD5                          ,
   Ini_Pendant_Type                          ,
   Ini_Pendant_Model                         ,
   Ini_Piggyback_Port                        ,
   Ini_Piggyback_Modbus_Device               ,
   Ini_Handshake_Port                        ,
   Ini_Handshake_Modbus_Device               ,
   Ini_Tool_Changer_Port                     ,
   Ini_Tool_Changer_Input_Port               ,
   Ini_Tool_Changer_Modbus_Device            ,
   Ini_Tool_Changer_Input_Modbus_Device      ,
   Ini_Light_Port                            ,
   Ini_Head_Light_Port                       ,
   Ini_Head_Light_Off_Delay                  ,
   Ini_Light_Modbus_Device                   ,
   Ini_Head_Light_Modbus_Device              ,
   Ini_Spindle_MultiSpeed_Port               ,
   Ini_Spindle_MultiSpeed_Modbus_Device      ,
   Ini_Spindle_Fan_Port                      ,
   Ini_Spindle_Fan_Modbus_Device             ,
   Ini_Piggyback_Fan_Port                    ,
   Ini_Piggyback_Fan_Modbus_Device           ,
   Ini_Spindle_Power_Port                    ,
   Ini_Spindle_Power_Modbus_Device           ,
   Ini_Start_Port                            ,
   Ini_Start_Modbus_Device                   ,
   Ini_Probe_Port                            ,
   Ini_Probe_Modbus_Device                   ,
   Ini_Opto_Enable_Port                      ,
   Ini_Opto_Enable_Modbus_Device             ,
   Ini_Dust_Collector_Port                   ,
   Ini_Dust_Collector_Modbus_Device          ,
   Ini_Dust_Collector_Off_Delay              ,
   Ini_Dust_Collector_Damper_Port            ,
   Ini_Dust_Collector_Damper_Modbus_Device   ,
   Ini_Vacuum_Pump_Port                      ,
   Ini_Vacuum_Pump_Modbus_Device             ,
   Ini_Vacuum_Pump_On_Delay                  ,
   Ini_Vacuum_Pump_Off_Delay                 ,
   Ini_Marker_Port                           ,
   Ini_Marker_Modbus_Device                  ,
   Ini_Laser_Port                            ,
   Ini_Laser_Modbus_Device                   ,
   Ini_Laser_Enable_On_Delay                 ,
   Ini_Laser_Fan_Off_Delay                   ,
   Ini_Inkjet_Port                           ,
   Ini_Inkjet_Modbus_Device                  ,
   Ini_Inkjet_Enable_On_Delay                ,
   Ini_Inkjet_Enable_Off_Delay               ,
   Ini_Inkjet_Dwell                          ,
   MP_Ini_MD5                                ,
   Ini_Spindle_Cooldown_Time                 ,
   Ini_EMail_Log_To                          :AnsiString;

   Ini_Laser_Enable_Sound                    ,
   Ini_Laser_Disable_Sound                   ,
   Ini_Probe_3D_Enable_Sound                 ,
   Ini_Probe_3D_Disable_Sound                ,
   Ini_Marker_Enable_Sound                   ,
   Ini_Marker_Disable_Sound                  : AnsiString;


   MTS_Devices, Work_Zones, Tool_Holders, Port_Total_Pins     : Byte;
Implementation
function TStringListHelper.High: NativeInt;
   begin
      Exit (Self.Count-1);
   end;
function TStringsHelper.High: NativeInt;
   begin
      Exit (Self.Count-1);
   end;

Begin
   DisableErrorListPrompt:= False;
   IgnoreRange:=False;
   CheckBoundaries:=True;
   Volume_Up:=False;
   DrawWithwWaits:=True;
   DNUText:='';
   G0Wait:=False;
   Program_End_Time:=0;
   Spindle_Zero_Time:=-1;
   Recursive_CLLTE:=0;
   OldSpindleSpeed:=0;
End.
