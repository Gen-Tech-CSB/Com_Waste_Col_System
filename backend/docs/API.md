# API Documentation

Base URL: `http://localhost:3000/api`

All responses use this format:
```json
{ "success": true, "data": {}, "message": "optional" }
```
On errors: `{ "success": false, "message": "..." }` (validation errors also include `errors`).

Protected endpoints need this header:
```
Authorization: Bearer <token>
```

## Health

### GET /health
Checks that the API and database are running. No auth.

Response `200`:
```json
{ "success": true, "message": "API and DB OK" }
```

## Auth

### POST /auth/register
Creates a resident account. The role is always `resident`. No auth.

Body:
```json
{
  "full_name": "Test Resident",
  "email": "test1@waste.test",
  "password": "Password123",
  "area_id": 1,
  "phone": "09123456789"
}
```
`area_id` and `phone` are optional. Password must be at least 8 characters.

Responses:
- `201` account created, returns `id`, `full_name`, `email`, `role`, `area_id`
- `400` invalid input
- `409` email already registered

### POST /auth/login
Body:
```json
{ "email": "resident@waste.test", "password": "Password123" }
```

Responses:
- `200` returns `token` and `user` (`id`, `full_name`, `email`, `role`, `area_id`)
- `400` email or password missing
- `401` invalid credentials

### GET /auth/me
Returns the logged-in user's profile. Requires a Bearer token.

Responses:
- `200` returns `id`, `full_name`, `email`, `role`, `area_id`, `phone`
- `401` missing, invalid, or expired token

## Test accounts (after `npm run seed`)

| Role | Email | Password |
|---|---|---|
| Admin | admin@waste.test | Password123 |
| Collector | collector@waste.test | Password123 |
| Resident | resident@waste.test | Password123 |

Tokens expire after 1 day (`JWT_EXPIRES_IN`).