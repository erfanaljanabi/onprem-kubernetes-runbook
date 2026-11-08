# 04 — Initialize control plane and join workers

**Where:** `kubeadm init` on the control plane only; `kubeadm join` on each worker.

### Initialize

```bash
# Replace example placeholders locally; do not commit actual IPs.
sudo kubeadm init \
  --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
  --apiserver-cert-extra-sans="${CONTROL_PLANE_HOSTNAME},${CONTROL_PLANE_IP}" \
  --pod-network-cidr="${POD_CIDR}"
```

**Why:** Generates certificates and bootstraps etcd, API server, scheduler and controller manager. The Pod CIDR must match Calico's pool.

```bash
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"              # Protect administrator credentials
kubectl get nodes                           # May be NotReady before CNI
kubectl get pods -A                          # Inspect control-plane components
```

**SECURITY:** `admin.conf` is a highly privileged credential. Keep it on trusted machines, never in this repository.

### Join workers

On the control plane, **privately** generate the join command:

```bash
sudo kubeadm token create --print-join-command
```

Run the printed command on each worker. Its structure is:

```bash
sudo kubeadm join "${CONTROL_PLANE_IP}:6443" \
  --token '<PRIVATE_BOOTSTRAP_TOKEN>' \
  --discovery-token-ca-cert-hash 'sha256:<PRIVATE_CA_HASH>'
```

**Why:** Workers verify the cluster CA and register their kubelets. Tokens and actual CA hashes must not be committed.

```bash
kubectl get nodes -o wide                   # Confirm four registered nodes
```

**Verify:** One control-plane and three worker nodes are registered. `Ready` requires a functioning CNI.
