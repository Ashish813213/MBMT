import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/departure_reminder.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pickers.dart';

/// "Remind me before my bus" - a list of daily departure reminders. Distinct
/// from the live-tracking screen's travel alert (which fires while riding,
/// close to your stop): this fires before you've even left. See
/// `AppState.startReminderClock` for why this is an in-app reminder rather
/// than an OS push notification.
class DepartureRemindersScreen extends StatelessWidget {
  const DepartureRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<DepartureReminder> reminders = s.departureReminders;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Departure Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'departure-reminder-fab',
        onPressed: () => _openAddFlow(context, s),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Add reminder'),
      ),
      body: reminders.isEmpty
          ? _EmptyState(onAdd: () => _openAddFlow(context, s))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Icon(Icons.info_outline_rounded, color: AppColors.brand, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Reminders fire while the app is open, on your device's local time - "
                          'they will not wake a fully closed app.',
                          style: TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final DepartureReminder r in reminders) ...<Widget>[
                  _ReminderCard(
                    reminder: r,
                    onToggle: (bool v) => s.setDepartureReminderEnabled(r.id, v),
                    onDelete: () {
                      s.removeDepartureReminder(r.id);
                      showToast(context, 'Reminder removed', icon: Icons.delete_outline_rounded);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Future<void> _openAddFlow(BuildContext context, AppState s) async {
    final List<Bus> buses = MockData.nearbyBuses;
    if (buses.isEmpty) return;

    final String? busNumber = await pickOption(
      context,
      title: 'Which bus?',
      options: buses.map((Bus b) => b.number).toList(),
    );
    if (busNumber == null || !context.mounted) return;

    final Bus bus = MockData.busByNumber(busNumber);
    final String? stopName = await pickOption(
      context,
      title: 'Boarding stop',
      options: bus.stops,
    );
    if (stopName == null || !context.mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Usual departure time',
    );
    if (time == null || !context.mounted) return;

    final String? leadChoice = await pickOption(
      context,
      title: 'Remind me how early?',
      options: const <String>['5 min before', '10 min before', '15 min before', '20 min before'],
    );
    if (leadChoice == null || !context.mounted) return;
    final int lead = int.parse(leadChoice.split(' ').first);

    s.addDepartureReminder(DepartureReminder(
      id: 'dr${DateTime.now().microsecondsSinceEpoch}',
      busNumber: bus.number,
      stopName: stopName,
      hour: time.hour,
      minute: time.minute,
      leadMinutes: lead,
    ));
    showToast(context, 'Reminder set for Bus ${bus.number}', icon: Icons.alarm_on_rounded);
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onToggle, required this.onDelete});

  final DepartureReminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          SoftIcon(
            Icons.alarm_rounded,
            size: 44,
            iconSize: 20,
            color: reminder.enabled ? AppColors.brand : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Bus ${reminder.busNumber} · ${reminder.timeLabel}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  'From ${reminder.stopName} · ${reminder.leadMinutes} min before',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: reminder.enabled,
            onChanged: onToggle,
            activeColor: AppColors.brand,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SoftIcon(Icons.alarm_add_rounded, size: 64, iconSize: 30),
            const SizedBox(height: 16),
            const Text('No departure reminders yet',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              "Set a daily reminder for your regular bus so you don't miss it before you've "
              'even left home.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_alarm_rounded, size: 18),
              label: const Text('Add your first reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
