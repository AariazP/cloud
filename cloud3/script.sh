#!/bin/bash

#Cargar variables de ambiente
source .env
#crear disco
VBoxManage createmedium disk --filename "$DISK_PATH" --size "$SIZE" --format VDI
if [ -f "$DISK_NAME" ]; then
	echo "Se ha creado el disco $NAME en la ruta $DISK_PATH"
fi

#adjuntar el disco duro virtual
VBoxManage storageattach "$VM_NAME" --storagectl "$CONTROLLER" --port $PORT --device $DEVICE --type hdd --medium "$DISK_PATH"

#verificar que si se adjunto

if [ $? -eq 0 ]; then
	echo "Disco adjuntado correctamente"

	#levantar la maquina

	VBoxManage startvm "$VM_NAME" --type gui

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

sleep 35

# Variables iniciales
REPO_URL="git@github.com:usuario/SSH-VM.git" # Cambia esto por tu URL del repo
CLONE_DIR="/ruta/especifica/SSH-VM"          # Cambia esto por la ruta donde quieres clonar el repo

# Función para clonar el repositorio
clone_repo() {
	if [ -d "$CLONE_DIR" ]; then
		echo "El repositorio ya existe, eliminando $CLONE_DIR ..."
		rm -rf "$CLONE_DIR"
	fi

	echo "Clonando el repositorio..."
	git clone "$REPO_URL" "$CLONE_DIR"

	if [ $? -ne 0 ]; then
		echo "Error al clonar el repositorio."
		exit 1
	fi
}

# Clonar el repositorio
clone_repo

# Navegar a la carpeta del repositorio
cd "$CLONE_DIR" || exit

# Obtener la última carpeta modificada o agregada en el último commit
LAST_COMMIT=$(git log -1 --pretty=format:"%H") # Obtener el hash del último commit
LAST_DIR=$(git diff-tree --no-commit-id --name-only -r "$LAST_COMMIT" | grep / | tail -n 1)

if [ -z "$LAST_DIR" ]; then
	echo "No se encontró ninguna carpeta modificada en el último commit."
	exit 1
fi

# Leer la IP desde ip_address.txt en la carpeta más reciente
IP_FILE="$CLONE_DIR/$LAST_DIR/ip_address.txt"

if [ ! -f "$IP_FILE" ]; then
	echo "No se encontró el archivo ip_address.txt en $LAST_DIR"
	exit 1
fi

# Guardar la IP y rutas en variables
IP_ADDRESS=$(cat "$IP_FILE")
FOLDER_PATH="$CLONE_DIR/$LAST_DIR"
SSH_KEY_PATH="$CLONE_DIR/$LAST_DIR/ssh_key"

# Mostrar la información
echo "Última carpeta modificada/agregada: $FOLDER_PATH"
echo "IP leída: $IP_ADDRESS"
echo "Ruta de la llave SSH: $SSH_KEY_PATH"
