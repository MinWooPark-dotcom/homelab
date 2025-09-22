# Scripts

쿠버네티스 클러스터를 수동 설치하는 과정을 자동화한 Bash 스크립트 모음입니다.  
Ansible로 확장하기 전 단계로, 직접 명령어를 자동화해 반복 가능한 설치를 목표로 합니다.

## 전제 조건
- 모든 노드는 네트워크에 연결되어 있어야 합니다.
- swap은 비활성화되어 있어야 합니다.

## 스크립트 파일
- **install-common.sh**  
  모든 노드에서 공통으로 실행. containerd, kubeadm, kubelet, kubectl 설치 및 초기 설정.
- **init-master.sh**  
  마스터 노드 초기화(`kubeadm init`). 실행 후 출력되는 join 명령을 저장해야 함.

- **join-worker.sh**  
  워커 노드에서 실행. `init-master.sh`가 출력한 join 명령을 인자로 넘겨 실행.

- **reset-cluster.sh**  
  클러스터 완전 초기화. kubeadm, CNI, iptables 흔적까지 제거.

- **reset-worker-node.sh**  
  워클러스터 완전 초기화. kubeadm, CNI, iptables 흔적까지 제거.

## 사용법
```bash
chmod +x ./scripts
# 모든 노드에서 공통 설치
./install-common.sh
# 마스터 노드 초기화
./init-master.sh
# 워커 노드 조인
./join-worker.sh "<kubeadm join ...>"
# 필요 시 모든 노드에서 클러스터 초기화
./reset-node.sh master 
./reset-node.sh worker
```

## 클러스터 초기화 전/후 확인 방법
네트워크 인터페이스 확인
```bash
ip a
```
- 리셋 전: cni0, flannel.1, cali* 같은 가상 인터페이스가 보일 수 있음.
- 리셋 후: 물리 인터페이스(eth0, enp3s0 등)와 lo만 남아야 정상.

iptables 규칙 확인
```bash
sudo iptables -t nat -S | grep KUBE
```
- 리셋 전: KUBE-SERVICES, KUBE-POSTROUTING, KUBE-FORWARD 같은 체인 보임.
- 리셋 후: INPUT, OUTPUT, FORWARD 같은 기본 체인만 남아야 정상.

kubeconfig 확인
```bash
ls -l ~/.kube/config
```
- 리셋 전: 존재.
- 리셋 후: 삭제됨.