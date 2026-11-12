# Community Waste Collection System Guide

Setup Commands Features and Troubleshooting

Documentation date: 11 November 2026  
Application version: 1.0.0+1  
Documented source: commit a129dbd plus subsequent local interface updates on branch ci/cd_workflow  
Repository: https://github.com/Gen-Tech-CSB/Com_Waste_Col_System

This guide explains how to run, use, test, and maintain the current project. It is written for the project team, including members who run only the frontend while a teammate runs the backend and database. Commands use Windows PowerShell unless a different operating system is named.

**Start with Section 4 if your teammate already runs the backend. Start with Section 5 if you will run the backend and database yourself.** You do not need PostgreSQL on every computer.

The feature table describes the actual implementation. Several resident screens still use demonstration data even though account creation, login, profiles, and admin report management use the backend.

## 1 How the system works

The project has three running components:

~~~text
Browser or Android or desktop app
                  |
                  | HTTP requests to API_BASE_URL
                  v
          Express backend API
                  |
                  | DATABASE_URL kept on the backend
                  v
           PostgreSQL database

pgAdmin manages PostgreSQL.
GitHub stores code and runs automated checks.
~~~

- **Frontend:** a Flutter application. It displays the interface and sends supported requests to the backend.
- **Backend:** a Node.js and Express server. It checks input, authenticates users, and reads or writes database records.
- **PostgreSQL:** stores accounts, collection areas, schedules, reports, photos, and report history.
- **pgAdmin:** a management application used to inspect and administer PostgreSQL. It is not the database server itself.
- **GitHub Actions:** builds and tests code. The current workflow does not deploy a live backend or connect automatically to the team's database.

When a frontend connects to a teammate's backend, account registration is saved in the database configured on that teammate's backend. Your own computer does not need a database.

### Addresses and ports

| Address or port | Meaning |
|---|---|
| localhost | The computer running that particular app or command |
| 3000 | Default backend API port |
| 5432 | Usual PostgreSQL server port |
| 8080 | Frontend web-server port used in this guide |
| 10.0.2.2 | Android emulator address for the host computer |
| 192.168.254.127 | Example teammate backend address used during development; verify it before reuse |

**Two different settings have different jobs.** The frontend's `API_BASE_URL` points to the backend server. The backend's `DATABASE_URL` points to PostgreSQL. Never put a database connection string into the frontend.

## 2 Project folders and terminal basics

~~~text
Com_Waste_Col_System/
  .github/workflows/ci.yml     GitHub checks and build jobs
  backend/
    .env.example              Configuration template
    package.json              Backend commands
    server.js                 Server entry point
    src/
      controllers/            Request handlers and validation
      db/                     Connection checks, migrations and seed
      middleware/             Authentication and uploads
      models/                 Database queries
      routes/                 API endpoint registration
    docs/                     API and database reference
    test/                     Backend tests
  frontend/
    pubspec.yaml              Flutter dependencies and version
    lib/
      screens/                Login, register, home, admin, profile, settings
      providers/              Theme and demonstration data state
      services/               API client, address configuration, validation
      theme/                  Light and dark themes
      widgets/                Shared interface elements
    test/                     Flutter tests and Windows image references
    web/ android/ windows/ linux/ macos/
  docs/                       This guide and quick-start instructions
~~~

The **project folder** contains `backend` and `frontend`. The **Flutter folder** is `frontend`, where `pubspec.yaml` is located.

Check your current folder:

~~~powershell
Get-Location
Get-ChildItem
~~~

From the project folder, enter the frontend:

~~~powershell
cd frontend
~~~

From the backend folder, move to the frontend:

~~~powershell
cd ..\frontend
~~~

Move one folder up:

~~~powershell
cd ..
~~~

Run commands one at a time. Do not copy the `PS C:\...\>` prompt. Keep a long command on one line, including the complete `--dart-define` option. Browser links, Markdown brackets, and spaces do not belong inside an API address.

## 3 Software requirements

