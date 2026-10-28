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

Expected output: `applied 001_init.sql`, then `seed done`.
Running them again is safe: migrate prints `skip ...` and seed does not duplicate data.

## 4. Verify in pgAdmin

Open `waste_db`, then Schemas, public, Tables (right-click Tables, Refresh). You should see:

| Table | Purpose |
|---|---|
| `users` | Accounts with role (`resident`, `admin`, `collector`) |
| `barangays` | List of barangays |
| `areas` | Zones/puroks inside a barangay |
| `schema_migrations` | Tracks which migration files were applied |

After seeding: 2 barangays, 5 areas, and 3 users (admin, collector, resident).

## Relationships

- `areas.barangay_id` references `barangays.id`
- `users.area_id` references `areas.id`

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