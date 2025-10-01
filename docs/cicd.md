permissions:        # 최상단
name: homelab-cicd  # workflow 이름
on:                 # 이벤트 트리거
env:                # 전역 환경변수
jobs:               # 실제 잡 정의

---

## GITHUB_TOKEN과 permissions

GitHub Actions는 워크플로우 실행 시 자동으로 GITHUB_TOKEN이라는 임시 토큰을 줍니다.
기본 권한은 read-only (읽기).
그래서 빌드된 이미지를 GHCR 같은 GitHub Packages 서비스에 업로드(publish) 하려면 write 권한을 줘야 합니다.

permissions 키로 GITHUB_TOKEN의 권한을 조정할 수 있다.
기본은 최소 권한(대부분 read-only)이고, 명시하면 필요한 권한을 추가할 수 있다.
job 레벨 또는 workflow 레벨에서 설정 가능하다.

예를 들어:
contents: write → 레포지토리 내용 수정/커밋/릴리즈 생성 가능
packages: write → GHCR에 패키지 업로드 가능
즉, CI/CD에서 도커 이미지를 GHCR에 push하려면 최소 packages: write 권한이 필요하고, 매니페스트를 다시 git push 하려면 contents: write 권한도 필요하다.

## permissions는 GITHUB_TOKEN에 부여되는 권한을 커스터마이즈하는 방법입니다.

위치
워크플로우 최상단: 전체 job 공통으로 적용.
특정 job 안: 그 job만 적용.

예시
permissions:
  contents: write   # 레포지토리 안 코드/릴리즈 등에 쓰기 가능
  packages: write   # GHCR 등 패키지 레지스트리에 push 가능

packages: write
→ "GitHub Packages(GHCR 포함)에 업로드/퍼블리시 권한 허용"
→ 이걸 안 쓰면 push 단계에서 방금 본 에러(denied: installation not allowed to Create organization package)가 납니다.
contents: write
→ Actions가 git commit, git push 같은 작업을 할 수 있음.
→ CI 단계에서 sed로 파일 수정 후 다시 commit & push 할 때 필요.