| Component | Needed by | Requirements |
|---|---|---|
| Flutter SDK | Anyone running or building the frontend | Flutter with a bundled Dart version satisfying the project's ^3.13.5 requirement |
| Chrome or Edge | Web developers and testers | A supported browser |
| Node.js and npm | Backend owner | Node.js 22 matches the current GitHub workflow |
| PostgreSQL | Database owner | A reachable PostgreSQL server; CI uses PostgreSQL 16 |
| pgAdmin | Database administrator | Optional graphical database management tool |
| Git | Team members exchanging source code | Access to the GitHub repository |
| Android tools | Android developers | Android SDK, command-line tools, Java, and an emulator or USB-connected phone |
| Windows build tools | Windows desktop developers | Visual Studio with Desktop development with C++ and its required Windows SDK |
| Platform tools | Linux or macOS developers | The native tools reported by Flutter doctor on that operating system |

Check the installed tools:

~~~powershell
flutter --version
flutter doctor
node --version
npm.cmd --version
git --version
~~~

On Windows, this guide uses `npm.cmd` because PowerShell can block `npm.ps1`. On Linux and macOS, use `npm` instead.

If Flutter reports that plugins require symlink support, enable Windows Developer Mode. Open the relevant settings page with:

~~~powershell
Start-Process "ms-settings:developers"
~~~

After enabling it, run `flutter pub get` again inside `frontend`. Fully restart Flutter after adding a plugin.

## 4 Run only the frontend using a teammate's backend

This is the recommended development arrangement when your teammate owns the database.

### What your teammate does

On the computer running the backend:

1. Open the matching project version.
2. Configure `backend/.env` for the PostgreSQL database.
3. Start the backend from `backend`:

~~~powershell
npm.cmd ci
npm.cmd start
~~~

4. Keep the backend terminal open.
5. Open `http://localhost:3000/api/health` on that computer.
6. Find the active network adapter's IPv4 address:

~~~powershell
ipconfig
~~~

7. Allow the backend's TCP port 3000 through the firewall for the shared private network as needed.

Your teammate should confirm that the health endpoint returns:

~~~json
{"success":true,"message":"API and DB OK"}
~~~

### What you do

Connect to the same reachable network or VPN. In your browser, open the teammate's address, for example:

~~~text
http://192.168.254.127:3000/api/health
~~~

If it works on their computer but not yours, investigate the IP address, network routing, and firewall before trying registration.

From the project folder:

~~~powershell
cd frontend
flutter pub get
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

Open `http://localhost:8080` manually in Chrome or Edge. Replace the example IP with the teammate's current server address.

The backend computer must stay on, reachable, and running the server. Your frontend does not require PostgreSQL, pgAdmin, or a local backend in this arrangement. Changing your own `backend/.env` will not change the database used by your teammate's backend.

## 5 Run the full system on one development computer

Use two terminals. Both terminals initially start in the project folder.

### Prepare the development database

The database owner must create a PostgreSQL database and a database login allowed to use it. One example database name is `waste_db`; the actual name is the one in your configuration.

In pgAdmin, connect to the PostgreSQL server and use its database management controls or Query Tool to create the development database and assign the intended owner. Use credentials supplied by your database administrator.

Existing team databases should be backed up before schema changes. Do not reset a shared database to solve a frontend problem.

### Terminal 1 Configure and start the backend

~~~powershell
cd backend
npm.cmd ci
~~~

Create the local configuration file only if it does not already exist:

~~~powershell
if (!(Test-Path .env)) {
    Copy-Item .env.example .env
}
notepad .env
~~~

Fill in your own values:

~~~dotenv
DATABASE_URL=postgresql://USERNAME:PASSWORD@DATABASE_HOST:5432/DATABASE_NAME
JWT_SECRET=replace-with-a-long-random-secret
JWT_EXPIRES_IN=1d
PORT=3000
~~~

Replace all placeholders. Use `localhost` only when PostgreSQL is on the same computer as the backend. Passwords containing URL-reserved characters must be URL-encoded within a connection URL.

Generate a JWT signing secret locally if you need a new development secret:

~~~powershell
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
~~~

Paste the result into your local configuration. Keep `.env`, actual database passwords, signing secrets, and database backups out of GitHub.

Check the connection:

~~~powershell
npm.cmd run db:check
~~~

If it says the database is connected but required tables are missing, apply the project's migrations to the intended development database:

~~~powershell
npm.cmd run migrate
npm.cmd run db:check
~~~

Optionally create sample development data:

~~~powershell
npm.cmd run seed
~~~

Start the backend:

~~~powershell
npm.cmd start
~~~

Expected server message:

~~~text
Server running on port 3000
~~~

