# Public repository security

This repository is designed for publishing **documentation and templates**, not actual infrastructure state.

**Never commit:** real IP maps or VPN addresses, kubeconfigs, `/etc/kubernetes/admin.conf`, CA private keys, SSH private keys, bootstrap tokens, API credentials, real hostnames, credentials, rendered manifests or the source PDF.

- `.env.local` is ignored. `.env.example` contains documentation-only TEST-NET addresses.
- Review `git status`, `git diff --cached`, and the output of `scripts/check-public-safe.sh` before every push.
- Consider `gitleaks` or `trufflehog` for dedicated secret scanning; a grep-based check cannot guarantee safety.
- `.gitignore` **does not remove data already committed**. If a secret is committed, rotate it immediately and rewrite history where appropriate.
- Avoid screenshots or architecture images showing real network addresses.
- Keep actual `kubeadm join` tokens private and short-lived.
- Do not upload the original homelab PDF; it includes real infrastructure addresses.
