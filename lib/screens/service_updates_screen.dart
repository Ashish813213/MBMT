import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/service_update_card.dart';

class ServiceUpdatesScreen extends StatefulWidget {
  const ServiceUpdatesScreen({super.key});

  @override
  State<ServiceUpdatesScreen> createState() => _ServiceUpdatesScreenState();
}

class _ServiceUpdatesScreenState extends State<ServiceUpdatesScreen> {
  // null = All
  UpdateType? _filter;

  static const List<UpdateType?> _tabs = <UpdateType?>[
    null,
    UpdateType.diversion,
    UpdateType.delay,
    UpdateType.cancellation,
    UpdateType.information,
  ];

  String _labelFor(UpdateType? t) => t == null ? 'All' : t.label;

  @override
  Widget build(BuildContext context) {
    final List<ServiceUpdate> updates = _filter == null
        ? MockData.serviceUpdates
        : MockData.serviceUpdates.where((ServiceUpdate u) => u.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Service Updates')),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _tabs.length,
              separatorBuilder: (BuildContext _, int __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int i) {
                final UpdateType? t = _tabs[i];
                final bool active = t == _filter;
                return ChoiceChip(
                  label: Text(_labelFor(t)),
                  selected: active,
                  onSelected: (_) => setState(() => _filter = t),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: active ? Colors.white : AppColors.inkSoft,
                  ),
                  selectedColor: AppColors.brand,
                  backgroundColor: AppColors.surface,
                  showCheckmark: false,
                );
              },
            ),
          ),
          Expanded(
            child: updates.isEmpty
                ? const Center(
                    child: Text('No updates in this category',
                        style: TextStyle(color: AppColors.inkSoft)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: updates.length,
                    separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int i) =>
                        ServiceUpdateCard(update: updates[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
