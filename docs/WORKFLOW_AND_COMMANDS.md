# Community Waste Collection System — Workflow and Commands

This guide covers setup, local development, web/Android/Windows, database connectivity, testing, GitHub CI, builds, and deployment. Run commands one at a time. Replace example addresses and credentials with your actual settings.

## 1. Overall system structure

```text
User / Administrator
        ↓
Flutter frontend (Web · Android · Windows desktop)
        ↓ HTTP API requests
Node.js + Express backend
        ↓ SQL queries
PostgreSQL database
```

pgAdmin manages PostgreSQL; PostgreSQL stores the records. GitHub stores source code and runs automated checks. The current workflow does not publish a live application automatically.

## 2. Project folders

```text
Com_Waste_Col_System/
├── .github/workflows/       GitHub automated checks
├── backend/
│   ├── server.js            API entry point
│   ├── package.json         Commands and dependencies
│   ├── .env                Local database settings and secrets (ignored)
│   └── src/
│       ├── routes/          API endpoints
│       ├── controllers/     Request handling
│       ├── middleware/      Authentication and uploads
│       └── db/              Connection and migrations
├── frontend/
│   ├── pubspec.yaml         Flutter dependencies
│   ├── lib/                Screens, widgets, providers, services
│   ├── test/               Automated tests
│   ├── web/
│   ├── android/
│   └── windows/
└── docs/                   Guides
```

Run npm commands inside `backend` and Flutter commands inside `frontend`.

## 3. Prepare your computer

Install Git, Node.js/npm, Flutter, and Chrome. For Android, install Android Studio and SDK tools. For Windows desktop, install Visual Studio with **Desktop development with C++**, including default components. Visual Studio is separate from VS Code.

Install PostgreSQL and optionally pgAdmin only if you host the database locally. A teammate can host the database instead.

```powershell
git --version
node --version
npm.cmd --version
flutter --version
flutter doctor
```

### Android tools and licenses

In Android Studio: **More Actions → SDK Manager → SDK Tools → Android SDK Command-line Tools (latest) → Apply**.

```powershell
flutter doctor --android-licenses
flutter doctor
```

Review and accept the SDK licenses. When Flutter requests plugin symlink support, open Windows Developer Settings and enable Developer Mode:

```powershell
Start-Process "ms-settings:developers"
```

Keep several GB of free disk space; native toolchains and builds may need considerably more. Check the installer's required space.

## 4. Open the project

Existing local copy:

```powershell
cd "C:\Users\USER\Downloads\Com_Waste_Col_System-ci-cd_workflow\Com_Waste_Col_System-ci-cd_workflow"
git branch --show-current
git status
```

The intended working branch is `ci/cd_workflow`. To obtain a fresh copy on another computer:

```powershell
git clone --branch ci/cd_workflow https://github.com/Gen-Tech-CSB/Com_Waste_Col_System.git
cd Com_Waste_Col_System
```

## 5. Configure PostgreSQL connectivity

From the project root:

```powershell
cd backend
```

Only if `.env` does not already exist:

```powershell
Copy-Item .env.example .env
```

Edit `.env` with the database owner's connection details:

```dotenv
DATABASE_URL=postgresql://USERNAME:PASSWORD@HOST:5432/DATABASE_NAME
JWT_SECRET=replace-with-a-long-random-secret
JWT_EXPIRES_IN=1d
PORT=3000
```

| Database location | HOST |
|---|---|
| Same computer as backend | `localhost` |
| Teammate's computer | Their reachable database IP address |
| Hosted PostgreSQL | Provider's database hostname |

For remote PostgreSQL, the owner must configure PostgreSQL client access and the firewall to allow the backend computer. Use the hosting provider's required TLS settings for hosted connections. Do not commit `.env`, tokens, or real database passwords.

## 6. Start the backend

Open Terminal 1:

```powershell
cd "C:\Users\USER\Downloads\Com_Waste_Col_System-ci-cd_workflow\Com_Waste_Col_System-ci-cd_workflow\backend"
npm.cmd ci
npm.cmd run db:check
```

For a new development database, apply the schema and check again:

```powershell
npm.cmd run migrate
npm.cmd run db:check
```

Optional development sample data:

```powershell
npm.cmd run seed
```

Seed only the intended development database. This creates sample records and development accounts.

Start the server:

```powershell
npm.cmd start
```

Or use automatic restarts during development:

```powershell
npm.cmd run dev
```

Choose one server command; do not run both on port 3000. Open `http://localhost:3000/api/health`. Expected response:

```json
{"success":true,"message":"API and DB OK"}
```

This confirms database reachability, not every application feature. When your teammate runs the backend, check their address instead and do not start a second backend just to use their API.

## 7. Start the web frontend

Open Terminal 2:

