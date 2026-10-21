# Secrets management (SOPS + age + KSOPS)

All Kubernetes secrets in this repository are encrypted with [SOPS](https://github.com/getsops/sops) using a dedicated age key.

## Encrypted files

- `gitops/apps/registry/secret-registry-auth.yaml` — htpasswd for the private docker registry
- `gitops/apps/actions-runner-controller/secret-gha-github-app.yaml` — GitHub App credentials for actions-runner-controller
- `gitops/apps/argocd-config/manifests/secret-sops-age-key.yaml` — the age private key itself (installed into `argocd` namespace so Argo CD can decrypt everything)

## Decryption chain

1. Argo CD repo-server runs a KSOPS CMP sidecar (see `gitops/apps/argocd-config/manifests/repo-server-ksops-patch.yaml`).
2. The sidecar reads the age private key from the `sops-age-key` secret mounted at `/etc/age-key/key.txt`.
3. Each application that needs secrets uses a kustomize source with a `ksops` generator (see `secret-generator.yaml` next to each encrypted secret).

Bootstrap order: the `sops-age-key` secret is created by the `argocd-config` Application, which is a plain kustomize source rendered by the same KSOPS sidecar — the age key secret must be applied manually once during initial bootstrap (see the `argocd_bootstrap` Ansible role) before Argo CD can decrypt anything.

## Editing secrets

```sh
export SOPS_AGE_KEY_FILE=~/.config/sops/age-homelab/k8s-homelab.txt
sops gitops/apps/registry/secret-registry-auth.yaml
```

## GitHub App for actions-runner-controller

The runner scale set authenticates as a GitHub App (org-scoped runners).
Create it once in the GitHub UI (org → Settings → Developer settings → New GitHub App):

- Homepage URL: any valid URL (e.g. `https://reveek-io.ru`), Callback URL: `http://localhost`
- Webhook: **uncheck** Active
- Repository permissions: Administration (read/write), Metadata (read-only)
- Organization permissions: Self-hosted runners (read/write)

Then generate a private key (`.pem` download) and fill the encrypted secret:

```sh
export SOPS_AGE_KEY_FILE=~/.config/sops/age-homelab/k8s-homelab.txt
sops gitops/apps/actions-runner-controller/secret-gha-github-app.yaml
```

Keys: `github_app_id` (App ID), `github_app_installation_id` (Installation ID
from the app's install page), `github_app_private_key` (contents of the `.pem` file).

## Re-encrypting after key rotation

```sh
export SOPS_AGE_KEY_FILE=~/.config/sops/age-homelab/k8s-homelab.txt
sops updatekeys gitops/apps/registry/secret-registry-auth.yaml
```
