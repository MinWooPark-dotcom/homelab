#!/bin/bash
set -e

# 클러스터 초기화
sudo kubeadm reset -f

# CNI 설정 삭제
sudo rm -rf /etc/cni/net.d
sudo rm -rf /var/lib/cni

# kubeconfig 삭제
rm -f ~/.kube/config

# containerd 재시작
sudo systemctl restart containerd