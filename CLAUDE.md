# Project rules — k8s Homelab

## Remote server access — Ansible only

Any command that must run on cluster nodes (master `192.168.1.10`, worker `192.168.1.7`)
is executed **only through Ansible**, never via direct SSH:

```sh
ansible <host|group> -m shell -a '<command>'          # ad-hoc command
ansible <host|group> -m command -a '<command>'        # without shell
ansible <host|group> -m setup                         # gather facts
ansible-playbook playbooks/site.yml --tags <tag>      # playbook run
```

- Use inventory groups/aliases from `inventory.yml` (`master`, `worker`), not raw IPs.
- For privileged commands use `become` (`-b`), not `sudo` inside the command string.
- Read-only inspection (facts, service status, logs) — ad-hoc modules are fine:
  `ansible master -m shell -a 'kubectl get pods -A'`.
- Changes to node state (packages, services, k3s config) go through the existing roles
  (`k3s_common`, `k3s_server`, `k3s_worker`, `argocd_bootstrap`) — extend a role
  instead of piling up ad-hoc shell commands.
- Never SSH into nodes directly (`ssh user@192.168.1.x`) to run commands manually.

## Secrets

- Secrets live in `group_vars/all/secrets.yml` (ansible-vault encrypted).
  Never commit plaintext secrets; `secrets.example.yml` is the template.
- Vault-encrypted files are decrypted only via ansible-vault commands.

## GitOps

- Cluster workload changes go through the `gitops/` directory (Argo CD Applications),
  not through direct `kubectl apply` on the nodes, except the one-time bootstrap
  (`gitops/bootstrap/root-app.yaml`).
