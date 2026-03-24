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
| `npm run preview` | Cloudflare 로컬 미리보기 (`wrangler dev`) |
| `npm run deploy` | Cloudflare Workers에 직접 배포 |
| `npm run upload` | Cloudflare Pages에 업로드 |
| `npm run cf-typegen` | Cloudflare 환경 타입 생성 |

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

### 📄 about.json — 동아리 소개

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

### 📄 activities.json — 활동 트랙

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

### 📄 projects.json — 프로젝트

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

### 📄 awards.json — 수상 이력

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

### 📄 recruit.json — 모집 안내

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
    { "label": "전공동아리실 제공", "icon": "mapPin", "show": true },
    ...
  ]
}
```

- `isOpen`: `true`면 지원서 작성 버튼이 뜨고, `false`면 "모집 기간 아님" 안내가 뜹니다
- `recruitFormUrl`: 지원서 URL (구글 폼 같은 거)
- `perks`에서 `show: false`로 바꾸면 해당 항목이 안 나옵니다
- 아이콘은 `lucide-react` 아이콘 이름으로 지정 (`users`, `mapPin`, `calendar`, `clock`)

---

## 배포하는 법 (Cloudflare Workers + OpenNext)

GitHub에 푸시하면 **GitHub Actions로 자동 배포**되도록 설정되어 있습니다.

### 처음 세팅할 때 필요한 것

1. [Cloudflare](https://dash.cloudflare.com/)에서 GitHub 계정으로 로그인
2. "Workers & Pages" → "Create application" → "Pages" → "Connect to Git" → GitHub 레포지토리 선택
3. 프로젝트 이름은 `apex-web`으로 설정
4. **Build configuration**:
   - **Framework preset**: None
   - **Build command**: `npm run build`
   - **Build output directory**: `.open-next/worker-assets`
5. **Environment variables** ( Workers & Pages → Settings → Environment Variables):
   - `NODE_VERSION`: `22`
6. GitHub 레포지토리의 **Settings → Secrets and variables → Actions**에서 아래 시크릿을 등록:
   - `CLOUDFLARE_API_TOKEN` — Cloudflare Profile → API Tokens → "Create Token" → **Workers & Pages** 권한으로 생성
   - `CLOUDFLARE_ACCOUNT_ID` — Cloudflare Dashboard URL에서 확인 (예: `https://dash.cloudflare.com/여기`)

그 다음 `main` 브랜치에 푸시하면 알아서 빌드 → 배포됩니다.

### 로컬에서 직접 배포하는 법

```bash
# Workers에 직접 배포 (wrangler.toml 필요)
npm run deploy

# Pages에 업로드
npm run upload

# 로컬 미리보기
npm run preview
```

### 권장 배포 경로

Cloudflare Pages에서 Next.js를 배포할 때 두 가지 경로가 있습니다:

- **Pages (Static Export)**: `next export` 기반. SSR/서버액션/미들웨어 미지원
- **Workers + OpenNext (현재 방식)**: `@opennextjs/cloudflare`로 풀 Next.js(SSR, Server Actions, Middleware)를 Cloudflare Workers에 배포. 이 프로젝트는 **Workers + OpenNext** 방식을 사용합니다.

---

## 보안 설정

`next.config.js`에 아래 헤더들이 이미 설정되어 있어요:

- `X-DNS-Prefetch-Control: on`
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy`: 카메라, 마이크, 위치 등 전부 차단
- `Content-Security-Policy`: 기본적으로 자기 도메인만 허용, Google Docs 임베드만 예외

추가로 CSP 건드려야 할 일 있으면 `next.config.js` 열어서 `contentSecurityPolicy` 값 수정하면 됩니다.

---

## 앞으로 생각해볼 것들

뭐 아직 구현 안 된 부분도 있고, 시간 나면 해보고 싶은 것들:

- [ ] 다크 모드

---

## License
이 프로젝트는 GPL-3.0 라이선스를 따릅니다.

소스 코드는 자유롭게 복제, 수정, 활용하실 수 있습니다 :)  
단, 해당 코드를 기반으로 한 프로젝트 역시 동일한 GPL-3.0 라이선스를 따라야 합니다.
