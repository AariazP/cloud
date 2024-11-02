import requests
import subprocess
import time

# Configuración Prometheus
PROMETHEUS_URL = "http://localhost:9090"
CPU_THRESHOLD_HIGH = 80  # Umbral superior para CPU
CPU_THRESHOLD_LOW = 20   # Umbral inferior para CPU
RAM_THRESHOLD_HIGH = 80  # Umbral superior para RAM
RAM_THRESHOLD_LOW = 20   # Umbral inferior para RAM

# Variables de control
escalado_ejecutado = False
estado_alto_uso = {}
estado_bajo_uso = {}
ip_nombre_map = {}

def load_ip_nombre_mapping(filename):
    try:
        with open(filename, 'r') as file:
            for line in file:
                ip, nombre_vm = line.strip().split(':')
                print("Se lee", ip, nombre_vm)
                ip_nombre_map[ip] = nombre_vm
    except Exception as e:
        print(f"Error al cargar el archivo de mapeo: {e}")

def get_metric(query):
    try:
        response = requests.get(f"{PROMETHEUS_URL}/api/v1/query", params={'query': query})
        response.raise_for_status()
        results = response.json().get('data', {}).get('result', [])
        if not results:
            print("Advertencia: No se obtuvieron resultados para la consulta.")
        return results
    except requests.RequestException as e:
        print(f"Error al conectar con Prometheus: {e}")
        return []

def scale_up():
    print("Ejecutando script de escalado...")
    subprocess.run(["./script.sh"])

def shutdown_machine(ip_address):
    load_ip_nombre_mapping("nombres_vm.txt")
    machine_name = ip_nombre_map.get(ip_address)
    print("El nombre de la máquina que se va a apagar:", machine_name)
    if machine_name == "node_1":
        print("No se apaga la máquina 1")
    elif machine_name:
        print(f"Apagando máquina {machine_name} por bajo uso de recursos...")
        subprocess.run(["/home/master/fp/shutdowm_machine.sh", machine_name])
    else:
        print(f"No se encontró la máquina para la IP: {ip_address}")

def monitor():
    global escalado_ejecutado

    cpu_query = '100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) by (instance))'
    ram_query = '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100'

    # Obtiene métricas de CPU
    cpu_usage = get_metric(cpu_query)
    if not cpu_usage:
        print("No se obtuvieron resultados para la consulta de CPU.")
    for instance in cpu_usage:
        usage = float(instance['value'][1])  # Convierte a float el valor de uso de CPU
        ip_address = instance['metric'].get('instance', 'N/A')
        if ip_address == 'N/A':
            print("La métrica no contiene la clave 'instance'. Saltando esta entrada.")
            continue

        usage = int(usage)
        print(f"Uso de CPU en {ip_address}: {usage}%")

        if usage > CPU_THRESHOLD_HIGH:
            print(f"Uso de CPU alto en {ip_address}: {usage}%")
            estado_alto_uso[ip_address] = estado_alto_uso.get(ip_address, 0) + 1
            estado_bajo_uso[ip_address] = 0
            if estado_alto_uso[ip_address] >= 4:
                scale_up()
                escalado_ejecutado = True
                estado_alto_uso[ip_address] = 0
        elif usage < CPU_THRESHOLD_LOW:
            print(f"Uso de CPU bajo en {ip_address}: {usage}%")
            estado_bajo_uso[ip_address] = estado_bajo_uso.get(ip_address, 0) + 1
            estado_alto_uso[ip_address] = 0
            if estado_bajo_uso[ip_address] >= 4:
                shutdown_machine(ip_address)
                estado_bajo_uso[ip_address] = 0

    # Obtiene métricas de RAM
    ram_usage = get_metric(ram_query)
    if not ram_usage:
        print("No se obtuvieron resultados para la consulta de RAM.")
    for instance in ram_usage:
        usage = float(instance['value'][1])
        ip_address = instance['metric'].get('instance', 'N/A')
        if ip_address == 'N/A':
            print("La métrica no contiene la clave 'instance'. Saltando esta entrada.")
            continue

        usage = int(usage)
        print(f"Uso de RAM en {ip_address}: {usage}%")
        if usage > RAM_THRESHOLD_HIGH:
            print(f"Uso de RAM alto en {ip_address}: {usage}%")
            estado_alto_uso[ip_address] = estado_alto_uso.get(ip_address, 0) + 1
            estado_bajo_uso[ip_address] = 0
            if estado_alto_uso[ip_address] >= 4:
                if not escalado_ejecutado:
                    scale_up()
                    escalado_ejecutado = True
                estado_alto_uso[ip_address] = 0
        elif usage < RAM_THRESHOLD_LOW:
            print(f"Uso de RAM bajo en {ip_address}: {usage}%")
            estado_bajo_uso[ip_address] = estado_bajo_uso.get(ip_address, 0) + 1
            estado_alto_uso[ip_address] = 0
            if estado_bajo_uso[ip_address] >= 4:
                shutdown_machine(ip_address)
                estado_bajo_uso[ip_address] = 0

if __name__ == "__main__":
    load_ip_nombre_mapping("nombres_vm.txt")
    if not escalado_ejecutado:
        scale_up()
        escalado_ejecutado = True

    while True:
        monitor()
        time.sleep(15)

