#!/bin/bash
set -e

# Validar variables de entorno
if [ -z "$PASSWORD" ]; then
    echo "Error: PASSWORD no está definida"
    exit 1
fi

if [ -z "$IPA_SERVER_IP" ]; then
    echo "Error: IPA_SERVER_IP no está definida"
    exit 1
fi

# Usar variables de entorno
REALM="IPA.TEST"
DOMAIN="ipa.test"
ADMIN_PASSWORD="${PASSWORD}"
DS_PASSWORD="${PASSWORD}"
IP_ADDRESS="${IPA_SERVER_IP}"

# Instalar FreeIPA server
ipa-server-install \
    --unattended \
    --realm="${REALM}" \
    --domain="${DOMAIN}" \
    --ds-password="${DS_PASSWORD}" \
    --admin-password="${ADMIN_PASSWORD}" \
    --ip-address="${IP_ADDRESS}" \
    --no-ntp

# Iniciar servicios de systemd
exec /usr/sbin/init