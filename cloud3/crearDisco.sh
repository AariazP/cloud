#!/bin/bash

#Nombre el disco y ruta
NAME="$1.vdi"
DISK_PATH="/c/Users/Julian/VirtualBox Vms/$NAME"
SIZE="4096"
VBOX="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
VM_NAME=$2

#crear disco
"$VBOX" createmedium disk --filename "$DISK_PATH" --size "$SIZE" --format VDI
if [ -f "$DISK_PATH" ]; then
	echo "NAME: $VM_NAME PATH: $DISK_PATH"
fi

