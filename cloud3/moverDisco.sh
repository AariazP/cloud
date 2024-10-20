#!/bin/bash

#Load environment variables
source .env

# Función para apagar la máquina si está encendida
apagar_maquina() {
	local maquina="$1"
	estado=$(VBoxManage showvminfo "$maquina" --machinereadable | grep -c 'VMState="running"')

	if [ "$estado" -eq 1 ]; then
		echo "Apagando la máquina: $maquina"
		VBoxManage controlvm "$maquina" acpipowerbutton
		sleep 5 # Esperar un momento para asegurarse de que la máquina se apague
	else
		echo "La máquina $maquina ya está apagada."
	fi
}

# Apagar las máquinas si es necesario
apagar_maquina "$MAQUINA_ORIGEN"
apagar_maquina "$MAQUINA_DESTINO"

# Mover el disco de una máquina a otra
echo "Desconectando el disco $DISK_PATH de la máquina $MAQUINA_ORIGEN"
VBoxManage storageattach "$MAQUINA_ORIGEN" --storagectl $CONTROLLER --port 1 --device 0 --medium none

echo "Conectando el disco $DISCO a la máquina $MAQUINA_DESTINO"
VBoxManage storageattach "$MAQUINA_DESTINO" --storagectl $CONTROLLER --port 1 --device 0 --type hdd --medium "$DISK_PATH"

# Encender la máquina de destino
echo "Encendiendo la máquina: $MAQUINA_DESTINO"
VBoxManage startvm "$MAQUINA_DESTINO" --type gui

echo "Operación completada con éxito."
