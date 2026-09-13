# k8s Homelab

K3s cluster managed by Ansible with Argo CD GitOps.

## Topology

| Node | IP | OS | RAM | Role |
|---|---|---|---|---|
| master | 192.168.1.10 | Linux Mint | 4 GB | k3s server, Argo CD, registry PV |
| worker | 192.168.1.7 | Debian | 8 GB | k3s agent, Hermes fleet, compose services |

## Repository layout

```
ansible.cfg, inventory.yml, group_vars/   Ansible control plane
playbooks/site.yml                        Node prep + k3s install
playbooks/bootstrap.yml                   Argo CD bootstrap (one-time)
roles/k3s_common                          Base packages, sudo, ssh hardening
roles/k3s_server                          k3s server install, token, kubeconfig fetch
roles/k3s_worker                          k3s agent join
roles/argocd_bootstrap                    Argo CD install + resource tuning
gitops/bootstrap/                         Root Application (app-of-apps)
gitops/apps/cert-manager/                 cert-manager Application + ClusterIssuer
gitops/apps/registry/                     Docker Registry Application (twuni chart)
gitops/apps/hermes/                       Hermes Agent chart + Application
images/hermes-agent/Dockerfile            Hermes container image
```

## First deployment

1. Fill `group_vars/all.yml` (domain, gitops repo URL) and copy
   `group_vars/all/secrets.example.yml` to `group_vars/all/secrets.yml`
   (encrypt with ansible-vault).
2. Update `gitops/bootstrap/root-app.yaml` and `gitops/apps/hermes/app.yaml`
   with the real git repository URL.
3. Update ingress hosts in `gitops/apps/registry/app.yaml`,
   `gitops/apps/hermes/chart/values.yaml` and the ACME email in
   `gitops/apps/cert-manager/clusterissuer.yaml`.
4. Deploy the cluster:

```sh
ansible-playbook playbooks/site.yml
ansible-playbook playbooks/bootstrap.yml
```

5. Apply the root Application:

```sh
kubectl apply -f gitops/bootstrap/root-app.yaml
```

6. Router: forward ports 80/443 to 192.168.1.10. DNS: point
   `registry.<domain>` and `hermes.<domain>` at the public IP.

## Hermes image build

```sh
docker buildx build --platform linux/amd64 \
  -t registry.<domain>/hermes-agent:latest images/hermes-agent \
  --push
```

## Secrets

Kubernetes secrets (`hermes-secrets`, registry htpasswd) are rendered from
ansible-vault values and applied manually; they are never committed.
