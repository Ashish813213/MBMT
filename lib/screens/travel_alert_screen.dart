import 'package:flutter/material.dart';

import '../models/travel_alert.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/pickers.dart';

/// Lets the user set (or remove) a proximity alert for the bus they're
/// tracking - e.g. "buzz me 2 stops before Thane Station". [onSave] and
/// [onRemove] mutate the tracking screen's state directly; this screen just
/// pops itself once one of them has been called.
class TravelAlertScreen extends StatefulWidget {
  const TravelAlertScreen({
    super.key,
    required this.busNumber,
    required this.stops,
    required this.onSave,
    required this.onRemove,
    this.initial,
  });

  final String busNumber;
  final List<String> stops;
  final TravelAlert? initial;
  final ValueChanged<TravelAlert> onSave;
  final VoidCallback onRemove;

  @override
  State<TravelAlertScreen> createState() => _TravelAlertScreenState();
}

class _TravelAlertScreenState extends State<TravelAlertScreen> {
  late String _targetStop;
  late int _stopsBefore;
  late bool _vibrate;
  late bool _sound;

  static const List<int> _stopChoices = <int>[1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _targetStop = widget.initial?.targetStopName ??
        (widget.stops.isNotEmpty ? widget.stops.last : '');
    _stopsBefore = widget.initial?.stopsBefore ?? 2;
    _vibrate = widget.initial?.vibrate ?? true;
    _sound = widget.initial?.sound ?? true;
  }

  // The origin stop can't sensibly be an alert target - there is nothing
  // "before" it on this route.
  List<String> get _selectableStops =>
      widget.stops.length > 1 ? widget.stops.sublist(1) : widget.stops;

  void _save() {
    widget.onSave(TravelAlert(
      targetStopName: _targetStop,
      stopsBefore: _stopsBefore,
      vibrate: _vibrate,
      sound: _sound,
    ));
    Navigator.of(context).pop();
  }

  void _remove() {
    widget.onRemove();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Travel Alert')),
      bottomNavigationBar: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SafeArea(
          top: false,
          child: Row(
            children: <Widget>[
              if (widget.initial != null) ...<Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _remove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    icon: const Icon(Icons.notifications_off_rounded, size: 18),
                    label: const Text('Remove'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: widget.initial != null ? 2 : 1,
                child: FilledButton.icon(
                  onPressed: _targetStop.isEmpty ? null : _save,
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: const Text('Save alert'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.notifications_active_rounded, color: AppColors.brand, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bus ${widget.busNumber} - get a heads-up before your stop so you never miss it.',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Alert me when approaching'),
          AppCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final String? picked = await pickOption(
                  context,
                  title: 'Choose your stop',
                  options: _selectableStops,
                  current: _targetStop,
                );
                if (picked != null) setState(() => _targetStop = picked);
              },
              child: Row(
                children: <Widget>[
                  const Icon(Icons.place_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _targetStop.isEmpty ? 'Choose your stop' : _targetStop,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'How many stops before'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _stopChoices.map((int n) {
              final bool selected = n == _stopsBefore;
              return ChoiceChip(
                label: Text('$n stop${n == 1 ? '' : 's'} early'),
                selected: selected,
                onSelected: (_) => setState(() => _stopsBefore = n),
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.inkSoft,
                ),
                selectedColor: AppColors.brand,
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Alert style'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              children: <Widget>[
                SwitchListTile.adaptive(
                  value: _vibrate,
                  onChanged: (bool v) => setState(() => _vibrate = v),
                  activeColor: AppColors.brand,
                  secondary: const SoftIcon(Icons.vibration_rounded, size: 40, iconSize: 20),
                  title: const Text('Vibrate', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: _sound,
                  onChanged: (bool v) => setState(() => _sound = v),
                  activeColor: AppColors.brand,
                  secondary: const SoftIcon(Icons.volume_up_rounded, size: 40, iconSize: 20),
                  title: const Text('Play sound', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
