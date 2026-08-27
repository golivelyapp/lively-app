import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/event.dart';
import '../../home/providers/event_providers.dart';
import '../../onboarding/providers/onboarding_draft_controller.dart';
import '../models/chat_message.dart';
import '../providers/event_chat_provider.dart';

class EventChatScreen extends ConsumerStatefulWidget {
  const EventChatScreen({required this.eventId, super.key});
  final String eventId;

  @override
  ConsumerState<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends ConsumerState<EventChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    final String me = ref.read(onboardingDraftProvider).name ?? 'You';
    ref.read(eventChatsProvider.notifier).sendMessage(
          eventId: widget.eventId,
          senderName: me,
          text: text,
        );
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Event? event = ref.watch(eventByIdProvider(widget.eventId));
    if (event == null) {
      return const Scaffold(body: Center(child: Text('Chat not found')));
    }
    final List<ChatMessage> messages =
        ref.watch(eventChatsProvider)[widget.eventId] ?? const <ChatMessage>[];
    final bool archived = event.isPast && !event.isWithinPostEventWindow;
    final String myName = ref.watch(onboardingDraftProvider).name ?? 'You';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: <Widget>[
            SizedBox(
              width: 32,
              height: 32,
              child: ClipOval(
                child: event.coverImageUrl.isEmpty
                    ? Container(color: AppColors.surface)
                    : CachedNetworkImage(imageUrl: event.coverImageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                event.title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final ChatMessage msg = messages[i];
                  if (msg.isSystem) return _SystemBubble(text: msg.text);
                  final bool mine = msg.senderName == myName;
                  return _MessageBubble(msg: msg, mine: mine);
                },
              ),
            ),
            if (archived)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.surface,
                child: Text(
                  'This chat is archived. You can still read messages, but new ones are disabled.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              )
            else
              _ChatInput(controller: _input, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  const _SystemBubble({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(text, textAlign: TextAlign.center, style: AppTextStyles.caption),
        ),
      ),
    );
  }
}

/// Deterministic avatar background so the same sender always gets the
/// same colour across sessions — helps identification at a glance even
/// before we have real profile photos for other attendees.
class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.name});
  final String name;
  static const List<Color> _palette = <Color>[
    AppColors.coral,
    AppColors.magenta,
    AppColors.pink,
    AppColors.gold,
    AppColors.balanceWomen,
    AppColors.balanceMen,
  ];
  @override
  Widget build(BuildContext context) {
    final int hash = name.codeUnits.fold<int>(0, (a, b) => a + b);
    final Color bg = _palette[hash % _palette.length];
    final String initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textOnDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.msg, required this.mine});
  final ChatMessage msg;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    final Widget bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: mine ? AppColors.magenta : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppSpacing.radiusMd),
          topRight: const Radius.circular(AppSpacing.radiusMd),
          bottomLeft: Radius.circular(mine ? AppSpacing.radiusMd : 4),
          bottomRight: Radius.circular(mine ? 4 : AppSpacing.radiusMd),
        ),
      ),
      child: Text(
        msg.text,
        style: AppTextStyles.body.copyWith(
          color: mine ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
    );

    if (mine) {
      return Align(
        alignment: Alignment.centerRight,
        child: bubble,
      );
    }

    // Non-mine messages get an avatar + name so it's always obvious who
    // said what — the previous version only showed the name label,
    // which several users missed at a glance.
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SenderAvatar(name: msg.senderName),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    msg.senderName,
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                bubble,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(hintText: 'Say something…'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.magenta,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.send, color: AppColors.textOnDark, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
