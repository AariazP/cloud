#!/bin/bash

# Variables
DISK="/dev/sdb"                  # Cambia esto al dispositivo que quieras formatear
PARTITION="${DISK}1"             # La partición a crear y formatear
MOUNT_POINT="/mnt/external_disk" # Punto de montaje opcional
USER="user"                      # Usuario que tendrá acceso al disco

# Listar los discos y particiones
echo "Listando discos disponibles..."
lsblk
echo "Disco seleccionado: $DISK"

# Formatear el disco
echo "Formateando el disco $DISK con GPT..."
parted $DISK mklabel gpt --script

# Crear una partición que ocupe todo el espacio
echo "Creando partición primaria en $DISK..."
parted $DISK mkpart primary ext4 0% 100% --script

# Esperar a que la partición se cree
sleep 1 # Puedes ajustar el tiempo según sea necesario

# Formatear la partición como ext4
if [ -e "$PARTITION" ]; then
	echo "Formateando la partición $PARTITION como ext4..."
	mkfs.ext4 $PARTITION
else
	echo "La partición $PARTITION no existe."
	exit 1
fi

# Montar el disco (opcional)
echo "Montando la partición en $MOUNT_POINT..."
mkdir -p $MOUNT_POINT
mount $PARTITION $MOUNT_POINT

# Verificar si el montaje fue exitoso
if mountpoint -q $MOUNT_POINT; then
	echo "Montaje exitoso en $MOUNT_POINT."
else
	echo "Error al montar la partición. Verifica el tipo de sistema de archivos."
	exit 1
fi

# Mostrar detalles del disco
echo "Detalles de la nueva partición:"
lsblk -f | grep $DISK

echo "Configurando permisos"
chmod 700 $MOUNT_POINT

echo "Configurando propietario"
chown -R $USER:$USER $MOUNT_POINT

echo "Proceso completado."

lsblk
