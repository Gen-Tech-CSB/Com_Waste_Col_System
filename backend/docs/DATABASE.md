# Database Setup

Database: PostgreSQL. Name: `waste_db`. Tool: pgAdmin (or `psql`).

## 1. Create the database and user

In pgAdmin, connect to your PostgreSQL server (as `postgres`), right-click the `postgres` database, choose **Query Tool**, and run (use your own password, letters and numbers only):

```sql
CREATE USER waste_user WITH PASSWORD 'ChangeMe123';
CREATE DATABASE waste_db OWNER waste_user;
```

## 2. Configure `.env`

Copy `.env.example` to `.env` inside `backend/` and set:

```
PORT=3000
DATABASE_URL=postgres://waste_user:ChangeMe123@localhost:5432/waste_db
JWT_SECRET=<long random string>
JWT_EXPIRES_IN=1d
```

Generate a secret with:

```
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Never commit `.env`.

## 3. Install, migrate, and seed

```
cd backend
npm install
npm run migrate
npm run seed
```

Expected output: `applied 001_init.sql`, `applied 002_schedules.sql`, `applied 003_schedule_waste_types.sql`, `applied 004_reports.sql`, then `seed done`.

## 4. Verify in pgAdmin

Open `waste_db`, then Schemas, public, Tables (right-click Tables, Refresh). You should see 8 tables:

| Table | Purpose |
|---|---|
| `users` | Accounts with role (`resident`, `admin`, `collector`) |
| `barangays` | List of barangays |
| `areas` | Zones/puroks inside a barangay |
| `collection_schedules` | One row per area per day of the week; `waste_types` is a list collected together |
| `reports` | Resident reports (missed pickup, illegal dumping, and so on) with a reference number and status |
| `report_photos` | Photo paths for each report (up to 3 per report) |
| `report_status_history` | Status timeline of each report (who changed it, when, and the remarks) |
| `schema_migrations` | Tracks which migration files were applied |

After seeding: 2 barangays, 8 areas, 3 users (admin, collector, resident), and 16 schedules.
The reports tables stay empty until reports are submitted.

## Relationships

- `areas.barangay_id` references `barangays.id`
- `users.area_id` references `areas.id`
- `collection_schedules.area_id` references `areas.id`
- `reports.user_id` references `users.id` (the resident who reported)
- `reports.area_id` references `areas.id`
- `reports.assigned_to` references `users.id` (the staff assigned, optional)
- `report_photos.report_id` references `reports.id` (deleted together with the report)
- `report_status_history.report_id` references `reports.id` (deleted together with the report)
- `report_status_history.changed_by` references `users.id`

## Migrations

SQL files live in `backend/src/db/migrations/` and run in filename order (`001_...`, `002_...`). Each file runs once. To change the schema, add a new numbered file; do not edit one that was already merged.

## Reset the database (deletes all data)

Run in the Query Tool connected to the `postgres` database:

```sql
DROP DATABASE waste_db;
CREATE DATABASE waste_db OWNER waste_user;
```

Then run `npm run migrate` and `npm run seed` again.

## Troubleshooting

| Error | Cause |
|---|---|
| `password authentication failed` | Wrong user or password in `DATABASE_URL` |
| `database "waste_db" does not exist` | Step 1 was not done |
| `ECONNREFUSED` | PostgreSQL service is not running |
| `Missing script: "migrate"` | `package.json` is missing the `migrate` script |