#!/bin/bash

# Variables
MACHINE_A="Ubuntu1"
MACHINE_B="Ubuntu2"
STORAGECTL="SATA Controller"
PORT=0
DEVICE=0
DISK_A="/home/arias/VirtualBox VMs/${MACHINE_A}/${MACHINE_A}.vdi"
DISK_B="/home/arias/VirtualBox VMs/${MACHINE_B}/${MACHINE_B}.vdi"

# Función para mostrar el menú
menu() {
	echo "Menú de opciones:"
	echo "1. Mover disco de la máquina 1 a la 2"
	echo "2. Mover disco de la máquina 2 a la 1"
	echo "3. Salir"
	read -p "Selecciona una opción (1/2/3): " op

	case $op in
	1)
		opcion1
		;;
	2)
		opcion2
		;;
	3)
		salir
		;;
	*)
		echo "Opción no válida."
		menu
		;;
	esac
}

# Opción 1: Mover disco de la máquina A a la B
opcion1() {
	# Desacoplar
	VBoxManage storageattach "$MACHINE_A" --storagectl "$STORAGECTL" --port $PORT --device $DEVICE --type hdd --medium none
	# Mover
	VBoxManage modifymedium disk "$DISK_A" --move "$DISK_B"
	# Acoplar
	VBoxManage storageattach "$MACHINE_B" --storagectl "$STORAGECTL" --port $PORT --device $DEVICE --type hdd --medium "$DISK_B"
	read -p "Presiona [Enter] para continuar..."
	menu
}

# Opción 2: Mover disco de la máquina B a la A
opcion2() {
	# Desacoplar
	VBoxManage storageattach "$MACHINE_B" --storagectl "$STORAGECTL" --port $PORT --device $DEVICE --type hdd --medium none
	# Mover
	VBoxManage modifymedium disk "$DISK_B" --move "$DISK_A"
	# Acoplar
	VBoxManage storageattach "$MACHINE_A" --storagectl "$STORAGECTL" --port $PORT --device $DEVICE --type hdd --medium "$DISK_A"
	read -p "Presiona [Enter] para continuar..."
	menu
}

# Opción 3: Salir
salir() {
	echo "Saliendo del Menú"
	exit 0
}

# Mostrar el menú
menu
