# 02 — Prepare Ubuntu on every node

**Where:** All four Ubuntu VMs. **Why:** Kubernetes networking and the container runtime need compatible kernel features.

```bash
sudo apt-get update                     # Refresh package metadata
sudo apt-get upgrade -y                # Apply OS updates
sudo apt-get install -y ca-certificates curl gpg apt-transport-https \
  software-properties-common conntrack socat iproute2
# Utilities for repositories, TLS, networking and kubeadm
sudo timedatectl set-ntp true           # Enable clock synchronization
timedatectl status                      # Check NTP
sudo swapoff -a                         # Disable swap until reboot
swapon --show                           # Expect no active swap
sudo cp /etc/fstab /etc/fstab.bak        # Backup persistent mount configuration
sudo nano /etc/fstab                    # Comment swap entries to keep swap off
```

```bash
sudo tee /etc/modules-load.d/k8s.conf >/dev/null <<'EOF'
overlay
br_netfilter
EOF
sudo modprobe overlay                   # Overlay filesystem support
sudo modprobe br_netfilter              # Bridge filtering support
sudo tee /etc/sysctl.d/99-kubernetes-cri.conf >/dev/null <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system                    # Apply kernel networking settings
sysctl net.ipv4.ip_forward              # Expect 1
```

**Verify:** Time is synchronized, swap is disabled, kernel modules are loaded and forwarding is enabled. Kubernetes can support swap in some configurations, but this guide uses the conventional swap-disabled kubeadm setup.
