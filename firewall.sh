#!bin/bash

# Establecer el modo estricto de bash
set -euo pipefail

echo "Iniciando configuración del firewall..."

# limpiar reglas anteriores
iptables -F
iptables -X
iptables -Z

# Establecer politicas por defecto
echo "Estableciendo politicas por defecto..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir tráfico de loopback
echo "Configurando interfaz loopback..."
iptables -A INPUT -i lo -j ACCEPT

# Permitir tráfico establecido y relacionado
echo "Permitiendo conexiones establecidas..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir Mysql
echo "Permitiendo acceso a MYSQL"
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

# Permitir purtos específicos 
iptables -A INPUT -p tcp --dport 22 -j ACCEPT # SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT # HTTPS

# Logging para pauqetes rechazados 
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

# Denegar el resto del tráfico
iptables -A INPUT -j DROP

echo "Configuración del firewall completada"

# Mantener el script en ejecución
tail -f /dev/null