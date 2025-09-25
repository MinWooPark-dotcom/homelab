# Scripts

쿠버네티스 클러스터를 수동 설치하는 과정을 자동화한 Bash 스크립트 모음입니다.  
Ansible로 확장하기 전 단계로, 직접 명령어를 자동화해 반복 가능한 설치를 목표로 합니다.

## 전제 조건
- 모든 노드는 네트워크에 연결되어 있어야 합니다.
- K8s는 RAM을 기준으로 리소스를 관리해야 정확한 스케줄링이 보장되므로 메모리 스왑(swap)은 비활성화되어 있어야 합니다.

## 스크립트 파일
- install-common.sh  
  - 모든 노드에서 공통으로 실행. K8s docs "Installing kubeadm - Installing kubeadm, kubelet and kubectl"에 해당.
- init-master.sh  
  - 마스터 노드 초기화. K8s docs "Creating a cluster with kubeadm - Initializing your control-plane node"에 해당.
- reset-node.sh  
  - 클러스터 초기화. 
- install-cni
  - CNI 설치.
- check-reset-node
  - 클러스터 정상 초기화가 되었는지 확인.

## 사용법
```bash
# scripts 디렉토리에 있는 shell script에 실행 권한 부여
cd /scripts
chmod +x *.sh

./install-common.sh
./init-master.sh
# ./init-master.sh의 출력값을 실행하여 워커노드 조인
# e.g. sudo kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
./install-cni.sh


# 필요 시 노드 초기화
./reset-node.sh
./check-reset-node.sh
```

## 개념
- CNI
  - 랜카드의 역할을 하는 가상 인터페이스.
  - CNI 규격에 맞추어 만들어 네트워크 인터페이스를 만드는 CNI plugin을 설치해야 K8s 내에서 네트워크 가능함.
  - CNI 설정(/etc/cni/net.d/*.conflist) 을 읽어서 네트워크 세팅을 함.
  - 주의해야 할 점은 CNI 교체 시 /etc/cni/net.d/ 에서 기존 CNI plugin 파일 제거해야함.