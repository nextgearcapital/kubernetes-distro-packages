#!/bin/bash

    # deb
    # /etc/init.d/
    # --deb-init FILEPATH           (deb only) Add FILEPATH as an init script
    # --deb-default FILEPATH        (deb only) Add FILEPATH as /etc/default configuration
    # --deb-upstart FILEPATH        (deb only) Add FILEPATH as an upstart script

ETCD_VERSION=2.3.1

rm -rf etcd/source
mkdir etcd/source

curl -L  https://github.com/coreos/etcd/releases/download/v$ETCD_VERSION/etcd-v$ETCD_VERSION-linux-amd64.tar.gz | tar xvz -C etcd/source --strip-components 1

fpm -s dir -n "etcd" \
-p etcd/builds \
-C ./etcd -v "$ETCD_VERSION" \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install etcd/scripts/deb/after-install.sh \
--before-install etcd/scripts/deb/before-install.sh \
--after-remove etcd/scripts/deb/after-remove.sh \
--before-remove etcd/scripts/deb/before-remove.sh \
--deb-init etcd/services/initd/etcd \
--license "Apache Software License 2.0" \
--maintainer "NextGear Capital <devops@nextgearcapital.com>" \
--vendor "NextGear Capital" \
--description "Etcd binaries and services" \
source/etcd=/usr/bin/etcd \
source/etcdctl=/usr/bin/etcdctl


# systemd version - add a .0 to the version
fpm -s dir -n "etcd" \
-p etcd/builds/systemd \
-C ./etcd -v "$ETCD_VERSION~systemd" \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--after-install etcd/scripts/deb/systemd/after-install.sh \
--before-install etcd/scripts/deb/systemd/before-install.sh \
--after-remove etcd/scripts/deb/systemd/after-remove.sh \
--before-remove etcd/scripts/deb/systemd/before-remove.sh \
--config-files etc/etcd \
--license "Apache Software License 2.0" \
--maintainer "NextGear Capital <devops@nextgearcapital.com>" \
--vendor "NextGear Capital" \
--description "Etcd binaries and services" \
source/etcd=/usr/bin/etcd \
source/etcdctl=/usr/bin/etcdctl \
services/systemd/etcd.service=/lib/systemd/system/etcd.service \
config/systemd/etcd.conf=/etc/etcd/etcd.conf
