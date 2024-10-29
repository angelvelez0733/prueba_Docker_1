# DockerFile
FROM ubuntu:20.04

# Establecer variables de entorno para evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

## Instalar iptables y otras dependencias
RUN apt-get update && apt-get install -y \
    iptables \
    iproute2 \
    net-tools && \
    apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Copiar el script de configuración
COPY firewall.sh /usr/local/bin/firewall.sh

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/firewall.sh

## HealthCheck para verificar que el firewall está funcionando
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD iptables -L > /dev/null || exit 1

# Comando para ejecutar el el script al iniciar el contenedor
CMD ["bash", "/usr/local/bin/firewall.sh"]
