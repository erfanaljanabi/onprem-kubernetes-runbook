# 06 — DNS, Service networking and remote administration

### Verify in-cluster networking

```bash
kubectl get pods -A -o wide             # Pod status, node and pod IP
kubectl get svc -A                     # Services and ClusterIPs
kubectl get endpointslices -A          # Service backend endpoints
kubectl exec <SOURCE_POD> -- nslookup <SERVICE_NAME>
kubectl exec <SOURCE_POD> -- curl -sS http://<SERVICE_NAME>
kubectl exec <SOURCE_POD> -- curl -sS http://<DESTINATION_POD_IP>
```

**Why:** Distinguishes DNS, Service routing and direct cross-node pod connectivity. Replace placeholders with temporary test workloads; no demo deployments are included because they were removed from the source lab.

### Remote access

An optional private VPN (such as Tailscale) can provide encrypted reachability to the API server. **Never commit VPN addresses, machine identities, tailnet details or administrative kubeconfig.**

```bash
sudo tailscale up                       # On the node, join an authorized tailnet
tailscale ip -4                         # Show its private VPN address locally
tailscale status                        # Check peer connectivity
ssh <LOCAL_USERNAME>@<PRIVATE_VPN_IP>   # From admin workstation
```

A trusted admin workstation may receive kubeconfig via secure copy to a **private** path:

```bash
mkdir -p ~/.kube
scp <LOCAL_USERNAME>@<PRIVATE_VPN_IP>:~/.kube/config ~/.kube/homelab.yaml
chmod 600 ~/.kube/homelab.yaml
```

If API endpoint differs from certificate name, configure `kubectl config set-cluster ... --server=... --tls-server-name=...` on the private kubeconfig only. Never disable API server certificate verification.

**Verify:** `KUBECONFIG=~/.kube/homelab.yaml kubectl get nodes` works remotely.
