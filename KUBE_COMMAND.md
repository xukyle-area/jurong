# KUBE_COMMAND

# 查看
```
# 查看 Flink 相关的 Pods
kubectl get pods -n infra | grep flink
```
```
# 查看 Flink Services
kubectl get services -n infra | grep flink
```
```
# 查看 Flink JobManager 日志
kubectl logs -n infra deployment/flink-jobmanager
```
```
# 查看 Flink TaskManager 日志
kubectl logs -n infra deployment/flink-taskmanager
```
```
# 描述 Flink JobManager Service
kubectl describe service flink-jobmanager -n infra
```
```
# 端口转发到本地（如果需要）
kubectl port-forward -n infra service/flink-jobmanager 8081:8081
```
```
# 访问 Flink Web UI（通过 NodePort 或 LoadBalancer）
kubectl get service flink-jobmanager-ui -n infra
```
```
# 查看所有命名空间
kubectl get namespaces -o yaml
```
```
# 查看特定命名空间中的 Pods
kubectl get pods -n infra -o yaml
```
```
# 查看特定 Deployment 的 YAML
kubectl get deployment flink-jobmanager -n infra -o yaml

kubectl get deployment flink-taskmanager -n infra -o yaml
```
```
# 查看特定 Service 的 YAML
kubectl get service flink-jobmanager -n infra -o yaml
```
```
# 查看 StatefulSet 的 YAML
kubectl get statefulset kafka -n infra -o yaml
```
```
# 查看 ConfigMap 或 Secret 的 YAML
kubectl get configmap -n infra -o yaml
```
```
# 查看 Ingress 的 YAML
kubectl get ingress infra-ingress -n infra -o yaml
```
```
# 查看所有资源（包括 CRDs）
kubectl get all -n infra -o yaml
```