```powershell
cd "C:\Users\USER\Downloads\Com_Waste_Col_System-ci-cd_workflow\Com_Waste_Col_System-ci-cd_workflow\frontend"
flutter pub get
```

Backend on your own computer:

```powershell
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000
```

Backend on your teammate's computer:

```powershell
flutter run -d web-server --web-port=8080 --dart-define=API_BASE_URL=http://192.168.254.127:3000
```

Open `http://localhost:8080`. Replace the IP if it changes. Alternatively, launch Chrome directly:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.254.127:3000
```

Keep the backend and frontend running in separate terminals.

## 8. Run on an Android phone

Enable Developer options and USB debugging. Connect the phone by USB, accept its debugging prompt, and connect the phone and backend computer to the same Wi-Fi.

From `frontend`:

```powershell
flutter devices
flutter run -d PHONE_ID --dart-define=API_BASE_URL=http://192.168.254.127:3000
```

Replace `PHONE_ID` with the listed device ID. First open `http://192.168.254.127:3000/api/health` in the phone's browser. If unreachable, check the backend IP, Wi-Fi, and firewall access to port 3000.

On a phone, `localhost` means the phone itself, not your computer.

## 9. Run on an Android emulator

Start an emulator in Android Studio's Device Manager. From `frontend`:

```powershell
flutter devices
```

Backend on the emulator's host computer:

```powershell
flutter run -d EMULATOR_ID --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Backend on your teammate's computer:

```powershell
flutter run -d EMULATOR_ID --dart-define=API_BASE_URL=http://192.168.254.127:3000
```

Replace `EMULATOR_ID` with the listed ID.

## 10. Run on Windows desktop

After installing Visual Studio's C++ workload, reopen PowerShell. From `frontend`:

```powershell
flutter doctor
```

Backend on your computer:

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:3000
```

Backend on your teammate's computer:

```powershell
flutter run -d windows --dart-define=API_BASE_URL=http://192.168.254.127:3000
```

### API address reference

| App target | Backend location | API base URL |
|---|---|---|
| Web or Windows | Same computer | `http://localhost:3000` |
| Android emulator | Same computer | `http://10.0.2.2:3000` |
| Physical phone | Computer on same Wi-Fi | `http://COMPUTER_IP:3000` |
| Any target | Teammate's computer | `http://TEAMMATE_IP:3000` |
| Deployed app | Hosted backend | `https://YOUR_BACKEND_HOST` |

Only the backend receives PostgreSQL credentials. The frontend receives the backend API address.

## 11. Account and administrator workflow

```text
Create account → Frontend validation → Backend validation
→ Hash password → Insert PostgreSQL user → Confirm success
→ Sign in → Verify credentials → Return token → Open role's screen
```

Registration supports email format validation, passwords of at least 8 characters, confirmation, live password checks, optional phone/area, and duplicate-email/connection errors. Success appears only after backend confirmation. Email format validation does not verify email ownership; verification links are not implemented.

Administrator access depends on the database user's role. Development seed credentials, only when those records exist:

```text
Email: admin@waste.test
Password: Password123
```

Use private administrator credentials for deployment, not development seed accounts.

## 12. Features and implementation status

| Feature | Current behavior |
|---|---|
| Registration | Saves users through backend to PostgreSQL |
| Login | Backend authentication and token |
| Profile | Loads and updates supported user details |
| Admin report counts/list/details | Backend data, filters and pagination |
| Admin report status updates | Saved through backend |
| Admin progress overview | Calculated from backend summary counts |
| Collection schedules | Demo/local data with filters and tips |
| Resident report form | Demo/local flow |
| My reports and ratings | Demo/local flow |
| Schedule management | Local provider state |
| Announcements | Local application state |
| Sorting guide | Searchable local content |
| Settings | Light, dark, and system appearance |
| Appearance preference | Saved on the device |

A working database connection does not automatically connect demo screens to the database.

## 13. Test the project

Frontend, inside `frontend`:

```powershell
flutter pub get
flutter analyze
flutter test --concurrency=1
```

Individual checks:

```powershell
flutter test test/account_dashboard_test.dart
flutter test test/responsive_test.dart
```

When dependencies are already installed:

```powershell
flutter analyze --no-pub
flutter test --no-pub --concurrency=1
```

Backend, inside `backend`:

```powershell
npm.cmd ci
npm.cmd test
```

Database integration tests require a separate test database. In a separate terminal, inside `backend`:

```powershell
$env:NODE_ENV = "test"
$env:RUN_DB_TESTS = "1"
$env:DATABASE_URL = "postgresql://TEST_USER:TEST_PASSWORD@localhost:5432/TEST_DATABASE"
npm.cmd run migrate
npm.cmd test
```

Close that terminal afterward so the test settings are not reused for normal development.

## 14. Commit and push to GitHub

From the project root:

```powershell
git branch --show-current
git status
git diff
```

