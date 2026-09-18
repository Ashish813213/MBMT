import 'package:url_launcher/url_launcher.dart';

import 'location_service.dart';

/// Builds the SOS message and hands it to WhatsApp via a `wa.me` click-to-chat
/// link - no WhatsApp API keys or contact-book access needed, just a normal
/// URL that opens a chat with the message pre-filled.
class SosService {
  SosService._();

  static String buildMessage({
    String? busNumber,
    String? destination,
    required LocationResult location,
    required String fallbackLocationText,
  }) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('\u{1F198} SOS - I need help, please check on me.');

    if (busNumber != null && busNumber.trim().isNotEmpty) {
      final String towards =
          (destination != null && destination.trim().isNotEmpty) ? ' towards $destination' : '';
      buffer.writeln('I am on MBMT Bus $busNumber$towards.');
    }

    if (location.hasCoordinates) {
      buffer.writeln(
        'My live location: https://maps.google.com/?q=${location.latitude},${location.longitude}',
      );
    } else {
      buffer.writeln('My approximate location: $fallbackLocationText');
    }

    buffer.write('Sent from the MBMT Smart Bus app.');
    return buffer.toString();
  }

  /// Opens a WhatsApp chat with [phone] and [message] pre-filled. Returns
  /// false if nothing could handle the link (e.g. WhatsApp not installed and
  /// no browser available), so the caller can show a fallback message.
  static Future<bool> sendViaWhatsApp({required String phone, required String message}) async {
    final String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return false;
    final Uri uri = Uri.parse('https://wa.me/$digits?text=${Uri.encodeComponent(message)}');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
