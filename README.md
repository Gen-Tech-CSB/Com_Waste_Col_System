# Community Waste Collection System

Flutter client with an Express/PostgreSQL API.

## Backend

Create `backend/.env` with DATABASE_URL, JWT_SECRET, JWT_EXPIRES_IN (for example 1d), and optionally PORT (default 3000). Use a long random JWT secret.

From backend: run `npm ci`, `npm run migrate`, optionally `npm run seed`, then `npm start`.
Run backend checks with `npm test`.

## Web, Android and desktop

From frontend, run `flutter pub get` and use:

- Web: `flutter run -d chrome`
- Android emulator: `flutter run -d <device-id>` (see `flutter devices`)
- Windows: `flutter run -d windows`
- Linux: `flutter run -d linux`
- macOS: `flutter run -d macos`

Build with `flutter build web`, `flutter build apk`, `flutter build windows`, `flutter build linux`, or `flutter build macos`. Desktop builds require their matching operating system and native build tools. Android requires the Android SDK and Java; macOS requires Xcode.

The API defaults to localhost:3000 on web/desktop and 10.0.2.2:3000 on Android emulators. For physical devices, use a reachable computer address, for example:

`flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000`

API_BASE_URL is the origin only, without /api. Release deployment should use an HTTPS origin. Android permits local HTTP in debug/profile builds only. An HTTPS web page also needs an HTTPS backend.

Run `flutter analyze` and `flutter test` before building. CI checks the frontend from its own directory and builds web, Android (debug APK), Windows, Linux and macOS.

## Accounts and admin dashboard

Account creation now calls POST /api/auth/register and inserts a resident into PostgreSQL. Passwords are hashed on the backend. Duplicate emails and invalid fields are shown in the form; a failed request never shows a success message. Barangay/purok choices come from GET /api/areas; choosing an area is optional.

Sign-in now uses POST /api/auth/login. The old frontend demo credentials no longer bypass authentication. Use an existing database account or create a resident through the registration screen. Admin access requires a user with the admin role in the database; public registration cannot create admins. In a development database only, the existing seed script creates admin@waste.test with Password123. Do not seed demo credentials into a shared production database.

The admin dashboard reads report counts, paginated reports, report details and status changes from the API. A valid session is required. Tokens are kept in memory, cleared on logout/expiration, and reset when the app restarts or the browser reloads.

Keep both the backend and frontend running. backend/.env must point to your intended PostgreSQL database and define JWT_SECRET. Apply migrations to your development database before trying registration or the dashboard. No new migration is required for these changes.

## Tests

From frontend run flutter analyze and flutter test. These include account form, API error, session, responsive dashboard and navigation checks. From backend run npm.cmd test on Windows (npm test elsewhere). The database integration test is enabled by RUN_DB_TESTS=1 only against the disposable CI database, after migrations; it verifies registration, stored password hashes, duplicate-email rejection and login. Ordinary local tests skip that database integration test.

## Remaining demo features

Resident reports, schedules, feedback and announcements still include local/demo behavior. The admin dashboard displays reports already stored through the API; the resident report form is not yet connected. The backend connection widget checks API/database health using the shared API configuration.

## User profile

The resident workspace includes a Profile destination on phones and a My profile sidebar item on desktop/web. Admins can open their profile from the person icon in the admin toolbar. Profiles load through GET /api/auth/me and save through PATCH /api/auth/me.

Users can update their full name, phone and collection area. Email and role are displayed as account details. Updates require a valid session and are limited to that session's user. The backend rejects attempts to change a role, email or another user's ID through this endpoint. No new database migration is needed.

Deploy the updated backend routes, controller and user model together with the frontend. If the backend runs on a teammate's computer, that teammate must update and restart it for profile saving to work.

## Settings and appearance

Tap the profile avatar in the resident header to open My profile. Settings is available from the header gear, desktop sidebar, profile page, and admin header. Appearance offers Light mode, Dark mode, or Use device setting. The selected mode is saved locally with shared_preferences and restored on the same device/browser origin. System mode follows operating-system appearance changes. Account and authentication data are not stored in these preferences.

After pulling this update, run flutter pub get and fully restart the frontend so the new preferences plugin is registered.
