import 'package:flutter/material.dart';

import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'language_screen.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          Text(
            'Make MBMT comfortable to use. These settings apply across the whole app '
            'and are designed to help first-time and elderly travellers.',
            style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.45),
          ),
          const SizedBox(height: 16),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              children: <Widget>[
                _Toggle(
                  icon: Icons.format_size_rounded,
                  title: 'Large text',
                  subtitle: 'Increase text size everywhere',
                  value: s.largeText,
                  onChanged: (bool v) => s.updateSetting(largeText: v),
                ),
                const Divider(height: 1),
                _Toggle(
                  icon: Icons.contrast_rounded,
                  title: 'High contrast',
                  subtitle: 'Stronger colours and borders',
                  value: s.highContrast,
                  onChanged: (bool v) => s.updateSetting(highContrast: v),
                ),
                const Divider(height: 1),
                _Toggle(
                  icon: Icons.motion_photos_off_rounded,
                  title: 'Reduce motion',
                  subtitle: 'Minimise animations and movement',
                  value: s.reduceMotion,
                  onChanged: (bool v) => s.updateSetting(reduceMotion: v),
                ),
                const Divider(height: 1),
                _Toggle(
                  icon: Icons.spellcheck_rounded,
                  title: 'Simple language',
                  subtitle: 'Shorter, plainer wording',
                  value: s.simpleLanguage,
                  onChanged: (bool v) => s.updateSetting(simpleLanguage: v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          AppCard(
            child: NavRow(
              icon: Icons.translate_rounded,
              title: 'Language',
              subtitle: 'English · हिन्दी · मराठी',
              onTap: () => pushPage(context, const LanguageScreen()),
            ),
          ),
          const SizedBox(height: 16),

          const SectionHeader(title: 'Preview'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.t('buses_near_you'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  s.simpleLanguage
                      ? 'Bus 45A to Thane Station. Comes in 6 minutes. Ticket 25 rupees.'
                      : 'Bus 45A towards Thane Station arrives in 6 min · Fare ₹25 · Medium crowd.',
                  style: const TextStyle(fontSize: 13.5, color: AppColors.inkSoft, height: 1.4),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: () {}, child: const Text('Sample button')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppCard(
            color: AppColors.brandSoft,
            borderColor: AppColors.brand,
            child: const Row(
              children: <Widget>[
                Icon(Icons.record_voice_over_rounded, color: AppColors.brand),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Screen-reader ready: every button, icon and status has a spoken '
                    'label for TalkBack and VoiceOver.',
                    style: TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      secondary: SoftIcon(icon, size: 40, iconSize: 20),
      title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      activeColor: AppColors.brand,
    );
  }
}
