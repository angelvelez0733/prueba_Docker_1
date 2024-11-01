# Dockerfile para FreeIPA con configuración de firewall
FROM rockylinux:9

# Establecer variables de entorno
ENV container=docker
ENV IPA_SERVER_IP=${IPA_SERVER_IP:-192.168.211.194}
ENV PASSWORD=${PASSWORD:-Angel123*}

# Instalar FreeIPA, herramientas de red y firewall
RUN dnf -y update && \
    dnf -y install \
    freeipa-server \
    freeipa-server-dns \
    freeipa-server-trust \
    iptables \
    iptables-services \
    net-tools \
    && dnf clean all

# Copiar scripts de configuración
COPY firewall.sh /usr/local/bin/firewall.sh
COPY install-freeipa.sh /usr/local/bin/install-freeipa.sh

# Hacer scripts ejecutables
RUN chmod +x /usr/local/bin/firewall.sh \
    && chmod +x /usr/local/bin/install-freeipa.sh

# Preparar para systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Volúmenes para persistencia
VOLUME [ "/sys/fs/cgroup", "/storage" ]

# HealthCheck para firewall
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD iptables -L > /dev/null || exit 1

# Comando de inicio combinado
CMD ["/bin/bash", "-c", "/usr/local/bin/firewall.sh & /usr/local/bin/install-freeipa.sh"]