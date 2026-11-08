# 09 — Local Path Provisioner and PVC persistence

**Why:** `kubeadm` clusters do not automatically include a dynamic StorageClass. Local Path Provisioner uses a selected node's disk to create PVs. **Not highly available; no replication.**

```bash
kubectl get storageclass                  # Initially no classes in the source lab
kubectl get nodes -o custom-columns='NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory'
# Check node schedulable resources before adding services.
df -h /                                   # Run on each node to inspect disk capacity
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.32/deploy/local-path-storage.yaml
kubectl get pods -n local-path-storage
kubectl get storageclass
```

The source lab's `local-path` class used `Delete`, `WaitForFirstConsumer` and no expansion. A new PVC remains `Pending` until a pod consumes it.

### Persistence test

```bash
kubectl apply -f examples/storage/pvc.yaml
kubectl get pvc storage-test-pvc          # Pending before a consuming pod
kubectl apply -f examples/storage/pod-write.yaml
kubectl wait --for=condition=Ready pod/storage-test --timeout=120s
kubectl get pod storage-test -o wide
kubectl get pvc storage-test-pvc          # Bound
kubectl exec storage-test -- cat /data/test.txt
kubectl delete pod storage-test           # Keep PVC
kubectl apply -f examples/storage/pod-read.yaml
kubectl wait --for=condition=Ready pod/storage-test --timeout=120s
kubectl exec storage-test -- cat /data/test.txt
# Same marker proves data survived pod replacement.
kubectl delete pod storage-test
kubectl delete pvc storage-test-pvc
kubectl get pods,pvc -n default
kubectl get pv                            # Test PV should be gone
```

**Placement:** Both test pods use the same worker hostname; edit `nodeSelector` to match your actual worker before applying. The `1Gi` local-path PVC is not necessarily an enforced disk quota.
