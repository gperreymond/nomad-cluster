# NOMAD CLUSTER

## Setup

* https://developer.hashicorp.com/vagrant/downloads

```sh
# install dependencies with asdf
$ .wtf/install-dependencies.sh
$ pip install --upgrade pip
$ pip install cryptography
$ pip install ansible
$ pip install ansible-dev-tools
$ pip install ansible-lint
$ ansible-galaxy collection install community.docker
```

## Run Vagrant

```sh
# remove old ssh entries if needed
$ ssh-keygen -R [127.0.0.1]:2201
$ ssh-keygen -R [127.0.0.1]:2202
$ ssh-keygen -R [127.0.0.1]:2203
# prepare
$ vagrant up
# validate fingerprints
$ ssh vagrant@127.0.0.1 -p 2201
$ ssh vagrant@127.0.0.1 -p 2202
$ ssh vagrant@127.0.0.1 -p 2203
# get informations about ssh on vagrant
$ vagrant ssh-config
```

## Install and use Tailscale

* https://login.tailscale.com/admin/machines

```sh
$ curl -fsSL https://tailscale.com/install.sh | sh
$ tailscale up
```

## Run Ansible

* https://www.digitalocean.com/community/tutorials/how-to-use-vault-to-protect-sensitive-ansible-data

```sh
# prepare ansible vault: create "ansible-vault-password.txt"
# generate nomad certificats
$ .wtf/nomad-generate-certificats.sh -region global -datacenter infra
# generate nomad gossip encryption key
$ .wtf/nomad-gossip-encryption-key.sh -region global -datacenter infra
# run playbooks
$ ansible-playbook -i ansible/inventories/infra/inventory.ini ansible/playbook-infra.yml
# boostrap nomad acl after the first "ansible-playbook"
$ .wtf/nomad-acl-bootstrap.sh -region global -datacenter infra
```

## Usefull commands

```sh
$ nomad system gc -tls-skip-verify
$ nomad system reconcile summaries -tls-skip-verify
$ dig SRV whoami-http.default.service.nomad @[nomad_cluster_ip_from_tailscale]
```

## Run Kubernetes with k0s

```sh
$ eval $(ssh-agent)
$ k0sctl apply --config k0sctl.yaml
$ k0sctl kubeconfig --config k0sctl.yaml > kubeconfig
$ kubectl --kubeconfig kubeconfig get pods
$ k0sctl reset --config k0sctl.yaml
```

## Documentations

* https://docs.k0sproject.io/stable/k0sctl-install/
* https://docs.k0sproject.io/v1.23.6+k0s.2/configuration/#specnetwork
* https://github.com/ituoga/coredns-nomad
