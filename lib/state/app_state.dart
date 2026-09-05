import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/mock_data.dart';
import '../i18n/strings.dart';
import '../models/models.dart';

/// Single source of truth for the whole prototype.
///
/// Deliberately plain: a [ChangeNotifier] surfaced through an
/// [InheritedNotifier] ([AppScope]). No external state-management package.
class AppState extends ChangeNotifier {
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
  }

  void removeFavourite(String id) {
    _favourites.removeWhere((FrequentJourney j) => j.id == id);
    notifyListeners();
  }

  // --- Favourite routes (from the tracking screen) ---------------------
  final Set<String> _favouriteRoutes = <String>{};
  bool isFavouriteRoute(String number) => _favouriteRoutes.contains(number);
  void toggleFavouriteRoute(String number) {
    if (!_favouriteRoutes.add(number)) {
      _favouriteRoutes.remove(number);
    }
    notifyListeners();
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
    return ticket;
  }

  // --- Journey planner (driven from AppState so tab + deep links share it) --
  String plannerFrom = 'Mira Road Station (E)';
  String plannerTo = 'Thane Station';
  String plannerWhen = 'Now';
  bool plannerShowResults = false;

  void setPlanner({String? from, String? to, String? when, bool? showResults}) {
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
    plannerShowResults = false;
    notifyListeners();
  }

  /// Deep-link into the Journey tab with a from/to pre-filled.
  void openPlanner(String from, String to, {bool auto = true}) {
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
    to: 'Thane Station',
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
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
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
