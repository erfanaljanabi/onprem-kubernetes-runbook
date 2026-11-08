# 03 — Install containerd and Kubernetes packages

**Where:** All four Ubuntu VMs.

```bash
sudo apt-get install -y containerd             # Install container runtime
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
containerd --version                          # Check runtime version
sudo grep -n 'SystemdCgroup' /etc/containerd/config.toml
sudo nano /etc/containerd/config.toml         # Set SystemdCgroup = true in runc options
sudo systemctl enable --now containerd        # Enable runtime at boot
sudo systemctl restart containerd             # Apply configuration
sudo systemctl status containerd --no-pager   # Verify healthy service
```

**Important:** containerd v1 and v2 have different config layouts. Check the installed runtime's CRI plugin and runc options before editing. The `SystemdCgroup` setting must be placed in the correct section.

Install a **supported** Kubernetes minor version; `v1.37` is the source lab's version, not a universal recommendation.

```bash
K8S_MINOR=v1.37
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR}/deb/Release.key" \
 | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
printf 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/%s/deb/ /\n' "$K8S_MINOR" \
 | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl   # Prevent unexpected version upgrades
kubeadm version                             # Confirm kubeadm
kubectl version --client                    # Confirm CLI
```

**Verify:** containerd runs, Kubernetes packages are installed, and versions are compatible. Do not blindly copy a Kubernetes minor version into an older environment.
