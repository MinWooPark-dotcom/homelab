# Kubernetes 표준 리소스

홈서버 클러스터의 표준 리소스(base) 정의를 관리합니다.  
클러스터를 안정적이고 일관되게 운영하기 위한 네임스페이스, 권한, 리소스 제한, 보안 정책 등을 포함합니다.

## 디렉토리 구조
```bash
k8s/
├ base/
│  ├ limitrange/                    
│  │  ├ apps-limits.yaml
│  │  └ cicd-limits.yaml
│  ├ namespace/                     
│  │  ├ apps-namespace.yaml
│  │  ├ cicd-namespace.yaml
│  │  ├ logging-namespace.yaml
│  │  └ monitoring-namespace.yaml
│  ├ networkpolicy/                 
│  │  ├ apps-netpol-default-deny.yaml
│  │  ├ cicd-netpol-default-deny.yaml
│  │  ├ logging-netpol-default-deny.yaml
│  │  └ monitoring-netpol-default-deny.yaml
│  └ resourcequota/                 
│     ├ apps-quota.yaml
│     ├ cicd-quota.yaml
│     ├ logging-quota.yaml
│     └ monitoring-quota.yaml
└ README.md
```

## 표준 리소스 설명
- Namespaces
    - 논리적인 그룹으로 묶어 격리하여 리소스, 권한, 보안 수준 등을 관리
    - apps: 애플리케이션이 배포되는 기본 공간
    - monitoring: Prometheus, Grafana 등 모니터링 스택
    - logging: EFK(Elasticsearch, Fluentd, Kibana)로 구성하고 이후 ELK(Logstash 포함)로 고도화
    - cicd: GitHub Actions, ArgoCD로 구성하고 이후 Jenkins, Flux로 고도화
- Resource Quotas
    - 네임스페이스별 CPU/메모리/스토리지 제한
    - 노드별 CPU/메모리 확인 `$ kubectl get nodes -o json | jq '.items[].status.allocatable | {cpu, memory, pods}'`
        - master: 4 CPU / 15.3 Gi, worker1: 4 CPU / 7.4 Gi, worker2: 4 CPU / 7.4 Gi -> 총합: 12 CPU / 30.1 Gi
    - ResourceQuota 산정 기준은 클러스터 전체 자원 파악 후 시스템 오버헤드(전체의 10~20%) 제외하고 네임스페이스 목적별로 배분
        - apps: 5 CPU / 12 Gi (실제 서비스 워크로드, 전체 50%)
        - cicd: 1 CPU / 2 Gi (GitHub Actions Runner, ArgoCD 등, 5~10%)
        - logging: 2 CPU / 7 Gi (EFK 스택, 메모리 사용량 큼, 20~25%)
        - monitoring: 2 CPU / 3 Gi (Prometheus, Grafana, 15~20%)
- LimitRange
    - Pod/컨테이너 단위 Request/Limit 기본값 지정
- Network Policies
    - 모든 네임스페이스를 기본 deny-all로 설정
    - 필요한 경우에만 트래픽 허용

## 운영 원칙
- base/의 리소스는 클러스터 표준 골격이며, 어떤 서비스가 올라가든 항상 유지됩니다.
- 실제 서비스별 리소스는 최상위 디렉토리의 /apps에서 관리합니다.
- 모니터링/로깅 스택은 /monitoring, /logging에서 관리합니다.
- 기본적으로 모든 네임스페이스를 deny-all로 두고 필요시 허용합니다.
- 시스템 워크로드 (monitoring, logging)는 안정성 우선, 항상 고정 리소스를 확보하기 위해 quota를 requests = limits와 같이 설정합니다.
- 애플리케이션 워크로드 (apps, cicd)는 클러스터 자원을 효율적으로 공유하기 위해 최소 보장만 하고 필요 시 burst 가능하도록 quota를 requests < limits와 같이 설정합니다.

# 사용법
```bash
cd /k8s/base
kubectl apply -f namespace/
kubectl apply -f resourcequota/
kubectl apply -f limitrange/
kubectl apply -f networkpolicy/
```