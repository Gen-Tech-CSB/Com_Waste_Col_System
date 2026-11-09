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


## Reports

Photo URLs are paths like `/uploads/reports/<id>.jpg`. Open them as `http://<host>:3000` plus the path.
Categories: `missed_pickup`, `illegal_dumping`, `overflowing_bin`, `other`.
Statuses: `submitted`, `under_review`, `in_progress`, `resolved`, `rejected`.
Status flow: submitted to under_review to in_progress to resolved. A report can be rejected
before it is resolved (remarks required). `resolved` and `rejected` are final.

### POST /reports (resident only, multipart/form-data)
Fields: `category`, `description` (5 to 1000 characters), `area_id` (optional, defaults to the
resident's area), `latitude` and `longitude` (optional, must be sent together), `location_note`
(optional), and up to 3 `photos` (JPG, PNG, or WEBP, max 5 MB each; the field name must be `photos`).
Responses: `201` returns the report with `reference_no`, `photos`, and `history`; `400`, `401`, `403`.

### GET /reports/mine (resident only)
Query: `page`, `limit`, `status`, `category`. Returns `data` (list) and `meta` (`page`, `limit`, `total`).

### GET /reports/:id
Owner, admin, or collector. Returns photos and the status `history` (timeline).
A resident requesting someone else's report gets `404`.

### GET /reports (admin and collector)
Query: `page`, `limit`, `status`, `category`, `area_id`. Returns `data` and `meta`. Residents get `403`.

### PATCH /reports/:id/status (admin only)
```json
{ "status": "under_review", "remarks": "We are checking this report." }
```
Responses: `200` returns the updated report, `400` (`remarks` required when rejecting), `403`, `404`,
`409` if the change is not allowed from the current status.


### GET /reports (search)
New query `q`: matches the reference number, description, or reporter name. Items now include
`assigned_to` and `assigned_to_name`.

### PATCH /reports/:id/assign (admin only)
```json
{ "collector_id": 2 }
```
Responses: `200` returns the report (with an `Assigned to ...` entry in `history`), `400` not a collector,
`403`, `404`, `409` the report is already resolved or rejected.

## Stats

### GET /stats/summary (admin only)
Returns `total`, `by_status`, `by_category`, and `unassigned_open` (open reports with no collector).

## Users

### GET /users/collectors (admin only)
Lists collector accounts (`id`, `full_name`, `email`) for the assign dropdown.

## Collection runs

One run = one schedule on one date. Runs are created automatically for today's active schedules
(Philippine time, Asia/Manila). A `pending` run whose `end_time` has passed becomes `missed`.
Statuses: `pending`, `collected`, `partial`, `not_collected`, `missed`.

### GET /runs/today (admin and collector)
Today's runs with `area_name`, `barangay_name`, `start_time`, `end_time`, `waste_types`, `status`,
`reason`, `marked_by_name`, and `marked_at`.

### PATCH /runs/:id (collector and admin)
```json
{ "status": "not_collected", "reason": "Truck breakdown" }
```
`status`: `collected`, `partial`, or `not_collected`. `reason` (3+ characters) is required unless `collected`.
A run that is `pending` or `missed` can be marked once. Responses: `200`, `400`, `403`, `404`,
`409` already marked.

### GET /runs (admin only)
Query: `date` (YYYY-MM-DD, default today), `status`, `area_id`.

### GET /runs/mine (resident only)
Runs for the resident's own area for the last 7 days, to show "Collected at ..." in the app.


## Errors and limits
- Unknown `/api/...` routes return `404` `Route not found`; a malformed JSON body returns `400` `Invalid JSON body`.
- `POST /auth/login` allows 10 failed attempts per IP every 15 minutes (`429` after that; successful logins are not counted).
  `POST /auth/register` allows 20 requests per IP every 15 minutes. Both can be changed with
  `LOGIN_RATE_LIMIT` and `REGISTER_RATE_LIMIT` in `.env`.