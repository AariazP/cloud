#!/bin/bash

VBOX="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"

# Verificar que se hayan pasado los tres parámetros
if [ "$#" -ne 3 ]; then
    echo "Se necesitan: $0 <nombre_disco> <nombre_maquina_origen> <nombre_maquina_destino>"
    exit 1
fi

DISCO="$1"
MAQUINA_ORIGEN="$2"
MAQUINA_DESTINO="$3"

# Función para apagar la máquina si está encendida
apagar_maquina() {
    local maquina="$1"
    estado=$("$VBOX" showvminfo "$maquina" --machinereadable | grep -c 'VMState="running"')

    if [ "$estado" -eq 1 ]; then
        echo "Apagando la máquina: $maquina"
        "$VBOX" controlvm "$maquina" acpipowerbutton
        sleep 5  # Esperar un momento para asegurarse de que la máquina se apague
    else
        echo "La máquina $maquina ya está apagada."
    fi
}

# Apagar las máquinas si es necesario
apagar_maquina "$MAQUINA_ORIGEN"
apagar_maquina "$MAQUINA_DESTINO"

# Mover el disco de una máquina a otra
echo "Desconectando el disco $DISCO de la máquina $MAQUINA_ORIGEN"
"$VBOX" storageattach "$MAQUINA_ORIGEN" --storagectl "SATA" --port 1 --device 0 --medium none

echo "Conectando el disco $DISCO a la máquina $MAQUINA_DESTINO"
"$VBOX" storageattach "$MAQUINA_DESTINO" --storagectl "SATA" --port 1 --device 0 --type hdd --medium "$DISCO"

# Encender la máquina de destino
echo "Encendiendo la máquina: $MAQUINA_DESTINO"
"$VBOX" startvm "$MAQUINA_DESTINO" --type gui

echo "Operación completada con éxito."

