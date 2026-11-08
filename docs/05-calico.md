# 05 — Install Calico CNI

**Where:** A machine with authorized `kubectl` access.

Calico provides pod-to-pod networking, routing/encapsulation and NetworkPolicy enforcement. The source lab used Tigera operator with Calico v3.33.0, Pod CIDR `<YOUR_NETWORK_VALUE>`, and LAN-specific node IP autodetection to prevent a VPN interface from being selected.

```bash
CALICO_VERSION=v3.33.0
kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml"
# Installs the Calico operator and its CRDs.
curl -fsSLo /tmp/calico-custom-resources.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml"
# Review and edit the Installation resource: pod pool CIDR and LAN CIDR.
kubectl apply -f /tmp/calico-custom-resources.yaml
# Deploys the Calico network with your chosen pod CIDR.
```

For the **LAN autodetection** fix, use a local shell variable rather than committing a real CIDR:

```bash
kubectl patch installation.operator.tigera.io default --type=merge \
  -p "{\"spec\":{\"calicoNetwork\":{\"nodeAddressAutodetectionV4\":{\"cidrs\":[\"${LAN_CIDR}\"]}}}}"
```

**Why:** Ensures Calico advertises the node's intended LAN IP rather than a VPN address.

```bash
kubectl get pods -n calico-system -o wide
kubectl get pods -n tigera-operator
kubectl get nodes -o wide
```

**Verify:** Calico pods healthy, nodes Ready, and pod traffic between workers succeeds. Check CNI manifest compatibility with the installed Kubernetes version.
