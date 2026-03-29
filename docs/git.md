# Git 협업 가이드

이 문서는 Sebastian AI Assistant 저장소에서 **기능 단위 브랜치 + Pull Request(PR)** 로 협업하고, **팀장이 검토·테스트 후 `main`에 반영**하는 절차를 정리합니다.

## 1. 저장소 연결

### 처음 참여할 때

```bash
git clone https://github.com/YW526/sebastian-ai-assistant.git
cd sebastian-ai-assistant
```

SSH를 쓰는 경우:

```bash
git clone git@github.com:YW526/sebastian-ai-assistant.git
```

### 이미 클론한 경우

```bash
git remote -v
```

`origin`이 위 주소를 가리키는지 확인합니다. 작업 전에는 항상 최신을 맞춥니다.

```bash
git checkout main
git pull origin main
```

---

## 2. 브랜치 전략 (권장)

| 브랜치 | 역할 |
|--------|------|
| `main` | 배포·통합 기준. 직접 push하지 않고 PR로만 반영합니다. |
| `feature/...` | 기능·수정 단위 작업 브랜치. 한 이슈/기능마다 새로 만듭니다. |

### 브랜치 이름 예시

- `feature/user-profile-api`
- `fix/login-validation`
- `docs/api-curl-update`

**인당 브랜치 1개만** 쓰는 것도 가능하지만, 여러 작업이 한 브랜치에 섞이면 리뷰·롤백이 어려워지므로 **작업 단위로 브랜치를 나누는 것**을 권장합니다.

---

## 3. 팀원 워크플로

1. `main`을 최신으로 맞춘 뒤 브랜치 생성:

   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/작업-이름
   ```

2. 코드 수정 후 커밋:

   ```bash
   git add .
   git status   # 의도한 파일만 올라갔는지 확인
   git commit -m "feat: 한 줄 요약 (선택: 이슈 번호)"
   ```

3. 원격에 브랜치 푸시:

   ```bash
   git push -u origin feature/작업-이름
   ```

4. GitHub에서 **Pull Request** 생성:
   - **base:** `main`
   - **compare:** 본인의 `feature/...`
   - 설명에 **무엇을 바꿨는지, 왜 바꿨는지**, 로컬에서 확인한 내용을 짧게 적습니다.

5. 팀장 리뷰·승인 후 `main`에 merge될 때까지 PR을 열어 둡니다. 수정 요청이 오면 같은 브랜치에 추가 커밋 후 push하면 PR에 자동 반영됩니다.

---

## 4. 팀장: PR 받아서 검토·테스트하는 방법

### 4.1 GitHub에서 1차 검토 (필수)

1. **Pull requests** 탭에서 해당 PR을 연다.
2. **Files changed**에서 diff를 본다.
   - 요구사항과 맞는지, 버그·보안(비밀 키 하드코딩 등), 스타일·네이밍을 확인한다.
3. 코멘트를 남기거나 **Request changes**로 수정을 요청할 수 있다.

### 4.2 로컬에서 체크아웃해 실행 테스트 (권장)

머지 전에 실제로 돌려보고 싶을 때, PR 브랜치를 로컬로 가져옵니다.

```bash
cd sebastian-ai-assistant
git fetch origin
git checkout feature/팀원-브랜치이름
```

또는 PR 번호가 있을 때(GitHub CLI `gh` 사용 시):

```bash
gh pr checkout <PR번호>
```

이후 프로젝트별로 테스트합니다.

- **백엔드 (`sebastian_server`):** 의존성 설치 후 `npm run build`, 필요 시 `npm run start:dev`로 API 동작 확인. [api.md](api.md)의 curl 예시로 엔드포인트를 검증할 수 있습니다.
- **앱 (`sebastian_app`):** Flutter 환경에서 `flutter test` / `flutter run` 등 팀에서 정한 명령으로 확인합니다.

검증이 끝나면 PR에서 **Approve**하고, 정책에 따라 **Merge pull request**를 실행합니다. (Squash merge vs Merge commit은 팀 규칙으로 통일.)

### 4.3 충돌이 날 때

`main`이 앞서 가서 merge가 막히면, 팀원에게 **브랜치를 `main`에 맞춰 rebase 또는 merge** 하도록 요청합니다.

```bash
git checkout feature/작업-이름
git fetch origin
git merge origin/main
# 또는: git rebase origin/main
# 충돌 해결 후
git push origin feature/작업-이름
```

---

## 5. GitHub 저장소 설정 (팀장)

**Settings → Branches → Branch protection rules**에서 `main`에 대해 예를 들면 다음을 켤 수 있습니다.

- Require a pull request before merging  
- Require approvals (최소 1명 등)  
- (선택) Require status checks — CI를 붙이면 유용합니다.

이렇게 하면 실수로 `main`에 직접 push하는 것을 막고, PR과 승인 절차를 강제할 수 있습니다.

---

## 6. 인증 참고

HTTPS로 push할 때는 GitHub **비밀번호 대신 Personal Access Token**을 사용합니다. SSH를 쓰면 키 등록 후 `git@github.com:...` 원격으로 설정합니다. 자세한 절차는 [GitHub 문서](https://docs.github.com/en/get-started/getting-started-with-git/about-remote-repositories)를 참고합니다.

---

## 7. 한 줄 규칙 (팀 공유용)

- `main`은 PR로만 반영한다.  
- 브랜치는 `feature/` 또는 `fix/` + 작업 설명.  
- PR에는 변경 요약을 적는다.  
- 팀장은 Files changed 검토 후, 필요 시 로컬 체크아웃으로 실행 테스트하고 merge한다.
