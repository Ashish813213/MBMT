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
| **MBMT Assistant** | conversational trip planner (greets you, asks your destination, plans a real bus/transfer/walk/rickshaw itinerary), typed **or spoken** input (Whisper transcription), replies in your selected app language — see below |

### Demo flow

Home → search "Thane Station" → route options → select 45A → live tracking →
Buy Ticket → Payment → Active Ticket → View Journey.

---

## MBMT Assistant (optional, requires an OpenAI API key)

Tap the chat‑bubble button on Home, "MBMT Assistant" in Profile, or the drawer
entry. It greets you, asks where you're going, then **calls a real, deterministic
route planner** (`lib/services/trip_planner.dart` — plain Dart graph search over
`MockData`'s bus routes, no AI) via OpenAI function/tool calling, so every bus
number, stop and fare it talks about is real prototype data, never invented.
When no direct bus route is known it clearly labels an estimated auto‑rickshaw
leg instead of guessing. Voice input records with the device mic and transcribes
with OpenAI Whisper; replies are in whatever language is selected in
**Profile → Language**. The app works perfectly with **no key configured** — the
assistant screens just show a "not configured" notice and everything else in
the app is unaffected.

### ⚠️ About API keys — read this before running it

**Never put a real OpenAI API key in a chat message, a committed file, or
anywhere in git history.** A key typed into this project's source would be
public forever the moment it's pushed, since this repo is on GitHub. If a key
has ever been pasted somewhere like that, treat it as compromised and rotate
it at platform.openai.com immediately, key or no key involved here.

This project never hardcodes a key. It's read at **build time** via
`--dart-define`, which keeps it out of every committed file:

```bash
flutter run \
  --dart-define=OPENAI_API_KEY=sk-...your-key... \
  --dart-define=OPENAI_MODEL=gpt-4o-mini \
  --dart-define=OPENAI_TRANSCRIBE_MODEL=whisper-1
```

`OPENAI_MODEL` / `OPENAI_TRANSCRIBE_MODEL` are optional (the defaults above are
used if omitted) — override them if OpenAI has retired the default model by the
time you run this.

For convenience, copy `secrets.example.json` to **`secrets.local.json`**
(already git‑ignored — it will never be committed), fill in your key, then run:

```powershell
.\scripts\run_with_ai.ps1
```

which reads that file and passes the `--dart-define` flags for you.

**Even with `--dart-define`, a *built and distributed* APK still has the key
compiled into it** — decompiling an APK to extract a constant string is
trivial, so anyone you hand the APK to could extract and misuse your key. That
is an acceptable tradeoff for `flutter run`‑ing on your own machine for a
presentation; it is **not** safe for a key you'd mind someone else spending.
For anything beyond a demo, put the key behind your own backend that the app
calls instead of OpenAI directly.

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

- Mostly the **Flutter SDK alone** — Material 3, `ChangeNotifier` +
  `InheritedNotifier` for state, `Navigator` for routing, `CustomPainter` for
  the map and the QR‑style code.
- Three small packages power the *optional* AI assistant: `http` (talks to the
  OpenAI REST API directly, no SDK), `record` (microphone input) and
  `path_provider` (a temp path for recordings). Nothing else needs `pub get`
  to touch the network.
- The ticket QR is a deterministic **QR‑style** placeholder (`lib/widgets/qr_view.dart`).
  Swap in the `qr_flutter` package for a scannable code — a one‑line change in
  `ActiveTicketScreen`.

## Project layout

```
lib/
  main.dart, app.dart, nav.dart
  theme/app_theme.dart          MBMT blue+green visual language
  models/models.dart            Bus, RouteOption, Ticket, Pass, …
  models/trip_models.dart       TripLeg, TripItinerary (planner output)
  models/ai_chat_message.dart   chat turn model
  data/mock_data.dart           real stops / stations / routes / timetables
  data/ai_context.dart          OpenAI system prompts + the plan_trip tool schema
  i18n/strings.dart             en / hi / mr
  state/app_state.dart          single ChangeNotifier + AppScope
  services/ai_service.dart      raw OpenAI HTTP calls (chat + tool-calling + Whisper)
  services/trip_planner.dart    deterministic bus/transfer/walk route search (no AI)
  services/trip_agent.dart      wires ai_service + trip_planner together
  services/voice_input_service.dart  mic recording -> Whisper transcript
  widgets/                      Header, SearchBar, QuickAction, BusCard,
                                JourneyCard, ServiceUpdate, BottomNavigation,
                                TicketCard, RouteCard, StatusBadge, CrowdIndicator,
                                MiniMap, QrView, ItineraryCard, pickers, drawer, common
  screens/                      home, search, journey_planner, tracking, track_bus,
                                buy_ticket, payment, active_ticket, tickets,
                                service_updates, profile (+ sub‑screens),
                                accessibility, language, favourites, notifications,
                                ai_assistant
```
