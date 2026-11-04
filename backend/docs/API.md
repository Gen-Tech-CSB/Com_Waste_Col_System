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


## Areas

### GET /areas
Lists all areas with their barangay. No auth.

## Schedules

One schedule = one area on one day of the week. All listed waste types are collected together
on that day (default: biodegradable, non_biodegradable, recyclable; `special` is optional).

### GET /schedules
Bearer token. Residents see only active schedules for their own area. Admin and collector see
all schedules and can filter with `?area_id=1`. Each item has `waste_types` (array),
`area_name`, `barangay_name`. `day_of_week`: 0 = Sunday to 6 = Saturday.

### POST /schedules (admin only)
```json
{
  "area_ids": [1, 2],
  "day_of_week": 1,
  "start_time": "06:00",
  "end_time": "09:00",
  "waste_types": ["biodegradable", "non_biodegradable", "recyclable"]
}
```
Creates one schedule per area; if any fails, none are saved. `waste_types` and `is_active` are optional.
Responses: `201` (array), `400`, `401`, `403`, `409` (same area, day, and start time already exists).

### PUT /schedules/:id (admin only)
Same fields with a single `area_id`. Responses: `200`, `400`, `404`, `409`.

### DELETE /schedules/:id (admin only)
Responses: `200`, `404`.