Check `http://localhost:3000/api/health`. Keep Terminal 1 running.

For automatic restarts after backend source changes, use this instead of `npm.cmd start`:

~~~powershell
npm.cmd run dev
~~~

### Terminal 2 Start the frontend

From the project folder:

~~~powershell
cd frontend
flutter pub get
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000
~~~

Open `http://localhost:8080`. To use Flutter's automatic Chrome launch instead:

~~~powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
~~~

Press Ctrl+C in each terminal to stop its running process.

## 6 What each backend command does

Run these inside `backend`.

| Command | Purpose | Changes database data |
|---|---|---|
| npm.cmd ci | Install dependencies from the lockfile | No |
| npm.cmd run db:check | Check connectivity and required seed tables | No |
| npm.cmd run migrate | Apply unapplied SQL migration files | Yes |
| npm.cmd run seed | Add sample development accounts, areas, and schedules | Yes |
| npm.cmd start | Start the API server | Requests can change data |
| npm.cmd run dev | Start the API with source-file watching | Requests can change data |
| npm.cmd test | Run backend tests | Ordinary local tests mock database operations; the opt-in integration test writes only to its test database |

A successful `db:check` confirms connectivity and the specific table checks implemented by that script. Applying migrations remains the way to ensure the full project schema is installed.

## 7 Current features and their status

| Feature | Current implementation | Where its state is kept |
|---|---|---|
| Create account | Real API request; creates a resident after server confirmation | PostgreSQL |
| Login | Real credentials checked by the backend; routes by database role | PostgreSQL account plus an in-memory JWT session |
| Profile view and editing | Reads the account; edits name, phone, and collection area | PostgreSQL |
| Admin report summary | Counts stored reports by status | PostgreSQL |
| Admin report list | Filters, pagination, and report detail | PostgreSQL |
| Admin report status updates | Validates transitions and saves remarks/history | PostgreSQL |
| Settings and appearance | Light, dark, or device-controlled mode | Device/browser preferences |
| Responsive navigation | Phone navigation and desktop sidebar; profile icon opens profile | App state |
| Collection schedule screen | Preview schedules with waste-type filters, expandable preparation tips, and navigation shortcuts | Current app memory |
| Manage schedules interface | Adds and removes demonstration schedules | Current app memory |
| Announcement interface | Updates a local provider value | Current app memory |
| Resident report submission interface | Demonstration confirmation; currently does not send the report to the API | No database insert from this screen |
| My reports and service feedback interface | Sample report and local rating/feedback behavior | Local demonstration state |
| Sorting guide | Searchable guidance with expandable category examples and a local-rules reminder | Source code |

**Important:** a success notice on the resident report demonstration screen does not mean a report was inserted into PostgreSQL. The backend report API exists, but that resident screen still needs integration.

The sorting guide directs users to their barangay waste office for current rules and contact details. Local schedule and announcement changes are not shared between separate computers or app instances.

## 8 Accounts roles and admin access

Everyone uses the same login screen. The backend returns the user's role.

| Role | Current access |
|---|---|
| Resident | Resident workspace and own profile; resident report API permissions |
| Admin | Admin workspace, report status changes, schedule API management, and own profile |
| Collector | Admin-style report viewing and own profile; cannot perform admin-only status changes |

Public registration always creates a resident. It cannot set the admin role.

### Development seed accounts

These accounts are inserted by `npm.cmd run seed` in the database configured on the backend:

| Role | Email | Initial password |
|---|---|---|
| Admin | admin@waste.test | Password123 |
| Collector | collector@waste.test | Password123 |
| Resident | resident@waste.test | Password123 |

These are development fixtures, not an authentication bypass. They work only after they exist in the backend's database. Seeding does not reset an existing account's password or role when the email already exists.

For a real team administrator, the database owner can assign the admin role to an approved existing account. For example, in pgAdmin's Query Tool on the correct database:

~~~sql
UPDATE users
SET role = 'admin'
WHERE email = 'approved.admin@example.com'
RETURNING id, email, role;
~~~

Replace the example email with the approved account. The person must log out and log in again so their new token contains the updated role.

To inspect accounts without displaying password hashes:

~~~sql
SELECT id, full_name, email, role, area_id, phone
FROM users
ORDER BY id;
~~~

## 9 Create an account and sign in

