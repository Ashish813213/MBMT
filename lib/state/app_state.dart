import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/departure_reminder.dart';
import '../models/emergency_contact.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Single source of truth for the whole prototype.
///
/// Deliberately plain: a [ChangeNotifier] surfaced through an
/// [InheritedNotifier] ([AppScope]). No external state-management package.
/// Tickets, favourites, emergency contacts, departure reminders and settings
/// are mirrored to on-device storage (see [loadPersisted] / [StorageService])
/// so a demo survives an app restart; everything still works, just reset to
/// sample defaults, if that load hasn't run yet or storage is unavailable.
class AppState extends ChangeNotifier {
  // --- Persistence keys -------------------------------------------------
  static const String _kLanguage = 'mbmt.language';
  static const String _kLargeText = 'mbmt.largeText';
  static const String _kHighContrast = 'mbmt.highContrast';
  static const String _kReduceMotion = 'mbmt.reduceMotion';
  static const String _kSimpleLanguage = 'mbmt.simpleLanguage';
  static const String _kPushAlerts = 'mbmt.pushAlerts';
  static const String _kServiceAlerts = 'mbmt.serviceAlerts';
  static const String _kFavourites = 'mbmt.favourites';
  static const String _kFavouriteRoutes = 'mbmt.favouriteRoutes';
  static const String _kTickets = 'mbmt.tickets';
  static const String _kRecentSearches = 'mbmt.recentSearches';
  static const String _kEmergencyContacts = 'mbmt.emergencyContacts';
  static const String _kDepartureReminders = 'mbmt.departureReminders';
  // --- Bottom navigation -----------------------------------------------------
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

  // --- Current location -----------------------------------------------------
  String _location = 'Mira Road (E), Thane';
  String get location => _location;
  set location(String value) {
    _location = value;
    notifyListeners();
  }

  /// The nearest MBMT boarding stop for the current location, used to pre-fill
  /// the "From" field. Maps e.g. "Mira Road (E), Thane" -> "Mira Road Station (E)".
  String get originStop {
    final String base = _location.split('(').first.split(',').first.trim();
    for (final String stop in MockData.stops) {
      if (stop.toLowerCase().startsWith(base.toLowerCase())) return stop;
    }
    return base.isEmpty ? _location : base;
  }

  // --- Settings ------------------------------------------------------------
  String _language = 'en'; // en | hi | mr
  String get language => _language;
  set language(String code) {
    _language = code;
    notifyListeners();
    unawaited(StorageService.instance.setString(_kLanguage, _language));
  }

  bool largeText = false;
  bool highContrast = false;
  bool reduceMotion = false;
  bool simpleLanguage = false;
  bool pushAlerts = true;
  bool serviceAlerts = true;

  void updateSetting({
    bool? largeText,
    bool? highContrast,
    bool? reduceMotion,
    bool? simpleLanguage,
    bool? pushAlerts,
    bool? serviceAlerts,
  }) {
    this.largeText = largeText ?? this.largeText;
    this.highContrast = highContrast ?? this.highContrast;
    this.reduceMotion = reduceMotion ?? this.reduceMotion;
    this.simpleLanguage = simpleLanguage ?? this.simpleLanguage;
    this.pushAlerts = pushAlerts ?? this.pushAlerts;
    this.serviceAlerts = serviceAlerts ?? this.serviceAlerts;
    notifyListeners();
    unawaited(_persistSettings());
  }

  Future<void> _persistSettings() async {
    final StorageService store = StorageService.instance;
    await store.setBool(_kLargeText, largeText);
    await store.setBool(_kHighContrast, highContrast);
    await store.setBool(_kReduceMotion, reduceMotion);
    await store.setBool(_kSimpleLanguage, simpleLanguage);
    await store.setBool(_kPushAlerts, pushAlerts);
    await store.setBool(_kServiceAlerts, serviceAlerts);
  }

  /// Translation helper. `t('view_all')`.
  String t(String key) => Strings.t(_language, key, simple: simpleLanguage);

  double get textScale => largeText ? 1.28 : 1.0;

  // --- Frequent / favourite journeys -------------------------------------
  final List<FrequentJourney> _favourites =
      List<FrequentJourney>.from(MockData.frequentJourneys);
  List<FrequentJourney> get favourites => List<FrequentJourney>.unmodifiable(_favourites);

  void addFavourite(String from, String to) {
    final String busNumber = MockData.busNumberForStops(from, to);
    _favourites.add(
      FrequentJourney(
        id: 'fj${DateTime.now().microsecondsSinceEpoch}',
        from: from,
        to: to,
        nextBusMin: 5 + Random().nextInt(20),
        busNumber: busNumber,
      ),
    );
    notifyListeners();
    unawaited(_persistFavourites());
  }

