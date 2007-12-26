unit MainUnit2;
//this unit is used by both the network client and the main program (USERINTERFACE)

interface

uses dialogs,forms,classes,windows,sysutils,formsettingsunit,registry,cefuncproc,AdvancedOptionsUnit,
     MemoryBrowserFormUnit

{$ifdef net}
,unit2;
{$else}
,plugin,mainunit,hotkeyhandler,frmProcessWatcherunit,newkernelhandler;
{$endif}

procedure HandleautoAttachString;
procedure LoadSettingsFromRegistry;
procedure initcetitle;
function GetScanType: Integer;
function getVarType: Integer;

const beta=''; //empty this for a release

var
  CEnorm:string = 'Cheat Engine'+beta;
  CERegion:string = 'Cheat Engine 5.3'+beta+' - Please Wait!';
  CESearch:string = 'Cheat Engine 5.3'+beta+' - Please Wait!';
  CERegionSearch:string = 'Cheat Engine 5.3+'+beta+' - Please Wait!';
  CEWait:string= 'Cheat Engine 5.3'+beta+' - Please Wait!';

resourcestring
  strStart='Start';
  strStop='Stop';
  strOK='OK';
  strBug='BUG!';
  strAutoAssemble='Assembler';

  strAddressHasToBeReadable='The address has to be readable if you want to use this function';
  strNewScan='New Scan';
  strFirstScan='First Scan';
  strNoDescription='No description';

  strNeedNewerWindowsVersion='This function only works in Windows 2000+ (perhaps also NT but not tested)';

  //scantypes
  strexact='Exact';
  strexactvalue='Exact Value';
  strbiggerThan='Bigger than...';
  strSmallerThan='Smaller than...';
  strIncreasedValue='Increased value';
  strIncreasedValueBy='Increased value by ...';
  strDecreasedValue='Decreased value';
  strDecreasedValueBy='Decreased value by ...';
  strValueBetween='Value between...';

  strChangedValue='Changed value';
  strUnchangedValue='Unchanged value';
  strUnknownInitialValue='Unknown initial value';
  strSameAsFirstScan='Same as first scan';

  strFailedToInitialize='Failed to initialize the debugger';
  strtoolong='Too long';

  type tspeedhackspeed=record
    speed: single;
    sleeptime: dword;
  end;

  var
    speedhackspeed1: tspeedhackspeed;
    speedhackspeed2: tspeedhackspeed;
    speedhackspeed3: tspeedhackspeed;
    speedhackspeed4: tspeedhackspeed;
    speedhackspeed5: tspeedhackspeed;

    speedupdelta: single;
    slowdowndelta: single;

implementation

function GetScanType: Integer;
var vtype: integer;
begin
  with mainform do
  begin
    result:=exact_value;

    vtype:= getvartype;
    if getvartype in [0,1,2,3,4,6] then
    begin
      if not nextscanbutton.enabled then
      begin
        //first scan
        case scantype.ItemIndex of
          0: result:=exact_value;
          1: result:=biggerthan;
          2: result:=smallerthan;
          3: result:=valuebetween;
          4: result:=Advanced_scan;
        end;
      end
      else
      begin
        //next scan
        case scantype.itemindex of
          0: result:=exact_value;
          1: result:=biggerthan;
          2: result:=smallerthan;
          3: result:=valuebetween;
          4: result:=increased_value;
          5: result:=increased_value_by;
          6: result:=decreased_value;
          7: result:=decreased_value_by;
          8: result:=changed_value;
          9: result:=unchanged_value;
          10: result:=sameasfirst;
        end;
      end;
    end;
  end;
end;

function getVarType: Integer;
begin
  {


Bit = 5
Byte =0
2 Bytes =1
4 Bytes =2
8 Bytes =6
Float =3
Double =4
Text = 7
}
  with mainform do
  begin
    case VarType.ItemIndex of
      0: result:=5; //binary
      1: result:=0; //byte
      2: result:=1; //2 bytes
      3: result:=2; //4 bytes
      4: result:=6; //8 bytes
      5: result:=3; //float
      6: result:=4; //double
      7: result:=7; //text
      8: result:=8; //array of byte
      else result:=0;
    end;
  end;