1. Start the matching backend and frontend versions.
2. Confirm that the backend health endpoint succeeds from the frontend computer.
3. Select Create an account.
4. Enter your full name, email, optional phone, password, and matching password confirmation.
5. Optionally expand Collection area and select a registered barangay/purok.
6. Submit and wait for confirmation.
7. Sign in using the same email and password.

Current validation includes:

- Full name: 2 to 150 characters after trimming.
- Email: valid address format, normalized to lowercase, at most 150 characters.
- Password for a new account: at least 8 characters and at most 72 UTF-8 bytes.
- Confirmation: must match the password.
- Phone: optional, up to 20 characters.
- Area: optional; a supplied ID must exist in the database.

Email checks validate format only. No verification email is sent and ownership of the inbox is not confirmed.

A failed registration request does not show account-created success. General errors appear in a small dismissible notice; field errors appear below the relevant inputs. Duplicate email addresses are rejected.

Passwords are hashed by the backend using bcrypt. The frontend does not store the password or persist the JWT. Reloading the page or restarting the app requires signing in again.

## 10 Profile settings and appearance

### Profile

Tap the person/avatar icon in the resident header or use Profile in the phone navigation and My profile in the desktop sidebar. Admins can use the person icon in their header.

The profile shows your name, account email, role, and initials avatar. You can edit your full name, phone, and collection area.

- Save changes sends an authenticated request to the backend.
- Discard changes restores the last loaded or saved profile.
- Failed saves preserve the details you typed.
- Email and role are account details, not editable profile fields.
- An expired session offers a route back to sign in.
- If the collection-area list fails to load, the stored area is retained.

A profile save changes only the signed-in user's record.

### Settings

Open the gear icon, the desktop Settings item, or the Settings control on your profile. Appearance offers:

| Choice | Behavior |
|---|---|
| Light mode | Light surfaces with readable dark text |
| Dark mode | Dark surfaces with green accents |
| Use device setting | Follows the operating system's light or dark appearance |

The choice is saved locally. On the web, use the same browser and site origin, including port, to reuse the saved preference. It is not a PostgreSQL profile preference and is not synchronized to other devices. Browser data clearing can remove it.

## 11 Admin dashboard and report workflow

The dashboard loads real counts and reports through the API. It provides status filters, ten-report pages, report details, and refresh/retry controls.

An empty list should show No reports to show. It should not produce a Report not found error simply because the database has no reports.

Choose Review report to view its details. Admins can choose a permitted next status and save remarks. Collectors have read-only report access through the dashboard.

| Current status | Permitted next statuses |
|---|---|
| submitted | under_review, rejected |
| under_review | in_progress, resolved, rejected |
| in_progress | resolved, rejected |
| resolved | None |
| rejected | None |

Rejecting a report requires remarks of at least 3 characters. Remarks have a maximum of 500 characters. The server records a status history. If a report has changed and the server rejects the transition, the interface shows an error instead of confirming success.

Existing reports must already be in PostgreSQL, for example through the report API. The resident report form currently remains a demonstration feature.

## 12 Android and desktop commands

Run Flutter commands inside `frontend`. Keep the backend reachable from the device.

### Android emulator

Start an emulator and list devices:

~~~powershell
flutter devices
~~~

Replace DEVICE_ID with the emulator ID returned by that command:

~~~powershell
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://10.0.2.2:3000
~~~

Use 10.0.2.2 when the backend runs on the computer hosting the emulator. Use the teammate's reachable IP when the backend runs on a different computer.

### Physical Android phone

Enable Developer options and USB debugging on the phone. Connect with a USB data cable and accept the debugging prompt. List devices and use the phone's ID:

~~~powershell
flutter devices
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

The phone itself must be able to reach the backend address. A USB connection alone does not make a teammate's private network reachable.

For Android tooling checks:

~~~powershell
flutter doctor
flutter doctor --android-licenses
~~~

Install missing Android SDK command-line tools through Android Studio's SDK Manager if Flutter reports that they are absent.

### Desktop

Run each command on the matching operating system:

~~~powershell
flutter run -d windows --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

~~~bash
flutter run -d linux --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

~~~bash
flutter run -d macos --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

Windows needs the Visual Studio C++ desktop tools. macOS needs Xcode and its platform prerequisites. Linux requires its native build dependencies; the current CI installs clang, cmake, ninja-build, pkg-config, and libgtk-3-dev.

