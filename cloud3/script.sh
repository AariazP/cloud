#!/bin/bash

#Ruta al exe de VirtualBox
VBOX="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"

#Variables
entrada=$(cat | tr -d '\n' | tr -s ' ')
echo $entrada
#Nombre el disco y ruta
VM_NAME=$(echo "$entrada"|awk -F "NAME: " '{print $2}' | awk -F " PATH: " '{print $1}')
echo " El nombre de la maquina virtual $VM_NAME"
DISK_PATH=$(echo "$entrada"|awk -F "PATH: " '{print $2}')
echo " La ruta del disco $DISK_PATH"
CONTROLLER="SATA"
PORT=1
DEVICE=0
USER="vboxuser"
SSH_KEY="/c/Users/Julian/Desktop/cloud/cloud3/id_rsa"
PATH_SCRIPT="/c/Users/Julian/Desktop/cloud/cloud3/formatearDisco.sh"
REMOTE_SCRIPT="/home/$USER/Desktop/formatearDisco.sh"



#adjuntar el disco duro virtual
"$VBOX" storageattach "$VM_NAME" --storagectl "$CONTROLLER" --port $PORT --device $DEVICE --type hdd --medium "$DISK_PATH"

#verificar que si se adjunto

if [ $? -eq 0 ]; then
	echo "Disco adjuntado correctamente"

	#levantar la maquina

	"$VBOX" startvm "$VM_NAME" --type gui
	
	if [ $? -eq 0 ]; then
		echo "VM levantada exitosamente"
	
	else 
		echo "Error al levantar la vm"
		exit 1
	fi
else 
	echo "Error adjuntando el disco"
	exit 1
fi

sleep 40

# Ejecuta guestproperty enumerate para obtener la IP
INFO=$("$VBOX" guestproperty enumerate "$VM_NAME" | grep "V4/IP")
IP=$(echo "$INFO" | awk -F"'" '{print $2}')

#Mostrar la ip
echo "La direccion IP de la maquina $VM_NAME es $IP"

#transferir el script por scp

scp -i "$SSH_KEY" "$PATH_SCRIPT" "$USER"@"$IP":"$REMOTE_SCRIPT"

#Ejecutar el script
ssh -i "$SSH_KEY" "$USER"@"$IP" "bash $REMOTE_SCRIPT"
