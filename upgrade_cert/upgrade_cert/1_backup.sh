#!/bin/bash
mv /etc/kubernetes/pki/apiserver.key /etc/kubernetes/pki/apiserver.key.old
mv /etc/kubernetes/pki/apiserver.crt /etc/kubernetes/pki/apiserver.crt.old
mv /etc/kubernetes/pki/apiserver-kubelet-client.crt /etc/kubernetes/pki/apiserver-kubelet-client.crt.old
mv /etc/kubernetes/pki/apiserver-kubelet-client.key /etc/kubernetes/pki/apiserver-kubelet-client.key.old
mv /etc/kubernetes/pki/front-proxy-client.crt /etc/kubernetes/pki/front-proxy-client.crt.old
mv /etc/kubernetes/pki/front-proxy-client.key /etc/kubernetes/pki/front-proxy-client.key.old
