#!/bin/bash
set -e

# /etc/cni/net.d/ 파일 확인
if sudo test -d /etc/cni/net.d && [ "$(sudo ls /etc/cni/net.d)" ]; then
  echo "Exist /etc/cni/net.d/ file"
else
  echo "No /etc/cni/net.d/ file"
fi

# /var/lib/cni 디렉토리 확인
if sudo test -d /var/lib/cni; then
  echo "Exist /var/lib/cni directory"
else
  echo "No /var/lib/cni directory"
fi

# kubeconfig 파일 확인
if [ -f ~/.kube/config ]; then
  echo "Exist ~/.kube/config file"
else
  echo "No ~/.kube/config file"
fi