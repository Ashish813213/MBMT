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
| Home dashboard | header (menu, location picker, notifications badge, avatar), smart search bar, 4 quick actions, **Buses Near You (real device GPS, falls back to sample data)**, Frequent Journeys, Service Update banner |
| Smart search | recent + suggested + typed results across destinations, stops, bus numbers, route numbers; mic affordance (simulated) |
| Journey planner | From / To pickers + swap, departure, **Fastest / Cheapest / Less Crowded** route cards with frequency, select → live tracking |
| Live tracking | real OpenStreetMap view (`flutter_map`, route line, stops, animated bus marker), ticking ETA & distance, next stop, **route timetable** (frequency, service hours, depot, next departures), stops timeline, **proximity travel alert**, travel actions, SOS, Buy Ticket |
| Tickets | Buy Ticket → Payment (UPI / Card / Net Banking, simulated) → **Active Ticket** with QR, plus Active / History / My Passes tabs |
| Service updates | filterable by Diversion / Delay / Cancellation / Information |
| Profile | tickets, passes, favourites, payment methods, notifications, language, accessibility, help, feedback, about, SOS |
| Accessibility | large text, high contrast, reduce motion, simple language, English / हिन्दी / मराठी — all applied app‑wide, live |
| **MBMT Assistant** | conversational trip planner (greets you, asks your destination, then returns a **Google-Maps-style mode picker — Bus, Auto-rickshaw, Walk, each with real time/fare**, and **can book a ticket** once you confirm), knows every real stop/area and route in the network, typed **or spoken** input (Whisper transcription), replies in your selected app language — see below |
| **Travel alert** | on the tracking screen, set "buzz me N stops before my stop" — fires a haptic + sound + dialog alert once the live-tracked bus gets that close |
| **Departure reminders** | set a daily "remind me N minutes before my 8:15 bus" reminder from Profile or the drawer — fires an in-app haptic + sound + dialog while the app is open (see note below on why this isn't an OS push notification) |
| **SOS** | real device GPS (with a saved-location fallback), current bus context, one tap to open a WhatsApp chat (to a saved emergency contact or a one-off number) with your location and bus pre-filled |
| **Persistence** | tickets, favourites, emergency contacts, departure reminders, recent searches and settings (language, accessibility) survive an app restart via on-device storage — no backend, no accounts |

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

`plan_trip` returns a **Google‑Maps‑style list of mode options** —
`TripPlanner.planModes()` — instead of one "best" pick: a direct or
one‑transfer **Bus** route when one exists, plus an **Auto‑rickshaw** and a
**Walk** estimate, each computed from the two stops' real collected GPS
coordinates (straight‑line distance via `lib/services/geo_utils.dart`) so a
300 m hop gets a walking suggestion and an 8 km one gets a rickshaw estimate,
not the same fixed guess either way. The chat renders these as tappable
chips (`TripModeSelector` in `lib/widgets/itinerary_card.dart`) so you can
compare and pick, exactly like a maps app's mode picker. Its system prompt
(`lib/data/ai_context.dart`) is grounded with every real route *and* every
real stop grouped by area, so it recognises place names even for stops that
never appear as a route's named origin/destination (e.g. "Maxus Mall",
"K.D. Empire").

