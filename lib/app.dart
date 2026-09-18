import 'dart:async';

import 'package:flutter/material.dart';

import 'models/departure_reminder.dart';
import 'screens/root_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

/// Root of the MBMT Smart Bus prototype.
///
/// Owns the single [AppState], rebuilds the [MaterialApp] when theme-affecting
/// settings change (high contrast, large text, language), and - on wide
/// screens / desktop preview - frames the app inside a phone shell.
class MbmtApp extends StatefulWidget {
  const MbmtApp({super.key});

  @override
  State<MbmtApp> createState() => _MbmtAppState();
}

class _MbmtAppState extends State<MbmtApp> {
  final AppState _state = AppState();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChanged);
    // Fire-and-forget: the app renders instantly with sample data, then
    // updates itself the moment persisted data (tickets, favourites, ...)
    // has loaded from disk.
    unawaited(_state.loadPersisted());
    // Deferred past the first frame so the departure-reminder clock's first
    // check (which can call notifyListeners() -> setState()) never runs
    // synchronously inside initState().
    WidgetsBinding.instance.addPostFrameCallback((_) => _state.startReminderClock());
  }

  void _onStateChanged() {
    setState(() {});
    final DepartureReminder? pending = _state.pendingReminderAlert;
    if (pending != null) {
      _state.acknowledgeReminderAlert();
      WidgetsBinding.instance.addPostFrameCallback((_) => _showReminderDialog(pending));
    }
  }

  void _showReminderDialog(DepartureReminder reminder) {
    final BuildContext? context = _navigatorKey.currentContext;
    if (context == null) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: const Icon(Icons.directions_bus_rounded, color: AppColors.brand, size: 32),
        title: const Text('Time to leave!'),
        content: Text(
          'Bus ${reminder.busNumber} from ${reminder.stopName} departs around '
          '${reminder.timeLabel} - about ${reminder.leadMinutes} min from now.',
        ),
        actions: <Widget>[
          FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'MBMT Smart Bus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(highContrast: _state.highContrast),
        home: const RootShell(),
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData mq = MediaQuery.of(context);
          final Widget scaled = MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(_state.textScale),
              disableAnimations: _state.reduceMotion,
            ),
            child: child ?? const SizedBox.shrink(),
          );
          return _PhoneFrame(child: scaled);
        },
      ),
    );
  }
}

/// On phones this is a no-op. On a wide window (desktop / web preview) it
/// centres the experience inside a realistic 390x844 device frame.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool wide = size.width > 520;
    if (!wide) return child;

    const double frameW = 390;
    const double frameH = 844;
    final double h = frameH + 24 > size.height ? size.height - 24 : frameH;

    return ColoredBox(
      color: const Color(0xFF0B1220),
      child: Center(
        child: Container(
          width: frameW + 24,
          height: h + 24,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(46),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x55000000), blurRadius: 40, spreadRadius: 4),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(frameW, h),
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              ),
              child: SizedBox(width: frameW, height: h, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
