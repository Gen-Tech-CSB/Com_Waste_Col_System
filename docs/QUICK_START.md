# Quick Start

Community Waste Collection System

Use one command at a time. The project folder contains both backend and frontend. All example IP addresses must be checked against your teammate's current address.

## If your teammate runs the backend

You only need the frontend. Your teammate must keep their backend and PostgreSQL running.

First open this on your computer:

~~~text
http://192.168.254.127:3000/api/health
~~~

Proceed when it returns success true. From the project folder:

~~~powershell
cd frontend
flutter pub get
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

Open http://localhost:8080 in Chrome or Edge.

If you are currently inside backend, enter the frontend using:

~~~powershell
cd ..\frontend
~~~

Do not run your own backend just to connect to your teammate's server.

## If you run everything on your computer

PostgreSQL must already be installed/running and a development database must exist.

Terminal 1 starts in the project folder:

~~~powershell
cd backend
npm.cmd ci
~~~

Create .env only if missing, then edit its placeholders:

~~~powershell
if (!(Test-Path .env)) {
    Copy-Item .env.example .env
}
notepad .env
~~~

~~~dotenv
DATABASE_URL=postgresql://USERNAME:PASSWORD@localhost:5432/DATABASE_NAME
JWT_SECRET=your-long-random-secret
JWT_EXPIRES_IN=1d
PORT=3000
~~~

On the intended development database:

~~~powershell
npm.cmd run migrate
npm.cmd run db:check
npm.cmd start
~~~

Keep that terminal open. Confirm http://localhost:3000/api/health returns success true.

Terminal 2 starts in the project folder:

~~~powershell
cd frontend
flutter pub get
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000
~~~

Open http://localhost:8080. Press Ctrl+C in each terminal when finished.

## Accounts and the interface

Create account saves a resident through the backend. Use a valid email format and a password of at least 8 characters. Email ownership is not verified.

For sample development accounts only, the backend owner can run this inside backend:

~~~powershell
npm.cmd run seed
~~~

Seeded admin: admin@waste.test  
Initial password: Password123

The seed does not reset an existing password or role. Use the team's existing admin credentials when applicable. Public signup always creates a resident.

Tap the profile icon to view/edit your name, phone, and collection area. Open Settings to select light, dark, or device appearance. Your theme is remembered locally.

**Still demonstration features:** resident report submission, sample My reports/feedback, and provider-based schedules/announcements. Their current interface actions do not persist those changes to PostgreSQL.

## Common command errors

| Message | What to do |
|---|---|
| No pubspec.yaml or expected project root | Enter frontend |
| Missing script seed | Enter backend |
| backend/backend does not exist | You are already in backend |
| npm.ps1 is blocked | Use npm.cmd |
| PostgreSQL refused connection | Check the backend owner's database host, port, and server |
| Request timed out | Open the teammate's health URL from your own computer |
| Plugin symlink support required | Enable Windows Developer Mode, then rerun flutter pub get |

Open Windows developer settings if needed:

~~~powershell
Start-Process "ms-settings:developers"
~~~

## Checks and GitHub

Inside frontend:

~~~powershell
flutter analyze
flutter test --reporter expanded
~~~

Inside backend:

~~~powershell
npm.cmd test
~~~

From the project folder, on ci/cd_workflow:

~~~powershell
git status
git add .
git diff --cached --name-only
git commit -m "Describe your changes"
git push origin ci/cd_workflow
~~~

Exclude .env, secrets, and database backups. Open GitHub Actions to inspect the run. Automatic checks run only on pushes to ci/cd_workflow. They use a temporary test database, not your teammate's real database.

See PROJECT_GUIDE.md for Android/desktop commands, API details, deployment, database structure, and full troubleshooting.