## 13 Build distributable files

Use the actual reachable backend URL at build time. These examples use an illustrative HTTPS hostname that must be replaced.

From `frontend`:

~~~powershell
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
flutter build windows --release --dart-define=API_BASE_URL=https://api.example.com
~~~

On Linux or macOS:

~~~bash
flutter build linux --release --dart-define=API_BASE_URL=https://api.example.com
flutter build macos --release --dart-define=API_BASE_URL=https://api.example.com
~~~

| Target | Usual output location inside frontend |
|---|---|
| Web | build/web/ |
| Android APK | build/app/outputs/flutter-apk/app-release.apk |
| Windows | build/windows/x64/runner/Release/ |
| Linux | build/linux/x64/release/bundle/ |
| macOS | build/macos/Build/Products/Release/ |

Output architecture can vary by build target. Distribute the full desktop bundle, not just an executable copied out of its required files.

Android store/release distribution needs the team's proper signing configuration; the generated project template is not a completed production signing setup. Local HTTP is enabled for Android debug/profile development. Use HTTPS for release deployment.

To preview an already built web folder, if Python is installed:

~~~powershell
py -m http.server 8080 --directory build/web
~~~

Then open `http://localhost:8080`. Serve the web folder through a web server; do not rely on opening index.html directly from disk.

## 14 Test and verify the project

### Frontend checks

Run inside `frontend`:

~~~powershell
flutter analyze
flutter test --reporter expanded
~~~

To reduce the number of test workers:

~~~powershell
flutter test --concurrency=1 --reporter expanded
~~~

To reproduce CI-style fallback-font layout checks on Windows:

~~~powershell
flutter test --concurrency=1 --dart-define=LAYOUT_ONLY=true --reporter expanded
~~~

The current suite contains 29 Flutter tests covering account forms, API errors, authentication sessions, profile editing, admin status updates, responsive navigation, settings, and preference persistence.

Screenshot references are Windows-specific. Linux still runs functional and layout assertions, including the shorter desktop-window check, without requiring the Windows screenshot fonts.

### Backend checks

Run inside `backend`:

~~~powershell
npm.cmd test
~~~

Ordinary local tests use mocked database operations. The separate database integration test is enabled by RUN_DB_TESTS=1 and is intended for a disposable test database after migrations. It creates and removes a test account and checks actual registration, login, profile persistence, and report-summary access. Do not enable it casually against the team's real database.

### Verify real persistence

On the intended development system:

1. Confirm /api/health succeeds.
2. Create a unique resident account through the app.
3. Ask the database owner to inspect the users table in pgAdmin.
4. Sign in with that account.
5. Change its phone or name in Profile and save.
6. Inspect the same users row again.

Opening the interface alone does not prove database connectivity. A frontend unit test using a mock HTTP client also does not prove a connection to the team's database.

## 15 Git and GitHub commands

The project repository is:

~~~text
https://github.com/Gen-Tech-CSB/Com_Waste_Col_System.git
~~~

The branch used for automatic checks is `ci/cd_workflow`, not `cd/cd_workflow`.

### Clone a fresh copy

~~~powershell
git clone --branch ci/cd_workflow https://github.com/Gen-Tech-CSB/Com_Waste_Col_System.git
cd Com_Waste_Col_System
~~~

### Check your current branch and remote

Run from the project folder:

~~~powershell
git status
git branch --show-current
git remote -v
~~~

If origin is missing:

~~~powershell
git remote add origin https://github.com/Gen-Tech-CSB/Com_Waste_Col_System.git
~~~

If origin already exists but points to the wrong repository:

~~~powershell
git remote set-url origin https://github.com/Gen-Tech-CSB/Com_Waste_Col_System.git
~~~

The URL is an argument to a Git command. Entering the URL alone in PowerShell will not upload anything.

### Save and push changes

Use the ci/cd_workflow branch and review what you are publishing:

~~~powershell
git switch ci/cd_workflow
git status --short
git add .
git diff --cached --name-only
git commit -m "Describe your changes"
git push origin ci/cd_workflow
~~~

Check that the staged list does not include .env, real credentials, or database backups. The current ignore rules exclude backend/.env, backend/node_modules, Flutter build output, and generated test-failure images.

### Receive team changes

