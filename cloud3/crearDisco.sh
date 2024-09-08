#!/bin/bash

#Nombre el disco y ruta
NAME="$1.vdi"
PATH="/c/Users/Julian/VirtualBox Vms/$NAME"
SIZE="4096"
VBOX="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"

#crear disco
"$VBOX" createmedium disk --filename "$PATH" --size "$SIZE" --format VDI
if [ -f "$PATH" ]; then
	echo "Se ha creado el disco $NAME en la ruta $PATH"
fi

