# KUBE_COMMAND

# 查看

查看 namespace 下的 pod 列表：
```
kubectl get pods -n <namespace>
```

如果  deployment 提交了但是 pod 无法正常启动，使用下面指令：
```
kubectl describe pod <pod-id> -n app
```

查看服务的 deployment.yaml 文件：
```
kubectl describe deployment <service-name> -n app

kubectl describe deployment tethys -n app

```

如果服务发生了重启，通过这个指令看异常事件：
```
kubectl describe pod <pod-id> -n app

kubectl describe pod tethys-65bb74bcfb-bdgn9 -n app

```

删除 cassandra 的流程

```
kubectl get pods -n infra | grep cassandra

kubectl get statefulsets,deployments -n infra

kubectl get statefulset cassandra -n infra -o yaml

kubectl get services -n infra | grep cassandra

kubectl get pvc -n infra | grep cassandra

kubectl delete statefulset cassandra -n infra

kubectl delete service cassandra-service -n infra

kubectl delete pvc cassandra-data-cassandra-0 -n infra

kubectl get all,pvc -n infra | grep cassandra

kubectl get pods -n infra | grep cassandra
```