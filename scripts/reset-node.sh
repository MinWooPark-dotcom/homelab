#!/bin/bash
set -euo pipefail

ROLE=${1:-}

if [[ -z "$ROLE" ]]; then
  echo "Usage: $0 <master|worker>"
  exit 1
fi

echo "[0] stop kubelet"
sudo systemctl stop kubelet || true

echo "[1] kubeadm reset"
sudo kubeadm reset -f

echo "[2] remove k8s/CNI dirs"
if [[ "$ROLE" == "master" ]]; then
  sudo rm -rf /etc/kubernetes /var/lib/etcd
fi
sudo rm -rf /var/lib/cni /etc/cni/net.d /var/lib/kubelet

echo "[3] delete CNI links"
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true
sudo ip link delete vxlan.calico 2>/dev/null || true
for dev in $(ip -o link show | awk -F': ' '/(^| )(cali|cni-)/{print $2}'); do
  sudo ip link delete "$dev" 2>/dev/null || true
done

echo "[4] iptables backup"
sudo iptables-save > "$HOME/iptables.backup" || true

echo "[5] drop KUBE/FLANNEL in nat (jump rules -> chains)"
for CH in PREROUTING OUTPUT POSTROUTING; do
  sudo iptables -t nat -L $CH --line-numbers \
  | awk '/KUBE-|FLANNEL-/{print $1}' \
  | sort -rn | while read -r N; do sudo iptables -t nat -D $CH $N || true; done
done
for C in $(sudo iptables -t nat -S | awk '/^-N (KUBE|FLANNEL)/{print $2}'); do
  sudo iptables -t nat -F "$C" || true
  sudo iptables -t nat -X "$C" || true
done

echo "[6] drop KUBE/FLANNEL in filter (jump rules -> chains)"
for CH in INPUT FORWARD OUTPUT; do
  sudo iptables -L $CH --line-numbers \
  | awk '/KUBE-|FLANNEL-/{print $1}' \
  | sort -rn | while read -r N; do sudo iptables -D $CH $N || true; done
done
for C in $(sudo iptables -S | awk '/^-N (KUBE|FLANNEL)/{print $2}'); do
  sudo iptables -F "$C" || true
  sudo iptables -X "$C" || true
done

echo "[7] flush conntrack"
sudo conntrack -F 2>/dev/null || true

echo "[8] restart container runtime"
sudo systemctl restart containerd || true

echo "[9] kubeconfig remove"
rm -f "$HOME/.kube/config" || true

echo "[done] reset for $ROLE node completed (WG/NAT kept)"
