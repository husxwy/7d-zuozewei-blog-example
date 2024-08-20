

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

kubectl config get-contexts 

vim ~/.zshrc
alias ks='kubectl config set-context --current --namespace '
alias ku='kubectl config use-context '
source ~/.zshrc
ks 7d
kubectl config get-contexts 
# CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
# *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   7d
ks 7d


k config use-context kubernetes-admin@kubernetes 
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
# elfLink was empty 在k8s集群 v1.20之前都存在，在v1.20之后被删除，需要在/etc/kubernetes/manifests/kube-apiserver.yaml 添加参数
# 所有 master 节点执行
vim /etc/kubernetes/manifests/kube-apiserver.yaml 

# spec:
#   containers:
#   - command:
#     - kube-apiserver
#     - --feature-gates=RemoveSelfLink=false  # 添加

kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml

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

ks 7d

k apply -f mysql-min-pv-nfs.yaml 
k get pv
# Retain

k delete -f mysql-min-pvc.yaml
k apply -f mysql-min-pvc.yaml -n 7d
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

# TODO 存储
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

ssh root@10.8.14.84

# 运行容器生成证书
docker run --name elastic-charts-certs -i -w /app elasticsearch:7.7.1 /bin/sh -c  \
  "elasticsearch-certutil ca --out /app/elastic-stack-ca.p12 --pass '' && \
    elasticsearch-certutil cert --name security-master --dns \
    security-master --ca /app/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /app/elastic-certificates.p12"

# 从容器中将生成的证书拷贝出来
docker cp elastic-charts-certs:/app/elastic-certificates.p12 ./ 

# 删除容器
docker rm -f elastic-charts-certs

# 将 pcks12 中的信息分离出来，写入文件
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem

# 添加证书
kubectl create secret generic elastic-certificates --from-file=elastic-certificates.p12 -n 7d
kubectl create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem -n 7d

# 设置集群用户名密码，用户名不建议修改
kubectl create secret generic elastic-credentials \
  --from-literal=username=elastic --from-literal=password=admin@123 -n 7d

k get secret

helm uninstall elasticsearch-master

# TODO 健康检查问题，删除健康检查
# 安装 ElasticSearch Master 节点  2节点
helm install elasticsearch-master -f es-master-values.yaml --version 7.7.1 elastic/elasticsearch

k get pvc

k get sts
k get sts elasticsearch-master -o yaml
k des

# NOTES:
# 1. Watch all cluster members come up.
kubectl get pods --namespace=7d -l app=elasticsearch-master -w
# 2. Test cluster health using Helm test.
helm test elasticsearch-master --cleanup

helm uninstall elasticsearch-data
# 安装 ElasticSearch Data 节点
helm install elasticsearch-data -f es-data-values.yaml --version 7.7.1 elastic/elasticsearch

helm uninstall elasticsearch-client
# 安装 ElasticSearch Client 节点
helm install elasticsearch-client -f es-client-values.yaml --version 7.7.1 elastic/elasticsearch 

helm uninstall kibana
# Helm 安装 Kibana
helm install kibana -f es-kibana-values.yaml --version 7.7.1 elastic/kibana

k delete pvc elasticsearch-data-elasticsearch-data-0  elasticsearch-data-elasticsearch-data-1 elasticsearch-master-elasticsearch-master-0  elasticsearch-master-elasticsearch-master-1

k get deploy

k get deploy kibana-kibana

helm install --name elasticsearch elastic/elasticsearch --version  7.7.1

helm show values elastic/elasticsearch
helm install elasticsearch --version 7.7.1 elastic/elasticsearch
helm install elasticsearch --version 7.7.1 elastic/elasticsearch

cd /usr/share/elasticsearch/config

cat elasticsearch.yml

# 未开启xpack 不需要账号密码

helm install kibana  --version 7.7.1 elastic/kibana
# 修改端口为 30601


```


## jmeter-k8s

```shell




cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-jmeter-cluster
ls |awk '{print $NF}'



ks 7d

k apply -f jmeter_influxdb_configmap.yaml

