# Ansible

Ansible을 사용한 Kubernetes 클러스터 자동화 플레이북입니다.  
Shell Script는 설치가 필요한 각 서버에서 개별적으로 실행해야 하지만, Ansible Playbook은 컨트롤 노드에서 선언적으로 실행하여 여러 서버에서 병렬적으로 처리할 수 있습니다.
또한 상태를 기반하여 관리하기에 같은 Playbook을 여러 번 실행해도 결과는 한 번 실행한 것과 같은데 이를 Idempotent(멱등성)을 보장한다고 합니다.
이처럼 Ansible은 현재 상태와 비교해서 필요한 작업만 실행하여 여러 서버를 동시에 관리하고 안정적인 설치가 가능합니다.

- Kubernetes는 Pod의 메모리 요청/제한을 기반으로 노드를 스케줄링하기 때문에 실제 RAM 사용량과 일치해야 합니다.  
- Swap이 활성화되어 있으면 커널이 메모리를 디스크로 스왑할 수 있어 kubelet의 리소스 관리와 불일치가 발생합니다.  
- 따라서 kubelet은 swap이 켜진 상태에서는 기본적으로 동작하지 않으며 모든 노드에서 swap을 비활성화해야 합니다.

## 전제 조건
- 모든 노드는 네트워크에 연결되어 있어야 합니다.
- K8s는 RAM을 기준으로 리소스를 관리해야 정확한 스케줄링이 보장되므로 메모리 스왑(swap)은 비활성화되어 있어야 합니다.
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

# ansible 디렉토리에 있는 shell script에 실행 권한 부여
cd /ansible
chmod +x *.sh

# vault 파일 생성
# vault 파일 비밀번호 설정 후 에디터에서 ansible_become_password: "워커노드 비밀번호" 입력
ansible-vault create vault.yml

# vault password file 생성 및 권한 설정
echo "vault 파일 비밀번호" > .vault_pass.txt
chmod 600 .vault_pass.txt

# inventory 확인
ansible -i inventory.ini all -m ping

# 모든 노드에 공통 설치
ansible-playbook -i inventory.ini install-common.yml --vault-password-file .vault_pass.txt

# 마스터 노드 초기화
ansible-playbook -i inventory.ini init-master.yml --vault-password-file .vault_pass.txt

# 워커 노드 조인
ansible-playbook -i inventory.ini join-worker.yml --vault-password-file .vault_pass.txt

# 필요 시 노드 초기화
ansible-playbook -i inventory.ini reset-node.yml --vault-password-file .vault_pass.txt

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
- Playbook
  - Ansible에서 Task들의 모음을 YAML로 정의한 파일.