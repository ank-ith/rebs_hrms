# REBS HRMS — Flutter Assignment

An offline-capable employee workspace built with Flutter for the REBS HRMS platform.

---

## Architecture

```
Presentation (BLoC) ──► Domain (Repository Abstracts) ──► Data (API + Hive)
```

| Layer | Responsibility |
|---|---|
| **Presentation** | Widgets, Screens, BLoC (events/states) |
| **Domain** | Abstract repository interfaces |
| **Data** | Hive local datasources, Dio API services, Repository implementations |
| **Core** | Constants, DI wiring, LocationService, NetworkInfo, Failures |

**State Management:** `flutter_bloc` — chosen for explicit sealed states (Loading / Loaded / Error / Offline), testability with `bloc_test`, and enforced separation between UI and business logic.

**Persistence:** `hive_flutter` — fast embedded NoSQL store. Used for both cached server data and the pending event queue that survives app restarts.

**HTTP Client:** `dio` — interceptors, configurable timeouts per request, typed `DioException` for retry/timeout/409 handling.

---

## Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart     ← office coords, geofence, base URL
│   ├── errors/failures.dart             ← typed failure classes
│   ├── network/dio_client.dart          ← Dio factory
│   ├── network/network_info.dart        ← connectivity wrapper
│   └── services/location_service.dart  ← GPS + Haversine distance
├── data/
│   ├── local/                           ← Hive datasources
│   ├── models/                          ← Hive-annotated models + .g.dart adapters
│   ├── remote/                          ← Dio API services
│   └── repositories/                   ← Repository implementations
├── domain/
│   └── repositories/                   ← Abstract interfaces
├── presentation/
│   ├── bloc/dashboard/                 ← Dashboard BLoC
│   ├── bloc/attendance/                ← Attendance BLoC
│   ├── bloc/leave/                     ← Leave BLoC
│   ├── screens/                        ← Dashboard, Leave screens
│   └── widgets/                        ← Reusable UI components
mock_server/
└── bin/server.dart                      ← Dart Shelf mock HTTP API
```

---

## Setup & Running

### Prerequisites
- Flutter SDK ≥ 3.0
- Dart SDK ≥ 3.0
- Android emulator or physical device

### 1. Start the Mock API Server

```bash
cd mock_server
dart pub get
dart run bin/server.dart
```

Server starts at **http://localhost:8080**

> On Android emulator, the app uses `10.0.2.2:8080` which maps to your host machine's localhost. No changes needed for the emulator.
> On a **physical device**, update `baseUrl` in `lib/core/constants/app_constants.dart` to your machine's LAN IP (e.g. `http://192.168.1.x:8080`).

### 2. Run the Flutter App

```bash
flutter pub get
flutter run
```

---

## Simulating Locations for Reviewers

**Method 1 — Android Emulator Extended Controls:**
1. Open emulator → `...` (Extended Controls) → Location
2. Set Latitude: `12.9716`, Longitude: `77.5946` (matches configured office)
3. Click "Set Location"

**Method 2 — Debug bypass flag (fastest for review):**
In `lib/core/constants/app_constants.dart`, `debugMockLocation` is already set to `true` — this skips the geofence check entirely so check-in works from any location.

```dart
static const bool debugMockLocation = true; // ← set false to test real geofence
```

---

## Mock API Scenario Switching

Switch scenarios by POSTing to `/scenario`:

```bash
# Normal (default)
curl -X POST http://localhost:8080/scenario \
  -H "Content-Type: application/json" \
  -d '{"scenario":"success"}'

# Slow — 3 second delay (test timeout handling)
curl -X POST http://localhost:8080/scenario \
  -H "Content-Type: application/json" \
  -d '{"scenario":"slow"}'

# Server error — 500 on every request
curl -X POST http://localhost:8080/scenario \
  -H "Content-Type: application/json" \
  -d '{"scenario":"error"}'

# Duplicate attendance conflict — 409 on POST /attendance/events
curl -X POST http://localhost:8080/scenario \
  -H "Content-Type: application/json" \
  -d '{"scenario":"conflict"}'

# Leave validation failure — 422 on POST /leave/requests
curl -X POST http://localhost:8080/scenario \
  -H "Content-Type: application/json" \
  -d '{"scenario":"leave_reject"}'
```

