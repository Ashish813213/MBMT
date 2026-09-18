import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/emergency_contact.dart';
import '../nav.dart';
import '../services/location_service.dart';
import '../services/sos_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Emergency screen: fetches the device's real location, builds an SOS
/// message (with the current bus, if any), and hands it to WhatsApp via a
/// wa.me link - either to a one-off number or a saved emergency contact.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key, this.busNumber, this.destination});

  final String? busNumber;
  final String? destination;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  LocationResult? _location;
  bool _locating = true;
  bool _sendingQuick = false;
  String? _sendingContactId;

  final TextEditingController _quickPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _quickPhone.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locating = true);
    final LocationResult result = await LocationService.instance.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _location = result;
      _locating = false;
    });
  }

  String _buildMessage(AppState s) {
    return SosService.buildMessage(
      busNumber: widget.busNumber,
      destination: widget.destination,
      location: _location ?? const LocationResult(),
      fallbackLocationText: s.location,
    );
  }

  Future<void> _send(String phone, String message, {String? contactId}) async {
    final String trimmed = phone.trim();
    if (trimmed.isEmpty) {
      showToast(context, 'Enter a phone number first', icon: Icons.error_outline_rounded);
      return;
    }
    setState(() {
      contactId != null ? _sendingContactId = contactId : _sendingQuick = true;
    });
    final bool ok = await SosService.sendViaWhatsApp(phone: trimmed, message: message);
    if (!mounted) return;
    setState(() {
      _sendingContactId = null;
      _sendingQuick = false;
    });
    if (!ok) {
      showToast(context, 'Could not open WhatsApp - is it installed?',
          icon: Icons.error_outline_rounded);
    }
  }

  Future<void> _addContact(AppState s) async {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController phoneCtrl = TextEditingController();

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Add emergency contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'With country code, e.g. 91XXXXXXXXXX',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
      s.addEmergencyContact(nameCtrl.text.trim(), phoneCtrl.text.trim());
    }
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final String message = _buildMessage(s);
    final List<EmergencyContact> contacts = s.emergencyContacts;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: const Text('SOS')),
      body: ListView(
        padding: kScreenPad,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Share your live location and current bus with someone you trust, '
                    'straight to WhatsApp.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Your situation'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              children: <Widget>[
                if (widget.busNumber != null) ...<Widget>[
                  _InfoLine(
                    icon: Icons.directions_bus_rounded,
                    label: 'Current bus',
                    value: widget.destination == null
                        ? 'Bus ${widget.busNumber}'
                        : 'Bus ${widget.busNumber} towards ${widget.destination}',
                  ),
                  const Divider(height: 1),
                ],
                _LocationLine(
                  locating: _locating,
                  location: _location,
                  fallbackText: s.location,
                  onRefresh: _fetchLocation,
                  onOpenSettings: () => LocationService.instance.openAppSettings(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Expanded(child: SectionHeader(title: 'Message preview')),
              IconButton(
                tooltip: 'Copy message',
                icon: const Icon(Icons.copy_rounded, size: 19, color: AppColors.muted),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  showToast(context, 'Message copied', icon: Icons.copy_rounded);
                },
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(message,
                style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.45)),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Send now'),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _quickPhone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Phone number',
                      hintText: 'e.g. 91XXXXXXXXXX',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _sendingQuick ? null : () => _send(_quickPhone.text, message),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                  icon: _sendingQuick
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              const Expanded(child: SectionHeader(title: 'Saved contacts')),
              TextButton.icon(
                onPressed: () => _addContact(s),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (contacts.isEmpty)
            AppCard(
              child: Row(
                children: <Widget>[
                  const Icon(Icons.contacts_rounded, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No saved contacts yet. Add someone you trust for one-tap SOS.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                    ),
                  ),
                ],
              ),
            )
          else
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < contacts.length; i++) ...<Widget>[
                    if (i != 0) const Divider(height: 1),
                    _ContactRow(
                      contact: contacts[i],
                      sending: _sendingContactId == contacts[i].id,
                      onSend: () => _send(contacts[i].phone, message, contactId: contacts[i].id),
                      onRemove: () => s.removeEmergencyContact(contacts[i].id),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.brand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 1),
                Text(value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.locating,
    required this.location,
    required this.fallbackText,
    required this.onRefresh,
    required this.onOpenSettings,
  });

  final bool locating;
  final LocationResult? location;
  final String fallbackText;
  final VoidCallback onRefresh;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final bool found = location?.hasCoordinates ?? false;
    final bool permanentlyDenied = (location?.error ?? '').contains('permanently denied');

    late final IconData icon;
    late final Color color;
    late final String title;
    late final String subtitle;

    if (locating) {
      icon = Icons.my_location_rounded;
      color = AppColors.brand;
      title = 'Getting your location...';
      subtitle = 'This uses your device GPS, not the app\'s sample location.';
    } else if (found) {
      icon = Icons.check_circle_rounded;
      color = AppColors.live;
      title = 'Live location found';
      subtitle = '${location!.latitude!.toStringAsFixed(5)}, ${location!.longitude!.toStringAsFixed(5)}';
    } else {
      icon = Icons.location_off_rounded;
      color = AppColors.warn;
      title = location?.error ?? 'Location unavailable';
      subtitle = 'Using your saved location instead: $fallbackText';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                if (!locating) ...<Widget>[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: onRefresh,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Try again', style: TextStyle(fontSize: 12.5)),
                      ),
                      if (permanentlyDenied)
                        OutlinedButton.icon(
                          onPressed: onOpenSettings,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: const Icon(Icons.settings_rounded, size: 16),
                          label: const Text('Open settings', style: TextStyle(fontSize: 12.5)),
                        ),
                    ],
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.sending,
    required this.onSend,
    required this.onRemove,
  });

  final EmergencyContact contact;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brandDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(contact.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove contact',
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
            visualDensity: VisualDensity.compact,
          ),
          FilledButton.icon(
            onPressed: sending ? null : onSend,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 38),
            ),
            icon: sending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.chat_rounded, size: 16),
            label: const Text('Send', style: TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
