---
typora-copy-images-to: ../image
---

# helm 安装

## 用途

 Helm是一种简化Kubernetes应用程序安装和管理的工具。

## 组件

* helm（client）

本地chart 开发,仓库管理,与tiller server 交互,发送预安装的chart，release 管理。

* tiller （server）

监听来自helm client的请求，通过chart及配置构建应用，安装chart到k8s，并跟踪随后的发布，管理k8s的chart

## 概念

* chart：包含了创建 `Kubernetes`的一个应用实例的必要信息
* config：包含了应用发布配置信息
* release：是一个 chart 及其配置的一个运行实例

## 安装

### 安装 helm 

```shell
$ wget https://github.com/helm/helm/archive/v2.10.0.tar.gz
$ tar -zxvf v2.10.0.tar.gz
$ mv helm /usr/bin/
```

### 安装tiller

```shell
$ helm init --upgrade --tiller-image cnych/tiller:v2.10.0  --stable-repo-url https://cnych.github.io/kube-charts-mirror/helm init --upgrade --tiller-image cnych/tiller:v2.10.0  --stable-repo-url https://cnych.github.io/kube-charts-mirror/

$ kubectl create -f helm_rbac.yaml
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

```

## 检查

```shell
$ helm version 
Client: &version.Version{SemVer:"v2.10.0", GitCommit:"9ad53aac42165a5fadc6c87be0dea6b115f93090", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.10.0", GitCommit:"9ad53aac42165a5fadc6c87be0dea6b115f93090", GitTreeState:"clean"}
```



## helm 在k8s 集群外安装

拷贝.kube 目录，目的是连接k8s 集群。

```shell
scp -r .kube   .
```

helm 初始化

```shell
$ helm init --client-only  --stable-repo-url https://cnych.github.io/kube-charts-mirror/
```



## 构建私有的 stable-repo

启动stable serve ，如下所示，启动后只能通过http://127.0.0.1:8879的方式访问。

```
helm serve 
Regenerating index. This may take a moment.
Now serving you on 127.0.0.1:8879
```

如果想要痛机器IP访问的话加上—address。

```
helm serve --address 10.116.18.104:8879
Regenerating index. This may take a moment.
Now serving you on 10.116.18.93:8879
```

![image-20180906174808890](/Volumes/mac-d/github/k8s_learn/image/image-20180906174808890.png)

