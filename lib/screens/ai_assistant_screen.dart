import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/ai_chat_message.dart';
import '../models/models.dart';
import '../nav.dart';
import '../services/ai_service.dart';
import '../services/trip_agent.dart';
import '../services/voice_input_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/itinerary_card.dart';
import 'active_ticket_screen.dart';

/// "MBMT Assistant" - greets the user, asks where they want to go, then plans
/// a real door-to-door MBMT trip (bus legs, transfers, walking, and an
/// auto-rickshaw fallback when no route is known) using [TripAgent], and can
/// book a real digital ticket once the user confirms. Supports typed or
/// spoken input and replies in the app's selected language.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<AiChatMessage> _messages = <AiChatMessage>[];
  final TripAgent _agent = TripAgent();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _sending = false;
  bool _recording = false;
  bool _transcribing = false;
  String? _error;
  bool _greeted = false;

  static const List<String> _suggestedPrompts = <String>[
    'How do I get to Thane Station?',
    'Fare from Bhayandar to Mira Road',
    'Book me a ticket to Bhayandar Station',
    'Which bus goes to Uttan?',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_greeted) {
      _greeted = true;
      final AppState s = AppScope.of(context);
      _messages.add(AiChatMessage(role: AiRole.assistant, content: s.t('ai_greeting')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    if (VoiceInputService.instance.isRecording) {
      VoiceInputService.instance.cancel();
    }
    super.dispose();
  }

  List<AiChatMessage> _historyWindow() {
    const int maxTurns = 10;
    if (_messages.length <= maxTurns) return List<AiChatMessage>.of(_messages);
    return _messages.sublist(_messages.length - maxTurns);
  }

  /// Issues a real ticket via [AppState], exactly like the manual Buy Ticket
  /// -> Payment flow but skipping the payment step (this prototype already
  /// simulates payment everywhere else too). Called by [TripAgent] once the
  /// model has confirmed a direct, single-bus trip with the user.
  Ticket _issueBookedTicket(
    AppState s, {
    required String from,
    required String to,
    required String busNumber,
    required int fare,
    required int passengers,
  }) {
    final Bus bus = MockData.busByNumber(busNumber);
    final TicketDraft draft = TicketDraft(
      from: from,
      to: to,
      route: busNumber,
      fare: fare,
      count: passengers,
      vehicleNo: bus.vehicleNo,
    );
    s.setTicketDraft(draft);
    return s.issueTicket(draft);
  }

  Future<void> _send(String text) async {
    final String q = text.trim();
    if (q.isEmpty || _sending) return;

    final AppState s = AppScope.of(context);
    final List<AiChatMessage> history = _historyWindow();

    setState(() {
      _messages.add(AiChatMessage(role: AiRole.user, content: q));
      _sending = true;
      _error = null;
      _controller.clear();
    });
    _scrollToEnd();

    try {
      final AiTurnResult result = await _agent.respond(
        history: history,
        userMessage: q,
        languageCode: s.language,
        currentLocationStop: s.originStop,
        onBookTicket: ({
          required String from,
          required String to,
          required String busNumber,
          required int fare,
          required int passengers,
        }) =>
            _issueBookedTicket(
          s,
          from: from,
          to: to,
          busNumber: busNumber,
          fare: fare,
          passengers: passengers,
        ),
      );
      if (!mounted) return;
      setState(() {
        _messages.add(AiChatMessage(
          role: AiRole.assistant,
          content: result.reply,
          itineraries: result.itineraries,
          ticket: result.ticket,
        ));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _sending = false;
      });
    }
    _scrollToEnd();
  }

  Future<void> _toggleMic() async {
    if (_transcribing) return;

    if (_recording) {
      setState(() => _transcribing = true);
      String? text;
      String? failure;
      try {
        text = await VoiceInputService.instance.stopAndTranscribe();
      } catch (e) {
        failure = e.toString();
      }
      if (!mounted) return;
      setState(() {
        _recording = false;
        _transcribing = false;
      });
      if (failure != null) {
        showToast(context, failure, icon: Icons.error_outline_rounded);
      } else if (text != null && text.isNotEmpty) {
        await _send(text);
      } else {
        showToast(context, 'Could not hear anything - try again', icon: Icons.mic_off_rounded);
      }
      return;
    }

    final bool started = await VoiceInputService.instance.start();
    if (!mounted) return;
    if (started) {
      setState(() => _recording = true);
    } else {
      showToast(context, 'Microphone permission is needed for voice input',
          icon: Icons.mic_off_rounded);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState s = AppScope.of(context);
    final bool configured = AiService.instance.isConfigured;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(title: Text(s.t('ai_assistant'))),
      body: Column(
        children: <Widget>[
          if (!configured) _NotConfiguredBanner(text: s.t('ai_unconfigured')),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              children: <Widget>[
                for (final AiChatMessage m in _messages) _MessageBlock(message: m),
                if (_sending) const _TypingBubble(),
                if (_messages.length == 1 && !_sending)
                  _SuggestionRow(
                    prompts: _suggestedPrompts,
                    enabled: configured,
                    onPick: _send,
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                  ),
                ],
              ),
            ),
          _Composer(
            controller: _controller,
            enabled: configured && !_sending && !_transcribing,
            recording: _recording,
            transcribing: _transcribing,
            onSend: _send,
            onMic: configured ? _toggleMic : null,
          ),
        ],
      ),
    );
  }
}

