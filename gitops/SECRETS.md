# Secrets management (SOPS + age + KSOPS)

All Kubernetes secrets in this repository are encrypted with [SOPS](https://github.com/getsops/sops) using a dedicated age key.

## Encrypted files

- `gitops/apps/registry/secret-registry-auth.yaml` — htpasswd for the private docker registry
- `gitops/apps/hermes/secret-hermes.yaml` — model provider API keys for hermes
- `gitops/apps/argocd-config/manifests/secret-sops-age-key.yaml` — the age private key itself (installed into `argocd` namespace so Argo CD can decrypt everything)

## Decryption chain

1. Argo CD repo-server runs a KSOPS CMP sidecar (see `gitops/apps/argocd-config/manifests/repo-server-ksops-patch.yaml`).
2. The sidecar reads the age private key from the `sops-age-key` secret mounted at `/etc/age-key/key.txt`.
3. Each application that needs secrets uses a kustomize source with a `ksops` generator (see `secret-generator.yaml` next to each encrypted secret).

Bootstrap order: the `sops-age-key` secret is created by the `argocd-config` Application, which is a plain kustomize source rendered by the same KSOPS sidecar — the age key secret must be applied manually once during initial bootstrap (see the `argocd_bootstrap` Ansible role) before Argo CD can decrypt anything.

## Editing secrets

```sh
export SOPS_AGE_KEY_FILE=~/.config/sops/age-homelab/k8s-homelab.txt
sops gitops/apps/hermes/secret-hermes.yaml
```

## Re-encrypting after key rotation

```sh
export SOPS_AGE_KEY_FILE=~/.config/sops/age-homelab/k8s-homelab.txt
sops updatekeys gitops/apps/hermes/secret-hermes.yaml
```
