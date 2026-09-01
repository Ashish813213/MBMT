import 'package:flutter/material.dart';

import '../models/models.dart';
import '../nav.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'active_ticket_screen.dart';

enum PayMethod { upi, card, netbanking }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PayMethod _method = PayMethod.upi;
  bool _processing = false;
  String _bank = 'HDFC Bank';

  Future<void> _pay(AppState s) async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final Ticket ticket = s.issueTicket(s.ticketDraft);
    setState(() => _processing = false);
    if (!mounted) return;
    pushAndReset(context, ActiveTicketScreen(ticket: ticket));
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final TicketDraft d = s.ticketDraft;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('Payment')),
      bottomNavigationBar: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SafeArea(
          top: false,
          child: FilledButton.icon(
            onPressed: _processing ? null : () => _pay(s),
            icon: _processing
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.lock_rounded, size: 18),
            label: Text(_processing ? 'Processing...' : '${s.t('pay_now')}  \u{20B9}${d.total}'),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: kScreenPad,
            children: <Widget>[
              AppCard(
                color: AppColors.brandSoft,
                borderColor: AppColors.brand,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${d.from} → ${d.to}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('Bus ${d.route} · ${d.count} Adult · ${d.date}',
                              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('\u{20B9}${d.total}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.brandDark)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SectionHeader(title: 'Pay using'),
              _MethodTile(
                selected: _method == PayMethod.upi,
                icon: Icons.account_balance_wallet_rounded,
                title: 'UPI',
                subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
                onTap: () => setState(() => _method = PayMethod.upi),
                child: const _UpiBody(),
              ),
              const SizedBox(height: 10),
              _MethodTile(
                selected: _method == PayMethod.card,
                icon: Icons.credit_card_rounded,
                title: 'Debit / Credit Card',
                subtitle: 'Visa, Mastercard, RuPay',
                onTap: () => setState(() => _method = PayMethod.card),
                child: const _CardBody(),
              ),
              const SizedBox(height: 10),
              _MethodTile(
                selected: _method == PayMethod.netbanking,
                icon: Icons.account_balance_rounded,
                title: 'Net Banking',
                subtitle: 'All major banks',
                onTap: () => setState(() => _method = PayMethod.netbanking),
                child: _NetBankingBody(
                  bank: _bank,
                  onBank: (String b) => setState(() => _bank = b),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Prototype checkout — no real payment is taken.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                  ),
                ],
              ),
            ],
          ),
          if (_processing)
            const Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(color: Color(0x14000000)),
              ),
            ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.line,
          width: selected ? 1.8 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Icon(icon, color: selected ? AppColors.brand : AppColors.inkSoft, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 1),
                        Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                  Icon(
                    selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    color: selected ? AppColors.brand : AppColors.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
            crossFadeState: selected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _UpiBody extends StatelessWidget {
  const _UpiBody();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(height: 1),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: 'ashish@okhdfc',
          decoration: const InputDecoration(
            labelText: 'UPI ID',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <Widget>[
            for (final String a in const <String>['GPay', 'PhonePe', 'Paytm', 'BHIM'])
              Chip(label: Text(a), visualDensity: VisualDensity.compact),
          ],
        ),
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(height: 1),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: '4242 4242 4242 4242',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Card number',
            prefixIcon: Icon(Icons.credit_card_rounded),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                initialValue: '08/28',
                decoration: const InputDecoration(labelText: 'Expiry'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '***',
                obscureText: true,
                decoration: const InputDecoration(labelText: 'CVV'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NetBankingBody extends StatelessWidget {
  const _NetBankingBody({required this.bank, required this.onBank});
  final String bank;
  final ValueChanged<String> onBank;

  @override
  Widget build(BuildContext context) {
    const List<String> banks = <String>[
      'HDFC Bank', 'State Bank of India', 'ICICI Bank', 'Axis Bank', 'Bank of Baroda', 'Kotak Mahindra Bank',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(height: 1),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: bank,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Select bank',
            prefixIcon: Icon(Icons.account_balance_rounded),
          ),
          items: banks
              .map((String b) => DropdownMenuItem<String>(value: b, child: Text(b)))
              .toList(),
          onChanged: (String? v) {
            if (v != null) onBank(v);
          },
        ),
      ],
    );
  }
}
