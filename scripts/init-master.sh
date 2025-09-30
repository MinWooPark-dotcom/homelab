#!/bin/bash
set -e

# kubeadm init 실행
# Pod 네트워크에 할당할 CIDR 블록은 CNI 플러그인에 따라 요구값이 다름. Flannel은 10.244.0.0/16에 해당. 마스터 노드의 LAN IP를 명시적으로 지정.
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.0.10

# kubectl config 복사
# root 전용 파일인 admin.conf를 현재 사용자 홈 디렉토리(~/.kube/config)로 복사 후 해당 파일의 소유권을 현재 사용자에게 변경.
# root 외에도 현재 사용자 계정에서 kubectl 명령을 쓸 수 있음.
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 마지막 kubeadm token create --print-join-command 출력 값을 사용하여 워커 노드에서 마스터 노드로 조인
kubeadm token create --print-join-command