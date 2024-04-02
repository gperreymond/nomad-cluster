job "grafana-system" {
  namespace = "grafana-system"
  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "nomad-cluster-1"
  }
  group "grafana" {
    count = 1
    network {
      mode = "host"
      port "tcp" {
        to = 5432
      }
      port "http" {
        to = 3000
      }
    }
    task "postgres" {
      driver = "docker"
      config {
        image          = "postgres:16.2-alpine3.19"
        ports          = ["tcp"]
        auth_soft_fail = true
        volumes = [
          "/home/vagrant/grafana_postgres_data:/var/lib/postgresql/data/pgdata"
        ]
      }
      template {
        destination = "local/env.conf"
        env         = true
        change_mode = "restart"
        data        = <<EOF
PGDATA = "/var/lib/postgresql/data/pgdata"
POSTGRES_DATABASE = "grafana"
POSTGRES_USER = "grafana"
POSTGRES_PASSWORD = "super#changeme"
EOF
      }
      service {
        name     = "grafana-postgres-tcp"
        provider = "nomad"
        port     = "tcp"
      }
      identity {
        env  = true
        file = true
      }
      resources {
        cpu    = 200
        memory = 128
      }
    }
    task "grafana" {
      driver = "docker"
      config {
        image          = "grafana/grafana:10.1.9-ubuntu"
        ports          = ["http"]
        auth_soft_fail = true
        volumes = [
          "local/grafana.ini:/etc/grafana/grafana.ini"
        ]
      }
      template {
        destination = "local/env.conf"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- range nomadService "grafana-postgres-tcp" }}
GF_DATABASE_HOST = "{{ .Address }}:{{ .Port }}"
{{- end }}
GF_DATABASE_PASSWORD = "super#changeme"
GF_SECURITY_ADMIN_PASSWORD = "changeme"
GF_SECURITY_ADMIN_USER = "admin"
GF_INSTALL_PLUGIN = "volkovlabs-echarts-panel,grafana-worldmap-panel,grafana-piechart-panel,natel-discrete-panel,grafana-opensearch-datasource"
GF_USERS_ALLOW_SIGN_UP = "false"
GF_SECURITY_DISABLE_INITIAL_ADMIN_CREATION = "false"
GF_AUTH_DISABLE_LOGIN_FORM = "true"
GF_LOG_CONSOLE_FORMAT = "json"
GF_DATABASE_TYPE = "postgres"
GF_DATABASE_NAME = "grafana"
GF_DATABASE_USER = "grafana"
EOF
      }
      template {
        destination = "local/grafana.ini"
        data        = <<EOF
[auth.anonymous]
enabled = false
org_name = ASYTECH
EOF
      }
      service {
        name     = "grafana-http"
        provider = "nomad"
        port     = "http"
      }
      identity {
        env  = true
        file = true
      }
      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
