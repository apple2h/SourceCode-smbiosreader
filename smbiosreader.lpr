program smbiosreader;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, uSMBIOS;

type

  { TSMBIOSReader }

  TSMBIOSReader = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure GetMemoryDeviceInfo;
  end;

{ TSMBIOSReader }

procedure TSMBIOSReader.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  try
    GetMemoryDeviceInfo;
 except
    on E:Exception do
        Writeln(E.Classname, ':', E.Message);
 end;
 Writeln('Press Enter to exit');
 Readln;

  // stop program loop
  Terminate;
end;

constructor TSMBIOSReader.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TSMBIOSReader.Destroy;
begin
  inherited Destroy;
end;

procedure TSMBIOSReader.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

procedure TSMBIOSReader.GetMemoryDeviceInfo;
Var
  SMBios : TSMBios;
  LMemoryDevice  : TMemoryDeviceInformation;
begin
  SMBios:=TSMBios.Create;
  try
      WriteLn('SMBIOS Report of Memory Device Information');
      WriteLn('-------------------------');

      if SMBios.HasMemoryDeviceInfo then
      for LMemoryDevice in SMBios.MemoryDeviceInformation do
      begin
        WriteLn(Format('Total Width    %d bits',[LMemoryDevice.RAWMemoryDeviceInfo^.TotalWidth]));
        WriteLn(Format('Data Width     %d bits',[LMemoryDevice.RAWMemoryDeviceInfo^.DataWidth]));
        WriteLn(Format('Size           %d Mbytes',[LMemoryDevice.GetSize]));
        WriteLn(Format('Form Factor    %s',[LMemoryDevice.GetFormFactor]));
        WriteLn(Format('Device Locator %s',[LMemoryDevice.GetDeviceLocatorStr]));
        WriteLn(Format('Bank Locator   %s',[LMemoryDevice.GetBankLocatorStr]));
        WriteLn(Format('Memory Type    %s',[LMemoryDevice.GetMemoryTypeStr]));
        WriteLn(Format('Speed          %d MHz',[LMemoryDevice.RAWMemoryDeviceInfo^.Speed]));
        WriteLn(Format('Manufacturer   %s',[LMemoryDevice.ManufacturerStr]));
        WriteLn(Format('Serial Number  %s',[LMemoryDevice.SerialNumberStr]));
        WriteLn(Format('Asset Tag      %s',[LMemoryDevice.AssetTagStr]));
        WriteLn(Format('Part Number    %s',[LMemoryDevice.PartNumberStr]));

        WriteLn;

        if LMemoryDevice.RAWMemoryDeviceInfo^.PhysicalMemoryArrayHandle>0 then
        begin
          WriteLn('  Physical Memory Array');
          WriteLn('  ---------------------');
          WriteLn('  Location         '+LMemoryDevice.PhysicalMemoryArray.GetLocationStr);
          WriteLn('  Use              '+LMemoryDevice.PhysicalMemoryArray.GetUseStr);
          WriteLn('  Error Correction '+LMemoryDevice.PhysicalMemoryArray.GetErrorCorrectionStr);
          if LMemoryDevice.PhysicalMemoryArray.RAWPhysicalMemoryArrayInformation^.MaximumCapacity<>$80000000 then
            WriteLn(Format('  Maximum Capacity %d Kb',[LMemoryDevice.PhysicalMemoryArray.RAWPhysicalMemoryArrayInformation^.MaximumCapacity]))
          else
            WriteLn(Format('  Maximum Capacity %d bytes',[LMemoryDevice.PhysicalMemoryArray.RAWPhysicalMemoryArrayInformation^.ExtendedMaximumCapacity]));

          WriteLn(Format('  Memory devices   %d',[LMemoryDevice.PhysicalMemoryArray.RAWPhysicalMemoryArrayInformation^.NumberofMemoryDevices]));
        end;
        WriteLn;
      end
      else
      Writeln('No Memory Device Info was found');
  finally
   SMBios.Free;
  end;
end;

var
  Application: TSMBIOSReader;
begin
  Application:=TSMBIOSReader.Create(nil);
  Application.Title:='SMBIOS Reader';
  Application.Run;
  Application.Free;
end.

