#!/usr/bin/env bash
set -euo pipefail
# Basic pre-push checks; not a substitute for human review or secret scanning.
echo "Checking tracked files for common private file patterns..."
git ls-files | grep -Ei '(^|/)(\.env\.local|admin\.conf|kubeconfig|id_rsa|id_ed25519|secrets?)(/|$)|\.(key|pem|p12|pfx)$' && {
  echo "ERROR: Potentially sensitive tracked filename found."; exit 1;
} || true
echo "Checking for obvious credentials and private networking identifiers..."
if git grep -nEI '(BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|client-key-data:|client-certificate-data:|certificate-authority-data:|[0-9a-f]{6}\.ts\.net|100\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' -- ':!scripts/check-public-safe.sh'; then
  echo "ERROR: Review possible secrets or VPN addresses."; exit 1
fi
echo "Basic checks passed. Still inspect staged diff and run a dedicated secret scanner."
