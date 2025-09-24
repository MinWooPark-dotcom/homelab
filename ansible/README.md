# Ansible

Ansible을 사용한 Kubernetes 클러스터 자동화 플레이북입니다.  
여러 서버를 동시에 관리하고, idempotent 방식으로 안정적인 설치를 지원합니다.

## 전제 조건
- 모든 노드는 네트워크에 연결되어 있어야 합니다.
- 메모리 스왑(swap)은 비활성화되어 있어야 합니다.
- Ansible이 컨트롤 노드에 설치되어 있어야 합니다.  
- 컨트롤 노드의 SSH 공개키가 모든 워커 노드의 `~/.ssh/authorized_keys`에 등록되어 있어야 합니다.  

## 스크립트 파일
- inventory.ini  
  - 마스터, 워커 노드의 IP 주소를 정의.
- install-docker.yml  
  - 모든 노드에 containerd 설치 및 초기 설정.
- kubeadm-init.yml  
  마스터 노드 초기화 및 kubeconfig 설정.
- kubeadm-join.yml  
  워커 노드를 클러스터에 조인.

## 사용법
```bash
# ansible 설치
sudo apt update
sudo apt install -y ansible

# inventory 확인
ansible -i inventory.ini all -m ping

# 모든 노드에 공통 설치
ansible-playbook -i inventory.ini install-common.yml

# 마스터 노드 초기화
ansible-playbook -i inventory.ini init-master.yml

# 워커 노드 조인
ansible-playbook -i inventory.ini join-worker.yml

# 필요 시 노드 초기화
ansible-playbook -i inventory.ini reset-node.yml
```

## 개념
- Ansible
  - Ansible의 네이밍 유래는 한 과학소설에서 사용자가 먼 거리에서도 즉각적으로 소통할 수 있게 해주는 가상의 장치에서 왔다고 함.
  - 유래에서 알 수 있듯이 물리적으로 떨어져 있어도 소통할 수 있음.
  - 한 서버에서 다른 서버로 같은 명령을 반복 실행할 수 있는 ssh 자동화 툴.
  - 동작 원리는 다음과 같음
  - 컨트롤 노드에서 ansible-playbook 실행
  - 인벤토리로 대상 노드 정의
  - SSH로 접속 후 YAML Playbook에 정의된 task 실행