k apply -f influxdb_pvc.yaml

k get pvc |grep influxdb

k apply -f jmeter_influxdb_deploy.yaml


influx  #登录数据库
 version 1.6.2

 show databases  #查看所有数据库


 CREATE DATABASE "jmeter"  #创建数据库
 


 use jmeter               #切换数据库
 # 84
 CREATE USER "admin" WITH PASSWORD 'admin' WITH ALL PRIVILEGES 
 # 41
 CREATE USER "admin" WITH PASSWORD '5R6WS#ZQ;276' WITH ALL PRIVILEGES 
# 创建管理员权限的用户

cat jmeter_cluster_create.sh
# 需要重建命名空间
sh jmeter_cluster_create.sh

sh ./dashboard.sh
# Incorrect Usage. flag provided but not defined: -execute
#  influx 2.* 无execute 命令 使用 1.8.6

sh ./start_test.sh

sh start_test.sh web-test.jmx

模版：5496


```

## nacos 

单机版
```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-nacos-v1.4
ls |awk '{print $NF}'

ks 7d

tenant=7d
echo $tenant
mysql_pod=`kubectl get po -n $tenant | grep mysql | awk '{print $1}'`
echo $mysql_pod
kubectl exec -ti -n $tenant $mysql_pod -- cp /nacos.sql /nacos.sql

kubectl cp "nacos.sql" -n $tenant "$mysql_pod:/nacos.sql"

kubectl cp "nacos.sql" -n 7d -c mysql-min "mysql-min-f88796f89-hn99j:/tmp/"


kubectl exec -ti -n 7d mysql-min-f88796f89-hn99j -- bash
mysql -h host -P port_number -u username -p password <file_to_execute.sql
# 提示输入密码，直接回车
mysql -u root -p   < nacos.sql

mysql -u root -p $MYSQL_ROOT_PASSWORD  < nacos.sql

mysql --user=root --password=$MYSQL_ROOT_PASSWORD 

kubectl cp "nacos-user.sql" -n 7d -c mysql-min "mysql-min-f88796f89-hn99j:/tmp/"
mysql -u root -p   < nacos-user.sql

SELECT user,Host FROM  mysql.user;

SHOW GRANTS FOR 'nacos'@'%';


k apply -f nacos-stand.yaml

http://10.8.14.84:30018/nacos/#/login
nacos/nacos
```


## prometues

```shell
cd /Users/husx/data/git/github/husxwy/ansible/Kubernetes/Prometheus/kube-prometheus-0.8.0-test

kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/

ks  monitoring

# 修改 Deployments grafana  StatefulSets prometheus-k8s nodePort
k  get service grafana -o yaml| sed 's/type: ClusterIP/type: NodePort/g' | kubectl replace -f -

k  get svc grafana

10.8.14.84:32077
admin
admin


k  get service prometheus-k8s

k  get service prometheus-k8s -o yaml| sed 's/type: ClusterIP/type: NodePort/g' | kubectl replace -f -

10.8.14.84:32201

模版

|jemter | 5496 | |
| k8s | 13105 |  |
| redis | 13105 |  |
| mongodb | 2583 | |

```
##  redis

```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-kube-promethues-auto-discover
ls |awk '{print $NF}'

ks 7d

cd redis

k apply -f redis-storage.yaml 

k get pvc |grep reids 

k apply -f redis-config.yaml

k apply -f promethues-redis.yaml 

k get deploy |grep redis
k get pod -owide |grep redis
k get svc -owide |grep redis
curl 172.18.143.90:9121/metrics
k get pod -owide |grep centos
k exec -it centos-6f8b8ddb99-qsv58 -c centos -- curl 172.18.143.90:9121/metrics

k  get service cloud-redis  -o yaml| sed 's/type: ClusterIP/type: NodePort/g' | kubectl replace -f -

k  get service cloud-redis
# 6379:31233/TCP,9121:31549/TCP

k get prometheus k8s -n monitoring -o yaml

k explain Prometheus 
k explain Prometheus.spec.additionalScrapeConfigs

