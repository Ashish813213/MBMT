import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/crowd_indicator.dart';
import '../widgets/mini_map.dart';
import '../widgets/status_badge.dart';
import 'buy_ticket_screen.dart';

/// Live bus tracking. Map-style view, route line, stops timeline, next stop and
/// quick travel actions. ETA + position tick down while the screen is open.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key, required this.busNumber});

  final String busNumber;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final Bus _bus;
  late final double _initialEta;
  double _eta = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bus = MockData.busByNumber(widget.busNumber);
    _initialEta = _bus.etaMin.toDouble();
    _eta = _initialEta;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _eta = (_eta - 0.4).clamp(1.0, _initialEta));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress {
    final double done = (_initialEta - _eta) / _initialEta;
    return (0.06 + done * 0.88).clamp(0.0, 1.0);
  }

  int get _nextStopIndex {
    final int n = _bus.stops.length;
    return (_progress * (n - 1)).ceil().clamp(1, n - 1);
  }

  double get _distanceKm => (_bus.distanceKm * (_eta / _initialEta)).clamp(0.1, _bus.distanceKm);

  /// Upcoming scheduled departures from the route origin, spaced by the
  /// route headway and aligned to the next headway slot.
  List<String> _nextDepartures({int count = 3}) {
    final DateTime now = DateTime.now();
    final int h = _bus.headwayMin;
    final int toNext = h - (now.minute % h);
    final DateTime first = DateTime(now.year, now.month, now.day, now.hour, now.minute)
        .add(Duration(minutes: toNext));
    return List<String>.generate(count, (int i) {
      final DateTime t = first.add(Duration(minutes: i * h));
      final int hr = t.hour % 12 == 0 ? 12 : t.hour % 12;
      final String mm = t.minute.toString().padLeft(2, '0');
      return '$hr:$mm ${t.hour < 12 ? 'AM' : 'PM'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final bool fav = s.isFavouriteRoute(_bus.number);
    final int etaShown = _eta.round();
    final String nextStop = _bus.stops[_nextStopIndex];
    final bool animate = !MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: Text('Tracking ${_bus.number}'),
        actions: <Widget>[
          IconButton(
            tooltip: s.t('favourite_route'),
            onPressed: () {
              s.toggleFavouriteRoute(_bus.number);
              showToast(context,
                  fav ? 'Removed from favourite routes' : 'Added to favourite routes',
                  icon: Icons.star_rounded);
            },
            icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded,
                color: fav ? AppColors.warn : null),
          ),
          IconButton(
            tooltip: s.t('share_journey'),
            onPressed: () => showToast(context, 'Journey link copied - ready to share',
                icon: Icons.ios_share_rounded),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      bottomNavigationBar: _BuyTicketBar(bus: _bus),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_bus.destination,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                    const SizedBox(height: 2),
                    Text('Via ${_bus.via}  ·  Bus ${_bus.vehicleNo}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                  ],
                ),
              ),
              CrowdIndicator(_bus.crowd, compact: true),
            ],
          ),
          const SizedBox(height: 14),

          // --- status card ---------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: AppColors.liveSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.live.withOpacity(0.25)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                LiveDot(animate: animate),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Arriving in $etaShown min',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.live700)),
                      const SizedBox(height: 2),
                      Text('${_distanceKm.toStringAsFixed(1)} km away  ·  Next stop: $nextStop',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
                StatusBadge(_bus.status, dense: true),
              ],
            ),
          ),
          const SizedBox(height: 14),

          MiniMap(
            stopCount: _bus.stops.length,
            progress: _progress,
            userIndex: _nextStopIndex,
            animate: animate,
          ),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                const Icon(Icons.my_location_rounded, size: 16, color: AppColors.brand),
                const SizedBox(width: 8),
                Text('${s.t('next_stop')}: ',
                    style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                Expanded(
                  child: Text(nextStop,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.brandDark)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const SectionHeader(title: 'Route timetable'),
          AppCard(
            child: Column(
              children: <Widget>[
                InfoRow('Frequency', _bus.frequencyLabel),
                const Divider(height: 16),
                InfoRow('Service hours', _bus.serviceHoursLabel),
                const Divider(height: 16),
                InfoRow('Depot', _bus.depot),
                const Divider(height: 16),
                InfoRow('Scheduled run', '${_bus.runningTimeMin} min · ₹${_bus.fare}'),
                const Divider(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Next from ${_bus.origin}',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final String time in _nextDepartures())
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.brandSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(time,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brandDark)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const SectionHeader(title: 'Upcoming stops'),
          _StopsTimeline(stops: _bus.stops, nextIndex: _nextStopIndex),
          const SizedBox(height: 18),

          const SectionHeader(title: 'Travel actions'),
          _ActionsGrid(bus: _bus, fav: fav),
        ],
      ),
    );
  }
}

class _StopsTimeline extends StatelessWidget {
  const _StopsTimeline({required this.stops, required this.nextIndex});

  final List<String> stops;
  final int nextIndex;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Column(
        children: List<Widget>.generate(stops.length, (int i) {
          final bool passed = i <= nextIndex - 1;
          final bool isNext = i == nextIndex;
          final bool isLast = i == stops.length - 1;
          final Color railColor = passed ? AppColors.brand : AppColors.line;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: 14),
                      decoration: BoxDecoration(
                        color: passed
                            ? AppColors.brand
                            : isNext
                                ? Colors.white
                                : AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isNext ? AppColors.brand : (passed ? AppColors.brand : AppColors.muted),
                          width: isNext ? 3 : 2,
                        ),
                      ),
                      child: passed
                          ? const Icon(Icons.check_rounded, size: 10, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2.5, color: railColor),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 11, bottom: isLast ? 11 : 18),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            stops[i],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                              color: passed ? AppColors.inkSoft : AppColors.ink,
                            ),
                          ),
                        ),
                        if (isNext)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('Next stop',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          )
                        else if (i == 0)
                          const Text('Start',
                              style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700))
                        else if (isLast)
                          const Text('Destination',
                              style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  const _ActionsGrid({required this.bus, required this.fav});
  final Bus bus;
  final bool fav;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    Widget btn(IconData icon, String label, VoidCallback onTap, {bool active = false}) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          alignment: Alignment.centerLeft,
          side: BorderSide(color: active ? AppColors.warn : AppColors.line),
          backgroundColor: active ? AppColors.warnSoft : Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: active ? AppColors.warn : AppColors.brand),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: btn(Icons.directions_walk_rounded, s.t('get_directions'),
                  () => showToast(context, 'Opening walking directions to the stop',
                      icon: Icons.directions_walk_rounded)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: btn(
                fav ? Icons.star_rounded : Icons.star_border_rounded,
                s.t('favourite_route'),
                () {
                  s.toggleFavouriteRoute(bus.number);
                  showToast(context, fav ? 'Removed favourite route' : 'Saved favourite route',
                      icon: Icons.star_rounded);
                },
                active: fav,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: btn(Icons.ios_share_rounded, s.t('share_journey'),
                  () => showToast(context, 'Journey link copied - ready to share',
                      icon: Icons.ios_share_rounded)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: btn(Icons.notifications_active_rounded, s.t('set_travel_alert'),
                  () => showToast(context,
                      'Alert set - we will notify you when Bus ${bus.number} is 5 min away',
                      icon: Icons.notifications_active_rounded)),
            ),
          ],
        ),
      ],
    );
  }
}

class _BuyTicketBar extends StatelessWidget {
  const _BuyTicketBar({required this.bus});
  final Bus bus;

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: () {
            s.setTicketDraft(TicketDraft(
              from: s.originStop,
              to: bus.destination,
              route: bus.number,
              fare: bus.fare,
              vehicleNo: bus.vehicleNo,
            ));
            pushPage(context, const BuyTicketScreen());
          },
          icon: const Icon(Icons.confirmation_number_rounded),
          label: Text('${s.t('buy_ticket')}  ·  \u{20B9}${bus.fare}'),
        ),
      ),
    );
  }
}
