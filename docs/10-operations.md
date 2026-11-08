# 10 — Health checks, troubleshooting and production notes

```bash
kubectl config current-context             # Check target cluster before changes
kubectl cluster-info                       # API server / DNS information
kubectl get nodes -o wide                  # Node status and LAN interfaces
kubectl get pods -A -o wide                # System workload status
kubectl get svc -A                         # Services and LoadBalancer addresses
kubectl get events -A --sort-by=.lastTimestamp
kubectl get storageclass                   # Storage provisioning
kubectl get pv                             # Provisioned volumes
kubectl get pvc -A                         # Claims in all namespaces
kubectl top nodes                          # Live utilization
kubectl top pods -A
kubectl describe pod <POD> -n <NAMESPACE>  # Pod events and scheduling details
kubectl logs <POD> -n <NAMESPACE> --all-containers=true
kubectl logs <POD> -n <NAMESPACE> --previous
sudo systemctl status kubelet --no-pager   # On affected node
sudo journalctl -u kubelet -n 100 --no-pager
sudo systemctl status containerd --no-pager
sudo journalctl -u containerd -n 100 --no-pager
sudo crictl ps -a
free -h                                    # Host memory
df -h                                      # Host disk pressure
sudo ss -lntp | grep 6443                  # API server listener on control plane
```

## Before adapting this to production
- Multiple control-plane nodes behind a stable API endpoint; etcd backups and tested restores.
- Secure firewall rules, network policies, RBAC and workload identity.
- Valid kubelet serving certificates; remove insecure Metrics Server flag.
- Encrypted, backed-up, replicated storage rather than local-path for critical data.
- Pinned and validated Kubernetes/CNI/Helm versions; vulnerability and image scanning.
- Monitoring/alerting, resource requests and capacity planning, secrets management and GitOps.
- Secure kubeconfig distribution, audit logs, patching and disaster recovery.

**Verified stopping point:** Single control plane + three workers; Calico; DNS/Service networking; MetalLB/Traefik; optional remote access; Metrics Server; Local Path Provisioner and PVC persistence test. Prometheus/Grafana/Alertmanager/Argo CD not installed yet.
