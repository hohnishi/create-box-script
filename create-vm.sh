@echo off
setlocal
set cmdname="$0"
### cd "%~dp0"
set exit=exit

### envirenment settings
#export VBOXBIN=C:\Program Files\Oracle\VirtualBox
export VBOXMANAGE="$(which VBoxManage)"
export VBOXVMBASE="~/VirtualBox VMs"
export ISOBASE="/mnt/hdd1/Data/ISO"
export VAGRANT="$(which vagrant)"
export SSHOPT=-o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL

### VM settings
export OSIMAGE="${ISOBASE}/Linux Dist/OL76_V980739-01.iso"
export VMNAME=OL76box
### set OSTYPE=RedHat_64
export OSTYPE=Oracle_64
export MEMSIZE=512
export VDIPATH=${VBOXVMBASE}/${VMNAME}/${VMNAME}.vdi
export VDISIZE=204800

if "%1"=="" (
   call :usage
   ${exit} $?
) else if "%1"=="all" (
   call :all
   ${exit} $?
) else if "%1"=="createvm" (
   call :createvm
   ${exit} $?
) else if "%1"=="showvm" (
   call :showvm
   ${exit} $?
) else if "%1"=="showvm2" (
   call :showvm2
   ${exit} $?
) else if "%1"=="eject" (
   call :eject
   ${exit} $?
) else if "%1"=="additions" (
   call :additions
   ${exit} $?
) else if "%1"=="osimage" (
   call :osimage
   ${exit} $?
) else if "%1"=="vmstart" (
   call :vmstart
   ${exit} $?
) else if "%1"=="vmshutdown" (
   call :vmshutdown
   ${exit} $?
) else if "%1"=="createpkg" (
   call :createpkg
   ${exit} $?
) else if "%1"=="addbox" (
   call :addbox
   ${exit} $?
)

### ###############################################
usage() {
	echo "Usage: ${cmdname} createvm|showvm|showvm2|eject|additions|osimage|vmstart|vmshutdown|createpkg|addbox"
	${exit}
}
### ###############################################
all() {
	time /T
	call :createvm
	call :showvm  > ${VMNAME}_info.txt
	call :osimage
	start httpserver.exe
	call :vmstart
	time /T
	echo select "Install XXXXX" and TAB
	echo add to boot option
::	echo "inst.ks=http://192.168.56.1:8080/ks.cfg"
	echo inst.ks=http://10.0.2.2:8080/ks.cfg
	echo wait until OS bootup
	time /T
	pause
	time /T
	call :additions
	ssh ${SSHOPT} -p 2222 vagrant@localhost "sudo mount /dev/sr0 /mnt ; sudo /mnt/VBoxLinuxAdditions.run ; sudo umount /mnt"
	time /T
	echo create and add box
	time /T
	pause
	time /T
	call :createpkg
	call :addbox
	time /T
	${exit}
}
### ###############################################
### # create VM from scratch
createvm() {
	:: # VM
	${VBOXMANAGE} createvm --name "${VMNAME}" --register
	${VBOXMANAGE} modifyvm "${VMNAME}" --ostype "${OSTYPE}"
	${VBOXMANAGE} modifyvm "${VMNAME}" --x2apic on
	${VBOXMANAGE} modifyvm "${VMNAME}" --rtcuseutc  on
	${VBOXMANAGE} modifyvm "${VMNAME}" --memory "${MEMSIZE}"
	${VBOXMANAGE} modifyvm "${VMNAME}" --nic1 nat
	${VBOXMANAGE} modifyvm "${VMNAME}" --natpf1 "Rule 1,tcp,127.0.0.1,2222,,22"
	${VBOXMANAGE} modifyvm "${VMNAME}" --audio none
	${VBOXMANAGE} modifyvm "${VMNAME}" --usb off
	:: # DVD Drive
	${VBOXMANAGE} storagectl    "${VMNAME}" --name "IDE" --add ide
	${VBOXMANAGE} storageattach "${VMNAME}" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium emptydrive
	:: # HDD
	${VBOXMANAGE} createmedium disk --filename "${VDIPATH}" --size ${VDISIZE} --format VDI
	${VBOXMANAGE} storagectl    "${VMNAME}" --name "SATA" --add sata --portcount 1
	${VBOXMANAGE} storageattach "${VMNAME}" --storagectl "SATA" --type hdd     --port 0 --device 0 --medium "${VDIPATH}"
	${exit}
}
### ###############################################
### # show vm information
showvm() {
	${VBOXMANAGE} showvminfo "${VMNAME}"
	${exit}
}
### ###############################################
### # show vm information mr
showvm2() {
	${VBOXMANAGE} showvminfo --machinereadable "${VMNAME}"
	${exit}
}
### ###############################################
### # eject virtual CD
eject() {
	${VBOXMANAGE} storageattach "${VMNAME}" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium emptydrive
	${exit}
}
### ###############################################
### # set additions CD
additions() {
	${VBOXMANAGE} storageattach "${VMNAME}" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium additions
	${exit}
}
### ###############################################
### # set OS image CD
osimage() {
	${VBOXMANAGE} storageattach "${VMNAME}" --storagectl "IDE" --type dvddrive --port 1 --device 0 --medium ${OSIMAGE}
	${exit}
}
### ###############################################
### # start VM
vmstart() {
	${VBOXMANAGE} startvm "${VMNAME}"
	${exit}
}
### ###############################################
### # vm shutdown
vmshutdown() {
	${VBOXMANAGE} controlvm "${VMNAME}" acpipowerbutton
	${exit}
}
### ###############################################
### # cretate vagrant package
createpkg() {
	${VAGRANT} package --base "${VMNAME}" --output "${VMNAME}.box"
	${exit}
}
### ###############################################
### # add vagrant box
addbox() {
	${VAGRANT} box list
	${VAGRANT} box add "${VMNAME}.box" --name "private/${VMNAME}"
	${VAGRANT} box list
	${exit}
}
### ## EOF
