job "coredns-nomad" {
  type = "system"
  group "coredns" {
    network {
      mode = "host"
      port "dns" {
        static = 53
      }
    }
    service {
      name     = "hostmaster"
      provider = "nomad"
      port     = "dns"
    }
    task "coredns" {
      driver = "docker"
      config {
        image      = "ghcr.io/ituoga/coredns-nomad:v0.0.8"
        privileged = true
        volumes = [
          "secrets/coredns/Corefile:/etc/Corefile:ro",
        ]
        ports = ["dns"]
        args  = ["-conf", "/etc/Corefile", "-dns.port", "53"]
      }
      env {
        NOMAD_SKIP_VERIFY = "true"
      }
      template {
        data          = <<EOF
service.nomad.:53 {
    errors
    debug
    health
    log
    nomad {
      zone service.nomad
	  	address https://{{ env "attr.nomad.advertise.address" }}
      token 454fa468-92d3-f6e0-6b8d-dc7a653317ba
      ttl 10
    }
    cache 30
}
EOF
        destination   = "secrets/coredns/Corefile"
        change_mode   = "signal"
        change_signal = "SIGHUP"
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