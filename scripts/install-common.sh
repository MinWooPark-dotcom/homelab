#!/bin/bash
set -e

# apt 업데이트 및 Kubernetes 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# /etc/apt/keyrings 디렉토리 보장
sudo mkdir -p -m 755 /etc/apt/keyrings

# Kubernetes 패키지를 설치할 때 사용할 저장소 공개 서명 키를 다운로드 및 등록
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Kubernetes apt 저장소 추가
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# apt 패키지 업데이트, kubelet, kubeadm, kubectl 설치 및 버전 고정
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# kubelet 실행
sudo systemctl enable --now kubelet
