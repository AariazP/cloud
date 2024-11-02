#!/bin/bash

VBoxManage='/usr/local/bin/VBoxManage'

# Nombre de la máquina virtual en VirtualBox
VM_NAME=$1
# Ruta del archivo de configuración de HAProxy
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"
# Servicio de HAProxy
HAPROXY_SERVICE="haproxy"

# Apagar la máquina virtual
echo "Apagando la máquina virtual $VM_NAME..."
$VBoxManage controlvm "$VM_NAME" acpipowerbutton

# Esperar a que la máquina virtual se apague
echo "Esperando que la máquina virtual se apague..."
while [[ "$($VBoxManage showvminfo "$VM_NAME" --machinereadable | grep -c '^VMState="poweroff"$')" -ne 1 ]]; do
	sleep 2
done
echo "La máquina virtual $VM_NAME se ha apagado."

# Eliminar la máquina virtual de VirtualBox
echo "Eliminando la máquina virtual $VM_NAME..."
$VBoxManage unregistervm "$VM_NAME" --delete
echo "La máquina virtual $VM_NAME ha sido eliminada."
