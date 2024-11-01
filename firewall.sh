#!/bin/bash

# Establecer el modo estricto de bash
set -euo pipefail

echo "Iniciando configuración del firewall..."

# Función para manejar errores
handle_error() {
    echo "Error en la línea $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Limpiar reglas anteriores
echo "Limpiando reglas existentes"
iptables -F
iptables -X
iptables -Z

# Establecer políticas por defecto
echo "Estableciendo políticas por defecto"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir tráfico de loopback
echo "Configurando interfaz loopback"
iptables -A INPUT -i lo -j ACCEPT

# Permitir tráfico establecido y relacionado
echo "Permitiendo conexiones establecidas"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Puertos para FreeIPA y servicios adicionales
echo "Configurando puertos para FreeIPA"
FREEIPA_PORTS=(
    22    # SSH
    80    # HTTP
    443   # HTTPS
    389   # LDAP
    636   # LDAPS
    88    # Kerberos
    464   # Kerberos
    749   # Kerberos
)

# Permitir puertos específicos
for port in "${FREEIPA_PORTS[@]}"; do
    iptables -A INPUT -p tcp --dport "$port" -j ACCEPT
done

# Logging para paquetes rechazados
echo "Configurando logging para paquetes rechazados"
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

# Denegar el resto del tráfico
iptables -A INPUT -j DROP

# Guardar configuración (para distribuciones basadas en Red Hat)
echo "Guardando configuración de firewall"
service iptables save

echo "Configuración del firewall completada"

# Mantener el script en ejecución
tail -f /dev/null