With your current work committed or otherwise safely saved:

~~~powershell
git fetch origin
git pull --ff-only origin ci/cd_workflow
~~~

If Git reports diverging or unrelated histories, stop and inspect the situation with the team. Do not use force push as a general fix for rejected pushes.

## 16 What GitHub Actions runs

The workflow is stored in `.github/workflows/ci.yml`.

Automatic execution is limited to pushes to `ci/cd_workflow`. The file also enables manual dispatch. There is no pull-request trigger in the current workflow.

Merging the code into another branch carries over the code, but this branch filter does not automatically run checks on that other branch. It does not control whether the application itself can run.

| Job | Current behavior |
|---|---|
| Flutter Tests and Web Build | Install dependencies, analyze, run tests, build web, upload flutter-web-build |
| Backend and PostgreSQL Tests | Start temporary PostgreSQL 16, install backend packages, apply migrations, run tests including the database integration test |
| Native build matrix | Build Android debug APK, Windows release, Linux release, and macOS release on matching runners |

The native matrix currently checks builds but does not upload native packages as downloadable artifacts. The web job uploads `flutter-web-build`.

### View a run

1. Open the repository on GitHub.
2. Select Actions.
3. Open Community Waste System CI.
4. Open the run for your commit.
5. Expand the relevant job and step.

If a Run workflow button is available, choose ci/cd_workflow to start a manual run. Pushing a new commit to that branch also starts the configured checks.

If a step ends with Process completed with exit code 1, read the earlier lines for the failed test name and actual exception. That final line is only a failure summary.

### Test database versus team database

The backend job creates its own temporary database named testdb with workflow test credentials. It does not use the team's backend/.env file, and passing this job does not prove that the team's real database is reachable.

The current web build does not supply a deployment API_BASE_URL. It therefore uses the frontend's default localhost backend address. Rebuild with the deployed backend URL before using that artifact as a public, database-connected website.

## 17 Deploying a shared website

A complete deployment needs three reachable components:

~~~text
Public frontend URL
        |
        v
Public HTTPS backend URL
        |
        v
PostgreSQL accessible to that backend
~~~

1. Choose a backend hosting environment that can run the Node.js server.
2. Configure its private DATABASE_URL, JWT_SECRET, JWT_EXPIRES_IN, and required PORT settings.
3. Make the intended PostgreSQL database reachable from that backend.
4. Apply the project's schema to the intended environment under the database owner's control.
5. Deploy the matching backend code and verify its /api/health endpoint.
6. Build the Flutter frontend with that backend's HTTPS origin.
7. Host the contents of frontend/build/web using an appropriate static hosting service.
8. Verify registration, login, profile saving, and admin report access end to end.

An example build command, after replacing the hostname:

~~~powershell
flutter build web --release --dart-define=API_BASE_URL=https://api.example.com
~~~

API_BASE_URL is an origin only; do not add /api because the app adds it. It is compiled into the frontend. Changing a frontend machine's .env does not change a built web bundle.

A database on a teammate's private Wi-Fi address is usually not reachable from a public hosting server or GitHub runner without suitable routing. A public website cannot rely on a teammate's laptop being off or disconnected.

Keep database credentials on the backend. A hosted frontend must use HTTPS-compatible API access. Plan proper Android signing, upload storage, access controls, backups, and integration of the remaining demonstration screens before treating the project as a completed public service.

Uploading code to GitHub or obtaining a successful build is not a deployment step in the current workflow.

## 18 Database access and structure

### Who needs direct database access

Frontend users connect to the backend, not directly to PostgreSQL. If the backend and PostgreSQL run together on your teammate's computer, frontend access normally requires the backend port, not an open PostgreSQL port on every client.

For administration through pgAdmin on a different computer, the database owner must provide the server address, port, database name, username, and password and allow the connection.

PostgreSQL remote access may require:

- An appropriate listen_addresses setting on the database server.
- A pg_hba.conf rule limited to the intended client IP and database account.
- Firewall or hosting-provider access rules.
- A shared network, VPN, or other authorized route.

Example pg_hba.conf pattern for an administrator to adapt:

~~~text
host DATABASE_NAME DATABASE_USER YOUR_CLIENT_IP/32 scram-sha-256
~~~

Do not replace a server's existing access rules wholesale. Consult the PostgreSQL documentation and database owner.

