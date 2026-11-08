# EXAMPLE ONLY — render locally; do not commit rendered values.
network:
  version: 2
  ethernets:
    ${NETPLAN_INTERFACE}:
      dhcp4: false
      addresses:
        - ${NODE_IP}/24
      routes:
        - to: default
          via: ${GATEWAY_IP}
      nameservers:
        addresses:
          - ${DNS_IP}
