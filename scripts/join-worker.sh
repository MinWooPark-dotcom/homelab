#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./join-worker.sh '<kubeadm join command>'"
  exit 1
fi

# 인자로 받은 kubeadm join 실행
sudo $1
echo "[INFO] Worker node joined cluster."
