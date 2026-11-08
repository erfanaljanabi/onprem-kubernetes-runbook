# 01 — Plan and configure the VMs

**Where:** Hypervisor and all Ubuntu nodes. **Why:** `kubeadm` assumes stable node connectivity.

- Create one control-plane VM and three worker VMs with Ubuntu Server 24.04, ~2 vCPU and ~4 GiB RAM each (adjust for your hardware).
- Select **bridged** adapters when VMs must be independently reachable on your LAN; NAT is an alternative but changes access/routing requirements.
- Allocate non-overlapping ranges for LAN, Pods, Services, VPN and MetalLB. Reserve MetalLB addresses outside DHCP.
- Use site-approved firewall rules. Kubernetes control-plane API TCP 6443; kubelet TCP 10250; etcd TCP 2379–2380 for control-plane communication; CNI-specific traffic such as Calico VXLAN UDP 4789 and BGP TCP 179 when enabled.

```bash
ip -br addr                 # Find active NIC and current IP
ip -br link                 # Identify interface name for Netplan
ip route                    # Confirm gateway and routes
hostnamectl                 # Confirm hostname and OS
resolvectl status           # Inspect DNS configuration
sudo ls /etc/netplan        # Find existing network config
```

Set a **unique** hostname on each VM:

```bash
sudo hostnamectl set-hostname control-plane   # On control-plane VM only
# On workers use worker-1, worker-2, worker-3 respectively
```

Example Netplan template: [`templates/netplan.yaml.tpl`](../templates/netplan.yaml.tpl). Do not blindly overwrite cloud-init managed configuration. Backup current settings first.

```bash
sudo netplan try             # Apply temporarily, rollback if access breaks
sudo netplan apply           # Apply the validated network configuration
getent hosts control-plane  # Confirm local DNS/hosts resolution
ping -c 2 "$GATEWAY_IP"      # Test gateway reachability (after loading local env)
```

Configure `/etc/hosts` on each VM or use internal DNS to resolve all four node hostnames. Use your actual local addresses, never the documentation-only values in `.env.example`.

**Verify:** Every VM can reach the others by intended LAN IP; gateway and DNS work.
