
#!/bin/bash

VM_A="OsmaArias"
VM_B="AriasOsma"
DISK_NAME="OsmaArias.vdi"
BASE_DIR='/c/Users/Julian/VirtualBox VMs'
DISK_PATH_A="$BASE_DIR/$VM_A/$DISK_NAME"
DISK_PATH_B="$BASE_DIR/$VM_B/$DISK_NAME"
STORAGE_CTL="SATA Controller"

STATUS_A=$(VBoxManage showvminfo "$VM_A" --machinereadable | grep -c 'VMState="poweroff"')
STATUS_B=$(VBoxManage showvminfo "$VM_B" --machinereadable | grep -c 'VMState="poweroff"')

if [ $STATUS_A -eq 0 ]; then
  echo "Error: La máquina $VM_A no está apagada."
  exit 1
fi

if [ $STATUS_B -eq 0 ]; then
  echo "Error: La máquina $VM_B no está apagada."
  exit 1
fi

echo "Ambas máquinas están apagadas. Verificando la ubicación actual del disco..."

DISK_ATTACHED_A=$(VBoxManage showvminfo "$VM_A" | grep "Location" | grep -c "$DISK_PATH" )
DISK_ATTACHED_B=$(VBoxManage showvminfo "$VM_B" | grep "Location" | grep -c "$DISK_PATH" )


if [ $DISK_ATTACHED_A -eq 1 ]; then
  echo "El disco está conectado a $VM_A. Desconectando y moviendo el disco a la carpeta de $VM_B..."

  VBoxManage storageattach "$VM_A" --storagectl "$STORAGE_CTL" --port 0 --device 0 --type hdd --medium none
  VBoxManage modifymedium "$DISK_PATH_A" --move "$DISK_PATH_B"
  VBoxManage storageattach "$VM_B" --storagectl "$STORAGE_CTL" --port 0 --device 0 --type hdd --medium "$DISK_PATH_B"

  echo "El disco ha sido movido de $VM_A a $VM_B con éxito."

elif [ $DISK_ATTACHED_B -eq 1 ]; then
  echo "El disco está conectado a $VM_B. Desconectando y moviendo el disco a la carpeta de $VM_A..."

  VBoxManage storageattach "$VM_B" --storagectl "$STORAGE_CTL" --port 0 --device 0 --type hdd --medium none
  VBoxManage modifymedium "$DISK_PATH_B" --move "$DISK_PATH_A"
  VBoxManage storageattach "$VM_A" --storagectl "$STORAGE_CTL" --port 0 --device 0 --type hdd --medium "$DISK_PATH_A"

  echo "El disco ha sido movido de $VM_B a $VM_A con éxito."

else
  echo "Error: El disco no está conectado a ninguna de las máquinas."
  exit 1
fi
