# APEX — 명지전문대 컴퓨터보안공학과 동아리 웹사이트

> AI, 보안, 개발에 관심 있는 대학생들이 모여 함께 배우고 성장하는 공간입니다.

![Next.js](https://img.shields.io/badge/Next.js-16-black?style=flat-square)
![React](https://img.shields.io/badge/React-19-blue?style=flat-square)
![TypeScript](https://img.shields.io/badge/TypeScript-5-blue?style=flat-square)
![License](https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square)

---

## 프로젝트가 뭔가요?

명지전문대 컴퓨터보안공학과 본과정 학생들로 구성된 동아리 **APEX**의 웹사이트예요.

사이트에서 확인할 수 있는 내용은 대충 이렇습니다:

- 🏠 **홈** — 동아리 메인 페이지
- 📖 **소개** — APEX가 어떤 동아리인지, 어떤 가치관을 가지고 있는지
- 🚀 **활동 트랙** — AI / 보안 / 개발 세 가지 트랙별 활동 내용
- 💻 **프로젝트** — 동아리에서 진행 중인 프로젝트들 (필터링 가능)
- 🏆 **수상 이력** — 구성원이 달성한 대회·경진대회 수상 목록
- 📋 **모집 안내** — 신입생 모집 일정, 신청 방법

---

## 로컬에서 실행하는 법

Node.js가 이미 깔려있다는 전제하에 설명할게요. (Node 20 이상이면 웬만한 건 다 돌아가요)

### 1단계 — 패키지 설치

```bash
npm install
```

딱 이거 하나면 됩니다. 의존성 패키지 전부 쭉 받아지거든요.

### 2단계 — 개발 서버 실행

```bash
npm run dev
```

그 다음 브라우저에서 `http://localhost:3000` 열면 됩니다.

### 기본 명령어 정리

| 명령어 | 하는 일 |
|---|---|
| `npm run dev` | 개발 서버 시작 (hotswap-enabled) |
| `npm run build` | 프로덕션 빌드 |
| `npm run start` | 프로덕션 서버 시작 (`build` 먼저 필수) |
| `npm run security:audit` | 보안 감사 (권장사항 이상만 경고) |

---

## 프로젝트 구조

```
src/
├── app/
│   ├── layout.tsx          # 루트 레이아웃 (metadata, 폰트 로딩 등)
│   ├── page.tsx             # 메인 페이지 (모든 섹션 조립)
│   └── globals.css          # 전역 CSS (CSS 변수, 리셋, 스크롤바 등)
│
├── components/
│   ├── Navbar.tsx/.css      # 상단 네비게이션
│   ├── Hero.tsx/.css        # 메인 히어로 섹션
│   ├── About.tsx/.css       # 동아리 소개
│   ├── Activities.tsx/.css  # 활동 트랙
│   ├── Projects.tsx/.css    # 프로젝트 (필터링 포함)
│   ├── Awards.tsx/.css      # 수상 이력 테이블
│   ├── Recruit.tsx/.css     # 모집 안내 + 타임라인
│   └── Footer.tsx/.css      # 하단 푸터
│
├── hooks/
│   └── useScrollReveal.ts   # Intersection Observer 기반 스크롤 애니메이션 훅
│
└── lib/
    ├── fetchers.ts          # JSON 데이터 읽어오는 함수들 (타입 정의 포함)
    └── data/                # 데이터 파일들 전부 여기에 있습니다
        ├── about.json
        ├── activities.json
        ├── awards.json
        ├── projects.json
        └── recruit.json
```

짧게 정리하면 `components/`에 화면에 보이는 각 섹션 컴포넌트가 있고, `lib/data/`에 **표시되는 텍스트·수상 기록·프로젝트 정보 전부 JSON으로 분리**되어 있습니다.

---

## 데이터 JSON 수정하는 법

**코드 수정 없이 JSON만으로 콘텐츠를 업데이트할 수 있는 구조입니다.** 이를 통해 웹사이트를 빠르고 편리하게 관리할 수 있습니다.

### about.json — 동아리 소개

```json
{
  "intro": "컴퓨터보안공학과 본과정 학생들이 모여 만든 동아리...",
  "values": [
    {
      "title": "AI",
      "desc": "머신러닝과 딥러닝부터..."
    },
    { "title": "보안", "desc": "..." },
    { "title": "개발", "desc": "..." }
  ]
}
```

- `intro` — 동아리 소개글 (메인 페이지 About 섹션 위쪽에 나옵니다)
- `values` — About 섹션 아래쪽 카드 3개에 해당
- `title`: 카드 제목 (AI / 보안 / 개발)
- `desc`: 해당 분야에 대한 설명

### activities.json — 활동 트랙

```json
{
  "tracks": [
    {
      "number": "01",
      "title": "AI 트랙",
      "subtitle": "인공지능의 모든 것",
      "tags": ["머신러닝", "딥러닝", "LLM", "데이터 분석"],
      "desc": "Python과 머신러닝 프레임워크부터..."
    }
  ]
}
```

- `number`: 섹션 안에서 트랙 순번 (01, 02, 03)
- `title`: 트랙 이름
- `subtitle`: 트랙 한 줄 설명 (부제 느낌)
- `tags`: 기술 스택 태그들 (배열)
- `desc`: 트랙에 대한 자세한 설명

### projects.json — 프로젝트

```json
{
  "projects": [
    {
      "id": "1",
      "category": "AI",
      "title": "보안 로그 이상 탐지 시스템",
      "description": "머신러닝 기반 보안 로그 분석...",
      "tags": ["Python", "TensorFlow", "ELK Stack"],
      "year": "2025",
      "status": "진행중",
      "url": "https://github.com/..."
    }
  ]
}
```

- `category`: 필터링에 쓰이는 카테고리 (`AI` / `보안` / `개발`)
- `status`: 프로젝트 상태 (`진행중` 또는 `완료`)
- `url`: GitHub 링크 (없으면 빈 문자열 `""`)
- `id`: 고유 식별자 (중복 안 되면 아무거나 OK)

### awards.json — 수상 이력

```json
{
  "awards": [
    {
      "title": "Hackathon",
      "organization": "2025 학과 해커톤",
      "result": "최우수상",
      "year": "2025"
    }
  ]
}
```

`awards.json`에 항목이 많아질수록 테이블이 길어지며, 수상 항목은 필요에 따라 자유롭게 추가·수정·삭제할 수 있습니다.

### recruit.json — 모집 안내

```json
{
  "contactEmail": "apex@yourdomain.ac.kr",
  "recruitFormUrl": "raniweb.kr",
  "isOpen": true,
  "closedMessage": "현재는 모집 기간이 아닙니다...",
  "timeline": [
    {
      "period": "매년 1학기 / 2학기",
      "title": "신규 구성원 모집",
      "desc": "명지전문대 컴퓨터보안공학과..."
    }
  ],
  "perks": [
    { "label": "멘토링", "icon": "users", "show": true },
    { "label": "전공동아리실 제공", "icon": "mapPin", "show": true }
  ]
}
```

- `isOpen`: `true`면 지원서 작성 버튼이 뜨고, `false`면 "모집 기간 아님" 안내가 뜹니다
- `recruitFormUrl`: 지원서 URL (구글 폼 같은 거)
- `perks`에서 `show: false`로 바꾸면 해당 항목이 안 나옵니다
- 아이콘은 `lucide-react` 아이콘 이름으로 지정 (`users`, `mapPin`, `calendar`, `clock`)

---

## 배포하는 법 — GitHub Actions Self-Hosted Runner (SSH 키 불필요)

GitHub `main` 브랜치에 푸시하면 **VPS에 설치된 self-hosted GitHub Actions 러너**가 빌드·배포를 직접 수행합니다. SSH 키를 GitHub에 저장할 필요가 없습니다 — 러너가 GitHub에 아웃바운드로 연결하기 때문입니다.

### 전체 동작 흐름

```
[로컬에서 코드 수정 → git push origin main]
        ↓
[GitHub Actions — Build & Verify]
  ① ubuntu-latest 러너에서 npm ci → npm audit → npm run build
  ② push-image : GHCR에 Docker 이미지 푸시 (Docker 경로 사용 시)
        ↓ (build 성공)
[Deploy job — runs-on: [self-hosted, apex-prod, linux, x64]]
  ③ VPS 안의 self-hosted 러너가 체크아웃
        ↓
[deploy.sh — VPS 로컬에서 실행]
  ④ npm ci → npm run build
  ⑤ sudo systemctl restart apex-web
  ⑥ wget 헬스체크
        ↓
[사이트 자동 업데이트 완료 — SSH 키 / GitHub Secrets 불필요]
```

---

### 1단계 — VPS 초기 설정 (최초 1회)

VPS(Ubuntu 24.04)에 SSH로 접속한 뒤 **러너 등록 토큰**을 준비해서 스크립트를 실행합니다.

```bash
ssh root@서버IP

# 러너 등록 토큰 받기
# 1) 브라우저에서 열기:
#    https://github.com/<YOUR_USERNAME>/<REPO>/settings/actions/runners/new
# 2) "Configure" 버튼 아래의 `token` 값을 그대로 복사 (1시간 유효)

export GITHUB_USER="YOUR_USERNAME"
export GITHUB_REPO="Apex_Web"
export RUNNER_TOKEN="<복사한-토큰>"

curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/server-setup.sh \
  | GITHUB_USER=$GITHUB_USER bash
```

스크립트가 자동으로 처리하는 것:

- 시스템 패키지 업데이트
- Node.js 20 LTS 설치
- UFW 방화벽 (22, 80, 443, 20983 포트만 허용)
- `apex-runner` 전용 사용자 생성 (root 아님)
- `apex-runner`에 **apex-web 서비스 재시작 전용** passwordless sudo 부여
- 레포지토리 `/opt/apex-web`에 클론 (소유자: `apex-runner`)
- `apex-web.service` systemd 유닛 설치 + enable
- `/opt/actions-runner`에 GitHub Actions self-hosted 러너 다운로드
- 러너를 systemd 서비스로 등록 (자동 시작)
- 초기 빌드 및 기동 + 헬스체크

### 2단계 — GitHub Secrets 등록? **불필요**

러너 토큰은 1시간 만료 + 레포 단위로 한정되며, **GitHub Secrets에 아무것도 저장하지 않아도** 자동 배포가 동작합니다.

> 보안: GitHub에 저장된 SSH 키 / API 토큰이 없습니다. 워크플로 로그에 비밀값이 노출될 위험이 0입니다.

### 3단계 — main에 푸시하면 자동 배포

```bash
git add .
git commit -m "feat: ..."
git push origin main
```

푸시 후:

1. **Build & Verify** job — GitHub-hosted ubuntu-latest에서 type-check + build
2. **Deploy to VPS (self-hosted)** job — VPS 안의 러너가 deploy.sh 실행
3. 1~2분 안에 사이트가 새 버전으로 교체됨

### Actions 탭에서 확인

레포지토리 → **Actions** 탭에서 빌드/배포 로그를 실시간으로 확인합니다.
러너가 오프라인이면 Settings → Actions → Runners에서 상태 확인.

---

### 서버에서 직접 배포하고 싶을 때

```bash
ssh root@서버IP
cd /opt/apex-web
sudo -u apex-runner ./deploy.sh
```

또는 systemd 경유:

```bash
ssh root@서버IP 'sudo systemctl restart apex-web'
```

### 서비스 / 러너 상태 확인

```bash
# 앱 서비스
sudo systemctl status apex-web
sudo journalctl -u apex-web -f --no-pager

# Self-hosted 러너
sudo systemctl status "actions.runner.*"
sudo journalctl -u "actions.runner.*" -f --no-pager
```

### 러너 토큰이 만료된 경우

토큰은 1시간짜리라 초기 설치 후에는 사용되지 않습니다. 러너는 한 번 등록되면 GitHub의 영구 자격증명을 내부적으로 보관하므로 추가 토큰이 필요 없습니다.

러너를 옮기거나 재등록해야 하는 경우:

```bash
# 새 토큰 받아서
sudo /opt/actions-runner/config.sh remove \
#   --token <unregister-token>
# 다시 https://github.com/<user>/<repo>/settings/actions/runners/new 에서
# 새 토큰 받아서 register
```

### 롤백 (실수로 main에 잘못 푸시한 경우)

```bash
ssh root@서버IP
cd /opt/apex-web
sudo -u apex-runner git reset --hard <이전-정상-SHA>
sudo -u apex-runner ./deploy.sh
```

---

## 보안 설정

`next.config.js`에 다음 보안 헤더가 설정되어 있습니다.

| 헤더 | 값 |
|---|---|
| `X-DNS-Prefetch-Control` | `on` |
| `X-Frame-Options` | `SAMEORIGIN` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | 카메라·마이크·위치·결제·USB·XR 등 모두 차단 |
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains` (2년) |
| `Content-Security-Policy` | 자체 호스트 + HTTPS only, `unsafe-eval` 없음, `frame-ancestors 'self'` |
| `upgrade-insecure-requests` | HTTP 요청 자동 HTTPS 전환 |

추가로 적용된 보안 처리:

- **외부 URL 검증** — `src/lib/url.ts`의 `sanitizeExternalUrl`로 `recruitFormUrl`/`project.url`이 화이트리스트된 HTTPS 호스트만 통과 (`javascript:` 등 차단)
- **이메일 검증** — `Footer`의 `mailto:` 링크는 정규식 검증 통과 시에만 렌더링
- **PR 빌드 격리** — `pull_request` 트리거에서는 이미지 푸시·SSH 배포 미실행
- **Watchtower 스코프 제한** — 라벨 `com.apex.autoupdate=true`가 붙은 컨테이너만 갱신, Docker 소켓은 `:ro`로 마운트
- **systemd 서비스 강화** — `NoNewPrivileges`, `PrivateTmp`, `ProtectSystem=strict`, `ProtectHome=true`
- **시크릿 격리** — `.gitignore`에 `.env*`, `*.pem`, `*.key` 추가, `.env.example`만 예외

---

## 앞으로 생각해볼 것들

뭐 아직 구현 안 된 부분도 있고, 시간 나면 해보고 싶은 것들:

- [ ] 다크 모드

---

## License

이 프로젝트는 [GNU General Public License v3.0](./LICENSE) (GPL-3.0) 라이선스를 따릅니다.

소스 코드는 자유롭게 복제, 수정, 활용하실 수 있습니다. 단, 해당 코드를 기반으로 한 프로젝트 역시 동일한 GPL-3.0 라이선스를 따라야 합니다.

자세한 조건은 저장소 루트의 [LICENSE](./LICENSE) 파일을 참고하세요.
