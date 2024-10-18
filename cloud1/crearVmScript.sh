#!/bin/bash

# Solicitar el nombre de la VM
vmname=$1
OS=$2

MINT_ISO="/c/Users/Julian/Downloads/linuxmint-22-xfce-64bit.iso"
DEBIAN_ISO="/c/Users/Julian/Downloads/debian-12.7.0-amd64-DVD-1.iso"
MX_ISO="/c/Users/Julian/Downloads/MX-23.3_x64.iso"
UBUNTU_ISO="/c/Users/Julian/Downloads/ubuntu-24.04.1-live-server-amd64.iso"
NET_CARD="Broadcom NetLink (TM) Gigabit Ethernet"


if [ $OS = "mint" ]; then
	echo "La vm se creara con mint"
	PATH_ISO=$MINT_ISO
elif [ $OS = "debian" ]; then
	echo "La vm se creara con debian"
	PATH_ISO=$DEBIAN_ISO

elif [ $OS = "ubuntu" ]; then
        echo "La vm se creara con ubuntu"
        PATH_ISO=$UBUNTU_ISO


elif [ $OS = "mx" ]; then
        echo "La vm se creara con linux mx"
        PATH_ISO=$MX_ISO
else
	echo "No se encuentra disponible ese sistema operativo"
	exit 1
fi

# Crear la máquina virtual
VBoxManage createvm --name "$vmname" --ostype Debian_64 --register

# Configurar la memoria RAM, memoria de video, CPUs y habilitar IOAPIC
VBoxManage modifyvm "$vmname" --memory 512 --vram 128 --cpus 2 --ioapic on

# Configurar la red como Adaptador Puente
VBoxManage modifyvm "$vmname" --nic1 bridged --bridgeadapter1 "$NET_CARD"

# Configurar el controlador SATA y crear un disco duro de 25 GB
VBoxManage storagectl "$vmname" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage createmedium --filename "$HOME/VirtualBox VMs/$vmname/$vmname.vdi" --size 25600
VBoxManage storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$vmname/$vmname.vdi"

# Agregar el controlador IDE para el disco óptico e insertar la imagen ISO
VBoxManage storagectl "$vmname" --name "IDE Controller" --add ide
VBoxManage storageattach "$vmname" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$PATH_ISO"

# Configurar el controlador de video y habilitar EFI
VBoxManage modifyvm "$vmname" --graphicscontroller vmsvga --firmware efi --boot1 dvd --boot2 disk --boot3 none --boot4 none
