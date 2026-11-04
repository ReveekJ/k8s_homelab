# Workload Placement

## Policy

This two-node k3s cluster separates system and application workloads to preserve memory for applications:

| Node | Role | Placement rule |
|---|---|---|
| `master` / `192.168.1.10` | system | `homelab.reveek.io/node-role: system` |
| `worker` / `192.168.1.7` / `debian-hp` | application | hostname selector plus application toleration |

The worker is tainted with:

```text
homelab.reveek.io/node-role=application:NoSchedule
```

This prevents system Pods without the application toleration from consuming worker memory. The master is intentionally not tainted, so system Pods can run there without extra tolerations.

## New application workload

Every application Pod template must include:

```yaml
nodeSelector:
  kubernetes.io/hostname: debian-hp
tolerations:
  - key: homelab.reveek.io/node-role
    operator: Equal
    value: application
    effect: NoSchedule
```

Apply this to Deployments, StatefulSets, Jobs, and CronJobs. For a Helm chart, define the values once and render both fields in every relevant Pod template. Persistent volumes using `local-path` must also remain on the worker or use a storage design that supports the chosen node placement.

## New system workload

System components must use:

```yaml
nodeSelector:
  homelab.reveek.io/node-role: system
```

Do not add the application toleration to system workloads. Components managed by k3s or an upstream chart must be configured at their owning layer: k3s `HelmChartConfig` for bundled charts such as Traefik, Helm values for cert-manager, and Ansible bootstrap patches for Argo CD.

## Monitoring exception

The monitoring stack is an explicit exception to the system workload rule. Prometheus, Loki, Grafana, kube-state-metrics, and smartctl-exporter use the application placement rule and run on `debian-hp`: the master has too little free memory, and its small eMMC root cannot host a TSDB or log store.

Alloy runs on both nodes because it collects host metrics and logs, so it carries the application toleration and has no `nodeSelector`. All monitoring Pods use the `monitoring-low` PriorityClass, which never preempts applications and makes monitoring an early eviction candidate under memory pressure.

## Verification

After a change, inspect both scheduling metadata and actual placement:

```sh
kubectl get nodes --show-labels
kubectl get pods -A -o wide
kubectl describe node debian-hp
```

The expected result is system infrastructure on `master` and application workloads on `debian-hp`.