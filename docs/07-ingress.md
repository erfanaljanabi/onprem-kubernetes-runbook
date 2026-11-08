# 07 — MetalLB and Traefik

**Why:** A bare-metal/VMware cluster has no cloud provider to assign LoadBalancer IPs. MetalLB advertises an address from your LAN; Traefik routes HTTP(S) to application Services.

Install a **pinned, compatible MetalLB release** from its official deployment instructions first. The historical installation command was not preserved in the source runbook.

```bash
kubectl get pods -n metallb-system             # Verify controller and speakers
kubectl get ipaddresspools -n metallb-system   # View address pools
kubectl get l2advertisements -n metallb-system # Check L2 advertisements
```

Configure MetalLB using [`templates/metallb-pool.yaml.tpl`](../templates/metallb-pool.yaml.tpl), rendered **locally** with addresses excluded from DHCP.

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update traefik
helm show values traefik/traefik > /tmp/traefik-defaults.yaml
kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install traefik traefik/traefik \
  --namespace traefik --set service.type=LoadBalancer
kubectl get svc -n traefik
kubectl get pods -n traefik
```

**Verify:** Traefik is running and its LoadBalancer Service has an address from the designated pool. Review ingress security, authentication, TLS, and chart version pinning before production use.
