job insideman {
    datacenters = ["dc1"]
    namespace = "default"
    type = "service"

    group "app" {
        count = 1

        network {
            port "http" {
                to = 6379
            }
        }

        task "app" {
            driver = "docker"

            config {
            image = "redis:latest"
            ports = ["http"]
            }

            service {
                name = "inside-man"
                port = "http"
                tags = ["namespace=default"]

                check {
                type = "http"
                port = "http"
                interval = "5s"
                timeout = "2s"
                path = "/_status"
            }
        }

            template {
                data = <<EOH
                {{with secret "/auth/token/create/inside-man" "policies=app-inside-man-read-write" "no_default_policy=true" "renewable=false"}}export VAULT_TOKEN={{.Auth.ClientToken}}{{ end }}
                EOH
                destination = "secrets/vault.env"
                change_mode = "restart"
                env = true
                splay = "10s"
            }

            resources {
                cpu = 100
                memory = 256
            }

            vault {
            policies = ["app-inside-man-read-only"]
            env = false
            change_mode = "signal"
            change_signal = "SIGHUP"
            }
        }
    }
}
