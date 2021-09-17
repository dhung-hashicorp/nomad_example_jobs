job createnamespace {
  type = "batch"
  datacenters = ["dc1"]
  group "group" {
    count = 1

    task "task" {
      template {
        data = <<EOH
#!/bin/bash

echo "$(date) -- Getting Nomad token from Vault."
export VAULT_ADDR="http://127.0.0.1:8200"
nomadtoken=`/usr/bin/vault read nomad/creds/team-infra | grep secret_id | awk '{print$2}'`
echo "$(date) -- This line is to demo token retrieved was ${nomadtoken} and can be removed"
export NOMAD_TOKEN=${nomadtoken}
echo "$(date) -- Creating namespace called test-namespace"
/usr/bin/nomad namespace apply test-namespace
echo "$(date) -- Getting list of namespaces"
/usr/bin/nomad namespace list
echo "$(date) -- Removing test-namespace"
/usr/bin/nomad namespace delete test-namespace
EOH
        destination = "local/gettoken.sh"
      }

      driver = "raw_exec"

      config {
        command = "${NOMAD_TASK_DIR}/gettoken.sh"
      }
      
      vault {
        policies = ["root-user"]
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      resources {
        memory = 10
        cpu = 50
      }
    }
  }
}
