# FlinkDeployment 配置解析
# ======================

## 1. 基本信息
apiVersion: flink.apache.org/v1beta1  # Flink Kubernetes Operator API
kind: FlinkDeployment                  # 资源类型：Flink 应用部署
metadata:
  name: flink-quote-candle            # 部署名称
  namespace: emr-flink                # 命名空间

## 2. EMR on EKS 配置
spec:
  emrReleaseLabel: emr-6.13.0-flink-latest     # EMR 版本
  executionRoleArn: arn:aws:iam::...           # AWS IAM 角色
  flinkVersion: v1_17                          # Flink 版本

## 3. 高可用配置
flinkConfiguration:
  high-availability: org.apache.flink.kubernetes.highavailability.KubernetesHaServicesFactory
  high-availability.storageDir: s3://...      # HA 元数据存储
  state.checkpoints.dir: s3://...             # 检查点存储
  state.savepoints.dir: s3://...              # 保存点存储

## 4. 作业配置
job:
  entryClass: com.tiger.exodus.quote.indexer.CandleIndexerJob  # 入口类
  jarURI: local:///usr/lib/flink/usrlib/indexer.jar           # JAR 路径
  args:                                                        # 程序参数
    - hk-prod/candle.properties
    - empty
  parallelism: 2                                              # 并行度
  upgradeMode: last-state                                     # 升级模式

## 5. 资源配置
jobManager:
  replicas: 2                          # JobManager 副本数（HA）
  resource:
    cpu: 0.2                          # CPU 资源
    memory: 768m                      # 内存资源

taskManager:
  replicas: 1                          # TaskManager 副本数
  resource:
    cpu: 0.1                          # CPU 资源  
    memory: 1024m                     # 内存资源

## 6. 云服务集成
- AWS EMR on EKS
- S3 存储（检查点、保存点、日志）
- IAM 权限管理
- Ingress 外部访问