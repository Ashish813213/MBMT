import 'package:flutter/material.dart';

import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// -------------------------------------------------------------------------
/// Payment methods
/// -------------------------------------------------------------------------
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          AppCard(
            child: Column(
              children: const <Widget>[
                _MethodRow(icon: Icons.account_balance_wallet_rounded, title: 'UPI', value: 'ashish@okhdfc'),
                Divider(height: 20),
                _MethodRow(icon: Icons.credit_card_rounded, title: 'HDFC Debit Card', value: '**** 4242'),
                Divider(height: 20),
                _MethodRow(icon: Icons.account_balance_rounded, title: 'Net Banking', value: 'HDFC Bank'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => showToast(context, 'Add payment method - prototype only',
                icon: Icons.add_card_rounded),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add payment method'),
          ),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SoftIcon(icon, size: 40, iconSize: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(value, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
            ],
          ),
        ),
        const Icon(Icons.check_circle_rounded, color: AppColors.live, size: 18),
      ],
    );
  }
}

/// -------------------------------------------------------------------------
/// Notification preferences
/// -------------------------------------------------------------------------
class NotificationPrefsScreen extends StatelessWidget {
  const NotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Column(
              children: <Widget>[
                SwitchListTile.adaptive(
                  value: s.pushAlerts,
                  onChanged: (bool v) => s.updateSetting(pushAlerts: v),
                  activeColor: AppColors.brand,
                  secondary: const SoftIcon(Icons.directions_bus_rounded, size: 40, iconSize: 20),
                  title: const Text('Bus arrival alerts', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Notify me when my bus is a few minutes away'),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  value: s.serviceAlerts,
                  onChanged: (bool v) => s.updateSetting(serviceAlerts: v),
                  activeColor: AppColors.brand,
                  secondary: const SoftIcon(Icons.campaign_rounded, color: AppColors.warn, size: 40, iconSize: 20),
                  title: const Text('Service updates', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Diversions, delays and cancellations on my routes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------------------------------------------------------------
/// Help & Support
/// -------------------------------------------------------------------------
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<List<String>> _faq = <List<String>>[
    <String>[
      'How do I show my ticket to the conductor?',
      'Open Tickets > Active, tap your ticket and show the QR code. The conductor scans it to validate your journey.',
    ],
    <String>[
      'Can I travel on a different bus with the same ticket?',
      'A ticket is valid for the route and date you selected. For a different route, buy a new ticket or use a pass.',
    ],
    <String>[
      'The bus ETA looks wrong. Why?',
      'ETAs use live vehicle positions and traffic. During diversions the estimate updates as the bus rejoins its route.',
    ],
    <String>[
      'How do passes work?',
      'A daily, weekly or monthly pass lets you travel any number of times on all MBMT routes until it expires.',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          AppCard(
            child: Column(
              children: <Widget>[
                NavRow(
                  icon: Icons.call_rounded,
                  title: 'Call MBMT helpline',
                  subtitle: '1800-000-0000 · 7 AM to 10 PM',
                  onTap: () => showToast(context, 'Dialling MBMT helpline (demo)', icon: Icons.call_rounded),
                ),
                const Divider(height: 1),
                NavRow(
                  icon: Icons.mail_rounded,
                  title: 'Email support',
                  subtitle: 'help@mbmt.example',
                  onTap: () => showToast(context, 'Opening email app (demo)', icon: Icons.mail_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Frequently asked'),
          ..._faq.map(
            (List<String> qa) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  title: Text(qa[0],
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(qa[1],
                          style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.45)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------------------------------------------------------------
/// Feedback
/// -------------------------------------------------------------------------
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 4;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Feedback')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          const Text('How is your experience with MBMT Smart Bus?',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (int i) {
              final bool on = i < _rating;
              return IconButton(
                onPressed: () => setState(() => _rating = i + 1),
                iconSize: 34,
                icon: Icon(on ? Icons.star_rounded : Icons.star_border_rounded,
                    color: on ? AppColors.warn : AppColors.muted),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tell us what worked well or what to improve...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              showToast(context, 'Thanks for your feedback!', icon: Icons.favorite_rounded);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Submit feedback'),
          ),
        ],
      ),
    );
  }
}

/// -------------------------------------------------------------------------
/// About MBMT
/// -------------------------------------------------------------------------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('About MBMT')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: <Color>[AppColors.brand, AppColors.brandDark]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('MBMT Smart Bus',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const Text('Version 1.0 · Concept prototype',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text('About Mira-Bhayandar Municipal Transport',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text(
                  'MBMT operates the public bus network across Mira Road, Bhayandar and '
                  'connecting corridors to Thane and Ghodbunder Road, carrying lakhs of '
                  'commuters, students and workers every week.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            color: AppColors.warnSoft,
            borderColor: AppColors.warn,
            child: const Text(
              'This app is a student redesign concept created for a project '
              'presentation. It is not an official MBMT product, uses sample data '
              'only, and does not claim any feature is currently available in a live '
              'MBMT app.',
              style: TextStyle(fontSize: 12.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
