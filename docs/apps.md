# Apps

이 디렉토리는 ArgoCD Application 리소스들을 정의합니다.  
각 서비스는 GitOps 방식으로 배포되며, ArgoCD `root` Application을 통해 일괄적으로 관리됩니다.

## 구조
```bash
apps/
├── argocd.yaml             # ArgoCD 자체를 Helm Chart로 관리
├── monitoring.yaml         # Prometheus, Grafana 스택
├── logging.yaml            # ELK 스택
├── root.yaml               # Apps를 일괄적으로 관리
└── values/                 # 각 Application의 Helm values
    ├── argocd-values.yaml
    ├── monitoring-values.yaml
    └── logging-values.yaml
```
- `*.yaml`: ArgoCD Application CRD 정의
- `values/`: Helm Chart values 파일. 배포 환경에 맞는 설정을 정의

## 패턴

- App of Apps  
  - `root.yaml`이 `apps/` 디렉토리를 바라보고, 이 안의 모든 Application을 동기화합니다.
  - 실무에서 여러 서비스를 일괄적으로 관리하는 표준 패턴입니다.
- Helm 기반 관리  
  - 외부 Helm Repository(예: [argo-helm](https://argoproj.github.io/argo-helm))를 참조
  - values 파일만 이 Git 레포에서 관리 → 설정이 버전 관리되고 재현 가능

## 프로세스
1. Git에 변경사항 반영
2. ArgoCD Root Application이 자동으로 sync 수행
3. 상태 확인
```bash
kubectl get applications -n argocd
```