job "etcd-cluster" {
  type = "system"
  constraint {
    attribute = "${meta.NodeType}"
    value     = "control-plane"
  }
  group "etcd-members" {
    network {
      mode = "host"
      port "http" {
        static = 2379
      }
      port "peer" {
        static = 2380
      }
    }
    service {
      name     = "etcd-http"
      provider = "nomad"
      port     = "http"
    }
    service {
      name     = "etcd-peer"
      provider = "nomad"
      port     = "peer"
    }
    task "etcd" {
      driver = "docker"
      config {
        image   = "quay.io/coreos/etcd:v3.5.9"
        command = "etcd"
        ports   = ["http", "peer"]
        volumes = [
          "/home/vagrant/etcd_data:/etcd_data"
        ]
        privileged     = true
        auth_soft_fail = true
      }
      template {
        destination = "local/env.conf"
        env         = true
        change_mode = "restart"
        data        = <<EOF
ETCDCTL_API="3"
ETCD_DATA_DIR="/etcd_data"
ETCD_NAME="{{ env "attr.unique.hostname" }}"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://{{ env "attr.unique.network.ip-address" }}:2380"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://{{ env "attr.unique.network.ip-address" }}:2379"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="2a0d490d-23b2-474b-a88f-d46301e9c83c"
ETCD_INITIAL_CLUSTER="nomad-cluster-1=http://100.119.109.67:2380,nomad-cluster-2=http://100.124.124.5:2380,nomad-cluster-3=http://100.94.153.116:2380"
EOF
      }
      identity {
        env  = true
        file = true
      }
      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}