import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';

/// Bottom-sheet stop picker with a live filter. Returns the chosen stop name.
Future<String?> pickStop(BuildContext context, {required String title, String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (BuildContext ctx) => _StopPickerSheet(title: title, current: current),
  );
}

class _StopPickerSheet extends StatefulWidget {
  const _StopPickerSheet({required this.title, this.current});
  final String title;
  final String? current;

  @override
  State<_StopPickerSheet> createState() => _StopPickerSheetState();
}

class _StopPickerSheetState extends State<_StopPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final List<String> stops = MockData.stops
        .where((String s) => s.toLowerCase().contains(_q.toLowerCase()))
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
                  hintText: 'Search stops',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: stops.length,
                itemBuilder: (BuildContext context, int i) {
                  final String stop = stops[i];
                  final bool sel = stop == widget.current;
                  return ListTile(
                    leading: Icon(
                      sel ? Icons.radio_button_checked_rounded : Icons.location_on_outlined,
                      color: sel ? AppColors.brand : AppColors.muted,
                    ),
                    title: Text(stop, style: const TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () => Navigator.pop(context, stop),
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
