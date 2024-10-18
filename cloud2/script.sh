#!/bin/bash

# Solicitar el nombre de la VM
echo "Ingrese el nombre de la vm"
read vmname

# Crear la máquina virtual
VBoxManage createvm --name "$vmname" --ostype Debian_64 --register

# Configurar la memoria RAM, memoria de video, CPUs y habilitar IOAPIC
VBoxManage modifyvm "$vmname" --memory 512 --vram 128 --cpus 2 --ioapic on

# Configurar la red como Adaptador Puente
VBoxManage modifyvm "$vmname" --nic1 bridged --bridgeadapter1 "Broadcom NetLink (TM) Gigabit Ethernet"

# Configurar el controlador SATA y crear un disco duro de 25 GB
VBoxManage storagectl "$vmname" --name "SATA Controller" --add sata --controller IntelAhci

# Agregar el controlador IDE para el disco óptico e insertar la imagen ISO
VBoxManage storagectl "$vmname" --name "IDE Controller" --add ide

# Configurar el controlador de video y habilitar EFI
VBoxManage modifyvm "$vmname" --graphicscontroller vmsvga --firmware efi --boot1 disk --boot2 none --boot3 none --boot4 none
