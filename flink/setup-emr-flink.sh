#!/bin/bash

echo "🚀 设置 AWS EMR on EKS + Flink Operator"
echo "=================================="

# 检查必要的工具
check_tools() {
    for tool in aws kubectl helm eksctl; do
        if ! command -v $tool &> /dev/null; then
            echo "❌ $tool 未安装，请先安装"
            exit 1
        fi
    done
    echo "✅ 所有必要工具已安装"
}

# 1. 创建 EKS 集群 (如果还没有)
create_eks_cluster() {
    echo "📋 创建 EKS 集群..."
    
    cat << EOF > eks-cluster-config.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: flink-emr-cluster
  region: us-west-2
  version: "1.28"

nodeGroups:
  - name: worker-nodes
    instanceType: m5.xlarge
    desiredCapacity: 3
    minSize: 2
    maxSize: 10
    volumeSize: 100
    ssh:
      enableSsm: true

addons:
  - name: vpc-cni
  - name: coredns
  - name: kube-proxy
  - name: aws-ebs-csi-driver

iam:
  withOIDC: true
  serviceAccounts:
    - metadata:
        name: emr-containers-sa-spark
        namespace: emr
      wellKnownPolicies:
        autoScaler: true
      attachPolicyARNs:
        - arn:aws:iam::aws:policy/AmazonElasticMapReduceClientFullAccess
EOF

    eksctl create cluster -f eks-cluster-config.yaml
}

# 2. 设置 EMR on EKS
setup_emr_on_eks() {
    echo "📋 设置 EMR on EKS..."
    
    # 创建 EMR 命名空间
    kubectl create namespace emr
    
    # 创建执行角色
    aws emr-containers create-virtual-cluster \
        --name flink-virtual-cluster \
        --container-provider '{
            "id": "flink-emr-cluster",
            "type": "EKS",
            "info": {
                "eksInfo": {
                    "namespace": "emr"
                }
            }
        }'
    
    # 获取虚拟集群 ID
    VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters \
        --query 'virtualClusters[?name==`flink-virtual-cluster`].id' \
        --output text)
    
    echo "✅ EMR 虚拟集群 ID: $VIRTUAL_CLUSTER_ID"
    echo "export EMR_VIRTUAL_CLUSTER_ID=$VIRTUAL_CLUSTER_ID" >> ~/.bashrc
}

# 3. 安装 Flink Kubernetes Operator
install_flink_operator() {
    echo "📋 安装 Flink Kubernetes Operator..."
    
    # 添加 Flink Operator Helm 仓库
    helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.7.0/
    helm repo update
    
    # 创建 Flink 命名空间
    kubectl create namespace flink-system
    
    # 安装 Flink Operator
    helm install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator \
        --namespace flink-system \
        --set webhook.create=false \
        --set defaultConfiguration.create=true \
        --set defaultConfiguration.append=true \
        --set 'defaultConfiguration.flink-conf.yaml=|
        taskmanager.numberOfTaskSlots: 2
        state.backend: rocksdb
        state.checkpoints.dir: s3://your-flink-bucket/checkpoints
        state.savepoints.dir: s3://your-flink-bucket/savepoints
        execution.checkpointing.interval: 60s
        restart-strategy: fixed-delay
        restart-strategy.fixed-delay.attempts: 3'
    
    echo "✅ Flink Operator 安装完成"
}

# 主执行流程
main() {
    check_tools
    
    echo "请选择操作:"
    echo "1) 创建 EKS 集群"
    echo "2) 设置 EMR on EKS"
    echo "3) 安装 Flink Operator"
    echo "4) 全部执行"
    
    read -p "请输入选项 (1-4): " choice
    
    case $choice in
        1) create_eks_cluster ;;
        2) setup_emr_on_eks ;;
        3) install_flink_operator ;;
        4) 
            create_eks_cluster
            setup_emr_on_eks
            install_flink_operator
            ;;
        *) echo "无效选项" && exit 1 ;;
    esac
    
    echo "🎉 设置完成!"
}

main "$@"