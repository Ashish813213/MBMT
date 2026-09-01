import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/journey_card.dart';
import '../widgets/pickers.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  Future<void> _add(BuildContext context, AppState s) async {
    String from = 'Home';
    String to = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setSheet) {
            Widget row(String label, String value, VoidCallback onTap) => InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text('$label  ',
                            style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w700)),
                        Expanded(
                          child: Text(value.isEmpty ? 'Choose stop' : value,
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: value.isEmpty ? AppColors.muted : AppColors.ink)),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
                      ],
                    ),
                  ),
                );

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('New favourite journey',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  row('FROM', from, () async {
                    final String? v = await pickStop(ctx, title: 'From', current: from);
                    if (v != null) setSheet(() => from = v);
                  }),
                  row('TO', to, () async {
                    final String? v = await pickStop(ctx, title: 'To', current: to);
                    if (v != null) setSheet(() => to = v);
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: to.isEmpty
                          ? null
                          : () {
                              s.addFavourite(from, to);
                              Navigator.pop(ctx);
                            },
                      child: const Text('Save journey'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<FrequentJourney> list = s.favourites;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Favourite Journeys')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, s),
        backgroundColor: AppColors.brand,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add journey'),
      ),
      body: list.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No favourite journeys yet.\nTap "Add journey" to save one for one-tap planning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.inkSoft, height: 1.5),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: <Widget>[
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < list.length; i++) ...<Widget>[
                        if (i != 0) const Divider(height: 1),
                        JourneyCard(
                          journey: list[i],
                          onOpen: () {
                            s.openPlanner(list[i].from, list[i].to);
                            Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
                          },
                          onRemove: () => s.removeFavourite(list[i].id),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
