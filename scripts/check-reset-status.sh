#!/bin/bash
set -euo pipefail
IFACE=${IFACE:-$(ip route show default | awk '{print $5}' | head -1)}

ok(){ echo "[OK]  $*"; }
warn(){ echo "[WARN] $*"; }

echo "== K8s/Flannel 체인 점검 =="
sudo iptables -t nat -S | grep -Eq 'KUBE|FLANNEL' && { sudo iptables -t nat -S | grep -E 'KUBE|FLANNEL' | sed 's/^/[NAT] /'; warn "nat 잔존"; } || ok "nat ok"
sudo iptables -S        | grep -Eq 'KUBE|FLANNEL' && { sudo iptables -S        | grep -E 'KUBE|FLANNEL' | sed 's/^/[FILTER] /'; warn "filter 잔존"; } || ok "filter ok"

echo "== WireGuard 규칙 (-v 카운터) =="
sudo iptables -L -n -v | grep -qE '\swg0\s' && { sudo iptables -L -n -v | grep -E '\swg0\s' | sed 's/^/[WG] /'; ok "wg0 필터 규칙 존재"; } || warn "wg0 필터 규칙 없음"

echo "== NAT MASQUERADE(${IFACE}) 점검 =="
if sudo iptables -t nat -S POSTROUTING | grep -q -- "-o ${IFACE} .* -j MASQUERADE"; then
  sudo iptables -t nat -S POSTROUTING | grep -- "-o ${IFACE} .* -j MASQUERADE" | sed 's/^/[NAT] /'
  ok "MASQUERADE(-o ${IFACE}) 존재"
elif sudo iptables -t nat -L -n -v | grep -q "MASQUERADE.*${IFACE}"; then
  sudo iptables -t nat -L -n -v | grep "MASQUERADE.*${IFACE}" | sed 's/^/[NAT] /'
  ok "MASQUERADE(${IFACE}) 존재"
else
  warn "MASQUERADE(-o ${IFACE}) 없음"
fi

echo "== 잔여 CNI 링크 점검 =="
ip -o link show | grep -Eq 'cni0|flannel\.1|cali|cni-' && { ip -o link show | grep -E 'cni0|flannel\.1|cali|cni-' | sed 's/^/[LINK] /'; warn "CNI 링크 잔존"; } || ok "links ok"