Confirm the branch is `ci/cd_workflow`. Review your changes and exclude secrets and generated builds. To stage all reviewed changes:

```powershell
git add .
git diff --cached
git commit -m "Improve frontend UI and interactions"
git fetch origin
git rebase origin/ci/cd_workflow
```

If conflicts occur, resolve the marked content, save files, then:

```powershell
git add PATH_TO_RESOLVED_FILE
git rebase --continue
```

To cancel a rebase:

```powershell
git rebase --abort
```

Rerun relevant checks after integrating changes, then:

```powershell
git push origin HEAD:ci/cd_workflow
```

Do not force-push to solve an ordinary rejected push.

## 15. GitHub CI workflow

```text
Push to ci/cd_workflow
├── Flutter: dependencies → analysis → tests → web build/artifact
├── Backend: temporary PostgreSQL → dependencies → migrations → tests
└── Native builds: Android debug · Windows · Linux · macOS
```

In GitHub: **Repository → Actions → Community Waste System CI → Latest run → Job output**.

The current workflow supports pushes to `ci/cd_workflow` and manual runs. It uses a temporary test database, not your teammate's real database. It uploads the web artifact; native jobs check builds without uploading installers. It does not deploy a live application.

After merging into another branch, the workflow's push trigger still names `ci/cd_workflow`. Update the trigger if you want pushes to that other branch to run CI.

## 16. Build distributable versions

From `frontend`, replace the example HTTPS API host with your deployed backend.

### Web

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://YOUR_BACKEND_HOST
```

Output: `frontend/build/web/`.

### Android APK

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_BACKEND_HOST
```

Output: `frontend/build/app/outputs/flutter-apk/app-release.apk`.

### Android App Bundle

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://YOUR_BACKEND_HOST
```

Output: `frontend/build/app/outputs/bundle/release/app-release.aab`. Configure your own Android release signing before publishing publicly.

### Windows

```powershell
flutter build windows --release --dart-define=API_BASE_URL=https://YOUR_BACKEND_HOST
```

Output: `frontend/build/windows/x64/runner/Release/`. Distribute the complete release folder or an installer containing it; the executable needs its accompanying files.

## 17. Deployment workflow

```text
Hosted PostgreSQL → Transfer existing data if needed
→ Deploy backend with environment settings → Apply migrations
→ Check /api/health → Build frontend using HTTPS API URL
→ Publish frontend → Test accounts, profiles, and admin reports
```

Provide a hosted database, public HTTPS backend, backend secrets, backups, private administrator credentials, and persistent storage for report uploads. Transfer existing database records through backup/restore; pushing code does not transfer data.

For an initial deployment, the backend can run as a Render Node web service with root directory `backend`, build command `npm ci`, and start command `npm run migrate && npm start`. Set `DATABASE_URL`, `JWT_SECRET`, `JWT_EXPIRES_IN`, and `NODE_ENV=production` on the host. If using Render PostgreSQL, use its internal URL with the backend in the same region/workspace. Confirm current hosting plan limits before selecting a service.

Build the frontend with the resulting HTTPS backend URL, then publish the generated `frontend/build/web` files to a static host. The existing GitHub web artifact is built without an explicit deployed API URL; configure the build argument before using it as your deployed frontend.

## 18. Troubleshooting

| Error | Action |
|---|---|
| No pubspec.yaml | Run Flutter commands inside `frontend` |
| Missing script: seed | Run npm commands inside `backend` |
| npm.ps1 blocked | Use `npm.cmd` |
| backend/backend missing | You are already in `backend` |
| PostgreSQL connection refused | Check database service, host, port, access rules, firewall |
| Account creation timeout | Check API health from the app's device |
| origin missing | Check `git remote -v` and configure the correct remote |
| Push rejected | Fetch and integrate remote commits |
| Android tools missing | Install command-line tools using SDK Manager |
| Windows toolchain missing | Install Visual Studio's C++ workload |
| Symlink support required | Enable Windows Developer Mode |
| Disk full | Free disk space and clear generated Flutter files |
| Build file locked | Stop Flutter/debug sessions; restart if necessary |

Stop Flutter before cleaning generated files. Inside `frontend`:

```powershell
flutter clean
flutter pub get
```

Check the backend computer's current IPv4 address on that computer:

```powershell
ipconfig
```

Check API availability:

```powershell
Invoke-RestMethod "http://192.168.254.127:3000/api/health"
```

## 19. Daily workflow

```text
Check branch and changes → Integrate remote work when appropriate
→ Start/confirm PostgreSQL → Start backend → Check health
→ Start frontend on chosen device → Make and review changes
→ Analyze and test → Commit → Push → Check GitHub Actions
```

Stop a running backend or frontend with **Ctrl+C**.

## Related guides

- [Quick start](QUICK_START.md)
- [Full project guide](PROJECT_GUIDE.md)
