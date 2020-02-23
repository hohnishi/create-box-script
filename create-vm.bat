@echo off
setlocal
set cmdname=%~n0%~x0
REM cd "%~dp0"
set exit=exit /B

REM envirenment settings
set VBOXBIN=C:\Program Files\Oracle\VirtualBox
set VBOXMANAGE="%VBOXBIN%\VBoxManage.exe"
set VBOXVMBASE=C:\VirtualBox VMs
set ISOBASE=C:\Users\Hajim\Documents\ISO\OL

REM VM settings
set OSIMAGE=%ISOBASE%\OL76_V980739-01.iso
set VMNAME=OL76base
REM set OSTYPE=RedHat_64
set OSTYPE=Oracle_64
set MEMSIZE=512
set VDIPATH=%VBOXVMBASE%\%VMNAME%\%VMNAME%.vdi
set VDISIZE=204800

if "%1"=="" (
   call :usage
   %exit% !ERRORLEVEL!
) else if "%1"=="all" (
   call :all
   %exit% !ERRORLEVEL!
) else if "%1"=="createvm" (
   call :createvm
   %exit% !ERRORLEVEL!
) else if "%1"=="showvm" (
   call :showvm
   %exit% !ERRORLEVEL!
) else if "%1"=="showvm2" (
   call :showvm2
   %exit% !ERRORLEVEL!
) else if "%1"=="eject" (
   call :eject
   %exit% !ERRORLEVEL!
) else if "%1"=="additions" (
   call :additions
   %exit% !ERRORLEVEL!
) else if "%1"=="osimage" (
   call :osimage
   %exit% !ERRORLEVEL!
) else if "%1"=="startvm" (
   call :startvm
   %exit% !ERRORLEVEL!
) else if "%1"=="addhostonly" (
   call :addhostonly
   %exit% !ERRORLEVEL!
) else if "%1"=="delhostonly" (
   call :delhostonly
   %exit% !ERRORLEVEL!
)

REM ###############################################
:usage
	echo "Usage: %cmdname% createvm|showvm|showvm2|eject|additions|osimage|addhostonly|delhostonly"
	%exit%

REM ###############################################
:all
	time /T
	call :createvm
	call :showvm  > %VMNAME%_info.txt
	call :osimage
::	call :addhostonly
	start httpserver.exe
	call :startvm
	echo select "Install XXXXX" and TAB
	echo add to boot option
::	echo "inst.ks=http://192.168.56.1:8080/ks.cfg"
	echo inst.ks=http://10.0.2.2:8080/ks.cfg
	pause
::	call :eject
	time /T
	%exit%

REM ###############################################
REM # create VM from scratch
:createvm
	:: # VM
	%VBOXMANAGE% createvm --name "%VMNAME%" --register
	%VBOXMANAGE% modifyvm "%VMNAME%" --ostype "%OSTYPE%"
	%VBOXMANAGE% modifyvm "%VMNAME%" --memory "%MEMSIZE%"
	%VBOXMANAGE% modifyvm "%VMNAME%" --nic1 nat
	%VBOXMANAGE% modifyvm "%VMNAME%" --natpf1 "Rule 1,tcp,127.0.0.1,2222,,22"
	%VBOXMANAGE% modifyvm "%VMNAME%" --audio none
	%VBOXMANAGE% modifyvm "%VMNAME%" --usb off
	:: # HDD
	%VBOXMANAGE% createmedium disk --filename "%VDIPATH%" --size %VDISIZE% --format VDI
	%VBOXMANAGE% storagectl    "%VMNAME%" --name "SATA" --add sata
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "SATA" --type hdd     --port 0 --device 0 --medium "%VDIPATH%"
	:: # DVD Drive
	%VBOXMANAGE% storagectl    "%VMNAME%" --name "IDE" --add ide
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium emptydrive
	%exit%

REM ###############################################
REM # show vm information
:showvm
	%VBOXMANAGE% showvminfo "%VMNAME%"
	%exit%

REM ###############################################
REM # show vm information mr
:showvm2
	%VBOXMANAGE% showvminfo --machinereadable "%VMNAME%"
	%exit%

REM ###############################################
REM # eject virtual CD
:eject
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium emptydrive
	%exit%

REM ###############################################
REM # set additions CD
:additions
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium additions
	%exit%

REM ###############################################
REM # set OS image CD
:osimage
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium %OSIMAGE%
	%exit%

REM ###############################################
REM # start VM
:startvm
	%VBOXMANAGE% startvm "%VMNAME%"
	%exit%

REM ###############################################
REM # add host only network I/F
:addhostonly
::	%VBOXMANAGE% addhostonly create --hostonlyadapter4 vboxnetX
	%VBOXMANAGE% modifyvm "%VMNAME%" --hostonlyadapter4 "VirtualBox Host-Only Ethernet Adapter"
	%VBOXMANAGE% modifyvm "%VMNAME%" --nic4 hostonly
	%exit%

REM ###############################################
REM # delete host only network I/F
:delhostonly
	%VBOXMANAGE% modifyvm "%VMNAME%" --nic4 none
	%exit%

REM ## EOF
