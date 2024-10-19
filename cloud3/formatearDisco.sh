#!/bin/bash

# Variables
DISK="/dev/sdb"                  # Cambia esto al dispositivo que quieras formatear
PARTITION="${DISK}1"             # La partición a crear y formatear
MOUNT_POINT="/mnt/external_disk" # Punto de montaje opcional

# Listar los discos y particiones
echo "Listando discos disponibles..."
lsblk
echo "Disco seleccionado: $DISK"

# Formatear el disco
echo "Formateando el disco $DISK con GPT..."
sudo parted $DISK mklabel gpt --script

# Crear una partición que ocupe todo el espacio
echo "Creando partición primaria en $DISK..."
sudo parted $DISK mkpart primary ext4 0% 100% --script

# Formatear la partición como ext4
echo "Formateando la partición $PARTITION como ext4..."
sudo mkfs.ext4 $PARTITION

# Montar el disco (opcional)
echo "Montando la partición en $MOUNT_POINT..."
mkdir -p $MOUNT_POINT
sudo mount $PARTITION $MOUNT_POINT

# Mostrar detalles del disco
echo "Detalles de la nueva partición:"
sudo lsblk -f | grep $DISK

echo "Configurando permisos"
sudo chmod 777 /mnt/external_disk

echo "Proceso completado."

lsblk
