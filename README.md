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
$ tailscale ip
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