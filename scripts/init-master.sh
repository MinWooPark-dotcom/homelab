#!/bin/bash
set -e

# kubeadm init 실행
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# kubectl config 복사
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[INFO] Master node initialized."
echo "[INFO] Save the join command below and run it on worker nodes:"
kubeadm token create --print-join-command
# 마지막 kubeadm token create --print-join-command 출력으로 워커 노드가 조인할 때 필요한 kubeadm join 명령 생성