import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'tracking_screen.dart';

/// Smart search: destinations, bus stops, bus numbers, route numbers.
/// The user never needs to know a route number to get a result.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  static const List<String> _examples = <String>[
    'Thane Station',
    'Mira Road Station',
    'Bhayandar',
    '45A',
    'Ghodbunder Road',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<SearchResult> get _results {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return const <SearchResult>[];

    final List<SearchResult> out = <SearchResult>[];

    for (final Bus b in MockData.nearbyBuses) {
      if (b.number.toLowerCase().contains(q)) {
        out.add(SearchResult(
          title: 'Bus ${b.number}',
          subtitle: 'To ${b.destination} · via ${b.via}',
          kind: SearchKind.bus,
        ));
      }
    }
    for (final SearchResult d in MockData.suggestedDestinations) {
      if (d.title.toLowerCase().contains(q)) out.add(d);
    }
    for (final String stop in MockData.stops) {
      final bool already = out.any((SearchResult r) => r.title.toLowerCase() == stop.toLowerCase());
      if (!already && stop.toLowerCase().contains(q)) {
        out.add(SearchResult(title: stop, subtitle: 'Bus stop', kind: SearchKind.stop));
      }
    }
    return out;
  }

  void _choose(BuildContext context, SearchResult r) {
    final AppState s = AppScope.of(context);
    s.addRecentSearch(r.kind == SearchKind.bus ? r.title.replaceFirst('Bus ', '') : r.title);

    if (r.kind == SearchKind.bus || r.kind == SearchKind.route) {
      final String number = r.title.replaceFirst('Bus ', '').trim();
      pushReplacementPage(context, TrackingScreen(busNumber: number));
    } else {
      s.openPlanner(s.originStop, r.title);
      Navigator.of(context).pop();
    }
  }

  void _chooseRaw(BuildContext context, String value) {
    final AppState s = AppScope.of(context);
    s.addRecentSearch(value);
    final List<Bus> matches = MockData.nearbyBuses
        .where((Bus b) => b.number.toLowerCase() == value.toLowerCase())
        .toList();
    if (matches.isNotEmpty) {
      pushReplacementPage(context, TrackingScreen(busNumber: matches.first.number));
    } else {
      s.openPlanner(s.originStop, value);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final List<SearchResult> results = _results;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Material(
          color: Colors.transparent,
          child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (String v) => setState(() => _query = v),
              onSubmitted: (String v) {
                if (v.trim().isNotEmpty) _chooseRaw(context, v.trim());
              },
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: s.t('search_placeholder'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.brand),
                suffixIcon: IconButton(
                  tooltip: 'Voice search (demo)',
                  icon: const Icon(Icons.mic_rounded, color: AppColors.brand),
                  onPressed: () {
                    _controller.text = 'Thane Station';
                    setState(() => _query = 'Thane Station');
                    showToast(context, 'Voice search is simulated in this prototype',
                        icon: Icons.mic_rounded);
                  },
                ),
              ),
            ),
          ),
        ),
      body: results.isNotEmpty
          ? ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: results.length,
              separatorBuilder: (BuildContext _, int __) => const Divider(height: 1, indent: 60),
              itemBuilder: (BuildContext context, int i) => _ResultTile(
                result: results[i],
                onTap: () => _choose(context, results[i]),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                _Header('Try'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _examples
                      .map((String e) => ActionChip(
                            label: Text(e),
                            onPressed: () => _chooseRaw(context, e),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                if (s.recentSearches.isNotEmpty) ...<Widget>[
                  Row(
                    children: <Widget>[
                      _Header('Recent searches'),
                      const Spacer(),
                      TextButton(
                        onPressed: s.clearRecentSearches,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  ...s.recentSearches.map(
                    (String q) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history_rounded, color: AppColors.muted),
                      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                      trailing: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.muted),
                      onTap: () => _chooseRaw(context, q),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _Header('Suggested destinations'),
                ...MockData.suggestedDestinations.map(
                  (SearchResult d) => _ResultTile(
                    result: d,
                    onTap: () => _choose(context, d),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 2),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.6)),
      );
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.onTap});
  final SearchResult result;
  final VoidCallback onTap;

  IconData get _icon {
    switch (result.kind) {
      case SearchKind.bus:
      case SearchKind.route:
        return Icons.directions_bus_rounded;
      case SearchKind.stop:
        return Icons.signpost_rounded;
      case SearchKind.destination:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(12)),
        child: Icon(_icon, color: AppColors.brand, size: 20),
      ),
      title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
      subtitle: Text(result.subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}

