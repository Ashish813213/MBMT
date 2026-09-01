import 'package:flutter/material.dart';

import '../nav.dart';
import '../screens/search_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// The most prominent element on the home screen. Tapping it opens the full
/// search experience (recent + suggested + typed results). Supports
/// destinations, bus stops, bus numbers and route numbers, with a mic affordance.
class SmartSearchBar extends StatelessWidget {
  const SmartSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => pushPage(context, const SearchScreen()),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.brand.withOpacity(0.35), width: 1.4),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x141A4FBD), blurRadius: 18, offset: Offset(0, 6)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search_rounded, color: AppColors.brand),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.t('search_placeholder'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mic_none_rounded, size: 19, color: AppColors.brand),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
