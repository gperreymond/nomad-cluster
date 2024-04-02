job "vector-metrics" {
  type = "system"
  group "vector" {
    network {
      mode = "host"
      port "http" {
        static = 9876
        to     = 9876
      }
    }
    service {
      name     = "vector-metrics-http"
      provider = "nomad"
      port     = "http"
    }
    task "vector-node" {
      driver = "docker"
      config {
        image          = "timberio/vector:0.37.0-debian"
        ports          = ["http"]
        auth_soft_fail = true
        volumes = [
          "local/vector.yaml:/etc/vector/vector.yaml"
        ]
      }
      template {
        destination = "local/vector.yaml"
        env         = false
        change_mode = "restart"
        data        = <<EOF
api:
  enabled: false
sources:
  host_metrics:
    type: host_metrics
    collectors:
      - cgroups
      - cpu
      - disk
      - filesystem
      - load
      - host
      - memory
      - network
    namespace: host_metrics
    scrape_interval_secs: 30
sinks:
  prometheus_exporter:
    type: prometheus_exporter
    inputs:
      - host_metrics
    address: 0.0.0.0:9876
EOF
      }
      identity {
        env  = true
        file = true
      }
      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}