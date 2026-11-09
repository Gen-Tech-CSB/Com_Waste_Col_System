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

## Current functional limitations

Login uses the demo accounts defined in login_screen.dart. Registration, reports, schedules and announcements include local/demo behavior; they are not a complete connection to the backend. Added platform support does not make these features production-ready. The backend connection widget checks API/database health using the shared API configuration.
