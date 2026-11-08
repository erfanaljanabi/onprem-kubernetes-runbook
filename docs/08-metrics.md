# 08 — Metrics Server and resource inspection

**Why:** Metrics Server aggregates kubelet CPU and memory samples for `kubectl top` and autoscaling APIs. It does not store long-term metrics.

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set 'args[0]=--kubelet-preferred-address-types=InternalIP\,ExternalIP\,Hostname'
# The backslashes escape Helm's comma-separated --set syntax.
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl logs -n kube-system deploy/metrics-server
```

If kubelet serving certificates lack valid IP SANs, logs may show `x509` errors. **Production fix:** issue trusted kubelet serving certificates with appropriate SANs. **Lab-only workaround:**

```bash
helm upgrade metrics-server metrics-server/metrics-server \
  --namespace kube-system --reuse-values \
  --set 'args[1]=--kubelet-insecure-tls'
```

```bash
kubectl top nodes                        # Live node CPU/RAM
kubectl top pods -A                      # Live pod CPU/RAM
kubectl describe nodes | grep -A 6 'Allocated resources:'
# Requests/limits are scheduling reservations, not measured usage.
kubectl get deployments -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,CPU_REQUEST:.spec.template.spec.containers[*].resources.requests.cpu,MEM_REQUEST:.spec.template.spec.containers[*].resources.requests.memory,CPU_LIMIT:.spec.template.spec.containers[*].resources.limits.cpu,MEM_LIMIT:.spec.template.spec.containers[*].resources.limits.memory'
# Deployment resources only; excludes DaemonSets and static pods.
```
