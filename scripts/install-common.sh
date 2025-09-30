#!/bin/bash
set -e

# 1. containerd 설치
sudo apt update
sudo apt install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# SystemdCgroup = true 설정 변경
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# containerd 서비스 실행
sudo systemctl enable --now containerd

# 2. Kubernetes 필수 패키지 설치 및 저장소 추가
sudo apt install -y apt-transport-https ca-certificates curl gpg

# Kubernetes 패키지를 설치할 때 사용할 저장소 공개 서명 키를 다운로드 및 등록
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Kubernetes apt 저장소 추가
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 3. kubelet, kubeadm, kubectl 설치
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# kubelet 실행
sudo systemctl enable --now kubelet
