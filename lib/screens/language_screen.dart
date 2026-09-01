import 'package:flutter/material.dart';

import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const List<List<String>> _langs = <List<String>>[
    <String>['en', 'English', 'English'],
    <String>['hi', 'हिन्दी', 'Hindi'],
    <String>['mr', 'मराठी', 'Marathi'],
  ];

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < _langs.length; i++) ...<Widget>[
                  if (i != 0) const Divider(height: 1),
                  RadioListTile<String>(
                    value: _langs[i][0],
                    groupValue: s.language,
                    onChanged: (String? v) {
                      if (v != null) {
                        s.language = v;
                        showToast(context, 'Language updated', icon: Icons.translate_rounded);
                      }
                    },
                    activeColor: AppColors.brand,
                    title: Text(_langs[i][1],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    subtitle: Text(_langs[i][2], style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'In this prototype, the home dashboard, navigation and key actions are '
                  'translated. Full translation would cover every screen.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
