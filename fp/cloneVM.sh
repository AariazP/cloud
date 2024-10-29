#!/bin/bash

cd ~/Desktop/cloud/fp/

VBoxManage='/usr/local/bin/VBoxManage'

source .env
# Variables
NAME="$NEW_VM$RANDOM"
# Crear la nueva máquina virtual
echo "Creando la máquina virtual '$NEW_VM'..."
$VBoxManage createvm --name "$NAME" --register

# Configurar red en modo Bridge
$VBoxManage modifyvm "$NAME" --nic1 bridged
$VBoxManage modifyvm "$NAME" --bridgeadapter1 "en0: Wi-Fi"
$VBoxManage modifyvm "$NAME" --nictype1 82540EM
$VBoxManage modifyvm "$NAME" --cableconnected1 on
$VBoxManage modifyvm "$NAME" --nicpromisc1 deny
$VBoxManage modifyvm "$NAME" --macaddress1 auto

# Configurar la máquina virtual
echo "Configurando la máquina virtual '$NAME'..."
$VBoxManage modifyvm "$NAME" --memory 2048 --vram 128 --acpi on --nic1 bridged
$VBoxManage modifyvm "$NAME" --ostype "Ubuntu_64" --cpu-profile "host"
$VBoxManage modifyvm "$NAME" --graphicscontroller VMSVGA --firmware efi --boot1 floppy --boot2 dvd

# Agregar controladores
$VBoxManage storagectl "$NAME" --name "Virtio SCSI" --add virtio-scsi

# Adjuntar el disco multiconexión a la máquina virtual
$VBoxManage storageattach "$NAME" --storagectl "Virtio SCSI" --port 0 --device 0 --type hdd --medium "$DISCO_MULTICONEXION"

# Iniciar la máquina virtual en modo headless
echo "Iniciando la máquina virtual '$NAME' en modo headless..."
$VBoxManage startvm "$NAME" --type headless

echo "La máquina virtual '$NAME' ha sido creada e iniciada en modo headless."
