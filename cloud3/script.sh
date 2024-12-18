# Cargar variables de ambiente
source .env

# Función para clonar o actualizar el repositorio
clone_or_pull_repo() {
	if [ -d "$CLONE_DIR" ]; then
		echo "Repositorio ya existe. Realizando pull..."
		cd "$CLONE_DIR" || exit
		git pull origin main
	else
		echo "Clonando el repositorio..."
		git clone "$REPO_URL" "$CLONE_DIR"
		cd "$CLONE_DIR" || exit
	fi
}

# Clonar o actualizar el repositorio antes de iniciar la VM
clone_or_pull_repo
# Verificar si el disco ya existe
if [ -f "$DISK_PATH" ]; then
	echo "El disco $DISK_PATH ya existe. No se creará uno nuevo."
else
	# Crear disco
	VBoxManage createmedium disk --filename "$DISK_PATH" --size "$SIZE" --format VDI
	if [ -f "$DISK_PATH" ]; then
		echo "Se ha creado el disco en la ruta $DISK_PATH"
	else
		echo "Error al crear el disco en $DISK_PATH"
		exit 1
	fi
fi

# Adjuntar el disco duro virtual
VBoxManage storageattach "$VM_NAME" --storagectl "$CONTROLLER" --port $PORT --device $DEVICE --type hdd --medium "$DISK_PATH"

# Verificar que se adjuntó correctamente
if [ $? -eq 0 ]; then
	echo "Disco adjuntado correctamente"

	# Levantar la máquina virtual
	VBoxManage startvm "$VM_NAME" --type gui

	if [ $? -eq 0 ]; then
		echo "VM levantada exitosamente"
	else
		echo "Error al levantar la VM"
		exit 1
	fi
else
	echo "Error adjuntando el disco"
	exit 1
fi

# Esperar a que la máquina levante
sleep 35

# Realizar git pull después de que la VM esté arriba (significa que ya subió las credenciales)
clone_or_pull_repo

# Obtener la última carpeta (basada en la IP)
LAST_COMMIT=$(git log -1 --pretty=format:"%H") # Obtener el hash del último commit
LAST_IP_DIR=$(git diff-tree --no-commit-id --name-only -r "$LAST_COMMIT" | grep / | cut -d '/' -f 1 | tail -n 1)

if [ -z "$LAST_IP_DIR" ]; then
	echo "No se encontró ninguna carpeta de IP modificada en el último commit."
	exit 1
fi

# Definir las rutas a los archivos de la carpeta correspondiente a la IP
IP_FILE="$CLONE_DIR/$LAST_IP_DIR/ip_address.txt"
SSH_KEY_PATH="$CLONE_DIR/$LAST_IP_DIR/ssh_key"

# Verificar que el archivo de la IP existe
if [ ! -f "$IP_FILE" ]; then
	echo "No se encontró el archivo ip_address.txt en $LAST_IP_DIR"
	exit 1
fi

# Guardar la IP y la ruta de la llave SSH
IP_ADDRESS=$(cat "$IP_FILE")

# Mostrar la información
echo "Última carpeta (IP) modificada: $LAST_IP_DIR"
echo "IP leída: $IP_ADDRESS"
echo "Ruta de la llave SSH: $SSH_KEY_PATH"

# cambiar permisos a la llave SSH
chmod 600 "$SSH_KEY_PATH"

# Transferir el script sin interacción para 'known_hosts'
scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$FORMAT_SCRIPT" "$USER@$IP_ADDRESS:$REMOTE_PATH"

# Ejecutar el script remoto sin interacción para 'known_hosts'
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$IP_ADDRESS" "bash $REMOTE_SCRIPT"