---

## Idempotency Strategy

Every check-in/check-out event is assigned a **UUID** (`event_id`) client-side before persisting locally. This UUID is included in every POST to the server.

- If the server has already processed an event with that UUID, it returns **409**.
- The client treats a 409 response on retry as **already synced** (not rejected).
- This means retrying a timed-out request is safe — no duplicate server records.

---

## What the Production Server Must Validate

Device-side checks improve UX but are not authoritative. A production server must independently verify:

| Check | Reason |
|---|---|
| Duplicate by `event_id` (idempotent key) | Client retries and duplicate taps |
| Office geo-fence (server-authoritative coords) | Client coordinates can be spoofed |
| Check-out ordering (check-in must precede check-out) | Client state can be manipulated |
| Company timezone / business hours | Device clock can be wrong |
| Authentication & authorization (JWT / session) | Out of scope here but essential in production |

---

## Offline Sync Architecture

```
Check-In / Check-Out tap
       │
       ▼
Persist to Hive pending queue (PendingSync)
       │
       ├── Online? ──► POST to server immediately
       │                    ├── 200/201 → mark Synced
       │                    ├── 409    → mark Synced (idempotent)
       │                    ├── Timeout → keep PendingSync (retry later)
       │                    └── Other  → mark Rejected
       │
       └── Offline? → stays PendingSync, survives app restart
                           │
                           ▼
                  Connectivity restored OR manual "Sync Now"
                           │
                           ▼
                  FIFO queue sync (check-in before check-out guaranteed)
```

---

## Completed Features

- [x] Employee Dashboard — name, ID, department, attendance status, leave balance, 5 recent records
- [x] All UI states — Loading, Loaded, Error, Offline (cached)
- [x] Check-In / Check-Out with Haversine geofencing (200m radius)
- [x] Location permission handling — denied, permanently denied (open settings dialog), unavailable
- [x] Duplicate prevention — once per day, check-out requires check-in
- [x] Offline event queue — Hive persistence survives app restart
- [x] Pending / Synced / Rejected status badge per event
- [x] Auto-sync on reconnect + manual "Sync Now" button with pending badge
- [x] FIFO sync ordering (check-in before check-out guaranteed)
- [x] Idempotent retry with UUID `event_id`
- [x] Timeout handling — events stay Pending, retry safely with same UUID
- [x] Leave Application with full client-side validation
- [x] Leave history viewable offline from cache
- [x] Server-side error propagation to UI
- [x] 5+ automated tests (attendance rules + leave validation + widget tests)
- [x] Mock API server with scenario switching

## Demo Recordings

The four recordings below demonstrate the main required flows:

- [Dashboard and online check-in](demo/Recording%202026-11-23%20182231.mp4)
- [Offline attendance action](demo/Recording%202026-11-23%20182911.mp4)
- [Restart and synchronization](demo/Recording%202026-11-23%20184546.mp4)
- [Leave validation and submission](demo/Recording%202026-11-23%20190405.mp4)

## Limitations / Trade-offs

- Hive `.g.dart` adapters are pre-generated (committed to repo) to skip the `build_runner` step for reviewers
- Background sync while app is fully terminated is out of scope (per assignment)
- Login / auth is out of scope (single pre-configured employee: EMP001)
- Weekend/holiday exclusion in leave day count not implemented (per assignment specification)
- The mock server runs locally by default; for physical-device review, expose port 8080 with ngrok and update `baseUrl` to the generated HTTPS URL.

---

## Time Spent

| Phase | Time |
|---|---|
| Setup + Mock Server | 1 hr |
| Data Layer (models, local, remote, repos) | 1.5 hr |
| Dashboard Screen + BLoC | 1 hr |
| Attendance + Geofence + BLoC | 2 hr |
| Offline Sync Engine | 0.5 hr |
| Leave Module + BLoC | 1 hr |
| Tests | 0.5 hr |
| README + Polish | 0.5 hr |
| **Total** | **8 hrs** |

---

## AI Tools Disclosure

Code scaffolding, boilerplate generation, and architectural guidance were assisted by **Antigravity (Google DeepMind AI)**. All logic, architecture decisions, idempotency/sync strategy, and business rules were reviewed and are fully understood. All code can be explained and modified independently.
