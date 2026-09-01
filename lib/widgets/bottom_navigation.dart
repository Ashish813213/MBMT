import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String key;
  const _NavItem(this.icon, this.activeIcon, this.key);
}

/// 5-tab bottom navigation: Home, Journey, Tickets, Track, Profile.
class MbmtBottomNav extends StatelessWidget {
  const MbmtBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'nav_home'),
    _NavItem(Icons.alt_route_outlined, Icons.alt_route_rounded, 'nav_journey'),
    _NavItem(Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, 'nav_tickets'),
    _NavItem(Icons.near_me_outlined, Icons.near_me_rounded, 'nav_track'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'nav_profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List<Widget>.generate(_items.length, (int i) {
              final _NavItem item = _items[i];
              final bool active = i == currentIndex;
              return Expanded(
                child: Semantics(
                  selected: active,
                  button: true,
                  label: s.t(item.key),
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: active ? AppColors.brandSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            active ? item.activeIcon : item.icon,
                            size: 23,
                            color: active ? AppColors.brand : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            s.t(item.key),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                              color: active ? AppColors.brand : AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