### Tables

| Table | Purpose |
|---|---|
| barangays | Barangay records |
| areas | Puroks or zones linked to a barangay |
| users | Accounts, roles, password hashes, phone, and optional area |
| collection_schedules | Area, day, start/end time, active state, waste types |
| reports | Report category, description, location, owner, status, reference |
| report_photos | File paths associated with reports |
| report_status_history | Changes, remarks, actor, and time |
| schema_migrations | Applied migration filenames |

Areas reference barangays. Users and schedules reference areas. Reports reference their resident and area. Photos and history reference the report.

The migration files are 001_init.sql, 002_schedules.sql, 003_schedule_waste_types.sql, and 004_reports.sql. Add new numbered migrations for future schema changes instead of rewriting migrations already used by the team.

On a fresh development database, the seed creates 2 barangays, 8 areas, 3 sample users, and 16 schedules. Existing databases can have different totals. Seeding does not create sample reports.

When moving databases, use PostgreSQL/pgAdmin backup and restore under the owner's control. Creating a new empty database does not move existing users and reports. Keep backups outside the source repository.

## 19 API reference

All paths below start with `/api`. Successful responses normally contain `success: true` and `data`; errors contain `success: false` and a message. Validation errors can also include an errors list.

Protected endpoints require:

~~~text
Authorization: Bearer TOKEN_FROM_LOGIN
~~~

| Method | Path after /api | Access | Purpose |
|---|---|---|---|
| GET | /health | Public | Check API and database |
| POST | /auth/register | Public | Create a resident |
| POST | /auth/login | Public | Obtain token and account details |
| GET | /auth/me | Signed-in user | Read own profile |
| PATCH | /auth/me | Signed-in user | Update own name, phone, area |
| GET | /areas | Public | List collection areas |
| GET | /schedules | Signed-in user | Resident's active-area schedules, or staff list |
| POST | /schedules | Admin | Create schedules for one or more areas |
| PUT | /schedules/:id | Admin | Update one schedule |
| DELETE | /schedules/:id | Admin | Delete one schedule |
| POST | /reports | Resident | Create a report through the API |
| GET | /reports/mine | Resident | List own reports |
| GET | /reports | Admin or collector | List reports with pagination and filters |
| GET | /reports/summary | Admin or collector | Count reports by status |
| GET | /reports/:id | Owner, admin, collector | Read a report with photos and history |
| PATCH | /reports/:id/status | Admin | Save a permitted status transition |

Profile updates accept only full_name, phone, and area_id, with at least one field. Phone and area_id can be null to clear them. Attempts to update id, email, or role through the profile endpoint are rejected.

Report categories are missed_pickup, illegal_dumping, overflowing_bin, and other. Description length is 5 to 1000 characters. Optional latitude and longitude must be supplied together.

The report API supports multipart/form-data with up to 3 photos, each at most 5 MB, using the field name photos. Supported types are JPG, PNG, and WEBP. This capability belongs to the backend API; the current resident report screen is not integrated with it.

Schedules use day_of_week values 0 through 6, where 0 is Sunday. Times use HH:MM. The backend supports biodegradable, non_biodegradable, recyclable, and special waste types.

For payload examples and additional responses, see backend/docs/API.md.

## 20 Troubleshooting

### Flutter cannot find pubspec.yaml

You are outside the Flutter folder. From the project folder:

~~~powershell
cd frontend
flutter pub get
~~~

From backend:

~~~powershell
cd ..\frontend
~~~

### PowerShell says npm.ps1 cannot be loaded

Use the Windows command wrapper:

~~~powershell
npm.cmd ci
npm.cmd start
~~~

Changing the computer's execution policy is not required for these commands.

### Missing script seed or migrate

Run the command in backend, where package.json defines it:

~~~powershell
cd backend
npm.cmd run seed
~~~

If already inside backend, run only the last command. Do not enter backend a second time.

### PostgreSQL refused the connection

Check the host and port in the backend owner's .env. localhost means that backend computer. Confirm PostgreSQL is running and accepts that connection.

If your teammate runs the backend and database, use their API from your frontend instead of trying to run an unconfigured local backend.

### Database connected but tables are missing

Have the database owner apply the project migrations to the intended development database, then run db:check again. Do not seed into a database with an unrelated schema.

### Frontend request timed out

Test the API address from the frontend computer:

