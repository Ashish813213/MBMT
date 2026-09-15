import 'package:flutter/material.dart';

import '../data/bus_stops.dart';
import '../theme/app_theme.dart';

/// Bottom-sheet stop picker over the collected stop table, grouped by area.
/// Outside-MBMC termini stay hidden unless the user opts in.
/// Returns the chosen stop name.
Future<String?> pickStop(BuildContext context,
    {required String title, String? current, bool includeOutside = false}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (BuildContext ctx) => _StopPickerSheet(
        title: title, current: current, includeOutside: includeOutside),
  );
}

class _StopPickerSheet extends StatefulWidget {
  const _StopPickerSheet(
      {required this.title, this.current, this.includeOutside = false});
  final String title;
  final String? current;
  final bool includeOutside;

  @override
  State<_StopPickerSheet> createState() => _StopPickerSheetState();
}

class _StopPickerSheetState extends State<_StopPickerSheet> {
  String _q = '';
  late bool _showOutside = widget.includeOutside;

  @override
  Widget build(BuildContext context) {
    final String q = _q.toLowerCase();
    final List<RealStop> stops = kRealStops
        .where((RealStop s) =>
            (s.isOutside ? _showOutside : true) &&
            (q.isEmpty ||
                s.name.toLowerCase().contains(q) ||
                s.area.toLowerCase().contains(q) ||
                s.buses.any((String b) => b.toLowerCase().contains(q))))
        .toList();
    final MediaQueryData mq = MediaQuery.of(context);
    final double insets = mq.viewInsets.bottom;
    final double raw = mq.size.height - insets - mq.padding.top - 24;
    final double maxH = raw < 240
        ? 240
        : raw > 560
            ? 560
            : raw;

    return Padding(
      padding: EdgeInsets.only(bottom: insets),
      child: SizedBox(
        height: maxH,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (String v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'Search stops, areas or bus numbers',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Thane / Borivali / Manori halts'),
                  selected: _showOutside,
                  onSelected: (bool v) => setState(() => _showOutside = v),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${stops.length} stops',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: stops.length,
                itemBuilder: (BuildContext context, int i) {
                  final RealStop stop = stops[i];
                  final bool sel = stop.name == widget.current;
                  return ListTile(
                    leading: Icon(
                      sel ? Icons.radio_button_checked_rounded : Icons.location_on_outlined,
                      color: sel ? AppColors.brand : AppColors.muted,
                    ),
                    title: Text(stop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${stop.area} · Buses ${stop.buses.join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: stop.isOutside
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warnSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('Outside',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.warn)),
                          )
                        : null,
                    onTap: () => Navigator.pop(context, stop.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple single-choice sheet. Returns the chosen value.
Future<String?> pickOption(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (BuildContext ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          for (final String o in options)
            ListTile(
              leading: Icon(
                o == current ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: o == current ? AppColors.brand : AppColors.muted,
              ),
              title: Text(o, style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx, o),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
