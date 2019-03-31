# k8s kubeadm 证书过期解决办法

如果kubeadm 的版本在1.8之前需要更新kubeadm

```
$ sudo curl -sSL https://dl.k8s.io/release/v1.8.15/bin/linux/amd64/kubeadm > ./kubeadm.1.8.15
$ chmod a+rx kubeadm.1.8.15
$ sudo mv /usr/bin/kubeadm /usr/bin/kubeadm.1.7
$ sudo mv kubeadm.1.8.15 /usr/bin/kubeadm
```

1. 备份旧的apiserver，apiserver-kubelet-client和前端代理客户端证书和密钥。

```
$ sudo mv /etc/kubernetes/pki/apiserver.key /etc/kubernetes/pki/apiserver.key.old
$ sudo mv /etc/kubernetes/pki/apiserver.crt /etc/kubernetes/pki/apiserver.crt.old
$ sudo mv /etc/kubernetes/pki/apiserver-kubelet-client.crt /etc/kubernetes/pki/apiserver-kubelet-client.crt.old
$ sudo mv /etc/kubernetes/pki/apiserver-kubelet-client.key /etc/kubernetes/pki/apiserver-kubelet-client.key.old
$ sudo mv /etc/kubernetes/pki/front-proxy-client.crt /etc/kubernetes/pki/front-proxy-client.crt.old
$ sudo mv /etc/kubernetes/pki/front-proxy-client.key /etc/kubernetes/pki/front-proxy-client.key.old
```

2. 生成新的apiserver，apiserver-kubelet-client和front-proxy-client证书和密钥。

```
$ sudo kubeadm alpha phase certs apiserver --apiserver-advertise-address <IP address of your master server>
$ sudo kubeadm alpha phase certs apiserver-kubelet-client
$ sudo kubeadm alpha phase certs front-proxy-client
```

3. 备份旧配置文件

```
$ sudo mv /etc/kubernetes/admin.conf /etc/kubernetes/admin.conf.old
$ sudo mv /etc/kubernetes/kubelet.conf /etc/kubernetes/kubelet.conf.old
$ sudo mv /etc/kubernetes/controller-manager.conf /etc/kubernetes/controller-manager.conf.old
$ sudo mv /etc/kubernetes/scheduler.conf /etc/kubernetes/scheduler.conf.old
```

4. 生成新的配置文件。

这里有一个重要的注意事项。如果您在AWS上，则需要`--node-name`在此请求中显式传递参数。否则，您将收到如下错误：`Unable to register node "ip-10-0-8-141.ec2.internal" with API server: nodes "ip-10-0-8-141.ec2.internal" is forbidden: node ip-10-0-8-141 cannot modify node ip-10-0-8-141.ec2.internal`在您的日志中`sudo journalctl -u kubelet --all | tail`，主节点将报告`Not Ready`您运行时的状态`kubectl get nodes`。

请务必替换传入的值`--apiserver-advertise-address`并`--node-name`使用正确的环境值。

```
$ sudo kubeadm alpha phase kubeconfig all --apiserver-advertise-address 10.0.8.141 --node-name ip-10-0-8-141.ec2.internal
[kubeconfig] Wrote KubeConfig file to disk: "admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "scheduler.conf"
```

5. 确保您`kubectl`正在寻找配置文件的正确位置。

```
$ mv .kube/config .kube/config.old
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
$ sudo chmod 777 $HOME/.kube/config
$ export KUBECONFIG=.kube/config
```

6. 重新启动主节点

```
$ sudo /sbin/shutdown -r now
```

7. 重新连接到主节点并获取令牌，并验证主节点是否“就绪”。将令牌复制到剪贴板。您将在下一步中使用它。

```
$ kubectl get nodes
$ kubeadm token list
```

证书生成后重启api-server启动不了。提示找不到master1节点，查看etcd 发现etcd的状态不对，证书也过期了。需要重新生成etcd的证书。需要修改ca-config.json  里的过期时间。

```
cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem \ -ca-key=/etc/kubernetes/ssl/ca-key.pem \ -config=/etc/kubernetes/ssl/ca-config.json \ -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
ls etcd* 
etcd.csr  etcd-csr.json  etcd-key.pem  etcd.pem 
mkdir -p /etc/etcd/ssl
mv etcd*.pem /etc/etcd/ssl/
```

查看etcd的状态

```
[root@master1 etcd]# etcdctl --endpoints=https://10.116.18.145:2379 --ca-file=/etc/etcd/ssl/ca.pem --cert-file=/etc/etcd/ssl/etcd.pem --key-file=/etc/etcd/ssl/etcd-key.pem cluster-health
2019-03-31 15:18:31.919967 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated
2019-03-31 15:18:31.920633 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated
member 5631425343d8b20 is healthy: got healthy result from https://10.116.18.145:2379
member 939263a827aa51fe is healthy: got healthy result from https://10.116.18.146:2379
member 98b63f6a6282be46 is healthy: got healthy result from https://10.116.18.147:2379
cluster is healthy
```

查看集群情况

```
[root@master1 etcd]# kubectl  get nodes
NAME      STATUS    ROLES     AGE       VERSION
master1   Ready     master    1y        v1.9.4
master2   Ready     master    362d      v1.9.4
master3   Ready     master    362d      v1.9.4
node1     Ready     <none>    363d      v1.9.4
node2     Ready     <none>    250d      v1.9.4
node3     Ready     <none>    242d      v1.9.4
node4     Ready     <none>    354d      v1.9.4
node5     Ready     <none>    254d      v1.9.4
node6     Ready     <none>    250d      v1.9.4
node7     Ready     <none>    354d      v1.9.4
node8     Ready     <none>    167d      v1.9.4
node9     Ready     <none>    167d      v1.9.4
```

