# Project rules — k8s Homelab

## Mandatory restrictions

- **Do not use the `k8s-preprod-readonly` skill** in this project, under any circumstances.
- Connect to cluster servers only through Ansible. Use `ansible` for ad-hoc commands and
  `ansible-playbook` for playbooks; never connect directly with SSH or another remote-access tool.

## Workload placement

The cluster has two nodes with a strict memory-oriented placement policy:

- `master` (`192.168.1.10`) is the system node. k3s server, Argo CD, cert-manager, Traefik, CoreDNS, and other cluster infrastructure run here.
- `worker` (`192.168.1.7`, hostname `debian-hp`) is the application node. User-facing applications, databases, queues, registries, runners, and their backup jobs run here.

The worker has the taint `homelab.reveek.io/node-role=application:NoSchedule`. Every new application Pod must therefore have both:

```yaml
nodeSelector:
  kubernetes.io/hostname: debian-hp
tolerations:
  - key: homelab.reveek.io/node-role
    operator: Equal
    value: application
    effect: NoSchedule
```

For Helm charts, expose these as values and render them into every Deployment, StatefulSet, CronJob, and Job Pod template. Do not add the application toleration to system components. System workloads use `homelab.reveek.io/node-role: system`; unlabelled cluster infrastructure remains on the master because the worker taint rejects it.

This policy exists to keep application memory pressure off the 4 GiB master and to reserve the 8 GiB worker for application workloads. Any exception requires an explicit placement decision in the manifest.

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
