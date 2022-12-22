

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

```
kubectl get nodes


```