# kubectl apply -f secret generic additional-configs --from-file=prometheus-additional.yaml -n monitoring

# 
# apiVersion: monitoring.coreos.com/v1
# kind: Prometheus
# spec:
#   additionalScrapeConfigs:
#     name: additional-configs
#     key: prometheus-additional.yaml
```

## mongo
```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-kube-promethues-auto-discover
ls |awk '{print $NF}'

ks 7d

cd mongo

k apply -f mongo-storage.yaml 

k get pvc |grep mongo 

k apply -f mongo-config.yaml

k apply -f promethues-mongo-deploy.yaml 

k get deploy |grep mongo
k get pod -owide |grep db-mongo 
k get svc -owide |grep db-mongo 
curl 172.18.143.90:9121/metrics
k get pod -owide |grep centos
k exec -it centos-6f8b8ddb99-qsv58 -c centos -- curl 172.18.30.245:9104/metrics

k  get service db-mongo -o yaml| sed 's/type: ClusterIP/type: NodePort/g' | kubectl replace -f -

k  get service db-mongo 
# 27017:31753/TCP,9104:30549/TCP

```

## rabbitmq
```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-kube-promethues-auto-discover
ls |awk '{print $NF}'

ks 7d

cd rabbitmq

k apply -f rabbitmq-storage.yaml 

k get pvc |grep rabbitmq 

k apply -f rabbitmq-config.yaml

k apply -f promethues-rabbitmq-deploy.yaml 

k get deploy |grep rabbitmq
k get pod -owide |grep cloud-rabbitmq 
k get svc -owide |grep cloud-rabbitmq 
k get pod -owide |grep centos
k exec -it centos-6f8b8ddb99-qsv58 -c centos -- curl 172.18.239.176:9419/metrics

k  get service cloud-rabbitmq  -o yaml| sed 's/type: ClusterIP/type: NodePort/g' | kubectl replace -f -

k  get service cloud-rabbitmq 
#  5672:31029/TCP,15672:30455/TCP,9419:31500/TCP

# 开启 开启管理功能
rabbitmq-plugins enable rabbitmq-plugins enable

http://10.8.14.84:30455/
guest/guest
```

## skywalking
```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-skywalking


git clone https://github.com/apache/skywalking-kubernetes
cd skywalking-kubernetes/chart
helm repo add elastic https://helm.elastic.co
helm dep up skywalking
export SKYWALKING_RELEASE_NAME=skywalking  # 定义自己的名称
export SKYWALKING_RELEASE_NAMESPACE=7d  # 定义自己的命名空间

cp ../values-my-es.yaml  ./skywalking/values-7d-es.yaml
helm install "${SKYWALKING_RELEASE_NAME}" skywalking -n "${SKYWALKING_RELEASE_NAMESPACE}" \
  -f  ./skywalking/values-7d-es.yaml

helm install skywalking skywalking/skywalking -n  7d  -f ./values-7d-es.yaml



docker build -t  harbor.kefu.com/test/skywalking-agent:8.1.0 .

docker push harbor.kefu.com/test/skywalking-agent:8.1.0


```


```shell
cd /Users/husx/data/git/github/husxwy/7d-zuozewei-blog-example/Kubernetes/k8s-kube-promethues-auto-discover
ls |awk '{print $NF}'

ks 7d

cd 

```

## app


| 应用名 |地址链接|账号|密码|
|-----|-----|-----|-----|
| k8s |http://10.8.14.84:32567/dashboard| | |
| nacos | http://10.8.14.84:30018/nacos/#/login | nacos |nacos| 
| grafana | http://10.8.14.84:32077 | admin | admin| 
| prometheus | http://10.8.14.84:32201 |  | | 
| mysql | 10.8.14.84:30336| root | 9ZeNk0DghH | 
| skywalking | http://10.8.14.84:32165|  | | 
| rabbitmq management | http://10.8.14.84:30455| guest  | guest | 
| Spring Boot Admin | http://10.8.14.84:30399/| 7d | 123456 | 
| | |  | | 
| | |  | | 
| | |  | | 
| | |  | | 

