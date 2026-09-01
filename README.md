# MBMT Smart Bus — Flutter Android app

A **proposed redesigned** app for **Mira‑Bhayandar Municipal Transport (MBMT)**, built
for a college / project presentation.

> This is a concept prototype. It is **not** an official MBMT product, all data
> shown is realistic **sample data**, and no feature is claimed to exist in any
> live MBMT app.

The code was written **without running the Flutter SDK** (no `flutter create`, no
`pub get`, no build on this machine). It is a complete, buildable project — you
just need a machine with the Flutter SDK to run it.

---

## Run it

```bash
cd mbmt
flutter pub get
flutter run            # on an attached Android device / emulator
```

Other targets also work (`flutter run -d chrome`, `-d windows`, …). On a wide
screen the UI is centred inside a phone frame for a realistic preview.

### If the Android build folder is incomplete for your toolchain

`android/` here is a minimal, modern (embedding v2, AGP 8.1 / Gradle 8.3) setup.
If your Flutter/Gradle versions need something different, regenerate the platform
folders **without touching `lib/` or `pubspec.yaml`**:

```bash
flutter create . --platforms=android
```

`flutter run` also generates `android/local.properties` and the Gradle wrapper jar
automatically on first launch.

---

## What's implemented

| Area | Screen(s) |
|---|---|
| Home dashboard | header (menu, location picker, notifications badge, avatar), smart search bar, 4 quick actions, Buses Near You, Frequent Journeys, Service Update banner |
| Smart search | recent + suggested + typed results across destinations, stops, bus numbers, route numbers; mic affordance (simulated) |
| Journey planner | From / To pickers + swap, departure, **Fastest / Cheapest / Less Crowded** route cards with frequency, select → live tracking |
| Live tracking | map‑style `CustomPainter` view (route line, stops, animated bus marker), ticking ETA & distance, next stop, **route timetable** (frequency, service hours, depot, next departures), stops timeline, travel actions, Buy Ticket |
| Tickets | Buy Ticket → Payment (UPI / Card / Net Banking, simulated) → **Active Ticket** with QR, plus Active / History / My Passes tabs |
| Service updates | filterable by Diversion / Delay / Cancellation / Information |
| Profile | tickets, passes, favourites, payment methods, notifications, language, accessibility, help, feedback, about |
| Accessibility | large text, high contrast, reduce motion, simple language, English / हिन्दी / मराठी — all applied app‑wide, live |

### Demo flow

Home → search "Thane Station" → route options → select 45A → live tracking →
Buy Ticket → Payment → Active Ticket → View Journey.

---

## Real Mira‑Bhayandar data

`lib/data/mock_data.dart` uses the **real geography** MBMT serves — Mira Road
Station (E/W), Bhayandar Station (E/W), Kashimira Junction, Golden Nest Circle,
150 Feet Road, Ghodbunder Road, Patlipada, Kapurbawdi, Thane Station, Dahisar
Check Naka, Uttan, Chowk, Maxus Mall, and more — with realistic route numbers
(45A, 20, 12, 1, 6, 7), headways, first/last bus times, fares and crowd levels.
These timetable values are **plausible samples**, not a published schedule.

---

## Tech

- **Flutter SDK only** — zero third‑party packages, so `flutter pub get` resolves
  offline. Material 3, `ChangeNotifier` + `InheritedNotifier` for state,
  `Navigator` for routing, `CustomPainter` for the map and the QR‑style code.
- The ticket QR is a deterministic **QR‑style** placeholder (`lib/widgets/qr_view.dart`).
  Swap in the `qr_flutter` package for a scannable code — a one‑line change in
  `ActiveTicketScreen`.

## Project layout

```
lib/
  main.dart, app.dart, nav.dart
  theme/app_theme.dart          MBMT blue+green visual language
  models/models.dart            Bus, RouteOption, Ticket, Pass, …
  data/mock_data.dart           real stops / stations / routes / timetables
  i18n/strings.dart             en / hi / mr
  state/app_state.dart          single ChangeNotifier + AppScope
  widgets/                      Header, SearchBar, QuickAction, BusCard,
                                JourneyCard, ServiceUpdate, BottomNavigation,
                                TicketCard, RouteCard, StatusBadge, CrowdIndicator,
                                MiniMap, QrView, pickers, drawer, common
  screens/                      home, search, journey_planner, tracking, track_bus,
                                buy_ticket, payment, active_ticket, tickets,
                                service_updates, profile (+ sub‑screens),
                                accessibility, language, favourites, notifications
```
