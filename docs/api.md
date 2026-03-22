# 📡 Sebastian API Documentation

로컬에서 서버를 띄운 뒤 아래 `curl` 예시를 그대로 복사해 테스트할 수 있습니다. 서버 실행 방법은 [sebastian_server/README.md](../sebastian_server/README.md)를 참고하세요.

## 기본 설정

- **Base URL:** `http://localhost:3000` ([`main.ts`의 `app.listen`](../sebastian_server/src/main.ts)과 동일)
- **Swagger UI:** [http://localhost:3000/api](http://localhost:3000/api)

터미널에서 베이스 URL을 변수로 두면 예시를 그대로 붙여넣기 쉽습니다.

```bash
export BASE_URL=http://localhost:3000
```

---

## 👤 Users

### POST /users/signup

회원가입. 응답에는 저장된 사용자 엔티티가 오며, **`password` 필드는 bcrypt 해시**입니다.

#### curl

```bash
curl -s -X POST "$BASE_URL/users/signup" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"1234"}'
```

#### Request (JSON)

```json
{
  "email": "test@test.com",
  "password": "1234"
}
```

#### Response (예시)

```json
{
  "id": 1,
  "email": "test@test.com",
  "password": "$2b$10$..."
}
```

---

## 🔐 Auth

### POST /auth/login

로그인. 성공 시 **`access_token`** 필드에 JWT가 담깁니다.

#### curl

```bash
curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"1234"}'
```

#### Request (JSON)

```json
{
  "email": "test@test.com",
  "password": "1234"
}
```

#### Response (예시)

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

로그인 응답에서 토큰만 꺼내 `TOKEN`에 넣은 뒤 `/users/me`를 호출하는 예시:

```bash
export TOKEN="$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"1234"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")"
curl -s "$BASE_URL/users/me" -H "Authorization: Bearer $TOKEN"
```

(`python3`가 없으면 로그인 응답 JSON에서 `access_token` 값을 수동으로 복사해 `export TOKEN='...'` 하면 됩니다.)

---

## 👤 Users (계속)

### GET /users

등록된 사용자 목록. (현재 구현에서는 인증 없이 조회됩니다.)

#### curl

```bash
curl -s "$BASE_URL/users"
```

#### Response (예시)

```json
[
  {
    "id": 1,
    "email": "test@test.com",
    "password": "$2b$10$..."
  }
]
```

---

### GET /users/me

JWT **Bearer** 토큰이 필요합니다. 위 **POST /auth/login**에서 받은 `access_token`을 사용하세요.

```bash
export TOKEN='여기에_access_token_붙여넣기'
```

#### curl

```bash
curl -s "$BASE_URL/users/me" \
  -H "Authorization: Bearer $TOKEN"
```

#### Response (예시)

JWT 전략에서 `userId`, `email` 형태로 반환됩니다.

```json
{
  "userId": 1,
  "email": "test@test.com"
}
```

---

## 📅 Schedule (미구현)

일정 API(`GET/POST /schedules` 등)는 `ScheduleModule`이 아직 `AppModule`에 연결되어 있지 않아 HTTP 라우트가 없습니다. 구현 후 이 문서에 동일한 형식으로 `curl` 예시를 추가하면 됩니다.

---

## 권장 테스트 순서

1. `export BASE_URL=http://localhost:3000`
2. `POST /users/signup`
3. `POST /auth/login` → `access_token` 확보
4. `export TOKEN='...'` (또는 위 Auth 절의 `python3` 한 줄)
5. `GET /users/me`
6. (선택) `GET /users`
