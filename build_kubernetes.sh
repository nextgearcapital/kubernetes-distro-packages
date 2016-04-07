#!/bin/bash

K8S_VERSION=${K8S_VERSION:-1.2.1}
rm -rf kubernetes/source/kubernetes/v$K8S_VERSION
rm -f kubernetes/master/kubernetes-master_$K8S_VERSION_amd64.deb
rm -f kubernetes/master/kubernetes-node_$K8S_VERSION_amd64.deb

mkdir -p kubernetes/source/kubernetes/v$K8S_VERSION
cd kubernetes/source/kubernetes/v$K8S_VERSION
curl -L https://storage.googleapis.com/kubernetes-release/release/v$K8S_VERSION/kubernetes.tar.gz | tar xvz
# Nightly
# https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v$K8S_VERSION/kubernetes.tar.gz
tar xfvz kubernetes/server/kubernetes-server-linux-amd64.tar.gz
cd ../../../../

#build_deb_master

    # deb
    # /etc/init.d/
    # --deb-init FILEPATH           (deb only) Add FILEPATH as an init script
    # --deb-default FILEPATH        (deb only) Add FILEPATH as /etc/default configuration
    # --deb-upstart FILEPATH        (deb only) Add FILEPATH as an upstart script


fpm -s dir -n "kubernetes-master" \
-p kubernetes/builds \
-C ./kubernetes/master -v $K8S_VERSION \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install kubernetes/master/scripts/deb/after-install.sh \
--before-install kubernetes/master/scripts/deb/before-install.sh \
--after-remove kubernetes/master/scripts/deb/after-remove.sh \
--before-remove kubernetes/master/scripts/deb/before-remove.sh \
--deb-init kubernetes/master/services/initd/kube-apiserver \
--deb-init kubernetes/master/services/initd/kube-controller-manager \
--deb-init kubernetes/master/services/initd/kube-scheduler \
--deb-init kubernetes/master/services/initd/kubelet \
--deb-default kubernetes/master/initd_config/kube-apiserver \
--deb-default kubernetes/master/initd_config/kube-controller-manager \
--deb-default kubernetes/master/initd_config/kube-scheduler \
--deb-default kubernetes/master/initd_config/kubelet \
--license "Apache Software License 2.0" \
--maintainer "NextGear Capital <devops@nextgearcapital.com>" \
--vendor "NextGear Capital" \
--description "Kubernetes master binaries and services" \
--url "https://www.nextgearcapital.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/kube-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/kube-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-scheduler=/usr/bin/kube-scheduler \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubectl=/usr/bin/kubectl \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/hyperkube=/usr/bin/hyperkube \
etc/kubernetes/manifests

# systemd version
fpm -s dir -n "kubernetes-master" \
-p kubernetes/builds/systemd \
-C ./kubernetes/master -v "$K8S_VERSION~systemd" \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install kubernetes/master/scripts/deb/systemd/after-install.sh \
--before-install kubernetes/master/scripts/deb/systemd/before-install.sh \
--after-remove kubernetes/master/scripts/deb/systemd/after-remove.sh \
--before-remove kubernetes/master/scripts/deb/systemd/before-remove.sh \
--license "Apache Software License 2.0" \
--maintainer "NextGear Capital <devops@nextgearcapital.com>" \
--vendor "NextGear Capital" \
--description "Kubernetes master binaries and services" \
--url "https://www.nextgearcapital.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/kube-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/kube-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-scheduler=/usr/bin/kube-scheduler \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubectl=/usr/bin/kubectl \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/hyperkube=/usr/bin/hyperkube \
services/systemd/kube-apiserver.service=/lib/systemd/system/kube-apiserver.service \
services/systemd/kube-controller-manager.service=/lib/systemd/system/kube-controller-manager.service \
services/systemd/kube-scheduler.service=/lib/systemd/system/kube-scheduler.service \
services/systemd/kubelet.service=/lib/systemd/system/kubelet.service \
etc/kubernetes/master/kubelet.conf \
etc/kubernetes/master/apiserver.conf \
etc/kubernetes/master/config.conf \
etc/kubernetes/master/controller-manager.conf \
etc/kubernetes/master/scheduler.conf \
etc/kubernetes/manifests


# post launch script for addons
# skydns enable
# Kubernetes installs do not configure the nodes' resolv.conf files to use the cluster DNS by default, because that process is inherently environment-specific.
# This should probably be implemented eventually.

#build_deb_node

# services
# deps etcd, docker (etcd.service, docker.service)
# kube-proxy.service
# kube-kubelet.service
# cadvisor.service?

# TODO later
# /var/lib/kubelet/kubernetes_auth
# {"BearerToken": "SF839TwEqeyO2mwbOtQMZFJ8nQIu7asb", "Insecure": true }
fpm -s dir -n "kubernetes-node" \
-p kubernetes/builds \
-C ./kubernetes/node -v $K8S_VERSION \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install kubernetes/node/scripts/deb/after-install.sh \
--before-install kubernetes/node/scripts/deb/before-install.sh \
--after-remove kubernetes/node/scripts/deb/after-remove.sh \
--before-remove kubernetes/node/scripts/deb/before-remove.sh \
--deb-default kubernetes/node/initd_config/kubelet \
--deb-default kubernetes/node/initd_config/kube-proxy \
--deb-init kubernetes/node/services/initd/kubelet \
--deb-init kubernetes/node/services/initd/kube-proxy \
--license "Apache Software License 2.0" \
--maintainer "NextGear Capital <devops@nextgearcapital.com>" \
--vendor "NextGear Capital" \
--description "Kubernetes node binaries and services" \
--url "https://www.nextgearcapital.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-proxy=/usr/bin/kube-proxy \
etc/kubernetes/manifests


# systemd version
fpm -s dir -n "kubernetes-node" \
-p kubernetes/builds/systemd \
-C ./kubernetes/node -v "$K8S_VERSION~systemd" \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install kubernetes/node/scripts/deb/systemd/after-install.sh \
--before-install kubernetes/node/scripts/deb/systemd/before-install.sh \
--after-remove kubernetes/node/scripts/deb/systemd/after-remove.sh \
--before-remove kubernetes/node/scripts/deb/systemd/before-remove.sh \
--config-files etc/kubernetes/node \
--license "Apache Software License 2.0" \
--maintainer "NextGear Capital <devops@nextgearcapital.com>" \
--vendor "NextGear Capital" \
--description "Kubernetes node binaries and services" \
--url "https://www.nextgearcapital.com" \
etc/kubernetes/node/config.conf \
etc/kubernetes/node/kubelet.conf \
etc/kubernetes/node/kube-proxy.conf \
services/systemd/kubelet.service=/lib/systemd/system/kubelet.service \
services/systemd/kube-proxy.service=/lib/systemd/system/kube-proxy.service \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-proxy=/usr/bin/kube-proxy \
etc/kubernetes/manifests
