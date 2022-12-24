

```shell
git clone git@github.com:husxwy/7d-zuozewei-blog-example.git
```
```log
error: Untracked working tree file '.DS_Store' would be overwritten by merge.
fatal: unable to checkout working tree
warning: Clone succeeded, but checkout failed.
You can inspect what was checked out with 'git status'
and retry with 'git restore --source=HEAD :/'
```

```shell
git reset --hard HEAD

git pull
git branch
git checkout -b husx

git branch
git push origin husx:husx


find ./ -name ".DS_Store" -exec rm {} \;
subl .gitignore 

subl rademe.husx.md
```

## k8s

v1.22.2
3 master

```shell
k create ns 7d
```


## nfs-Provisioner

```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-nfs-provisioner
ls |awk '{print $NF}'
nfs-provisioner-deploy.yaml
nfs-rbac.yaml
nfs-storage.yaml
test-helm-pod.yaml
test-helm-pvc.yaml
test-pod.yaml
test-pvc.yaml

root@10.8.15.31      

mkdir -p /data/nfs/k8stest/7d/provisioner

/data/nfs/k8stest/7d/provisioner 

# unexpected error getting claim reference: selfLink was empty, can't make reference
# 所有 master 节点执行
vim /etc/kubernetes/manifests/kube-apiserver.yaml 

# spec:
#   containers:
#   - command:
#     - kube-apiserver
#     - --feature-gates=RemoveSelfLink=false  # 添加


k apply -f nfs-rbac.yaml -n 7d

kubectl apply -f nfs-provisioner-deploy.yaml -n 7d

k -n 7d get deploy

k delete sc nfs-storage 

kubectl apply -f nfs-storage.yaml

k get sc


k -n 7d delete pvc test-pvc
k -n 7d delete -f test-pvc.yaml
k -n 7d apply -f test-pvc.yaml
k -n 7d get pv
k -n 7d get pvc

k -n 7d get pvc test-pvc -o yaml

k -n 7d delete -f test-pod.yaml

k -n 7d apply -f test-pod.yaml

k -n 7d get po test-pod  -o yaml

k -n 7d describe po test-pod 

#   MountVolume.SetUp failed for volume "kube-api-access-6nrwt" : object "7d"/"kube-root-ca.crt" not registered

k -n 7d apply -f test-deploy.yaml

k -n 7d get po test-deploy  -o yaml

k -n 7d describe deploy test-deploy 
```

## mysql
```shell
kubectl get nodes

root@10.8.15.31      

mkdir -p /data/nfs/k8stest/7d/mysql
groupadd -g 27 mysql
useradd -u 27 -g mysql mysql
id mysql
cd /data/nfs/k8stest/7d 
chown -R mysql:mysql mysql

k apply -f mysql-min-pv-nfs.yaml 
k get pv
# Retain

k delete -f mysql-min-pvc.yaml
k apply -f mysql-min-pvc.yaml
k get pvc
# Pending

k apply -f mysql-min-secret.yaml

k get Secret

k apply -f mysql-config.yaml  
k get  cm

k delete -f mysql-min-deployment.yaml
k delete -f mysql-min-service.yaml  

# docker run -di --name=tensquare_mysql -p 33306:3306 -e MYSQL_ROOT_PASSWORD=123456 centos/mysql-57-centos7

# 删除 MYSQL_PASSWORD
k apply -f mysql-min-deployment.yaml

k apply -f mysql-min-service.yaml  

 
k apply -f mysql-min-backup-job.yaml 

ERROR 1290 (HY000) at line 1: The MySQL server is running with the --skip-grant-tables option so it cannot execute this statement

ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)


10.8.14.84_30336_root_9ZeNk0DghH

```

## es
```shell
# 添加 Chart 仓库
helm repo add  elastic    https://helm.elastic.co
helm repo update
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-ek
# 安装 ElasticSearch Master 节点
helm install elasticsearch-master -f es-master-values.yaml --version 7.7.1 elastic/elasticsearch

# NOTES:
# 1. Watch all cluster members come up.
kubectl get pods --namespace=default -l app=elasticsearch-master -w
# 2. Test cluster health using Helm test.
helm test elasticsearch-master --cleanup

# 安装 ElasticSearch Data 节点
helm install elasticsearch-data -f es-data-values.yaml --version 7.7.1 elastic/elasticsearch

# 安装 ElasticSearch Client 节点
helm install elasticsearch-client -f es-client-values.yaml --version 7.7.1 elastic/elasticsearch 

# Helm 安装 Kibana
helm install kibana -f es-kibana-values.yaml --version 7.7.1 elastic/kibana
```

