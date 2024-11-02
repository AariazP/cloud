#!/bin/bash

IP_ADDRESS='192.168.100.137'
USER='aariaz'
SCRIPT_PATH='/Users/aariaz/Desktop/cloud/fp/script.sh'
TARGETS_FILE='/etc/prometheus/nodes.json'
CLONE_DIR="/home/master/SSH-VM"
REPO_URL="https://github.com/AariazP/SSH-VM.git"
REPO_NAME="SSH-VM"
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

clone_or_pull_repo

/home/master/fp/clonarVm.sh | grep "Creando la máquina virtual"

sleep 30

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
IP_ADDRESS_VM=$(cat "$IP_FILE")

# Mostrar la información
echo "Última carpeta (IP) modificada: $LAST_IP_DIR"
echo "IP leída: $IP_ADDRESS_VM"
echo "Ruta de la llave SSH: $SSH_KEY_PATH"

# cambiar permisos a la llave SSH
chmod 600 "$SSH_KEY_PATH"

# Función para agregar un nuevo nodo al archivo JSON
add_target() {

  # Inicializa el archivo JSON si está vacío
  if [ ! -f "$TARGETS_FILE" ] || [ ! -s "$TARGETS_FILE" ]; then
    echo '[]' > "$TARGETS_FILE"
  fi

  # Lee el contenido actual del archivo JSON, excluyendo los corchetes inicial y final
  current_targets=$(jq -c '.[]' "$TARGETS_FILE" | paste -sd, -)

  # Verifica si current_targets no está vacío
  if [ -n "$current_targets" ]; then
    # Construye el nuevo contenido del archivo con el nuevo target
    echo "[${current_targets},{\"targets\": [\"${IP_ADDRESS_VM}:9100\"], \"labels\": {\"job\": \"node_exporter\"}}]" > "$TARGETS_FILE"
  else
    echo "[{\"targets\": [\"${IP_ADDRESS_VM}:9100\"], \"labels\": {\"job\": \"node_exporter\"}}]" > "$TARGETS_FILE"
  fi

    echo "IP ${IP_ADDRESS_VM}:9100 agregada correctamente a $TARGETS_FILE"
}


# Llama a la función para agregar el nuevo target
add_target

# Recarga la configuración de Prometheus
curl -X POST http://localhost:9090/-/reload

HOSTNAME=$(ssh $USER@$IP_ADDRESS -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null 'cat /Users/aariaz/Desktop/cloud/fp/ultima_maquina.txt')
echo "El nombre de la nueva máquina es: $HOSTNAME"
echo "Agregando al archivo nombres_vm.txt la entrada: $HOSTNAME:$IP_ADDRESS"
echo "$IP_ADDRESS_VM:$HOSTNAME">>'/home/master/fp/nombres_vm.txt'
ROOT='root'

ssh -i $SSH_KEY_PATH $ROOT@$IP_ADDRESS_VM -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " hostnamectl set-hostname $HOSTNAME; exit"

# Asignar argumentos a variables
PUERTO="8000"
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"  # Cambia esta ruta si es necesario


# Comprobar si el archivo de configuración existe
if [ ! -f "$HAPROXY_CFG" ]; then
    echo "El archivo de configuración $HAPROXY_CFG no existe."
    exit 1
fi

# Verificar si ya existe el servidor con la misma IP
if grep -q "server.*$IP_ADDRESS_VM:$PUERTO" "$HAPROXY_CFG"; then
    echo "El servidor con IP $NUEVA_IP y puerto $PUERTO ya está en la configuración."
    exit 0
fi

# Construir la línea del servidor que se va a añadir
NUEVO_SERVIDOR="    server $HOSTNAME $IP_ADDRESS_VM:$PUERTO check"

# Usa ed para agregar la línea al final de la sección backend http_back
echo "/^backend http_back/a
$NUEVO_SERVIDOR
.
w
q" | ed -s "$HAPROXY_CFG"

# Reiniciar HAProxy para aplicar los cambios
systemctl restart haproxy

# Mensaje de éxito
echo "Se ha añadido el servidor con IP $IP_ADDRESS_VM en el puerto $PUERTO a la sección backend http_back de $HAPROXY_CFG y HAProxy se ha reiniciado."