Once a direct (no‑transfer) route is confirmed, it can also **book the ticket**
— a second tool call (`book_ticket`) that re‑derives the authoritative bus and
fare from the same route planner (never trusts the model's own numbers), then
issues a real ticket through the same `AppState.issueTicket` the manual Buy
Ticket flow uses. The chat shows a ticket confirmation card with a "View
Ticket" button straight to the QR code. Multi‑bus (transfer) trips and
rickshaw‑only estimates are explicitly *not* bookable — the assistant says so
rather than fabricating a ticket for a route that doesn't exist as one bus.

Voice input records with the device mic and transcribes with OpenAI Whisper;
replies are in whatever language is selected in **Profile → Language**. The
app works perfectly with **no key configured** — the assistant screens just
show a "not configured" notice and everything else in the app is unaffected.

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

## Departure reminders — why in‑app, not a push notification

A real "remind me before my bus" feature usually means an OS‑scheduled push
notification that fires even with the app closed. That needs
`flutter_local_notifications` plus the `timezone` package, an Android
notification channel, and — on Android 12+ — exact‑alarm permissions, and —
on Android 13+ — a runtime `POST_NOTIFICATIONS` permission prompt. All of
that is genuinely version‑dependent in ways that can't be verified without
running a real build, which this environment couldn't do.

So `AppState.startReminderClock()` instead checks every enabled reminder on
a 20‑second foreground timer and fires the same haptic + sound + dialog
pattern already proven on the live‑tracking travel alert. The reminder's
configuration (bus, stop, time, lead minutes) is persisted and survives a
restart; the *alert* only fires while the app is open. If you later build
this for real, swapping in `flutter_local_notifications` for
`AppState._checkReminders`'s alert step is the natural upgrade.

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

- Core app: **Flutter SDK** — Material 3, `ChangeNotifier` + `InheritedNotifier`
  for state, `Navigator` for routing, `CustomPainter` for the QR‑style code.
- Live tracking's map: `flutter_map` + `latlong2` (a native, Leaflet‑style
  widget rendering OpenStreetMap tiles — no JS, no WebView).
- The *optional* AI assistant: `http` (talks to the OpenAI REST API directly,
  no SDK), `record` (microphone input), `path_provider` (a temp path for
  recordings).
- SOS + Home's real "Buses Near You": `geolocator` (real device GPS, with a
  graceful permission‑denied fallback) and, for SOS, `url_launcher` (opens a
  `wa.me` WhatsApp chat with the SOS message pre‑filled).
- Persistence: `shared_preferences` (on‑device key/value storage for
  tickets, favourites, contacts, reminders and settings — see
  `lib/services/storage_service.dart`).
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
  models/travel_alert.dart      "N stops before my stop" alert config
  models/emergency_contact.dart SOS saved-contact model
  models/departure_reminder.dart "remind me before my bus" config
  data/mock_data.dart           real stops / stations / routes / timetables
  data/bus_stops.dart           89 real MBMT stops (name, lat/lng, area, routes)
  data/real_routes.dart         32 real MBMT bus routes
  data/ai_context.dart          OpenAI system prompts + plan_trip/book_ticket tool schemas
  i18n/strings.dart             en / hi / mr
  state/app_state.dart          single ChangeNotifier + AppScope (+ persistence, reminder clock)
  services/ai_service.dart      raw OpenAI HTTP calls (chat + tool-calling + Whisper)
  services/trip_planner.dart    deterministic bus/transfer/walk/rickshaw route search (no AI)
  services/trip_agent.dart      wires ai_service + trip_planner (+ booking) together
  services/voice_input_service.dart  mic recording -> Whisper transcript
  services/location_service.dart     geolocator wrapper (SOS + real "Buses Near You")
  services/sos_service.dart          SOS message text + wa.me WhatsApp handoff
  services/storage_service.dart      shared_preferences wrapper (on-device persistence)
  services/geo_utils.dart            shared Haversine distance helper
  widgets/                      Header, SearchBar, QuickAction, BusCard,
                                JourneyCard, ServiceUpdate, BottomNavigation,
                                TicketCard, RouteCard, StatusBadge, CrowdIndicator,
                                RealMap, QrView, ItineraryCard (+ TripModeSelector),
                                pickers, drawer, common
  screens/                      home, search, journey_planner, tracking, track_bus,
                                buy_ticket, payment, active_ticket, tickets,
                                service_updates, profile (+ sub‑screens),
                                accessibility, language, favourites, notifications,
                                ai_assistant, travel_alert, sos, departure_reminders
```