  void removeFavourite(String id) {
    _favourites.removeWhere((FrequentJourney j) => j.id == id);
    notifyListeners();
    unawaited(_persistFavourites());
  }

  Future<void> _persistFavourites() => StorageService.instance.setStringList(
        _kFavourites,
        _favourites.map((FrequentJourney j) => jsonEncode(j.toJson())).toList(),
      );

  // --- Favourite routes (from the tracking screen) ---------------------
  final Set<String> _favouriteRoutes = <String>{};
  bool isFavouriteRoute(String number) => _favouriteRoutes.contains(number);
  void toggleFavouriteRoute(String number) {
    if (!_favouriteRoutes.add(number)) {
      _favouriteRoutes.remove(number);
    }
    notifyListeners();
    unawaited(StorageService.instance.setStringList(_kFavouriteRoutes, _favouriteRoutes.toList()));
  }

  // --- Notifications ----------------------------------------------------
  final List<AppNotification> _notifications = MockData.notifications();
  List<AppNotification> get notifications =>
      List<AppNotification>.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((AppNotification n) => !n.read).length;

  void markAllNotificationsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    notifyListeners();
  }

  // --- Tickets --------------------------------------------------------
  final List<Ticket> _tickets = List<Ticket>.from(MockData.ticketHistory);
  List<Ticket> get tickets => List<Ticket>.unmodifiable(_tickets);
  List<Ticket> get activeTickets =>
      _tickets.where((Ticket t) => t.status == 'active').toList();
  List<Ticket> get pastTickets =>
      _tickets.where((Ticket t) => t.status != 'active').toList();

  Ticket issueTicket(TicketDraft draft) {
    final Random rng = Random();
    final String id = 'TKT${(rng.nextInt(900000) + 100000)}${(rng.nextInt(900) + 100)}';
    final DateTime now = DateTime.now();
    final Ticket ticket = Ticket(
      id: id,
      from: draft.from,
      to: draft.to,
      route: draft.route,
      fare: draft.total,
      date: _formatDate(now, relative: draft.date),
      time: _formatTime(now),
      status: 'active',
      passengers: '${draft.count} Adult',
      vehicleNo: draft.vehicleNo,
    );
    _tickets.insert(0, ticket);
    notifyListeners();
    unawaited(_persistTickets());
    return ticket;
  }

  Future<void> _persistTickets() => StorageService.instance.setStringList(
        _kTickets,
        _tickets.map((Ticket t) => jsonEncode(t.toJson())).toList(),
      );

  // --- Journey planner (driven from AppState so tab + deep links share it) --
  String plannerFrom = 'Mira Road Station (E)';
  String plannerTo = 'Thane Station (E) Kopri';
  String plannerWhen = 'Now';
  bool plannerShowResults = false;

  void setPlanner({String? from, String? to, String? when, bool? showResults}) {
    if (from != null || to != null) selectedRoute = null;
    plannerFrom = from ?? plannerFrom;
    plannerTo = to ?? plannerTo;
    plannerWhen = when ?? plannerWhen;
    plannerShowResults = showResults ?? plannerShowResults;
    notifyListeners();
  }

  void swapPlannerEnds() {
    final String t = plannerFrom;
    plannerFrom = plannerTo;
    plannerTo = t;
    selectedRoute = null;
    plannerShowResults = false;
    notifyListeners();
  }

  /// Deep-link into the Journey tab with a from/to pre-filled.
  void openPlanner(String from, String to, {bool auto = true}) {
    selectedRoute = null;
    plannerFrom = from;
    plannerTo = to;
    plannerShowResults = auto;
    setTab(1);
    notifyListeners();
  }

  RouteOption? selectedRoute;
  void selectRoute(RouteOption route) {
    selectedRoute = route;
    notifyListeners();
  }

  // --- Tickets tab segment (0 active, 1 history, 2 passes) -----------------
  int ticketsSegment = 0;
  void openTickets(int segment) {
    ticketsSegment = segment;
    _tabIndex = 2;
    notifyListeners();
  }

  void setTicketsSegment(int segment) {
    ticketsSegment = segment;
    notifyListeners();
  }

  // --- Ticket draft ----------------------------------------------
  TicketDraft ticketDraft = const TicketDraft(
    from: 'Mira Road Station (E)',
    to: 'Thane Station (E) Kopri',
  );
  void setTicketDraft(TicketDraft draft) {
    ticketDraft = draft;
    notifyListeners();
  }

  // --- Recent searches -----------------------------------------
  final List<String> _recentSearches = List<String>.from(MockData.recentSearches);
  List<String> get recentSearches => List<String>.unmodifiable(_recentSearches);
  void addRecentSearch(String query) {
    final String q = query.trim();
    if (q.isEmpty) return;
    _recentSearches
      ..removeWhere((String s) => s.toLowerCase() == q.toLowerCase())
      ..insert(0, q);
    if (_recentSearches.length > 6) {
      _recentSearches.removeRange(6, _recentSearches.length);
    }
    notifyListeners();
    unawaited(StorageService.instance.setStringList(_kRecentSearches, _recentSearches));
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
    unawaited(StorageService.instance.setStringList(_kRecentSearches, _recentSearches));
  }

  // --- Emergency contacts (SOS screen) --------------------------
  final List<EmergencyContact> _emergencyContacts = <EmergencyContact>[];
  List<EmergencyContact> get emergencyContacts =>
      List<EmergencyContact>.unmodifiable(_emergencyContacts);

  void addEmergencyContact(String name, String phone) {
    _emergencyContacts.add(
      EmergencyContact(id: 'ec${DateTime.now().microsecondsSinceEpoch}', name: name, phone: phone),
    );
    notifyListeners();
    unawaited(_persistEmergencyContacts());
  }

  void removeEmergencyContact(String id) {
    _emergencyContacts.removeWhere((EmergencyContact c) => c.id == id);
    notifyListeners();
    unawaited(_persistEmergencyContacts());
  }

  Future<void> _persistEmergencyContacts() => StorageService.instance.setStringList(
        _kEmergencyContacts,
        _emergencyContacts.map((EmergencyContact c) => jsonEncode(c.toJson())).toList(),
      );

  // --- Departure reminders ("leave now for your bus") ---------------------
  //
  // Distinct from the live-tracking screen's TravelAlert (which fires while
  // riding, close to your stop): this fires `leadMinutes` before a daily
  // boarding time, so you don't miss the bus before you've even left. It is
  // an in-app reminder checked on a foreground timer, not an OS push
  // notification - see [startReminderClock] for why.
  final List<DepartureReminder> _departureReminders = <DepartureReminder>[];
  List<DepartureReminder> get departureReminders =>
      List<DepartureReminder>.unmodifiable(_departureReminders);

  void addDepartureReminder(DepartureReminder reminder) {
    _departureReminders.add(reminder);
    notifyListeners();
    unawaited(_persistDepartureReminders());
  }

  void removeDepartureReminder(String id) {
    _departureReminders.removeWhere((DepartureReminder r) => r.id == id);
    _firedToday.removeWhere((String key) => key.startsWith('$id|'));
    notifyListeners();
    unawaited(_persistDepartureReminders());
  }

  void setDepartureReminderEnabled(String id, bool enabled) {
    final int i = _departureReminders.indexWhere((DepartureReminder r) => r.id == id);
    if (i == -1) return;
    _departureReminders[i] = _departureReminders[i].copyWith(enabled: enabled);
    notifyListeners();
    unawaited(_persistDepartureReminders());
  }

  Future<void> _persistDepartureReminders() => StorageService.instance.setStringList(
        _kDepartureReminders,
        _departureReminders.map((DepartureReminder r) => jsonEncode(r.toJson())).toList(),
      );

  Timer? _reminderTimer;
  final Set<String> _firedToday = <String>{};
  DepartureReminder? _pendingReminderAlert;

  /// The reminder that just fired, if any - the UI shell shows an alert for
  /// it, then calls [acknowledgeReminderAlert].
  DepartureReminder? get pendingReminderAlert => _pendingReminderAlert;

  void acknowledgeReminderAlert() {
    _pendingReminderAlert = null;
  }

  /// Starts the foreground clock that checks departure reminders. Real OS
  /// push notifications (`flutter_local_notifications` + scheduled exact
  /// alarms) would fire even with the app closed, but that plugin's Android
  /// 12+ exact-alarm and Android 13+ POST_NOTIFICATIONS permission handling
  /// varies by OS version in ways that can't be verified without a real
  /// build here - so this prototype checks reminders every 20s while the app
  /// is open instead, using the same haptic+sound+dialog pattern already
  /// proven on the live tracking screen's travel alert.
  void startReminderClock() {
    _checkReminders();
    _reminderTimer ??= Timer.periodic(const Duration(seconds: 20), (_) => _checkReminders());
  }

  void _checkReminders() {
    final DateTime now = DateTime.now();
    final String todayKey = '${now.year}-${now.month}-${now.day}';

    for (final DepartureReminder r in _departureReminders) {
      if (!r.enabled) continue;
      final String firedKey = '${r.id}|$todayKey';
      if (_firedToday.contains(firedKey)) continue;

      final DateTime target = DateTime(now.year, now.month, now.day, r.hour, r.minute);
      final DateTime lead = target.subtract(Duration(minutes: r.leadMinutes));
      if (now.isBefore(lead) || now.isAfter(target)) continue;

      _firedToday.add(firedKey);
      _pendingReminderAlert = r;
      HapticFeedback.vibrate();
      SystemSound.play(SystemSoundType.alert);
      notifyListeners();
      return; // one alert at a time is enough
    }
  }

  // --- Load persisted state -----------------------------------------------

  /// Reads everything persisted by [StorageService] back into memory,
  /// overwriting the sample defaults this object was constructed with. Runs
  /// once, fired-and-forgotten from `_MbmtAppState.initState`, so the app
  /// renders instantly with sample data and then updates itself the moment
  /// real on-device data is available (usually a few ms later).
  Future<void> loadPersisted() async {
    final StorageService store = StorageService.instance;

    final String? lang = await store.getString(_kLanguage);
    if (lang != null) _language = lang;

    largeText = await store.getBool(_kLargeText) ?? largeText;
    highContrast = await store.getBool(_kHighContrast) ?? highContrast;
    reduceMotion = await store.getBool(_kReduceMotion) ?? reduceMotion;
    simpleLanguage = await store.getBool(_kSimpleLanguage) ?? simpleLanguage;
    pushAlerts = await store.getBool(_kPushAlerts) ?? pushAlerts;
    serviceAlerts = await store.getBool(_kServiceAlerts) ?? serviceAlerts;

    await _loadListIfPresent(_kFavourites, (List<String> raw) {
      _favourites
        ..clear()
        ..addAll(raw.map(
            (String r) => FrequentJourney.fromJson(jsonDecode(r) as Map<String, dynamic>)));
    });
    await _loadListIfPresent(_kTickets, (List<String> raw) {
      _tickets
        ..clear()
        ..addAll(raw.map((String r) => Ticket.fromJson(jsonDecode(r) as Map<String, dynamic>)));
    });
    await _loadListIfPresent(_kEmergencyContacts, (List<String> raw) {
      _emergencyContacts
        ..clear()
        ..addAll(raw.map(
            (String r) => EmergencyContact.fromJson(jsonDecode(r) as Map<String, dynamic>)));
    });
    await _loadListIfPresent(_kDepartureReminders, (List<String> raw) {
      _departureReminders
        ..clear()
        ..addAll(raw.map(
            (String r) => DepartureReminder.fromJson(jsonDecode(r) as Map<String, dynamic>)));
    });

    final List<String> routes = await store.getStringList(_kFavouriteRoutes);
    if (routes.isNotEmpty) {
      _favouriteRoutes
        ..clear()
        ..addAll(routes);
    }
    final List<String> recents = await store.getStringList(_kRecentSearches);
    if (recents.isNotEmpty) {
      _recentSearches
        ..clear()
        ..addAll(recents);
    }

    notifyListeners();
  }

  /// Replaces the in-memory sample list for [key] via [apply], but only when
  /// something was actually saved before - an absent key means "never
  /// persisted yet", so the sample data already in memory (from this
  /// object's field initialisers) is left as-is instead of being wiped to an
  /// empty list.
  Future<void> _loadListIfPresent(String key, void Function(List<String> raw) apply) async {
    final List<String> raw = await StorageService.instance.getStringList(key);
    if (raw.isEmpty) return;
    apply(raw);
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  // --- Formatting helpers -------------------------------------
  static String _formatDate(DateTime dt, {String relative = 'Today'}) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    DateTime target = dt;
    if (relative == 'Tomorrow') {
      target = dt.add(const Duration(days: 1));
    }
    final String label = relative == 'Now' ? 'Today' : relative;
    return '$label, ${target.day} ${months[target.month - 1]} ${target.year}';
  }

  static String _formatTime(DateTime dt) {
    final int h24 = dt.hour;
    final int h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final String mm = dt.minute.toString().padLeft(2, '0');
    final String ap = h24 < 12 ? 'AM' : 'PM';
    return '$h12:$mm $ap';
  }
}

/// Exposes [AppState] to the widget tree and rebuilds dependents on notify.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final AppScope? scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope.of() called with no AppScope in the tree.');
    }
    return scope.notifier!;
  }
}
