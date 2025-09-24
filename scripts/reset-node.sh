#!/bin/bash
set -e

# 클러스터 초기화
sudo kubeadm reset -f

# kubeconfig 삭제
rm -f ~/.kube/config