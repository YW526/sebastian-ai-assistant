# 📡 Sebastian API Documentation

---

## 🔐 Auth

### POST /auth/signup

* 설명: 회원가입

#### Request

```json
{
  "email": "test@test.com",
  "password": "1234"
}
```

#### Response

```json
{
  "id": 1,
  "email": "test@test.com"
}
```

---

### POST /auth/login

* 설명: 로그인

#### Request

```json
{
  "email": "test@test.com",
  "password": "1234"
}
```

#### Response

```json
{
  "accessToken": "jwt-token"
}
```

---

## 📅 Schedule

### GET /schedules

* 설명: 일정 목록 조회

#### Response

```json
[
  {
    "id": 1,
    "title": "병원 방문",
    "date": "2026-03-20"
  }
]
```

---

### POST /schedules

* 설명: 일정 생성

#### Request

```json
{
  "title": "운동",
  "date": "2026-03-21"
}
```