~~~powershell
Test-NetConnection -ComputerName 192.168.254.127 -Port 3000
~~~

Read TcpTestSucceeded. Also open the backend health URL in a browser. Check the teammate's backend process, current IPv4 address, network/VPN, and firewall. An IP address can change when the network reconnects.

### Incorrect email or password

Use a database account, not the removed frontend mock login. Confirm the backend points to the expected database. Seed accounts work only if inserted, and the seed script does not reset an existing password.

### Account creation fails

Read the field errors or dismissible notice. Check email format, the eight-character minimum, matching passwords, duplicate email, and API reachability. Server errors require checking the backend owner's terminal and database configuration.

### Admin dashboard says Report not found

The initial summary request can be mistaken for an ID if the backend is an older version. Update the teammate's backend to the matching source and restart it. The /reports/summary route must be registered before /reports/:id.

An empty database should show an empty state, not an endpoint error.

### Profile saving gives an endpoint error

The running backend needs PATCH /api/auth/me plus its controller and model implementation. Update the matching backend source and restart. Also check session expiry and the validity of the selected collection area.

### Login returns a server error

Check database access, JWT_SECRET, and JWT_EXPIRES_IN on the backend. A valid expiry example is 1d. Read the backend terminal's actual error; do not share secrets in a public issue.

### Chrome debugger shows Runtime.evaluate or execution-context errors

Try the supported web-server option and open the page manually:

~~~powershell
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://192.168.254.127:3000
~~~

A debugger error alone does not establish whether PostgreSQL is connected. Check the health endpoint separately.

### Flutter reports plugin symlink support is required

Enable Windows Developer Mode and run flutter pub get again. Fully restart the frontend rather than relying on hot reload for a newly added plugin.

### Flutter tests report that the disk is full

Free disk space before retrying. Flutter uses generated build files and temporary compiler output. A project cleanup can remove rebuildable output:

~~~powershell
flutter clean
flutter pub get
~~~

Run these in frontend. Cleanup can require plugin links to be recreated, so Developer Mode may be needed on Windows.

### Git push says non fast forward or fetch first

Save your work, fetch, and inspect the branch:

~~~powershell
git fetch origin
git status
~~~

If a normal fast-forward update is possible on the correct branch:

~~~powershell
git pull --ff-only origin ci/cd_workflow
git push origin ci/cd_workflow
~~~

If histories diverge, coordinate a merge with the team. Avoid force pushing over another person's work.

### GitHub says Repository not found

Check git remote -v and the exact repository URL. Sign in with an account that has repository access. A correct-looking URL does not grant permission.

### GitHub says Process completed with exit code 1

Expand the failed step and read the earlier exception. Package update notices are informational. Preserve the failing test name and error details when asking for help.

### Code was pushed but the teammate still sees old behavior

A GitHub push does not restart the backend on a teammate's computer. The teammate must obtain the matching code, install changed dependencies, apply any intended migrations, and restart the server.

## 21 Team handoff checklist

Before a demonstration:

- Agree on the project version and branch.
- Confirm which computer or service runs PostgreSQL and the backend.
- Verify the health endpoint from each frontend device.
- Start frontend builds with the correct API origin.
- Use a registered account with the intended role.
- Demonstrate real registration, login, profile edits, and admin reports.
- Clearly identify local demonstration screens.
- Keep the backend computer awake and its terminal running.
- Confirm that secrets and database backups are excluded from the commit.
- Record any failed job's actual error rather than only its exit code.

Before public deployment, finish the resident report and schedule integrations, decide how announcements and feedback will be stored, verify local guidance and contact information, and configure hosting, HTTPS, signing, backups, and operational access.

## 22 Official references and project references

- Flutter web setup: https://docs.flutter.dev/platform-integration/web/setup
- Flutter web build and deployment: https://docs.flutter.dev/deployment/web
- GitHub workflow triggers: https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow
- PostgreSQL client access rules: https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
- Project API details: backend/docs/API.md
- Existing database notes: backend/docs/DATABASE.md
- Workflow source: .github/workflows/ci.yml
- Recorded successful Flutter job for source a129dbd: https://github.com/Gen-Tech-CSB/Com_Waste_Col_System/actions/runs/42689833662/job/129406342136

The project source and current configuration remain the authority when the code changes after this documentation snapshot.


