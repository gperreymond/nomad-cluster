job "whoami" {
  group "whoami" {
    count = 3
    network {
      port "http" {
        to = 80
      }
    }
    service {
      name     = "whoami-http"
      provider = "nomad"
      port     = "http"
    }
    task "whoami" {
      driver = "docker"
      config {
        image          = "traefik/whoami:v1.10.1"
        ports          = ["http"]
        auth_soft_fail = true
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