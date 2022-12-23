

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

