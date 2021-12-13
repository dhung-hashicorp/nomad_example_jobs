###Example of job that has two groups. Second group uses canary of it will not stop any instance until manual promotion is executed
job "example" {
  datacenters = ["dc1"]

  group "one" {
    count = 3
    network {
      port "db" {
#        to = 6379
      }
    }
    update {
      max_parallel     = 1
      min_healthy_time = "30s"
      healthy_deadline = "1m"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:3.2"

        ports = ["db"]
      }

      resources {
        cpu    = 102
        memory = 128
      }
    }
  }
  group "two" {
    count = 3
    network {
      port "db" {
#        to = 6379
      }
    }
    update {
      canary = 1
      max_parallel     = 1
      min_healthy_time = "30s"
      healthy_deadline = "1m"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:3.2"

        ports = ["db"]
      }

      resources {
        cpu    = 102
        memory = 128
      }
    }
  }
}