end;

procedure HandleautoAttachString;
var s: string;
    s2: string;
    i: integer;
begin
  mainform.autoattachlist.clear;
  s:=formsettings.EditAutoAttach.Text;
  s2:='';
  for i:=1 to length(s) do
  begin
    if s[i]=';' then
    begin
      s2:=trim(s2);
      if s2<>'' then
        mainform.autoattachlist.Add(s2);

      s2:='';
      continue;
    end;
    s2:=s2+s[i];
  end;

  s2:=trim(s2);
  if s2<>'' then
    mainform.autoattachlist.Add(s2);

  mainform.AutoAttachTimer.Enabled:=mainform.autoattachlist.Count>0;
end;

procedure LoadSettingsFromRegistry;
var reg : TRegistry;
    modifier: dword;
    key: dword;
    hotkey: string;
    i,j: integer;
    go: boolean;
    temphotkeylist: array [0..28] of cefuncproc.tkeycombo;
    found:boolean;
    names: TStringList;
    s,s2: string;
begin
  try
    reg:=Tregistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey('\Software\Cheat Engine',false) then
      begin
        with formsettings do
        begin
          LoadingSettingsFromRegistry:=true;
          try cbshowundo.checked:=reg.ReadBool('Undo'); except end;
          try cbShowAdvanced.checked:=reg.ReadBool('Advanced');except end;
          try checkThread.checked:=reg.ReadBool('SeperateThread'); except end;
          try combothreadpriority.itemindex:=reg.ReadInteger('ScanThreadpriority'); except end;

          mainform.UndoScan.visible:={$ifdef net}false{$else}cbshowundo.checked{$endif};


          mainform.advancedbutton.Visible:=cbShowAdvanced.checked;
          mainform.cbspeedhack.Visible:=cbShowAdvanced.checked;


          {$ifndef net}
          SuspendHotkeyHandler;

          try speedhackspeed1.speed:=reg.ReadFloat('Speedhack 1 speed'); except speedhackspeed1.speed:=1; end;
          try speedhackspeed1.sleeptime:=reg.ReadInteger('Speedhack 1 sleeptime'); except speedhackspeed1.sleeptime:=3; end;
          try speedhackspeed2.speed:=reg.ReadFloat('Speedhack 2 speed'); except speedhackspeed2.speed:=1; end;
          try speedhackspeed2.sleeptime:=reg.ReadInteger('Speedhack 2 sleeptime'); except speedhackspeed2.sleeptime:=3; end;
          try speedhackspeed3.speed:=reg.ReadFloat('Speedhack 3 speed'); except speedhackspeed3.speed:=1; end;
          try speedhackspeed3.sleeptime:=reg.ReadInteger('Speedhack 3 sleeptime'); except speedhackspeed3.sleeptime:=3; end;
          try speedhackspeed4.speed:=reg.ReadFloat('Speedhack 4 speed'); except speedhackspeed4.speed:=1; end;
          try speedhackspeed4.sleeptime:=reg.ReadInteger('Speedhack 4 sleeptime'); except speedhackspeed4.sleeptime:=3; end;
          try speedhackspeed5.speed:=reg.ReadFloat('Speedhack 5 speed'); except speedhackspeed5.speed:=1; end;
          try speedhackspeed5.sleeptime:=reg.ReadInteger('Speedhack 5 sleeptime'); except speedhackspeed5.sleeptime:=3; end;

          try speedupdelta:=reg.ReadFloat('Increase Speedhack delta'); except end;
          try slowdowndelta:=reg.ReadFloat('Decrease Speedhack delta'); except end;

          try reg.ReadBinaryData('Show Cheat Engine Hotkey',temphotkeylist[0][0],10); except mainform.label7.Caption:=''; end;
          try reg.ReadBinaryData('Pause process Hotkey',temphotkeylist[1][0],10); except end;
          try reg.ReadBinaryData('Toggle speedhack Hotkey',temphotkeylist[2][0],10); except end;
          try reg.ReadBinaryData('Set Speedhack speed 1 Hotkey',temphotkeylist[3][0],10); except end;
          try reg.ReadBinaryData('Set Speedhack speed 2 Hotkey',temphotkeylist[4][0],10); except end;
          try reg.ReadBinaryData('Set Speedhack speed 3 Hotkey',temphotkeylist[5][0],10); except end;
          try reg.ReadBinaryData('Set Speedhack speed 4 Hotkey',temphotkeylist[6][0],10); except end;
          try reg.ReadBinaryData('Set Speedhack speed 5 Hotkey',temphotkeylist[7][0],10); except end;

          try reg.ReadBinaryData('Increase Speedhack speed',temphotkeylist[8][0],10); except end;
          try reg.ReadBinaryData('Decrease Speedhack speed',temphotkeylist[9][0],10); except end;

          try reg.ReadBinaryData('Binary Hotkey',temphotkeylist[10][0],10); except end;
          try reg.ReadBinaryData('Byte Hotkey',temphotkeylist[11][0],10); except end;
          try reg.ReadBinaryData('2 Bytes Hotkey',temphotkeylist[12][0],10); except end;
          try reg.ReadBinaryData('4 Bytes Hotkey',temphotkeylist[13][0],10); except end;
          try reg.ReadBinaryData('8 Bytes Hotkey',temphotkeylist[14][0],10); except end;
          try reg.ReadBinaryData('Float Hotkey',temphotkeylist[15][0],10); except end;
          try reg.ReadBinaryData('Double Hotkey',temphotkeylist[16][0],10); except end;
          try reg.ReadBinaryData('Text Hotkey',temphotkeylist[17][0],10); except end;
          try reg.ReadBinaryData('Array of Byte Hotkey',temphotkeylist[18][0],10); except end;
          try reg.ReadBinaryData('New Scan Hotkey',temphotkeylist[19][0],10); except end;
          try reg.ReadBinaryData('New Scan-Exact Value',temphotkeylist[20][0],10); except end;
          try reg.ReadBinaryData('Unknown Initial Value Hotkey',temphotkeylist[21][0],10); except end;
          try reg.ReadBinaryData('Next Scan-Exact Value',temphotkeylist[22][0],10); except end;

          try reg.ReadBinaryData('Increased Value Hotkey',temphotkeylist[23][0],10); except end;
          try reg.ReadBinaryData('Decreased Value Hotkey',temphotkeylist[24][0],10); except end;
          try reg.ReadBinaryData('Changed Value Hotkey',temphotkeylist[25][0],10); except end;
          try reg.ReadBinaryData('Unchanged Value Hotkey',temphotkeylist[26][0],10); except end;
          try reg.ReadBinaryData('Undo Last scan Hotkey',temphotkeylist[27][0],10); except end;
          try reg.ReadBinaryData('Cancel scan Hotkey',temphotkeylist[28][0],10); except end;

          try reg.ReadBinaryData('Speedhack speed 1',Speedhackspeed1,sizeof(tspeedhackspeed)); except speedhackspeed1.speed:=2; speedhackspeed1.sleeptime:=3; end;
          try reg.ReadBinaryData('Speedhack speed 2',Speedhackspeed2,sizeof(tspeedhackspeed)); except speedhackspeed2.speed:=2; speedhackspeed2.sleeptime:=3; end;
          try reg.ReadBinaryData('Speedhack speed 3',Speedhackspeed3,sizeof(tspeedhackspeed)); except speedhackspeed3.speed:=2; speedhackspeed3.sleeptime:=3; end;
          try reg.ReadBinaryData('Speedhack speed 4',Speedhackspeed4,sizeof(tspeedhackspeed)); except speedhackspeed4.speed:=2; speedhackspeed4.sleeptime:=3; end;
          try reg.ReadBinaryData('Speedhack speed 5',Speedhackspeed5,sizeof(tspeedhackspeed)); except speedhackspeed5.speed:=2; speedhackspeed5.sleeptime:=3; end;


          //fill the hotkeylist
          for i:=0 to 28 do
          begin
            found:=false;

            for j:=0 to length(hotkeythread.hotkeylist)-1 do
            begin
              if (hotkeythread.hotkeylist[j].id=i) and (hotkeythread.hotkeylist[j].handler2) then
              begin
                //found it
                hotkeythread.hotkeylist[j].keys:=temphotkeylist[i];
                found:=true;
                break;
              end;
            end;

            if not found then //add it
            begin
              j:=length(hotkeythread.hotkeylist);
              setlength(hotkeythread.hotkeylist,j+1);
              hotkeythread.hotkeylist[j].keys:=temphotkeylist[i];
              hotkeythread.hotkeylist[j].windowtonotify:=mainform.Handle;
              hotkeythread.hotkeylist[j].id:=i;
              hotkeythread.hotkeylist[j].handler2:=true;
            end;

            checkkeycombo(temphotkeylist[i]);
          end;

          if temphotkeylist[0][0]<>0 then
            hotkey:=ConvertKeyComboToString(temphotkeylist[0])
          else
            hotkey:='no';


          if temphotkeylist[1][0]<>0 then
            advancedoptions.pausehotkeystring:='('+ConvertKeyComboToString(temphotkeylist[1])+')'
          else
            advancedoptions.pausehotkeystring:=' (No hotkey)';

          if temphotkeylist[2][0]<>0 then
            mainform.cbSpeedhack.Hint:='Enable/Disable speedhack. ('+ConvertKeyComboToString(temphotkeylist[2])+')'
          else
            mainform.cbSpeedhack.Hint:='Enable/Disable speedhack. (No hotkey)';


          ResumeHotkeyHandler;

          {$endif}

          try buffersize:=reg.readInteger('Buffersize'); except buffersize:=512; end;


          try EditBufSize.text:=IntToStr(buffersize) except EditBufSize.Text:='512'; end;
          buffersize:=buffersize*1024;
          {$ifdef net} mainform.buffersize:=buffersize; {$endif}

          try if reg.ReadBool('UseDebugRegs') then formsettings.rbDebugRegisters.checked:=true else formsettings.rdWriteExceptions.checked:=true; except end;

          try
            if reg.readbool('Show Disassembler') then
            begin
              formsettings.cbShowDisassembler.checked:=true;
              memorybrowser.Panel1.Visible:=true;
              memorybrowser.updatedisassemblerview;
              memorybrowser.RefreshMB;
            end
            else
            begin
              formsettings.cbShowDisassembler.checked:=false;
              memorybrowser.Panel1.Visible:=false;
              memorybrowser.RefreshMB;
            end;
          except

          end;

          try formsettings.cbCenterOnPopup.checked:=reg.readbool('Center on popup'); except end;
          try mainform.updatetimer.Interval:=reg.readInteger('Update interval'); except end;
          try mainform.freezetimer.Interval:=reg.readInteger('Freeze interval'); except end;
          formsettings.EditUpdateInterval.text:=IntToStr(mainform.updatetimer.Interval);
          formsettings.EditFreezeInterval.text:=IntToStr(mainform.freezetimer.Interval);

          {$ifdef net}
          //also get the update interval for network
          try i:=reg.readInteger('Network Update Interval'); except end;
          try formsettings.EditNetworkUpdateInterval.Text:=IntToStr(i); except end;
          {$endif}

          try cbShowAsSigned.checked:=reg.readbool('Show values as signed'); except end;
          try cbBinariesAsDecimal.checked:=reg.readbool('Handle binarys as decimals'); except end;

    //      reg.KeyExists()
          if reg.ValueExists('AutoAttach') then
            EditAutoAttach.Text:=reg.ReadString('AutoAttach');

          if reg.ValueExists('Always AutoAttach') then
            cbAlwaysAutoAttach.checked:=reg.readbool('Always AutoAttach');



          try EditNetworkUpdateInterval.Text:=IntToStr(reg.ReadInteger('Network Update Interval')); except end;
          try cbShowDebugoptions.checked:=reg.ReadBool('Show debugger options'); except end;
          try replacewithnops.checked:=reg.readBool('Replace incomplete opcodes with NOPS'); except end;
          try askforreplacewithnops.checked:=reg.readBool('Ask for replace with NOPS'); except end;
          try cbFastscan.checked:=reg.ReadBool('Fastscan on by default'); except end;
          try checkbox1.Checked:=reg.readbool('Use Anti-debugdetection'); except end;
          try cbhandlebreakpoints.Checked:=reg.ReadBool('Handle unhandled breakpoints'); except end;

          if cbFastscan.Checked then mainform.cbFastscan.Checked:=true else mainform.cbFastScan.Checked:=false;

          try cbsimplecopypaste.checked:=reg.readbool('Simple copy/paste'); except end;


          try rbDebugAsBreakpoint.Checked:=reg.readbool('Hardware breakpoints'); except end;
          try rbInt3AsBreakpoint.checked:=not reg.readbool('Hardware breakpoints'); except end;

          try cbUpdatefoundList.Checked:=reg.readbool('Update Foundaddress list'); except end;

          try mainform.UpdateFoundlisttimer.interval:=reg.readInteger('Update Foundaddress list Interval'); except end;
          try editUpdatefoundInterval.Text:=IntToStr(mainform.UpdateFoundlisttimer.interval); except end;          

          try cbSkip_PAGE_NOCACHE.Checked:=reg.readbool('skip PAGE_NOCACHE'); except end;
          Skip_PAGE_NOCACHE:=cbSkip_PAGE_NOCACHE.Checked;

          //try cbBreakOnAttach.Checked:=reg.readbool('Break when debuging'); except end;
          cbBreakOnattach.Checked:=false;
          try cbHideAllWindows.Checked:=reg.ReadBool('Hide all windows'); except end;
          try temphideall:=reg.ReadBool('Really hide all windows'); except end;
          onlyfront:=not formsettings.temphideall;

          try cbMemPrivate.Checked:=reg.ReadBool('MEM_PRIVATE'); except end;
          try cbMemImage.Checked:=reg.ReadBool('MEM_IMAGE'); except end;
          try cbMemMapped.Checked:=reg.ReadBool('MEM_MAPPED'); except end;
          Scan_MEM_PRIVATE:=cbMemPrivate.checked;
          Scan_MEM_IMAGE:=cbMemImage.Checked;
          Scan_MEM_MAPPED:=cbMemMapped.Checked;

          try cbLowMemoryUsage.Checked:=reg.ReadBool('Low Memory Usage'); except end;
          try cbEnableHyperscanWhenPossible.Checked:=reg.ReadBool('Use Hyperscan if posible'); except end;

          try cbStealth.Checked:=reg.ReadBool('StealthOnExecute'); except cbstealth.Checked:=false; end;
          try cbProtectMe.Checked:=reg.readbool('Protect CE'); except cbprotectme.checked:=false; end;
          try cbKernelQueryMemoryRegion.checked:=reg.ReadBool('Use dbk32 QueryMemoryRegionEx'); except end;
          try cbKernelReadWriteProcessMemory.checked:=reg.ReadBool('Use dbk32 ReadWriteProcessMemory'); except end;
          try cbKernelOpenProcess.checked:=reg.ReadBool('Use dbk32 OpenProcess'); except end;


          try cbUndoMemoryChanges.checked:=reg.ReadBool('Undo memory changes'); except end;
          try cbForceUndo.checked:=reg.ReadBool('Undo memory changes:Force writable'); except end;

          if not cbUndoMemorychanges.Checked then
          begin
            cbforceundo.Checked:=false;
            cbforceundo.Enabled:=false;
          end;

          {$ifndef net}


          try unrandomizersettings.defaultreturn:=reg.ReadInteger('Unrandomizer: default value'); except end;
          try unrandomizersettings.incremental:=reg.ReadBool('Unrandomizer: incremental'); except end;

          try DenyList:=reg.ReadBool('ModuleList as Denylist'); except denylist:=true; end;
          try DenyListGlobal:=reg.ReadBool('Global Denylist'); except denylistglobal:=false; end;
          try ModuleListSize:=reg.ReadInteger('ModuleListSize'); except modulelistsize:=0; end;
          if modulelist<>nil then freemem(modulelist);
          getmem(modulelist,modulelistsize);
          try reg.ReadBinaryData('Module List',ModuleList^,ModuleListSize); except end;

          try cbProcessWatcher.checked:=reg.readBool('Use Processwatcher'); except end;
          try cbKdebug.checked:=reg.ReadBool('Use Kernel Debugger'); except end;

          if cbForceUndo.checked then LoadDBK32;

          if cbKernelQueryMemoryRegion.checked then UseDBKQueryMemoryRegion else DontUseDBKQueryMemoryRegion;
          if cbKernelReadWriteProcessMemory.checked then UseDBKReadWriteMemory else DontUseDBKReadWriteMemory;
          if cbKernelOpenProcess.Checked then UseDBKOpenProcess else DontUseDBKOpenProcess;

          if cbProcessWatcher.Checked then
            if (frmProcessWatcher=nil) then //propably yes
              frmProcessWatcher:=tfrmprocesswatcher.Create(mainform); //start the process watcher

          {$endif}

          if cbUndoMemoryChanges.checked then
            if not fileexists(cheatenginedir+'ceprotect.dat') then
            begin
              cbUndoMemoryChanges.Checked:=false;
              cbforceundo.Enabled:=false;
              cbforceundo.Checked:=false;
            end;




          //load the exclude list
          try
            i:=0;
            go:=true;
            while go do
            begin
              setlength(donthidelist,length(donthidelist)+1);
              donthidelist[i]:=reg.readstring('Do not hide '+IntToStr(i));
              if donthidelist[i]='' then
              begin
                setlength(donthidelist,length(donthidelist)-1);
                go:=false;
              end;

              inc(i);
            end;
          except
            if length(donthidelist)=0 then
            begin
              setlength(donthidelist,1);
              donthidelist[0]:='explorer.exe';
            end;
          end;


        end;


      end;

      {$ifndef net}
      if Reg.OpenKey('\Software\Cheat Engine\plugins',false) then
      begin
        names:=TStringList.create;
        try
          reg.GetValueNames(names);
          names.Sort;

          for i:=0 to names.Count-1 do
          begin
            try
              if names[i][10]='A' then //plugin dll
              begin
                s:=reg.ReadString(names[i]);
                j:=pluginhandler.LoadPlugin(s);
              end;

              if names[i][10]='B' then //enabled or not
              begin
                if reg.ReadBool(names[i]) then
                  pluginhandler.EnablePlugin(j);
              end;
            except

            end;


          end;

          pluginhandler.FillCheckListBox(formsettings.clbPlugins);
        finally
          names.Free;
        end;
      end;
      {$endif}


      formsettings.LoadingSettingsFromRegistry:=false;

    finally
      reg.CloseKey;
    end;
  except

  end;

  {$ifdef net}
  MemoryBrowser.Kerneltools1.visible:=false;
  {$else}
  MemoryBrowser.Kerneltools1.Enabled:=DarkByteKernel<>0;
  {$endif}

  HandleAutoAttachString;
end;

procedure initcetitle;
var dwhandle: thandle;
    FileVersionInfoSize: integer;
    puLen: cardinal;
    FileVersionInfo: pointer;
     b: pointer;
    ffi: ^VS_FIXEDFILEINFO;

begin
  CEnorm:='Cheat Engine 5.3';  //.';

{  FileVersionInfoSize:=GetFileVersionInfoSize(pchar(application.exename),dwhandle);
  if FileVersionInfoSize>0 then
  begin
    getmem(FileVersionInfo,FileVersionInfoSize);
    try
      if GetFileVersionInfo(pchar(application.exename),0,FileVersionInfoSize,FileVersionInfo) then
      begin
        if VerQueryValue(FileVersionInfo,'\',b,puLen) then
        begin
          ffi:=b;
          cenorm:=cenorm+(inttostr(ffi.dwFileVersionLS))+beta;

        end;
      end;

    finally
      freemem(FileVersionInfo);
    end;

  end;        }

  CERegion:=cenorm+' - Please Wait!';
  CESearch:=CERegion;
  CERegionSearch:= CERegion;
  CEWait:= ceregion;
  mainform.Caption:=CENorm;
end;

end.

