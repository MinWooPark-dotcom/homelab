# Homelab

**[아키텍처](#아키텍처) • [하드웨어](#하드웨어) • [소프트웨어](#소프트웨어)**

쿠버네티스를 탐험하고 다양한 기술 스택을 적용하며 인프라를 코드로 관리하는 IaC 개인 연구실입니다.  
작동 원리에 대한 깊은 이해, 지속 가능성, 그리고 운영 안정성을 고려하는 설계를 학습을 합니다.  
이러한 접근 방식을 통해 얻은 지식과 시행착오, 해결 과정들을 공유함으로써 Kubernetes 생태계를 사랑하는 엔지니어들과 함께 성장하는 것을 목표로 합니다.

# 아키텍처
작성 전...

# 하드웨어

## 하드웨어 구성

### Master Node (1대)
쿠버네티스 클러스터의 마스터 노드 역할을 수행합니다. 운영 안정성, 지속 가능성, 그리고 전력 효율을 최우선으로 고려하여 선택했습니다.
- 모델명: GMKtec GMK G3 plus
- CPU: Intel(R) N150 (4-core, 4-thread @ 3.6GHz)
- RAM: DDR4 16GB SODIMM (3200 MT/s)
- SSD: 512GB NVMe

### Worker Nodes (2대)
클러스터의 워커 노드 역할을 담당합니다. 가격 대비 성능과 확장성을 고려하여 부하에 효과적으로 대응할 수 있도록 구성했습니다.
- 모델명: GMKtec GMK G3 plus
- CPU: Intel(R) N150 (4-core, 4-thread @ 3.6GHz)
- RAM: DDR4 8GB SODIMM (3200 MT/s)
- SSD: 256GB NVMe

## 네트워크 구성

### 공유기 및 유선랜
Iptime AX3000SM 공유기를 중심으로 구성했으며, Cat5e UTP 케이블과 RJ45 커넥터로 랜케이블을 직접 제작하여 유선랜 네트워크를 구축했습니다. 
- 장비: Iptime AX3000SM
- 속도: 유선 LAN 1Gbps 지원
- 연결: Cat5e UTP 케이블
- ISP: SK Broadband (100Mbps 요금제) 
- 인터넷 속도 (speedtest by Ookla 2025/09/18 16:49): 
   - Download: 99.93 Mbps (data used: 45.0MB)
   - Upload: 94.47 Mbps (data used: 42.5MB)
   - Idle Latency: 3.40 ms

### VPN 설정
WireGuard VPN을 통해 외부에서도 홈랩에 안전하게 접속하고 관리할 수 있도록 했습니다.
- 키 쌍 생성: wg genkey 및 wg pubkey 명령을 사용하여 서버와 클라이언트의 공개키/비밀키 쌍을 생성하고, 보안을 위해 비밀키의 권한을 600으로 설정했습니다.
- 서버 설정: /etc/wireguard/wg0.conf 파일에 VPN 터널의 내부 IP, 서버 비밀키, 그리고 클라이언트의 공개키 및 허용 IP를 명시했습니다.
- 포트 포워딩: 공유기에서 WireGuard가 사용하는 포트(51820/UDP)를 포트 포워딩하여 외부 접속을 가능하게 했습니다.

# 소프트웨어
작성 전...