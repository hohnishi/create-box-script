@echo off
setlocal
set cmdname=%~n0%~x0
REM cd "%~dp0"
set exit=exit /B

REM envirenment settings
set VBOXBIN=C:\Program Files\Oracle\VirtualBox
set VBOXMANAGE="%VBOXBIN%\VBoxManage.exe"
set VBOXVMBASE=C:\VirtualBox VMs
set ISOBASE=C:\Users\Hajim\Documents\ISO
set VAGRANT=C:\HashiCorp\Vagrant\bin\vagrant.exe
set SSHOPT=-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL

REM VM settings
set OSIMAGE=%ISOBASE%\OL\OL76_V980739-01.iso
set VMNAME=OL76box
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
) else if "%1"=="vmstart" (
   call :vmstart
   %exit% !ERRORLEVEL!
) else if "%1"=="vmshutdown" (
   call :vmshutdown
   %exit% !ERRORLEVEL!
) else if "%1"=="createpkg" (
   call :createpkg
   %exit% !ERRORLEVEL!
)

REM ###############################################
:usage
	echo "Usage: %cmdname% createvm|showvm|showvm2|eject|additions|osimage|vmstart|vmshutdown|createpkg"
	%exit%

REM ###############################################
:all
	time /T
	call :createvm
	call :showvm  > %VMNAME%_info.txt
	call :osimage
	start httpserver.exe
	call :vmstart
	echo select "Install XXXXX" and TAB
	echo add to boot option
::	echo "inst.ks=http://192.168.56.1:8080/ks.cfg"
	echo inst.ks=http://10.0.2.2:8080/ks.cfg
	echo wait until OS bootup
	pause
	call :additions
	ssh %SSHOPT% -p 2222 vagrant@localhost "sudo mount /dev/sr0 /mnt ; sudo /mnt/VBoxLinuxAdditions.run ; sudo umount /mnt"
	time /T
	%exit%

REM ###############################################
REM # create VM from scratch
:createvm
	:: # VM
	%VBOXMANAGE% createvm --name "%VMNAME%" --register
	%VBOXMANAGE% modifyvm "%VMNAME%" --ostype "%OSTYPE%"
	%VBOXMANAGE% modifyvm "%VMNAME%" --x2apic on
	%VBOXMANAGE% modifyvm "%VMNAME%" --rtcuseutc  on
	%VBOXMANAGE% modifyvm "%VMNAME%" --memory "%MEMSIZE%"
	%VBOXMANAGE% modifyvm "%VMNAME%" --nic1 nat
	%VBOXMANAGE% modifyvm "%VMNAME%" --natpf1 "Rule 1,tcp,127.0.0.1,2222,,22"
	%VBOXMANAGE% modifyvm "%VMNAME%" --audio none
	%VBOXMANAGE% modifyvm "%VMNAME%" --usb off
	:: # DVD Drive
	%VBOXMANAGE% storagectl    "%VMNAME%" --name "IDE" --add ide
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium emptydrive
	:: # HDD
	%VBOXMANAGE% createmedium disk --filename "%VDIPATH%" --size %VDISIZE% --format VDI
	%VBOXMANAGE% storagectl    "%VMNAME%" --name "SATA" --add sata --portcount 1
	%VBOXMANAGE% storageattach "%VMNAME%" --storagectl "SATA" --type hdd     --port 0 --device 0 --medium "%VDIPATH%"
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
:vmstart
	%VBOXMANAGE% startvm "%VMNAME%"
	%exit%

REM ###############################################
REM # vm shutdown
:vmshutdown
	%VBOXMANAGE% controlvm "%VMNAME%" acpipowerbutton
	%exit%

REM ###############################################
REM # cretate vagrant package
:createpkg
	%VAGRANT% package --base "%VMNAME%"
	%exit%

REM ## EOF