class _NotConfiguredBanner extends StatelessWidget {
  const _NotConfiguredBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warnSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warn.withOpacity(0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warn),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.prompts, required this.enabled, required this.onPick});
  final List<String> prompts;
  final bool enabled;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: prompts
            .map((String p) => ActionChip(
                  label: Text(p),
                  onPressed: enabled ? () => onPick(p) : null,
                ))
            .toList(),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({required this.message});
  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.role == AiRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          _Bubble(isUser: isUser, text: message.content),
          if (message.itineraries != null && message.itineraries!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
              child: TripModeSelector(options: message.itineraries!),
            ),
          ],
          if (message.ticket != null) ...<Widget>[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
              child: _TicketConfirmationCard(ticket: message.ticket!),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.isUser, required this.text});
  final bool isUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
      decoration: BoxDecoration(
        color: isUser ? AppColors.brand : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        border: isUser ? null : Border.all(color: AppColors.line),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.5, height: 1.4, color: isUser ? Colors.white : AppColors.ink),
      ),
    );
  }
}

class _TicketConfirmationCard extends StatelessWidget {
  const _TicketConfirmationCard({required this.ticket});
  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.liveSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.live.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.live700),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Ticket booked',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.live700)),
              ),
              Text('₹${ticket.fare}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.live700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${ticket.from} → ${ticket.to}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'Bus ${ticket.route} · ${ticket.passengers} · ${ticket.id}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => pushPage(context, ActiveTicketScreen(ticket: ticket)),
              icon: const Icon(Icons.confirmation_number_rounded, size: 16),
              label: const Text('View Ticket'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.recording,
    required this.transcribing,
    required this.onSend,
    required this.onMic,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool recording;
  final bool transcribing;
  final ValueChanged<String> onSend;
  final VoidCallback? onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _MicButton(recording: recording, transcribing: transcribing, onTap: onMic),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled && !recording,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? onSend : null,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: recording
                      ? 'Listening...'
                      : enabled
                          ? 'Ask about a route, fare or pass...'
                          : 'Assistant unavailable',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: enabled ? AppColors.brand : AppColors.muted,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: enabled ? () => onSend(controller.text) : null,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.recording, required this.transcribing, required this.onTap});
  final bool recording;
  final bool transcribing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (transcribing) {
      return Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return Material(
      color: recording ? AppColors.danger : AppColors.brandSoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            recording ? Icons.stop_rounded : Icons.mic_none_rounded,
            color: recording ? Colors.white : AppColors.brand,
            size: 20,
          ),
        ),
      ),
    );
  }
}
