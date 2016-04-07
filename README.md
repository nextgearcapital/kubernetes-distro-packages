# Kubernetes Linux Distribution Packages Builder

* Requirements:
  * Install [etcd](https://github.com/coreos/etcd) (on master or a separate etcd cluster)
  * Install [docker](https://docs.docker.com/installation) (ubuntu/debian only)

To build Kubernetes:
```sh
./build_kubernetes
```

To build etcd:
```sh
./build_etcd
```

#### Configure Kubernetes Master

*Configure Kubernetes Master*
To configure services, edit configuration files in `/etc/kubernetes/master` or `/etc/kubernetes/node`
To override services, copy `/lib/systemd/system` to `/etc/systemd/system` to override. This allows you to customize local services without worrying about losing changes as the result of a package upgrade.

*Enable HTTPS (optional)*
By default, the apiserver is setup using insecure http and assumes a firewall will provide enough security. To enable https support, certs must be generated. A basic key has already been generated during install at `/srv/kubernetes/server.key`. To generate certs:
```
cd /srv/kubernetes
curl -O -L https://raw.githubusercontent.com/kubernetes/kubernetes/v1.1.2/cluster/saltbase/salt/generate-cert/make-ca-cert.sh
chmod +x make-ca-cert.sh

#Set to your master ip and already chosen cluster ip range
master_ip=127.0.0.1
SERVICE_CLUSTER_IP_RANGE=10.254.0.0/16

#Assumes cluster is named 'kubernetes' for DNS
./make-ca-cert.sh ${master_ip} IP:${master_ip},IP:${SERVICE_CLUSTER_IP_RANGE%.*}.1,DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local;
```

For AWS the external IP can be automatically discovered using:
```
./make-ca-cert.sh _use_aws_external_ip_ (other args...)
```

Update the kubernetes configuration files with the newly generated keys
```
#kube-apiserver
--secure-port=443 --tls-cert-file=/srv/kubernetes/server.cert --tls-private-key-file=/srv/kubernetes/server.key --client-ca-file=/srv/kubernetes/ca.crt

#kube-controller-manager
  --root-ca-file=/srv/kubernetes/ca.crt --service-account-private-key-file=/srv/kubernetes/server.key
```

*Start services*
sudo systemctl start kube-apiserver
sudo systemctl start kube-scheduler
sudo systemctl start kube-controller-manager
sudo systemctl start kubelet

test with
`curl -L http://<master ip>:8080/version`

###### Configure Kubernetes Node

Set `--master=<master ip>` for a node in `/etc/kubernetes/node/kube-proxy.conf` and `--master=<master ip>` in `/etc/kubernetes/node/kubelet.conf`


sudo systemctl start kube-proxy
sudo systemctl start kubelet

Check services are running
`systemctl list-units -t service --all`




### Init.d and Debian 7 (wheezy)/ Ubuntu 14.x (trusty) Configuration

Install docker on [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) or [Debian](https://docs.docker.com/installation/debian/) and [etcd](https://github.com/coreos/etcd)


#### Configure Kubernetes
To configure services, edit the file with the same name in `/etc/default`


Master

```bash
sudo service kube-apiserver start
sudo service kube-scheduler start
sudo service kube-controller-manager start
sudo service kubelet start
```

Configure Node
Set the `--master` for a node in `/etc/default/kube-proxy` and `--api-servers` in `/etc/default/kubelet`

```bash
sudo service kube-proxy start
sudo service kubelet start
```

## Development Build Notes
* Make sure to have fpm installed along with rpmbuild
* run `K8S_VERSION=1.2.0 ./build_kubernetes.sh`

### Vagrant Smoke tests
- CentOS
```
$ cd vagrant/centos; vagrant destroy && vagrant up
$ vagrant ssh master
$ sudo K8S_VERSION=1.2.0 /vagrant/test/master.sh
$ vagrant ssh node
$ sudo K8S_VERSION=1.2.0 /vagrant/test/node.sh
```

- Ubuntu
```
# Trusty
$ cd vagrant/ubuntu/trusty; vagrant destroy && vagrant up
$ vagrant ssh master
$ sudo K8S_VERSION=1.2.0 /vagrant/test/master.sh
$ vagrant ssh node
$ sudo K8S_VERSION=1.2.0 /vagrant/test/node.sh

# Vivid
$ cd vagrant/ubuntu/vivid; vagrant destroy && vagrant up
$ vagrant ssh master
$ sudo K8S_VERSION=1.2.0 /vagrant/test/master.sh
$ vagrant ssh node
$ sudo K8S_VERSION=1.2.0 /vagrant/test/node.sh
```

## Development Requirements

* ruby
* prerequisites:

     `gem install fpm`
