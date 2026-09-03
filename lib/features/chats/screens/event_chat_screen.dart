import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/supabase_client.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/event.dart';
import '../../home/providers/event_providers.dart';
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
  int _lastMessageCount = 0;
  bool _didInitialScroll = false;
  int _initialUnreadCount = 0;

  // Threshold in pixels below which we consider the user "at the bottom".
  // If they're within this of maxScrollExtent we auto-scroll on new msgs;
  // otherwise we leave them where they are so they can read history.
  static const double _autoScrollThreshold = 120;

  @override
  void initState() {
    super.initState();
    // Snapshot unread count BEFORE ChatController.build() adds this event to
    // activeChatEventIdsProvider (which suppresses the count to 0). The raw
    // RPC cache still holds the real value because markRead() hasn't fired yet.
    _initialUnreadCount = ref
            .read(unreadCountsProvider)
            .valueOrNull?[widget.eventId] ??
        0;
    // Mark the channel read as soon as the screen mounts — the ChatController
    // won't have resolved the channelId yet on the first frame, so poll
    // after the provider's first data.
    WidgetsBinding.instance.addPostFrameCallback((_) => _markReadIfReady());
  }

  @override
  void dispose() {
    // Best-effort second mark on close so anything received while viewing
    // is credited as read.
    ref
        .read(chatMessagesProvider(widget.eventId).notifier)
        .markRead(); // fire-and-forget
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _markReadIfReady() async {
    if (!mounted) return;
    await ref
        .read(chatMessagesProvider(widget.eventId).notifier)
        .markRead();
  }

  Future<void> _send() async {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await ref
        .read(chatMessagesProvider(widget.eventId).notifier)
        .sendMessage(text);
    // Sender should always end up looking at their new message.
    _jumpToBottomSoon();
  }

  bool _isNearBottom() {
    if (!_scroll.hasClients) return true;
    final double pos = _scroll.position.pixels;
    final double max = _scroll.position.maxScrollExtent;
    return (max - pos) <= _autoScrollThreshold;
  }

  void _jumpToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _animateToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _scrollToFirstUnreadSoon(int totalMessages) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final double max = _scroll.position.maxScrollExtent;
      if (max <= 0) return;
      final int firstUnreadIndex = totalMessages - _initialUnreadCount;
      final double target =
          (max * firstUnreadIndex / totalMessages).clamp(0.0, max);
      _scroll.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Event? event = ref.watch(eventByIdProvider(widget.eventId));
    if (event == null) {
      return const Scaffold(body: Center(child: Text('Chat not found')));
    }

    final AsyncValue<List<ChatMessage>> chatAsync =
        ref.watch(chatMessagesProvider(widget.eventId));

    // WhatsApp behaviour: on very first data load, jump straight to the
    // newest message; on subsequent additions, animate down ONLY if the
    // user is already near the bottom (so browsing history isn't yanked).
    chatAsync.whenData((msgs) {
      if (!_didInitialScroll && msgs.isNotEmpty) {
        _didInitialScroll = true;
        _lastMessageCount = msgs.length;
        if (_initialUnreadCount > 0 && _initialUnreadCount < msgs.length) {
          _scrollToFirstUnreadSoon(msgs.length);
        } else {
          _jumpToBottomSoon();
        }
        return;
      }
      if (msgs.length != _lastMessageCount) {
        final bool wasAtBottom = _isNearBottom();
        _lastMessageCount = msgs.length;
        if (wasAtBottom) _animateToBottomSoon();
      }
    });

    final bool archived = event.isPast && !event.isWithinPostEventWindow;
    final String? myId = SupabaseService.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: _ChatHeader(event: event),
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: chatAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.magenta),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      "Couldn't load this chat: $e",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Say hi — nobody has said anything yet.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scroll,
                    // Not inverted — ascending timeline, newest at bottom.
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final ChatMessage msg = messages[i];
                      if (msg.isSystem) return _SystemBubble(text: msg.text);
                      final bool mine = msg.senderId != null &&
                          myId != null &&
                          msg.senderId == myId;
                      return _MessageBubble(
                        msg: msg,
                        mine: mine,
                        onRetry: msg.status == ChatMessageStatus.failed &&
                                msg.clientTempId != null
                            ? () => ref
                                .read(chatMessagesProvider(widget.eventId)
                                    .notifier)
                                .retry(msg.clientTempId!)
                            : null,
                      );
                    },
                  );
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

/// Cover + title + live member count. Tapping anywhere opens event detail.
class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int memberCount = event.rsvpCount;
    return InkWell(
      onTap: () => context.push(RoutePaths.eventDetail(event.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: event.coverImageUrl.isEmpty
                    ? Container(color: AppColors.surface)
                    : CachedNetworkImage(
                        imageUrl: event.coverImageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    event.title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
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
          child: Text(text,
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        ),
      ),
    );
  }
}

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
  const _MessageBubble({
    required this.msg,
    required this.mine,
    this.onRetry,
  });
  final ChatMessage msg;
  final bool mine;
  final VoidCallback? onRetry;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            bubble,
            Padding(
              padding: const EdgeInsets.only(right: 4, top: 2, bottom: 2),
              child: _StatusIndicator(status: msg.status, onRetry: onRetry),
            ),
          ],
        ),
      );
    }

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
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.w600),
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

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status, this.onRetry});
  final ChatMessageStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ChatMessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.textSecondary,
          ),
        );
      case ChatMessageStatus.sent:
        return const Icon(Icons.check,
            size: 14, color: AppColors.textSecondary);
      case ChatMessageStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 14, color: AppColors.error),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
    }
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
                child: Icon(Icons.send,
                    color: AppColors.textOnDark, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
