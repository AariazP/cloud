#!/bin/bash

IP_ADDRESS='192.168.100.137'
USER='aariaz'
MACHINE=$1
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"
PROMETHEUS_CFG="/etc/prometheus/nodes.json"

ssh $USER@$IP_ADDRESS -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "bash /Users/aariaz/Desktop/cloud/fp/shutdown_machine.sh $MACHINE"


# Servicio de HAProxy
HAPROXY_SERVICE="haproxy"

# Remover línea del archivo de configuración de HAProxy que contiene el nombre de la máquina virtual usando ed
echo "Modificando el archivo de configuración de HAProxy..."
ed -s "$HAPROXY_CFG" <<EOF
g/$MACHINE/d
w
q
EOF


# Reiniciar el servicio de HAProxy
echo "Reiniciando el servicio HAProxy..."
systemctl restart "$HAPROXY_SERVICE"

#Eliminar nombre del archivo de nombres
sed -i "/$MACHINE/d" '/home/master/fp/nombres_vm.txt'

# Eliminar entrada del archivo de configuración de Prometheus
echo "Modificando el archivo de configuración de Prometheus..."
ed -s "$PROMETHEUS_CFG" <<EOF
g/192.168.100.202:9100/d
w
q
EOF
#Reiniciar el servicio de prometheus
systemctl restart prometheus 


echo "Script finalizado."
