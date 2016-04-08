#!/bin/bash
getent group kube-cert >/dev/null || groupadd -r kube-cert
mkdir -p -m 755 /var/run/kubernetes

getent group kube >/dev/null || groupadd -r kube
getent passwd kube >/dev/null || useradd -r -g kube -d /var/run/kubernetes -s /sbin/nologin \
        -c "Kubernetes user" kube

chown -R kube /var/run/kubernetes
chgrp -R kube /var/run/kubernetes

SERVICE_ACCOUNT_KEY="/etc/kubernetes/service_account.key"
# Generate ServiceAccount key if needed
if [ ! -f "${SERVICE_ACCOUNT_KEY}" ]; then
  mkdir -p "$(dirname ${SERVICE_ACCOUNT_KEY})"
  openssl genrsa -out "${SERVICE_ACCOUNT_KEY}" 2048 2>/dev/null
fi
