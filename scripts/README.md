# Scripts

쿠버네티스 클러스터를 수동 설치하는 과정을 자동화한 Bash 스크립트 모음입니다.  
Ansible로 확장하기 전 단계로, 직접 명령어를 자동화해 반복 가능한 설치를 목표로 합니다.

## 전제 조건
- 모든 노드는 네트워크에 연결되어 있어야 합니다.
- 메모리 스왑(swap)은 비활성화되어 있어야 합니다.

## 스크립트 파일
- install-common.sh  
  모든 노드에서 공통으로 실행. K8s docs Installing kubeadm - Installing kubeadm, kubelet and kubectl에 해당
- init-master.sh  
  마스터 노드 초기화
- reset-node.sh  
  클러스터 초기화

## 사용법
```bash
# scripts 디렉토리에 있는 shell script에 실행 권한 부여
cd /scripts
chmod +x *.sh

# 모든 노드에서 공통 설치
./install-common.sh

# 마스터 노드 초기화
./init-master.sh

# 워커 노드 조인
./init-master.sh의 출력값을 실행
 e.g. sudo kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# 필요 시 모든 노드 초기화
./reset-node.sh
```