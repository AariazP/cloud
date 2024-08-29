#!/bin/bash

# Solicitar el nombre de la VM
echo "Ingrese el nombre de la vm"
read vmname

# Crear la máquina virtual
VBoxManage createvm --name "$vmname" --ostype Debian_64 --register

# Configurar la memoria RAM, memoria de video, CPUs y habilitar IOAPIC
VBoxManage modifyvm "$vmname" --memory 512 --vram 128 --cpus 2 --ioapic on

# Configurar la red como Adaptador Puente
VBoxManage modifyvm "$vmname" --nic1 bridged --bridgeadapter1 "eno1"

# Configurar el controlador SATA y crear un disco duro de 25 GB
VBoxManage storagectl "$vmname" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage createhd --filename "$HOME/VirtualBox VMs/$vmname/$vmname.vdi" --size 25600
VBoxManage storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$vmname/$vmname.vdi"

# Agregar el controlador IDE para el disco óptico e insertar la imagen ISO
VBoxManage storagectl "$vmname" --name "IDE Controller" --add ide
VBoxManage storageattach "$vmname" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "/home/arias/Descargas/ubuntu-24.04-live-server-amd64.iso"

# Configurar el controlador de video y habilitar EFI
VBoxManage modifyvm "$vmname" --graphicscontroller vmsvga --firmware efi --boot1 dvd --boot2 disk --boot3 none --boot4 none
